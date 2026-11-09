import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:orbita_kids/config/themes/app_themes.dart';
import 'package:orbita_kids/config/routes/app_routes.dart';

/// Barra inferior del docente.
class TeacherShell extends StatelessWidget {
  const TeacherShell({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  static const tabs = [
    (AppRoutes.teacherHome, Icons.home_rounded, 'Inicio'),
    (AppRoutes.groups, Icons.groups_rounded, 'Grupos'),
    (AppRoutes.activities, Icons.assignment_rounded, 'Actividades'),
    (AppRoutes.reports, Icons.insights_rounded, 'Resultados'),
    (AppRoutes.teacherProfile, Icons.person_rounded, 'Perfil'),
  ];

  @override
  Widget build(BuildContext context) {
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

/// Estado vacío cuando los datos dependen del backend pendiente.
class BackendPendingNotice extends StatelessWidget {
  const BackendPendingNotice({super.key, required this.what});
  final String what;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: AppRadius.card,
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_off_rounded),
          Gap.w12,
          Expanded(
            child: Text(
              '$what se mostrarán cuando el servidor de Órbita Kids esté disponible. Mientras tanto puedes preparar borradores en el teléfono.',
            ),
          ),
        ],
      ),
    ),
  );
}
