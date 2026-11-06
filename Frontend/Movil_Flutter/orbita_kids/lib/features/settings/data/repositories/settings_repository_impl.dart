import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:orbita_kids/features/settings/domain/entities/app_settings.dart';
import 'package:orbita_kids/features/settings/domain/repositories/settings_repository.dart';

/// Preferencias en SharedPreferences (JSON con la clave del prototipo).
class SharedPrefsSettingsRepository implements SettingsRepository {
  const SharedPrefsSettingsRepository(this._prefs);
  final SharedPreferences _prefs;

  static const key = 'orbita-kids-prefs-v2';

  @override
  AppSettings load() {
    final raw = _prefs.getString(key);
    if (raw == null) return const AppSettings();
    try {
      return AppSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const AppSettings();
    }
  }

  @override
  Future<void> save(AppSettings settings) =>
      _prefs.setString(key, jsonEncode(settings.toJson()));
}
