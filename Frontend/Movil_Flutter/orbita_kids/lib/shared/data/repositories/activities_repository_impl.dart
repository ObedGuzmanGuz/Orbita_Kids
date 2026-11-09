import 'package:dio/dio.dart';

import 'package:orbita_kids/core/network/api_cache.dart';
import 'package:orbita_kids/core/network/api_client.dart';
import 'package:orbita_kids/core/storage/local_store.dart';
import 'package:orbita_kids/shared/data/demo/demo_data.dart';
import 'package:orbita_kids/shared/domain/entities/content.dart';
import 'package:orbita_kids/shared/domain/repositories/activities_repository.dart';

/// Actividades: datos demo + actividades creadas en el teléfono.
class LocalActivitiesRepository implements ActivitiesRepository {
  LocalActivitiesRepository(this._store, {required this.includeDemo});
  final LocalStore _store;
  final bool includeDemo;
  static const col = 'activities';

  @override
  bool get available => includeDemo;

  @override
  Future<List<Activity>> list() async {
    final local = (await _store.all(col)).map(Activity.fromJson).toList();
    final ids = local.map((a) => a.id).toSet();
    return [
      ...local,
      if (includeDemo) ...DemoData.activities.where((a) => !ids.contains(a.id)),
    ];
  }

  @override
  Future<void> saveLocal(Activity activity) =>
      _store.put(col, activity.id, activity.toJson());

  @override
  Future<void> deleteLocal(String id) => _store.delete(col, id);
}

/// Con servidor: las actividades publicadas vienen de `GET /activities` (con
/// copia local para usar sin Internet). Los borradores y lo publicado que aún
/// no llega al servidor viven en el teléfono y se agregan a la lista.
class ServerActivitiesRepository implements ActivitiesRepository {
  ServerActivitiesRepository(this._store, this._cache);
  final LocalStore _store;
  final ApiCache _cache;
  static const col = LocalActivitiesRepository.col;

  @override
  bool get available => true;

  @override
  Future<List<Activity>> list() async {
    final local = (await _store.all(col)).map(Activity.fromJson).toList();
    List<Activity> server;
    try {
      final data = await _cache.get(ApiEndpoints.activities) as Map;
      server = [
        for (final a in data['items'] as List)
          Activity.fromJson(Map<String, dynamic>.from(a as Map)),
      ];
    } on DioException {
      // Sin red y sin copia guardada: se muestra lo que hay en el teléfono.
      server = const [];
    }
    final ids = server.map((a) => a.id).toSet();
    return [...server, ...local.where((a) => !ids.contains(a.id))];
  }

  @override
  Future<void> saveLocal(Activity activity) =>
      _store.put(col, activity.id, activity.toJson());

  @override
  Future<void> deleteLocal(String id) => _store.delete(col, id);
}
