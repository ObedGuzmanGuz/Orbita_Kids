import 'package:orbita_kids/features/auth/domain/entities/auth_entities.dart';
import 'package:orbita_kids/features/auth/domain/repositories/auth_repositories.dart';

/// Pausa la cuenta tras 3 contraseñas incorrectas durante 15 minutos.
abstract final class LoginAttemptPolicy {
  static const maxAttempts = 3;
  static const lockDuration = Duration(minutes: 15);

  /// Una pausa vencida ya no cuenta.
  static LoginLock normalize(LoginLock l, DateTime now) =>
      l.until != null && !l.until!.isAfter(now) ? LoginLock.none : l;

  static LoginLock afterFailure(LoginLock l, DateTime now) {
    final fails = l.fails + 1;
    return LoginLock(
      fails: fails,
      until: fails >= maxAttempts ? now.add(lockDuration) : null,
    );
  }
}

/// Resultado de restaurar la sesión al abrir la app.
class RestoredSession {
  const RestoredSession({
    this.session,
    this.expired = false,
    this.lock = LoginLock.none,
  });
  final Session? session;
  final bool expired;
  final LoginLock lock;
}

/// Restaura la sesión guardada. Sin Internet se abre tal cual (offline
/// first); con Internet, una sesión vencida se renueva o se da por terminada.
class RestoreSession {
  const RestoreSession(this._auth, this._sessions);
  final AuthRepository _auth;
  final SessionRepository _sessions;

  Future<RestoredSession> call({
    required DateTime now,
    required bool online,
  }) async {
    final lock = LoginAttemptPolicy.normalize(await _sessions.readLock(), now);
    var s = await _sessions.read();
    if (s == null) return RestoredSession(lock: lock);
    if (s.isExpired(now) && online) {
      try {
        s = await _auth.refresh(s);
        await _sessions.save(s);
      } on AuthFailure catch (f) {
        if (f.code == AuthFailureCode.expired) {
          await _sessions.clear();
          return RestoredSession(expired: true, lock: lock);
        }
      }
    }
    return RestoredSession(session: s, lock: lock);
  }
}

/// Guarda (o no) la sesión recién iniciada y limpia los intentos fallidos.
class StartSession {
  const StartSession(this._sessions);
  final SessionRepository _sessions;

  Future<void> call(Session s, {required bool remember}) async {
    await _sessions.clearLock();
    remember ? await _sessions.save(s) : await _sessions.clear();
  }
}

/// Guarda la sesión actualizada si la persona pidió mantenerla.
class PersistSession {
  const PersistSession(this._sessions);
  final SessionRepository _sessions;

  Future<void> call(Session s, {required bool remember}) async {
    if (remember) await _sessions.save(s);
  }
}

/// Usuario y contraseña con bloqueo por intentos fallidos.
/// Lanza [AccountLocked] o [InvalidCredentials].
class SignInWithPassword {
  const SignInWithPassword(this._auth, this._sessions);
  final AuthRepository _auth;
  final SessionRepository _sessions;

  Future<Session> call(
    String username,
    String password, {
    required LoginLock lock,
    required DateTime now,
  }) async {
    if (lock.isLocked(now)) throw AccountLocked(lock.until!);
    final s = await _auth.signInWithPassword(username.trim(), password);
    if (s != null) return s;
    final next = LoginAttemptPolicy.afterFailure(lock, now);
    await _sessions.saveLock(next);
    if (next.isLocked(now)) throw AccountLocked(next.until!);
    throw InvalidCredentials(
      LoginAttemptPolicy.maxAttempts - next.fails,
      lock: next,
    );
  }
}

/// Inicio federado (Google, Facebook, institución o cuenta Órbita).
class SignInWithProvider {
  const SignInWithProvider(this._auth);
  final AuthRepository _auth;

