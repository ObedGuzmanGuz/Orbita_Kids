// Datos que solo existen en la interfaz de acceso. La validación real ocurre en el servidor (/api/auth/*).

// Solo para mostrar la pista de la demostración en pantalla.
export const DEMO_PASSWORD = 'orbita'
export const DEMO_OTP = '246810'

// Identidades del proveedor SIMULADO (pantalla 05). En producción esta lista la muestra Google o Microsoft.
export const IDP_ACCOUNTS = [
  { letter: 'A', email: 'ana.rios@escuela.example', note: 'Docente · Google Workspace de la escuela' },
  { letter: 'L', email: 'laura.mendez@escuela.example', note: 'Dirección · administra la institución' },
  { letter: 'R', email: 'raul.dominguez@escuela.example', note: 'Docente invitado · aún no acepta' },
  { letter: 'N', email: 'nuevo.docente@correo.example', note: 'Identidad sin cuenta en Órbita Kids' },
  { letter: 'L', email: 'luna.m@alumnos.escuela.example', note: 'Cuenta de estudiante' },
]

// Qué pantalla mostrar según la respuesta del servidor.
export function routeForAuthError(error) {
  switch (error?.code) {
    case 'student':
      return '/acceso/estudiante'
    case 'no_role':
      return '/acceso/sin-rol'
    case 'locked':
      return '/acceso/bloqueada'
    case 'invited':
      return '/invitacion'
    default:
      return null
  }
}
