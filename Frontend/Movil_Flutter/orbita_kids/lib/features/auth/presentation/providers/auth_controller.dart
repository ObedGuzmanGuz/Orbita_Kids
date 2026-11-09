import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:orbita_kids/core/network/connectivity.dart';
import 'package:orbita_kids/config/providers/core_providers.dart';
import 'package:orbita_kids/features/auth/providers/auth_providers.dart';
import 'package:orbita_kids/features/auth/domain/entities/auth_entities.dart';
import 'package:orbita_kids/features/auth/domain/usecases/auth_usecases.dart';

export 'package:orbita_kids/features/auth/providers/auth_providers.dart'
    show authRepositoryProvider, demoDirectoryProvider;

enum AuthStatus { restoring, signedOut, signedIn, guest }

@immutable
class AuthState {
  const AuthState({
    this.status = AuthStatus.restoring,
    this.session,
    this.lock = LoginLock.none,
    this.expired = false,
    this.pendingRemoteLogout = false,
    this.remember = true,
  });

  final AuthStatus status;
  final Session? session;

  /// Intentos fallidos y pausa de la cuenta.
  final LoginLock lock;

  /// La sesión venció y Keycloak no la renovó.
  final bool expired;

  /// Cierre de sesión remoto pendiente hasta que vuelva la conexión.
  final bool pendingRemoteLogout;
  final bool remember;

  AppUser? get user => session?.user;
  bool get isGuest => status == AuthStatus.guest;
  bool get isSignedIn => status == AuthStatus.signedIn && session != null;
  int get failedAttempts => lock.fails;
  DateTime? get lockedUntil => lock.until;

  AuthState copyWith({
    AuthStatus? status,
    Session? session,
    LoginLock? lock,
    bool? expired,
    bool? pendingRemoteLogout,
    bool? remember,
  }) => AuthState(
    status: status ?? this.status,
    session: session ?? this.session,
    lock: lock ?? this.lock,
    expired: expired ?? this.expired,
    pendingRemoteLogout: pendingRemoteLogout ?? this.pendingRemoteLogout,
    remember: remember ?? this.remember,
  );
}

/// Estado de la sesión para la UI. Las reglas (bloqueo, refresh, cierre
/// remoto pendiente) viven en los casos de uso del dominio.
class AuthController extends Notifier<AuthState> {
  Timer? _refreshTimer;

  DateTime _now() => ref.read(clockProvider)();
  bool get _online => ref.read(onlineProvider);

  @override
  AuthState build() {
    ref.onDispose(() => _refreshTimer?.cancel());
    ref.listen<bool>(onlineProvider, (prev, now) {
      if (now && prev == false) _onReconnect();
    });
    return const AuthState();
  }

  /// Restaura la sesión guardada (se usa en el splash).
  Future<void> restore() async {
    final r = await ref
        .read(restoreSessionProvider)
        .call(now: _now(), online: _online);
    if (!ref.mounted) return;
    var session = r.session;
    // Una sesión guardada sin token (de modo demo) no sirve con el servidor.
    if (session != null &&
        session.accessToken == null &&
        ref.read(appConfigProvider).usesServer) {
      await ref.read(expireSessionProvider).call();
      session = null;
    }
    state = AuthState(
      status: session == null ? AuthStatus.signedOut : AuthStatus.signedIn,
      session: session,
      expired: r.expired,
      lock: r.lock,
    );
    _scheduleRefresh();
    unawaited(_refreshProfile());
  }

  /// Completa la sesión con el grupo e institución que guarda el servidor.
  Future<void> _refreshProfile() async {
    final s = state.session;
    if (s == null || !_online) return;
    final u = await ref.read(refreshProfileProvider).call(s.user);
    final current = state.session;
    if (u == null || !ref.mounted || current?.user.id != s.user.id) return;
    final ns = current!.copyWith(user: u);
    state = state.copyWith(session: ns);
    await ref.read(persistSessionProvider).call(ns, remember: state.remember);
  }

  bool get isLocked => state.lock.isLocked(_now());

  /// Inicio con usuario y contraseña (formulario de la app, solo modo demo).
  /// Lanza `AccountLocked` o `InvalidCredentials`.
  Future<AppUser> signInWithPassword(
    String username,
    String password, {
    bool remember = true,
  }) async {
    try {
      final s = await ref
          .read(signInWithPasswordProvider)
          .call(username, password, lock: state.lock, now: _now());
      await _start(s, remember);
      return s.user;
    } on InvalidCredentials catch (e) {
      state = state.copyWith(lock: e.lock);
      rethrow;
    } on AccountLocked catch (e) {
      state = state.copyWith(
        lock: LoginLock(fails: LoginAttemptPolicy.maxAttempts, until: e.until),
      );
      rethrow;
    }
  }

