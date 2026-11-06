import 'package:orbita_kids/features/auth/domain/entities/auth_entities.dart';
import 'package:orbita_kids/shared/domain/entities/content.dart';

/// Proveedor de identidad (Keycloak con PKCE, o demo sin servidor).
abstract interface class AuthRepository {
  bool get isDemo;

  /// Inicio federado en el navegador seguro del sistema.
  Future<Session> signIn(
    AuthMethod method, {
    String? loginHint,
    bool register = false,
  });

  /// Formulario de la app (solo demo; con Keycloak la contraseña se escribe
  /// en su página). Devuelve `null` si las credenciales no coinciden.
  Future<Session?> signInWithPassword(String username, String password);

  /// Identidad elegida en el selector de demostración.
  Future<Session> signInDemoAccount(String accountId);

  /// Renueva tokens. Lanza [AuthFailure] `expired` si ya no es válida.
  Future<Session> refresh(Session session);

  /// Cierre de sesión en el proveedor (RP-initiated logout).
  Future<void> remoteSignOut(String? idToken);

  /// Valida el código de desbloqueo. Puede lanzar `BackendUnavailable`.
  Future<bool> unlock(String code);
}

/// Sesión y estado de bloqueo guardados de forma segura en el teléfono.
abstract interface class SessionRepository {
  Future<Session?> read();
  Future<void> save(Session session);
  Future<void> clear();

  Future<LoginLock> readLock();
  Future<void> saveLock(LoginLock lock);
  Future<void> clearLock();

  /// `id_token` guardado para completar un cierre remoto sin conexión.
  Future<String?> pendingLogout();
  Future<void> savePendingLogout(String idToken);
  Future<void> clearPendingLogout();
}

/// Perfil guardado en el backend (grupo, institución, nombre editado).
abstract interface class ProfileRepository {
  /// El usuario de la sesión completado con los datos del servidor, o `null`
  /// si no hay servidor o no respondió (se sigue con el usuario local).
  Future<AppUser?> fetch(AppUser local);
}

/// Registro: validaciones que dependen de la escuela o del servidor.
abstract interface class RegistrationRepository {
  Future<GroupCodeCheck> validateGroupCode(String code);
  Future<bool> isUsernameTaken(String username);
}

/// Datos del modo demo que la interfaz muestra (identidades ficticias).
abstract interface class DemoDirectory {
  List<DemoIdentity> identitiesFor(AuthMethod method);
  List<DemoIdentity> institutionIdentities(String institutionId);
  List<(AuthFailureCode, String)> get scenarios;
  List<Institution> institutions();
  String get unlockCode;
}
