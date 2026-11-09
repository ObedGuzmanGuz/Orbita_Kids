import 'package:orbita_kids/core/sync/domain/sync_models.dart';
import 'package:orbita_kids/core/sync/domain/sync_queue.dart';
import 'package:orbita_kids/features/student/domain/entities/mission_outcome.dart';
import 'package:orbita_kids/features/student/domain/entities/student_progress.dart';
import 'package:orbita_kids/features/student/domain/repositories/student_repositories.dart';
import 'package:orbita_kids/features/student/domain/services/mission_engine.dart';
import 'package:orbita_kids/features/student/domain/usecases/progress_usecases.dart';
import 'package:orbita_kids/shared/domain/entities/content.dart';

/// Prepara una misión del mapa (o su refuerzo R3 con sumas pequeñas).
class StartMission {
  const StartMission(this._missions);
  final MissionsRepository _missions;

  MissionRun call(String missionId, {bool reinforcement = false}) {
    final m = _missions.mission(missionId);
    final level = reinforcement ? 1 : m.level;
    final type = reinforcement ? MissionType.visual : m.type;
    return MissionRun(
      missionId: m.id,
      name: reinforcement ? 'Refuerzo: ${m.name}' : m.name,
      level: level,
      type: type,
      planetId: m.planetId,
      reinforcement: reinforcement,
      items: generateItems(level, type, n: 5, easy: reinforcement),
    );
  }
}

/// Prepara una tarea de la maestra (bloques de hasta 6 ejercicios).
class StartAssignedTask {
  const StartAssignedTask();

  MissionRun call(Activity a) => MissionRun(
    missionId: a.id,
    name: a.name,
    level: a.level,
    type: a.type,
    assigned: true,
    items: generateItems(a.level, a.type, n: a.count.clamp(1, 6)),
  );
}

/// Cierra una misión: estrellas, piezas de la nave, insignias, reglas R2–R4,
/// guarda el progreso y deja el resultado en la cola de sincronización.
/// En modo explorar (`owner == null`) no se guarda ni se envía nada.
class FinishMission {
  const FinishMission(this._missions, this._progress, this._queue);
  final MissionsRepository _missions;
  final ProgressRepository _progress;
  final SyncQueue _queue;

  Future<(StudentProgress, MissionOutcome)> call(
    StudentProgress s,
    MissionRun run, {
    required String? owner,
    required DateTime now,
  }) async {
    final guest = owner == null;
    final stars = run.stars;
    final first = !run.assigned && !s.done.containsKey(run.missionId);
    final done = {...s.done};
    final tasks = {...s.tasksDone};
    if (run.assigned) {
      tasks.add(run.missionId);
    } else {
      final prev = done[run.missionId] ?? 0;
      done[run.missionId] = prev > stars ? prev : stars;
    }
    final low = run.percent < 60 ? s.lowStreak + 1 : 0;

    final pieces = [...s.pieces];
    String? piece;
    if (!run.assigned && run.planetId != null) {
      final p = _missions.planets().firstWhere((x) => x.id == run.planetId);
      final allDone = _missions
          .missionsOf(p.id)
          .every((m) => done.containsKey(m.id));
      if (allDone && !pieces.contains(p.part)) {
        piece = p.part;
        pieces.add(p.part);
      }
    }

    final badges = {...s.badges};
    final before = {...badges};
    if (first || s.history.isEmpty) badges.add('b1');
    if (run.hints > 0) badges.add('b6');
    if (piece == 'luces') badges.add('b2');
    if (piece == 'antena') badges.add('b5');
    if (run.firstTry >= 10) badges.add('b3');

    final acc = [...s.sessionAccuracy, run.percent];
    if (acc.length > 6) acc.removeAt(0);
    final today = ProgressRules.rollDay(s, now);
    final next = today.copyWith(
      stars: s.stars + stars,
      minutesToday: today.minutesToday + 4,
      done: done,
      tasksDone: tasks,
      lowStreak: low,
      pieces: pieces,
      badges: badges,
      sessionAccuracy: acc,
      history: [
        HistoryEntry(
          name: run.name,
          date: now,
          ok: run.firstTry,
          total: run.total,
          stars: stars,
          type: run.type,
        ),
        ...s.history,
      ].take(30).toList(),
    );

    final notify = shouldNotifyTeacher(low);
    String? queued;
    if (!guest) {
      await _progress.save(owner, next);
      final item = await _queue.enqueue(
        kind: SyncKind.attempt,
        owner: owner,
        title: run.name,
        detail:
            '${run.firstTry}/${run.total} al primer intento · ${run.attempts} intentos',
        payload: {
          'missionId': run.missionId,
          'assigned': run.assigned,
          'level': run.level,
          'firstTry': run.firstTry,
          'total': run.total,
          'attempts': run.attempts,
          'attemptIds': run.attemptIds,
          'stars': stars,
          'support': run.support,
          'rule': run.rule?.name,
          'notifyTeacher': notify,
          'finishedAt': now.toIso8601String(),
        },
      );
      queued = item.id;
    }

    return (
      next,
      MissionOutcome(
        stars: stars,
        percent: run.percent,
        firstTry: run.firstTry,
        total: run.total,
        attempts: run.attempts,
        rule: run.rule,
        notifyTeacher: notify && !guest,
        piece: piece,
        firstCompletion: first,
        newBadges: badges.difference(before).toList(),
        queued: queued,
        guest: guest,
      ),
    );
  }
}
