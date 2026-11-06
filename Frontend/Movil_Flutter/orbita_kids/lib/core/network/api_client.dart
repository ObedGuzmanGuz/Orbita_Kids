import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:orbita_kids/config/env/app_config.dart';

export 'package:orbita_kids/core/error/failures.dart';
import 'package:orbita_kids/config/providers/core_providers.dart';

/// Rutas del backend de Órbita Kids (`../backend`), relativas a
/// `API_BASE_URL` (p. ej. `http://localhost:3000/v1`). Una ruta `null` es una
/// función que el backend aún no ofrece: la app no la llama.
abstract final class ApiEndpoints {
  /// Perfil y rol del usuario autenticado.
  static const String me = '/me';

  /// Envío de resultados e intentos de misiones (idempotente por ID).
  static const String attempts = '/attempts';

  /// Publicación de actividades docentes.
  static const String activities = '/activities';

  /// Validación de códigos de grupo contra la licencia
  /// (`/check` es público; `/redeem` une al estudiante con el grupo).
  static const String groupCodes = '/group-codes';

  /// Grupos del docente (`/groups/:id/students` para el reporte).
  static const String groups = '/groups';

  /// Resumen de un estudiante para el docente.
  static const String students = '/students';

  /// Solicitudes de información de planes.
  static const String planRequests = '/plan-requests';

  /// Reportes de problemas enviados desde Ayuda.
  static const String supportReports = '/support-reports';

  /// Cierre de otras sesiones del usuario (pendiente en el backend: necesita
  /// la Admin API de Keycloak).
  static const String? sessions = null;
}

/// Mensaje del backend (`{error: {message}}`) o uno genérico.
String apiErrorMessage(DioException e) {
  final data = e.response?.data;
  if (data is Map && data['error'] is Map) {
    final msg = (data['error'] as Map)['message'];
    if (msg is String && msg.isNotEmpty) return msg;
  }
  final code = e.response?.statusCode;
  return code == null
      ? 'Sin respuesta del servidor'
      : 'El servidor respondió $code';
}

/// Proveedor del token de acceso vigente (lo registra el módulo de auth).
typedef AccessTokenGetter = Future<String?> Function();

final accessTokenGetterProvider = Provider<AccessTokenGetter>(
  (_) =>
      () async => null,
);

/// Cliente HTTP (Dio) con token Bearer. Solo existe si hay `API_BASE_URL` y
/// una sesión que el backend reconozca (Keycloak o `API_DEV_AUTH`).
final dioProvider = Provider<Dio?>((ref) {
  final AppConfig cfg = ref.watch(appConfigProvider);
  if (!cfg.usesServer) return null;
  final getToken = ref.watch(accessTokenGetterProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: cfg.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Accept': 'application/json'},
    ),
  );
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final t = await getToken();
        if (t != null) options.headers['Authorization'] = 'Bearer $t';
        handler.next(options);
      },
    ),
  );
  return dio;
});
