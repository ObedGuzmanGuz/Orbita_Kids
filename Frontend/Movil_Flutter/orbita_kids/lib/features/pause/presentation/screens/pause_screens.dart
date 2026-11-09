import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:orbita_kids/config/routes/app_routes.dart';
import 'package:orbita_kids/shared/presentation/art/mascot.dart';
import 'package:orbita_kids/shared/presentation/art/space_art.dart';
import 'package:orbita_kids/shared/domain/content/catalog.dart';
import 'package:orbita_kids/shared/domain/entities/content.dart';
import 'package:orbita_kids/shared/presentation/widgets/ui.dart';
import 'package:orbita_kids/features/student/presentation/providers/student_controller.dart';

/// 26 · Pausa Estelar: movimiento, aire libre, creatividad y familia.
class PauseScreen extends ConsumerStatefulWidget {
  const PauseScreen({super.key});

  @override
  ConsumerState<PauseScreen> createState() => _PauseScreenState();
}

class _PauseScreenState extends ConsumerState<PauseScreen> {
  PauseCategory? cat;

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(studentProvider);
    final c = context.ok;
    final list = Catalog.pauseActivities
        .where((a) => cat == null || a.category == cat)
        .toList();
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF0F2E2A)
                      : const Color(0xFFEAF8F2),
                  c.bg,
                ],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Semantics(
                            header: true,
                            child: Text(
                              'Pausa Estelar',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                          ),
                          Text(
                            'Muévete, explora y crea fuera de la pantalla',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Gap.h8,
                          TagChip(
                            'Hoy aprendiste ${s.minutesToday} min',
                            icon: Icons.schedule_rounded,
                            tone: Tone.mint,
                          ),
                        ],
                      ),
                    ),
                    Floating(
                      enabled: !reduceMotion(context, ref),
                      child: const Mascot.orbi(pose: 'jump', size: 96),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const InfoBanner(
                  tone: Tone.mint,
                  icon: Icons.health_and_safety_rounded,
                  text: 'Busca un espacio seguro y, si sales, hazlo siempre con un adulto. Funciona sin Internet.',
                ),
                Gap.h12,
                SizedBox(
                  height: 48,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: const Text('Todas'),
                          selected: cat == null,
                          onSelected: (_) => setState(() => cat = null),
                        ),
                      ),
                      for (final k in PauseCategory.values)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            avatar: Icon(k.icon, size: 18),
                            label: Text(k.label),
                            selected: cat == k,
                            onSelected: (_) => setState(() => cat = k),
                          ),
                        ),
                    ],
                  ),
                ),
                if (cat != null) ...[
                  Gap.h6,
                  Text(cat!.desc, style: Theme.of(context).textTheme.bodySmall),
                ],
                Gap.h12,
                for (final a in list)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: OkCard(
                      onTap: () => context.push(AppRoutes.pauseDetail(a.id)),
                      semanticLabel: '${a.name}. ${a.durationText}. ${a.desc}',
                      child: Row(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: a.category.color.withValues(alpha: .22),
                              borderRadius: AppRadius.card,
                            ),
                            child: Mascot.orbi(
                              pose: a.pose,
                              size: 58,
                              semanticLabel: null,
                            ),
                          ),
                          Gap.w12,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  a.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15.5,
                                  ),
                                ),
                                Text(
                                  a.desc,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                Gap.h4,
                                Wrap(
                                  spacing: 6,
                                  children: [
                                    TagChip(
                                      a.durationText,
                                      icon: Icons.timer_outlined,
                                      tone: Tone.mint,
                                    ),
                                    TagChip(
                                      a.category.label,
                                      tone: Tone.neutral,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SectionTitle('Ideas sin pantalla'),
                const OkCard(
                  child: Text(
                    'Cuenta los escalones de tu casa · Ordena tus colores del más claro al más oscuro · Inventa una suma con tus juguetes · Respira 5 veces como un cohete que despega.',
                  ),
                ),
                Gap.h10,
                Text(
                  'Sin rachas ni presión: la Pausa Estelar es para disfrutar.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 27 · Detalle de actividad.
class PauseDetailScreen extends StatelessWidget {
  const PauseDetailScreen({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context) {
    final a = Catalog.pause(id);
    final c = context.ok;
    final text =
        '${a.name}. ${a.desc} Pasos: ${a.steps.join(' ')} Seguridad: ${a.safety}';
    return OkPage(
      title: a.name,
      subtitle: a.category.label,
      children: [
        Container(
          height: 170,
          decoration: BoxDecoration(
            color: a.category.color.withValues(alpha: .22),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Center(child: Mascot.orbi(pose: a.pose, size: 150)),
        ),
        Gap.h12,
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            TagChip(
              a.durationText,
              icon: Icons.timer_outlined,
              tone: Tone.mint,
            ),
            TagChip(
              'Materiales: ${a.materials}',
              icon: Icons.inventory_2_outlined,
              tone: Tone.neutral,
            ),
          ],
        ),
        Align(alignment: Alignment.centerLeft, child: SpeakButton(text)),
        OkCard(
          child: Row(
            children: [
              IconBox(
                Icons.track_changes_rounded,
                bg: c.tintMint,
                fg: c.inkMint,
              ),
              Gap.w12,
              Expanded(
                child: Text(
                  a.objective,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
        const SectionTitle('Pasos'),
        for (var i = 0; i < a.steps.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 15,
                  backgroundColor: Brand.mint,
                  child: Text(
                    '${i + 1}',
                    style: const TextStyle(
                      color: Brand.ink,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Gap.w10,
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      a.steps[i],
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        Gap.h6,
        InfoBanner(
          tone: Tone.warn,
          icon: Icons.health_and_safety_rounded,
          title: 'Seguridad',
          text: a.safety,
        ),
        Gap.h8,
        InfoBanner(
          icon: Icons.accessible_rounded,
          title: 'Otra forma de hacerlo',
          text: a.alternative,
        ),
        Gap.h6,
        Text(
          'Sin GPS, cámara ni sensores.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Gap.h14,
        FilledButton.icon(
          style: FilledButton.styleFrom(backgroundColor: Brand.mintDark),
          onPressed: () => context.push(AppRoutes.pauseDoing(a.id)),
          icon: const Icon(Icons.play_arrow_rounded),
          label: const Text('Comenzar'),
        ),
      ],
    );
  }
}

/// 28 · Actividad en curso con temporizador opcional y festejo.
class PauseDoingScreen extends ConsumerStatefulWidget {
  const PauseDoingScreen({super.key, required this.id});
  final String id;

  @override
  ConsumerState<PauseDoingScreen> createState() => _PauseDoingScreenState();
}

class _PauseDoingScreenState extends ConsumerState<PauseDoingScreen> {
  Timer? _t;
  int? left;
  bool running = false;
  bool finished = false;
  bool firstBadge = false;

  PauseActivity get a => Catalog.pause(widget.id);

  @override
  void dispose() {
    _t?.cancel();
    super.dispose();
  }

  void _startTimer() {
    left ??= a.seconds;
    running = true;
    _t?.cancel();
    _t = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        left = left! - 1;
        if (left! <= 0) {
          left = 0;
          running = false;
          t.cancel();
        }
      });
    });
    setState(() {});
  }

  void _pauseTimer() {
    _t?.cancel();
    setState(() => running = false);
  }

  Future<void> _finish() async {
    _t?.cancel();
    final had = ref.read(studentProvider).badges.contains('b4');
    await ref.read(studentProvider.notifier).pauseFinished();
    setState(() {
      finished = true;
      firstBadge = !had;
    });
  }

  String _fmt(int s) =>
      '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final c = context.ok;
    if (finished) {
      return OkPage(
        title: '¡Lo hiciste!',
        children: [
          const Center(child: Mascot.orbi(pose: 'celebrate', size: 170)),
          Text(
            '¡Gran movimiento, astronauta!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Gap.h8,
          Text(
            'Terminaste «${a.name}». Tu cuerpo también es parte de la misión.',
            textAlign: TextAlign.center,
            style: TextStyle(color: c.muted),
          ),
          Gap.h12,
          if (firstBadge)
            const InfoBanner(
              tone: Tone.mint,
              icon: Icons.military_tech_rounded,
              title: 'Nueva insignia',
              text: 'Explorador activo: completaste una Pausa Estelar.',
            ),
          Gap.h16,
          FilledButton(
            onPressed: () => context.go(AppRoutes.pause),
            child: const Text('Otra actividad'),
          ),
          Gap.h10,
          OutlinedButton(
            onPressed: () => context.go(AppRoutes.studentHome),
            child: const Text('Volver al inicio'),
          ),
        ],
      );
    }
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [a.category.color.withValues(alpha: .25), c.bg],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    tooltip: 'Regresar',
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                ),
                const Spacer(),
                Text(
                  'Deja el teléfono y muévete',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Gap.h6,
                Text(
                  a.desc,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 17),
                ),
                Gap.h10,
                Floating(
                  enabled: !reduceMotion(context, ref),
                  child: Mascot.orbi(pose: a.pose, size: 170),
                ),
                Gap.h10,
                if (left != null)
                  Semantics(
                    liveRegion: left == 0,
                    label: left == 0
                        ? 'Tiempo terminado'
                        : 'Quedan ${left!} segundos',
                    excludeSemantics: true,
                    child: Text(
                      left == 0 ? '¡Tiempo!' : _fmt(left!),
                      style: AppTextStyles.number(52, color: c.ink),
                    ),
                  ),
                const Spacer(),
                if (left == null)
                  OutlinedButton.icon(
                    onPressed: _startTimer,
                    icon: const Icon(Icons.timer_outlined),
                    label: Text('Usar temporizador (${a.durationText})'),
                  )
                else if (left! > 0)
                  OutlinedButton.icon(
                    onPressed: running ? _pauseTimer : _startTimer,
                    icon: Icon(
                      running ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    ),
                    label: Text(running ? 'Pausar temporizador' : 'Seguir'),
                  ),
                Gap.h10,
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Brand.mintDark,
                    ),
                    onPressed: _finish,
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Terminar'),
                  ),
                ),
                Gap.h6,
                Text(
                  'El temporizador es opcional. La recompensa reconoce el movimiento, no el tiempo en pantalla.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
