import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Fuente de conectividad inyectable (connectivity_plus en la app real).
abstract interface class ConnectivitySource {
  Future<bool> isOnline();
  Stream<bool> changes();
}

class PlatformConnectivity implements ConnectivitySource {
  final _c = Connectivity();

  static bool _on(List<ConnectivityResult> r) =>
      r.any((e) => e != ConnectivityResult.none);

  @override
  Future<bool> isOnline() async {
    try {
      return _on(await _c.checkConnectivity());
    } catch (_) {
      return true;
    }
  }

  @override
  Stream<bool> changes() => _c.onConnectivityChanged.map(_on);
}

/// Fuente controlable (pruebas).
class FakeConnectivity implements ConnectivitySource {
  FakeConnectivity([this.online = true]);

  bool online;
  final _ctrl = StreamController<bool>.broadcast();

  void set(bool value) {
    online = value;
    _ctrl.add(value);
  }

  @override
  Future<bool> isOnline() async => online;

  @override
  Stream<bool> changes() => _ctrl.stream;
}

final connectivitySourceProvider = Provider<ConnectivitySource>(
  (_) => FakeConnectivity(),
);

class OnlineController extends Notifier<bool> {
  StreamSubscription<bool>? _sub;

  @override
  bool build() {
    final src = ref.watch(connectivitySourceProvider);
    _sub?.cancel();
    _sub = src.changes().listen((v) => state = v);
    ref.onDispose(() => _sub?.cancel());
    src.isOnline().then((v) {
      if (ref.mounted) state = v;
    });
    return true;
  }
}

/// `true` si hay red. Las pantallas lo usan para desactivar lo que la requiere.
final onlineProvider = NotifierProvider<OnlineController, bool>(
  OnlineController.new,
);
