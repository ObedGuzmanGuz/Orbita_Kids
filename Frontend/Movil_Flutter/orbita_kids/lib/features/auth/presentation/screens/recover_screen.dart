import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:orbita_kids/config/routes/app_routes.dart';
import 'package:orbita_kids/core/network/connectivity.dart';
import 'package:orbita_kids/config/providers/core_providers.dart';
import 'package:orbita_kids/shared/presentation/art/mascot.dart';
import 'package:orbita_kids/shared/presentation/widgets/ui.dart';
import 'package:orbita_kids/features/auth/domain/entities/auth_entities.dart';
import 'package:orbita_kids/features/auth/presentation/widgets/auth_ui.dart';

final _mailRe = RegExp(r'^\S+@\S+\.\S+$');

/// 12 · Recuperar cuenta (solo cuentas Órbita Kids).
class RecoverScreen extends ConsumerStatefulWidget {
  const RecoverScreen({super.key});

  @override
  ConsumerState<RecoverScreen> createState() => _RecoverScreenState();
}

class _RecoverScreenState extends ConsumerState<RecoverScreen> {
  int step = 1;
  final mail = TextEditingController();
  final p1 = TextEditingController();
  final p2 = TextEditingController();
  String? err, err2;

  @override
  void dispose() {
    mail.dispose();
    p1.dispose();
    p2.dispose();
    super.dispose();
  }

  void _send() {
    if (!ref.read(onlineProvider)) {
      context.push(AppRoutes.authState('network', method: 'orbita'));
      return;
    }
    if (!_mailRe.hasMatch(mail.text.trim())) {
      setState(() => err = 'Escribe un correo válido.');
      return;
    }
    setState(() {
      err = null;
      step = 2;
    });
  }

  void _save() {
    setState(() {
      err = PasswordRules.valid(p1.text, 8)
          ? null
          : 'La contraseña aún no cumple las reglas.';
      err2 = p2.text == p1.text ? null : 'Las contraseñas no son iguales.';
      if (err == null && err2 == null) step = 4;
    });
  }

