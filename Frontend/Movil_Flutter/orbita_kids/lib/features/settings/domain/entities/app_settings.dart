import 'package:meta/meta.dart';

/// Tema elegido: automático (sigue al sistema), claro u oscuro.
enum AppThemeChoice { auto, light, dark }

/// Preferencias del usuario. Persisten entre sesiones (SharedPreferences),
/// equivalentes a `PREF_DEF` del prototipo.
@immutable
class AppSettings {
  const AppSettings({
    this.theme = AppThemeChoice.auto,
    this.textScale = 1.0,
    this.highContrast = false,
    this.reducedMotion = false,
    this.readAloud = false,
    this.sounds = true,
    this.volume = 70,
    this.symbols = false,
    this.onboarded = false,
    this.notifActivities = true,
    this.notifResults = true,
    this.notifSync = true,
    this.notifRest = true,
    this.notifGroups = true,
    this.quietHours = true,
    this.wifiOnlyDownloads = true,
  });

  final AppThemeChoice theme;
  final double textScale;
  final bool highContrast;
  final bool reducedMotion;
  final bool readAloud;
  final bool sounds;
  final int volume;
  final bool symbols;
  final bool onboarded;
  final bool notifActivities;
  final bool notifResults;
  final bool notifSync;
  final bool notifRest;
  final bool notifGroups;
  final bool quietHours;
  final bool wifiOnlyDownloads;

  AppSettings copyWith({
    AppThemeChoice? theme,
    double? textScale,
    bool? highContrast,
    bool? reducedMotion,
    bool? readAloud,
    bool? sounds,
    int? volume,
    bool? symbols,
    bool? onboarded,
    bool? notifActivities,
    bool? notifResults,
    bool? notifSync,
    bool? notifRest,
    bool? notifGroups,
    bool? quietHours,
    bool? wifiOnlyDownloads,
  }) => AppSettings(
    theme: theme ?? this.theme,
    textScale: textScale ?? this.textScale,
    highContrast: highContrast ?? this.highContrast,
    reducedMotion: reducedMotion ?? this.reducedMotion,
    readAloud: readAloud ?? this.readAloud,
    sounds: sounds ?? this.sounds,
    volume: volume ?? this.volume,
    symbols: symbols ?? this.symbols,
    onboarded: onboarded ?? this.onboarded,
    notifActivities: notifActivities ?? this.notifActivities,
    notifResults: notifResults ?? this.notifResults,
    notifSync: notifSync ?? this.notifSync,
    notifRest: notifRest ?? this.notifRest,
    notifGroups: notifGroups ?? this.notifGroups,
    quietHours: quietHours ?? this.quietHours,
    wifiOnlyDownloads: wifiOnlyDownloads ?? this.wifiOnlyDownloads,
  );

  Map<String, dynamic> toJson() => {
    'theme': theme.name,
    'textScale': textScale,
    'highContrast': highContrast,
    'reducedMotion': reducedMotion,
    'readAloud': readAloud,
    'sounds': sounds,
    'volume': volume,
    'symbols': symbols,
    'onboarded': onboarded,
    'notifActivities': notifActivities,
    'notifResults': notifResults,
    'notifSync': notifSync,
    'notifRest': notifRest,
    'notifGroups': notifGroups,
    'quietHours': quietHours,
    'wifiOnlyDownloads': wifiOnlyDownloads,
  };

  factory AppSettings.fromJson(Map<String, dynamic> j) {
    const d = AppSettings();
    return AppSettings(
      theme: AppThemeChoice.values.firstWhere(
        (t) => t.name == j['theme'],
        orElse: () => d.theme,
      ),
      textScale: (j['textScale'] as num?)?.toDouble() ?? d.textScale,
      highContrast: j['highContrast'] as bool? ?? d.highContrast,
      reducedMotion: j['reducedMotion'] as bool? ?? d.reducedMotion,
      readAloud: j['readAloud'] as bool? ?? d.readAloud,
      sounds: j['sounds'] as bool? ?? d.sounds,
      volume: j['volume'] as int? ?? d.volume,
      symbols: j['symbols'] as bool? ?? d.symbols,
      onboarded: j['onboarded'] as bool? ?? d.onboarded,
      notifActivities: j['notifActivities'] as bool? ?? d.notifActivities,
      notifResults: j['notifResults'] as bool? ?? d.notifResults,
      notifSync: j['notifSync'] as bool? ?? d.notifSync,
      notifRest: j['notifRest'] as bool? ?? d.notifRest,
      notifGroups: j['notifGroups'] as bool? ?? d.notifGroups,
      quietHours: j['quietHours'] as bool? ?? d.quietHours,
      wifiOnlyDownloads: j['wifiOnlyDownloads'] as bool? ?? d.wifiOnlyDownloads,
    );
  }
}
