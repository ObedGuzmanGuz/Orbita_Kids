import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:orbita_kids/core/sync/domain/sync_models.dart';
import 'package:orbita_kids/core/sync/presentation/providers/sync_controller.dart';
import 'package:orbita_kids/features/auth/presentation/providers/auth_controller.dart';
import 'package:orbita_kids/features/teacher/providers/teacher_providers.dart';
import 'package:orbita_kids/features/teacher/domain/usecases/activities_usecases.dart';
import 'package:orbita_kids/shared/domain/entities/content.dart';

export 'package:orbita_kids/features/teacher/providers/teacher_providers.dart'
    show teacherDataAvailableProvider, trendLabelsProvider;

/// Estado de la presentación del docente. Cada proveedor llama a un caso de
/// uso; ninguno conoce las implementaciones de datos.

final groupsProvider = FutureProvider<List<SchoolGroup>>(
  (ref) => ref.watch(getGroupsProvider).call(),
);

final activeGroupsProvider = Provider<List<SchoolGroup>>(
  (ref) => (ref.watch(groupsProvider).value ?? const [])
      .where((g) => g.status == GroupStatus.active)
      .toList(),
);

final studentsOfProvider = FutureProvider.family<List<StudentSummary>, String>(
  (ref, groupId) => ref.watch(getGroupStudentsProvider).call(groupId),
);

final allStudentsProvider = FutureProvider<List<StudentSummary>>(
  (ref) => ref
      .watch(getActiveStudentsProvider)
      .call(ref.watch(activeGroupsProvider)),
);

final studentProviderById = FutureProvider.family<StudentSummary?, String>(
  (ref, id) => ref.watch(getStudentProvider).call(id),
);

/// Actividades + borradores locales; marca las que siguen en la cola.
final activitiesProvider = FutureProvider<List<Activity>>((ref) {
  final queued = ref
      .watch(syncControllerProvider)
      .items
      .where((i) => i.kind == SyncKind.activityDraft)
      .map((i) => i.id)
      .toSet();
  return ref.watch(getActivitiesProvider).call(queuedIds: queued);
});

/// Acciones del docente: delegan en los casos de uso y refrescan el estado.
class TeacherActions {
  TeacherActions(this.ref);
  final Ref ref;

  static const _uuid = Uuid();

  String newId() => _uuid.v4();

  Map<String, String> validate(Activity a, {required bool publishing}) =>
      const ValidateActivity().call(a, publishing: publishing);

  Future<void> saveDraft(Activity a) async {
    await ref.read(saveActivityDraftProvider).call(a);
    ref.invalidate(activitiesProvider);
  }

  Future<void> publish(Activity a, {required bool scheduled}) async {
    final user = ref.read(currentUserProvider)!;
    await ref
        .read(publishActivityProvider)
        .call(a, owner: user.id, scheduled: scheduled);
    ref.invalidate(activitiesProvider);
  }

  Future<void> deleteDraft(String id) async {
    await ref.read(deleteActivityDraftProvider).call(id);
    ref.invalidate(activitiesProvider);
  }

  Future<SchoolGroup> createGroup(String name, String grade) async {
    final g = await ref.read(createGroupProvider).call(name, grade);
    ref.invalidate(groupsProvider);
    return g;
  }

  Future<void> updateGroup(SchoolGroup g) async {
    await ref.read(updateGroupProvider).call(g);
    ref.invalidate(groupsProvider);
  }
}

final teacherActionsProvider = Provider<TeacherActions>(TeacherActions.new);
