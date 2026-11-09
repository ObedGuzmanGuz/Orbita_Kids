import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:orbita_kids/core/sync/providers/sync_providers.dart';
import 'package:orbita_kids/features/plans/data/repositories/plans_repository_impl.dart';
import 'package:orbita_kids/features/plans/domain/repositories/plans_repository.dart';
import 'package:orbita_kids/features/plans/domain/usecases/plans_usecases.dart';

final plansRepositoryProvider = Provider<PlansRepository>(
  (ref) => QueuedPlansRepository(ref.watch(syncQueueProvider)),
);

final getPlansProvider = Provider(
  (ref) => GetPlans(ref.watch(plansRepositoryProvider)),
);

final requestPlanInformationProvider = Provider(
  (ref) => RequestPlanInformation(ref.watch(plansRepositoryProvider)),
);
