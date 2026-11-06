import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:orbita_kids/config/routes/app_routes.dart';
import 'package:orbita_kids/core/error/failures.dart';
import 'package:orbita_kids/core/network/connectivity.dart';
import 'package:orbita_kids/config/providers/core_providers.dart';
import 'package:orbita_kids/features/settings/presentation/providers/settings_controller.dart';
import 'package:orbita_kids/shared/presentation/art/mascot.dart';
import 'package:orbita_kids/shared/presentation/widgets/ui.dart';
import 'package:orbita_kids/features/auth/providers/auth_providers.dart';
import 'package:orbita_kids/features/auth/domain/entities/auth_entities.dart';
import 'package:orbita_kids/features/auth/presentation/widgets/auth_ui.dart';

final _userRe = RegExp(r'^[a-z0-9._]{3,}$', caseSensitive: false);
final _mailRe = RegExp(r'^\S+@\S+\.\S+$');

/// 10 · Registro de estudiante (5 pasos) o docente (4 pasos).
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  String? who; // 'est' | 'prof'
  int step = 1;
  bool done = false;
  final e = <String, String>{};

  // Estudiante
  String? groupName;
  final name = TextEditingController();
  final user = TextEditingController();
  final pass = TextEditingController();
  final pass2 = TextEditingController();
  String? method;
  AvatarLook look = const AvatarLook(
    character: 'teo',
    helmet: 'turquesa',
    accessory: 'ninguno',
  );
  bool adultOk = false;

  // Docente
  final mail = TextEditingController();
  final inst = TextEditingController();
  String code = '';

  @override
  void dispose() {
    for (final c in [name, user, pass, pass2, mail, inst]) {
      c.dispose();
    }
    super.dispose();
  }

  bool get est => who == 'est';
  int get total => est ? 5 : 4;

  List<(IconData, String)> get labels => est
      ? const [
          (Icons.key_rounded, 'Código'),
          (Icons.person_rounded, 'Nombre'),
          (Icons.lock_rounded, 'Acceso'),
          (Icons.brush_rounded, 'Astronauta'),
          (Icons.check_rounded, 'Confirmar'),
        ]
      : const [
          (Icons.person_rounded, 'Datos'),
          (Icons.key_rounded, 'Acceso'),
          (Icons.mail_rounded, 'Verificar'),
          (Icons.shield_rounded, 'Permisos'),
        ];

  List<String> get tips => est
      ? const [
          'Pide el código de grupo a tu maestra o a tu escuela.',
          'Usa solo tu nombre o un apodo. ¡Nada de apellidos!',
          'Elige cómo vas a entrar a Órbita Kids.',
          '¡Diseña a tu astronauta! Luego podrás cambiarlo.',
          'Un adulto te ayuda a revisar y confirmar.',
        ]
      : const [
          'Usa tu correo institucional.',
          'Elige tu método de acceso.',
          'Revisa tu correo y escribe el código.',
          'Tu institución autoriza el acceso docente.',
        ];

  Future<void> _next() async {
    // El dominio decide si el usuario ya existe (demo: cuentas ficticias).
    final taken = who == 'est' && step == 2 && user.text.trim().isNotEmpty
        ? await ref.read(isUsernameTakenProvider).call(user.text)
        : false;
    if (!mounted) return;
    e.clear();
    if (!ref.read(onlineProvider)) {
      context.push(AppRoutes.authState('network', method: 'orbita'));
      return;
    }
    final demo = ref.read(appConfigProvider).isDemo;
    if (est) {
      if (step == 1 && groupName == null) {
        e['g'] = 'Primero valida el código de grupo.';
      }
      if (step == 2) {
        if (name.text.trim().isEmpty) e['n'] = 'Escribe cómo te llamamos.';
        if (user.text.trim().isEmpty) {
          e['u'] = 'Elige un nombre de usuario.';
        } else if (taken) {
          e['u'] = 'Ese nombre ya está en uso. Prueba con otro.';
        } else if (!_userRe.hasMatch(user.text.trim())) {
          e['u'] = 'Usa al menos 3 letras, números, punto o guion bajo.';
        }
      }
      if (step == 3) {
        if (method == null) {
          e['m'] = 'Elige cómo vas a entrar.';
        } else if (method == 'orbita') {
          if (!PasswordRules.valid(pass.text, 8)) {
            e['p'] = 'La contraseña aún no cumple las reglas.';
          }
          if (pass2.text != pass.text) {
            e['p2'] = 'Las contraseñas no son iguales.';
          }
        }
      }
      if (step == 5) {
        if (!adultOk) e['t'] = 'Pide a un adulto que te ayude con este paso.';
        if (e.isEmpty) return setState(() => done = true);
      }
    } else {
      if (step == 1) {
        if (name.text.trim().isEmpty) e['n'] = 'Escribe tu nombre.';
        if (!_mailRe.hasMatch(mail.text.trim())) {
          e['mail'] = 'Escribe un correo institucional válido.';
        }
      }
      if (step == 2) {
        if (method == null) e['m'] = 'Elige un método de acceso.';
        if (e.isEmpty && !demo) {
          // Con Keycloak: la cuenta y la verificación se hacen en Keycloak.
          runKeycloakSignIn(ref, switch (method) {
            'google' => AuthMethod.google,
            'facebook' => AuthMethod.facebook,
            'inst' => AuthMethod.institution,
            _ => AuthMethod.orbita,
          }, register: method == 'orbita');
          return;
        }
      }
      if (step == 3 && code != ref.read(demoDirectoryProvider).unlockCode) {
        e['code'] = code.length < 6
            ? 'Escribe los 6 números.'
            : 'El código no coincide. Revísalo.';
      }
      if (step == 4) {
        if (!adultOk) e['t'] = 'Debes aceptar las condiciones para continuar.';
        if (e.isEmpty) return setState(() => done = true);
      }
    }
    setState(() {
      if (e.isEmpty) step++;
    });
  }

  void _back() => setState(() {
    e.clear();
    if (step > 1) {
      step--;
    } else {
      who = null;
    }
  });

  @override
  Widget build(BuildContext context) {
    final online = ref.watch(onlineProvider);
    final c = context.ok;
    if (who == null) {
      return OkPage(
        title: 'Crear cuenta',
        subtitle: 'Únete a la tripulación de Órbita Kids',
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              BrandLogo(width: 150),
              Mascot.orbi(pose: 'wave', size: 96),
            ],
          ),
          const DemoModeBanner(compact: true),
          if (!online) ...[
            Gap.h10,
            const InfoBanner(
              icon: Icons.wifi_off_rounded,
              text: 'Sin conexión. El registro necesita Internet.',
            ),
          ],
          const SectionTitle('¿Quién eres?'),
          _WhoCard(
            enabled: online,
            art: const Mascot(
              look: AvatarLook(character: 'teo', helmet: 'turquesa'),
              pose: 'celebrate',
              size: 84,
            ),
            title: 'Soy estudiante',
            text: 'Con el código de tu clase y la ayuda de un adulto. ¡Elige tu astronauta!',
            color: c.tintViolet,
            onTap: () => setState(() => who = 'est'),
          ),
          Gap.h10,
          _WhoCard(
            enabled: online,
            art: Icon(Icons.assignment_rounded, size: 52, color: c.inkTeal),
            title: 'Soy docente',
            text: 'Con tu correo institucional. Tu escuela autoriza el acceso.',
            color: c.tintTeal,
            onTap: () => setState(() => who = 'prof'),
          ),
          Gap.h14,
          const InfoBanner(
            icon: Icons.shield_outlined,
            text: 'Tu rol no se elige aquí: lo asigna el servidor según tu escuela y tu licencia.',
          ),
          Gap.h8,
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Ya tengo cuenta'),
          ),
        ],
      );
    }
    if (done) return _doneView(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: OkPage(
        title: est ? 'Registro de estudiante' : 'Registro docente',
        subtitle: 'Paso $step de $total · ${labels[step - 1].$2}',
        children: [
          _Stepper(labels: labels, step: step),
          Gap.h12,
          OrbiSays(
            text: tips[step - 1],
            pose: const [
              'think',
              'wave',
              'point',
              'celebrate',
              'learn',
            ][step - 1],
            size: 64,
          ),
          if (!online) ...[
            Gap.h10,
            const InfoBanner(
              icon: Icons.wifi_off_rounded,
              text: 'Sin conexión. Podrás terminar el registro cuando vuelva Internet.',
            ),
          ],
          Gap.h16,
          ...est ? _studentStep(context) : _teacherStep(context),
          Gap.h20,
          Row(
            children: [
              SizedBox(
                width: 80,
                child: OutlinedButton(
                  onPressed: _back,
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    semanticLabel: 'Paso anterior',
                  ),
                ),
              ),
              Gap.w10,
              Expanded(
                child: FilledButton(
                  onPressed: _next,
                  child: Text(
                    est && step == 5
                        ? 'Crear cuenta'
                        : !est && step == 4
                        ? 'Enviar solicitud'
                        : !est && step == 3
                        ? 'Verificar'
                        : 'Continuar',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _err(String k) => e[k] == null
      ? const SizedBox.shrink()
      : Padding(
          padding: const EdgeInsets.only(top: 8),
          child: InfoBanner(
            tone: Tone.err,
            icon: Icons.error_outline_rounded,
            text: e[k]!,
          ),
        );

  Widget _methodCard(String id, Widget icon, String title, String sub) {
    final c = context.ok;
    final on = method == id;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Semantics(
        selected: on,
        child: OkCard(
          color: on ? c.tintViolet : null,
          onTap: () => setState(() => method = id),
          child: Row(
            children: [
              SizedBox(width: 32, child: icon),
              Gap.w10,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    if (sub.isNotEmpty)
                      Text(sub, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              Icon(
                on
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: c.purpleDark,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _studentStep(BuildContext context) {
    final t = Theme.of(context).textTheme;
    switch (step) {
      case 1:
        return [
          Text('Código de grupo', style: t.titleLarge),
          Gap.h6,
          const Text(
            'Lo entrega tu escuela o tu maestra. Se valida contra la licencia de la escuela.',
          ),
          if (groupName != null) ...[
            Gap.h12,
            InfoBanner(
              tone: Tone.ok,
              icon: Icons.check_circle_rounded,
              text: 'Te unirás a $groupName.',
            ),
          ],
          Gap.h12,
          FilledButton.icon(
            onPressed: () async {
              final g = await context.push<String>(AppRoutes.registerCode);
              if (g != null) setState(() => groupName = g);
            },
            icon: const Icon(Icons.key_rounded),
            label: Text(
              groupName == null ? 'Escribir código de grupo' : 'Cambiar código',
            ),
          ),
          _err('g'),
        ];
      case 2:
        return [
          Text('¿Cómo te llamamos?', style: t.titleLarge),
          Gap.h12,
          TextField(
            controller: name,
            decoration: InputDecoration(
              labelText: 'Nombre de uso',
              hintText: 'Tu nombre o apodo',
              helperText: 'Solo tu nombre de pila o un apodo. Sin apellidos.',
              errorText: e['n'],
            ),
          ),
          Gap.h12,
          TextField(
            controller: user,
            decoration: InputDecoration(
              labelText: 'Nombre de usuario',
              hintText: 'ej. teo.cohete',
              prefixIcon: const Icon(Icons.person_outline_rounded),
              errorText: e['u'],
            ),
          ),
        ];
      case 3:
        return [
          Text('¿Cómo vas a entrar?', style: t.titleLarge),
          Gap.h12,
          _methodCard(
            'orbita',
            const Icon(Icons.rocket_launch_rounded),
            'Usuario y contraseña Órbita Kids',
            'Una cuenta administrada por tu escuela.',
          ),
          _methodCard(
            'inst',
            const Icon(Icons.school_rounded),
            'Cuenta de mi escuela',
            'Si tu escuela tiene acceso institucional.',
          ),
          _methodCard(
            'adult',
            const Icon(Icons.family_restroom_rounded),
            'Un adulto vincula su Google o Facebook',
            'El adulto entra y administra tu acceso.',
          ),
          if (method == 'orbita') ...[
            Gap.h8,
            PasswordField(
              controller: pass,
              errorText: e['p'],
              autofill: AutofillHints.newPassword,
            ),
            Gap.h6,
            ListenableBuilder(
              listenable: pass,
              builder: (_, _) => PasswordRules(value: pass.text),
            ),
            Gap.h10,
            PasswordField(
              controller: pass2,
              label: 'Repite la contraseña',
              errorText: e['p2'],
              autofill: AutofillHints.newPassword,
            ),
          ],
          _err('m'),
        ];
      case 4:
        final s = ref.watch(settingsProvider);
        return [
          Text('Elige tu astronauta', style: t.titleLarge),
          Center(
            child: Mascot(look: look, pose: 'wave', size: 130),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final ch in AvatarCatalog.all)
                ChoiceChip(
                  label: Text(ch.name),
                  selected: look.character == ch.id,
                  onSelected: (_) =>
                      setState(() => look = look.copyWith(character: ch.id)),
                ),
            ],
          ),
          Gap.h10,
          Wrap(
            spacing: 12,
            children: [
              for (final h in AvatarCatalog.helmets)
                _ColorDot(
                  color: h.$3,
                  label: 'Casco ${h.$2}',
                  selected: look.helmet == h.$1,
                  onTap: () =>
                      setState(() => look = look.copyWith(helmet: h.$1)),
                ),
            ],
          ),
          const SectionTitle('Preferencias iniciales'),
          SettingsGroup(
            children: [
              SwitchListTile(
                secondary: const Icon(Icons.text_increase_rounded),
                title: const Text('Letra más grande'),
                value: s.textScale > 1,
                onChanged: (v) => ref
                    .read(settingsProvider.notifier)
                    .update((x) => x.copyWith(textScale: v ? 1.15 : 1)),
              ),
              SwitchListTile(
                secondary: const Icon(Icons.volume_up_rounded),
                title: const Text('Leer instrucciones en voz alta'),
                value: s.readAloud,
                onChanged: (v) => ref
                    .read(settingsProvider.notifier)
                    .update((x) => x.copyWith(readAloud: v)),
              ),
              SwitchListTile(
                secondary: const Icon(Icons.dark_mode_rounded),
                title: const Text('Tema oscuro'),
                value: s.theme == AppThemeChoice.dark,
                onChanged: (v) => ref
                    .read(settingsProvider.notifier)
                    .update(
                      (x) => x.copyWith(
                        theme: v ? AppThemeChoice.dark : AppThemeChoice.light,
                      ),
                    ),
              ),
            ],
          ),
        ];
      default:
        return [
          Text('Revisa y confirma', style: t.titleLarge),
          Gap.h12,
          OkCard(
            child: Column(
              children: [
                for (final (a, b) in [
                  ('Grupo', groupName ?? '—'),
                  ('Nombre de uso', name.text),
                  ('Usuario', user.text),
                  (
                    'Acceso',
                    switch (method) {
                      'orbita' => 'Usuario y contraseña',
                      'inst' => 'Cuenta de la escuela',
                      _ => 'Vinculada por un adulto',
                    },
                  ),
                ])
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            a,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        Text(
                          b,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Gap.h10,
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            value: adultOk,
            onChanged: (v) => setState(() => adultOk = v ?? false),
            title: const Text(
              'Un adulto (mamá, papá, tutor o docente) me ayudó a leer y aceptar las condiciones y el aviso de privacidad.',
            ),
          ),
          Row(
            children: [
              TextButton(
                onPressed: () => context.push(AppRoutes.terms),
                child: const Text('Leer condiciones'),
              ),
              TextButton(
                onPressed: () => context.push(AppRoutes.privacy),
                child: const Text('Leer privacidad'),
              ),
            ],
          ),
          _err('t'),
        ];
    }
  }

  List<Widget> _teacherStep(BuildContext context) {
    final t = Theme.of(context).textTheme;
    switch (step) {
      case 1:
        return [
          Text('Tus datos', style: t.titleLarge),
          Gap.h12,
          TextField(
            controller: name,
            decoration: InputDecoration(
              labelText: 'Nombre',
              hintText: 'ej. Ana Ríos',
              errorText: e['n'],
            ),
          ),
          Gap.h12,
          TextField(
            controller: mail,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            decoration: InputDecoration(
              labelText: 'Correo institucional',
              hintText: 'nombre@escuela.example',
              prefixIcon: const Icon(Icons.mail_outline_rounded),
              errorText: e['mail'],
            ),
          ),
          Gap.h12,
          TextField(
            controller: inst,
            decoration: const InputDecoration(
              labelText: 'Institución (si corresponde)',
            ),
          ),
        ];
      case 2:
        return [
          Text('Método de acceso', style: t.titleLarge),
          Gap.h12,
          _methodCard(
            'inst',
            const Icon(Icons.school_rounded),
            'Mi institución',
            '',
          ),
          _methodCard('google', const GoogleLogo(), 'Google', ''),
          _methodCard('facebook', const FacebookLogo(), 'Facebook', ''),
          _methodCard(
            'orbita',
            const Icon(Icons.rocket_launch_rounded),
            'Cuenta Órbita Kids',
            '',
          ),
          _err('m'),
        ];
      case 3:
        return [
          Text('Confirma tu identidad', style: t.titleLarge),
          Gap.h6,
          Text('Enviamos un código de 6 dígitos a ${mail.text}.'),
          Gap.h6,
          const DemoModeBanner(compact: true),
          Text(
            'Código de demostración: ${ref.watch(demoDirectoryProvider).unlockCode}',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          Gap.h14,
          CodeBoxes(onChanged: (v) => code = v, error: e['code'] != null),
          _err('code'),
        ];
      default:
        return [
          Text('Permisos docentes', style: t.titleLarge),
          Gap.h6,
          Text(
            'El acceso docente lo autoriza tu institución. Enviaremos tu solicitud a ${inst.text.isEmpty ? 'tu institución' : inst.text}.',
          ),
          Gap.h12,
          OkCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Permisos que solicitarás',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                for (final p in const [
                  'Ver tus grupos y estudiantes',
                  'Crear y publicar actividades',
                  'Consultar resultados y reportes',
                ])
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
                      children: [
                        Icon(Icons.check_rounded, color: context.ok.ok),
                        Gap.w8,
                        Expanded(child: Text(p)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            value: adultOk,
            onChanged: (v) => setState(() => adultOk = v ?? false),
            title: const Text(
              'Acepto las condiciones de uso y el aviso de privacidad.',
            ),
          ),
          _err('t'),
        ];
    }
  }

  Widget _doneView(BuildContext context) {
    final c = context.ok;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (est) Mascot(look: look, pose: 'celebrate', size: 130),
                    const Mascot.orbi(pose: 'jump', size: 90),
                  ],
                ),
                Gap.h12,
                Text(
                  est ? '¡Ya eres parte de la tripulación!' : 'Solicitud lista',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Gap.h8,
                Text(
                  est
                      ? 'Te uniste a ${groupName ?? ''}. Entra con tu usuario ${user.text}.'
                      : '${inst.text.isEmpty ? 'Tu institución' : inst.text} debe autorizar tu acceso docente; te avisaremos por correo.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: c.muted, fontSize: 16),
                ),
                Gap.h14,
                const InfoBanner(
                  icon: Icons.science_rounded,
                  tone: Tone.warn,
                  text: 'Demostración: la cuenta no se guardó en ningún servidor.',
                ),
                Gap.h16,
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => context.go(AppRoutes.login),
                    child: const Text('Ir a iniciar sesión'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WhoCard extends StatelessWidget {
  const _WhoCard({
    required this.art,
    required this.title,
    required this.text,
    required this.color,
    required this.onTap,
    required this.enabled,
  });

  final Widget art;
  final String title;
  final String text;
  final Color color;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) => Opacity(
    opacity: enabled ? 1 : .5,
    child: OkCard(
      color: color,
      onTap: enabled ? onTap : null,
      child: Row(
        children: [
          SizedBox(width: 90, child: Center(child: art)),
          Gap.w12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                Gap.h4,
                Text(text),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _Stepper extends StatelessWidget {
  const _Stepper({required this.labels, required this.step});
  final List<(IconData, String)> labels;
  final int step;

  @override
  Widget build(BuildContext context) {
    final c = context.ok;
    return Semantics(
      label: 'Paso $step de ${labels.length}',
      excludeSemantics: true,
      child: Row(
        children: [
          for (var k = 0; k < labels.length; k++)
            Expanded(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: k + 1 < step
                        ? c.ok
                        : k + 1 == step
                        ? Brand.purple
                        : c.tintGray,
                    child: Icon(
                      k + 1 < step ? Icons.check_rounded : labels[k].$1,
                      size: 18,
                      color: k + 1 <= step ? Colors.white : c.muted,
                    ),
                  ),
                  Gap.h4,
                  Text(
                    labels[k].$2,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: c.muted,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({
    required this.color,
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final Color color;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    label: label,
    excludeSemantics: true,
    child: InkResponse(
      onTap: onTap,
      radius: 30,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? context.ok.ink : context.ok.card,
            width: 4,
          ),
        ),
        child: selected
            ? const Icon(Icons.check_rounded, color: Colors.white)
            : null,
      ),
    ),
  );
}

/// 11 · Código de grupo. Devuelve el nombre del grupo al validar.
class GroupCodeScreen extends ConsumerStatefulWidget {
  const GroupCodeScreen({super.key});

  @override
  ConsumerState<GroupCodeScreen> createState() => _GroupCodeScreenState();
}

class _GroupCodeScreenState extends ConsumerState<GroupCodeScreen> {
  final ctrl = TextEditingController();
  String? err;
  String? found;

  @override
  void dispose() {
    ctrl.dispose();
    super.dispose();
  }

  Future<void> _validate() async {
    setState(() {
      err = null;
      found = null;
    });
    try {
      final r = await ref
          .read(validateGroupCodeProvider)
          .call(ctrl.text, online: ref.read(onlineProvider));
      if (!mounted) return;
      setState(() {
        found = r.groupName;
        err = r.error;
      });
    } on BackendUnavailable {
      if (!mounted) return;
      setState(
        () => err = 'La validación de códigos contra la licencia necesita el servidor de Órbita Kids, que aún no está disponible.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.ok;
    return OkPage(
      title: 'Código de grupo',
      subtitle: 'Únete a tu clase',
      children: [
        const DemoModeBanner(compact: true),
        Gap.h12,
        TextField(
          controller: ctrl,
          textCapitalization: TextCapitalization.characters,
          style: AppTextStyles.number(22, color: c.ink),
          decoration: InputDecoration(
            labelText: 'Código',
            hintText: 'ORB-2A7K',
            prefixIcon: const Icon(Icons.key_rounded),
            errorText: err,
            errorMaxLines: 3,
          ),
          onSubmitted: (_) => _validate(),
        ),
        Gap.h6,
        Text(
          'Códigos de demostración: ORB-2A7K (válido), ORB-OLD1 (vencido), ORB-1C2P (grupo archivado), ORB-FULL (sin lugares).',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Gap.h12,
        FilledButton(onPressed: _validate, child: const Text('Validar')),
        if (found != null) ...[
          Gap.h16,
          OkCard(
            color: c.okBg,
            child: Row(
              children: [
                Icon(Icons.groups_rounded, color: c.ok, size: 34),
                Gap.w12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Grupo $found',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Text(
                        'Escuela Primaria Demo Órbita · Mtra. Ana Ríos',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Gap.h12,
          FilledButton.icon(
            onPressed: () => context.pop(found),
            icon: const Icon(Icons.check_rounded),
            label: const Text('Continuar'),
          ),
        ],
      ],
    );
  }
}
