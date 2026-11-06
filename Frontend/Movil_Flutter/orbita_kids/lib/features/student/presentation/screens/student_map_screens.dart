import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:orbita_kids/config/routes/app_routes.dart';
import 'package:orbita_kids/core/network/connectivity.dart';
import 'package:orbita_kids/shared/presentation/art/mascot.dart';
import 'package:orbita_kids/shared/presentation/art/space_art.dart';
import 'package:orbita_kids/shared/domain/content/catalog.dart';
import 'package:orbita_kids/shared/domain/entities/content.dart';
import 'package:orbita_kids/shared/presentation/widgets/skeleton.dart';
import 'package:orbita_kids/shared/presentation/widgets/ui.dart';
import 'package:orbita_kids/features/auth/presentation/providers/auth_controller.dart';
import 'package:orbita_kids/features/student/presentation/providers/student_controller.dart';
import 'package:orbita_kids/features/student/domain/entities/student_progress.dart';

/// 18 · Mapa espacial con 6 planetas y desbloqueo progresivo.
class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final _scroll = ScrollController();
  static const _step = 190.0;
  static const _node = 120.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      final s = ref.read(studentProvider);
      final guest = ref.read(authControllerProvider).isGuest;
      final i = Catalog.planets.indexWhere(
        (p) => p.id == s.nextMission(guest: guest).planetId,
      );
      final y = _y(i) - 220;
      _scroll.jumpTo(y.clamp(0, _scroll.position.maxScrollExtent));
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  double _y(int i) => 40 + (Catalog.planets.length - 1 - i) * _step;

  void _locked(Planet p, int i, bool guest) {
    final prev = i > 0 ? Catalog.planets[i - 1] : null;
    toast(
      context,
      guest
          ? 'Este planeta se abre con una cuenta de tu escuela.'
          : 'Completa ${prev?.name} para abrir ${p.name}.',
      icon: Icons.lock_rounded,
    );
  }

  void _open(Planet p, bool online) {
    final s = ref.read(studentProvider);
    if (!online && !s.isDownloaded(p.id)) {
      toast(
        context,
        'Sin Internet solo abren los planetas descargados.',
        icon: Icons.wifi_off_rounded,
      );
      return;
    }
    final next = Catalog.missionsOf(p.id).firstWhere(
      (m) => !s.done.containsKey(m.id),
      orElse: () => Catalog.missionsOf(p.id).first,
    );
    context.push(AppRoutes.mission(next.id));
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(studentProvider);
    if (!s.loaded) return const _MapSkeleton();
    final guest = ref.watch(authControllerProvider).isGuest;
    final online = ref.watch(onlineProvider);
    final cur = s.nextMission(guest: guest).planetId;
    final curP = Catalog.planet(cur);
    final h = _y(0) + _node + 120;
    final still = reduceMotion(context, ref);

    return Scaffold(
      backgroundColor: Brand.space,
      body: SpaceBackground(
        seed: 17,
        stars: 60,
        colors: const [Color(0xFF2A2C7A), Color(0xFF191B58), Color(0xFF0D102B)],
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 8, 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Semantics(
                            header: true,
                            child: Text(
                              'Tu universo',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(color: Colors.white),
                            ),
                          ),
                          const Text(
                            'Completa las misiones y avanza en tu aventura',
                            style: TextStyle(
                              color: Brand.lavender,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!guest)
                      IconButton(
                        tooltip: 'Centro de descargas',
                        color: Colors.white,
                        onPressed: () => context.push(AppRoutes.downloads),
                        icon: const Icon(Icons.download_for_offline_rounded),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, box) {
                    final w = box.maxWidth;
                    double x(int i) => i.isOdd ? w - _node - 24 : 24;
                    return SingleChildScrollView(
                      controller: _scroll,
                      child: SizedBox(
                        height: h,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: CustomPaint(
                                painter: _PathPainter([
                                  for (
                                    var i = 0;
                                    i < Catalog.planets.length;
                                    i++
                                  )
                                    Offset(x(i) + _node / 2, _y(i) + _node / 2),
                                ]),
                              ),
                            ),
                            for (var i = 0; i < Catalog.planets.length; i++)
                              _planetNode(
                                context,
                                i,
                                x(i),
                                s,
                                guest,
                                cur,
                                still,
                                online,
                              ),
                            Positioned(
                              left: x(0) + _node + 10,
                              top: _y(0) + 40,
                              child: Floating(
                                enabled: !still,
                                child: Mascot(
                                  look: s.look,
                                  pose: 'point',
                                  size: 64,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                color: const Color(0xFF191B58),
                child: OrbiSays(
                  dark: true,
                  size: 64,
                  pose: 'point',
                  text: guest
                      ? 'Prueba el Planeta Verde. Los otros 5 planetas se abren con una cuenta.'
                      : '¡Continúa en ${curP.name}! ${Catalog.level(curP.level).desc}',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _planetNode(
    BuildContext context,
    int i,
    double x,
    StudentProgress s,
    bool guest,
    String cur,
    bool still,
    bool online,
  ) {
    final p = Catalog.planets[i];
    final un = s.planetUnlocked(p.id, guest: guest);
    final dc = s.doneCount(p.id);
    final dl = s.isDownloaded(p.id);
    final right = i.isOdd;
    final isCur = p.id == cur;
    final label =
        '${p.name}, ${Catalog.level(p.level).short}, ${un ? '$dc de 3 misiones' : 'bloqueado'}${dl ? ', disponible sin Internet' : ''}';

    final planet = SizedBox(
      width: _node,
      height: _node,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (isCur)
            Container(
              width: _node,
              height: _node,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Brand.yellow.withValues(alpha: .45),
                    blurRadius: 28,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          Opacity(opacity: un ? 1 : .55, child: PlanetArt.of(p, size: 100)),
          Positioned(
            left: 0,
            top: 4,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const StarIcon(size: 34),
                Text(
                  '${p.level}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Brand.ink,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          if (!un)
            const CircleAvatar(
              radius: 20,
              backgroundColor: Color(0xCC0D102B),
              child: Icon(Icons.lock_rounded, color: Colors.white),
            )
          else if (dl)
            const Positioned(
              right: 6,
              bottom: 8,
              child: CircleAvatar(
                radius: 13,
                backgroundColor: Brand.mint,
                child: Icon(
                  Icons.download_done_rounded,
                  size: 15,
                  color: Brand.ink,
                ),
              ),
            ),
        ],
      ),
    );

    final prev = i > 0 ? Catalog.planets[i - 1] : null;
    final card = Container(
      width: 150,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .1),
        borderRadius: AppRadius.field,
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            p.name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            un
                ? '$dc/3 misiones · ${Catalog.level(p.level).short}'
                : 'Bloqueado',
            style: const TextStyle(
              color: Brand.lavender,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (un)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                children: [
                  for (var k = 1; k <= 3; k++)
                    Container(
                      width: 10,
                      height: 10,
                      margin: const EdgeInsets.only(right: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: k <= dc ? Brand.yellow : Colors.white24,
                      ),
                    ),
                ],
              ),
            )
          else
            Text(
              guest ? 'Con una cuenta' : 'Completa ${prev?.name}',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
        ],
      ),
    );

    return Positioned(
      left: right ? x - 160 : x,
      top: _y(i),
      child: Semantics(
        button: true,
        label: label,
        excludeSemantics: true,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => un ? _open(p, online) : _locked(p, i, guest),
          child: Row(
            children: right ? [card, Gap.w10, planet] : [planet, Gap.w10, card],
          ),
        ),
      ),
    );
  }
}

class _PathPainter extends CustomPainter {
  _PathPainter(this.points);
  final List<Offset> points;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final a = points[i - 1], b = points[i];
      path.cubicTo(a.dx, a.dy - 120, b.dx, b.dy + 120, b.dx, b.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = Brand.lavender.withValues(alpha: .1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10,
    );
    for (final m in path.computeMetrics()) {
      for (double d = 0; d < m.length; d += 12) {
        final t = m.getTangentForOffset(d);
        if (t != null) {
          canvas.drawCircle(
            t.position,
            1.8,
            Paint()..color = const Color(0xFFE6E3FF),
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PathPainter old) => old.points != points;
}

/// 19 · Detalle de misión.
class MissionDetailScreen extends ConsumerWidget {
  const MissionDetailScreen({super.key, required this.missionId});
  final String missionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final m = Catalog.mission(missionId);
    final pl = Catalog.planet(m.planetId);
    final s = ref.watch(studentProvider);
    final guest = ref.watch(authControllerProvider).isGuest;
    final online = ref.watch(onlineProvider);
    final st = s.done[m.id] ?? 0;
    final dl = s.isDownloaded(pl.id);
    final c = context.ok;
    final unlocked = s.planetUnlocked(pl.id, guest: guest);

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(30),
            ),
            child: SpaceBackground(
              seed: 21,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            tooltip: 'Regresar',
                            color: Colors.white,
                            onPressed: () => context.pop(),
                            icon: const Icon(Icons.arrow_back_rounded),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  Catalog.level(pl.level).name,
                                  style: const TextStyle(
                                    color: Brand.lavender,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                  ),
                                ),
                                Semantics(
                                  header: true,
                                  child: Text(
                                    pl.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Row(
                          children: [
                            PlanetArt.of(pl, size: 104),
                            Gap.w12,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TagChip(
                                    'Misión ${m.n} de 3 · ${st > 0 ? 'Completada' : 'Pendiente'}',
                                    tone: Tone.neutral,
                                  ),
                                  Gap.h6,
                                  Text(
                                    m.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(color: Colors.white),
                                  ),
                                  Gap.h6,
                                  StarRow(
                                    value: st,
                                    size: 18,
                                    off: Colors.white24,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Gap.h14,
                      Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            for (final x in Catalog.missionsOf(pl.id))
                              ChoiceChip(
                                avatar: s.done.containsKey(x.id)
                                    ? const Icon(Icons.check_rounded, size: 16)
                                    : null,
                                showCheckmark: false,
                                label: Text('Misión ${x.n}'),
                                selected: x.id == m.id,
                                onSelected: (_) => context.pushReplacement(
                                  AppRoutes.mission(x.id),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    TagChip(
                      dl ? 'Disponible sin Internet' : 'Necesita Internet',
                      icon: dl
                          ? Icons.download_done_rounded
                          : Icons.cloud_outlined,
                      tone: dl ? Tone.mint : Tone.neutral,
                    ),
                    SpeakButton(m.story),
                  ],
                ),
                Gap.h8,
                OrbiSays(
                  title: 'Orbi te cuenta',
                  text: m.story,
                  pose: 'learn',
                  size: 70,
                ),
                Gap.h12,
                OkCard(
                  child: Row(
                    children: [
                      IconBox(
                        Icons.track_changes_rounded,
                        bg: c.tintViolet,
                        fg: c.purpleDark,
                      ),
                      Gap.w12,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Vas a aprender',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              m.objective,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Gap.h10,
                Row(
                  children: [
                    Expanded(
                      child: OkCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tipo',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              m.type.label,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Gap.w10,
                    Expanded(
                      child: OkCard(
                        semanticLabel: 'Dificultad ${m.level} de 6',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Nivel ${m.level}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Gap.h6,
                            Row(
                              children: [
                                for (var k = 1; k <= 6; k++)
                                  Container(
                                    width: 14,
                                    height: 10,
                                    margin: const EdgeInsets.only(right: 4),
                                    decoration: BoxDecoration(
                                      color: k <= m.level
                                          ? Brand.purple
                                          : c.line,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Gap.h10,
                OkCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Practicarás sumas como',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Gap.h8,
                      Wrap(
                        spacing: 8,
                        children: [
                          for (final e in m.examples)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: c.tintViolet,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                e,
                                style: AppTextStyles.number(
                                  18,
                                  color: c.inkViolet,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                Gap.h10,
                OkCard(
                  color: c.tintYellow,
                  child: Row(
                    children: [
                      const StarIcon(size: 34),
                      Gap.w12,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Recompensa',
                              style: TextStyle(
                                color: c.inkYellow,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              'Hasta 3 estrellas y la pieza «${pl.part}» de tu nave',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Gap.h16,
                if (!unlocked)
                  const InfoBanner(
                    icon: Icons.lock_rounded,
                    text: 'Este planeta aún está bloqueado.',
                  )
                else if (!online && !dl)
                  const InfoBanner(
                    icon: Icons.wifi_off_rounded,
                    text: 'Este planeta no está descargado. Conéctate a Internet o descárgalo desde el Centro de descargas.',
                  )
                else
                  FilledButton.icon(
                    onPressed: () {
                      ref.read(runProvider.notifier).startMission(m.id);
                      context.push(AppRoutes.play);
                    },
                    icon: const Icon(Icons.rocket_launch_rounded),
                    label: Text(st > 0 ? 'Jugar otra vez' : 'Comenzar misión'),
                  ),
                if (guest) ...[
                  Gap.h10,
                  const InfoBanner(
                    icon: Icons.visibility_rounded,
                    text: 'Modo explorar: tu resultado no se guarda.',
                  ),
                ],
                Gap.h8,
                Center(
                  child: TextButton.icon(
                    onPressed: () => context.push(AppRoutes.meetOrbi),
                    icon: const Mascot.orbi(
                      pose: 'wave',
                      size: 28,
                      semanticLabel: null,
                    ),
                    label: const Text('¿Quién es Orbi?'),
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

/// 18c · Mapa en carga (esqueleto sobre el fondo espacial).
class _MapSkeleton extends StatelessWidget {
  const _MapSkeleton();

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Brand.space,
    body: SpaceBackground(
      seed: 17,
      child: SafeArea(
        child: Semantics(
          label: 'Cargando tu universo',
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const SkeletonBox(width: 160, height: 22, dark: true),
              Gap.h8,
              const SkeletonBox(width: 240, height: 12, dark: true),
              Gap.h24,
              for (var i = 0; i < 4; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 28),
                  child: Row(
                    mainAxisAlignment: i.isOdd
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    children: const [
                      SkeletonBox(
                        width: 100,
                        height: 100,
                        radius: 50,
                        dark: true,
                      ),
                      SizedBox(width: 12),
                      SkeletonBox(
                        width: 130,
                        height: 56,
                        radius: 16,
                        dark: true,
                      ),
                    ],
                  ),
                ),
              const SlowServerNote(),
            ],
          ),
        ),
      ),
    ),
  );
}
