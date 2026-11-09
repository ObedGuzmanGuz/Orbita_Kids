import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:orbita_kids/config/routes/app_router.dart';
import 'package:orbita_kids/features/settings/presentation/providers/settings_controller.dart';
import 'package:orbita_kids/shared/presentation/art/mascot.dart';
import 'package:orbita_kids/shared/presentation/art/space_art.dart';
import 'package:orbita_kids/shared/presentation/widgets/ui.dart';
import 'package:orbita_kids/features/auth/presentation/providers/auth_controller.dart';

/// 01 · Splash Órbita Kids. Restaura la sesión mientras se muestra (~2 s).
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  Timer? _t;
  late final Future<void> _restore;
  bool _left = false;

  @override
  void initState() {
    super.initState();
    _restore = ref.read(authControllerProvider.notifier).restore();
    _t = Timer(const Duration(milliseconds: 2000), _next);
  }

  Future<void> _next() async {
    if (_left) return;
    _left = true;
    _t?.cancel();
    await _restore;
    if (mounted) context.go(AppRoutes.studios);
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final still = reduceMotion(context, ref);
    return Scaffold(
      backgroundColor: Brand.space,
      body: Semantics(
        button: true,
        label: 'Órbita Kids. Toca para continuar',
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _next,
          child: SpaceBackground(
            seed: 5,
            stars: 46,
            child: SafeArea(
              bottom: false,
              child: LayoutBuilder(
                builder: (context, box) {
                  final w = box.maxWidth, h = box.maxHeight;
                  Widget sym(String t, double x, double y, double size) =>
                      Positioned(
                        left: w * x,
                        top: h * y,
                        child: ExcludeSemantics(
                          child: Text(
                            t,
                            style: AppTextStyles.number(
                              size,
                              color: Brand.lavender.withValues(alpha: .7),
                            ),
                          ),
                        ),
                      );
                  return Stack(
                    children: [
                      sym('3', .08, .12, 22),
                      sym('2', .86, .16, 22),
                      sym('+', .1, .5, 26),
                      sym('=', .84, .52, 26),
                      Positioned(
                        right: w * .08,
                        top: h * .58,
                        child: const PlanetArt(
                          light: Color(0xFFFFB3A1),
                          dark: Color(0xFFD9434A),
                          size: 34,
                          ring: true,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 8,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.white.withValues(
                              alpha: .12,
                            ),
                          ),
                          onPressed: _next,
                          child: const Text('Saltar'),
                        ),
                      ),
                      Align(
                        alignment: const Alignment(0, -.55),
                        child: _Entrance(
                          still: still,
                          child: BrandLogo(width: (w * .78).clamp(200, 340)),
                        ),
                      ),
                      // Luna morada con el astronauta y Orbi.
                      Positioned(
                        left: -w * .2,
                        right: -w * .2,
                        bottom: -h * .12,
                        height: h * .3,
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: RadialGradient(
                              center: Alignment(0, -.6),
                              radius: 1,
                              colors: [Color(0xFF9186F5), Color(0xFF5E55D6)],
                            ),
                            borderRadius: BorderRadius.vertical(
                              top: Radius.elliptical(400, 120),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: h * .06,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Floating(
                              enabled: !still,
                              child: const Mascot(
                                look: AvatarLook(
                                  character: 'ari',
                                  helmet: 'morado',
                                ),
                                pose: 'wave',
                                size: 120,
                                semanticLabel: 'Astronauta saludando',
                              ),
                            ),
                            Gap.w18,
                            Flexible(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: AppRadius.field,
                                    ),
                                    child: const Text(
                                      '¡Guau! Soy Orbi',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Brand.ink,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                  Gap.h6,
                                  Floating(
                                    enabled: !still,
                                    child: const Mascot.orbi(
                                      pose: 'wave',
                                      size: 100,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Entrance extends StatelessWidget {
  const _Entrance({required this.child, required this.still});
  final Widget child;
  final bool still;

  @override
  Widget build(BuildContext context) {
    if (still) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutBack,
      builder: (_, v, c) => Opacity(
        opacity: v.clamp(0, 1),
        child: Transform.scale(scale: .85 + .15 * v, child: c),
      ),
      child: child,
    );
  }
}

/// 02 · Splash Órbita Kids Studios (1.5 s).
class StudiosSplashScreen extends ConsumerStatefulWidget {
  const StudiosSplashScreen({super.key});

  @override
  ConsumerState<StudiosSplashScreen> createState() =>
      _StudiosSplashScreenState();
}

class _StudiosSplashScreenState extends ConsumerState<StudiosSplashScreen> {
  Timer? _t;

  @override
  void initState() {
    super.initState();
    _t = Timer(const Duration(milliseconds: 1500), _next);
  }

  void _next() {
    if (!mounted) return;
    final auth = ref.read(authControllerProvider);
    final onboarded = ref.read(settingsProvider).onboarded;
    if (auth.isSignedIn) {
      context.go(homeFor(auth));
    } else if (auth.expired) {
      context.go(AppRoutes.authState('expired'));
    } else if (!onboarded) {
      context.go(AppRoutes.onboarding);
    } else {
      context.go(AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF0A0B18),
    body: Center(
      child: _Entrance(
        still: reduceMotion(context, ref),
        child: const Padding(
          padding: EdgeInsets.all(24),
          child: StudiosLogo(width: 320),
        ),
      ),
    ),
  );
}

/// 03 · Onboarding en 5 pasos (el primero presenta a Orbi).
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  int i = 0;

  static const _steps = [
    (
      '¡Hola! Soy Orbi',
      'Soy un perrito astronauta y seré tu copiloto. Te acompaño en cada misión: te doy pistas, festejo contigo y te recuerdo descansar.',
      'wave',
    ),
    (
      'Aprende matemáticas',
      'Practica sumas con estrellas, planetas y cohetes.',
      'learn',
    ),
    (
      'Explora nuevos planetas',
      'Cada planeta es una etapa de tu viaje.',
      'explore',
    ),
    (
      'Completa misiones',
      'Gana estrellas y repara tu nave. Si te equivocas, te ayudamos.',
      'celebrate',
    ),
    (
      'Muévete fuera de la pantalla',
      'Descubre, crea y juega en el mundo real con Pausa Estelar.',
      'jump',
    ),
  ];

  void _done() {
    ref
        .read(settingsProvider.notifier)
        .update((s) => s.copyWith(onboarded: true));
    final auth = ref.read(authControllerProvider);
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(auth.isSignedIn ? homeFor(auth) : AppRoutes.login);
    }
  }

  Widget _art(int k) => switch (k) {
    0 => Column(
      children: [
        const Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            _OrbiChip(Icons.auto_awesome_rounded, 'Pistas'),
            _OrbiChip(Icons.star_border_rounded, 'Festejos'),
            _OrbiChip(Icons.directions_run_rounded, 'Pausas'),
          ],
        ),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: Brand.yellow),
          onPressed: () => context.push(AppRoutes.meetOrbi),
          child: const Text('Conoce más a Orbi ›'),
        ),
      ],
    ),
    1 => FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('3 + 2', style: AppTextStyles.number(54, color: Colors.white)),
          Gap.w12,
          for (var j = 0; j < 3; j++) const StarIcon(size: 30),
        ],
      ),
    ),
    2 => const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        PlanetArt(light: Color(0xFFD5CFFF), dark: Color(0xFF8F86F0), size: 64),
        PlanetArt(
          light: Color(0xFFA7F0F4),
          dark: Color(0xFF3FA9B8),
          size: 92,
          ring: true,
        ),
        PlanetArt(
          light: Color(0xFFFFE6A6),
          dark: Color(0xFFE0A53A),
          size: 70,
          ring: true,
        ),
      ],
    ),
    3 => const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RocketArt(size: 80, angle: 0),
        SizedBox(width: 14),
        Column(
          children: [
            StarIcon(size: 40),
            SizedBox(height: 6),
            TagChip('+3 estrellas', tone: Tone.warn),
          ],
        ),
      ],
    ),
    _ => const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Mascot.orbi(pose: 'stretch', size: 80, semanticLabel: null),
        Mascot.orbi(pose: 'explore', size: 80, semanticLabel: null),
      ],
    ),
  };

  @override
  Widget build(BuildContext context) {
    final s = _steps[i];
    final last = i == _steps.length - 1;
    final still = reduceMotion(context, ref);
    return Scaffold(
      backgroundColor: Brand.space,
      body: SpaceBackground(
        seed: 31 + i,
        stars: 26,
        colors: const [Color(0xFF2A2C7A), Color(0xFF191B58), Color(0xFF0D102B)],
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: BrandLogo(width: 96),
                      ),
                    ),
                    TagChip('${i + 1} de ${_steps.length}', tone: Tone.neutral),
                    Gap.w8,
                    if (!last)
                      TextButton(
                        onPressed: _done,
                        style: TextButton.styleFrom(
                          foregroundColor: Brand.lavender,
                        ),
                        child: const Text('Omitir'),
                      ),
                  ],
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: still
                        ? Duration.zero
                        : const Duration(milliseconds: 300),
                    child: SingleChildScrollView(
                      key: ValueKey(i),
                      child: Column(
                        children: [
                          Gap.h12,
                          Floating(
                            enabled: !still,
                            child: Mascot.orbi(
                              pose: s.$3,
                              size: i == 0 ? 170 : 140,
                            ),
                          ),
                          Gap.h18,
                          _art(i),
                          Gap.h22,
                          Semantics(
                            header: true,
                            child: Text(
                              s.$1,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineLarge
                                  ?.copyWith(color: Colors.white),
                            ),
                          ),
                          Gap.h8,
                          Text(
                            s.$2,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 17,
                              color: Brand.lavenderText,
                            ),
                          ),
                          SpeakButton('${s.$1}. ${s.$2}', light: true),
                        ],
                      ),
                    ),
                  ),
                ),
                Semantics(
                  label: 'Paso ${i + 1} de ${_steps.length}',
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var k = 0; k < _steps.length; k++)
                        Expanded(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            height: 8,
                            decoration: BoxDecoration(
                              color: k <= i ? Brand.violet : Colors.white24,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Gap.h14,
                Row(
                  children: [
                    if (i > 0) ...[
                      SizedBox(
                        width: 80,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(
                              color: Colors.white38,
                              width: 2,
                            ),
                          ),
                          onPressed: () => setState(() => i--),
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            semanticLabel: 'Anterior',
                          ),
                        ),
                      ),
                      Gap.w10,
                    ],
                    Expanded(
                      child: FilledButton.icon(
                        style: last
                            ? FilledButton.styleFrom(
                                backgroundColor: Brand.yellow,
                                foregroundColor: Brand.ink,
                              )
                            : FilledButton.styleFrom(
                                backgroundColor: Brand.purple,
                              ),
                        onPressed: last ? _done : () => setState(() => i++),
                        icon: Icon(
                          last
                              ? Icons.rocket_launch_rounded
                              : Icons.arrow_forward_rounded,
                        ),
                        label: Text(last ? 'Comenzar' : 'Siguiente'),
                      ),
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
}

/// 04 · Loading: muestra los pasos del flujo de autenticación.
class LoadingScreen extends ConsumerStatefulWidget {
  const LoadingScreen({
    super.key,
    required this.next,
    this.message,
    this.sub,
    this.flow = false,
  });

  final String next;
  final String? message;
  final String? sub;
  final bool flow;

  @override
  ConsumerState<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends ConsumerState<LoadingScreen> {
  static const steps = [
    'Elegiste un método de acceso',
    'Flutter inició el flujo con PKCE',
    'Keycloak validó tu identidad',
    'La app recibió el código y los tokens',
    'Se identificó tu rol',
    'Abriendo tu inicio',
  ];

  int shown = 0;
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    final total = widget.flow ? 1800 : 1000;
    _tick = Timer.periodic(
      Duration(milliseconds: total ~/ (steps.length + 1)),
      (t) {
        if (!mounted) return;
        if (shown >= steps.length) {
          t.cancel();
          context.go(widget.next);
        } else {
          setState(() => shown++);
        }
      },
    );
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final still = reduceMotion(context, ref);
    return Scaffold(
      backgroundColor: Brand.space,
      body: SpaceBackground(
        seed: 9,
        stars: 30,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const BrandLogo(width: 150),
                  Gap.h10,
                  Floating(
                    enabled: !still,
                    child: const Mascot.orbi(pose: 'walk', size: 120),
                  ),
                  Gap.h12,
                  Text(
                    widget.message ?? 'Preparando tu próxima misión',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall
                        ?.copyWith(color: Colors.white),
                  ),
                  Gap.h6,
                  Text(
                    widget.sub ?? 'Esto toma solo un momento',
                    style: const TextStyle(color: Brand.lavenderText),
                  ),
                  Gap.h18,
                  if (widget.flow)
                    Semantics(
                      liveRegion: true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (var k = 0; k < steps.length; k++)
                            AnimatedOpacity(
                              opacity: k < shown ? 1 : .3,
                              duration: const Duration(milliseconds: 200),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 3,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      k < shown
                                          ? Icons.check_circle_rounded
                                          : Icons.radio_button_unchecked,
                                      size: 18,
                                      color: k < shown
                                          ? Brand.mint
                                          : Colors.white54,
                                    ),
                                    Gap.w8,
                                    Flexible(
                                      child: Text(
                                        steps[k],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    )
                  else
                    SizedBox(
                      width: 220,
                      child: ProgressLine(
                        value: shown / steps.length,
                        track: Colors.white24,
                        color: Brand.yellow,
                        label: 'Cargando',
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OrbiChip extends StatelessWidget {
  const _OrbiChip(this.icon, this.label);
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .12),
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: Colors.white24),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.white),
        Gap.w6,
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}
