import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'package:orbita_kids/features/settings/presentation/providers/settings_controller.dart';

/// Lectura en voz alta de instrucciones (botón «Escuchar»).
abstract interface class Speech {
  Future<void> say(String text, {double volume});
  Future<void> stop();
}

class TtsSpeech implements Speech {
  final _tts = FlutterTts();
  bool _ready = false;

  Future<void> _init() async {
    if (_ready) return;
    await _tts.setLanguage('es-MX');
    await _tts.setSpeechRate(0.45);
    _ready = true;
  }

  @override
  Future<void> say(String text, {double volume = .7}) async {
    try {
      await _init();
      await _tts.setVolume(volume);
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {
      // Sin motor de voz en el dispositivo: el texto sigue disponible para
      // el lector de pantalla mediante las etiquetas semánticas.
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }
}

class SilentSpeech implements Speech {
  final said = <String>[];

  @override
  Future<void> say(String text, {double volume = .7}) async => said.add(text);

  @override
  Future<void> stop() async {}
}

final speechProvider = Provider<Speech>((_) => SilentSpeech());

/// Atajo que respeta el volumen elegido en Configuración.
extension SpeakX on WidgetRef {
  Future<void> speak(String text) =>
      read(speechProvider)
          .say(text, volume: read(settingsProvider).volume / 100);
}
