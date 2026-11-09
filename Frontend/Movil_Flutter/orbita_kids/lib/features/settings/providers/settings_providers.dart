import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:orbita_kids/config/providers/core_providers.dart';
import 'package:orbita_kids/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:orbita_kids/features/settings/domain/repositories/settings_repository.dart';
import 'package:orbita_kids/features/settings/domain/usecases/settings_usecases.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SharedPrefsSettingsRepository(ref.watch(sharedPrefsProvider)),
);

final loadSettingsProvider = Provider(
  (ref) => LoadSettings(ref.watch(settingsRepositoryProvider)),
);

final saveSettingsProvider = Provider(
  (ref) => SaveSettings(ref.watch(settingsRepositoryProvider)),
);
