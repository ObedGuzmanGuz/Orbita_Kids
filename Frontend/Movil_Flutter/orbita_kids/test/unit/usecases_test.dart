import 'package:flutter_test/flutter_test.dart';
import 'package:orbita_kids/core/sync/domain/sync_models.dart';
import 'package:orbita_kids/core/sync/domain/sync_queue.dart';
import 'package:orbita_kids/core/sync/domain/sync_rules.dart';
import 'package:orbita_kids/features/auth/domain/entities/auth_entities.dart';
import 'package:orbita_kids/features/auth/domain/repositories/auth_repositories.dart';
import 'package:orbita_kids/features/auth/domain/usecases/auth_usecases.dart';
import 'package:orbita_kids/features/student/domain/entities/student_progress.dart';
import 'package:orbita_kids/features/student/domain/repositories/student_repositories.dart';
import 'package:orbita_kids/features/student/domain/services/mission_engine.dart';
import 'package:orbita_kids/features/student/domain/usecases/mission_usecases.dart';
import 'package:orbita_kids/features/student/domain/usecases/progress_usecases.dart';
import 'package:orbita_kids/features/teacher/domain/usecases/activities_usecases.dart';
import 'package:orbita_kids/shared/domain/content/catalog.dart';
import 'package:orbita_kids/shared/domain/entities/content.dart';
import 'package:orbita_kids/shared/domain/repositories/activities_repository.dart';

// ---------------- Dobles en memoria de los contratos del dominio ----------------

class FakeQueue implements SyncQueue {
  final items = <SyncItem>[];
  final discarded = <String>[];

  @override
  Future<SyncItem> enqueue({
    required SyncKind kind,
    required String owner,
    required String title,
    required String detail,
    Map<String, dynamic> payload = const {},
    String? id,
    String? baseVersion,
  }) async {
    final it = SyncItem(
      id: id ?? 'id-${items.length}',
      kind: kind,
      owner: owner,
      title: title,
      detail: detail,
      createdAt: DateTime(2026, 10, 29),
      payload: payload,
    );
    items.add(it);
    return it;
  }

  @override
  Future<void> discard(String id) async => discarded.add(id);
}

class MemProgress implements ProgressRepository {
  final saved = <String, StudentProgress>{};

  @override
  Future<StudentProgress?> load(String owner) async => saved[owner];

  @override
  Future<void> save(String owner, StudentProgress p) async => saved[owner] = p;

  @override
  StudentProgress initialFor(String name, DateTime today) =>
      StudentProgress(name: name);
}

class CatalogMissions implements MissionsRepository {
  @override
  List<Planet> planets() => Catalog.planets;
  @override
  List<Mission> missionsOf(String planetId) => Catalog.missionsOf(planetId);
  @override
  Mission mission(String id) => Catalog.mission(id);
}

class MemActivities implements ActivitiesRepository {
  final map = <String, Activity>{};
  @override
  bool get available => true;
  @override
  Future<List<Activity>> list() async => map.values.toList();
  @override
  Future<void> saveLocal(Activity a) async => map[a.id] = a;
  @override
  Future<void> deleteLocal(String id) async => map.remove(id);
}

class FakeAuth implements AuthRepository {
  @override
  bool get isDemo => true;
  @override
  Future<Session?> signInWithPassword(String u, String p) async => p == 'ok'
      ? Session(
          user: const AppUser(
            id: 'u',
            name: 'Luna',
            role: UserRole.student,
            method: AuthMethod.orbita,
            methodLabel: '',
          ),
          expiresAt: DateTime(2100),
          demo: true,
        )
      : null;
  @override
  Future<Session> signIn(
    AuthMethod m, {
    String? loginHint,
    bool register = false,
  }) => throw UnimplementedError();
  @override
  Future<Session> signInDemoAccount(String id) => throw UnimplementedError();
  @override
  Future<Session> refresh(Session s) async => s;
  @override
  Future<void> remoteSignOut(String? idToken) async {}
  @override
  Future<bool> unlock(String code) async => code == '000000';
}

class MemSessions implements SessionRepository {
  Session? session;
  LoginLock lock = LoginLock.none;
  String? pending;
  @override
  Future<Session?> read() async => session;
  @override
  Future<void> save(Session s) async => session = s;
  @override
  Future<void> clear() async => session = null;
  @override
  Future<LoginLock> readLock() async => lock;
  @override
  Future<void> saveLock(LoginLock l) async => lock = l;
  @override
  Future<void> clearLock() async => lock = LoginLock.none;
  @override
  Future<String?> pendingLogout() async => pending;
  @override
  Future<void> savePendingLogout(String t) async => pending = t;
  @override
  Future<void> clearPendingLogout() async => pending = null;
}

