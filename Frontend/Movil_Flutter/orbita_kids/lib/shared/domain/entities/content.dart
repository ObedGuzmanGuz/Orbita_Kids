import 'package:meta/meta.dart';

/// Modelos de contenido educativo compartidos por estudiante y docente.

enum MissionType { visual, choice, mix }

extension MissionTypeText on MissionType {
  String get label => switch (this) {
    MissionType.visual => 'Con dibujos',
    MissionType.choice => 'Elige la respuesta',
    MissionType.mix => 'Dibujos y opciones',
  };

  String get longLabel => switch (this) {
    MissionType.visual => 'Sumas con apoyo visual',
    MissionType.choice => 'Selección de respuestas',
    MissionType.mix => 'Visual + selección',
  };
}

@immutable
class Level {
  const Level(this.n, this.name, this.short, this.desc, this.max);
  final int n;
  final String name;
  final String short;
  final String desc;
  final int max;
}

enum PlanetKind { terra, ice, gas, ocean, lava, crystal }

@immutable
class Planet {
  const Planet({
    required this.id,
    required this.kind,
    required this.name,
    required this.lightArgb,
    required this.darkArgb,
    required this.level,
    required this.ring,
    required this.part,
  });

  final String id;
  final PlanetKind kind;
  final String name;

  /// Colores ARGB del degradado (la UI los convierte a `Color`).
  final int lightArgb;
  final int darkArgb;
  final int level;
  final bool ring;

  /// Pieza de la nave que se gana al completar el planeta.
  final String part;
}

@immutable
class Mission {
  const Mission({
    required this.id,
    required this.planetId,
    required this.n,
    required this.name,
    required this.type,
    required this.level,
    required this.story,
    required this.objective,
    required this.examples,
  });

  final String id;
  final String planetId;
  final int n;
  final String name;
  final MissionType type;
  final int level;
  final String story;
  final String objective;
  final List<String> examples;
}

@immutable
class BadgeDef {
  const BadgeDef(this.id, this.name, this.desc, this.colorArgb);
  final String id;
  final String name;
  final String desc;
  final int colorArgb;
}

enum PauseCategory { movement, outdoor, creative, family }

extension PauseCategoryText on PauseCategory {
  String get label => switch (this) {
    PauseCategory.movement => 'Movimiento espacial',
    PauseCategory.outdoor => 'Exploración al aire libre',
    PauseCategory.creative => 'Creatividad fuera de pantalla',
    PauseCategory.family => 'Retos familiares',
  };

  String get desc => switch (this) {
    PauseCategory.movement => 'Muévete como astronauta',
    PauseCategory.outdoor => 'Con un adulto cerca',
    PauseCategory.creative => 'Crea con tus manos',
    PauseCategory.family => 'Para hacer juntos',
  };
}

@immutable
class PauseActivity {
  const PauseActivity({
    required this.category,
    required this.id,
    required this.name,
    required this.pose,
    required this.seconds,
    required this.durationText,
    required this.desc,
    required this.objective,
    required this.materials,
    required this.steps,
    required this.safety,
    required this.alternative,
  });

  final PauseCategory category;
  final String id;
  final String name;

  /// Pose de Orbi para la ilustración.
  final String pose;
  final int seconds;
  final String durationText;
  final String desc;
  final String objective;
  final String materials;
  final List<String> steps;
  final String safety;
  final String alternative;
}

@immutable
class Galaxy {
  const Galaxy(
    this.id,
    this.name,
    this.iconKey,
    this.lightArgb,
    this.darkArgb,
    this.desc,
    this.topics,
  );
  final String id;
  final String name;

  /// Clave del ícono (`planet`, `book`, `grid`, `target`, `leaf`, `brush`).
  final String iconKey;
  final int lightArgb;
  final int darkArgb;
  final String desc;
  final List<String> topics;
}

@immutable
class Plan {
  const Plan({
    required this.id,
    required this.name,
    required this.monthly,
    required this.yearly,
    required this.who,
    required this.limits,
    required this.features,
    this.highlighted = false,
  });

  final String id;
  final String name;
  final int monthly;
  final int yearly;
  final String who;
  final List<String> limits;
  final List<String> features;
  final bool highlighted;
}

enum GroupStatus { active, archived }

@immutable
class SchoolGroup {
  const SchoolGroup({
    required this.id,
    required this.name,
    required this.grade,
    required this.code,
    required this.status,
  });

  final String id;
  final String name;
  final String grade;
  final String code;
  final GroupStatus status;

  SchoolGroup copyWith({String? name, String? grade, GroupStatus? status}) =>
      SchoolGroup(
        id: id,
        name: name ?? this.name,
        grade: grade ?? this.grade,
        code: code,
        status: status ?? this.status,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'grade': grade,
    'code': code,
    'status': status.name,
  };

