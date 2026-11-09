import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:orbita_kids/config/providers/core_providers.dart';
import 'package:orbita_kids/features/auth/domain/entities/auth_entities.dart';
import 'package:orbita_kids/features/auth/presentation/providers/auth_controller.dart';
import 'package:orbita_kids/features/student/providers/student_providers.dart';
import 'package:orbita_kids/features/student/domain/entities/mission_outcome.dart';
import 'package:orbita_kids/features/student/domain/entities/student_progress.dart';
import 'package:orbita_kids/features/student/domain/services/mission_engine.dart';
import 'package:orbita_kids/features/student/domain/usecases/mission_usecases.dart';
import 'package:orbita_kids/features/student/domain/usecases/progress_usecases.dart';
import 'package:orbita_kids/shared/domain/entities/avatar_look.dart';
import 'package:orbita_kids/shared/domain/entities/content.dart';

export 'package:orbita_kids/features/student/domain/entities/mission_outcome.dart';

/// Progreso observable del estudiante. Cada acción delega en un caso de uso;
/// el invitado (modo explorar) trabaja en memoria y no guarda nada.
class StudentController extends Notifier<StudentProgress> {
  @override
  StudentProgress build() {
    final auth = ref.watch(authControllerProvider);
    if (auth.isGuest) return StudentProgress.guest;
    final user = auth.user;
    if (user == null || user.role != UserRole.student) {
      return const StudentProgress();
    }
    _load(user);
    return StudentProgress(name: user.name, loaded: false);
  }

  DateTime _now() => ref.read(clockProvider)();

  Future<void> _load(AppUser user) async {
    final p = await ref
        .read(loadStudentProgressProvider)
        .call(owner: user.id, name: user.name, now: _now());
    if (ref.mounted) state = p;
  }

  /// Dueño de los datos, o `null` en modo explorar.
  String? get _owner => ref.read(authControllerProvider).isGuest
      ? null
      : ref.read(currentUserProvider)?.id;

  Future<void> _apply(StudentProgress p) async {
    state = p;
    final owner = _owner;
    if (owner != null) {
      await ref.read(saveStudentProgressProvider).call(owner, p);
    }
  }

  Future<void> saveLook(AvatarLook look) =>
      _apply(ProgressRules.withLook(state, look));

  Future<void> rename(String name) =>
      _apply(ProgressRules.renamed(state, name));

  Future<void> setDownloaded(String id, bool on) =>
      _apply(ProgressRules.withDownload(state, id, on));

  Future<void> pauseFinished() => _apply(ProgressRules.afterPause(state));

  /// Cierra la misión (ver [FinishMission]).
  Future<MissionOutcome> finish(MissionRun run) async {
    final (next, outcome) = await ref
        .read(finishMissionProvider)
        .call(state, run, owner: _owner, now: _now());
    if (ref.mounted) state = next;
    return outcome;
  }
}

final studentProvider = NotifierProvider<StudentController, StudentProgress>(
  StudentController.new,
);

/// Misión en curso (una a la vez).
class RunController extends Notifier<MissionRun?> {
  @override
  MissionRun? build() => null;

  MissionRun startMission(String missionId, {bool easy = false}) => state = ref
      .read(startMissionProvider)
      .call(missionId, reinforcement: easy);

  MissionRun startAssigned(Activity a) =>
      state = const StartAssignedTask().call(a);

  /// Inicia una misión ya construida (pruebas o reanudación).
  void begin(MissionRun run) => state = run;

  /// Notifica cambios internos del run (respuestas, avance).
  void touch() => ref.notifyListeners();

  void clear() => state = null;
}

final runProvider = NotifierProvider<RunController, MissionRun?>(
  RunController.new,
);
