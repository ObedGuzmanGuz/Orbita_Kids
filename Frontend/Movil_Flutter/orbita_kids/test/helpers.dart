import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:orbita_kids/app.dart';
import 'package:orbita_kids/core/audio/speech.dart';
import 'package:orbita_kids/config/env/app_config.dart';
import 'package:orbita_kids/core/network/connectivity.dart';
import 'package:orbita_kids/core/notifications/local_notifier.dart';
import 'package:orbita_kids/config/providers/core_providers.dart';
import 'package:orbita_kids/core/storage/local_store.dart';
import 'package:orbita_kids/core/storage/secure_store.dart';
import 'package:orbita_kids/core/sync/providers/sync_providers.dart';
import 'package:orbita_kids/core/sync/domain/sync_gateway.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Fecha fija del prototipo: jueves 29 de octubre de 2026, 10:00.
final fixedNow = DateTime(2026, 10, 29, 10);

Future<void> initTestEnv() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_MX');
}

/// Dependencias falsas e inspeccionables para pruebas.
class TestDeps {
  TestDeps({bool online = true, this.gateway})
    : connectivity = FakeConnectivity(online);

  final store = MemoryLocalStore();
  final secure = MemorySecureStore();
  final FakeConnectivity connectivity;
  final notifier = NoopLocalNotifier();
  final speech = SilentSpeech();
  final SyncGateway? gateway;
  DateTime now = fixedNow;

  Future<List> overrides({Map<String, Object> prefs = const {}}) async {
    SharedPreferences.setMockInitialValues({
      // Movimiento reducido: evita animaciones infinitas en pumpAndSettle.
      'orbita-kids-prefs-v2': '{"reducedMotion":true,"onboarded":true}',
      ...prefs,
    });
    final sp = await SharedPreferences.getInstance();
    return [
      appConfigProvider.overrideWithValue(AppConfig.demo),
      sharedPrefsProvider.overrideWithValue(sp),
      localStoreProvider.overrideWithValue(store),
      secureStoreProvider.overrideWithValue(secure),
      connectivitySourceProvider.overrideWithValue(connectivity),
      localNotifierProvider.overrideWithValue(notifier),
      speechProvider.overrideWithValue(speech),
      clockProvider.overrideWithValue(() => now),
      if (gateway != null) syncGatewayProvider.overrideWithValue(gateway!),
    ];
  }

  Future<ProviderContainer> container({
    Map<String, Object> prefs = const {},
  }) async {
    final c = ProviderContainer(
      overrides: [...(await overrides(prefs: prefs))],
    );
    addTearDown(c.dispose);
    return c;
  }
}

Future<void> pumpApp(WidgetTester tester, TestDeps deps) async {
  tester.view.physicalSize = const Size(1170, 6000);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [...(await deps.overrides())],
      child: const OrbitaKidsApp(),
    ),
  );
}

/// Avanza el reloj de prueba en pasos para que corran timers y navegación.
Future<void> advance(WidgetTester tester, Duration d) async {
  const step = Duration(milliseconds: 100);
  var t = Duration.zero;
  while (t < d) {
    await tester.pump(step);
    t += step;
  }
}
