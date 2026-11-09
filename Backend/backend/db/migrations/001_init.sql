-- Órbita Kids · esquema inicial.
-- Todas las fechas se guardan en UTC (DATETIME(3), la conexión usa +00:00).
-- Los IDs que genera la app (actividades, intentos, solicitudes) son UUID v4 y
-- funcionan como clave de idempotencia de la cola de sincronización.

CREATE TABLE institutions (
  id          CHAR(36)     NOT NULL,
  name        VARCHAR(160) NOT NULL,
  -- Alias del IdP en Keycloak (kc_idp_hint), si la institución tiene uno.
  idp_alias   VARCHAR(64)  NULL,
  created_at  DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Licencia de una institución: define cuántos estudiantes caben.
CREATE TABLE licenses (
  id              CHAR(36)     NOT NULL,
  institution_id  CHAR(36)     NOT NULL,
  plan_id         ENUM('free','aula','escuela','inst') NOT NULL,
  seats           INT UNSIGNED NOT NULL,
  starts_at       DATE         NOT NULL,
  ends_at         DATE         NULL,
  created_at      DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  KEY ix_licenses_institution (institution_id),
  CONSTRAINT fk_licenses_institution FOREIGN KEY (institution_id) REFERENCES institutions (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Usuarios. El ID es el `sub` de Keycloak; se crean al primer request
-- autenticado (aprovisionamiento just-in-time). El rol viene del token.
CREATE TABLE users (
  id              VARCHAR(64)  NOT NULL,
  role            ENUM('student','teacher') NOT NULL,
  name            VARCHAR(80)  NOT NULL,
  username        VARCHAR(80)  NULL,
  email           VARCHAR(160) NULL,
  -- Claim `identity_provider` (google, facebook, alias institucional...).
  idp             VARCHAR(64)  NULL,
  institution_id  CHAR(36)     NULL,
  -- Grupo actual del estudiante (null para docentes).
  group_id        CHAR(36)     NULL,
  -- AvatarLook de la app: {character, helmet, suit, accessory, expression}.
  look            JSON         NULL,
  version         INT UNSIGNED NOT NULL DEFAULT 1,
  last_seen_at    DATETIME(3)  NULL,
  created_at      DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at      DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  UNIQUE KEY ux_users_username (username),
  KEY ix_users_group (group_id),
  CONSTRAINT fk_users_institution FOREIGN KEY (institution_id) REFERENCES institutions (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Grupos escolares (GROUPS es palabra reservada en MySQL 8).
CREATE TABLE school_groups (
  id               CHAR(36)     NOT NULL,
  teacher_id       VARCHAR(64)  NOT NULL,
  institution_id   CHAR(36)     NULL,
  -- Sin licencia = plan gratuito sin límite de lugares definido todavía.
  license_id       CHAR(36)     NULL,
  name             VARCHAR(40)  NOT NULL,
  grade            VARCHAR(80)  NOT NULL,
  code             VARCHAR(12)  NOT NULL,
  code_expires_at  DATETIME(3)  NULL,
  status           ENUM('active','archived') NOT NULL DEFAULT 'active',
  version          INT UNSIGNED NOT NULL DEFAULT 1,
  created_at       DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at       DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  UNIQUE KEY ux_groups_code (code),
  KEY ix_groups_teacher (teacher_id, status),
  KEY ix_groups_license (license_id),
  CONSTRAINT fk_groups_teacher FOREIGN KEY (teacher_id) REFERENCES users (id),
  CONSTRAINT fk_groups_institution FOREIGN KEY (institution_id) REFERENCES institutions (id),
  CONSTRAINT fk_groups_license FOREIGN KEY (license_id) REFERENCES licenses (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

ALTER TABLE users
  ADD CONSTRAINT fk_users_group FOREIGN KEY (group_id) REFERENCES school_groups (id) ON DELETE SET NULL;

-- Actividades que publica o programa el docente (Activity en la app).
CREATE TABLE activities (
  id            CHAR(36)     NOT NULL,
  teacher_id    VARCHAR(64)  NOT NULL,
  group_id      CHAR(36)     NOT NULL,
  name          VARCHAR(80)  NOT NULL,
  type          ENUM('visual','choice','mix') NOT NULL,
  level         TINYINT UNSIGNED NOT NULL,
  count         TINYINT UNSIGNED NOT NULL,
  instructions  VARCHAR(500) NOT NULL DEFAULT '',
  assigned_at   DATETIME(3)  NOT NULL,
  due_at        DATETIME(3)  NOT NULL,
  -- Estado guardado. El estado efectivo (programada → activa → cerrada) se
  -- calcula con las fechas al leer.
  status        ENUM('draft','scheduled','active','closed') NOT NULL,
  version       INT UNSIGNED NOT NULL DEFAULT 1,
  created_at    DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at    DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  KEY ix_activities_group (group_id, status),
  KEY ix_activities_teacher (teacher_id),
  CONSTRAINT fk_activities_teacher FOREIGN KEY (teacher_id) REFERENCES users (id),
  CONSTRAINT fk_activities_group FOREIGN KEY (group_id) REFERENCES school_groups (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Resultado de una misión o tarea (SyncKind.attempt).
CREATE TABLE attempts (
  id              CHAR(36)     NOT NULL,
  student_id      VARCHAR(64)  NOT NULL,
  -- Grupo del estudiante cuando llegó el resultado (para reportes históricos).
  group_id        CHAR(36)     NULL,
  -- Misión del catálogo (m1…m18) o, en tareas asignadas, el ID de la actividad.
  mission_id      VARCHAR(64)  NOT NULL,
  activity_id     CHAR(36)     NULL,
  level           TINYINT UNSIGNED NOT NULL,
  first_try       SMALLINT UNSIGNED NOT NULL,
  total           SMALLINT UNSIGNED NOT NULL,
  attempts        SMALLINT UNSIGNED NOT NULL,
  stars           TINYINT UNSIGNED NOT NULL,
  support         BOOLEAN      NOT NULL DEFAULT FALSE,
  rule            VARCHAR(16)  NULL,
  notify_teacher  BOOLEAN      NOT NULL DEFAULT FALSE,
  attempt_ids     JSON         NULL,
  finished_at     DATETIME(3)  NOT NULL,
  received_at     DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  KEY ix_attempts_student (student_id, finished_at),
  KEY ix_attempts_group (group_id, finished_at),
  KEY ix_attempts_activity (activity_id, student_id),
  CONSTRAINT fk_attempts_student FOREIGN KEY (student_id) REFERENCES users (id),
  CONSTRAINT fk_attempts_group FOREIGN KEY (group_id) REFERENCES school_groups (id) ON DELETE SET NULL,
  CONSTRAINT fk_attempts_activity FOREIGN KEY (activity_id) REFERENCES activities (id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Solicitudes de información de planes (sin pagos).
CREATE TABLE plan_requests (
  id           CHAR(36)     NOT NULL,
  user_id      VARCHAR(64)  NOT NULL,
  plan_id      ENUM('free','aula','escuela','inst') NOT NULL,
  period       ENUM('mensual','anual') NOT NULL,
  institution  VARCHAR(160) NOT NULL,
  contact      VARCHAR(160) NOT NULL,
  students     INT UNSIGNED NOT NULL,
  message      TEXT         NULL,
  created_at   DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  KEY ix_plan_requests_user (user_id),
  CONSTRAINT fk_plan_requests_user FOREIGN KEY (user_id) REFERENCES users (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Reportes de problemas enviados desde Ayuda.
CREATE TABLE support_reports (
  id           CHAR(36)     NOT NULL,
  user_id      VARCHAR(64)  NOT NULL,
  topic        VARCHAR(80)  NOT NULL,
  text         TEXT         NOT NULL,
  app_version  VARCHAR(32)  NULL,
  created_at   DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  KEY ix_support_reports_user (user_id),
  CONSTRAINT fk_support_reports_user FOREIGN KEY (user_id) REFERENCES users (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
