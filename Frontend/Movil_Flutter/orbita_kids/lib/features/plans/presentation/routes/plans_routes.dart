import 'package:go_router/go_router.dart';

import 'package:orbita_kids/config/routes/app_routes.dart';
import 'package:orbita_kids/features/plans/presentation/screens/plans_screen.dart';

/// 52 · Planes institucionales (solo docentes).
final plansRoutes = <RouteBase>[
  GoRoute(path: AppRoutes.plans, builder: (_, _) => const PlansScreen()),
];
