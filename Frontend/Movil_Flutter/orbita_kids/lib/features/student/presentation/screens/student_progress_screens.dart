import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:orbita_kids/config/routes/app_routes.dart';
import 'package:orbita_kids/shared/presentation/art/mascot.dart';
import 'package:orbita_kids/shared/presentation/art/space_art.dart';
import 'package:orbita_kids/shared/domain/content/catalog.dart';
import 'package:orbita_kids/shared/presentation/widgets/charts.dart';
import 'package:orbita_kids/shared/presentation/widgets/ui.dart';
import 'package:orbita_kids/features/student/presentation/providers/student_controller.dart';
import 'package:orbita_kids/features/student/presentation/providers/student_state_providers.dart';

/// 23 · Mi progreso (tú contra tú, sin rankings).
class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(studentProvider);
    final next = s.nextMission();
    final pl = Catalog.planet(next.planetId);
    final okT = s.history.fold<int>(0, (a, h) => a + h.ok);
    final totT = s.history.fold<int>(0, (a, h) => a + h.total);
    final acc = s.sessionAccuracy;
    final diff = acc.length > 1 ? acc.last - acc.first : 0;
    final pend = ref.watch(pendingTasksProvider);
    final c = context.ok;

    return OkPage(
      title: 'Mi progreso',
      subtitle: 'Tu avance comparado contigo',
      showBack: false,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Brand.indigo, Brand.indigo2],
            ),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            children: [
              Mascot(look: s.look, pose: 'stand', size: 64),
              Gap.w12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nivel actual',
                      style: TextStyle(
                        color: Brand.lavender,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      Catalog.level(next.level).name,
                      style: Theme.of(context).textTheme.titleLarge
                          ?.copyWith(color: Colors.white),
                    ),
                    Gap.h8,
                    ProgressLine(
                      value: s.doneCount(pl.id) / 3,
                      track: Colors.white24,
                      label: 'Avance del planeta',
                    ),
                    Gap.h4,
                    Text(
                      '${s.doneCount(pl.id)} de 3 misiones de ${pl.name}',
                      style: const TextStyle(
                        color: Brand.lavender,
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Gap.h12,
        StatGrid(
          tiles: [
            StatTile(value: '${s.done.length}', label: 'misiones completadas'),
            StatTile(
              value: '${totT == 0 ? 0 : (okT * 100 / totT).round()}%',
              label: 'aciertos al primer intento',
            ),
            StatTile(value: '${s.history.length}', label: 'actividades hechas'),
            StatTile(value: '${s.stars}', label: 'estrellas reunidas'),
          ],
        ),
        SectionTitle(
          'Tú contra tú',
          action: acc.isEmpty ? null : 'últimas ${acc.length}',
        ),
        OkCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                acc.isEmpty
                    ? 'Juega tu primera misión para ver tu avance.'
                    : diff > 0
                    ? 'Ahora aciertas $diff puntos más que al principio. ¡Vas mejorando!'
                    : 'Sigue practicando: cada misión cuenta.',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              if (acc.isNotEmpty) ...[Gap.h12, SelfBars(values: acc)],
            ],
          ),
        ),
        const SectionTitle('Por planeta'),
        OkCard(
          child: Column(
            children: [
              for (final p in Catalog.planets)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      PlanetArt.of(p, size: 30),
                      Gap.w10,
                      Expanded(
                        child: HBar(
                          label: p.name,
                          value: s.doneCount(p.id),
                          max: 3,
                          suffix: '/3',
                          color: p.dark,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        if (pend.isNotEmpty) ...[
          SectionTitle(
            'Pendientes',
            action: 'Ver',
            onAction: () => context.push(AppRoutes.assigned),
          ),
          for (final a in pend)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: OkListTile(
                leading: IconBox(
                  Icons.assignment_rounded,
                  bg: c.tintTeal,
                  fg: c.inkTeal,
                ),
                title: a.name,
                subtitle:
                    'Entrega ${DateFormat('d MMM', 'es_MX').format(a.due)}',
                onTap: () => context.push(AppRoutes.assigned),
              ),
            ),
        ],
        const SectionTitle('Recomendación'),
        OkCard(
          child: Row(
            children: [
              IconBox(
                Icons.auto_awesome_rounded,
                bg: c.tintYellow,
                fg: c.inkYellow,
              ),
              Gap.w12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.lowStreak >= 1
                          ? 'Practica con dibujos: cuenta con calma'
                          : 'Sigue con «${next.name}»',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    Text(
                      s.lowStreak >= 2
                          ? 'Por tus últimos resultados · regla R4'
                          : Catalog.level(next.level).desc,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              FilledButton(
                style: FilledButton.styleFrom(minimumSize: const Size(56, 48)),
                onPressed: () => context.push(AppRoutes.mission(next.id)),
                child: const Text('Ir'),
              ),
            ],
          ),
        ),
        const SectionTitle('Insignias'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final b in Catalog.badges)
              Semantics(
                label:
                    '${b.name}: ${b.desc}. ${s.badges.contains(b.id) ? 'Ganada' : 'Por ganar'}',
                excludeSemantics: true,
                child: Container(
                  width: 104,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: s.badges.contains(b.id)
                        ? b.color.withValues(alpha: .25)
                        : c.tintGray,
                    borderRadius: AppRadius.field,
                  ),
                  child: Column(
                    children: [
                      Icon(
                        s.badges.contains(b.id)
                            ? Icons.military_tech_rounded
                            : Icons.lock_outline_rounded,
                        color: s.badges.contains(b.id) ? c.ink : c.muted,
                        size: 30,
                      ),
                      Gap.h4,
                      Text(
                        b.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SectionTitle('Historial'),
        if (s.history.isEmpty)
          const InfoBanner(text: 'Aquí aparecerán tus misiones terminadas.'),
        for (final h in s.history.take(10))
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: OkListTile(
              title: h.name,
              subtitle:
                  '${DateFormat('d MMM', 'es_MX').format(h.date)} · ${h.ok}/${h.total} al primer intento',
              trailing: StarRow(value: h.stars),
            ),
          ),
      ],
    );
  }
}
