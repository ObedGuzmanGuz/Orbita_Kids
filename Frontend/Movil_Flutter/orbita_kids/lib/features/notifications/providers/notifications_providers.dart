import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:orbita_kids/config/providers/core_providers.dart';
import 'package:orbita_kids/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:orbita_kids/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:orbita_kids/features/notifications/domain/usecases/notices_usecases.dart';

final notificationsRepositoryProvider = Provider<NotificationsRepository>(
  (ref) => LocalNotificationsRepository(
    ref.watch(localStoreProvider),
    demo: ref.watch(appConfigProvider).isDemo,
  ),
);

final getNoticesProvider = Provider(
  (ref) => GetNotices(ref.watch(notificationsRepositoryProvider)),
);

final markAllNoticesReadProvider = Provider(
  (ref) => MarkAllNoticesRead(ref.watch(notificationsRepositoryProvider)),
);