  Future<Session> call(
    AuthMethod method, {
    required bool online,
    String? loginHint,
    bool register = false,
  }) {
    if (!online) throw AuthFailure(AuthFailureCode.network, method: method);
    return _auth.signIn(method, loginHint: loginHint, register: register);
  }
}

class SignInDemoAccount {
  const SignInDemoAccount(this._auth);
  final AuthRepository _auth;

  Future<Session> call(String accountId) => _auth.signInDemoAccount(accountId);
}

/// Renueva tokens; lanza [AuthFailure] `expired` si Keycloak los rechaza.
class RefreshSession {
  const RefreshSession(this._auth, this._sessions);
  final AuthRepository _auth;
  final SessionRepository _sessions;

  Future<Session> call(Session s, {required bool remember}) async {
    final ns = await _auth.refresh(s);
    if (remember) await _sessions.save(ns);
    return ns;
  }
}

/// La sesión venció: se retiran los tokens (el progreso queda guardado).
class ExpireSession {
  const ExpireSession(this._sessions);
  final SessionRepository _sessions;

  Future<void> call() => _sessions.clear();
}

/// Cierra la sesión local y pide el cierre remoto. Devuelve `true` si el
/// cierre remoto quedó pendiente para cuando vuelva la conexión.
class SignOut {
  const SignOut(this._auth, this._sessions);
  final AuthRepository _auth;
  final SessionRepository _sessions;

  Future<bool> call(Session? s, {required bool online}) async {
    await _sessions.clear();
    if (s == null || s.demo) return false;
    if (online) {
      try {
        await _auth.remoteSignOut(s.idToken);
        return false;
      } catch (_) {}
    }
    if (s.idToken != null) await _sessions.savePendingLogout(s.idToken!);
    return true;
  }
}

/// Completa un cierre remoto pendiente al reconectar.
class CompletePendingLogout {
  const CompletePendingLogout(this._auth, this._sessions);
  final AuthRepository _auth;
  final SessionRepository _sessions;

  /// `true` si ya no queda nada pendiente.
  Future<bool> call() async {
    final token = await _sessions.pendingLogout();
    if (token == null) return true;
    try {
      await _auth.remoteSignOut(token);
      await _sessions.clearPendingLogout();
      return true;
    } catch (_) {
      return false;
    }
  }
}

/// Código de desbloqueo de 6 dígitos.
class UnlockAccount {
  const UnlockAccount(this._auth, this._sessions);
  final AuthRepository _auth;
  final SessionRepository _sessions;

  Future<bool> call(String code) async {
    final ok = await _auth.unlock(code);
    if (ok) await _sessions.clearLock();
    return ok;
  }
}

/// Trae del servidor el grupo y la institución del usuario. Si no hay
/// servidor o no responde, devuelve `null` y la sesión sigue igual.
class RefreshProfile {
  const RefreshProfile(this._profiles);
  final ProfileRepository _profiles;

  Future<AppUser?> call(AppUser local) async {
    try {
      return await _profiles.fetch(local);
    } catch (_) {
      return null;
    }
  }
}

/// Valida el formato y, después, el código contra la licencia.
class ValidateGroupCode {
  const ValidateGroupCode(this._repo);
  final RegistrationRepository _repo;

  static final _format = RegExp(r'^ORB-[A-Z0-9]{4}$');

  Future<GroupCodeCheck> call(String raw, {required bool online}) async {
    final code = raw.trim().toUpperCase();
    if (!online) {
      return const GroupCodeCheck.invalid(
        'Sin conexión. Validar el código necesita Internet.',
      );
    }
    if (!_format.hasMatch(code)) {
      return const GroupCodeCheck.invalid(
        'El código tiene la forma ORB-XXXX. Revisa cada letra.',
      );
    }
    return _repo.validateGroupCode(code);
  }
}

class IsUsernameTaken {
  const IsUsernameTaken(this._repo);
  final RegistrationRepository _repo;

  Future<bool> call(String username) => _repo.isUsernameTaken(username.trim());
}
