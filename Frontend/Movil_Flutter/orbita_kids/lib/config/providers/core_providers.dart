import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:orbita_kids/config/env/app_config.dart';
import 'package:orbita_kids/core/storage/local_store.dart';
import 'package:orbita_kids/core/storage/secure_store.dart';

/// Dependencias de infraestructura. Se sobrescriben en `bootstrap()` y en las
/// pruebas; nunca se crean en `main.dart`.
final appConfigProvider = Provider<AppConfig>((_) => AppConfig.demo);

final localStoreProvider = Provider<LocalStore>((_) => MemoryLocalStore());

final secureStoreProvider = Provider<SecureStore>((_) => MemorySecureStore());

final sharedPrefsProvider = Provider<SharedPreferences>(
  (_) => throw UnimplementedError('SharedPreferences se inyecta en bootstrap'),
);

/// Reloj inyectable para pruebas de bloqueo y expiración.
final clockProvider = Provider<DateTime Function()>((_) => DateTime.now);
