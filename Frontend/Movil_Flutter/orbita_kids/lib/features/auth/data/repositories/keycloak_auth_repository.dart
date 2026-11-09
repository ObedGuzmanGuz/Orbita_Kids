import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_appauth/flutter_appauth.dart';

import 'package:orbita_kids/config/env/app_config.dart';
import 'package:orbita_kids/core/error/failures.dart';
import 'package:orbita_kids/features/auth/domain/entities/auth_entities.dart';
import 'package:orbita_kids/features/auth/domain/repositories/auth_repositories.dart';

/// Implementación real contra Keycloak. No contiene secretos: el cliente es
/// público y usa PKCE (flutter_appauth lo genera automáticamente).
class KeycloakAuthRepository implements AuthRepository {
  KeycloakAuthRepository(this.cfg, [FlutterAppAuth? appAuth])
    : _appAuth = appAuth ?? const FlutterAppAuth();

  final AppConfig cfg;
  final FlutterAppAuth _appAuth;

  static const _scopes = ['openid', 'profile', 'email', 'offline_access'];

  @override
  bool get isDemo => false;

  String? _hint(AuthMethod m) => switch (m) {
    AuthMethod.google => cfg.idpHintGoogle,
    AuthMethod.facebook => cfg.idpHintFacebook,
    AuthMethod.institution =>
      cfg.idpHintInstitution.isEmpty ? null : cfg.idpHintInstitution,
    AuthMethod.orbita => null,
  };

  @override
  Future<Session> signIn(
    AuthMethod method, {
    String? loginHint,
    bool register = false,
  }) async {
    final hint = _hint(method);
    try {
      final r = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          cfg.keycloakClientId,
          cfg.keycloakRedirectUri,
          issuer: cfg.keycloakIssuer,
          scopes: _scopes,
          loginHint: loginHint,
          promptValues: register ? const ['create'] : null,
          additionalParameters: {'kc_idp_hint': ?hint, 'ui_locales': 'es'},
        ),
      );
      return _sessionFrom(
        method,
        r.accessToken,
        r.refreshToken,
        r.idToken,
        r.accessTokenExpirationDateTime,
      );
    } on FlutterAppAuthUserCancelledException {
      throw AuthFailure(AuthFailureCode.cancelled, method: method);
    } on FlutterAppAuthPlatformException catch (e) {
      throw AuthFailure(
        _mapError(e.platformErrorDetails.error),
        method: method,
        detail: e.platformErrorDetails.error ?? e.code,
      );
    } on PlatformException catch (e) {
      throw AuthFailure(
        AuthFailureCode.providerError,
        method: method,
        detail: e.code,
      );
    }
  }

  AuthFailureCode _mapError(String? oauthError) => switch (oauthError) {
    'access_denied' => AuthFailureCode.cancelled,
    'temporarily_unavailable' => AuthFailureCode.unavailable,
    'login_required' || 'invalid_grant' => AuthFailureCode.expired,
    _ => AuthFailureCode.providerError,
  };

  /// Con Keycloak la contraseña se escribe en su página segura.
  @override
  Future<Session?> signInWithPassword(String username, String password) =>
      throw const AuthFailure(AuthFailureCode.notConfigured);

  @override
  Future<Session> signInDemoAccount(String accountId) =>
      throw const AuthFailure(AuthFailureCode.notConfigured);

  /// El desbloqueo con código necesita un endpoint que el backend no publica.
  @override
  Future<bool> unlock(String code) =>
      throw const BackendUnavailable('desbloqueo de cuenta');

  @override
  Future<Session> refresh(Session session) async {
    if (session.refreshToken == null) {
      throw const AuthFailure(AuthFailureCode.expired);
    }
    try {
      final r = await _appAuth.token(
        TokenRequest(
          cfg.keycloakClientId,
          cfg.keycloakRedirectUri,
          issuer: cfg.keycloakIssuer,
          refreshToken: session.refreshToken,
          scopes: _scopes,
        ),
      );
      final s = _sessionFrom(
        session.user.method,
        r.accessToken,
        r.refreshToken ?? session.refreshToken,
        r.idToken ?? session.idToken,
        r.accessTokenExpirationDateTime,
      );
      return s;
    } on FlutterAppAuthPlatformException catch (e) {
      final err = e.platformErrorDetails.error;
      if (err == 'invalid_grant') {
        throw const AuthFailure(AuthFailureCode.expired);
      }
      throw AuthFailure(AuthFailureCode.network, detail: err);
    } on PlatformException catch (e) {
      throw AuthFailure(AuthFailureCode.network, detail: e.code);
    }
  }

  @override
  Future<void> remoteSignOut(String? idToken) async {
    await _appAuth.endSession(
      EndSessionRequest(
        idTokenHint: idToken,
        postLogoutRedirectUrl: cfg.keycloakPostLogoutRedirectUri,
        issuer: cfg.keycloakIssuer,
      ),
    );
  }

  Session _sessionFrom(
    AuthMethod method,
    String? access,
    String? refresh,
    String? id,
    DateTime? exp,
  ) {
    if (access == null) {
      throw AuthFailure(AuthFailureCode.providerError, method: method);
    }
    final claims = decodeJwtPayload(access);
    final roles = <String>{
      ...((claims['realm_access'] as Map?)?['roles'] as List? ?? const [])
          .cast<String>(),
    };
    final UserRole role;
    if (roles.contains(cfg.roleTeacher)) {
      role = UserRole.teacher;
    } else if (roles.contains(cfg.roleStudent)) {
      role = UserRole.student;
    } else {
      throw AuthFailure(AuthFailureCode.noRole, method: method);
    }
    final user = AppUser(
      id: claims['sub'] as String? ?? 'desconocido',
      name:
          claims['given_name'] as String? ??
          claims['preferred_username'] as String? ??
          'Astronauta',
      role: role,
      method: method,
      methodLabel: switch (method) {
        AuthMethod.orbita => 'Cuenta Órbita Kids',
        AuthMethod.google => 'Google',
        AuthMethod.facebook => 'Facebook',
        AuthMethod.institution => 'Cuenta institucional',
      },
      email: claims['email'] as String?,
      username: claims['preferred_username'] as String?,
    );
    return Session(
      user: user,
      accessToken: access,
      refreshToken: refresh,
      idToken: id,
      expiresAt: exp ?? DateTime.now().add(const Duration(minutes: 5)),
    );
  }
}

/// Decodifica el payload de un JWT sin validar firma (la valida el backend).
Map<String, dynamic> decodeJwtPayload(String jwt) {
  final parts = jwt.split('.');
  if (parts.length < 2) return const {};
  try {
    final norm = base64Url.normalize(parts[1]);
    return jsonDecode(utf8.decode(base64Url.decode(norm)))
        as Map<String, dynamic>;
  } catch (_) {
    return const {};
  }
}