void main() {
  final now = DateTime(2026, 10, 29, 10);

  group('FinishMission', () {
    MissionRun perfectRun(String id) {
      final m = Catalog.mission(id);
      final run = MissionRun(
        missionId: id,
        name: m.name,
        level: 1,
        type: MissionType.visual,
        planetId: m.planetId,
        items: const [
          SumItem(
            a: 1,
            b: 1,
            kind: MissionType.visual,
            options: [2, 3, 4, 5],
            object: 'star',
          ),
        ],
      );
      run.answer(2, 'a');
      run.next();
      return run;
    }

    test(
      'guarda progreso, gana la pieza del planeta y encola el intento',
      () async {
        final queue = FakeQueue(), progress = MemProgress();
        final finish = FinishMission(CatalogMissions(), progress, queue);
        const before = StudentProgress(name: 'Luna', done: {'m1': 3, 'm2': 3});
        final (next, out) = await finish(
          before,
          perfectRun('m3'),
          owner: 'u-luna',
          now: now,
        );

        expect(out.stars, 3);
        expect(out.piece, 'luces', reason: 'completó el Planeta Verde');
        expect(next.pieces, contains('luces'));
        expect(next.badges, contains('b2'));
        expect(progress.saved['u-luna'], same(next));
        expect(queue.items.single.kind, SyncKind.attempt);
        expect(out.queued, queue.items.single.id);
      },
    );

    test('en modo explorar no guarda ni envía nada', () async {
      final queue = FakeQueue(), progress = MemProgress();
      final finish = FinishMission(CatalogMissions(), progress, queue);
      final (_, out) = await finish(
        StudentProgress.guest,
        perfectRun('m1'),
        owner: null,
        now: now,
      );
      expect(out.guest, isTrue);
      expect(queue.items, isEmpty);
      expect(progress.saved, isEmpty);
    });

    test('carga el progreso inicial y reinicia los minutos del día', () async {
      final repo = MemProgress()
        ..saved['u'] = StudentProgress(
          name: 'Luna',
          minutesToday: 25,
          minutesDate: DateTime(2026, 10, 28),
        );
      final p = await LoadStudentProgress(repo)
          .call(owner: 'u', name: 'Luna', now: now);
      expect(p.minutesToday, 0);
    });
  });

  group('PublishActivity', () {
    test('queda pendiente de envío y nunca confirmada', () async {
      final repo = MemActivities(), queue = FakeQueue();
      final a = Activity(
        id: 'x',
        name: 'Sumas',
        groupId: 'g2a',
        type: MissionType.visual,
        level: 2,
        count: 8,
        assigned: now,
        due: now.add(const Duration(days: 3)),
        status: ActivityStatus.draft,
        done: 0,
        instructions: '',
      );
      await PublishActivity(
        repo,
        queue,
      ).call(a, owner: 'u-ana', scheduled: false);
      expect(repo.map['x']!.status, ActivityStatus.active);
      expect(repo.map['x']!.pendingSync, isTrue);
      expect(queue.items.single.id, 'x');
      expect(queue.discarded, [
        'x',
      ], reason: 'reemplaza un envío anterior del mismo borrador');
    });

    test('valida nombre, grupo y fechas', () {
      final a = Activity(
        id: 'x',
        name: ' ',
        groupId: '',
        type: MissionType.choice,
        level: 1,
        count: 5,
        assigned: now,
        due: now.subtract(const Duration(days: 1)),
        status: ActivityStatus.draft,
        done: 0,
        instructions: '',
      );
      expect(
        const ValidateActivity().call(a, publishing: true).keys,
        containsAll(['name', 'group', 'date']),
      );
      expect(
        const ValidateActivity().call(a, publishing: false).keys,
        isNot(contains('group')),
      );
    });
  });

  group('Autenticación', () {
    test('3 contraseñas incorrectas pausan la cuenta', () async {
      final sessions = MemSessions();
      final signIn = SignInWithPassword(FakeAuth(), sessions);
      var lock = LoginLock.none;
      for (var i = 1; i <= 2; i++) {
        try {
          await signIn('luna', 'mal', lock: lock, now: now);
        } on InvalidCredentials catch (e) {
          lock = e.lock;
          expect(e.remaining, 3 - i);
        }
      }
      await expectLater(
        signIn('luna', 'mal', lock: lock, now: now),
        throwsA(isA<AccountLocked>()),
      );
      expect(sessions.lock.isLocked(now), isTrue);
      expect(
        sessions.lock.isLocked(now.add(LoginAttemptPolicy.lockDuration)),
        isFalse,
      );
    });

    test('desbloquear limpia los intentos', () async {
      final sessions = MemSessions()
        ..lock = LoginLock(
          fails: 3,
          until: now.add(const Duration(minutes: 5)),
        );
      expect(await UnlockAccount(FakeAuth(), sessions).call('111111'), isFalse);
      expect(await UnlockAccount(FakeAuth(), sessions).call('000000'), isTrue);
      expect(sessions.lock.fails, 0);
    });

    test('sin conexión el cierre remoto queda pendiente', () async {
      final sessions = MemSessions();
      final s = Session(
        user: const AppUser(
          id: 'u',
          name: 'Ana',
          role: UserRole.teacher,
          method: AuthMethod.google,
          methodLabel: '',
        ),
        idToken: 'tok',
        expiresAt: DateTime(2100),
      );
      expect(
        await SignOut(FakeAuth(), sessions).call(s, online: false),
        isTrue,
      );
      expect(sessions.pending, 'tok');
      expect(await CompletePendingLogout(FakeAuth(), sessions).call(), isTrue);
      expect(sessions.pending, isNull);
    });
  });

  group('SyncRules', () {
    final item = SyncItem(
      id: 'a',
      kind: SyncKind.attempt,
      owner: 'u',
      title: 't',
      detail: 'd',
      createdAt: DateTime(2026),
      payload: const {},
    );

    test('un error programa reintento y un conflicto no se reenvía solo', () {
      final err = SyncRules.afterOutcome(item, const SyncRetry('503'), now)!;
      expect(err.status, SyncStatus.error);
      expect(err.nextRetryAt, now.add(const Duration(seconds: 15)));
      expect(SyncRules.isDue(err, now), isFalse);
      expect(SyncRules.isDue(err, now, force: true), isTrue);

      final conflict = SyncRules.afterOutcome(
        item,
        const SyncConflict('nuevo'),
        now,
      )!;
      expect(SyncRules.isDue(conflict, now, force: true), isFalse);
    });

    test('solo la confirmación del servidor retira el registro', () {
      expect(SyncRules.afterOutcome(item, const SyncConfirmed(), now), isNull);
      expect(
        SyncRules.afterOutcome(item, const SyncNotConfigured(), now)!.status,
        SyncStatus.pending,
      );
    });
  });
}
