import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:orbita_kids/config/providers/core_providers.dart';
import 'package:orbita_kids/core/network/api_cache.dart';
import 'package:orbita_kids/core/network/api_client.dart';
import 'package:orbita_kids/core/sync/providers/sync_providers.dart';
import 'package:orbita_kids/features/teacher/data/repositories/server_teacher_repositories.dart';
import 'package:orbita_kids/features/teacher/data/repositories/teacher_repositories_impl.dart';
import 'package:orbita_kids/features/teacher/domain/repositories/groups_repository.dart';
import 'package:orbita_kids/features/teacher/domain/repositories/users_repository.dart';
import 'package:orbita_kids/features/teacher/domain/usecases/activities_usecases.dart';
import 'package:orbita_kids/features/teacher/domain/usecases/groups_usecases.dart';
import 'package:orbita_kids/shared/providers/shared_providers.dart';

// ---------- Repositorios (servidor, demo o «pendiente de backend») ----------

final groupsRepositoryProvider = Provider<GroupsRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final cache = ref.watch(apiCacheProvider);
  if (dio != null && cache != null) return HttpGroupsRepository(dio, cache);
  return ref.watch(appConfigProvider).isDemo
      ? DemoGroupsRepository(ref.watch(localStoreProvider))
      : const PendingGroupsRepository();
});

final usersRepositoryProvider = Provider<UsersRepository>((ref) {
  final cache = ref.watch(apiCacheProvider);
  if (cache != null) return HttpUsersRepository(cache);
  return ref.watch(appConfigProvider).isDemo
      ? const DemoUsersRepository()
      : const PendingUsersRepository();
});

/// `false` si los datos del docente esperan un backend que aún no existe.
final teacherDataAvailableProvider = Provider<bool>(
  (ref) => ref.watch(usersRepositoryProvider).available,
);

/// Etiquetas de semanas para los gráficos de evolución.
final trendLabelsProvider = Provider<List<String>>(
  (ref) => ref.watch(usersRepositoryProvider).trendLabels(),
);

// ---------- Casos de uso ----------

final getGroupsProvider = Provider(
  (ref) => GetGroups(ref.watch(groupsRepositoryProvider)),
);
final createGroupProvider = Provider(
  (ref) => CreateGroup(ref.watch(groupsRepositoryProvider)),
);
final updateGroupProvider = Provider(
  (ref) => UpdateGroup(ref.watch(groupsRepositoryProvider)),
);
final getGroupStudentsProvider = Provider(
  (ref) => GetGroupStudents(ref.watch(usersRepositoryProvider)),
);
final getActiveStudentsProvider = Provider(
  (ref) => GetActiveStudents(ref.watch(usersRepositoryProvider)),
);
final getStudentProvider = Provider(
  (ref) => GetStudent(ref.watch(usersRepositoryProvider)),
);
final getActivitiesProvider = Provider(
  (ref) => GetActivities(ref.watch(activitiesRepositoryProvider)),
);
final saveActivityDraftProvider = Provider(
  (ref) => SaveActivityDraft(ref.watch(activitiesRepositoryProvider)),
);
final publishActivityProvider = Provider(
  (ref) => PublishActivity(
    ref.watch(activitiesRepositoryProvider),
    ref.watch(syncQueueProvider),
  ),
);
final deleteActivityDraftProvider = Provider(
  (ref) => DeleteActivityDraft(ref.watch(activitiesRepositoryProvider)),
);
