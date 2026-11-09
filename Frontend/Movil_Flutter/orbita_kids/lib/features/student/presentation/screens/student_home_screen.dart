import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:orbita_kids/config/routes/app_routes.dart';
import 'package:orbita_kids/config/providers/core_providers.dart';
import 'package:orbita_kids/shared/presentation/art/mascot.dart';
import 'package:orbita_kids/shared/presentation/art/space_art.dart';
import 'package:orbita_kids/shared/domain/content/catalog.dart';
import 'package:orbita_kids/shared/domain/entities/content.dart';
import 'package:orbita_kids/shared/presentation/widgets/skeleton.dart';
import 'package:orbita_kids/shared/presentation/widgets/ui.dart';
import 'package:orbita_kids/features/student/presentation/providers/student_controller.dart';
import 'package:orbita_kids/features/student/presentation/providers/student_state_providers.dart';
import 'package:orbita_kids/features/student/domain/entities/student_progress.dart';

/// Consejo de Orbi según el progreso.
String orbiTip(StudentProgress s) {
  if (s.minutesToday >= 20) {
    return 'Llevas ${s.minutesToday} minutos aprendiendo. ¿Hacemos una Pausa Estelar?';
  }
  if (s.lowStreak >= 1) {
    return 'Si una suma es difícil, cuenta los dibujos con calma. ¡Yo te ayudo!';
  }
  return '¡Ya casi completas ${Catalog.planet(s.nextMission().planetId).name}! Cada misión repara una pieza de tu nave.';
}

/// Encabezado espacial (`.hero` del prototipo).
class SpaceHero extends StatelessWidget {
  const SpaceHero({super.key, required this.child, this.seed = 11});
  final Widget child;
  final int seed;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(30)),
    child: SpaceBackground(
      seed: seed,
      stars: 30,
      colors: const [Color(0xFF2E3192), Color(0xFF191B58), Color(0xFF0D102B)],
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: DefaultTextStyle.merge(
            style: const TextStyle(color: Colors.white),
            child: child,
          ),
        ),
      ),
    ),
  );
}