  factory SchoolGroup.fromJson(Map<String, dynamic> j) => SchoolGroup(
    id: j['id'] as String,
    name: j['name'] as String,
    grade: j['grade'] as String,
    code: j['code'] as String,
    status: GroupStatus.values.byName(j['status'] as String),
  );
}

enum StudentStatus { upToDate, needsSupport, inactive, finished }

extension StudentStatusText on StudentStatus {
  String get label => switch (this) {
    StudentStatus.upToDate => 'Al día',
    StudentStatus.needsSupport => 'Necesita apoyo',
    StudentStatus.inactive => 'Sin actividad reciente',
    StudentStatus.finished => 'Ciclo terminado',
  };
}

@immutable
class StudentSummary {
  const StudentSummary({
    required this.id,
    required this.name,
    required this.groupId,
    required this.accuracy,
    required this.missed,
    required this.pending,
    required this.operations,
    required this.status,
    required this.colorArgb,
    required this.trend,
    required this.errors,
    required this.lastDays,
    this.recent = const [],
  });

  final String id;
  final String name;
  final String groupId;
  final int accuracy;
  final int missed;
  final int pending;
  final int operations;
  final StudentStatus status;
  final int colorArgb;
  final List<int> trend;
  final List<String> errors;

  /// Días desde el último intento; `null` si aún no hay intentos.
  final int? lastDays;

  /// Últimos intentos recibidos por el servidor (vacío en modo demo).
  final List<RecentAttempt> recent;
}

/// Intento de un estudiante tal como lo registró el servidor.
@immutable
class RecentAttempt {
  const RecentAttempt({
    required this.id,
    required this.title,
    required this.ok,
    required this.total,
    required this.date,
  });

  final String id;
  final String title;

  /// Aciertos al primer intento.
  final int ok;
  final int total;
  final DateTime date;
}

enum ActivityStatus { draft, scheduled, active, closed }

extension ActivityStatusText on ActivityStatus {
  String get label => switch (this) {
    ActivityStatus.draft => 'Borrador',
    ActivityStatus.scheduled => 'Programada',
    ActivityStatus.active => 'Activa',
    ActivityStatus.closed => 'Cerrada',
  };
}

@immutable
class Activity {
  const Activity({
    required this.id,
    required this.name,
    required this.groupId,
    required this.type,
    required this.level,
    required this.count,
    required this.assigned,
    required this.due,
    required this.status,
    required this.done,
    required this.instructions,
    this.pendingSync = false,
  });

  final String id;
  final String name;
  final String groupId;
  final MissionType type;
  final int level;
  final int count;
  final DateTime assigned;
  final DateTime due;
  final ActivityStatus status;

  /// Estudiantes que la terminaron.
  final int done;
  final String instructions;

  /// Guardada en el teléfono y aún no confirmada por el servidor.
  final bool pendingSync;

  Activity copyWith({
    String? name,
    String? groupId,
    MissionType? type,
    int? level,
    int? count,
    DateTime? assigned,
    DateTime? due,
    ActivityStatus? status,
    String? instructions,
    bool? pendingSync,
  }) => Activity(
    id: id,
    name: name ?? this.name,
    groupId: groupId ?? this.groupId,
    type: type ?? this.type,
    level: level ?? this.level,
    count: count ?? this.count,
    assigned: assigned ?? this.assigned,
    due: due ?? this.due,
    status: status ?? this.status,
    done: done,
    instructions: instructions ?? this.instructions,
    pendingSync: pendingSync ?? this.pendingSync,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'groupId': groupId,
    'type': type.name,
    'level': level,
    'count': count,
    'assigned': assigned.toIso8601String(),
    'due': due.toIso8601String(),
    'status': status.name,
    'done': done,
    'instructions': instructions,
    'pendingSync': pendingSync,
  };

  factory Activity.fromJson(Map<String, dynamic> j) => Activity(
    id: j['id'] as String,
    name: j['name'] as String,
    groupId: j['groupId'] as String,
    type: MissionType.values.byName(j['type'] as String),
    level: j['level'] as int,
    count: j['count'] as int,
    assigned: DateTime.parse(j['assigned'] as String),
    due: DateTime.parse(j['due'] as String),
    status: ActivityStatus.values.byName(j['status'] as String),
    done: j['done'] as int? ?? 0,
    instructions: j['instructions'] as String? ?? '',
    pendingSync: j['pendingSync'] as bool? ?? false,
  );
}

@immutable
class Institution {
  const Institution({
    required this.id,
    required this.name,
    required this.idp,
    required this.protocol,
    this.down = false,
  });

  final String id;
  final String name;
  final String idp;
  final String protocol;
  final bool down;
}
