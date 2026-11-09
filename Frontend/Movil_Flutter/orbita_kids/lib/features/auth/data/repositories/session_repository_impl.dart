import 'dart:convert';

import 'package:orbita_kids/core/storage/secure_store.dart';
import 'package:orbita_kids/features/auth/domain/entities/auth_entities.dart';
import 'package:orbita_kids/features/auth/domain/repositories/auth_repositories.dart';

/// Sesión, bloqueo y cierre pendiente en Keychain / Keystore.
class SecureSessionRepository implements SessionRepository {
  const SecureSessionRepository(this._store);
  final SecureStore _store;

  static const sessionKey = 'orbita.session';
  static const lockKey = 'orbita.lock';
  static const pendingLogoutKey = 'orbita.pendingLogout';

  @override
  Future<Session?> read() async {
    final raw = await _store.read(sessionKey);
    if (raw == null) return null;
    try {
      return Session.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      // Sesión dañada: se descarta y se pide entrar de nuevo.
      await _store.delete(sessionKey);
      return null;
    }
  }

  @override
  Future<void> save(Session session) =>
      _store.write(sessionKey, jsonEncode(session.toJson()));

  @override
  Future<void> clear() => _store.delete(sessionKey);

  @override
  Future<LoginLock> readLock() async {
    final raw = await _store.read(lockKey);
    if (raw == null) return LoginLock.none;
    final j = jsonDecode(raw) as Map<String, dynamic>;
    return LoginLock(
      fails: j['fails'] as int? ?? 0,
      until: j['until'] == null ? null : DateTime.parse(j['until'] as String),
    );
  }

  @override
  Future<void> saveLock(LoginLock lock) => _store.write(
    lockKey,
    jsonEncode({'fails': lock.fails, 'until': lock.until?.toIso8601String()}),
  );

  @override
  Future<void> clearLock() => _store.delete(lockKey);

  @override
  Future<String?> pendingLogout() => _store.read(pendingLogoutKey);

  @override
  Future<void> savePendingLogout(String idToken) =>
      _store.write(pendingLogoutKey, idToken);

  @override
  Future<void> clearPendingLogout() => _store.delete(pendingLogoutKey);
}
