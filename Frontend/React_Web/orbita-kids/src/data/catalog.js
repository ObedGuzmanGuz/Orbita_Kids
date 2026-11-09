// Catálogos de la interfaz: etiquetas de estado y la tabla de planes.
// Los datos de cada escuela (grupos, estudiantes, actividades…) llegan del servidor por /api/data.

// Estudiantes: 'support' (Necesita apoyo), 'idle' (Sin actividad reciente), 'ok' (Al día)
export const STATUS = {
  support: { label: 'Necesita apoyo', tag: 'tag--warning' },
  idle: { label: 'Sin actividad reciente', tag: '' },
  ok: { label: 'Al día', tag: 'tag--success' },
}

export const ACTIVITY_STATUS = {
  active: { label: 'Activa', tag: 'tag--success', filter: 'Activas' },
  scheduled: { label: 'Programada', tag: 'tag--primary', filter: 'Programadas' },
  draft: { label: 'Borrador', tag: 'tag--warning', filter: 'Borradores' },
  closed: { label: 'Cerrada', tag: '', filter: 'Cerradas' },
}

export const TEACHER_STATUS = {
  active: { label: 'Activo', tag: 'tag--success' },
  request: { label: 'Solicitud', tag: 'tag--warning' },
  invited: { label: 'Invitado', tag: 'tag--primary' },
  disabled: { label: 'Desactivado', tag: '' },
}

export const GROUP_STATUS = {
  active: { label: 'Activo', tag: 'tag--success' },
  expiring: { label: 'Vence pronto', tag: 'tag--warning' },
  full: { label: 'Sin lugares', tag: 'tag--danger' },
  archived: { label: 'Archivado', tag: '' },
}

export const PLANS = {
  headers: ['Gratuito', 'Aula', 'Escuela · actual', 'Licencia institucional'],
  rows: [
    ['Precio anual', '$0', '$8,150', '$18,350', '$50,990'],
    ['Estudiantes', 'Por definir', '50', '150', '500'],
    ['Docentes', 'Por definir', '5', 'Sin límite', 'Sin límite'],
    ['Panel institucional', '—', '—', 'Sí', 'Varios planteles'],
    ['Inicio de sesión institucional', '—', '—', 'Google o Microsoft', 'OIDC o SAML'],
    ['Reportes', 'Básicos', 'Básicos', 'Ampliados', 'Por plantel'],
  ],
}
