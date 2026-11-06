import 'package:orbita_kids/config/routes/app_routes.dart';
import 'package:orbita_kids/features/auth/domain/entities/auth_entities.dart';
import 'package:orbita_kids/features/auth/presentation/providers/auth_controller.dart';

/// Rutas públicas (sin sesión).
const publicPaths = {
  AppRoutes.splash,
  AppRoutes.studios,
  AppRoutes.onboarding,
  AppRoutes.loading,
  AppRoutes.login,
  AppRoutes.institution,
  AppRoutes.register,
  AppRoutes.registerCode,
  AppRoutes.recover,
  AppRoutes.lock,
  AppRoutes.unlock,
  AppRoutes.about,
  AppRoutes.aboutStudios,
  AppRoutes.privacy,
  AppRoutes.terms,
  AppRoutes.help,
  AppRoutes.settings,
  AppRoutes.accessibility,
  AppRoutes.theme,
  AppRoutes.connection,
  AppRoutes.explore,
  AppRoutes.meetOrbi,
};

/// Rutas de estudiante permitidas en modo explorar (sin cuenta).
const guestPaths = {
  AppRoutes.guestHome,
  AppRoutes.guestMore,
  AppRoutes.guestLocked,
  AppRoutes.avatar,
  AppRoutes.map,
  AppRoutes.pause,
  AppRoutes.play,
  AppRoutes.results,
  AppRoutes.meetOrbi,
  AppRoutes.galaxies,
};

/// Rutas que en modo explorar muestran «Disponible con cuenta» (pantalla 57).
const guestLockedPaths = {
  AppRoutes.progress,
  AppRoutes.assigned,
  AppRoutes.studentProfile,
  AppRoutes.studentNotices,
  AppRoutes.downloads,
  AppRoutes.sync,
  AppRoutes.editProfile,
  AppRoutes.security,
  AppRoutes.logout,
};

bool _isPublic(String p) =>
    publicPaths.contains(p) ||
    p.startsWith('/login/demo') ||
    p.startsWith('/auth-state');

bool _guestAllowed(String p) =>
    guestPaths.contains(p) ||
    p.startsWith('/s/mission/') ||
    p.startsWith('/s/pause/');

/// `true` si la ruta es `base` o cuelga de `base/` (evita confundir /sync con /s).
bool _under(String path, String base) =>
    path == base || path.startsWith('$base/');

/// Inicio de cada perfil.
String homeFor(AuthState s) {
  if (s.isGuest) return AppRoutes.guestHome;
  return s.user?.role == UserRole.teacher
      ? AppRoutes.teacherHome
      : AppRoutes.studentHome;
}

/// Redirección por estado de sesión y rol.
String? authRedirect(AuthState auth, String path) {
  if (auth.status == AuthStatus.restoring) {
    return path == AppRoutes.splash ? null : AppRoutes.splash;
  }
  if (path == AppRoutes.splash ||
      path == AppRoutes.studios ||
      path == AppRoutes.loading) {
    return null;
  }
  if (auth.expired && !_isPublic(path)) return AppRoutes.authState('expired');

  if (auth.isGuest) {
    if (_isPublic(path) || _guestAllowed(path)) return null;
    // 57 · Lo que guarda datos personales se explica en lugar de ocultarse.
    if (guestLockedPaths.contains(path)) return AppRoutes.guestLocked;
    return AppRoutes.guestHome;
  }
  if (!auth.isSignedIn) {
    return _isPublic(path) ? null : AppRoutes.login;
  }
  final role = auth.user!.role;
  if (path == AppRoutes.login ||
      path == AppRoutes.register ||
      path == AppRoutes.explore ||
      _under(path, AppRoutes.guestHome)) {
    return homeFor(auth);
  }
  if (_under(path, AppRoutes.studentHome) && role != UserRole.student) {
    return AppRoutes.teacherHome;
  }
  if (_under(path, AppRoutes.teacherHome) && role != UserRole.teacher) {
    return AppRoutes.studentHome;
  }
  return null;
}
