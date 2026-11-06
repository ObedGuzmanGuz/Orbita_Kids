import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:orbita_kids/config/routes/app_routes.dart';
import 'package:orbita_kids/core/network/connectivity.dart';
import 'package:orbita_kids/config/providers/core_providers.dart';
import 'package:orbita_kids/shared/presentation/art/mascot.dart';
import 'package:orbita_kids/shared/presentation/art/space_art.dart';
import 'package:orbita_kids/shared/presentation/widgets/ui.dart';
import 'package:orbita_kids/features/auth/presentation/providers/auth_controller.dart';
import 'package:orbita_kids/features/auth/domain/entities/auth_entities.dart';
import 'package:orbita_kids/features/auth/presentation/widgets/auth_ui.dart';

/// 05 · Inicio de sesión (Keycloak). El rol lo asigna el servidor.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _user = TextEditingController();
  final _pass = TextEditingController();
  bool managed = false;
  bool remember = true;
  bool busy = false;
  String? errUser, errPass, err;

  @override
  void dispose() {
    _user.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final ctrl = ref.read(authControllerProvider.notifier);
    if (ctrl.isLocked) return context.push(AppRoutes.lock).then((_) {});
    setState(() {
      err = null;
      errUser = _user.text.trim().isEmpty ? 'Escribe tu usuario.' : null;
      errPass = _pass.text.isEmpty ? 'Escribe tu contraseña.' : null;
    });
    if (errUser != null || errPass != null) return;
    if (!ref.read(onlineProvider)) {
      context.push(AppRoutes.authState('network', method: 'orbita'));
      return;
    }
    setState(() => busy = true);
    try {
      await ctrl.signInWithPassword(_user.text, _pass.text, remember: remember);
      goHomeAfterDemoSignIn(ref);
    } on InvalidCredentials catch (e) {
      _pass.clear();
      setState(
        () => err =
            'El usuario o la contraseña no coinciden. Te ${e.remaining == 1 ? 'queda 1 intento' : 'quedan ${e.remaining} intentos'}.',
      );
    } on AccountLocked {
      _pass.clear();
      if (mounted) context.push(AppRoutes.lock);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  void _idp(AuthMethod m) {
    final demo = ref.read(appConfigProvider).isDemo;
    if (m == AuthMethod.institution) {
      context.push(AppRoutes.institution);
    } else if (demo) {
      context.push(AppRoutes.demoProvider(m.name));
    } else {
      runKeycloakSignIn(ref, m, remember: remember);
    }
  }

  @override
  Widget build(BuildContext context) {
    final online = ref.watch(onlineProvider);
    final demo = ref.watch(appConfigProvider).isDemo;
    const lav = Brand.lavenderText;
    final linkStyle = TextButton.styleFrom(foregroundColor: Brand.lavender);

    return Scaffold(
      backgroundColor: Brand.indigo,
      body: SpaceBackground(
        seed: 3,
        stars: 24,
        child: SafeArea(
          child: AutofillGroup(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              children: [
                const Center(child: BrandLogo(width: 210)),
                Gap.h6,
                Semantics(
                  header: true,
                  child: Text(
                    '¡Bienvenido a bordo!',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium
                        ?.copyWith(color: Colors.white),
                  ),
                ),
                Gap.h4,
                const Text(
                  'Elige cómo quieres entrar.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: lav, fontSize: 15),
                ),
                Gap.h14,
                const DemoModeBanner(),
                if (!online) ...[
                  Gap.h12,
                  const InfoBanner(
                    icon: Icons.wifi_off_rounded,
                    text: 'Sin conexión. Para entrar por primera vez se necesita Internet. Si ya entraste antes en este teléfono, tu sesión guardada se abre sola.',
                  ),
                ],
                if (err != null) ...[
                  Gap.h12,
                  InfoBanner(
                    tone: Tone.err,
                    icon: Icons.error_outline_rounded,
                    text: err!,
                  ),
                ],
                Gap.h14,
                IdpButton(
                  logo: const GoogleLogo(),
                  label: 'Continuar con Google',
                  sub: 'Docentes y adultos responsables',
                  enabled: online,
                  onTap: () => _idp(AuthMethod.google),
                ),
                Gap.h10,
                IdpButton(
                  logo: const FacebookLogo(),
                  label: 'Continuar con Facebook',
                  sub: 'Docentes y adultos responsables',
                  enabled: online,
                  onTap: () => _idp(AuthMethod.facebook),
                ),
                Gap.h10,
                IdpButton(
                  logo: const Icon(
                    Icons.school_rounded,
                    color: Color(0xFF4D44C4),
                    size: 26,
                  ),
                  label: 'Acceder con mi institución',
                  sub: 'Google Workspace, Microsoft Entra ID y otros',
                  enabled: online,
                  onTap: () => _idp(AuthMethod.institution),
                ),
                Gap.h16,
                const Row(
                  children: [
                    Expanded(child: Divider(color: Colors.white24)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        'o',
                        style: TextStyle(
                          color: lav,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.white24)),
                  ],
                ),
                Gap.h12,
                if (!demo)
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: .14),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: online
                        ? () => runKeycloakSignIn(
                            ref,
                            AuthMethod.orbita,
                            remember: remember,
                          )
                        : null,
                    icon: const Icon(Icons.rocket_launch_rounded),
                    label: const Text('Entrar con cuenta Órbita Kids'),
                  )
                else if (!managed)
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: .14),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => setState(() => managed = true),
                    icon: const Icon(Icons.rocket_launch_rounded),
                    label: const Text('Entrar con cuenta Órbita Kids'),
                  )
                else
                  Theme(
                    data: Theme.of(context).copyWith(
                      inputDecorationTheme: Theme.of(context)
                          .inputDecorationTheme
                          .copyWith(
                            fillColor: Colors.white,
                            labelStyle: const TextStyle(
                              color: Color(0xFF66638A),
                              fontWeight: FontWeight.w700,
                            ),
                            prefixIconColor: const Color(0xFF66638A),
                            suffixIconColor: const Color(0xFF66638A),
                            errorStyle: const TextStyle(
                              color: Color(0xFFFFC2CC),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                    ),
                    child: DefaultTextStyle.merge(
                      style: const TextStyle(color: Brand.ink),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextField(
                            controller: _user,
                            style: const TextStyle(color: Brand.ink),
                            autofillHints: const [AutofillHints.username],
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: 'Usuario Órbita Kids',
                              hintText: 'ej. luna.astro',
                              errorText: errUser,
                              prefixIcon: const Icon(
                                Icons.person_outline_rounded,
                              ),
                            ),
                          ),
                          Gap.h10,
                          PasswordField(
                            controller: _pass,
                            errorText: errPass,
                            style: const TextStyle(color: Brand.ink),
                            onSubmitted: (_) => _submit(),
                          ),
                          Gap.h12,
                          FilledButton(
                            onPressed: busy ? null : _submit,
                            child: busy
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                    ),
                                  )
                                : const Text('Entrar'),
                          ),
                          Gap.h8,
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Brand.lavender,
                              side: const BorderSide(
                                color: Colors.white30,
                                width: 2,
                              ),
                            ),
                            onPressed: () => _pickDemo(context),
                            icon: const Icon(Icons.science_outlined),
                            label: const Text('Usar cuenta de demostración'),
                          ),
                        ],
                      ),
                    ),
                  ),
                Gap.h6,
                Theme(
                  data: Theme.of(context)
                      .copyWith(unselectedWidgetColor: Colors.white70),
                  child: CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    value: remember,
                    onChanged: (v) => setState(() => remember = v ?? true),
                    side: const BorderSide(color: Colors.white70, width: 2),
                    title: const Text(
                      'Mantener la sesión en este teléfono',
                      style: TextStyle(color: lav, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white38, width: 2),
                  ),
                  onPressed: () => context.push(AppRoutes.explore),
                  icon: const Icon(Icons.visibility_rounded),
                  label: const Text('Explorar sin cuenta'),
                ),
                Gap.h12,
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .1),
                    borderRadius: AppRadius.card,
                  ),
                  child: const Row(
                    children: [
                      Mascot.orbi(pose: 'point', size: 54, semanticLabel: null),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '¿Eres estudiante? ',
                                style: TextStyle(fontWeight: FontWeight.w900),
                              ),
                              TextSpan(
                                text: 'Entra con la cuenta que te dio tu escuela o pide ayuda a un adulto. No necesitas redes sociales.',
                              ),
                            ],
                          ),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Gap.h6,
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  children: [
                    TextButton(
                      style: linkStyle,
                      onPressed: () => context.push(AppRoutes.recover),
                      child: const Text('¿Problemas para entrar?'),
                    ),
                    TextButton(
                      style: linkStyle,
                      onPressed: () => context.push(AppRoutes.register),
                      child: const Text('Crear cuenta'),
                    ),
                  ],
                ),
                Gap.h4,
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      size: 15,
                      color: Color(0xFFA9A5DA),
                    ),
                    SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Acceso protegido con Keycloak · OAuth 2.0 + PKCE',
                        style: TextStyle(
                          color: Color(0xFFA9A5DA),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    TextButton(
                      style: linkStyle,
                      onPressed: () => context.push(AppRoutes.privacy),
                      child: const Text('Privacidad'),
                    ),
                    TextButton(
                      style: linkStyle,
                      onPressed: () => context.push(AppRoutes.about),
                      child: const Text('Acerca de'),
                    ),
                    TextButton(
                      style: linkStyle,
                      onPressed: () => context.push(AppRoutes.aboutStudios),
                      child: const Text('Studios'),
                    ),
                    TextButton(
                      style: linkStyle,
                      onPressed: () => context.push(AppRoutes.accessibility),
                      child: const Text('Accesibilidad'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDemo(BuildContext context) async {
    final pick = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Cuentas de demostración',
                style: Theme.of(ctx).textTheme.titleLarge,
              ),
              Gap.h4,
              Text(
                'Contraseña de ambas: orbita123',
                style: Theme.of(ctx).textTheme.bodySmall,
              ),
              Gap.h12,
              OkListTile(
                leading: const Mascot(
                  look: AvatarLook(),
                  pose: 'stand',
                  size: 40,
                ),
                title: 'Luna · estudiante',
                subtitle: 'luna.astro · 2° A',
                onTap: () => Navigator.pop(ctx, 'luna.astro'),
              ),
              Gap.h8,
              OkListTile(
                leading: const InitialsAvatar(
                  name: 'Ana Ríos',
                  color: Brand.turquoiseDark,
                ),
                title: 'Ana Ríos · docente',
                subtitle: 'ana.rios · 3 grupos',
                onTap: () => Navigator.pop(ctx, 'ana.rios'),
              ),
            ],
          ),
        ),
      ),
    );
    if (pick == null) return;
    _user.text = pick;
    _pass.text = 'orbita123';
    setState(() {});
  }
}
