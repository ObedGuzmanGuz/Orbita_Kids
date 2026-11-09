import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:orbita_kids/features/settings/providers/settings_providers.dart';
import 'package:orbita_kids/features/settings/domain/entities/app_settings.dart';
import 'package:orbita_kids/features/settings/domain/usecases/settings_usecases.dart';

export 'package:orbita_kids/features/settings/domain/entities/app_settings.dart';

/// Preferencias observables por toda la app. Persisten entre sesiones.
class SettingsController extends Notifier<AppSettings> {
  @override
  AppSettings build() => ref.read(loadSettingsProvider).call();

  void update(AppSettings Function(AppSettings s) change) {
    state = change(state);
    ref.read(saveSettingsProvider).call(state);
  }

  void restoreAccessibility() =>
      update(const RestoreAccessibilityDefaults().call);
}

final settingsProvider = NotifierProvider<SettingsController, AppSettings>(
  SettingsController.new,
);

/// Traducción del tema elegido a Flutter.
extension AppSettingsUi on AppSettings {
  ThemeMode get themeMode => switch (theme) {
    AppThemeChoice.auto => ThemeMode.system,
    AppThemeChoice.light => ThemeMode.light,
    AppThemeChoice.dark => ThemeMode.dark,
  };
}

/// Movimiento reducido: preferencia de la app o del sistema.
bool reduceMotionOf(BuildContext context, AppSettings s) =>
    s.reducedMotion || MediaQuery.maybeDisableAnimationsOf(context) == true;
