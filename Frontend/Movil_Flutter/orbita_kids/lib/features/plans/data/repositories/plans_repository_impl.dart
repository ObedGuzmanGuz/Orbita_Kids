import 'package:orbita_kids/core/sync/domain/sync_models.dart';
import 'package:orbita_kids/core/sync/domain/sync_queue.dart';
import 'package:orbita_kids/features/plans/domain/repositories/plans_repository.dart';
import 'package:orbita_kids/shared/domain/content/catalog.dart';
import 'package:orbita_kids/shared/domain/entities/content.dart';

/// Planes del catálogo; las solicitudes viajan por la cola de sincronización.
class QueuedPlansRepository implements PlansRepository {
  const QueuedPlansRepository(this._queue);
  final SyncQueue _queue;

  @override
  List<Plan> plans() => Catalog.plans;

  @override
  Future<void> requestInfo(PlanInfoRequest r) async {
    await _queue.enqueue(
      kind: SyncKind.planRequest,
      owner: r.owner,
      title: 'Información del plan ${r.plan.name}',
      detail: '${r.institution} · ${r.students} estudiantes aprox.',
      payload: {
        'plan': r.plan.id,
        'period': r.yearly ? 'anual' : 'mensual',
        'institution': r.institution,
        'contact': r.contact,
        'students': r.students,
        'message': r.message,
      },
    );
  }
}
