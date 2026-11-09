import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:orbita_kids/config/routes/app_routes.dart';
import 'package:orbita_kids/config/providers/core_providers.dart';
import 'package:orbita_kids/core/sync/presentation/providers/sync_controller.dart';
import 'package:orbita_kids/shared/domain/entities/content.dart';
import 'package:orbita_kids/shared/presentation/widgets/charts.dart';
import 'package:orbita_kids/shared/presentation/widgets/ui.dart';
import 'package:orbita_kids/features/auth/presentation/providers/auth_controller.dart';
import 'package:orbita_kids/features/auth/presentation/widgets/auth_ui.dart';
import 'package:orbita_kids/features/teacher/domain/usecases/groups_usecases.dart';
import 'package:orbita_kids/features/teacher/presentation/providers/teacher_state_providers.dart';
import 'package:orbita_kids/features/teacher/presentation/screens/teacher_shell.dart';

/// 29 · Home docente.
class TeacherHomeScreen extends ConsumerWidget {
  const TeacherHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final students = ref.watch(allStudentsProvider).value ?? const [];
    final acts = ref.watch(activitiesProvider).value ?? const [];
    final groups = ref.watch(activeGroupsProvider);
    final available = ref.watch(teacherDataAvailableProvider);
    final sync = ref.watch(syncControllerProvider);
    final now = ref.read(clockProvider)();
    final c = context.ok;
    final active = acts
        .where((a) => a.status == ActivityStatus.active)
        .toList();
    final support = students
        .where((s) => s.status == StudentStatus.needsSupport)
        .toList();
    final avg = students.isEmpty
        ? 0
        : (students.fold<int>(0, (a, s) => a + s.accuracy) / students.length)
              .round();
    final week = const WeeklyAverage().call(students);
    final lastSync = sync.lastSync;

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Brand.indigo, Brand.indigo2]),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 8, 20),
                child: Row(
                  children: [
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
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                          Semantics(
                            header: true,
                            child: Text(
                              'Hola, ${user?.name.split(' ').first ?? ''}',
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(color: Colors.white),
                            ),
                          ),
                          Text(
                            '${groups.length} grupos activos · ${user?.institution ?? 'Tu institución'}',
                            style: const TextStyle(
                              color: Brand.lavender,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Avisos',
                      color: Colors.white,
                      onPressed: () => context.push(AppRoutes.teacherNotices),
                      icon: const Icon(Icons.notifications_rounded),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const DemoModeBanner(compact: true),
                if (!available)
                  const BackendPendingNotice(
                    what: 'Tus grupos, estudiantes y resultados',
                  ),
                Gap.h10,
                StatGrid(
                  tiles: [
                    StatTile(
                      value: '${students.length}',
                      label: 'estudiantes activos',
                    ),
                    StatTile(value: '$avg%', label: 'aciertos promedio'),
                    StatTile(
                      value: '${active.length}',
                      label: 'actividades activas',
                    ),
                    StatTile(
                      value: '${support.length}',
                      label: 'necesitan apoyo',
                    ),
                  ],
                ),
                if (week.isNotEmpty) ...[
                  const SectionTitle('Aciertos por semana'),
                  OkCard(
                    child: LineChart(
                      values: week,
                      labels: ref.watch(trendLabelsProvider),
                      label:
                          'Aciertos promedio por semana: ${week.join(', ')} por ciento',
                    ),
                  ),
                ],
                const SectionTitle('Accesos rápidos'),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 2.3,
                  children: [
                    _Quick(
                      Icons.add_circle_rounded,
                      'Crear actividad',
                      c.tintViolet,
                      c.inkViolet,
                      () => context.push(AppRoutes.createActivityPath),
                    ),
                    _Quick(
                      Icons.groups_rounded,
                      'Grupos',
                      c.tintTeal,
                      c.inkTeal,
                      () => context.go(AppRoutes.groups),
                    ),
                    _Quick(
                      Icons.insights_rounded,
                      'Resultados',
                      c.tintYellow,
                      c.inkYellow,
                      () => context.go(AppRoutes.reports),
                    ),
                    _Quick(
                      Icons.notifications_rounded,
                      'Avisos',
                      c.tintMint,
                      c.inkMint,
                      () => context.push(AppRoutes.teacherNotices),
                    ),
                  ],
                ),
                if (support.isNotEmpty) ...[
                  const SectionTitle('Para acompañar'),
                  for (final s in support.take(3))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: OkListTile(
                        leading: InitialsAvatar(name: s.name, color: s.color),
                        title: s.name,
                        subtitle: s.errors.isEmpty
                            ? '${s.accuracy}% de aciertos'
                            : '${s.accuracy}% de aciertos · ${s.errors.first}',
                        trailing: const TagChip('Refuerzo', tone: Tone.warn),
                        onTap: () =>
                            context.push(AppRoutes.studentDetail(s.id)),
                      ),
                    ),
                ],
                SectionTitle(
                  'Actividades en curso',
                  action: 'Ver todas',
                  onAction: () => context.go(AppRoutes.activities),
                ),
                if (active.isEmpty)
                  const InfoBanner(
                    icon: Icons.inbox_rounded,
                    text: 'No hay actividades activas.',
                  ),
                for (final a in active.take(3))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ActivityCard(activity: a),
                  ),
                Gap.h10,
                Row(
                  children: [
                    Icon(Icons.cloud_done_outlined, size: 18, color: c.muted),
                    Gap.w6,
                    Expanded(
                      child: Text(
                        lastSync == null
                            ? 'Aún no hay sincronizaciones confirmadas por el servidor.'
                            : 'Última sincronización confirmada: ${DateFormat('d MMM, HH:mm', 'es_MX').format(lastSync)}',
                        style: Theme.of(context).textTheme.bodySmall,
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

class _Quick extends StatelessWidget {
  const _Quick(this.icon, this.label, this.bg, this.fg, this.onTap);
  final IconData icon;
  final String label;
  final Color bg;
  final Color fg;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => OkCard(
    color: bg,
    onTap: onTap,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    child: Row(
      children: [
        Icon(icon, color: fg),
        Gap.w8,
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: context.ok.ink,
            ),
          ),
        ),
      ],
    ),
  );
}

/// Tarjeta de actividad con participación y estado de envío.
class ActivityCard extends ConsumerWidget {
  const ActivityCard({super.key, required this.activity});
  final Activity activity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final a = activity;
    final groups = ref.watch(groupsProvider).value ?? const [];
    final g = groups.where((x) => x.id == a.groupId).firstOrNull;
    final total = ref.watch(studentsOfProvider(a.groupId)).value?.length ?? 0;
    final tone = switch (a.status) {
      ActivityStatus.draft => Tone.neutral,
      ActivityStatus.scheduled => Tone.warn,
      ActivityStatus.active => Tone.ok,
      ActivityStatus.closed => Tone.info,
    };
    return OkCard(
      onTap: a.status == ActivityStatus.draft
          ? () => context.push(AppRoutes.createActivity(draftId: a.id))
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  a.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
              TagChip(a.status.label, tone: tone),
            ],
          ),
          Gap.h4,
          Text(
            '${g?.name ?? 'Grupo'} · ${a.type.longLabel} · nivel ${a.level} · ${a.count} ejercicios',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Text(
            'Entrega ${DateFormat('d MMM', 'es_MX').format(a.due)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (a.status == ActivityStatus.active ||
              a.status == ActivityStatus.closed) ...[
            Gap.h8,
            ProgressLine(
              value: total == 0 ? 0 : a.done / total,
              label: 'Participación',
            ),
            Gap.h4,
            Text(
              '${a.done} de $total terminaron',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          if (a.pendingSync) ...[
            Gap.h8,
            const TagChip(
              'Pendiente de envío al servidor',
              icon: Icons.cloud_upload_outlined,
              tone: Tone.warn,
            ),
          ],
          if (a.status == ActivityStatus.draft) ...[
            Gap.h8,
            const TagChip(
              'Borrador en el teléfono · toca para continuar',
              icon: Icons.edit_note_rounded,
              tone: Tone.neutral,
            ),
          ],
        ],
      ),
    );
  }
}
