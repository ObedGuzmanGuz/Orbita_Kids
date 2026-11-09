import 'package:meta/meta.dart';

enum SyncStatus { pending, syncing, error, conflict }

/// Tipo de registro en la cola. Cada uno corresponde a un endpoint pendiente.
enum SyncKind { attempt, activityDraft, profile, planRequest, supportReport }

extension SyncKindText on SyncKind {
  String get label => switch (this) {
    SyncKind.attempt => 'Resultado de misión',
    SyncKind.activityDraft => 'Actividad',
    SyncKind.profile => 'Perfil',
    SyncKind.planRequest => 'Solicitud de información',
    SyncKind.supportReport => 'Reporte de problema',
  };
}

/// Registro pendiente de envío. Tiene ID único (idempotencia) y nunca se marca
/// como enviado hasta que el servidor lo confirma.
@immutable
class SyncItem {
  const SyncItem({
    required this.id,
    required this.kind,
    required this.owner,
    required this.title,
    required this.detail,
    required this.createdAt,
    required this.payload,
    this.status = SyncStatus.pending,
    this.attempts = 0,
    this.lastError,
    this.nextRetryAt,
    this.baseVersion,
  });

  final String id;
  final SyncKind kind;
  final String owner;
  final String title;
  final String detail;
  final DateTime createdAt;
  final Map<String, dynamic> payload;
  final SyncStatus status;
  final int attempts;
  final String? lastError;
  final DateTime? nextRetryAt;

  /// Versión del servidor sobre la que se editó (para detectar conflictos).
  final String? baseVersion;

  SyncItem copyWith({
    SyncStatus? status,
    int? attempts,
    String? lastError,
    bool clearError = false,
    DateTime? nextRetryAt,
    bool clearRetry = false,
    String? baseVersion,
  }) => SyncItem(
    id: id,
    kind: kind,
    owner: owner,
    title: title,
    detail: detail,
    createdAt: createdAt,
    payload: payload,
    status: status ?? this.status,
    attempts: attempts ?? this.attempts,
    lastError: clearError ? null : lastError ?? this.lastError,
    nextRetryAt: clearRetry ? null : nextRetryAt ?? this.nextRetryAt,
    baseVersion: baseVersion ?? this.baseVersion,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'kind': kind.name,
    'owner': owner,
    'title': title,
    'detail': detail,
    'createdAt': createdAt.toIso8601String(),
    'payload': payload,
    'status': status.name,
    'attempts': attempts,
    'lastError': lastError,
    'nextRetryAt': nextRetryAt?.toIso8601String(),
    'baseVersion': baseVersion,
  };

  factory SyncItem.fromJson(Map<String, dynamic> j) => SyncItem(
    id: j['id'] as String,
    kind: SyncKind.values.byName(j['kind'] as String),
    owner: j['owner'] as String,
    title: j['title'] as String,
    detail: j['detail'] as String,
    createdAt: DateTime.parse(j['createdAt'] as String),
    payload: Map<String, dynamic>.from(j['payload'] as Map),
    // Un envío interrumpido (app cerrada) vuelve a pendiente, nunca a enviado.
    status: j['status'] == 'syncing'
        ? SyncStatus.pending
        : SyncStatus.values.byName(j['status'] as String),
    attempts: j['attempts'] as int? ?? 0,
    lastError: j['lastError'] as String?,
    nextRetryAt: j['nextRetryAt'] == null
        ? null
        : DateTime.parse(j['nextRetryAt'] as String),
    baseVersion: j['baseVersion'] as String?,
  );
}

/// Resultado de enviar un registro al servidor.
sealed class SyncOutcome {
  const SyncOutcome();
}

/// El servidor guardó el registro (o ya lo tenía con el mismo ID).
class SyncConfirmed extends SyncOutcome {
  const SyncConfirmed();
}

/// El servidor tiene una versión más nueva: no se sobrescribe.
class SyncConflict extends SyncOutcome {
  const SyncConflict(this.message);
  final String message;
}

/// Error temporal (red, 5xx): se reintenta con espera creciente.
class SyncRetry extends SyncOutcome {
  const SyncRetry(this.message);
  final String message;
}

/// No hay servidor configurado: el registro sigue pendiente en el teléfono.
class SyncNotConfigured extends SyncOutcome {
  const SyncNotConfigured();
}

/// Registro confirmado por el servidor (historial).
@immutable
class SyncedRecord {
  const SyncedRecord({
    required this.id,
    required this.title,
    required this.kind,
    required this.owner,
    required this.at,
  });

  final String id;
  final String title;
  final SyncKind kind;
  final String owner;
  final DateTime at;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'kind': kind.name,
    'owner': owner,
    'at': at.toIso8601String(),
  };

  factory SyncedRecord.fromJson(Map<String, dynamic> j) => SyncedRecord(
    id: j['id'] as String,
    title: j['title'] as String,
    kind: SyncKind.values.byName(j['kind'] as String),
    owner: j['owner'] as String,
    at: DateTime.parse(j['at'] as String),
  );
}
