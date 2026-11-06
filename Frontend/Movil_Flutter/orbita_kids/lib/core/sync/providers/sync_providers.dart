import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:orbita_kids/core/network/api_client.dart';
import 'package:orbita_kids/config/providers/core_providers.dart';
import 'package:orbita_kids/core/sync/data/local_sync_queue_store.dart';
import 'package:orbita_kids/core/sync/data/sync_gateways.dart';
import 'package:orbita_kids/core/sync/domain/sync_gateway.dart';
import 'package:orbita_kids/core/sync/domain/sync_models.dart';
import 'package:orbita_kids/core/sync/domain/sync_queue.dart';
import 'package:orbita_kids/core/sync/domain/sync_queue_store.dart';
import 'package:orbita_kids/core/sync/presentation/providers/sync_controller.dart';

/// Composición de la cola: aquí se eligen las implementaciones de datos.
final syncGatewayProvider = Provider<SyncGateway>((ref) {
  final dio = ref.watch(dioProvider);
  return dio == null ? const NoBackendGateway() : HttpSyncGateway(dio);
});

final syncQueueStoreProvider = Provider<SyncQueueStore>(
  (ref) => LocalSyncQueueStore(ref.watch(localStoreProvider)),
);

/// Puerto `SyncQueue` para los casos de uso de otras features.
final syncQueueProvider = Provider<SyncQueue>(_ControllerQueue.new);

class _ControllerQueue implements SyncQueue {
  _ControllerQueue(this._ref);
  final Ref _ref;

  @override
  Future<SyncItem> enqueue({
    required SyncKind kind,
    required String owner,
    required String title,
    required String detail,
    Map<String, dynamic> payload = const {},
    String? id,
    String? baseVersion,
  }) => _ref
      .read(syncControllerProvider.notifier)
      .enqueue(
        kind: kind,
        owner: owner,
        title: title,
        detail: detail,
        payload: payload,
        id: id,
        baseVersion: baseVersion,
      );

  @override
  Future<void> discard(String id) =>
      _ref.read(syncControllerProvider.notifier).discard(id);
}
