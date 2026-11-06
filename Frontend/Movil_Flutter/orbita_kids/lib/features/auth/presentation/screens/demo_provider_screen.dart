import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:orbita_kids/config/routes/app_routes.dart';
import 'package:orbita_kids/shared/presentation/widgets/ui.dart';
import 'package:orbita_kids/features/auth/presentation/providers/auth_controller.dart';
import 'package:orbita_kids/features/auth/domain/entities/auth_entities.dart';
import 'package:orbita_kids/features/auth/presentation/widgets/auth_ui.dart';

/// 06 · 07 · Selector de identidad de DEMOSTRACIÓN.
///
/// Con Keycloak configurado esta pantalla no se usa: la app abre el navegador
/// seguro del sistema y Keycloak redirige al proveedor real. Aquí solo se
/// eligen identidades ficticias y escenarios para recorrer los flujos.
class DemoProviderScreen extends ConsumerWidget {
  const DemoProviderScreen({
    super.key,
    required this.method,
    this.institutionId,
  });

  final AuthMethod method;
  final String? institutionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.ok;
    final dir = ref.watch(demoDirectoryProvider);
    final inst = institutionId == null
        ? null
        : dir.institutions().where((i) => i.id == institutionId).firstOrNull;
    final ids = inst != null
        ? dir.institutionIdentities(inst.id)
        : dir.identitiesFor(method);
    final provider = inst?.name ?? method.label;

    Future<void> pick(DemoIdentity id) async {
      if (id.result != null) {
        context.pushReplacement(
          AppRoutes.authState(id.result!.name, method: method.name),
        );
        return;
      }
      await ref
          .read(authControllerProvider.notifier)
          .signInDemoAccount(id.accountId!);
      goHomeAfterDemoSignIn(ref);
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Icon(Icons.science_rounded, size: 18, color: c.muted),
            Gap.w8,
            Expanded(
              child: Text(
                'Simulación de $provider',
                style: Theme.of(context).textTheme.titleMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => context.pushReplacement(
              AppRoutes.authState('cancelled', method: method.name),
            ),
            child: const Text('Cancelar'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        children: [
          const DemoModeBanner(),
          Gap.h12,
          InfoBanner(
            icon: Icons.info_outline_rounded,
            text:
                'En la app real, Keycloak abre la página de $provider en el navegador seguro del teléfono. La app nunca pide tu contraseña de $provider.',
          ),
          if (method == AuthMethod.facebook) ...[
            Gap.h10,
            const InfoBanner(
              tone: Tone.warn,
              icon: Icons.family_restroom_rounded,
              text: 'Las cuentas de redes sociales son para adultos según las políticas de cada proveedor. Los niños no necesitan crear una.',
            ),
          ],
          const SectionTitle('Elige una identidad de demostración'),
          if (ids.isEmpty)
            InfoBanner(
              tone: Tone.err,
              icon: Icons.cloud_off_rounded,
              text: '${inst?.name ?? provider} no responde en este momento.',
              action: FilledButton(
                onPressed: () => context.pushReplacement(
                  AppRoutes.authState('unavailable', method: method.name),
                ),
                child: const Text('Ver qué hacer'),
              ),
            ),
          for (final id in ids) ...[
            OkListTile(
              leading: id.accountId != null
                  ? InitialsAvatar(
                      name: id.label,
                      color: id.accountId == 'u-ana'
                          ? Brand.turquoiseDark
                          : Brand.purple,
                    )
                  : IconBox(
                      Icons.person_outline_rounded,
                      bg: c.tintGray,
                      fg: c.muted,
                    ),
              title: id.label,
              subtitle: id.sub,
              onTap: () => pick(id),
            ),
            Gap.h8,
          ],
          const SectionTitle('Probar otros escenarios'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final (code, label) in dir.scenarios)
                ActionChip(
                  label: Text(label),
                  onPressed: () => context.pushReplacement(
                    AppRoutes.authState(code.name, method: method.name),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
