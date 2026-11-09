import { query } from '../../db/pool.js';

const userColumns = `u.id, u.role, u.name, u.username, u.email, u.idp, u.institution_id, u.group_id,
  u.look, u.version`;

function toUser(r) {
  return {
    id: r.id,
    role: r.role,
    name: r.name,
    username: r.username,
    email: r.email,
    idp: r.idp,
    institutionId: r.institution_id,
    groupId: r.group_id,
    look: r.look,
    version: r.version,
  };
}

export async function findUser(id) {
  const [r] = await query(`SELECT ${userColumns} FROM users u WHERE u.id = ?`, [id]);
  return r ? toUser(r) : null;
}

/**
 * Crea o actualiza al usuario con los datos del token. El nombre solo se toma
 * del token al crear la cuenta: después lo controla «Editar perfil».
 */
export async function upsertFromToken({ id, role, name, username, email, idp }) {
  await query(
    `INSERT INTO users (id, role, name, username, email, idp, last_seen_at)
     VALUES (?, ?, ?, ?, ?, ?, UTC_TIMESTAMP(3)) AS new
     ON DUPLICATE KEY UPDATE
       role = new.role, username = new.username, email = new.email,
       idp = new.idp, last_seen_at = new.last_seen_at`,
    [id, role, name.slice(0, 80), username, email, idp],
  );
}

/** Perfil completo para `GET /v1/me`. */
export async function profileOf(id) {
  const [r] = await query(
    `SELECT ${userColumns}, g.name AS group_name, g.grade AS group_grade, i.name AS institution_name
     FROM users u
     LEFT JOIN school_groups g ON g.id = u.group_id
     LEFT JOIN institutions i ON i.id = COALESCE(u.institution_id, g.institution_id)
     WHERE u.id = ?`,
    [id],
  );
  if (!r) return null;
  const u = toUser(r);
  return {
    ...u,
    group: u.groupId ? { id: u.groupId, name: r.group_name, grade: r.group_grade } : null,
    institution: r.institution_name ?? null,
  };
}

/**
 * Cambia nombre y/o avatar. Si `expectedVersion` no es null y no coincide,
 * no toca nada y devuelve `false` (412 para la app).
 */
export async function updateProfile(id, { name, look }, expectedVersion) {
  const res = await query(
    `UPDATE users
     SET name = COALESCE(?, name), look = COALESCE(?, look), version = version + 1
     WHERE id = ? AND (? IS NULL OR version = ?)`,
    [name ?? null, look ? JSON.stringify(look) : null, id, expectedVersion, expectedVersion],
  );
  return res.affectedRows === 1;
}
