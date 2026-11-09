import 'package:orbita_kids/features/auth/domain/entities/auth_entities.dart';
import 'package:orbita_kids/features/notifications/domain/entities/app_notice.dart';

/// Avisos dentro de la app. Los avisos push del servidor quedan pendientes.
abstract interface class NotificationsRepository {
  Future<List<AppNotice>> list(String owner, UserRole role);
  Future<void> add(String owner, AppNotice notice);
  Future<void> markAllRead(String owner, UserRole role);
}
