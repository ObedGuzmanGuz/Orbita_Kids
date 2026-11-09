import 'package:orbita_kids/features/student/domain/entities/student_progress.dart';
import 'package:orbita_kids/features/student/domain/repositories/student_repositories.dart';
import 'package:orbita_kids/shared/domain/entities/avatar_look.dart';
import 'package:orbita_kids/shared/domain/entities/content.dart';
import 'package:orbita_kids/shared/domain/repositories/activities_repository.dart';

/// Reglas puras sobre el progreso (sin E/S).
abstract final class ProgressRules {
  /// Reinicia los minutos de hoy al cambiar de día.
  static StudentProgress rollDay(StudentProgress p, DateTime now) {
    final d = p.minutesDate;
    final sameDay =
        d != null &&
        d.year == now.year &&
        d.month == now.month &&
        d.day == now.day;
    return sameDay ? p : p.copyWith(minutesToday: 0, minutesDate: now);
  }

  static StudentProgress withLook(StudentProgress p, AvatarLook look) =>
      p.copyWith(look: look);

  static StudentProgress renamed(StudentProgress p, String name) =>
      p.copyWith(name: name.trim());

  static StudentProgress withDownload(StudentProgress p, String id, bool on) {
    final d = {...p.downloads};
    on ? d.add(id) : d.remove(id);
    return p.copyWith(downloads: d);
  }

  /// Una Pausa Estelar terminada da la insignia «Explorador activo».
  static StudentProgress afterPause(StudentProgress p) =>
      p.copyWith(pausesDone: p.pausesDone + 1, badges: {...p.badges, 'b4'});
}

/// Lee el progreso guardado (o el inicial) y lo deja al día.
class LoadStudentProgress {
  const LoadStudentProgress(this._repo);
  final ProgressRepository _repo;

  Future<StudentProgress> call({
    required String owner,
    required String name,
    required DateTime now,
  }) async {
    final saved = await _repo.load(owner);
    final p = ProgressRules.rollDay(saved ?? _repo.initialFor(name, now), now);
    await _repo.save(owner, p);
    return p;
  }
}

class SaveStudentProgress {
  const SaveStudentProgress(this._repo);
  final ProgressRepository _repo;

  Future<void> call(String owner, StudentProgress p) => _repo.save(owner, p);
}

/// Tareas que la maestra asignó al grupo (activas o cerradas).
class GetStudentTasks {
  const GetStudentTasks(this._repo);
  final ActivitiesRepository _repo;

  Future<List<Activity>> call(String groupId) async => (await _repo.list())
      .where(
        (a) =>
            a.groupId == groupId &&
            (a.status == ActivityStatus.active ||
                a.status == ActivityStatus.closed),
      )
      .toList();
}

/// Tareas activas aún sin hacer.
class PendingTasks {
  const PendingTasks();

  List<Activity> call(List<Activity> tasks, Set<String> done) => tasks
      .where((a) => a.status == ActivityStatus.active && !done.contains(a.id))
      .toList();
}
