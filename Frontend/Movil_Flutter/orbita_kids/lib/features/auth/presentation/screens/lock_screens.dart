import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:orbita_kids/config/routes/app_routes.dart';
import 'package:orbita_kids/core/network/api_client.dart';
import 'package:orbita_kids/config/providers/core_providers.dart';
import 'package:orbita_kids/shared/presentation/art/mascot.dart';
import 'package:orbita_kids/shared/presentation/widgets/ui.dart';
import 'package:orbita_kids/features/auth/presentation/providers/auth_controller.dart';
import 'package:orbita_kids/features/auth/presentation/widgets/auth_ui.dart';

String _mmss(Duration d) {
  final s = d.inSeconds.clamp(0, 99 * 60);
  return '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';
}

/// 13 · Cuenta en pausa tras 3 intentos fallidos (15 min).
class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _t = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final until = ref.watch(authControllerProvider).lockedUntil;
    final now = ref.read(clockProvider)();
    final left = until == null ? Duration.zero : until.difference(now);
    final free = left <= Duration.zero;
    final c = context.ok;
    return OkPage(
      title: '',
      children: [
        Center(
          child: SizedBox(
            width: 200,
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.shield_rounded, size: 200, color: c.tintViolet),
                const Mascot.orbi(pose: 'think', size: 104),
                Positioned(
                  right: 30,
                  bottom: 24,
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: Brand.purple,
                      shape: BoxShape.circle,
                      border: Border.all(color: c.card, width: 5),
                    ),
                    child: const Icon(
                      Icons.lock_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Semantics(
          header: true,
          child: Text(
            free ? 'Ya puedes intentar de nuevo' : 'Tu cuenta está en pausa',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        Gap.h8,
        Text(
          'La contraseña se escribió mal 3 veces. Para cuidar tu cuenta, la pausamos un ratito. No pasa nada.',
          textAlign: TextAlign.center,
          style: TextStyle(color: c.muted, fontSize: 16),
        ),
        Gap.h18,
        OkCard(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.schedule_rounded, size: 30, color: c.purpleDark),
              Gap.w14,
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Podrás intentar de nuevo en',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Semantics(
                      label: 'Faltan ${left.inMinutes} minutos',
                      child: Text(
                        _mmss(left),
                        style: AppTextStyles.number(30, color: c.ink),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Gap.h18,
        FilledButton(
          onPressed: () => context.push(AppRoutes.unlock),
          child: const Text('Solicitar código de desbloqueo'),
        ),
        Gap.h10,
        OutlinedButton(
          onPressed: () => context.go(AppRoutes.login),
          child: const Text('Volver al inicio'),
        ),
        Gap.h12,
        Text(
          'El código llega al correo del docente (estudiantes) o a tu correo (docentes).',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

/// 14 · Código de desbloqueo de 6 dígitos.
class UnlockScreen extends ConsumerStatefulWidget {
  const UnlockScreen({super.key});

  @override
  ConsumerState<UnlockScreen> createState() => _UnlockScreenState();
}

class _UnlockScreenState extends ConsumerState<UnlockScreen> {
  String code = '';
  String? msg;
  bool ok = false;
  int wait = 30;
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _start();
  }

  void _start() {
    wait = 30;
    _t?.cancel();
    _t = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => wait--);
      if (wait <= 0) t.cancel();
    });
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  Future<void> _validate() async {
    if (code.length < 6) {
      setState(() {
        ok = false;
        msg = 'Escribe los 6 números.';
      });
      return;
    }
    try {
      final good = await ref
          .read(authControllerProvider.notifier)
          .unlockWithCode(code);
      setState(() {
        ok = good;
        msg = good
            ? '¡Listo! Tu cuenta ya está activa.'
            : 'El código no coincide. Revísalo.';
      });
      if (good && mounted) {
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            icon: const Mascot.orbi(pose: 'celebrate', size: 90),
            title: const Text('Cuenta desbloqueada'),
            content: const Text(
              'Ya puedes entrar otra vez. Si no recuerdas tu contraseña, pide ayuda a tu maestra.',
            ),
            actions: [
              FilledButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.go(AppRoutes.login);
                },
                child: const Text('Ir a iniciar sesión'),
              ),
            ],
          ),
        );
      }
    } on BackendUnavailable {
      setState(() {
        ok = false;
        msg = 'El desbloqueo con código necesita el servidor de Órbita Kids, que aún no está disponible. Espera los 15 minutos o pide ayuda a tu escuela.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.ok;
    final demo = ref.watch(appConfigProvider).isDemo;
    return OkPage(
      title: 'Código de desbloqueo',
      children: [
        Center(
          child: IconBox(
            Icons.shield_rounded,
            bg: c.tintViolet,
            fg: c.purpleDark,
            size: 110,
          ),
        ),
        Gap.h12,
        Text(
          'Escribe los 6 números que enviamos. El código dura 10 minutos.',
          textAlign: TextAlign.center,
          style: TextStyle(color: c.muted, fontSize: 16),
        ),
        if (demo) ...[
          Gap.h10,
          const DemoModeBanner(compact: true),
          Gap.h6,
          Text(
            'Código de demostración: ${ref.watch(demoDirectoryProvider).unlockCode}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ],
        Gap.h18,
        CodeBoxes(onChanged: (v) => code = v, error: msg != null && !ok),
        Gap.h12,
        if (msg != null)
          InfoBanner(
            tone: ok ? Tone.ok : Tone.err,
            icon: ok ? Icons.check_circle_rounded : Icons.error_outline_rounded,
            text: msg!,
          ),
        Gap.h18,
        FilledButton(onPressed: _validate, child: const Text('Validar código')),
        Gap.h10,
        OutlinedButton(
          onPressed: wait > 0
              ? null
              : () {
                  _start();
                  toast(
                    context,
                    demo
                        ? 'Modo demo: no se envía ningún correo. Usa el código de demostración.'
                        : 'El reenvío necesita el servidor de Órbita Kids (pendiente).',
                    icon: Icons.mail_outline_rounded,
                  );
                },
          child: Text(
            wait > 0 ? 'Reenviar código en $wait s' : 'Reenviar código',
          ),
        ),
        Gap.h10,
        TextButton(
          onPressed: () => context.go(AppRoutes.login),
          child: const Text('Volver al inicio'),
        ),
      ],
    );
  }
}
