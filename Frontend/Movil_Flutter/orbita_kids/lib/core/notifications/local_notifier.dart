import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Notificaciones locales del sistema (no push: el backend aún no existe).
abstract interface class LocalNotifier {
  Future<void> init();
  Future<void> show(int id, String title, String body);
}

class PlatformLocalNotifier implements LocalNotifier {
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'orbita_general',
      'Avisos de Órbita Kids',
      channelDescription: 'Actividades, resultados, sincronización y descansos',
      importance: Importance.defaultImportance,
    ),
    iOS: DarwinNotificationDetails(),
  );

  @override
  Future<void> init() async {
    try {
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(),
        ),
      );
      await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
      _ready = true;
    } catch (_) {
      _ready = false;
    }
  }

  @override
  Future<void> show(int id, String title, String body) async {
    if (!_ready) return;
    try {
      await _plugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: _details,
      );
    } catch (_) {}
  }
}

class NoopLocalNotifier implements LocalNotifier {
  final shown = <String>[];

  @override
  Future<void> init() async {}

  @override
  Future<void> show(int id, String title, String body) async =>
      shown.add(title);
}

final localNotifierProvider = Provider<LocalNotifier>(
  (_) => NoopLocalNotifier(),
);

/// Horario sin avisos: ninguno de 8:00 p. m. a 7:00 a. m.
bool inQuietHours(DateTime now) => now.hour >= 20 || now.hour < 7;