  @override
  Widget build(BuildContext context) {
    final demo = ref.watch(appConfigProvider).isDemo;
    final c = context.ok;

    if (!demo) {
      // Con Keycloak la recuperación ocurre en su página segura
      // («¿Olvidaste tu contraseña?»), con su propio envío de correo.
      return OkPage(
        title: 'Recuperar cuenta',
        subtitle: 'Recupera el acceso de forma segura',
        children: [
          const Center(child: Mascot.orbi(pose: 'think', size: 120)),
          Gap.h12,
          const _ProviderNotice(),
          Gap.h14,
          const Text(
            'Para cuentas Órbita Kids, abriremos la página segura de inicio de sesión. Toca «¿Olvidaste tu contraseña?» y sigue los pasos que llegan a tu correo.',
            style: TextStyle(fontSize: 16),
          ),
          Gap.h16,
          FilledButton.icon(
            onPressed: () => runKeycloakSignIn(ref, AuthMethod.orbita),
            icon: const Icon(Icons.open_in_new_rounded),
            label: const Text('Abrir página segura'),
          ),
          Gap.h10,
          OutlinedButton(
            onPressed: () => context.pop(),
            child: const Text('Volver'),
          ),
        ],
      );
    }

    return OkPage(
      title: 'Recuperar cuenta',
      subtitle: 'Paso $step de 4',
      children: [
        // Avance en 4 segmentos, como en el mockup 12a.
        Semantics(
          label: 'Paso $step de 4',
          excludeSemantics: true,
          child: Row(
            children: [
              for (var k = 1; k <= 4; k++)
                Expanded(
                  child: Container(
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: k <= step ? Brand.purple : c.line,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Gap.h12,
        const DemoModeBanner(compact: true),
        Gap.h12,
        if (step == 1) ...[
          OkCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¿Cómo entras normalmente?',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Gap.h10,
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GoogleLogo(size: 18),
                    SizedBox(width: 4),
                    FacebookLogo(size: 18),
                    SizedBox(width: 4),
                    Icon(
                      Icons.school_rounded,
                      size: 20,
                      color: Brand.purpleDark,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Si entras con Google, Facebook o tu institución, recupera la contraseña en ese proveedor. Órbita Kids nunca la guarda.',
                      ),
                    ),
                  ],
                ),
                Gap.h12,
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Mascot(
                      look: AvatarLook(character: 'ari'),
                      pose: 'stand',
                      size: 36,
                      semanticLabel: null,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Estudiante con cuenta Órbita Kids: tu maestra puede restablecer tu contraseña desde su grupo.',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Gap.h16,
          const Text(
            'Cuenta Órbita Kids de docente o adulto:',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          Gap.h10,
          TextField(
            controller: mail,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            decoration: InputDecoration(
              labelText: 'Correo electrónico',
              hintText: 'nombre@escuela.example',
              prefixIcon: const Icon(Icons.mail_outline_rounded),
              errorText: err,
            ),
          ),
          Gap.h16,
          FilledButton(
            onPressed: _send,
            child: const Text('Enviar instrucciones'),
          ),
          Gap.h8,
          TextButton(
            onPressed: () => context.go(AppRoutes.login),
            child: const Text('Volver a iniciar sesión'),
          ),
        ],
        if (step == 2) ...[
          const Center(child: Mascot.orbi(pose: 'point', size: 120)),
          Text(
            'Revisa tu correo',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Gap.h8,
          Text(
            'Si ${mail.text.trim()} pertenece a una cuenta, enviaremos un enlace para crear una nueva contraseña.',
            textAlign: TextAlign.center,
            style: TextStyle(color: c.muted),
          ),
          Gap.h12,
          const InfoBanner(
            tone: Tone.warn,
            icon: Icons.science_rounded,
            text: 'Modo demo: no se envía ningún correo. Continúa para ver el siguiente paso.',
          ),
          Gap.h16,
          FilledButton(
            onPressed: () => setState(() => step = 3),
            child: const Text('Ya tengo el enlace'),
          ),
          Gap.h8,
          OutlinedButton(
            onPressed: () => toast(
              context,
              'Modo demo: no se envía ningún correo.',
              icon: Icons.mail_outline_rounded,
            ),
            child: const Text('Reenviar'),
          ),
        ],
        if (step == 3) ...[
          Text(
            'Crea una nueva contraseña',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Gap.h12,
          PasswordField(
            controller: p1,
            label: 'Nueva contraseña',
            errorText: err,
            autofill: AutofillHints.newPassword,
          ),
          Gap.h6,
          ListenableBuilder(
            listenable: p1,
            builder: (_, _) => PasswordRules(value: p1.text),
          ),
          Gap.h10,
          PasswordField(
            controller: p2,
            label: 'Repite la contraseña',
            errorText: err2,
            autofill: AutofillHints.newPassword,
          ),
          Gap.h16,
          FilledButton(
            onPressed: _save,
            child: const Text('Guardar contraseña'),
          ),
        ],
        if (step == 4) ...[
          const Center(child: Mascot.orbi(pose: 'celebrate', size: 130)),
          Text(
            '¡Listo!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          Gap.h8,
          Text(
            'Tu nueva contraseña quedó guardada. Ya puedes entrar.',
            textAlign: TextAlign.center,
            style: TextStyle(color: c.muted),
          ),
          Gap.h8,
          const InfoBanner(
            tone: Tone.warn,
            icon: Icons.science_rounded,
            text:
                'Demostración: la contraseña no se cambió en ningún servidor.',
          ),
          Gap.h16,
          FilledButton(
            onPressed: () => context.go(AppRoutes.login),
            child: const Text('Ir a iniciar sesión'),
          ),
        ],
      ],
    );
  }
}

class _ProviderNotice extends StatelessWidget {
  const _ProviderNotice();

  @override
  Widget build(BuildContext context) => const InfoBanner(
    icon: Icons.info_outline_rounded,
    text: 'Solo para cuentas Órbita Kids. Si entras con Google, Facebook o tu institución, recupera el acceso en ese proveedor.',
  );
}
