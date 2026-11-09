import 'package:go_router/go_router.dart';

import 'package:orbita_kids/config/routes/app_routes.dart';
import 'package:orbita_kids/features/offline/presentation/screens/offline_screens.dart';

/// 38–40 · Conexión, descargas y sincronización.
final offlineRoutes = <RouteBase>[
  GoRoute(
    path: AppRoutes.connection,
    builder: (_, _) => const ConnectionScreen(),
  ),
  GoRoute(
    path: AppRoutes.downloads,
    builder: (_, _) => const DownloadsScreen(),
  ),
  GoRoute(path: AppRoutes.sync, builder: (_, _) => const SyncScreen()),
];
