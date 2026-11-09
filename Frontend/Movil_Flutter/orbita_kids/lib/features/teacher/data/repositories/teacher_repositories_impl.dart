import 'package:orbita_kids/core/network/api_client.dart';
import 'package:orbita_kids/core/storage/local_store.dart';
import 'package:orbita_kids/features/teacher/domain/repositories/groups_repository.dart';
import 'package:orbita_kids/features/teacher/domain/repositories/users_repository.dart';
import 'package:orbita_kids/shared/data/demo/demo_data.dart';
import 'package:orbita_kids/shared/domain/entities/content.dart';

// ===================== MODO DEMO =====================

class DemoGroupsRepository implements GroupsRepository {
  DemoGroupsRepository(this._store);
  final LocalStore _store;
  static const col = 'demo_groups';

  @override
  bool get available => true;

  @override
  Future<List<SchoolGroup>> list() async {
    final local = {
      for (final j in await _store.all(col))
        (j['id'] as String): SchoolGroup.fromJson(j),
    };
    return [
      for (final g in DemoData.groups) local.remove(g.id) ?? g,
      ...local.values,
    ];
  }

  @override
  Future<SchoolGroup> create(String name, String grade) async {
    final id = 'g${DateTime.now().millisecondsSinceEpoch}';
    // Código de demostración: en producción lo emite la licencia (backend).
    final code = 'ORB-${id.substring(id.length - 4).toUpperCase()}';
    final g = SchoolGroup(
      id: id,
      name: name,
      grade: grade,
      code: code,
      status: GroupStatus.active,
    );
    await _store.put(col, id, g.toJson());
    return g;
  }

  @override
  Future<SchoolGroup> update(SchoolGroup group) async {
    await _store.put(col, group.id, group.toJson());
    return group;
  }
}

class DemoUsersRepository implements UsersRepository {
  const DemoUsersRepository();

  @override
  List<String> trendLabels() => DemoData.weeks;

  @override
  bool get available => true;

  @override
  Future<List<StudentSummary>> studentsOf(String groupId) async =>
      DemoData.students[groupId] ?? const [];

  @override
  Future<StudentSummary?> student(String id) async {
    for (final l in DemoData.students.values) {
      for (final s in l) {
        if (s.id == id) return s;
      }
    }
    return null;
  }
}

// ============ SIN BACKEND (Keycloak configurado, API pendiente) ============

class PendingGroupsRepository implements GroupsRepository {
  const PendingGroupsRepository();

  @override
  bool get available => false;

  @override
  Future<List<SchoolGroup>> list() async => const [];

  @override
  Future<SchoolGroup> create(String name, String grade) =>
      throw const BackendUnavailable('crear grupos');

  @override
  Future<SchoolGroup> update(SchoolGroup group) =>
      throw const BackendUnavailable('editar grupos');
}

class PendingUsersRepository implements UsersRepository {
  const PendingUsersRepository();

  @override
  List<String> trendLabels() => const [];

  @override
  bool get available => false;

  @override
  Future<List<StudentSummary>> studentsOf(String groupId) async => const [];

  @override
  Future<StudentSummary?> student(String id) async => null;
}
