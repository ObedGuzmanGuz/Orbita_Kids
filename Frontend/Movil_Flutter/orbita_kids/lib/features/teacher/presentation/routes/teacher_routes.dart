import 'package:go_router/go_router.dart';

import 'package:orbita_kids/config/routes/app_routes.dart';
import 'package:orbita_kids/features/plans/presentation/routes/plans_routes.dart';
import 'package:orbita_kids/features/teacher/presentation/screens/activity_screens.dart';
import 'package:orbita_kids/features/teacher/presentation/screens/group_screens.dart';
import 'package:orbita_kids/features/teacher/presentation/screens/teacher_home_screen.dart';
import 'package:orbita_kids/features/teacher/presentation/screens/teacher_misc_screens.dart';
import 'package:orbita_kids/features/teacher/presentation/screens/teacher_shell.dart';

/// 29–37 · Docente.
final teacherRoutes = <RouteBase>[
  ShellRoute(
    builder: (_, s, child) =>
        TeacherShell(location: s.matchedLocation, child: child),
    routes: [
      GoRoute(
        path: AppRoutes.teacherHome,
        builder: (_, _) => const TeacherHomeScreen(),
      ),
      GoRoute(path: AppRoutes.groups, builder: (_, _) => const GroupsScreen()),
      GoRoute(
        path: AppRoutes.activities,
        builder: (_, _) => const ActivitiesScreen(),
      ),
      GoRoute(
        path: AppRoutes.reports,
        builder: (_, _) => const ReportsScreen(),
      ),
      GoRoute(
        path: AppRoutes.teacherProfile,
        builder: (_, _) => const TeacherProfileScreen(),
      ),
    ],
  ),
  GoRoute(
    path: AppRoutes.groupPattern,
    builder: (_, s) => GroupDetailScreen(groupId: s.pathParameters['id']!),
  ),
  GoRoute(
    path: AppRoutes.studentDetailPattern,
    builder: (_, s) => StudentDetailScreen(studentId: s.pathParameters['id']!),
  ),
  GoRoute(
    path: AppRoutes.createActivityPath,
    builder: (_, s) => CreateActivityScreen(
      draftId: s.uri.queryParameters['draft'],
      groupId: s.uri.queryParameters['group'],
    ),
  ),
  GoRoute(
    path: AppRoutes.teacherNotices,
    builder: (_, _) => const TeacherNoticesScreen(),
  ),
  ...plansRoutes,
];
