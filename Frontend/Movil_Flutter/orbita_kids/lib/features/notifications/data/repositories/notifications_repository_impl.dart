import 'package:orbita_kids/core/storage/local_store.dart';
import 'package:orbita_kids/config/routes/app_routes.dart';
import 'package:orbita_kids/features/auth/domain/entities/auth_entities.dart';
import 'package:orbita_kids/features/notifications/domain/entities/app_notice.dart';
import 'package:orbita_kids/features/notifications/domain/repositories/notifications_repository.dart';

/// Avisos locales + avisos de demostración. Los avisos push del servidor
/// quedan pendientes de backend (ver README).
class LocalNotificationsRepository implements NotificationsRepository {
  LocalNotificationsRepository(this._store, {required this.demo});
  final LocalStore _store;
  final bool demo;

  static const _studentDemo = [
    AppNotice(
      id: 'n1',
      kind: 'act',
      title: 'Tu maestra te dejó «Sumas hasta 20»',
      when: 'Hoy',
      route: AppRoutes.assigned,
    ),
    AppNotice(
      id: 'n2',
      kind: 'res',
      title: 'Ganaste 2 estrellas en «Recoge estrellas»',
      when: 'Ayer',
      route: AppRoutes.progress,
    ),
    AppNotice(
      id: 'n3',
      kind: 'rest',
      title: '¿Hacemos una Pausa Estelar? Llevas un rato aprendiendo',
      when: 'Ayer',
      route: AppRoutes.pause,
    ),
  ];

  static final _teacherDemo = [
    AppNotice(
      id: 't1',
      kind: 'res',
      title: '9 estudiantes de 2° A terminaron «Estrellas hasta 10»',
      when: 'Hoy',
      route: AppRoutes.reports,
    ),
    AppNotice(
      id: 't2',
      kind: 'rule',
      title: 'Diego L. podría beneficiarse de un refuerzo en sumas que pasan de 10 (regla R4)',
      when: 'Hoy',
      route: AppRoutes.studentDetail('g2a-3'),
    ),
    AppNotice(
      id: 't3',
      kind: 'act',
      title: '«Selección rápida» vence el 2 nov · 4 pendientes en 2° B',
      when: 'Ayer',
      route: AppRoutes.activities,
    ),
    AppNotice(
      id: 't4',
      kind: 'grp',
      title: 'El grupo 1° C quedó archivado al terminar el ciclo',
      when: '27 oct',
      route: AppRoutes.groups,
    ),
  ];

  String _col(String owner) => 'notices_$owner';

  @override
  Future<List<AppNotice>> list(String owner, UserRole role) async {
    final local = (await _store.all(_col(owner)))
        .map(AppNotice.fromJson)
        .toList();
    final ids = local.map((n) => n.id).toSet();
    final seed = !demo
        ? const <AppNotice>[]
        : role == UserRole.teacher
        ? _teacherDemo
        : _studentDemo;
    return [...local, ...seed.where((n) => !ids.contains(n.id))];
  }

  @override
  Future<void> add(String owner, AppNotice notice) =>
      _store.put(_col(owner), notice.id, notice.toJson());

  @override
  Future<void> markAllRead(String owner, UserRole role) async {
    for (final n in await list(owner, role)) {
      await _store.put(
        _col(owner),
        n.id,
        AppNotice(
          id: n.id,
          kind: n.kind,
          title: n.title,
          when: n.when,
          route: n.route,
          read: true,
        ).toJson(),
      );
    }
  }
}
