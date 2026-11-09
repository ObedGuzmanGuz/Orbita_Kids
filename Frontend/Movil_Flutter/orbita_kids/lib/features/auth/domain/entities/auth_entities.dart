import 'package:meta/meta.dart';

enum UserRole { student, teacher }

/// Método de acceso. Todos pasan por Keycloak (OIDC + PKCE).
enum AuthMethod { orbita, google, facebook, institution }

extension AuthMethodText on AuthMethod {
  String get label => switch (this) {
    AuthMethod.orbita => 'Órbita Kids',
    AuthMethod.google => 'Google',
    AuthMethod.facebook => 'Facebook',
    AuthMethod.institution => 'tu institución',
  };
}

@immutable
class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.role,
    required this.method,
    required this.methodLabel,
    this.email,
    this.username,
    this.groupId,
    this.institution,
  });

  final String id;
  final String name;
  final UserRole role;
  final AuthMethod method;

  /// Descripción del método vinculado (p. ej. «Google Workspace for Education»).
  final String methodLabel;
  final String? email;
  final String? username;
  final String? groupId;
  final String? institution;

  bool get isTeacher => role == UserRole.teacher;

  AppUser copyWith({
    String? name,
    UserRole? role,
    String? email,
    String? username,
    String? groupId,
    String? institution,
  }) => AppUser(
    id: id,
    name: name ?? this.name,
    role: role ?? this.role,
    method: method,
    methodLabel: methodLabel,
    email: email ?? this.email,
    username: username ?? this.username,
    groupId: groupId ?? this.groupId,
    institution: institution ?? this.institution,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'role': role.name,
    'method': method.name,
    'methodLabel': methodLabel,
    'email': email,
    'username': username,
    'groupId': groupId,
    'institution': institution,
  };

  factory AppUser.fromJson(Map<String, dynamic> j) => AppUser(
    id: j['id'] as String,
    name: j['name'] as String,
    role: UserRole.values.byName(j['role'] as String),
    method: AuthMethod.values.byName(j['method'] as String),
    methodLabel: j['methodLabel'] as String? ?? '',
    email: j['email'] as String?,
    username: j['username'] as String?,
    groupId: j['groupId'] as String?,
    institution: j['institution'] as String?,
  );
}

/// Sesión persistida en almacenamiento seguro.
@immutable
class Session {
  const Session({
    required this.user,
    required this.expiresAt,
    this.accessToken,
    this.refreshToken,
    this.idToken,
    this.demo = false,
  });

  final AppUser user;
  final String? accessToken;
  final String? refreshToken;
  final String? idToken;
  final DateTime expiresAt;

  /// Sesión de demostración (sin Keycloak).
  final bool demo;

  bool isExpired(DateTime now) => !now.isBefore(expiresAt);

  Session copyWith({
    AppUser? user,
    String? accessToken,
    String? refreshToken,
    String? idToken,
    DateTime? expiresAt,
  }) => Session(
    user: user ?? this.user,
    accessToken: accessToken ?? this.accessToken,
    refreshToken: refreshToken ?? this.refreshToken,
    idToken: idToken ?? this.idToken,
    expiresAt: expiresAt ?? this.expiresAt,
    demo: demo,
  );

  Map<String, dynamic> toJson() => {
    'user': user.toJson(),
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'idToken': idToken,
    'expiresAt': expiresAt.toIso8601String(),
    'demo': demo,
  };

  factory Session.fromJson(Map<String, dynamic> j) => Session(
    user: AppUser.fromJson(Map<String, dynamic>.from(j['user'] as Map)),
    accessToken: j['accessToken'] as String?,
    refreshToken: j['refreshToken'] as String?,
    idToken: j['idToken'] as String?,
    expiresAt: DateTime.parse(j['expiresAt'] as String),
    demo: j['demo'] as bool? ?? false,
  );
}

/// Resultados de autenticación que no son un inicio exitoso. Cada uno tiene
/// su variante en la pantalla «Estados de autenticación».
enum AuthFailureCode {
  cancelled,
  providerError,
  notRegistered,
  blocked,
  noRole,
  unavailable,
  expired,
  network,
  linking,
  backend,
  notConfigured,
}

class AuthFailure implements Exception {
  const AuthFailure(this.code, {this.method = AuthMethod.orbita, this.detail});
  final AuthFailureCode code;
  final AuthMethod method;
  final String? detail;

  @override
  String toString() =>
      'AuthFailure(${code.name}${detail == null ? '' : ': $detail'})';
}

/// Credenciales incorrectas en el formulario (solo modo demo).
class InvalidCredentials implements Exception {
  const InvalidCredentials(this.remaining, {this.lock = LoginLock.none});
  final int remaining;

  /// Intentos fallidos acumulados tras este error.
  final LoginLock lock;
}

/// Cuenta pausada por intentos fallidos.
class AccountLocked implements Exception {
  const AccountLocked(this.until);
  final DateTime until;
}

/// Identidad de demostración elegible en el selector de proveedor demo.
@immutable
class DemoIdentity {
  const DemoIdentity(this.label, this.sub, {this.accountId, this.result});
  final String label;
  final String sub;

  /// Cuenta demo con la que entra, o `null` si lleva a un estado de error.
  final String? accountId;
  final AuthFailureCode? result;
}

/// Intentos fallidos y pausa de la cuenta.
@immutable
class LoginLock {
  const LoginLock({this.fails = 0, this.until});
  final int fails;
  final DateTime? until;

  static const none = LoginLock();

  bool isLocked(DateTime now) => until != null && until!.isAfter(now);
}

/// Resultado de validar un código de grupo (pantalla 11).
@immutable
class GroupCodeCheck {
  const GroupCodeCheck.valid(this.groupName) : error = null;
  const GroupCodeCheck.invalid(this.error) : groupName = null;

  final String? groupName;
  final String? error;

  bool get ok => groupName != null;
}
