import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:orbita_kids/config/env/app_config.dart';
import 'package:orbita_kids/config/providers/core_providers.dart';
import 'package:orbita_kids/core/audio/speech.dart';
import 'package:orbita_kids/core/network/api_cache.dart';
import 'package:orbita_kids/core/network/api_client.dart';
import 'package:orbita_kids/core/network/connectivity.dart';
import 'package:orbita_kids/core/notifications/local_notifier.dart';
import 'package:orbita_kids/core/storage/local_store.dart';
import 'package:orbita_kids/core/storage/secure_store.dart';
import 'package:orbita_kids/features/auth/presentation/providers/auth_controller.dart';

const _pluginTimeout = Duration(seconds: 5);

/// Sobrescrituras de producción de los proveedores de infraestructura
/// (`core_providers.dart`). Las pruebas usan sus propias sobrescrituras.
///
/// En web no hay SQLite ni notificaciones del sistema: se usa memoria y
/// avisos dentro de la app. En el resto, si un plugin no responde a tiempo,
/// la app arranca igual en lugar de quedarse en blanco.
Future<List<Override>> productionOverrides() async {
  final cfg = AppConfig.fromEnvironment();
  final prefs = await SharedPreferences.getInstance();

  LocalStore store = MemoryLocalStore();
  if (!kIsWeb) {
    try {
      store = await SqliteLocalStore.open().timeout(_pluginTimeout);
    } catch (_) {
      store = MemoryLocalStore();
    }
  }

  final LocalNotifier notifier;
  if (kIsWeb) {
    notifier = NoopLocalNotifier();
  } else {
    final platform = PlatformLocalNotifier();
    try {
      await platform.init().timeout(_pluginTimeout);
    } catch (_) {}
    notifier = platform;
  }

  return [
    appConfigProvider.overrideWithValue(cfg),
    sharedPrefsProvider.overrideWithValue(prefs),
    localStoreProvider.overrideWithValue(store),
    secureStoreProvider.overrideWithValue(const PlatformSecureStore()),
    connectivitySourceProvider.overrideWithValue(PlatformConnectivity()),
    localNotifierProvider.overrideWithValue(notifier),
    speechProvider.overrideWithValue(TtsSpeech()),
    accessTokenGetterProvider.overrideWith(
      (ref) =>
          () async => ref.read(authControllerProvider).session?.accessToken,
    ),
    cacheOwnerProvider.overrideWith((ref) => () => ref.read(ownerIdProvider)),
  ];
}
