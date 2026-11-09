import 'package:meta/meta.dart';

/// Aviso dentro de la app (pantallas 24 y 36).
@immutable
class AppNotice {
  const AppNotice({
    required this.id,
    required this.kind,
    required this.title,
    required this.when,
    this.route,
    this.read = false,
  });

  final String id;

  /// `act`, `res`, `sync`, `rest`, `grp`, `rule`.
  final String kind;
  final String title;
  final String when;

  /// Ruta a abrir al tocar el aviso.
  final String? route;
  final bool read;

  Map<String, dynamic> toJson() => {
    'id': id,
    'kind': kind,
    'title': title,
    'when': when,
    'route': route,
    'read': read,
  };

  factory AppNotice.fromJson(Map<String, dynamic> j) => AppNotice(
    id: j['id'] as String,
    kind: j['kind'] as String,
    title: j['title'] as String,
    when: j['when'] as String,
    route: j['route'] as String?,
    read: j['read'] as bool? ?? false,
  );
}
