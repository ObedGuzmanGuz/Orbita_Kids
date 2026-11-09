import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:orbita_kids/features/auth/presentation/providers/auth_controller.dart';
import 'package:orbita_kids/features/notifications/providers/notifications_providers.dart';
import 'package:orbita_kids/features/notifications/domain/entities/app_notice.dart';

/// Avisos de la persona actual.
final noticesProvider = FutureProvider<List<AppNotice>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const [];
  return ref.watch(getNoticesProvider).call(user);
});

/// Ícono de cada tipo de aviso (solo presentación).
extension AppNoticeUi on AppNotice {
  IconData get icon => switch (kind) {
    'act' => Icons.assignment_rounded,
    'res' => Icons.star_rounded,
    'sync' => Icons.cloud_done_rounded,
    'rest' => Icons.directions_run_rounded,
    'grp' => Icons.groups_rounded,
    _ => Icons.auto_awesome_rounded,
  };
}
