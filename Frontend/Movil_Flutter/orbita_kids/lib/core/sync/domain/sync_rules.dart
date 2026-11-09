import 'dart:math';

import 'package:orbita_kids/core/sync/domain/sync_models.dart';

/// Reglas de negocio de la cola offline first (Dart puro, sin E/S):
///
/// * solo se retira un registro cuando el servidor lo confirma;
/// * los errores temporales se reintentan con espera exponencial con tope;
/// * los conflictos esperan la decisión de la persona y no se reenvían solos;
/// * sin servidor, el registro sigue pendiente (nunca «enviado»).
abstract final class SyncRules {
  static const maxBackoff = Duration(minutes: 30);

  static Duration backoffFor(int attempts) {
    final secs = 15 * pow(2, max(0, attempts - 1)).toInt();
    final d = Duration(seconds: secs);
    return d > maxBackoff ? maxBackoff : d;
  }

  /// ¿Toca intentar este registro ahora?
  static bool isDue(
    SyncItem i,
    DateTime now, {
    bool force = false,
    String? owner,
  }) {
    if (owner != null && i.owner != owner) return false;
    if (i.status == SyncStatus.conflict) return false;
    if (!force && i.nextRetryAt != null && i.nextRetryAt!.isAfter(now)) {
      return false;
    }
    return true;
  }

  /// Estado del registro tras la respuesta del servidor.
  /// Devuelve `null` si quedó confirmado (sale de la cola).
  static SyncItem? afterOutcome(SyncItem i, SyncOutcome out, DateTime now) =>
      switch (out) {
        SyncConfirmed() => null,
        SyncConflict(:final message) => i.copyWith(
          status: SyncStatus.conflict,
          lastError: message,
          attempts: i.attempts + 1,
        ),
        SyncRetry(:final message) => i.copyWith(
          status: SyncStatus.error,
          attempts: i.attempts + 1,
          lastError: message,
          nextRetryAt: now.add(backoffFor(i.attempts + 1)),
        ),
        SyncNotConfigured() => i.copyWith(
          status: SyncStatus.pending,
          clearError: true,
        ),
      };

  /// Próximo reintento programado entre los registros con error.
  static DateTime? nextRetry(Iterable<SyncItem> items) => items
      .where((i) => i.status == SyncStatus.error && i.nextRetryAt != null)
      .map((i) => i.nextRetryAt!)
      .fold<DateTime?>(null, (a, b) => a == null || b.isBefore(a) ? b : a);
}
