import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:orbita_kids/config/routes/app_routes.dart';
import 'package:orbita_kids/core/network/connectivity.dart';
import 'package:orbita_kids/core/sync/presentation/providers/sync_controller.dart';
import 'package:orbita_kids/shared/presentation/art/mascot.dart';
import 'package:orbita_kids/shared/presentation/widgets/ui.dart';
import 'package:orbita_kids/features/auth/presentation/providers/auth_controller.dart';

/// 49 · Cerrar sesión. No borra progreso pendiente: lo aísla y protege.
class LogoutScreen extends ConsumerStatefulWidget {
  const LogoutScreen({super.key});

  @override
  ConsumerState<LogoutScreen> createState() => _LogoutScreenState();
}

class _LogoutScreenState extends ConsumerState<LogoutScreen> {
  bool busy = false;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final pending = user == null
        ? 0
        : ref.watch(syncControllerProvider).of(user.id).length;
    final online = ref.watch(onlineProvider);
    final c = context.ok;
    return OkPage(
      title: 'Cerrar sesión',
      children: [
        const Center(child: Mascot.orbi(pose: 'wave', size: 130)),
        Text(
          '¿Quieres salir, ${user?.name ?? ''}?',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        Gap.h12,
        if (pending > 0)
          InfoBanner(
            tone: Tone.warn,
            icon: Icons.cloud_upload_outlined,
            text:
                'Tienes $pending registro${pending == 1 ? '' : 's'} sin enviar. No se borran: quedan guardados en este teléfono y se enviarán cuando vuelvas a entrar con tu cuenta.',
          )
        else
          const InfoBanner(
            tone: Tone.ok,
            icon: Icons.check_circle_rounded,
            text: 'No tienes registros pendientes.',
          ),
        Gap.h14,
        OkCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Qué pasará',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              for (final t in [
                'Se cierra la sesión en este teléfono.',
                'Se retiran los tokens de acceso guardados.',
                online ? 'Se pide a Keycloak el cierre de la sesión.' : 'Sin Internet: el cierre en Keycloak se completará al reconectar.',
                'Tu avance pendiente queda protegido y separado de otras cuentas.',
              ])
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_rounded, size: 18, color: c.ok),
                      Gap.w8,
                      Expanded(child: Text(t)),
                    ],
                  ),
                ),
            ],
          ),
        ),
        Gap.h18,
        FilledButton.icon(
          style: FilledButton.styleFrom(backgroundColor: c.err),
          onPressed: busy
              ? null
              : () async {
                  setState(() => busy = true);
                  await ref.read(authControllerProvider.notifier).signOut();
                  if (context.mounted) context.go(AppRoutes.login);
                },
          icon: const Icon(Icons.logout_rounded),
          label: const Text('Cerrar sesión'),
        ),
        Gap.h10,
        OutlinedButton(
          onPressed: () => context.pop(),
          child: const Text('Quedarme'),
        ),
      ],
    );
  }
}
