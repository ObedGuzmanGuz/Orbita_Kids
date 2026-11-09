/**
 * Rol a partir de `realm_access.roles`. Docente tiene prioridad, igual que en
 * la app (`KeycloakAuthRepository._sessionFrom`).
 */
export function roleFromClaims(claims, { roleStudent, roleTeacher }) {
  const roles = new Set(claims?.realm_access?.roles ?? []);
  if (roles.has(roleTeacher)) return 'teacher';
  if (roles.has(roleStudent)) return 'student';
  return null;
}

/** Datos del perfil que se toman del token (mappers del README de la app). */
export function profileFromClaims(claims) {
  return {
    id: claims.sub,
    name: claims.given_name || claims.preferred_username || 'Astronauta',
    username: claims.preferred_username ?? null,
    email: claims.email ?? null,
    idp: claims.identity_provider ?? null,
  };
}
