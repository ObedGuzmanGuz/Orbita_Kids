import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:orbita_kids/config/providers/core_providers.dart';
import 'package:orbita_kids/core/network/api_client.dart';
import 'package:orbita_kids/core/storage/local_store.dart';

/// Dueño de los datos en caché (lo registra el módulo de auth), para que una
/// cuenta nunca vea lo que descargó otra en el mismo teléfono.
typedef CacheOwnerGetter = String Function();

final cacheOwnerProvider = Provider<CacheOwnerGetter>((_) => () => 'anon');

/// Lecturas del API con copia local: sin red (o con el servidor caído) se
/// devuelve la última respuesta guardada de esa ruta.
class ApiCache {
  ApiCache(this._dio, this._store, this._owner);

  final Dio _dio;
  final LocalStore _store;
  final CacheOwnerGetter _owner;

  static const col = 'api_cache';

  Future<dynamic> get(String path) async {
    final key = '${_owner()}|$path';
    try {
      final res = await _dio.get<dynamic>(path);
      await _store.put(col, key, {'data': res.data});
      return res.data;
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      if (code == null || code >= 500) {
        final hit = await _store.get(col, key);
        if (hit != null) return hit['data'];
      }
      rethrow;
    }
  }
}

/// `null` si no hay servidor.
final apiCacheProvider = Provider<ApiCache?>((ref) {
  final dio = ref.watch(dioProvider);
  if (dio == null) return null;
  return ApiCache(
    dio,
    ref.watch(localStoreProvider),
    ref.watch(cacheOwnerProvider),
  );
});
