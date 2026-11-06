import 'package:go_router/go_router.dart';

import 'package:orbita_kids/config/routes/app_routes.dart';
import 'package:orbita_kids/features/pause/presentation/screens/pause_screens.dart';

/// 26 · Pausa Estelar (pestaña de la barra inferior).
final pauseTabRoutes = <RouteBase>[
  GoRoute(path: AppRoutes.pause, builder: (_, _) => const PauseScreen()),
];

/// 27–28 · Detalle y actividad en curso.
final pauseRoutes = <RouteBase>[
  GoRoute(
    path: AppRoutes.pauseDetailPattern,
    builder: (_, s) => PauseDetailScreen(id: s.pathParameters['id']!),
  ),
  GoRoute(
    path: AppRoutes.pauseDoingPattern,
    builder: (_, s) => PauseDoingScreen(id: s.pathParameters['id']!),
  ),
];
