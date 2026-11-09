import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:orbita_kids/config/routes/app_routes.dart';
import 'package:orbita_kids/features/settings/presentation/providers/settings_controller.dart';
import 'package:orbita_kids/shared/domain/entities/content.dart';
import 'package:orbita_kids/shared/presentation/widgets/charts.dart';
import 'package:orbita_kids/shared/presentation/widgets/ui.dart';
import 'package:orbita_kids/features/auth/presentation/providers/auth_controller.dart';
import 'package:orbita_kids/features/auth/presentation/widgets/auth_ui.dart';
import 'package:orbita_kids/features/notifications/presentation/widgets/notices_view.dart';
import 'package:orbita_kids/features/teacher/domain/usecases/groups_usecases.dart';
import 'package:orbita_kids/features/teacher/presentation/providers/teacher_state_providers.dart';
import 'package:orbita_kids/features/teacher/presentation/screens/teacher_shell.dart';

/// 35 · Resultados y reportes (legible en teléfono, sin tablas anchas).
class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  String? groupId;
  int weeks = 6;

  @override
  Widget build(BuildContext context) {
    final groups = ref.watch(activeGroupsProvider);
    final available = ref.watch(teacherDataAvailableProvider);
    final gid = groupId ?? (groups.isEmpty ? null : groups.first.id);
    final students = gid == null
        ? const <StudentSummary>[]
        : ref.watch(studentsOfProvider(gid)).value ?? const [];
    final acts = (ref.watch(activitiesProvider).value ?? const [])
        .where((a) => a.groupId == gid)
        .toList();
    final avg = students.isEmpty
        ? 0
        : (students.fold<int>(0, (a, s) => a + s.accuracy) / students.length)
              .round();
    final done = acts.fold<int>(0, (a, x) => a + x.done);
    final pend = students.fold<int>(0, (a, s) => a + s.pending);
    final ops = students.fold<int>(0, (a, s) => a + s.operations);
    final week = const WeeklyAverage().call(students);
    final shown = week.length > weeks
        ? week.sublist(week.length - weeks)
        : week;
    final allWeeks = ref.watch(trendLabelsProvider);
    final labels = allWeeks.length >= shown.length
        ? allWeeks.sublist(allWeeks.length - shown.length)
        : List.filled(shown.length, '');
    final errCount = <String, int>{};
    for (final s in students) {
      for (final e in s.errors) {
        errCount[e] = (errCount[e] ?? 0) + 1;
      }
    }
    final errs = errCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final support = students
        .where((s) => s.status == StudentStatus.needsSupport)
        .toList();
    final c = context.ok;

    return OkPage(
      title: 'Resultados y reportes',
      subtitle: 'Desempeño del grupo',
      showBack: false,
      children: [
        if (!available) const BackendPendingNotice(what: 'Los reportes'),
        if (groups.isNotEmpty)
          DropdownButtonFormField<String>(
            isExpanded: true,
            initialValue: gid,
            decoration: const InputDecoration(labelText: 'Grupo'),
            items: [
              for (final g in groups)
                DropdownMenuItem(value: g.id, child: Text('Grupo ${g.name}')),
            ],
            onChanged: (v) => setState(() => groupId = v),
          ),
        Gap.h10,
        SegmentedButton<int>(
          segments: const [
            ButtonSegment(value: 2, label: Text('2 semanas')),
            ButtonSegment(value: 4, label: Text('4 semanas')),
            ButtonSegment(value: 6, label: Text('6 semanas')),
          ],
          selected: {weeks},
          onSelectionChanged: (v) => setState(() => weeks = v.first),
        ),
        Gap.h12,
        StatGrid(
          tiles: [
            StatTile(value: '$avg%', label: 'aciertos al primer intento'),
            StatTile(value: '$done', label: 'actividades completadas'),
            StatTile(value: '$pend', label: 'pendientes'),
            StatTile(value: '$ops', label: 'intentos registrados'),
          ],
        ),
        if (shown.isNotEmpty) ...[
          const SectionTitle('Evolución'),
          OkCard(
            child: LineChart(
              values: shown,
              labels: labels,
              label:
                  'Aciertos promedio del grupo por semana: ${shown.join(', ')} por ciento',
            ),
          ),
        ],
        if (errs.isNotEmpty) ...[
          const SectionTitle('Errores frecuentes'),
          OkCard(
            child: Column(
              children: [
                for (final e in errs.take(5))
                  HBar(
                    label: e.key,
                    value: e.value,
                    max: students.length,
                    suffix: ' est.',
                    color: Brand.orange,
                  ),
              ],
            ),
          ),
        ],
        if (acts.isNotEmpty) ...[
          const SectionTitle('Participación por actividad'),
          OkCard(
            child: Column(
              children: [
                for (final a in acts)
                  HBar(
                    label: a.name,
                    value: a.done,
                    max: students.length,
                    suffix: '/${students.length}',
                  ),
              ],
            ),
          ),
        ],
        const SectionTitle('Necesitan refuerzo'),
        if (support.isEmpty)
          const InfoBanner(
            tone: Tone.ok,
            icon: Icons.check_circle_rounded,
            text: 'Nadie necesita refuerzo por ahora.',
          ),
        for (final s in support)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: OkListTile(
              leading: InitialsAvatar(name: s.name, color: s.color),
              title: s.name,
              subtitle: s.errors.isEmpty
                  ? '${s.accuracy}% de aciertos'
                  : '${s.accuracy}% · ${s.errors.first}',
              trailing: TextButton(
                onPressed: () =>
                    context.push(AppRoutes.createActivity(groupId: s.groupId)),
                child: const Text('Asignar'),
              ),
              onTap: () => context.push(AppRoutes.studentDetail(s.id)),
            ),
          ),
        Gap.h8,
        Text(
          'Sin rankings ni comparaciones entre estudiantes.',
          style: TextStyle(color: c.muted, fontSize: 13),
        ),
      ],
    );
  }
}

