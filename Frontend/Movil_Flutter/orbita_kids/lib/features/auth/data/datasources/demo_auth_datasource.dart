import 'package:orbita_kids/features/auth/domain/entities/auth_entities.dart';
import 'package:orbita_kids/shared/data/demo/demo_data.dart';

/// ======================== MODO DEMO ========================
/// Cuentas ficticias del prototipo. No hay red ni tokens reales.
abstract final class DemoAuthDataSource {
  static const accounts = <String, (String user, String pass, AppUser)>{
    'u-luna': (
      'luna.astro',
      'orbita123',
      AppUser(
        id: 'u-luna',
        name: 'Luna',
        role: UserRole.student,
        method: AuthMethod.orbita,
        methodLabel: 'Cuenta Órbita Kids administrada por la escuela',
        username: 'luna.astro',
        groupId: DemoData.studentGroupId,
        institution: 'Escuela Primaria Demo Órbita',
      ),
    ),
    'u-ana': (
      'ana.rios',
      'orbita123',
      AppUser(
        id: 'u-ana',
        name: 'Ana Ríos',
        role: UserRole.teacher,
        method: AuthMethod.google,
        methodLabel: 'Google Workspace for Education',
        email: 'ana.rios@escuela.example',
        username: 'ana.rios',
        institution: 'Escuela Primaria Demo Órbita',
      ),
    ),
  };

  static const identities = <AuthMethod, List<DemoIdentity>>{
    AuthMethod.google: [
      DemoIdentity(
        'ana.rios@escuela.example',
        'Docente · Google Workspace de la escuela',
        accountId: 'u-ana',
      ),
      DemoIdentity(
        'adulto.responsable@correo.example',
        'Adulto que administra la cuenta de Luna (2° A)',
        accountId: 'u-luna',
      ),
      DemoIdentity(
        'nuevo.docente@correo.example',
        'Identidad sin cuenta en Órbita Kids',
        result: AuthFailureCode.notRegistered,
      ),
      DemoIdentity(
        'ana.personal@correo.example',
        'Mismo correo que una cuenta existente',
        result: AuthFailureCode.linking,
      ),
    ],
    AuthMethod.facebook: [
      DemoIdentity('Ana Ríos', 'Docente', accountId: 'u-ana'),
      DemoIdentity(
        'Adulto responsable de Luna',
        'Administra la cuenta de Luna (2° A)',
        accountId: 'u-luna',
      ),
      DemoIdentity(
        'Perfil sin rol',
        'Registrado, pero sin rol asignado',
        result: AuthFailureCode.noRole,
      ),
    ],
  };

  static const institutionIdentities = <String, List<DemoIdentity>>{
    'edu1': [
      DemoIdentity(
        'luna.m@alumnos.escuela.example',
        'Estudiante · 2° A',
        accountId: 'u-luna',
      ),
      DemoIdentity('ana.rios@escuela.example', 'Docente', accountId: 'u-ana'),
    ],
    'edu2': [
      DemoIdentity(
        'docente@horizonte.example',
        'Docente sin licencia activa',
        result: AuthFailureCode.noRole,
      ),
    ],
    'edu3': [],
  };

  /// Escenarios de error que se pueden probar en modo demo.
  static const scenarios = <(AuthFailureCode, String)>[
    (AuthFailureCode.cancelled, 'Cancelar inicio de sesión'),
    (AuthFailureCode.providerError, 'Error del proveedor'),
    (AuthFailureCode.unavailable, 'Proveedor no disponible'),
    (AuthFailureCode.blocked, 'Cuenta bloqueada'),
    (AuthFailureCode.backend, 'Error de comunicación con backend'),
    (AuthFailureCode.network, 'Se perdió la conexión'),
  ];

  static const unlockCode = '482915';

  static Session sessionFor(String accountId) {
    final a = accounts[accountId]!.$3;
    return Session(
      user: a,
      expiresAt: DateTime.now().add(const Duration(days: 30)),
      demo: true,
    );
  }

  /// Valida usuario y contraseña de las cuentas demo.
  static AppUser? check(String username, String password) {
    for (final a in accounts.values) {
      if (a.$1.toLowerCase() == username.trim().toLowerCase() &&
          a.$2 == password) {
        return a.$3;
      }
    }
    return null;
  }
}
