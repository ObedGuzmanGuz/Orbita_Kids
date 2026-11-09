import 'package:flutter_test/flutter_test.dart';
import 'package:orbita_kids/core/network/connectivity.dart';
import 'package:orbita_kids/core/sync/data/local_sync_queue_store.dart';
import 'package:orbita_kids/core/sync/domain/sync_rules.dart';
import 'package:orbita_kids/core/sync/domain/sync_gateway.dart';
import 'package:orbita_kids/core/sync/domain/sync_models.dart';
import 'package:orbita_kids/core/sync/presentation/providers/sync_controller.dart';

import '../helpers.dart';

/// Puerta de envío controlable.
class ScriptedGateway implements SyncGateway {
  ScriptedGateway(this.next);
  SyncOutcome Function(SyncItem) next;
  final sent = <String>[];

  @override
  bool supports(SyncKind kind) => true;

  @override
  Future<SyncOutcome> send(SyncItem item) async {
    sent.add(item.id);
    return next(item);
  }
}

Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  setUpAll(initTestEnv);

  test('sin servidor: el registro queda pendiente, nunca enviado', () async {
    final deps = TestDeps();
    final c = await deps.container();
    final svc = c.read(syncControllerProvider.notifier);
    c.read(syncControllerProvider);
    await _settle();
    await svc.enqueue(
      kind: SyncKind.attempt,
      owner: 'u1',
      title: 'Misión',
      detail: '5/5',
    );
    await svc.syncNow(force: true);
    final st = c.read(syncControllerProvider);
    expect(st.items.single.status, SyncStatus.pending);
    expect(st.confirmed, isEmpty);
    expect(st.lastRunNoBackend, isTrue);
    expect((await deps.store.all(LocalSyncQueueStore.queueCol)).length, 1);
  });

  test(
    'confirmado por el servidor: sale de la cola y queda en el historial',
    () async {
      final gw = ScriptedGateway((_) => const SyncConfirmed());
      final deps = TestDeps(gateway: gw);
      final c = await deps.container();
      c.read(syncControllerProvider);
      await _settle();
      final it = await c
          .read(syncControllerProvider.notifier)
          .enqueue(
            kind: SyncKind.attempt,
            owner: 'u1',
            title: 'Misión',
            detail: '',
          );
      await c.read(syncControllerProvider.notifier).syncNow(force: true);
      final st = c.read(syncControllerProvider);
      expect(st.items, isEmpty);
      expect(st.confirmed.single.id, it.id);
      expect(st.lastSync, isNotNull);
      expect(await deps.store.all(LocalSyncQueueStore.queueCol), isEmpty);
    },
  );

  test(
    'error temporal: se reintenta con espera creciente sin perder el registro',
    () async {
      final gw = ScriptedGateway((_) => const SyncRetry('HTTP 503'));
      final deps = TestDeps(gateway: gw);
      final c = await deps.container();
      c.read(syncControllerProvider);
      await _settle();
      final svc = c.read(syncControllerProvider.notifier);
      await svc.enqueue(
        kind: SyncKind.attempt,
        owner: 'u1',
        title: 'Misión',
        detail: '',
      );
      await svc.syncNow(force: true);
      var item = c.read(syncControllerProvider).items.single;
      expect(item.status, SyncStatus.error);
      expect(item.attempts, greaterThanOrEqualTo(1));
      expect(item.nextRetryAt, isNotNull);

      // Sin forzar, respeta la espera.
      final before = gw.sent.length;
      await svc.syncNow();
      expect(gw.sent.length, before);

      // El servidor vuelve: se confirma.
      gw.next = (_) => const SyncConfirmed();
      await svc.syncNow(force: true);
      expect(c.read(syncControllerProvider).items, isEmpty);
      item = item;
    },
  );

  test('espera exponencial con tope', () {
    expect(SyncRules.backoffFor(1), const Duration(seconds: 15));
    expect(SyncRules.backoffFor(2), const Duration(seconds: 30));
    expect(SyncRules.backoffFor(3), const Duration(seconds: 60));
    expect(SyncRules.backoffFor(20), SyncRules.maxBackoff);
  });

  test('conflicto: no se sobrescribe y espera decisión', () async {
    final gw = ScriptedGateway((_) => const SyncConflict('versión más nueva'));
    final deps = TestDeps(gateway: gw);
    final c = await deps.container();
    c.read(syncControllerProvider);
    await _settle();
    final svc = c.read(syncControllerProvider.notifier);
    final it = await svc.enqueue(
      kind: SyncKind.activityDraft,
      owner: 't1',
      title: 'Actividad',
      detail: '',
    );
    await svc.syncNow(force: true);
    expect(
      c.read(syncControllerProvider).items.single.status,
      SyncStatus.conflict,
    );

    final sentBefore = gw.sent.length;
    await svc.syncNow(force: true);
    expect(
      gw.sent.length,
      sentBefore,
      reason: 'los conflictos no se reenvían solos',
    );

    gw.next = (_) => const SyncConfirmed();
    await svc.keepMine(it.id);
    await _settle();
    await svc.syncNow(force: true);
    expect(c.read(syncControllerProvider).items, isEmpty);
  });

  test('sin conexión no intenta enviar', () async {
    final gw = ScriptedGateway((_) => const SyncConfirmed());
    final deps = TestDeps(online: false, gateway: gw);
    final c = await deps.container();
    c.read(syncControllerProvider);
    c.read(onlineProvider);
    await _settle();
    await c
        .read(syncControllerProvider.notifier)
        .enqueue(kind: SyncKind.attempt, owner: 'u1', title: 'M', detail: '');
    await c.read(syncControllerProvider.notifier).syncNow(force: true);
    expect(gw.sent, isEmpty);
    expect(c.read(syncControllerProvider).items.length, 1);
  });

  test('un envío interrumpido se recupera como pendiente', () {
    final it = SyncItem(
      id: 'x',
      kind: SyncKind.attempt,
      owner: 'u1',
      title: 't',
      detail: 'd',
      createdAt: fixedNow,
      payload: const {},
      status: SyncStatus.syncing,
    );
    expect(SyncItem.fromJson(it.toJson()).status, SyncStatus.pending);
  });

  test('la cola se filtra por persona', () async {
    final deps = TestDeps();
    final c = await deps.container();
    c.read(syncControllerProvider);
    await _settle();
    final svc = c.read(syncControllerProvider.notifier);
    await svc.enqueue(
      kind: SyncKind.attempt,
      owner: 'a',
      title: 'A',
      detail: '',
    );
    await svc.enqueue(
      kind: SyncKind.attempt,
      owner: 'b',
      title: 'B',
      detail: '',
    );
    expect(c.read(syncControllerProvider).of('a').single.title, 'A');
  });
}
