import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:orbita_kids/config/providers/core_providers.dart';
import 'package:orbita_kids/core/sync/providers/sync_providers.dart';
import 'package:orbita_kids/features/student/data/repositories/student_repositories_impl.dart';
import 'package:orbita_kids/features/student/domain/repositories/student_repositories.dart';
import 'package:orbita_kids/features/student/domain/usecases/mission_usecases.dart';
import 'package:orbita_kids/features/student/domain/usecases/progress_usecases.dart';
import 'package:orbita_kids/shared/providers/shared_providers.dart';

final missionsRepositoryProvider = Provider<MissionsRepository>(
  (_) => const BundledMissionsRepository(),
);

final progressRepositoryProvider = Provider<ProgressRepository>(
  (ref) => LocalProgressRepository(
    ref.watch(localStoreProvider),
    demo: ref.watch(appConfigProvider).isDemo,
  ),
);

final loadStudentProgressProvider = Provider(
  (ref) => LoadStudentProgress(ref.watch(progressRepositoryProvider)),
);

final saveStudentProgressProvider = Provider(
  (ref) => SaveStudentProgress(ref.watch(progressRepositoryProvider)),
);

final getStudentTasksProvider = Provider(
  (ref) => GetStudentTasks(ref.watch(activitiesRepositoryProvider)),
);

final startMissionProvider = Provider(
  (ref) => StartMission(ref.watch(missionsRepositoryProvider)),
);

final finishMissionProvider = Provider(
  (ref) => FinishMission(
    ref.watch(missionsRepositoryProvider),
    ref.watch(progressRepositoryProvider),
    ref.watch(syncQueueProvider),
  ),
);
