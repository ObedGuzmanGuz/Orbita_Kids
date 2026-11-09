/// El servidor respondió pero no aceptó la operación (mensaje para mostrar).
class ServerRejected implements Exception {
  const ServerRejected(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Error de una operación que necesita un backend aún no disponible.
class BackendUnavailable implements Exception {
  const BackendUnavailable(this.what);

  final String what;

  @override
  String toString() => 'Backend no disponible: $what';
}