  /// Inicio federado con Keycloak (Google, Facebook, institución u Órbita).
  Future<AppUser> signInWithKeycloak(
    AuthMethod method, {
    bool remember = true,
    String? loginHint,
    bool register = false,
  }) async {
    final s = await ref
        .read(signInWithProviderProvider)
        .call(
          method,
          online: _online,
          loginHint: loginHint,
          register: register,
        );
    await _start(s, remember);
    return s.user;
  }

  /// Inicio con una identidad del selector demo.
  Future<AppUser> signInDemoAccount(
    String accountId, {
    bool remember = true,
  }) async {
    final s = await ref.read(signInDemoAccountProvider).call(accountId);
    await _start(s, remember);
    return s.user;
  }

  Future<void> _start(Session s, bool remember) async {
    state = AuthState(
      status: AuthStatus.signedIn,
      session: s,
      remember: remember,
    );
    await ref.read(startSessionProvider).call(s, remember: remember);
    _scheduleRefresh();
    unawaited(_refreshProfile());
  }

  /// Modo explorar: sin cuenta, solo el Planeta Verde y nada se guarda.
  void startGuest() =>
      state = AuthState(status: AuthStatus.guest, lock: state.lock);

  void leaveGuest() => state = state.copyWith(status: AuthStatus.signedOut);

  /// Desbloqueo con código de 6 dígitos. Puede lanzar `BackendUnavailable`.
  Future<bool> unlockWithCode(String code) async {
    final ok = await ref.read(unlockAccountProvider).call(code);
    if (ok) state = state.copyWith(lock: LoginLock.none);
    return ok;
  }

  void _scheduleRefresh() {
    _refreshTimer?.cancel();
    final s = state.session;
    if (s == null || s.demo) return;
    var wait = s.expiresAt.difference(_now()) - const Duration(seconds: 30);
    if (wait.isNegative) wait = Duration.zero;
    _refreshTimer = Timer(wait, refreshNow);
  }

  /// Renueva tokens. Si Keycloak rechaza, la sesión vence (pantalla 09).
  Future<void> refreshNow() async {
    final s = state.session;
    if (s == null || !_online) return;
    try {
      final ns = await ref
          .read(refreshSessionProvider)
          .call(s, remember: state.remember);
      state = state.copyWith(session: ns);
      _scheduleRefresh();
    } on AuthFailure catch (f) {
      if (f.code == AuthFailureCode.expired) await expire();
    }
  }

  /// La sesión venció: se retiran tokens; el progreso pendiente queda
  /// guardado en el teléfono, aislado por usuario.
  Future<void> expire() async {
    _refreshTimer?.cancel();
    await ref.read(expireSessionProvider).call();
    state = const AuthState(status: AuthStatus.signedOut, expired: true);
  }

  void clearExpired() => state = state.copyWith(expired: false);

  /// Cierra la sesión local y pide a Keycloak el cierre remoto si hay red.
  Future<void> signOut() async {
    _refreshTimer?.cancel();
    final pending = await ref
        .read(signOutProvider)
        .call(state.session, online: _online);
    state = AuthState(
      status: AuthStatus.signedOut,
      pendingRemoteLogout: pending,
      lock: state.lock,
    );
  }

  Future<void> _onReconnect() async {
    final done = await ref.read(completePendingLogoutProvider).call();
    if (done && ref.mounted && state.pendingRemoteLogout) {
      state = state.copyWith(pendingRemoteLogout: false);
    }
    if (state.session?.isExpired(_now()) ?? false) await refreshNow();
    await _refreshProfile();
  }

  /// Actualiza el nombre visible en la sesión local.
  Future<void> updateUserName(String name) async {
    final s = state.session;
    if (s == null) return;
    final ns = s.copyWith(user: s.user.copyWith(name: name));
    state = state.copyWith(session: ns);
    await ref.read(persistSessionProvider).call(ns, remember: state.remember);
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

/// Usuario actual o `null` (invitado o sin sesión).
final currentUserProvider = Provider<AppUser?>(
  (ref) => ref.watch(authControllerProvider.select((s) => s.user)),
);

/// Identificador para aislar datos locales por persona.
final ownerIdProvider = Provider<String>(
  (ref) => ref.watch(currentUserProvider)?.id ?? 'guest',
);
