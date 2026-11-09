import 'package:orbita_kids/features/settings/domain/entities/app_settings.dart';

/// Preferencias guardadas en el teléfono.
abstract interface class SettingsRepository {
  AppSettings load();
  Future<void> save(AppSettings settings);
}
