// Base de datos SQLite (módulo integrado de Node 22: node:sqlite). Un solo archivo, sin servidor aparte.
import { mkdirSync } from 'node:fs'
import { dirname, join } from 'node:path'
import { fileURLToPath } from 'node:url'
import { DatabaseSync } from 'node:sqlite'
import { seed } from './seed.js'

const here = dirname(fileURLToPath(import.meta.url))
export const DEFAULT_DB_PATH = join(here, 'data', 'orbita.sqlite')

const SCHEMA = `
CREATE TABLE IF NOT EXISTS schools (
  id          TEXT PRIMARY KEY,
  name        TEXT NOT NULL,
  plan        TEXT NOT NULL,
  cycle       TEXT NOT NULL,
  seats_total INTEGER NOT NULL,
  settings    TEXT NOT NULL DEFAULT '{}'
);

-- Cuentas que pueden iniciar sesión (personal de la escuela y estudiantes).
CREATE TABLE IF NOT EXISTS users (
  id            TEXT PRIMARY KEY,
  school_id     TEXT REFERENCES schools(id),
  username      TEXT NOT NULL UNIQUE,
  email         TEXT NOT NULL UNIQUE,
  name          TEXT NOT NULL,
  short         TEXT NOT NULL,
  initials      TEXT NOT NULL,
  color         TEXT NOT NULL,
  role_label    TEXT NOT NULL,
  kind          TEXT NOT NULL DEFAULT 'staff',   -- staff | student
  status        TEXT NOT NULL DEFAULT 'active',  -- active | invited
  spaces        TEXT NOT NULL DEFAULT '[]',      -- JSON: ["docente", "institucion"]
  password_hash TEXT,                            -- scrypt; nunca la contraseña
  two_factor    INTEGER NOT NULL DEFAULT 0,
  data_key      TEXT NOT NULL,                   -- llave AES-256 con la que el navegador cifra la caché de esta cuenta
  failed_logins INTEGER NOT NULL DEFAULT 0,
  locked_until  INTEGER,
  prefs         TEXT NOT NULL DEFAULT '{}',
  created_at    INTEGER NOT NULL
);

-- Sesiones abiertas. Se guarda el SHA-256 del token: el token real solo vive en la cookie del navegador.
CREATE TABLE IF NOT EXISTS sessions (
  id           TEXT PRIMARY KEY,
  user_id      TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  method       TEXT NOT NULL,                    -- password | google | microsoft | invitation
  user_agent   TEXT,
  created_at   INTEGER NOT NULL,
  last_seen_at INTEGER NOT NULL,
  expires_at   INTEGER NOT NULL
);

-- Verificación en dos pasos pendiente.
CREATE TABLE IF NOT EXISTS challenges (
  id         TEXT PRIMARY KEY,
  user_id    TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  method     TEXT NOT NULL,
  code_hash  TEXT NOT NULL,
  attempts   INTEGER NOT NULL DEFAULT 0,
  remember   INTEGER NOT NULL DEFAULT 0,
  expires_at INTEGER NOT NULL
);

-- Plantilla docente de la escuela (incluye invitaciones y solicitudes que aún no son cuentas activas).
CREATE TABLE IF NOT EXISTS staff (
  id         TEXT PRIMARY KEY,
  school_id  TEXT NOT NULL REFERENCES schools(id),
  user_id    TEXT REFERENCES users(id),
  name       TEXT NOT NULL,
  initials   TEXT NOT NULL,
  color      TEXT NOT NULL,
  email      TEXT NOT NULL UNIQUE,
  status     TEXT NOT NULL,                      -- active | request | invited | disabled
  note       TEXT,
  last       TEXT NOT NULL DEFAULT '—',
  director   INTEGER NOT NULL DEFAULT 0,
  created_at INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS class_groups (
  id                 TEXT PRIMARY KEY,
  school_id          TEXT NOT NULL REFERENCES schools(id),
  teacher_id         TEXT REFERENCES staff(id),
  support_teacher_id TEXT REFERENCES staff(id),
  name               TEXT NOT NULL,
  short              TEXT NOT NULL,
  level              TEXT NOT NULL,
  grade              INTEGER NOT NULL,
  code               TEXT NOT NULL UNIQUE,
  seats              INTEGER NOT NULL,
  until              TEXT NOT NULL,
  status             TEXT NOT NULL,              -- active | expiring | full | archived
  cycle              TEXT NOT NULL,              -- ciclo escolar, p. ej. 2026-27
  join_requests      INTEGER NOT NULL DEFAULT 0,
  completed          INTEGER NOT NULL DEFAULT 0,
  report             TEXT NOT NULL DEFAULT '{}'  -- reporte precalculado del mes (JSON)
);

CREATE TABLE IF NOT EXISTS students (
  id       TEXT PRIMARY KEY,
  group_id TEXT NOT NULL REFERENCES class_groups(id),
  name     TEXT NOT NULL,
  initials TEXT NOT NULL,
  color    TEXT NOT NULL,
  score    INTEGER NOT NULL,
  attempts INTEGER NOT NULL,
  pending  INTEGER NOT NULL,
  status   TEXT NOT NULL,                        -- support | idle | ok
  last     TEXT NOT NULL,
  topic    TEXT
);

CREATE TABLE IF NOT EXISTS activities (
  id           TEXT PRIMARY KEY,
  teacher_id   TEXT NOT NULL REFERENCES staff(id),
  group_id     TEXT NOT NULL REFERENCES class_groups(id),
  name         TEXT NOT NULL,
  mode         TEXT NOT NULL,                    -- visual | select | both
  level        INTEGER NOT NULL,
  count        INTEGER NOT NULL,
  due          TEXT,                             -- AAAA-MM-DD
  status       TEXT NOT NULL,                    -- active | scheduled | draft | closed
  done         INTEGER NOT NULL DEFAULT 0,
  total        INTEGER NOT NULL DEFAULT 0,
  instructions TEXT NOT NULL DEFAULT '',
  recipients   TEXT NOT NULL DEFAULT 'all',
  created_at   INTEGER NOT NULL,
  updated_at   INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS reinforcements (
  id         TEXT PRIMARY KEY,
  student_id TEXT NOT NULL REFERENCES students(id),
  teacher_id TEXT NOT NULL REFERENCES staff(id),
  topic      TEXT NOT NULL,
  created_at INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS notices (
  id         TEXT PRIMARY KEY,
  user_id    TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  space      TEXT NOT NULL,                      -- docente | institucion
  icon       TEXT NOT NULL,
  title      TEXT NOT NULL,
  meta       TEXT NOT NULL,
  to_path    TEXT NOT NULL,
  unread     INTEGER NOT NULL DEFAULT 1,
  created_at INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS invitations (
  token      TEXT PRIMARY KEY,
  staff_id   TEXT NOT NULL REFERENCES staff(id),
  invited_by TEXT NOT NULL,
  groups     TEXT NOT NULL DEFAULT '[]',
  expires    TEXT NOT NULL,
  status     TEXT NOT NULL DEFAULT 'pending'     -- pending | accepted | rejected
);

-- Reportes agregados que en un sistema real calcula un proceso nocturno.
CREATE TABLE IF NOT EXISTS reports (
  scope TEXT PRIMARY KEY,                        -- teacher:<id> | school:<id>
  data  TEXT NOT NULL
);

-- Registro de cambios recibidos. El id lo genera el navegador (chg-xxxxxx): si llega dos veces, no se aplica dos veces.
CREATE TABLE IF NOT EXISTS changes (
  id          TEXT PRIMARY KEY,
  user_id     TEXT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  type        TEXT NOT NULL,
  payload     TEXT NOT NULL,
  title       TEXT NOT NULL,
  icon        TEXT NOT NULL DEFAULT '133',
  status      TEXT NOT NULL,                     -- applied | rejected
  error       TEXT,
  created_at  INTEGER,                           -- cuándo se hizo en el equipo
  received_at INTEGER NOT NULL                   -- cuándo llegó al servidor
);

-- Solicitudes del sitio público y otras peticiones que atiende una persona.
CREATE TABLE IF NOT EXISTS requests (
  id         TEXT PRIMARY KEY,
  kind       TEXT NOT NULL,                      -- contact | plan | group | recover | access
  data       TEXT NOT NULL,
  created_at INTEGER NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_students_group ON students(group_id);
CREATE INDEX IF NOT EXISTS idx_activities_teacher ON activities(teacher_id);
CREATE INDEX IF NOT EXISTS idx_notices_user ON notices(user_id, space);
CREATE INDEX IF NOT EXISTS idx_sessions_user ON sessions(user_id);
CREATE INDEX IF NOT EXISTS idx_changes_user ON changes(user_id, received_at);
`

export async function openDb(path = process.env.DB_PATH || DEFAULT_DB_PATH) {
  if (path !== ':memory:') mkdirSync(dirname(path), { recursive: true })
  const db = new DatabaseSync(path)
  db.exec('PRAGMA journal_mode = WAL; PRAGMA foreign_keys = ON; PRAGMA busy_timeout = 3000;')
  db.exec(SCHEMA)
  const { n } = db.prepare('SELECT COUNT(*) AS n FROM users').get()
  if (n === 0) await seed(db)
  return db
}

// Ejecuta varias escrituras como una sola: o se guardan todas o ninguna.
export function transaction(db, fn) {
  db.exec('BEGIN IMMEDIATE')
  try {
    const result = fn()
    db.exec('COMMIT')
    return result
  } catch (error) {
    db.exec('ROLLBACK')
    throw error
  }
}

export const json = (value, fallback) => {
  try {
    return value == null ? fallback : JSON.parse(value)
  } catch {
    return fallback
  }
}
