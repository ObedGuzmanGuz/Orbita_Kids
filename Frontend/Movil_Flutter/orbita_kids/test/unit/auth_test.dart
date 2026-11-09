import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:orbita_kids/config/env/app_config.dart';
import 'package:orbita_kids/config/routes/app_router.dart';
import 'package:orbita_kids/features/settings/presentation/providers/settings_controller.dart';
import 'package:orbita_kids/core/sync/domain/sync_models.dart';
import 'package:orbita_kids/core/sync/presentation/providers/sync_controller.dart';
import 'package:orbita_kids/features/auth/presentation/providers/auth_controller.dart';
import 'package:orbita_kids/features/auth/data/datasources/demo_auth_datasource.dart';
import 'package:orbita_kids/features/auth/data/repositories/keycloak_auth_repository.dart';
import 'package:orbita_kids/features/auth/data/repositories/session_repository_impl.dart';
import 'package:orbita_kids/features/auth/domain/entities/auth_entities.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers.dart';

void main() {
  setUpAll(initTestEnv);

  test('sin KEYCLOAK_ISSUER ni CLIENT_ID la app entra en modo demo', () {
    expect(AppConfig.demo.isDemo, isTrue);
    expect(
      AppConfig.demo.missing,
      containsAll(['KEYCLOAK_ISSUER', 'KEYCLOAK_CLIENT_ID', 'API_BASE_URL']),
    );
    const real = AppConfig(
      keycloakIssuer: 'https://auth.example/realms/orbita',
      keycloakClientId: 'orbita-kids-app',
      keycloakRedirectUri: 'x:/cb',
      keycloakPostLogoutRedirectUri: 'x:/out',
      apiBaseUrl: '',
      idpHintGoogle: 'google',
      idpHintFacebook: 'facebook',
      idpHintInstitution: '',
      roleStudent: 'student',
      roleTeacher: 'teacher',
    );
    expect(real.isDemo, isFalse);
    expect(real.hasBackend, isFalse);
  });

  test('decodifica el payload de un JWT', () {
    final payload = base64Url
        .encode(
          utf8.encode(
            jsonEncode({
              'sub': 'abc',
              'realm_access': {
                'roles': ['teacher'],
              },
            }),
          ),
        )
        .replaceAll('=', '');
    final claims = decodeJwtPayload('h.$payload.s');
    expect(claims['sub'], 'abc');
    expect(decodeJwtPayload('basura'), isEmpty);
  });

  group('AuthController (demo)', () {
    test('restaura sin sesión → signedOut', () async {
      final c = await TestDeps().container();
      await c.read(authControllerProvider.notifier).restore();
      expect(c.read(authControllerProvider).status, AuthStatus.signedOut);
    });

    test('inicio con usuario y contraseña demo y sesión persistente', () async {
      final deps = TestDeps();
      final c = await deps.container();
      final ctrl = c.read(authControllerProvider.notifier);
      await ctrl.restore();
      final u = await ctrl.signInWithPassword('luna.astro', 'orbita123');
      expect(u.role, UserRole.student);
      expect(c.read(authControllerProvider).isSignedIn, isTrue);
      expect(
        await deps.secure.read(SecureSessionRepository.sessionKey),
        isNotNull,
      );

      // Nueva instancia: la sesión guardada se restaura.
      final c2 = await deps.container();
      await c2.read(authControllerProvider.notifier).restore();
      expect(c2.read(authControllerProvider).user?.name, 'Luna');
    });

    test('sin «mantener sesión» no se guarda en el teléfono', () async {
      final deps = TestDeps();
      final c = await deps.container();
      await c.read(authControllerProvider.notifier).restore();
      await c
          .read(authControllerProvider.notifier)
          .signInWithPassword('ana.rios', 'orbita123', remember: false);
      expect(
        await deps.secure.read(SecureSessionRepository.sessionKey),
        isNull,
      );
    });

    test('3 intentos fallidos pausan la cuenta 15 minutos', () async {
      final deps = TestDeps();
      final c = await deps.container();
      final ctrl = c.read(authControllerProvider.notifier);
      await ctrl.restore();
      await expectLater(
        ctrl.signInWithPassword('luna.astro', 'mal'),
        throwsA(
          isA<InvalidCredentials>().having((e) => e.remaining, 'quedan', 2),
        ),
      );
      await expectLater(
        ctrl.signInWithPassword('luna.astro', 'mal'),
        throwsA(isA<InvalidCredentials>()),
      );
      await expectLater(
        ctrl.signInWithPassword('luna.astro', 'mal'),
        throwsA(isA<AccountLocked>()),
      );
      expect(ctrl.isLocked, isTrue);
      // Ni la contraseña correcta entra durante la pausa.
      await expectLater(
        ctrl.signInWithPassword('luna.astro', 'orbita123'),
        throwsA(isA<AccountLocked>()),
      );

      // La pausa sobrevive a reiniciar la app.
      final c2 = await deps.container();
      await c2.read(authControllerProvider.notifier).restore();
      expect(c2.read(authControllerProvider.notifier).isLocked, isTrue);

      // Pasados 15 minutos se libera.
      deps.now = fixedNow.add(const Duration(minutes: 16));
      expect(ctrl.isLocked, isFalse);
    });

    test('desbloqueo con código', () async {
      final c = await TestDeps().container();
      final ctrl = c.read(authControllerProvider.notifier);
      await ctrl.restore();
      for (var i = 0; i < 3; i++) {
        try {
          await ctrl.signInWithPassword('luna.astro', 'x');
        } catch (_) {}
      }
      expect(await ctrl.unlockWithCode('123456'), isFalse);
      expect(ctrl.isLocked, isTrue);
      expect(await ctrl.unlockWithCode(DemoAuthDataSource.unlockCode), isTrue);
      expect(ctrl.isLocked, isFalse);
    });

    test('cerrar sesión retira tokens pero conserva lo pendiente', () async {
      final deps = TestDeps();
      final c = await deps.container();
      final ctrl = c.read(authControllerProvider.notifier);
      await ctrl.restore();
      await ctrl.signInWithPassword('luna.astro', 'orbita123');
      c.read(syncControllerProvider);
      await c
          .read(syncControllerProvider.notifier)
          .enqueue(
            kind: SyncKind.attempt,
            owner: 'u-luna',
            title: 'M',
            detail: '',
          );
      await ctrl.signOut();
      expect(c.read(authControllerProvider).status, AuthStatus.signedOut);
      expect(
        await deps.secure.read(SecureSessionRepository.sessionKey),
        isNull,
      );
      expect(c.read(syncControllerProvider).of('u-luna').length, 1);
    });

    test('sesión vencida marca el estado expirado', () async {
      final c = await TestDeps().container();
      final ctrl = c.read(authControllerProvider.notifier);
      await ctrl.restore();
      await ctrl.signInWithPassword('luna.astro', 'orbita123');
      await ctrl.expire();
      expect(c.read(authControllerProvider).expired, isTrue);
    });
  });

  group('Rutas por rol', () {
    const student = AppUser(
      id: 's',
      name: 'Luna',
      role: UserRole.student,
      method: AuthMethod.orbita,
      methodLabel: '',
    );
    const teacher = AppUser(
      id: 't',
      name: 'Ana',
      role: UserRole.teacher,
      method: AuthMethod.google,
      methodLabel: '',
    );
    final far = DateTime(2100);

    test('restaurando solo permite el splash', () {
      expect(authRedirect(const AuthState(), '/s'), '/');
      expect(authRedirect(const AuthState(), '/'), isNull);
    });

    test('sin sesión: públicas sí, privadas al login', () {
      const s = AuthState(status: AuthStatus.signedOut);
      expect(authRedirect(s, '/login'), isNull);
      expect(authRedirect(s, '/privacy'), isNull);
      expect(authRedirect(s, '/s'), '/login');
      expect(authRedirect(s, '/t/groups'), '/login');
      expect(authRedirect(s, '/sync'), '/login');
    });

    test('estudiante no entra a rutas docentes y viceversa', () {
      final s = AuthState(
        status: AuthStatus.signedIn,
        session: Session(user: student, expiresAt: far),
      );
      expect(authRedirect(s, '/t'), '/s');
      expect(authRedirect(s, '/s/map'), isNull);
      expect(authRedirect(s, '/login'), '/s');
      final t = AuthState(
        status: AuthStatus.signedIn,
        session: Session(user: teacher, expiresAt: far),
      );
      expect(authRedirect(t, '/s/map'), '/t');
      expect(authRedirect(t, '/t/plans'), isNull);
      expect(
        authRedirect(t, '/sync'),
        isNull,
        reason: '/sync no es ruta de estudiante',
      );
      expect(authRedirect(t, '/settings'), isNull);
      expect(authRedirect(t, '/security'), isNull);
      expect(
        authRedirect(s, '/terms'),
        isNull,
        reason: '/terms no es ruta docente',
      );
    });

    test('modo explorar limitado', () {
      const g = AuthState(status: AuthStatus.guest);
      expect(authRedirect(g, '/s/map'), isNull);
      expect(authRedirect(g, '/s/mission/m1'), isNull);
      expect(
        authRedirect(g, '/s/progress'),
        '/g/locked',
        reason: 'pantalla 57',
      );
      expect(authRedirect(g, '/s'), '/g');
      expect(authRedirect(g, '/g/more'), isNull);
      expect(authRedirect(g, '/s/avatar'), isNull);
      expect(authRedirect(g, '/t'), '/g');
    });

    test('sesión vencida lleva a su estado', () {
      const s = AuthState(status: AuthStatus.signedOut, expired: true);
      expect(authRedirect(s, '/s'), '/auth-state/expired');
    });
  });

  test('las preferencias persisten en SharedPreferences', () async {
    final deps = TestDeps();
    final c = await deps.container();
    c
        .read(settingsProvider.notifier)
        .update(
          (s) => s.copyWith(
            highContrast: true,
            textScale: 1.3,
            theme: AppThemeChoice.dark,
          ),
        );
    final sp = await SharedPreferences.getInstance();
    final saved = AppSettings.fromJson(
      jsonDecode(sp.getString('orbita-kids-prefs-v2')!) as Map<String, dynamic>,
    );
    expect(saved.highContrast, isTrue);
    expect(saved.textScale, 1.3);
    expect(saved.theme, AppThemeChoice.dark);
    expect(
      saved.onboarded,
      isTrue,
      reason: 'no se pierden las demás preferencias',
    );
  });
}
