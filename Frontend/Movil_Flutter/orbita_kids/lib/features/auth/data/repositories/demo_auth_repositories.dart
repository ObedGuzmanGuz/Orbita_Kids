import 'package:orbita_kids/core/error/failures.dart';
import 'package:orbita_kids/features/auth/data/datasources/demo_auth_datasource.dart';
import 'package:orbita_kids/features/auth/domain/entities/auth_entities.dart';
import 'package:orbita_kids/features/auth/domain/repositories/auth_repositories.dart';
import 'package:orbita_kids/shared/data/demo/demo_data.dart';
import 'package:orbita_kids/shared/domain/entities/content.dart';

/// ======================== MODO DEMO ========================
/// Sin Keycloak: cuentas ficticias, sin red ni tokens reales.
class DemoAuthRepository implements AuthRepository {
  const DemoAuthRepository();

  @override
  bool get isDemo => true;

  @override
  Future<Session> signIn(
    AuthMethod method, {
    String? loginHint,
    bool register = false,
  }) async => throw AuthFailure(AuthFailureCode.notConfigured, method: method);

  @override
  Future<Session?> signInWithPassword(String username, String password) async {
    final u = DemoAuthDataSource.check(username, password);
    return u == null ? null : DemoAuthDataSource.sessionFor(u.id);
  }

  @override
  Future<Session> signInDemoAccount(String accountId) async =>
      DemoAuthDataSource.sessionFor(accountId);

  @override
  Future<Session> refresh(Session session) async =>
      session.copyWith(expiresAt: DateTime.now().add(const Duration(days: 30)));

  @override
  Future<void> remoteSignOut(String? idToken) async {}

  @override
  Future<bool> unlock(String code) async =>
      code == DemoAuthDataSource.unlockCode;
}

/// =============== MODO DEMO CON SERVIDOR (`API_DEV_AUTH`) ===============
/// Las mismas cuentas demo, pero identificadas ante el backend de desarrollo
/// con `Bearer dev:<id>` (backend con AUTH_MODE=dev y `npm run db:seed`).
/// Solo para desarrollo: el backend rechaza AUTH_MODE=dev en producción.
class DevServerAuthRepository extends DemoAuthRepository {
  const DevServerAuthRepository();

  /// Cuenta demo → usuario sembrado en el backend.
  static const backendIds = {'u-luna': 'dev-luna-astro', 'u-ana': 'dev-ana-rios'};

  Session _withToken(Session s) {
    final id = backendIds[s.user.id] ?? s.user.id;
    return Session(
      user: AppUser.fromJson({...s.user.toJson(), 'id': id}),
      accessToken: 'dev:$id',
      expiresAt: s.expiresAt,
      demo: true,
    );
  }

  @override
  Future<Session?> signInWithPassword(String username, String password) async {
    final s = await super.signInWithPassword(username, password);
    return s == null ? null : _withToken(s);
  }

  @override
  Future<Session> signInDemoAccount(String accountId) async =>
      _withToken(await super.signInDemoAccount(accountId));

  @override
  Future<Session> refresh(Session session) async =>
      _withToken(await super.refresh(session));
}

/// Identidades, instituciones y escenarios de demostración.
class DemoDirectoryImpl implements DemoDirectory {
  const DemoDirectoryImpl();

  @override
  List<DemoIdentity> identitiesFor(AuthMethod method) =>
      DemoAuthDataSource.identities[method] ?? const [];

  @override
  List<DemoIdentity> institutionIdentities(String institutionId) =>
      DemoAuthDataSource.institutionIdentities[institutionId] ?? const [];

  @override
  List<(AuthFailureCode, String)> get scenarios => DemoAuthDataSource.scenarios;

  @override
  List<Institution> institutions() => DemoData.institutions;

  @override
  String get unlockCode => DemoAuthDataSource.unlockCode;
}

/// Sin modo demo no hay identidades ficticias que mostrar.
class EmptyDemoDirectory implements DemoDirectory {
  const EmptyDemoDirectory();

  @override
  List<DemoIdentity> identitiesFor(AuthMethod method) => const [];

  @override
  List<DemoIdentity> institutionIdentities(String institutionId) => const [];

  @override
  List<(AuthFailureCode, String)> get scenarios => const [];

  @override
  List<Institution> institutions() => const [];

  @override
  String get unlockCode => '';
}

/// Registro de demostración: códigos y usuarios ficticios.
class DemoRegistrationRepository implements RegistrationRepository {
  const DemoRegistrationRepository();

  @override
  Future<GroupCodeCheck> validateGroupCode(String code) async {
    final known = DemoData.groupCodeStates[code];
    if (known != null) return GroupCodeCheck.invalid(known);
    final g = DemoData.groups.where(
      (g) => g.code == code && g.status == GroupStatus.active,
    );
    return g.isEmpty
        ? const GroupCodeCheck.invalid(
            'No encontramos ese código. Pide ayuda a tu maestra.',
          )
        : GroupCodeCheck.valid(g.first.name);
  }

  @override
  Future<bool> isUsernameTaken(String username) async =>
      DemoAuthDataSource.accounts.values.any((a) => a.$1 == username);
}

/// Con Keycloak pero sin backend: la licencia no se puede consultar.
class PendingRegistrationRepository implements RegistrationRepository {
  const PendingRegistrationRepository();

  @override
  Future<GroupCodeCheck> validateGroupCode(String code) =>
      throw const BackendUnavailable('validar códigos de grupo');

  @override
  Future<bool> isUsernameTaken(String username) async => false;
}
