import 'package:meta/meta.dart';

import 'package:orbita_kids/shared/domain/entities/avatar_look.dart';
import 'package:orbita_kids/shared/domain/content/catalog.dart';
import 'package:orbita_kids/shared/domain/entities/content.dart';

@immutable
class HistoryEntry {
  const HistoryEntry({
    required this.name,
    required this.date,
    required this.ok,
    required this.total,
    required this.stars,
    required this.type,
  });

  final String name;
  final DateTime date;
  final int ok;
  final int total;
  final int stars;
  final MissionType type;

  Map<String, dynamic> toJson() => {
    'name': name,
    'date': date.toIso8601String(),
    'ok': ok,
    'total': total,
    'stars': stars,
    'type': type.name,
  };

  factory HistoryEntry.fromJson(Map<String, dynamic> j) => HistoryEntry(
    name: j['name'] as String,
    date: DateTime.parse(j['date'] as String),
    ok: j['ok'] as int,
    total: j['total'] as int,
    stars: j['stars'] as int,
    type: MissionType.values.byName(j['type'] as String),
  );
}

/// Progreso local del estudiante (offline first).
@immutable
class StudentProgress {
  const StudentProgress({
    this.name = 'Astronauta',
    this.look = const AvatarLook(),
    this.stars = 0,
    this.minutesToday = 0,
    this.minutesDate,
    this.done = const {},
    this.pieces = const [],
    this.lowStreak = 0,
    this.history = const [],
    this.sessionAccuracy = const [],
    this.badges = const {},
    this.tasksDone = const {},
    this.pausesDone = 0,
    this.downloads = const {},
    this.loaded = true,
  });

  final String name;
  final AvatarLook look;
  final int stars;
  final int minutesToday;
  final DateTime? minutesDate;

  /// Misión → mejores estrellas obtenidas.
  final Map<String, int> done;

  /// Piezas de la nave ganadas.
  final List<String> pieces;

  /// Misiones seguidas por debajo de 60 % (R4).
  final int lowStreak;
  final List<HistoryEntry> history;
  final List<int> sessionAccuracy;
  final Set<String> badges;
  final Set<String> tasksDone;
  final int pausesDone;

  /// Planetas descargados para usar sin Internet.
  final Set<String> downloads;

  /// `false` mientras se lee el progreso guardado (muestra la carga esqueleto).
  final bool loaded;

  int doneCount(String planetId) =>
      Catalog.missionsOf(planetId).where((m) => done.containsKey(m.id)).length;

  bool planetUnlocked(String planetId, {bool guest = false}) {
    final i = Catalog.planets.indexWhere((p) => p.id == planetId);
    if (i == 0) return true;
    if (guest) return false;
    return doneCount(Catalog.planets[i - 1].id) == 3;
  }

  /// Siguiente misión pendiente en planetas desbloqueados.
  Mission nextMission({bool guest = false}) {
    for (final p in Catalog.planets) {
      if (!planetUnlocked(p.id, guest: guest)) break;
      for (final m in Catalog.missionsOf(p.id)) {
        if (!done.containsKey(m.id)) return m;
      }
    }
    return guest ? Catalog.missions.first : Catalog.missions.last;
  }

  bool isDownloaded(String planetId) => downloads.contains(planetId);

  StudentProgress copyWith({
    String? name,
    AvatarLook? look,
    int? stars,
    int? minutesToday,
    DateTime? minutesDate,
    Map<String, int>? done,
    List<String>? pieces,
    int? lowStreak,
    List<HistoryEntry>? history,
    List<int>? sessionAccuracy,
    Set<String>? badges,
    Set<String>? tasksDone,
    int? pausesDone,
    Set<String>? downloads,
    bool? loaded,
  }) => StudentProgress(
    name: name ?? this.name,
    look: look ?? this.look,
    stars: stars ?? this.stars,
    minutesToday: minutesToday ?? this.minutesToday,
    minutesDate: minutesDate ?? this.minutesDate,
    done: done ?? this.done,
    pieces: pieces ?? this.pieces,
    lowStreak: lowStreak ?? this.lowStreak,
    history: history ?? this.history,
    sessionAccuracy: sessionAccuracy ?? this.sessionAccuracy,
    badges: badges ?? this.badges,
    tasksDone: tasksDone ?? this.tasksDone,
    pausesDone: pausesDone ?? this.pausesDone,
    downloads: downloads ?? this.downloads,
    loaded: loaded ?? this.loaded,
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'look': look.toJson(),
    'stars': stars,
    'minutesToday': minutesToday,
    'minutesDate': minutesDate?.toIso8601String(),
    'done': done,
    'pieces': pieces,
    'lowStreak': lowStreak,
    'history': [for (final h in history) h.toJson()],
    'sessionAccuracy': sessionAccuracy,
    'badges': badges.toList(),
    'tasksDone': tasksDone.toList(),
    'pausesDone': pausesDone,
    'downloads': downloads.toList(),
  };

  factory StudentProgress.fromJson(Map<String, dynamic> j) => StudentProgress(
    name: j['name'] as String? ?? 'Astronauta',
    look: AvatarLook.fromJson(
      Map<String, dynamic>.from(j['look'] as Map? ?? {}),
    ),
    stars: j['stars'] as int? ?? 0,
    minutesToday: j['minutesToday'] as int? ?? 0,
    minutesDate: j['minutesDate'] == null
        ? null
        : DateTime.parse(j['minutesDate'] as String),
    done: Map<String, int>.from(j['done'] as Map? ?? {}),
    pieces: List<String>.from(j['pieces'] as List? ?? const []),
    lowStreak: j['lowStreak'] as int? ?? 0,
    history: [
      for (final h in (j['history'] as List? ?? const []))
        HistoryEntry.fromJson(Map<String, dynamic>.from(h as Map)),
    ],
    sessionAccuracy: List<int>.from(j['sessionAccuracy'] as List? ?? const []),
    badges: Set<String>.from(j['badges'] as List? ?? const []),
    tasksDone: Set<String>.from(j['tasksDone'] as List? ?? const []),
    pausesDone: j['pausesDone'] as int? ?? 0,
    downloads: Set<String>.from(j['downloads'] as List? ?? const ['uno']),
  );

  /// Invitado (modo explorar): nada se guarda.
  static const guest = StudentProgress(name: 'explorador', downloads: {'uno'});
}
