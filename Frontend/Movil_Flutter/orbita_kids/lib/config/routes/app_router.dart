import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:orbita_kids/config/routes/app_routes.dart';
import 'package:orbita_kids/config/routes/route_guard.dart';
import 'package:orbita_kids/features/auth/presentation/providers/auth_controller.dart';
import 'package:orbita_kids/features/auth/presentation/routes/auth_routes.dart';
import 'package:orbita_kids/features/guest/presentation/routes/guest_routes.dart';
import 'package:orbita_kids/features/offline/presentation/routes/offline_routes.dart';
import 'package:orbita_kids/features/onboarding/presentation/routes/onboarding_routes.dart';
import 'package:orbita_kids/features/settings/presentation/routes/settings_routes.dart';
import 'package:orbita_kids/features/student/presentation/routes/student_routes.dart';
import 'package:orbita_kids/features/teacher/presentation/routes/teacher_routes.dart';

export 'package:orbita_kids/config/routes/app_routes.dart';
export 'package:orbita_kids/config/routes/route_guard.dart'
    show authRedirect, homeFor;

/// Avisa al router cuando cambia la sesión para recalcular redirecciones.
class _AuthListenable extends ChangeNotifier {
  _AuthListenable(Ref ref) {
    ref.listen(authControllerProvider, (_, _) => notifyListeners());
  }
}

final rootNavigatorKey = GlobalKey<NavigatorState>();

/// Router de la app: compone las rutas que declara cada feature y aplica el
/// guard de sesión y rol ([authRedirect]).
final routerProvider = Provider<GoRouter>((ref) {
  final listenable = _AuthListenable(ref);
  ref.onDispose(listenable.dispose);
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    refreshListenable: listenable,
    redirect: (context, state) =>
        authRedirect(ref.read(authControllerProvider), state.matchedLocation),
    routes: [
      ...onboardingRoutes,
      ...authRoutes,
      ...guestRoutes,
      ...settingsRoutes,
      ...offlineRoutes,
      ...studentRoutes,
      ...teacherRoutes,
    ],
  );
});
