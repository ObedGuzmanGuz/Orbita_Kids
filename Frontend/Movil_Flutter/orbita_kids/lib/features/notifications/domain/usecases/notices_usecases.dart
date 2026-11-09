import 'package:orbita_kids/features/auth/domain/entities/auth_entities.dart';
import 'package:orbita_kids/features/notifications/domain/entities/app_notice.dart';
import 'package:orbita_kids/features/notifications/domain/repositories/notifications_repository.dart';

class GetNotices {
  const GetNotices(this._repo);
  final NotificationsRepository _repo;

  Future<List<AppNotice>> call(AppUser user) => _repo.list(user.id, user.role);
}

class MarkAllNoticesRead {
  const MarkAllNoticesRead(this._repo);
  final NotificationsRepository _repo;

  Future<void> call(AppUser user) => _repo.markAllRead(user.id, user.role);
}
