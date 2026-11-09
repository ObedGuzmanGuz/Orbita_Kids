import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:orbita_kids/config/routes/app_router.dart';
import 'package:orbita_kids/features/settings/presentation/providers/settings_controller.dart';
import 'package:orbita_kids/config/themes/app_theme.dart';
import 'package:orbita_kids/features/offline/presentation/widgets/net_status_bar.dart';

/// Raíz de la app: tema, accesibilidad, router y barra de conexión.
class OrbitaKidsApp extends ConsumerWidget {
  const OrbitaKidsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Órbita Kids',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      themeMode: s.themeMode,
      theme: buildTheme(dark: false, highContrast: s.highContrast),
      darkTheme: buildTheme(dark: true, highContrast: s.highContrast),
      themeAnimationDuration: s.reducedMotion
          ? Duration.zero
          : const Duration(milliseconds: 250),
      locale: const Locale('es', 'MX'),
      supportedLocales: const [Locale('es', 'MX'), Locale('es')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        // El tamaño de texto de la app se suma al del sistema, con tope
        // para no romper la maqueta.
        final scale = (mq.textScaler.scale(1) * s.textScale).clamp(1.0, 2.0);
        return MediaQuery(
          data: mq.copyWith(
            textScaler: TextScaler.linear(scale),
            disableAnimations: mq.disableAnimations || s.reducedMotion,
            highContrast: mq.highContrast || s.highContrast,
          ),
          child: NetStatusFrame(child: child ?? const SizedBox()),
        );
      },
    );
  }
}
