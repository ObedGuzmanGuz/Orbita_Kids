import 'package:go_router/go_router.dart';

import 'package:orbita_kids/config/routes/app_routes.dart';
import 'package:orbita_kids/features/auth/domain/entities/auth_entities.dart';
import 'package:orbita_kids/features/auth/presentation/screens/auth_state_screen.dart';
import 'package:orbita_kids/features/auth/presentation/screens/demo_provider_screen.dart';
import 'package:orbita_kids/features/auth/presentation/screens/institution_screen.dart';
import 'package:orbita_kids/features/auth/presentation/screens/lock_screens.dart';
import 'package:orbita_kids/features/auth/presentation/screens/login_screen.dart';
import 'package:orbita_kids/features/auth/presentation/screens/logout_screen.dart';
import 'package:orbita_kids/features/auth/presentation/screens/recover_screen.dart';
import 'package:orbita_kids/features/auth/presentation/screens/register_screens.dart';

/// 05–14 y 49 · Acceso, registro, recuperación y cierre de sesión.
final authRoutes = <RouteBase>[
  GoRoute(path: AppRoutes.login, builder: (_, _) => const LoginScreen()),
  GoRoute(
    path: AppRoutes.demoProviderPattern,
    builder: (_, s) => DemoProviderScreen(
      method: AuthMethod.values.byName(s.pathParameters['method']!),
      institutionId: s.uri.queryParameters['inst'],
    ),
  ),
  GoRoute(
    path: AppRoutes.institution,
    builder: (_, _) => const InstitutionScreen(),
  ),
  GoRoute(
    path: AppRoutes.authStatePattern,
    builder: (_, s) => AuthStateScreen(
      code:
          AuthFailureCode.values.asNameMap()[s.pathParameters['code']] ??
          AuthFailureCode.providerError,
      method:
          AuthMethod.values.asNameMap()[s.uri.queryParameters['m']] ??
          AuthMethod.orbita,
    ),
  ),
  GoRoute(path: AppRoutes.register, builder: (_, _) => const RegisterScreen()),
  GoRoute(
    path: AppRoutes.registerCode,
    builder: (_, _) => const GroupCodeScreen(),
  ),
  GoRoute(path: AppRoutes.recover, builder: (_, _) => const RecoverScreen()),
  GoRoute(path: AppRoutes.lock, builder: (_, _) => const LockScreen()),
  GoRoute(path: AppRoutes.unlock, builder: (_, _) => const UnlockScreen()),
  GoRoute(path: AppRoutes.logout, builder: (_, _) => const LogoutScreen()),
];
