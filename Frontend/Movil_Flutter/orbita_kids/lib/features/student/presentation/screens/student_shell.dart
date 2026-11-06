import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:orbita_kids/config/routes/app_routes.dart';
import 'package:orbita_kids/features/auth/presentation/providers/auth_controller.dart';

/// Barra inferior del estudiante (5 pestañas) o del modo explorar.
class StudentShell extends ConsumerWidget {
  const StudentShell({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final guest = ref.watch(authControllerProvider.select((s) => s.isGuest));
    final tabs = guest
        ? const [
            (AppRoutes.guestHome, Icons.home_rounded, 'Inicio'),
            (AppRoutes.map, Icons.explore_rounded, 'Universo'),
            (AppRoutes.pause, Icons.directions_run_rounded, 'Pausa Estelar'),
            (AppRoutes.guestMore, Icons.more_horiz_rounded, 'Más'),
          ]
        : const [
            (AppRoutes.studentHome, Icons.home_rounded, 'Inicio'),
            (AppRoutes.map, Icons.explore_rounded, 'Explorar'),
            (AppRoutes.progress, Icons.insights_rounded, 'Mi progreso'),
            (AppRoutes.pause, Icons.directions_run_rounded, 'Pausa Estelar'),
            (AppRoutes.studentProfile, Icons.person_rounded, 'Perfil'),
          ];
    final idx = tabs.indexWhere((t) => t.$1 == location);
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: idx < 0 ? 0 : idx,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (i) => context.go(tabs[i].$1),
        destinations: [
          for (final t in tabs)
            NavigationDestination(icon: Icon(t.$2), label: t.$3, tooltip: t.$3),
        ],
      ),
    );
  }
}
