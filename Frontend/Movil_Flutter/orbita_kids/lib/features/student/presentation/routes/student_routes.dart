import 'package:go_router/go_router.dart';

import 'package:orbita_kids/config/routes/app_routes.dart';
import 'package:orbita_kids/features/guest/presentation/routes/guest_routes.dart';
import 'package:orbita_kids/features/pause/presentation/routes/pause_routes.dart';
import 'package:orbita_kids/features/student/presentation/screens/play_screens.dart';
import 'package:orbita_kids/features/student/presentation/screens/student_extra_screens.dart';
import 'package:orbita_kids/features/student/presentation/screens/student_home_screen.dart';
import 'package:orbita_kids/features/student/presentation/screens/student_map_screens.dart';
import 'package:orbita_kids/features/student/presentation/screens/student_progress_screens.dart';
import 'package:orbita_kids/features/student/presentation/screens/student_shell.dart';

/// 15–25 y 53 · Estudiante. Las pestañas del modo explorar comparten la
/// misma barra inferior.
final studentRoutes = <RouteBase>[
  ShellRoute(
    builder: (_, s, child) =>
        StudentShell(location: s.matchedLocation, child: child),
    routes: [
      GoRoute(
        path: AppRoutes.studentHome,
        builder: (_, _) => const StudentHomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.guestHome,
        builder: (_, _) => const GuestHomeScreen(),
      ),
      ...guestTabRoutes,
      GoRoute(path: AppRoutes.map, builder: (_, _) => const MapScreen()),
      GoRoute(
        path: AppRoutes.progress,
        builder: (_, _) => const ProgressScreen(),
      ),
      ...pauseTabRoutes,
      GoRoute(
        path: AppRoutes.studentProfile,
        builder: (_, _) => const StudentProfileScreen(),
      ),
    ],
  ),
  GoRoute(path: AppRoutes.assigned, builder: (_, _) => const AssignedScreen()),
  GoRoute(path: AppRoutes.avatar, builder: (_, _) => const AvatarScreen()),
  GoRoute(
    path: AppRoutes.missionPattern,
    builder: (_, s) => MissionDetailScreen(missionId: s.pathParameters['id']!),
  ),
  GoRoute(path: AppRoutes.play, builder: (_, _) => const PlayScreen()),
  GoRoute(path: AppRoutes.results, builder: (_, _) => const ResultsScreen()),
  GoRoute(
    path: AppRoutes.studentNotices,
    builder: (_, _) => const StudentNoticesScreen(),
  ),
  GoRoute(path: AppRoutes.galaxies, builder: (_, _) => const GalaxiesScreen()),
  GoRoute(path: AppRoutes.meetOrbi, builder: (_, _) => const MeetOrbiScreen()),
  ...pauseRoutes,
];
