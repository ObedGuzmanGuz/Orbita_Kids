import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:orbita_kids/shared/presentation/widgets/ui.dart';
import 'package:orbita_kids/features/auth/presentation/providers/auth_controller.dart';
import 'package:orbita_kids/features/auth/domain/entities/auth_entities.dart';
import 'package:orbita_kids/features/notifications/providers/notifications_providers.dart';
import 'package:orbita_kids/features/notifications/presentation/providers/notices_providers.dart';

/// Lista de avisos (estudiante y docente). Sin urgencia artificial.
class NoticesList extends ConsumerWidget {
  const NoticesList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.ok;
    final user = ref.watch(currentUserProvider);
    return ref
        .watch(noticesProvider)
        .when(
          loading: () => const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) =>
              InfoBanner(tone: Tone.err, text: 'No pudimos cargar los avisos.'),
          data: (list) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (list.isEmpty)
                const InfoBanner(
                  icon: Icons.inbox_rounded,
                  text: 'No tienes avisos por ahora.',
                ),
              if (list.any((n) => !n.read))
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () async {
                      await ref.read(markAllNoticesReadProvider).call(user!);
                      ref.invalidate(noticesProvider);
                    },
                    child: const Text('Marcar todo como leído'),
                  ),
                ),
              for (final n in list)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: OkListTile(
                    leading: IconBox(
                      n.icon,
                      bg: switch (n.kind) {
                        'rest' => c.tintMint,
                        'res' => c.tintYellow,
                        'rule' => c.tintYellow,
                        'act' => c.tintTeal,
                        _ => c.tintViolet,
                      },
                      fg: switch (n.kind) {
                        'rest' => c.inkMint,
                        'res' || 'rule' => c.inkYellow,
                        'act' => c.inkTeal,
                        _ => c.inkViolet,
                      },
                    ),
                    title: n.title,
                    subtitle: '${n.when}${n.read ? '' : ' · nuevo'}',
                    onTap: n.route == null
                        ? null
                        : () => context.push(n.route!),
                  ),
                ),
              if (user?.role == UserRole.teacher)
                Text(
                  'Los avisos del servidor (push) se activarán cuando el backend esté disponible.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
        );
  }
}
