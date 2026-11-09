import 'package:orbita_kids/core/sync/domain/sync_models.dart';

/// Puerto que usan los casos de uso de otras features para dejar registros
/// en la cola sin conocer cómo se envían.
abstract interface class SyncQueue {
  Future<SyncItem> enqueue({
    required SyncKind kind,
    required String owner,
    required String title,
    required String detail,
    Map<String, dynamic> payload,
    String? id,
    String? baseVersion,
  });

  Future<void> discard(String id);
}
