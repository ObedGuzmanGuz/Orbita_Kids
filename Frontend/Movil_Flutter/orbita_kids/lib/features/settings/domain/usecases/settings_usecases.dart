import 'package:orbita_kids/features/settings/domain/entities/app_settings.dart';
import 'package:orbita_kids/features/settings/domain/repositories/settings_repository.dart';

class LoadSettings {
  const LoadSettings(this._repo);
  final SettingsRepository _repo;

  AppSettings call() => _repo.load();
}

class SaveSettings {
  const SaveSettings(this._repo);
  final SettingsRepository _repo;

  Future<void> call(AppSettings s) => _repo.save(s);
}

/// Restaura accesibilidad y apariencia sin tocar el onboarding ni los avisos.
class RestoreAccessibilityDefaults {
  const RestoreAccessibilityDefaults();

  AppSettings call(AppSettings s) => const AppSettings().copyWith(
    onboarded: s.onboarded,
    notifActivities: s.notifActivities,
    notifResults: s.notifResults,
    notifSync: s.notifSync,
    notifRest: s.notifRest,
    notifGroups: s.notifGroups,
    quietHours: s.quietHours,
  );
}
