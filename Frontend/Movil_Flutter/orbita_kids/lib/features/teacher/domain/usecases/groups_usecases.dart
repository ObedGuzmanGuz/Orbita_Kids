import 'package:orbita_kids/features/teacher/domain/repositories/groups_repository.dart';
import 'package:orbita_kids/features/teacher/domain/repositories/users_repository.dart';
import 'package:orbita_kids/shared/domain/entities/content.dart';

class GetGroups {
  const GetGroups(this._repo);
  final GroupsRepository _repo;

  Future<List<SchoolGroup>> call() => _repo.list();
}

/// Crea un grupo (requiere servidor; en demo se guarda en el teléfono).
class CreateGroup {
  const CreateGroup(this._repo);
  final GroupsRepository _repo;

  Future<SchoolGroup> call(String name, String grade) =>
      _repo.create(name.trim(), grade.trim());
}

class UpdateGroup {
  const UpdateGroup(this._repo);
  final GroupsRepository _repo;

  Future<SchoolGroup> call(SchoolGroup group) => _repo.update(group);
}

class GetGroupStudents {
  const GetGroupStudents(this._repo);
  final UsersRepository _repo;

  Future<List<StudentSummary>> call(String groupId) =>
      _repo.studentsOf(groupId);
}

/// Estudiantes de todos los grupos activos (dashboard).
class GetActiveStudents {
  const GetActiveStudents(this._repo);
  final UsersRepository _repo;

  Future<List<StudentSummary>> call(List<SchoolGroup> groups) async => [
    for (final g in groups.where((g) => g.status == GroupStatus.active))
      ...await _repo.studentsOf(g.id),
  ];
}

class GetStudent {
  const GetStudent(this._repo);
  final UsersRepository _repo;

  Future<StudentSummary?> call(String id) => _repo.student(id);
}

/// Promedio semanal de aciertos de un conjunto de estudiantes.
class WeeklyAverage {
  const WeeklyAverage();

  List<int> call(List<StudentSummary> list) {
    if (list.isEmpty) return const [];
    final weeks = list.first.trend.length;
    return List.generate(
      weeks,
      (k) =>
          (list.fold<int>(0, (a, s) => a + s.trend[k]) / list.length).round(),
    );
  }
}
