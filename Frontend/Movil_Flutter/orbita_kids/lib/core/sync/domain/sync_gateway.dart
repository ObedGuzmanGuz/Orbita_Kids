import 'package:orbita_kids/core/sync/domain/sync_models.dart';

/// Contrato de envío de la cola hacia el backend.
abstract interface class SyncGateway {
  /// `true` si existe un servidor capaz de recibir este tipo de registro.
  bool supports(SyncKind kind);

  Future<SyncOutcome> send(SyncItem item);
}