/// 15 · Home estudiante.
class StudentHomeScreen extends ConsumerWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(studentProvider);
    // 58 · Mientras llega el progreso se muestra la estructura de la pantalla.
    if (!s.loaded) return const Scaffold(body: HomeSkeleton());
    final m = s.nextMission();
    final pl = Catalog.planet(m.planetId);
    final total = s.done.length;
    final tasks = ref.watch(pendingTasksProvider);
    final now = ref.read(clockProvider)();
    final still = reduceMotion(context, ref);
    final c = context.ok;
    final upcoming = [
      ...Catalog.planets
          .where((p) => s.planetUnlocked(p.id))
          .expand((p) => Catalog.missionsOf(p.id))
          .where((x) => !s.done.containsKey(x.id) && x.id != m.id),
      ...Catalog.missions.where((x) => s.done.containsKey(x.id)),
    ].take(4).toList();

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          SpaceHero(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const BrandLogo(width: 92),
                    const Spacer(),
                    TagChip(
                      '${s.minutesToday} min hoy',
                      icon: Icons.schedule_rounded,
                      tone: Tone.neutral,
                    ),
                  ],
                ),
                Gap.h6,
                Row(
                  children: [
                    Semantics(
                      button: true,
                      label: 'Abrir mi perfil',
                      excludeSemantics: true,
                      child: InkResponse(
                        onTap: () => context.go(AppRoutes.studentProfile),
                        child: CircleAvatar(
                          radius: 26,
                          backgroundColor: const Color(0xFF2E3192),
                          child: Mascot(look: s.look, pose: 'stand', size: 44),
                        ),
                      ),
                    ),
                    Gap.w10,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            toBeginningOfSentenceCase(
                              DateFormat(
                                "EEEE d 'de' MMMM",
                                'es_MX',
                              ).format(now),
                            ),
                            style: const TextStyle(
                              color: Brand.lavender,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Semantics(
                            header: true,
                            child: Text(
                              '¡Hola, ${s.name}!',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Avisos',
                      color: Colors.white,
                      onPressed: () => context.push(AppRoutes.studentNotices),
                      icon: const Icon(Icons.notifications_rounded),
                    ),
                  ],
                ),
                Gap.h10,
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: 136,
                      height: 130,
                      child: Stack(
                        children: [
                          Floating(
                            enabled: !still,
                            child: Mascot(
                              look: s.look,
                              size: 104,
                              semanticLabel: 'Tu astronauta',
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Semantics(
                              button: true,
                              label: 'Conoce a Orbi, tu perrito astronauta',
                              excludeSemantics: true,
                              child: InkResponse(
                                onTap: () => context.push(AppRoutes.meetOrbi),
                                child: const Mascot.orbi(
                                  pose: 'wave',
                                  size: 56,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const TagChip('Tu misión actual', tone: Tone.neutral),
                          Gap.h6,
                          Text(
                            m.name,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(color: Colors.white),
                          ),
                          Text(
                            '${pl.name} · Misión ${m.n} de 3${s.isDownloaded(pl.id) ? ' · sin Internet' : ''}',
                            style: const TextStyle(
                              color: Brand.lavender,
                              fontWeight: FontWeight.w700,
                              fontSize: 13.5,
                            ),
                          ),
                          Gap.h8,
                          ProgressLine(
                            value: s.doneCount(pl.id) / 3,
                            track: Colors.white24,
                            label: 'Progreso del planeta',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Gap.h16,
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Brand.yellow,
                      foregroundColor: Brand.ink,
                      minimumSize: const Size.fromHeight(64),
                      textStyle: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    onPressed: () => context.push(AppRoutes.mission(m.id)),
                    icon: const Icon(Icons.rocket_launch_rounded, size: 26),
                    label: const Text('Continuar misión'),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OrbiSays(text: orbiTip(s), pose: 'point', size: 66),
                Gap.h14,
                OkCard(
                  onTap: () => context.go(AppRoutes.progress),
                  child: Row(
                    children: [
                      IconBox(
                        Icons.trending_up_rounded,
                        bg: c.tintViolet,
                        fg: c.purpleDark,
                      ),
                      Gap.w12,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              spacing: 8,
                              children: [
                                Text(
                                  Catalog.level(m.level).name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  '$total de ${Catalog.missions.length} misiones',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                            Gap.h8,
                            ProgressLine(
                              value: total / Catalog.missions.length,
                              label: 'Progreso general',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SectionTitle(
                  'Tareas de tu maestra',
                  action: 'Ver todas',
                  onAction: () => context.push(AppRoutes.assigned),
                ),
                if (tasks.isEmpty)
                  OkCard(
                    child: Row(
                      children: [
                        const Mascot.orbi(pose: 'celebrate', size: 70),
                        Gap.w10,
                        const Expanded(
                          child: Text(
                            '¡Terminaste todas las tareas! Sigue con tus misiones.',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                  ),
                for (final a in tasks.take(2)) ...[
                  OkListTile(
                    leading: IconBox(
                      Icons.assignment_rounded,
                      bg: c.tintTeal,
                      fg: c.inkTeal,
                    ),
                    title: a.name,
                    subtitle:
                        '${a.type == MissionType.visual ? 'Con dibujos' : 'Elige la respuesta'} · ${Catalog.level(a.level).short} · entrega ${DateFormat('d MMM', 'es_MX').format(a.due)}',
                    trailing: const TagChip('Empezar'),
                    onTap: () => startTask(context, ref, a),
                  ),
                  Gap.h8,
                ],
                SectionTitle(
                  'Próximas misiones',
                  action: 'Ver mapa',
                  onAction: () => context.go(AppRoutes.map),
                ),
                SizedBox(
                  height: 120 + 60 * MediaQuery.textScalerOf(context).scale(1),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: upcoming.length,
                    separatorBuilder: (_, _) => Gap.w12,
                    itemBuilder: (_, i) {
                      final mm = upcoming[i];
                      final p = Catalog.planet(mm.planetId);
                      return SizedBox(
                        width: 160,
                        child: OkCard(
                          onTap: () => context.push(AppRoutes.mission(mm.id)),
                          padding: const EdgeInsets.all(14),
                          semanticLabel:
                              '${mm.name}, ${p.name}, ${s.done[mm.id] ?? 0} de 3 estrellas',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              PlanetArt.of(p, size: 48),
                              Gap.h6,
                              Text(
                                mm.name,
                                maxLines: 2,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                  height: 1.2,
                                ),
                              ),
                              Text(
                                p.name,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const Spacer(),
                              StarRow(value: s.done[mm.id] ?? 0),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Gap.h16,
                Row(
                  children: [
                    Expanded(
                      child: _Tile(
                        color: c.tintMint,
                        art: const Mascot.orbi(
                          pose: 'jump',
                          size: 58,
                          semanticLabel: null,
                        ),
                        title: 'Pausa Estelar',
                        sub: 'Muévete y explora',
                        onTap: () => context.go(AppRoutes.pause),
                      ),
                    ),
                    Gap.w12,
                    Expanded(
                      child: _Tile(
                        color: c.tintViolet,
                        art: const PlanetArt(
                          light: Color(0xFFF5C8FF),
                          dark: Color(0xFFA35BD6),
                          size: 54,
                          ring: true,
                        ),
                        title: 'Nuevas Galaxias',
                        sub: 'Próximamente',
                        onTap: () => context.push(AppRoutes.galaxies),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.color,
    required this.art,
    required this.title,
    required this.sub,
    required this.onTap,
  });
  final Color color;
  final Widget art;
  final String title;
  final String sub;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => OkCard(
    color: color,
    onTap: onTap,
    semanticLabel: '$title. $sub',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 64, child: art),
        Gap.h6,
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        Text(sub, style: Theme.of(context).textTheme.bodySmall),
      ],
    ),
  );
}

/// Inicia una tarea de la maestra.
void startTask(BuildContext context, WidgetRef ref, Activity a) {
  ref.read(runProvider.notifier).startAssigned(a);
  context.push(AppRoutes.play);
}

/// Home del modo explorar (sin cuenta).
class GuestHomeScreen extends ConsumerWidget {
  const GuestHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(studentProvider);
    final m = s.nextMission(guest: true);
    final pl = Catalog.planet(m.planetId);
    final dc = s.doneCount(pl.id);
    final still = reduceMotion(context, ref);
    final c = context.ok;
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          SpaceHero(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    BrandLogo(width: 92),
                    Spacer(),
                    TagChip(
                      'Modo explorar',
                      icon: Icons.visibility_rounded,
                      tone: Tone.warn,
                    ),
                  ],
                ),
                Gap.h6,
                Text(
                  '¡Hola, explorador!',
                  style: Theme.of(context).textTheme.headlineSmall
                      ?.copyWith(color: Colors.white),
                ),
                const Text(
                  'Prueba Órbita Kids sin cuenta.',
                  style: TextStyle(
                    color: Brand.lavender,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Gap.h8,
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Floating(
                      enabled: !still,
                      child: Mascot(
                        look: s.look,
                        size: 100,
                        semanticLabel: 'Tu astronauta',
                      ),
                    ),
                    const Mascot.orbi(pose: 'wave', size: 70),
                    Gap.w6,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const TagChip('Misión de prueba', tone: Tone.neutral),
                          Gap.h6,
                          Text(
                            dc == 3 ? 'Planeta Verde completo' : m.name,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(color: Colors.white),
                          ),
                          Text(
                            '${pl.name} · $dc de 3',
                            style: const TextStyle(
                              color: Brand.lavender,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Gap.h14,
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Brand.yellow,
                      foregroundColor: Brand.ink,
                    ),
                    onPressed: () => context.push(AppRoutes.mission(m.id)),
                    icon: const Icon(Icons.rocket_launch_rounded),
                    label: Text(dc == 3 ? 'Jugar otra vez' : 'Probar misión'),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const InfoBanner(
                  icon: Icons.visibility_rounded,
                  text: 'Estás en modo explorar: no guardamos datos y tu avance se borra al salir.',
                ),
                const SectionTitle('Puedes ver'),
                Row(
                  children: [
                    Expanded(
                      child: _Tile(
                        color: c.tintViolet,
                        art: const PlanetArt(
                          light: Color(0xFFB8F0C9),
                          dark: Color(0xFF3FAE7A),
                          size: 56,
                          kind: PlanetKind.terra,
                        ),
                        title: 'Tu universo',
                        sub: '6 planetas · vista previa',
                        onTap: () => context.go(AppRoutes.map),
                      ),
                    ),
                    Gap.w12,
                    Expanded(
                      child: _Tile(
                        color: c.tintMint,
                        art: const Mascot.orbi(
                          pose: 'jump',
                          size: 58,
                          semanticLabel: null,
                        ),
                        title: 'Pausa Estelar',
                        sub: 'Muévete y explora',
                        onTap: () => context.go(AppRoutes.pause),
                      ),
                    ),
                  ],
                ),
                Gap.h12,
                Row(
                  children: [
                    Expanded(
                      child: _Tile(
                        color: c.tintTeal,
                        art: Mascot(
                          look: s.look,
                          pose: 'stand',
                          size: 56,
                          semanticLabel: null,
                        ),
                        title: 'Tu astronauta',
                        sub: 'Pruébalo',
                        onTap: () => context.push(AppRoutes.avatar),
                      ),
                    ),
                    Gap.w12,
                    Expanded(
                      child: _Tile(
                        color: c.tintYellow,
                        art: Icon(
                          Icons.accessibility_new_rounded,
                          size: 48,
                          color: c.inkYellow,
                        ),
                        title: 'Accesibilidad',
                        sub: 'Texto, audio y colores',
                        onTap: () => context.push(AppRoutes.accessibility),
                      ),
                    ),
                  ],
                ),
                Gap.h16,
                OkCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Con una cuenta de tu escuela',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Gap.h4,
                      const Text(
                        'Tu avance se guarda, se abren los 6 planetas y recibes las tareas de tu maestra. La cuenta la crea tu escuela o un adulto responsable.',
                      ),
                      Gap.h12,
                      OutlinedButton(
                        onPressed: () => context.go(AppRoutes.guestMore),
                        child: const Text('Cómo obtener una cuenta'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
