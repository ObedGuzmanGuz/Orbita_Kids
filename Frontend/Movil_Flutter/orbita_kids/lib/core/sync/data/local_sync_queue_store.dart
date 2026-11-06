import 'package:orbita_kids/core/storage/local_store.dart';
import 'package:orbita_kids/core/sync/domain/sync_models.dart';
import 'package:orbita_kids/core/sync/domain/sync_queue_store.dart';

/// Cola guardada en SQLite (colecciones `sync_queue` y `sync_done`).
class LocalSyncQueueStore implements SyncQueueStore {
  const LocalSyncQueueStore(this._store);
  final LocalStore _store;

  static const queueCol = 'sync_queue';
  static const doneCol = 'sync_done';

  @override
  Future<List<SyncItem>> pending() async =>
      (await _store.all(queueCol)).map(SyncItem.fromJson).toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

  @override
  Future<List<SyncedRecord>> confirmed() async =>
      (await _store.all(doneCol)).map(SyncedRecord.fromJson).toList()
        ..sort((a, b) => b.at.compareTo(a.at));

  @override
  Future<void> save(SyncItem item) =>
      _store.put(queueCol, item.id, item.toJson());

  @override
  Future<void> remove(String id) => _store.delete(queueCol, id);

  @override
  Future<void> confirm(SyncedRecord record) async {
    await _store.put(doneCol, record.id, record.toJson());
    await _store.delete(queueCol, record.id);
  }
}
