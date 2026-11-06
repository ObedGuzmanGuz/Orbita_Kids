import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:orbita_kids/core/network/connectivity.dart';
import 'package:orbita_kids/config/providers/core_providers.dart';
import 'package:orbita_kids/core/sync/providers/sync_providers.dart';
import 'package:orbita_kids/core/sync/domain/sync_gateway.dart';
import 'package:orbita_kids/core/sync/domain/sync_models.dart';
import 'package:orbita_kids/core/sync/domain/sync_queue_store.dart';
import 'package:orbita_kids/core/sync/domain/sync_rules.dart';

@immutable
class SyncState {
  const SyncState({
    this.items = const [],
    this.confirmed = const [],
    this.running = false,
    this.lastSync,
    this.lastRunNoBackend = false,
    this.loaded = false,
  });

  /// Cola: solo registros NO confirmados.
  final List<SyncItem> items;

  /// Historial de confirmados por el servidor.
  final List<SyncedRecord> confirmed;
  final bool running;
  final DateTime? lastSync;

  /// La última ejecución no encontró servidor (modo demo o sin endpoint).
  final bool lastRunNoBackend;
  final bool loaded;

  List<SyncItem> of(String owner) =>
      items.where((i) => i.owner == owner).toList();

  SyncState copyWith({
    List<SyncItem>? items,
    List<SyncedRecord>? confirmed,
    bool? running,
    DateTime? lastSync,
    bool? lastRunNoBackend,
    bool? loaded,
  }) => SyncState(
    items: items ?? this.items,
    confirmed: confirmed ?? this.confirmed,
    running: running ?? this.running,
    lastSync: lastSync ?? this.lastSync,
    lastRunNoBackend: lastRunNoBackend ?? this.lastRunNoBackend,
    loaded: loaded ?? this.loaded,
  );
}

/// Estado observable de la cola offline first.
///
/// La lógica (qué enviar, reintentos, conflictos) vive en [SyncRules] del
/// dominio; aquí solo se coordina con la conectividad, el almacén y la
/// pasarela, y se publica el estado para la UI.
class SyncController extends Notifier<SyncState> {
  Timer? _retryTimer;
  Future<void>? _inflight;
  final _uuid = const Uuid();

  SyncQueueStore get _store => ref.read(syncQueueStoreProvider);
  SyncGateway get _gateway => ref.read(syncGatewayProvider);
  DateTime _now() => ref.read(clockProvider)();

  @override
  SyncState build() {
    ref.onDispose(() => _retryTimer?.cancel());
    ref.listen<bool>(onlineProvider, (prev, now) {
      if (now && prev == false) syncNow();
    });
    _load();
    return const SyncState();
  }

  Future<void> _load() async {
    final pending = await _store.pending();
    final done = await _store.confirmed();
    if (!ref.mounted) return;
    // Lo encolado mientras se cargaba gana sobre lo leído del disco.
    final byId = {for (final i in pending) i.id: i};
    for (final i in state.items) {
      byId[i.id] = i;
    }
    final known = state.confirmed.map((r) => r.id).toSet();
    state = state.copyWith(
      items: byId.values.toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt)),
      confirmed: [
        ...state.confirmed,
        ...done.where((r) => !known.contains(r.id)),
      ]..sort((a, b) => b.at.compareTo(a.at)),
      loaded: true,
    );
  }

  /// Agrega un registro a la cola y, si hay red, intenta enviarlo.
  Future<SyncItem> enqueue({
    required SyncKind kind,
    required String owner,
    required String title,
    required String detail,
    Map<String, dynamic> payload = const {},
    String? id,
    String? baseVersion,
  }) async {
    final item = SyncItem(
      id: id ?? _uuid.v4(),
      kind: kind,
      owner: owner,
      title: title,
      detail: detail,
      createdAt: _now(),
      payload: payload,
      baseVersion: baseVersion,
    );
    await _store.save(item);
    if (!ref.mounted) return item;
    state = state.copyWith(
      items: [...state.items.where((i) => i.id != item.id), item],
    );
    if (ref.read(onlineProvider)) unawaited(syncNow());
    return item;
  }

  /// Retira un registro sin enviarlo (borrador descartado o conflicto que la
  /// persona decidió resolver con la versión del servidor).
  Future<void> discard(String id) async {
    await _store.remove(id);
    if (!ref.mounted) return;
    state = state.copyWith(
      items: state.items.where((i) => i.id != id).toList(),
    );
  }

  /// Resolver conflicto conservando la versión local: se reenvía como nueva
  /// edición sobre la versión del servidor (nunca a ciegas).
  Future<void> keepMine(String id) async {
    final it = state.items.firstWhere((i) => i.id == id);
    await _save(
      it.copyWith(
        status: SyncStatus.pending,
        clearError: true,
        clearRetry: true,
        baseVersion: 'server-latest',
      ),
    );
    unawaited(syncNow(force: true));
  }

  Future<void> _save(SyncItem it) async {
    await _store.save(it);
    if (!ref.mounted) return;
    state = state.copyWith(
      items: [for (final i in state.items) i.id == it.id ? it : i],
    );
  }

  /// Envía lo pendiente. Con `force` ignora la espera de reintento.
  /// Si ya hay un envío en curso, devuelve ese mismo envío.
  Future<void> syncNow({bool force = false, String? owner}) {
    final running = _inflight;
    if (running != null) return running;
    if (!ref.read(onlineProvider)) return Future.value();
    final f = _run(force, owner);
    _inflight = f;
    return f.whenComplete(() => _inflight = null);
  }

  Future<void> _run(bool force, String? owner) async {
    final now = _now();
    final batch = state.items
        .where((i) => SyncRules.isDue(i, now, force: force, owner: owner))
        .toList();
    if (batch.isEmpty) return;

    state = state.copyWith(running: true, lastRunNoBackend: false);
    for (final it in batch) {
      await _save(it.copyWith(status: SyncStatus.syncing));
      if (!ref.mounted) return;
    }

    var noBackend = false;
    var anyConfirmed = false;
    for (final it in batch) {
      final current = state.items.where((i) => i.id == it.id).firstOrNull;
      if (current == null) continue;
      SyncOutcome out;
      try {
        out = await _gateway.send(current);
      } catch (e) {
        out = SyncRetry('$e');
      }
      if (!ref.mounted) return;
      if (out is SyncNotConfigured) noBackend = true;
      final next = SyncRules.afterOutcome(current, out, _now());
      if (next == null) {
        anyConfirmed = true;
        final rec = SyncedRecord(
          id: current.id,
          title: current.title,
          kind: current.kind,
          owner: current.owner,
          at: _now(),
        );
        await _store.confirm(rec);
        if (!ref.mounted) return;
        state = state.copyWith(
          items: state.items.where((i) => i.id != current.id).toList(),
          confirmed: [rec, ...state.confirmed].take(100).toList(),
        );
      } else {
        await _save(next);
      }
    }
    if (!ref.mounted) return;
    state = state.copyWith(
      running: false,
      lastRunNoBackend: noBackend,
      lastSync: anyConfirmed ? _now() : state.lastSync,
    );
    _scheduleRetry();
  }

  void _scheduleRetry() {
    _retryTimer?.cancel();
    final next = SyncRules.nextRetry(state.items);
    if (next == null) return;
    final wait = next.difference(_now());
    _retryTimer = Timer(wait.isNegative ? Duration.zero : wait, syncNow);
  }
}

final syncControllerProvider = NotifierProvider<SyncController, SyncState>(
  SyncController.new,
);
