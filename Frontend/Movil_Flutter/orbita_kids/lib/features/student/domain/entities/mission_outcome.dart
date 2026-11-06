import 'package:meta/meta.dart';

import 'package:orbita_kids/features/student/domain/services/mission_engine.dart';

/// Resultado de cerrar una misión (pantalla 22).
@immutable
class MissionOutcome {
  const MissionOutcome({
    required this.stars,
    required this.percent,
    required this.firstTry,
    required this.total,
    required this.attempts,
    required this.rule,
    required this.notifyTeacher,
    required this.piece,
    required this.firstCompletion,
    required this.newBadges,
    required this.queued,
    required this.guest,
  });

  final int stars;
  final int percent;
  final int firstTry;
  final int total;
  final int attempts;
  final AdaptRule? rule;
  final bool notifyTeacher;
  final String? piece;
  final bool firstCompletion;
  final List<String> newBadges;

  /// ID del registro en la cola de sincronización (null si es invitado).
  final String? queued;
  final bool guest;
}
