import 'package:dio/dio.dart';

import 'package:orbita_kids/core/network/api_client.dart';
import 'package:orbita_kids/core/sync/domain/sync_gateway.dart';
import 'package:orbita_kids/core/sync/domain/sync_models.dart';

/// Sin servidor (modo demo o backend sin endpoints): nada se marca como
/// enviado; los registros quedan pendientes y protegidos en el teléfono.
class NoBackendGateway implements SyncGateway {
  const NoBackendGateway();

  @override
  bool supports(SyncKind kind) => false;

  @override
  Future<SyncOutcome> send(SyncItem item) async => const SyncNotConfigured();
}

/// Envío HTTP real a las rutas de [ApiEndpoints] (contrato en
/// `backend/README.md`): 2xx confirma, 409/412 es conflicto, un rechazo de
/// datos o permisos (400, 403, 404, 422) también espera a la persona porque
/// reintentarlo no lo arregla, y lo demás (red, 401, 5xx) se reintenta.
class HttpSyncGateway implements SyncGateway {
  HttpSyncGateway(this._dio);

  final Dio _dio;

  static const _rejected = {400, 403, 404, 422};

  String _path(SyncKind k) => switch (k) {
    SyncKind.attempt => ApiEndpoints.attempts,
    SyncKind.activityDraft => ApiEndpoints.activities,
    SyncKind.profile => ApiEndpoints.me,
    SyncKind.planRequest => ApiEndpoints.planRequests,
    SyncKind.supportReport => ApiEndpoints.supportReports,
  };

  @override
  bool supports(SyncKind kind) => true;

  @override
  Future<SyncOutcome> send(SyncItem item) async {
    // «Conservar mi versión» marca `server-latest`: se envía sin If-Match para
    // que el servidor acepte la edición sobre su versión actual.
    final version = int.tryParse(item.baseVersion ?? '');
    try {
      await _dio.post<void>(
        _path(item.kind),
        data: {'id': item.id, ...item.payload},
        options: Options(
          headers: {
            'Idempotency-Key': item.id,
            if (version != null) 'If-Match': '"$version"',
          },
        ),
      );
      return const SyncConfirmed();
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      if (code == 409 || code == 412) {
        return SyncConflict(
          code == 412
              ? 'El servidor tiene una versión más reciente. No se sobrescribió.'
              : apiErrorMessage(e),
        );
      }
      if (_rejected.contains(code)) {
        return SyncConflict('El servidor no lo aceptó: ${apiErrorMessage(e)}');
      }
      return SyncRetry(apiErrorMessage(e));
    }
  }
}
