import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:orbita_kids/config/providers/core_providers.dart';
import 'package:orbita_kids/core/network/api_cache.dart';
import 'package:orbita_kids/shared/data/repositories/activities_repository_impl.dart';
import 'package:orbita_kids/shared/domain/repositories/activities_repository.dart';

/// Actividades compartidas por docente y estudiante.
final activitiesRepositoryProvider = Provider<ActivitiesRepository>((ref) {
  final store = ref.watch(localStoreProvider);
  final cache = ref.watch(apiCacheProvider);
  if (cache != null) return ServerActivitiesRepository(store, cache);
  return LocalActivitiesRepository(
    store,
    includeDemo: ref.watch(appConfigProvider).isDemo,
  );
});
