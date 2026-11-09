import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:orbita_kids/config/providers/core_providers.dart';
import 'package:orbita_kids/core/network/api_client.dart';
import 'package:orbita_kids/features/auth/data/repositories/demo_auth_repositories.dart';
import 'package:orbita_kids/features/auth/data/repositories/keycloak_auth_repository.dart';
import 'package:orbita_kids/features/auth/data/repositories/server_auth_repositories.dart';
import 'package:orbita_kids/features/auth/data/repositories/session_repository_impl.dart';
import 'package:orbita_kids/features/auth/domain/repositories/auth_repositories.dart';
import 'package:orbita_kids/features/auth/domain/usecases/auth_usecases.dart';

// ---------- Repositorios: Keycloak si está configurado, si no demo ----------

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final cfg = ref.watch(appConfigProvider);
  if (cfg.hasKeycloak) return KeycloakAuthRepository(cfg);
  return cfg.devServer
      ? const DevServerAuthRepository()
      : const DemoAuthRepository();
});

final sessionRepositoryProvider = Provider<SessionRepository>(
  (ref) => SecureSessionRepository(ref.watch(secureStoreProvider)),
);

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return dio == null
      ? const NoServerProfileRepository()
      : HttpProfileRepository(dio);
});

final registrationRepositoryProvider = Provider<RegistrationRepository>((ref) {
  final dio = ref.watch(dioProvider);
  if (dio != null) return HttpRegistrationRepository(dio);
  return ref.watch(appConfigProvider).isDemo
      ? const DemoRegistrationRepository()
      : const PendingRegistrationRepository();
});

final demoDirectoryProvider = Provider<DemoDirectory>(
  (ref) => ref.watch(appConfigProvider).isDemo
      ? const DemoDirectoryImpl()
      : const EmptyDemoDirectory(),
);

// ---------- Casos de uso ----------

final restoreSessionProvider = Provider(
  (ref) => RestoreSession(
    ref.watch(authRepositoryProvider),
    ref.watch(sessionRepositoryProvider),
  ),
);
final startSessionProvider = Provider(
  (ref) => StartSession(ref.watch(sessionRepositoryProvider)),
);
final persistSessionProvider = Provider(
  (ref) => PersistSession(ref.watch(sessionRepositoryProvider)),
);
final refreshProfileProvider = Provider(
  (ref) => RefreshProfile(ref.watch(profileRepositoryProvider)),
);
final signInWithPasswordProvider = Provider(
  (ref) => SignInWithPassword(
    ref.watch(authRepositoryProvider),
    ref.watch(sessionRepositoryProvider),
  ),
);
final signInWithProviderProvider = Provider(
  (ref) => SignInWithProvider(ref.watch(authRepositoryProvider)),
);
final signInDemoAccountProvider = Provider(
  (ref) => SignInDemoAccount(ref.watch(authRepositoryProvider)),
);
final refreshSessionProvider = Provider(
  (ref) => RefreshSession(
    ref.watch(authRepositoryProvider),
    ref.watch(sessionRepositoryProvider),
  ),
);
final expireSessionProvider = Provider(
  (ref) => ExpireSession(ref.watch(sessionRepositoryProvider)),
);
final signOutProvider = Provider(
  (ref) => SignOut(
    ref.watch(authRepositoryProvider),
    ref.watch(sessionRepositoryProvider),
  ),
);
final completePendingLogoutProvider = Provider(
  (ref) => CompletePendingLogout(
    ref.watch(authRepositoryProvider),
    ref.watch(sessionRepositoryProvider),
  ),
);
final unlockAccountProvider = Provider(
  (ref) => UnlockAccount(
    ref.watch(authRepositoryProvider),
    ref.watch(sessionRepositoryProvider),
  ),
);
final validateGroupCodeProvider = Provider(
  (ref) => ValidateGroupCode(ref.watch(registrationRepositoryProvider)),
);
final isUsernameTakenProvider = Provider(
  (ref) => IsUsernameTaken(ref.watch(registrationRepositoryProvider)),
);
