import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:orbita_kids/config/routes/app_routes.dart';
import 'package:orbita_kids/config/providers/core_providers.dart';
import 'package:orbita_kids/shared/presentation/widgets/ui.dart';
import 'package:orbita_kids/features/auth/domain/entities/auth_entities.dart';
import 'package:orbita_kids/features/auth/presentation/providers/auth_controller.dart';
import 'package:orbita_kids/features/auth/presentation/widgets/auth_ui.dart';

/// 08 · Acceso institucional (OIDC / SAML a través de Keycloak).
class InstitutionScreen extends ConsumerStatefulWidget {
  const InstitutionScreen({super.key});

  @override
  ConsumerState<InstitutionScreen> createState() => _InstitutionScreenState();
}

class _InstitutionScreenState extends ConsumerState<InstitutionScreen> {
  String q = '';

  @override
  Widget build(BuildContext context) {
    final cfg = ref.watch(appConfigProvider);
    final c = context.ok;

    if (!cfg.isDemo) {
      // Con Keycloak: el IdP institucional se elige en Keycloak (o directo
      // con KEYCLOAK_IDP_INSTITUTION). El catálogo de escuelas es del backend.
      return OkPage(
        title: 'Acceso institucional',
        subtitle: 'Entra con la identidad de tu escuela',
        children: [
          Gap.h8,
          const Center(
            child: IconBox(
              Icons.school_rounded,
              bg: Brand.lavender,
              fg: Brand.purpleDark,
              size: 96,
            ),
          ),
          Gap.h16,
          const Text(
            'Te llevaremos a la página segura de inicio de sesión. Ahí eliges tu escuela y entras con su proveedor (Google Workspace for Education, Microsoft Entra ID u otro compatible).',
            style: TextStyle(fontSize: 16),
          ),
          Gap.h16,
          FilledButton.icon(
            onPressed: () => runKeycloakSignIn(ref, AuthMethod.institution),
            icon: const Icon(Icons.open_in_new_rounded),
            label: const Text('Continuar a mi institución'),
          ),
          Gap.h12,
          InfoBanner(
            text: '¿No aparece tu escuela? Pide a la dirección que active Órbita Kids o escribe a soporte desde Ayuda.',
            action: TextButton(
              onPressed: () => context.push(AppRoutes.help),
              child: const Text('Ir a Ayuda'),
            ),
          ),
        ],
      );
    }

    final list = ref
        .watch(demoDirectoryProvider)
        .institutions()
        .where((i) => i.name.toLowerCase().contains(q.toLowerCase()))
        .toList();
    return OkPage(
      title: 'Acceso institucional',
      subtitle: 'Busca tu escuela',
      children: [
        const DemoModeBanner(),
        Gap.h12,
        TextField(
          decoration: const InputDecoration(
            labelText: 'Nombre de la escuela',
            prefixIcon: Icon(Icons.search_rounded),
          ),
          onChanged: (v) => setState(() => q = v),
        ),
        Gap.h12,
        if (list.isEmpty)
          const InfoBanner(
            text: 'No encontramos esa escuela. Revisa el nombre o pide ayuda a la dirección.',
          ),
        for (final i in list) ...[
          OkListTile(
            leading: IconBox(
              Icons.school_rounded,
              bg: c.tintViolet,
              fg: c.inkViolet,
            ),
            title: i.name,
            subtitle:
                '${i.idp} · ${i.protocol}${i.down ? ' · No disponible' : ''}',
            onTap: () => i.down
                ? context.push(
                    AppRoutes.authState('unavailable', method: 'institution'),
                  )
                : context.push(
                    AppRoutes.demoProvider('institution', institutionId: i.id),
                  ),
          ),
          Gap.h8,
        ],
        Gap.h8,
        InfoBanner(
          text: '¿No aparece tu escuela? Pide a la dirección que active Órbita Kids o escribe a soporte desde Ayuda.',
          action: TextButton(
            onPressed: () => context.push(AppRoutes.help),
            child: const Text('Ir a Ayuda'),
          ),
        ),
      ],
    );
  }
}
