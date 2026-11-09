import 'package:orbita_kids/core/sync/domain/sync_models.dart';

/// Persistencia local de la cola (registros pendientes y confirmados).
abstract interface class SyncQueueStore {
  Future<List<SyncItem>> pending();
  Future<List<SyncedRecord>> confirmed();
  Future<void> save(SyncItem item);
  Future<void> remove(String id);

  /// Guarda la confirmación del servidor y retira el registro de la cola.
  Future<void> confirm(SyncedRecord record);
}
