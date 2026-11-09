import 'package:go_router/go_router.dart';

import 'package:orbita_kids/config/routes/app_routes.dart';
import 'package:orbita_kids/features/settings/presentation/screens/info_screens.dart';
import 'package:orbita_kids/features/settings/presentation/screens/settings_screens.dart';

/// 41–48, 50 y 51 · Configuración, cuenta e información.
final settingsRoutes = <RouteBase>[
  GoRoute(path: AppRoutes.settings, builder: (_, _) => const SettingsScreen()),
  GoRoute(
    path: AppRoutes.accessibility,
    builder: (_, _) => const AccessibilityScreen(),
  ),
  GoRoute(path: AppRoutes.theme, builder: (_, _) => const ThemeScreen()),
  GoRoute(
    path: AppRoutes.editProfile,
    builder: (_, _) => const EditProfileScreen(),
  ),
  GoRoute(path: AppRoutes.security, builder: (_, _) => const SecurityScreen()),
  GoRoute(path: AppRoutes.about, builder: (_, _) => const AboutAppScreen()),
  GoRoute(
    path: AppRoutes.aboutStudios,
    builder: (_, _) => const AboutStudiosScreen(),
  ),
  GoRoute(path: AppRoutes.privacy, builder: (_, _) => const PrivacyScreen()),
  GoRoute(path: AppRoutes.terms, builder: (_, _) => const TermsScreen()),
  GoRoute(path: AppRoutes.help, builder: (_, _) => const HelpScreen()),
];
