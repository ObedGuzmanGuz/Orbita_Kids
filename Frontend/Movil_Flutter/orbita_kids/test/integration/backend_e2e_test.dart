// Prueba de punta a punta contra el backend real (`../backend`).
//
// Solo corre si se define ORBITA_API, con el backend en AUTH_MODE=dev y los
// datos de `npm run db:seed`:
//
//   ORBITA_API=http://localhost:3000/v1 flutter test test/integration
//
// Usa el código real de la app (sesión, casos de uso, cola, Dio): solo se
// sustituyen el almacenamiento y la conectividad por versiones en memoria.
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbita_kids/config/env/app_config.dart';
import 'package:orbita_kids/config/providers/core_providers.dart';
import 'package:orbita_kids/core/network/api_cache.dart';
import 'package:orbita_kids/core/network/api_client.dart';
import 'package:orbita_kids/core/network/connectivity.dart';
import 'package:orbita_kids/core/storage/local_store.dart';
import 'package:orbita_kids/core/storage/secure_store.dart';
import 'package:orbita_kids/core/sync/presentation/providers/sync_controller.dart';
import 'package:orbita_kids/features/auth/presentation/providers/auth_controller.dart';
import 'package:orbita_kids/features/student/domain/entities/student_progress.dart';
import 'package:orbita_kids/features/student/domain/usecases/mission_usecases.dart';
import 'package:orbita_kids/features/student/providers/student_providers.dart';
import 'package:orbita_kids/features/teacher/presentation/providers/teacher_state_providers.dart';
import 'package:orbita_kids/features/teacher/providers/teacher_providers.dart';
import 'package:orbita_kids/shared/domain/entities/content.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../helpers.dart';

final api = Platform.environment['ORBITA_API'];

/// Espera a que `ok()` se cumpla (la cola y el perfil trabajan en segundo plano).
Future<void> until(bool Function() ok, {String what = 'condición'}) async {
  for (var i = 0; i < 100; i++) {
    if (ok()) return;
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
  fail('No se cumplió: $what');
}

Future<ProviderContainer> appContainer() async {
  SharedPreferences.setMockInitialValues({});
  final sp = await SharedPreferences.getInstance();
  final cfg = AppConfig(
    keycloakIssuer: '',
    keycloakClientId: '',
    keycloakRedirectUri: AppConfig.demo.keycloakRedirectUri,
    keycloakPostLogoutRedirectUri: AppConfig.demo.keycloakPostLogoutRedirectUri,
    apiBaseUrl: api!,
    idpHintGoogle: 'google',
    idpHintFacebook: 'facebook',
    idpHintInstitution: '',
    roleStudent: 'student',
    roleTeacher: 'teacher',
    apiDevAuth: true,
  );
  final c = ProviderContainer(
    overrides: [
      appConfigProvider.overrideWithValue(cfg),
      sharedPrefsProvider.overrideWithValue(sp),
      localStoreProvider.overrideWithValue(MemoryLocalStore()),
      secureStoreProvider.overrideWithValue(MemorySecureStore()),
      connectivitySourceProvider.overrideWithValue(FakeConnectivity(true)),
      // Igual que productionOverrides().
      accessTokenGetterProvider.overrideWith(
        (ref) =>
            () async => ref.read(authControllerProvider).session?.accessToken,
      ),
      cacheOwnerProvider.overrideWith((ref) => () => ref.read(ownerIdProvider)),
    ],
  );
  addTearDown(c.dispose);
  c.read(onlineProvider);
  c.read(syncControllerProvider);
  await until(() => c.read(syncControllerProvider).loaded, what: 'cola cargada');
  return c;
}

void main() {
  setUpAll(() async {
    await initTestEnv();
    // flutter_test bloquea la red; esta prueba necesita la real.
    HttpOverrides.global = null;
  });

  test(
    'docente publica, estudiante resuelve y el docente ve el resultado',
    skip: api == null ? 'Define ORBITA_API para correr contra el backend' : false,
    () async {
      final c = await appContainer();
      final auth = c.read(authControllerProvider.notifier);
      final sync = c.read(syncControllerProvider.notifier);

      // ---- Docente: entra con la cuenta demo, ve sus grupos del servidor.
      await auth.signInWithPassword('ana.rios', 'orbita123');
      expect(c.read(currentUserProvider)!.id, 'dev-ana-rios');
      final groups = await c.read(getGroupsProvider).call();
      final g2a = groups.firstWhere((g) => g.code == 'ORB-2A7K');
      expect(g2a.id, hasLength(36), reason: 'ID del servidor, no el demo');

      final students = await c.read(getGroupStudentsProvider).call(g2a.id);
      expect(students.map((s) => s.id), contains('dev-luna-astro'));

      // ---- Publica una actividad: pasa por la cola hasta el servidor.
      final id = const Uuid().v4();
      final today = DateTime.now();
      final activity = Activity(
        id: id,
        name: 'Prueba E2E ${today.millisecondsSinceEpoch}',
        groupId: g2a.id,
        type: MissionType.choice,
        level: 2,
        count: 3,
        assigned: DateTime(today.year, today.month, today.day),
        due: DateTime(today.year, today.month, today.day + 7),
        status: ActivityStatus.draft,
        done: 0,
        instructions: 'Creada por backend_e2e_test',
      );
      await c.read(teacherActionsProvider).publish(activity, scheduled: false);
      await sync.syncNow(force: true);
      await until(
        () => c.read(syncControllerProvider).confirmed.any((r) => r.id == id),
        what: 'actividad confirmada por el servidor',
      );

      // ---- Estudiante: su grupo viene de /me y ve la tarea del servidor.
      await auth.signOut();
      await auth.signInWithPassword('luna.astro', 'orbita123');
      await until(
        () => c.read(currentUserProvider)?.groupId == g2a.id,
        what: 'grupo del estudiante desde /me',
      );
      final tasks = await c.read(getStudentTasksProvider).call(g2a.id);
      final task = tasks.firstWhere((t) => t.id == id);

      // Resuelve la tarea: falla el primero y lo corrige → 2 de 3 al primer intento.
      final run = const StartAssignedTask().call(task);
      for (var i = 0; !run.finished; i++) {
        if (i == 0) run.answer(run.current.answer + 1, const Uuid().v4());
        run.answer(run.current.answer, const Uuid().v4());
        run.next();
      }
      final (_, outcome) = await c
          .read(finishMissionProvider)
          .call(
            const StudentProgress(),
            run,
            owner: c.read(ownerIdProvider),
            now: DateTime.now(),
          );
      await sync.syncNow(force: true);
      await until(
        () => c
            .read(syncControllerProvider)
            .confirmed
            .any((r) => r.id == outcome.queued),
        what: 'intento confirmado por el servidor',
      );

      // ---- El servidor lo tiene: la actividad ya cuenta 1 estudiante.
      final dio = Dio(
        BaseOptions(
          baseUrl: api!,
          headers: {'Authorization': 'Bearer dev:dev-ana-rios'},
        ),
      );
      final res = await dio.get<Map<String, dynamic>>('/activities/$id');
      expect(res.data!['done'], 1);
      final luna = await dio.get<Map<String, dynamic>>('/students/dev-luna-astro');
      final recent = (luna.data!['recent'] as List).first as Map;
      expect(recent['id'], outcome.queued);
      expect(recent['title'], activity.name);
      expect(recent['firstTry'], 2);
      expect(recent['total'], 3);
    },
  );
}