/// 36 · Avisos del docente.
class TeacherNoticesScreen extends ConsumerWidget {
  const TeacherNoticesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final st = ref.watch(settingsProvider);
    final upd = ref.read(settingsProvider.notifier).update;
    return OkPage(
      title: 'Avisos',
      subtitle: 'Lo relevante de tus grupos',
      children: [
        const NoticesList(),
        SettingsGroup(
          title: 'Ajustes de avisos',
          children: [
            SwitchListTile(
              title: const Text('Actividades y entregas'),
              value: st.notifActivities,
              onChanged: (v) => upd((s) => s.copyWith(notifActivities: v)),
            ),
            SwitchListTile(
              title: const Text('Resultados y sugerencias (R4)'),
              value: st.notifResults,
              onChanged: (v) => upd((s) => s.copyWith(notifResults: v)),
            ),
            SwitchListTile(
              title: const Text('Sincronización'),
              value: st.notifSync,
              onChanged: (v) => upd((s) => s.copyWith(notifSync: v)),
            ),
            SwitchListTile(
              title: const Text('Información de grupos'),
              value: st.notifGroups,
              onChanged: (v) => upd((s) => s.copyWith(notifGroups: v)),
            ),
          ],
        ),
      ],
    );
  }
}

/// 37 · Perfil docente.
class TeacherProfileScreen extends ConsumerWidget {
  const TeacherProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final u = ref.watch(currentUserProvider);
    final groups = ref.watch(activeGroupsProvider);
    final c = context.ok;
    return OkPage(
      title: 'Mi perfil',
      showBack: false,
      children: [
        const DemoModeBanner(compact: true),
        Gap.h10,
        Center(
          child: InitialsAvatar(
            name: u?.name ?? '',
            color: Brand.turquoiseDark,
            size: 84,
          ),
        ),
        Gap.h8,
        Text(
          u?.name ?? '',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        if (u?.email != null)
          Text(
            u!.email!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        Text(
          '${u?.institution ?? 'Institución'} · ${groups.length} grupos',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Gap.h6,
        Center(
          child: TagChip(
            'Acceso: ${u?.methodLabel ?? ''}',
            icon: Icons.verified_user_rounded,
          ),
        ),
        Gap.h12,
        OkCard(
          color: c.tintTeal,
          child: Row(
            children: [
              Icon(Icons.laptop_chromebook_rounded, color: c.inkTeal, size: 32),
              Gap.w12,
              const Expanded(
                child: Text(
                  'PWA docente: la versión de escritorio para planear y revisar reportes se publicará junto con el backend.',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
        SettingsGroup(
          title: 'Cuenta',
          children: [
            ListTile(
              leading: const Icon(Icons.edit_rounded),
              title: const Text('Editar perfil'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.push(AppRoutes.editProfile),
            ),
            ListTile(
              leading: const Icon(Icons.groups_rounded),
              title: const Text('Mis grupos'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.go(AppRoutes.groups),
            ),
            ListTile(
              leading: const Icon(Icons.workspace_premium_rounded),
              title: const Text('Planes institucionales'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.push(AppRoutes.plans),
            ),
            ListTile(
              leading: const Icon(Icons.notifications_rounded),
              title: const Text('Avisos'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.push(AppRoutes.teacherNotices),
            ),
          ],
        ),
        SettingsGroup(
          title: 'Ajustes',
          children: [
            ListTile(
              leading: const Icon(Icons.settings_rounded),
              title: const Text('Configuración'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.push(AppRoutes.settings),
            ),
            ListTile(
              leading: const Icon(Icons.sync_rounded),
              title: const Text('Sincronización'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.push(AppRoutes.sync),
            ),
            ListTile(
              leading: const Icon(Icons.shield_rounded),
              title: const Text('Seguridad y sesiones'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.push(AppRoutes.security),
            ),
            ListTile(
              leading: const Icon(Icons.help_rounded),
              title: const Text('Ayuda'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.push(AppRoutes.help),
            ),
          ],
        ),
        Gap.h16,
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(foregroundColor: c.err),
          onPressed: () => context.push(AppRoutes.logout),
          icon: const Icon(Icons.logout_rounded),
          label: const Text('Cerrar sesión'),
        ),
      ],
    );
  }
}
