import 'package:orbita_kids/core/sync/domain/sync_models.dart';
import 'package:orbita_kids/core/sync/domain/sync_queue.dart';
import 'package:orbita_kids/shared/domain/entities/content.dart';
import 'package:orbita_kids/shared/domain/repositories/activities_repository.dart';

/// Actividades ordenadas por fecha, marcando las que siguen en la cola.
class GetActivities {
  const GetActivities(this._repo);
  final ActivitiesRepository _repo;

  Future<List<Activity>> call({Set<String> queuedIds = const {}}) async {
    final list = await _repo.list();
    return [
      for (final a in list) a.copyWith(pendingSync: queuedIds.contains(a.id)),
    ]..sort((a, b) => b.assigned.compareTo(a.assigned));
  }
}

/// Valida una actividad antes de guardarla o publicarla.
class ValidateActivity {
  const ValidateActivity();

  /// Mapa campo → mensaje; vacío si es válida.
  Map<String, String> call(Activity a, {required bool publishing}) => {
    if (a.name.trim().isEmpty) 'name': 'Escribe un nombre para la actividad.',
    if (publishing && a.groupId.isEmpty) 'group': 'Elige el grupo.',
    if (a.due.isBefore(a.assigned))
      'date': 'La entrega debe ser después del inicio.',
  };
}

/// Guarda en el teléfono como borrador. Funciona sin Internet.
class SaveActivityDraft {
  const SaveActivityDraft(this._repo);
  final ActivitiesRepository _repo;

  Future<void> call(Activity a) =>
      _repo.saveLocal(a.copyWith(status: ActivityStatus.draft));
}

/// Publica o programa: guarda local y deja el envío en la cola. Queda
/// «pendiente de envío» hasta que el backend confirme; nunca antes.
class PublishActivity {
  const PublishActivity(this._repo, this._queue);
  final ActivitiesRepository _repo;
  final SyncQueue _queue;

  Future<void> call(
    Activity a, {
    required String owner,
    required bool scheduled,
  }) async {
    final status = scheduled ? ActivityStatus.scheduled : ActivityStatus.active;
    final pub = a.copyWith(status: status, pendingSync: true);
    await _repo.saveLocal(pub);
    await _queue.discard(a.id);
    await _queue.enqueue(
      kind: SyncKind.activityDraft,
      id: a.id,
      owner: owner,
      title: a.name,
      detail: '${status.label} · ${a.count} ejercicios · nivel ${a.level}',
      payload: pub.toJson(),
    );
  }
}

class DeleteActivityDraft {
  const DeleteActivityDraft(this._repo);
  final ActivitiesRepository _repo;

  Future<void> call(String id) => _repo.deleteLocal(id);
}
