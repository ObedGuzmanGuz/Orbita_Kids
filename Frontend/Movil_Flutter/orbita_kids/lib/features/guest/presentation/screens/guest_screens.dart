import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:orbita_kids/config/routes/app_router.dart';
import 'package:orbita_kids/shared/presentation/art/mascot.dart';
import 'package:orbita_kids/shared/presentation/art/space_art.dart';
import 'package:orbita_kids/shared/presentation/widgets/ui.dart';
import 'package:orbita_kids/features/auth/presentation/providers/auth_controller.dart';

/// 54 · Explorar sin cuenta: qué se puede hacer antes de entrar al modo.
class ExploreIntroScreen extends ConsumerWidget {
  const ExploreIntroScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final still = reduceMotion(context, ref);
    Widget item(String t) => Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        t,
        style: const TextStyle(color: Brand.ink, fontWeight: FontWeight.w600),
      ),
    );
    return Scaffold(
      backgroundColor: Brand.indigo,
      body: SpaceBackground(
        seed: 54,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Row(
                children: [
                  IconButton(
                    tooltip: 'Regresar',
                    color: Colors.white,
                    onPressed: () => context.canPop()
                        ? context.pop()
                        : context.go(AppRoutes.login),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: Text(
                        'Explorar sin cuenta',
                        style: Theme.of(context).textTheme.titleLarge
                            ?.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              Gap.h12,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Floating(
                    enabled: !still,
                    child: const Mascot(
                      look: AvatarLook(character: 'ari', helmet: 'morado'),
                      pose: 'wave',
                      size: 104,
                    ),
                  ),
                  Gap.w18,
                  Floating(
                    enabled: !still,
                    child: const Mascot.orbi(pose: 'wave', size: 96),
                  ),
                ],
              ),
              Gap.h12,
              Text(
                'Mira cómo es Órbita Kids',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(color: Colors.white),
              ),
              Gap.h4,
              const Text(
                'Puedes ver y probar una parte de la app. No pedimos tu nombre ni ningún dato.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Brand.lavenderText, fontSize: 15),
              ),
              Gap.h16,
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.check_rounded, color: Brand.ink, size: 20),
                        SizedBox(width: 6),
                        Text(
                          'Puedes',
                          style: TextStyle(
                            color: Brand.ink,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    item(
                      'Jugar 3 misiones de prueba del Planeta Verde (nivel 1)',
                    ),
                    item('Ver el mapa de los 6 planetas'),
                    item('Hacer actividades de Pausa Estelar'),
                    item('Probar tu astronauta y la accesibilidad'),
                    Gap.h14,
                    const Row(
                      children: [
                        Icon(
                          Icons.lock_outline_rounded,
                          color: Brand.ink,
                          size: 20,
                        ),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Se necesita una cuenta para',
                            style: TextStyle(
                              color: Brand.ink,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    item('Guardar estrellas y avance'),
                    item('Los planetas 2 a 6 y las tareas de la maestra'),
                    item('Jugar sin Internet y ver tu progreso'),
                  ],
                ),
              ),
              Gap.h12,
              const Text(
                'Al salir del modo explorar, lo que hiciste se borra.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Brand.lavender,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              Gap.h16,
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: Brand.yellow,
                  foregroundColor: Brand.ink,
                ),
                onPressed: () {
                  ref.read(authControllerProvider.notifier).startGuest();
                  ref.read(routerProvider).go(AppRoutes.guestHome);
                },
                icon: const Icon(Icons.rocket_launch_rounded),
                label: const Text('Empezar a explorar'),
              ),
              Gap.h6,
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Brand.lavender),
                onPressed: () => context.canPop()
                    ? context.pop()
                    : context.go(AppRoutes.login),
                child: const Text('Prefiero iniciar sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Sale del modo explorar y lleva a una ruta pública.
void leaveGuestTo(WidgetRef ref, String path) {
  ref.read(authControllerProvider.notifier).leaveGuest();
  ref.read(routerProvider).go(path);
}

/// 56 · Más (modo explorar).
class GuestMoreScreen extends ConsumerWidget {
  const GuestMoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.ok;
    ListTile link(IconData i, Color bg, Color fg, String t, String route) =>
        ListTile(
          leading: IconBox(i, bg: bg, fg: fg, size: 40),
          title: Text(t, style: const TextStyle(fontWeight: FontWeight.w800)),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => context.push(route),
        );
    return OkPage(
      title: 'Más',
      subtitle: 'Modo explorar',
      showBack: false,
      children: [
        const OkCard(
          child: Row(
            children: [
              Mascot.orbi(pose: 'point', size: 58, semanticLabel: null),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Estás explorando sin cuenta. Nada de lo que hagas aquí se guarda ni se envía.',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
        SettingsGroup(
          title: 'Ajustes',
          children: [
            link(
              Icons.text_fields_rounded,
              c.tintViolet,
              c.inkViolet,
              'Accesibilidad',
              AppRoutes.accessibility,
            ),
            link(
              Icons.contrast_rounded,
              c.tintViolet,
              c.inkViolet,
              'Tema y colores',
              AppRoutes.theme,
            ),
            link(
              Icons.verified_user_rounded,
              c.tintMint,
              c.inkMint,
              'Privacidad',
              AppRoutes.privacy,
            ),
            link(
              Icons.help_outline_rounded,
              c.tintTeal,
              c.inkTeal,
              'Ayuda',
              AppRoutes.help,
            ),
          ],
        ),
        const SectionTitle('¿Cómo obtengo una cuenta?'),
        OkCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _HowRow(
                icon: Icons.school_rounded,
                bold: 'Si tu escuela usa Órbita Kids:',
                text: ' tu maestra te da un usuario o un código de grupo.',
                bg: c.tintViolet,
                fg: c.inkViolet,
              ),
              Gap.h12,
              _HowRow(
                icon: Icons.family_restroom_rounded,
                bold: 'Si no:',
                text: ' un adulto responsable puede crear la cuenta y vincularla.',
                bg: c.tintMint,
                fg: c.inkMint,
              ),
              Gap.h8,
              TextButton.icon(
                onPressed: () => leaveGuestTo(ref, AppRoutes.register),
                icon: const Icon(Icons.person_outline_rounded),
                label: const Text('Crear cuenta (para adultos)'),
              ),
            ],
          ),
        ),
        Gap.h16,
        FilledButton.icon(
          onPressed: () => leaveGuestTo(ref, AppRoutes.login),
          icon: const Icon(Icons.key_rounded),
          label: const Text('Ya tengo cuenta: iniciar sesión'),
        ),
        Gap.h8,
        TextButton.icon(
          onPressed: () async {
            final ok = await confirm(
              context,
              title: '¿Salir del modo explorar?',
              text: 'Lo que hiciste mientras explorabas se borra.',
              ok: 'Salir',
              cancel: 'Seguir explorando',
            );
            if (ok) leaveGuestTo(ref, AppRoutes.login);
          },
          icon: const Icon(Icons.logout_rounded),
          label: const Text('Salir del modo explorar'),
        ),
      ],
    );
  }
}

class _HowRow extends StatelessWidget {
  const _HowRow({
    required this.icon,
    required this.bold,
    required this.text,
    required this.bg,
    required this.fg,
  });
  final IconData icon;
  final String bold;
  final String text;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      IconBox(icon, bg: bg, fg: fg, size: 34),
      Gap.w10,
      Expanded(
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: bold,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              TextSpan(text: text),
            ],
          ),
        ),
      ),
    ],
  );
}

/// 57 · Disponible con cuenta (progreso, tareas o perfil sin cuenta).
class GuestLockedScreen extends StatelessWidget {
  const GuestLockedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.ok;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton.filledTonal(
                  tooltip: 'Regresar',
                  onPressed: () => context.canPop()
                      ? context.pop()
                      : context.go(AppRoutes.guestHome),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
              ),
              const Spacer(),
              const Center(child: Mascot.orbi(pose: 'think', size: 130)),
              Gap.h12,
              Semantics(
                header: true,
                child: Text(
                  'Tu progreso está disponible con una cuenta',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              Gap.h8,
              Text(
                'Las estrellas, el historial y el gráfico se guardan cuando tienes una cuenta de tu escuela.',
                textAlign: TextAlign.center,
                style: TextStyle(color: c.muted, fontSize: 15),
              ),
              Gap.h20,
              FilledButton(
                onPressed: () => context.go(AppRoutes.guestHome),
                child: const Text('Seguir explorando'),
              ),
              Gap.h6,
              TextButton(
                onPressed: () => context.go(AppRoutes.guestMore),
                child: const Text('Cómo obtener una cuenta'),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}
