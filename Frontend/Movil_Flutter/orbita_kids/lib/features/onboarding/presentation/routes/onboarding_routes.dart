import 'package:go_router/go_router.dart';

import 'package:orbita_kids/config/routes/app_routes.dart';
import 'package:orbita_kids/features/onboarding/presentation/screens/intro_screens.dart';

/// 01–04 · Splash, Studios, onboarding y carga.
final onboardingRoutes = <RouteBase>[
  GoRoute(path: AppRoutes.splash, builder: (_, _) => const SplashScreen()),
  GoRoute(
    path: AppRoutes.studios,
    builder: (_, _) => const StudiosSplashScreen(),
  ),
  GoRoute(
    path: AppRoutes.onboarding,
    builder: (_, _) => const OnboardingScreen(),
  ),
  GoRoute(
    path: AppRoutes.loading,
    builder: (_, s) => LoadingScreen(
      next: s.uri.queryParameters['next'] ?? AppRoutes.login,
      message: s.uri.queryParameters['msg'],
      sub: s.uri.queryParameters['sub'],
      flow: s.uri.queryParameters['flow'] == '1',
    ),
  ),
];
