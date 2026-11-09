import 'package:go_router/go_router.dart';

import 'package:orbita_kids/config/routes/app_routes.dart';
import 'package:orbita_kids/features/guest/presentation/screens/guest_screens.dart';

/// 54 y 57 · Pantallas del modo explorar fuera de la barra inferior.
final guestRoutes = <RouteBase>[
  GoRoute(
    path: AppRoutes.explore,
    builder: (_, _) => const ExploreIntroScreen(),
  ),
  GoRoute(
    path: AppRoutes.guestLocked,
    builder: (_, _) => const GuestLockedScreen(),
  ),
];

/// 56 · «Más» vive dentro de la barra inferior del invitado.
final guestTabRoutes = <RouteBase>[
  GoRoute(
    path: AppRoutes.guestMore,
    builder: (_, _) => const GuestMoreScreen(),
  ),
];
