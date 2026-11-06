import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:orbita_kids/config/providers/core_providers.dart';
import 'package:orbita_kids/config/routes/app_routes.dart';
import 'package:orbita_kids/core/network/api_client.dart';
import 'package:orbita_kids/core/network/connectivity.dart';
import 'package:orbita_kids/shared/domain/entities/content.dart';
import 'package:orbita_kids/shared/presentation/widgets/charts.dart';
import 'package:orbita_kids/shared/presentation/widgets/skeleton.dart';
import 'package:orbita_kids/shared/presentation/widgets/ui.dart';
import 'package:orbita_kids/features/teacher/presentation/providers/teacher_state_providers.dart';
import 'package:orbita_kids/features/teacher/presentation/screens/teacher_home_screen.dart';
import 'package:orbita_kids/features/teacher/presentation/screens/teacher_shell.dart';

/// 30 · Mis grupos.
class GroupsScreen extends ConsumerStatefulWidget {
  const GroupsScreen({super.key});

  @override
  ConsumerState<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends ConsumerState<GroupsScreen> {
  String q = '';

  @override
  Widget build(BuildContext context) {
    final groups = ref.watch(groupsProvider);
    final online = ref.watch(onlineProvider);
    final available = ref.watch(teacherDataAvailableProvider);
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => online
            ? showGroupSheet(context, ref)
            : toast(
                context,
                'Crear un grupo necesita Internet.',
                icon: Icons.wifi_off_rounded,
              ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Crear grupo'),
      ),
      body: OkPage(
        title: 'Mis grupos',
        subtitle: 'Los códigos vienen de la licencia de tu escuela',
        showBack: false,
        children: [
          if (!available) const BackendPendingNotice(what: 'Tus grupos'),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Buscar grupo',
              prefixIcon: Icon(Icons.search_rounded),
            ),
            onChanged: (v) => setState(() => q = v),
          ),
          Gap.h12,
          ...groups.when(
            loading: () => [const ListSkeleton()],
            error: (e, _) => [
              InfoBanner(tone: Tone.err, text: 'No pudimos cargar los grupos.'),
            ],
            data: (list) => [
              for (final g in list.where(
                (g) => g.name.toLowerCase().contains(q.toLowerCase()),
              ))
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _GroupCard(group: g),
                ),
            ],
          ),
          const SizedBox(height: 70),
        ],
      ),
    );
  }
}

class _GroupCard extends ConsumerWidget {
  const _GroupCard({required this.group});
  final SchoolGroup group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final g = group;
    final n = ref.watch(studentsOfProvider(g.id)).value?.length ?? 0;
    final c = context.ok;
    final active = g.status == GroupStatus.active;
    return OkCard(
      onTap: () => context.push(AppRoutes.group(g.id)),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: active ? c.tintViolet : c.tintGray,
              borderRadius: AppRadius.field,
            ),
            child: Text(
              g.name,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: active ? c.inkViolet : c.muted,
              ),
            ),
          ),
          Gap.w12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Grupo ${g.name}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '${g.grade} · $n estudiantes',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Gap.h4,
                TagChip(
                  active ? 'Activo' : 'Archivado',
                  tone: active ? Tone.ok : Tone.neutral,
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text(g.code, style: AppTextStyles.number(15, color: c.ink)),
              IconButton(
                tooltip: 'Copiar código ${g.code}',
                icon: const Icon(Icons.copy_rounded, size: 20),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: g.code));
                  toast(
                    context,
                    'Código ${g.code} copiado.',
                    icon: Icons.check_rounded,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Hoja para crear o editar un grupo.
Future<void> showGroupSheet(
  BuildContext context,
  WidgetRef ref, {
  SchoolGroup? edit,
}) async {
  final name = TextEditingController(text: edit?.name);
  final grade = TextEditingController(text: edit?.grade ?? '2.º de primaria');
  String? err;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setS) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          0,
          20,
          20 + MediaQuery.viewInsetsOf(ctx).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              edit == null ? 'Crear grupo' : 'Editar grupo',
              style: Theme.of(ctx).textTheme.titleLarge,
            ),
            Gap.h12,
            TextField(
              controller: name,
              decoration: InputDecoration(
                labelText: 'Nombre del grupo',
                hintText: 'ej. 2° C',
                errorText: err,
              ),
            ),
            Gap.h10,
            TextField(
              controller: grade,
              decoration: const InputDecoration(labelText: 'Grado'),
            ),
            Gap.h8,
            if (edit == null)
              Text(
                'El código del grupo lo asigna la licencia de tu escuela.',
                style: Theme.of(ctx).textTheme.bodySmall,
              ),
            Gap.h14,
            FilledButton(
              onPressed: () async {
                if (name.text.trim().isEmpty) {
                  setS(() => err = 'Escribe el nombre del grupo.');
                  return;
                }
                final actions = ref.read(teacherActionsProvider);
                try {
                  if (edit == null) {
                    final g = await actions.createGroup(
                      name.text.trim(),
                      grade.text.trim(),
                    );
                    if (ctx.mounted) {
                      Navigator.pop(ctx);
                      toast(
                        context,
                        ref.read(appConfigProvider).usesServer
                            ? 'Grupo ${g.name} creado · código ${g.code}.'
                            : 'Grupo ${g.name} creado · código ${g.code} (demo).',
                        icon: Icons.check_rounded,
                      );
                    }
                  } else {
                    await actions.updateGroup(
                      edit.copyWith(
                        name: name.text.trim(),
                        grade: grade.text.trim(),
                      ),
                    );
                    if (ctx.mounted) Navigator.pop(ctx);
                  }
                } on ServerRejected catch (e) {
                  setS(() => err = e.message);
                } on BackendUnavailable {
                  setS(
                    () => err = ref.read(appConfigProvider).usesServer
                        ? 'No hay conexión con el servidor. Inténtalo de nuevo.'
                        : 'Esta acción necesita el servidor de Órbita Kids (pendiente).',
                  );
                }
              },
              child: Text(edit == null ? 'Crear grupo' : 'Guardar cambios'),
            ),
          ],
        ),
      ),
    ),
  );
}

/// 31 · Detalle del grupo.
class GroupDetailScreen extends ConsumerStatefulWidget {
  const GroupDetailScreen({super.key, required this.groupId});
  final String groupId;

  @override
  ConsumerState<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends ConsumerState<GroupDetailScreen> {
  int tab = 0;
  StudentStatus? filter;
  String q = '';
  bool sortAcc = false;

  @override
  Widget build(BuildContext context) {
    final groups = ref.watch(groupsProvider).value ?? const [];
    final g = groups.where((x) => x.id == widget.groupId).firstOrNull;
    if (g == null) {
      return const OkPage(
        title: 'Grupo',
        children: [InfoBanner(text: 'No encontramos este grupo.')],
      );
    }
    final students = ref.watch(studentsOfProvider(g.id)).value ?? const [];
    final acts = (ref.watch(activitiesProvider).value ?? const [])
        .where((a) => a.groupId == g.id)
        .toList();
    final avg = students.isEmpty
        ? 0
        : (students.fold<int>(0, (a, s) => a + s.accuracy) / students.length)
              .round();
    final pend = students.fold<int>(0, (a, s) => a + s.pending);
    var list = students
        .where((s) => filter == null || s.status == filter)
        .where((s) => s.name.toLowerCase().contains(q.toLowerCase()))
        .toList();
    if (sortAcc) {
      list = [...list]..sort((a, b) => a.accuracy.compareTo(b.accuracy));
    }

    return OkPage(
      title: 'Grupo ${g.name}',
      subtitle: '${g.grade} · código ${g.code}',
      actions: [
        if (g.status == GroupStatus.active)
          IconButton(
            tooltip: 'Editar grupo',
            onPressed: () => showGroupSheet(context, ref, edit: g),
            icon: const Icon(Icons.edit_rounded),
          ),
      ],
      children: [
        StatGrid(
          tiles: [
            StatTile(value: '${students.length}', label: 'estudiantes'),
            StatTile(value: '$avg%', label: 'aciertos promedio'),
            StatTile(
              value:
                  '${acts.where((a) => a.status == ActivityStatus.active).length}',
              label: 'actividades activas',
            ),
            StatTile(value: '$pend', label: 'pendientes'),
          ],
        ),
        Gap.h12,
        if (g.status == GroupStatus.active)
          FilledButton.icon(
            onPressed: () =>
                context.push(AppRoutes.createActivity(groupId: g.id)),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Asignar actividad'),
          )
        else
          const InfoBanner(
            text: 'Grupo archivado: solo consulta. El ciclo escolar terminó.',
          ),
        Gap.h12,
        SegmentedButton<int>(
          segments: const [
            ButtonSegment(
              value: 0,
              icon: Icon(Icons.people_rounded),
              label: Text('Estudiantes'),
            ),
            ButtonSegment(
              value: 1,
              icon: Icon(Icons.assignment_rounded),
              label: Text('Actividades'),
            ),
          ],
          selected: {tab},
          onSelectionChanged: (v) => setState(() => tab = v.first),
        ),
        Gap.h12,
        if (tab == 0) ...[
          TextField(
            decoration: const InputDecoration(
              labelText: 'Buscar estudiante',
              prefixIcon: Icon(Icons.search_rounded),
            ),
            onChanged: (v) => setState(() => q = v),
          ),
          Gap.h8,
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              ChoiceChip(
                label: const Text('Todos'),
                selected: filter == null,
                onSelected: (_) => setState(() => filter = null),
              ),
              for (final st in [
                StudentStatus.needsSupport,
                StudentStatus.inactive,
                StudentStatus.upToDate,
              ])
                ChoiceChip(
                  label: Text(st.label),
                  selected: filter == st,
                  onSelected: (_) => setState(() => filter = st),
                ),
              FilterChip(
                avatar: const Icon(Icons.sort_rounded, size: 18),
                label: const Text('Menos aciertos primero'),
                selected: sortAcc,
                onSelected: (v) => setState(() => sortAcc = v),
              ),
            ],
          ),
          Gap.h10,
          if (list.isEmpty)
            const InfoBanner(text: 'Ningún estudiante coincide con el filtro.'),
          for (final s in list)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: OkListTile(
                leading: InitialsAvatar(name: s.name, color: s.color),
                title: s.name,
                subtitle: '${s.accuracy}% aciertos · ${s.pending} pendientes',
                trailing: TagChip(
                  s.status.label,
                  tone: switch (s.status) {
                    StudentStatus.needsSupport => Tone.warn,
                    StudentStatus.inactive => Tone.neutral,
                    StudentStatus.finished => Tone.info,
                    StudentStatus.upToDate => Tone.ok,
                  },
                ),
                onTap: () => context.push(AppRoutes.studentDetail(s.id)),
              ),
            ),
        ] else ...[
          if (acts.isEmpty)
            const InfoBanner(text: 'Este grupo aún no tiene actividades.'),
          for (final a in acts)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ActivityCard(activity: a),
            ),
        ],
      ],
    );
  }
}

/// 32 · Detalle del estudiante (sin diagnósticos).
class StudentDetailScreen extends ConsumerWidget {
  const StudentDetailScreen({super.key, required this.studentId});
  final String studentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(studentProviderById(studentId)).value;
    final weeks = ref.watch(trendLabelsProvider);
    if (s == null) {
      return const OkPage(
        title: 'Estudiante',
        children: [InfoBanner(text: 'No encontramos a este estudiante.')],
      );
    }
    final c = context.ok;
    final fmt = DateFormat('d MMM', 'es_MX');
    // Con servidor: los intentos que recibió. En modo demo: intentos de
    // demostración con identificador.
    final attempts = ref.watch(appConfigProvider).usesServer
        ? [
            for (final a in s.recent)
              (a.id, a.title, '${a.ok}/${a.total}', fmt.format(a.date)),
          ]
        : [
      for (var i = 0; i < 5; i++)
        (
          'att-${s.id}-${(s.operations * 7 + i * 13).toRadixString(16).padLeft(4, '0')}',
          [
            'Estrellas hasta 10',
            'Recoge estrellas',
            'Sumas hasta 20',
            'Repara la antena',
            'Señal a la Tierra',
          ][i],
          '${(s.accuracy / 20).round().clamp(1, 5)}/5',
          weeks.isEmpty ? '' : weeks[weeks.length - 1 - (i % weeks.length)],
        ),
          ];
    return OkPage(
      title: s.name,
      subtitle: 'Acompañamiento individual',
      children: [
        Row(
          children: [
            InitialsAvatar(name: s.name, color: s.color, size: 64),
            Gap.w12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TagChip(
                    s.status.label,
                    tone: s.status == StudentStatus.needsSupport
                        ? Tone.warn
                        : Tone.ok,
                  ),
                  Gap.h4,
                  Text(
                    s.lastDays == null
                        ? 'Aún no hay intentos registrados'
                        : 'Última actividad hace ${s.lastDays} días',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
        Gap.h12,
        StatGrid(
          tiles: [
            StatTile(
              value: '${s.accuracy}%',
              label: 'aciertos al primer intento',
            ),
            StatTile(value: '${s.operations}', label: 'sumas resueltas'),
            StatTile(value: '${s.missed}', label: 'errores este mes'),
            StatTile(value: '${s.pending}', label: 'actividades pendientes'),
          ],
        ),
        const SectionTitle('Evolución'),
        OkCard(
          child: LineChart(
            values: s.trend,
            labels: weeks,
            label:
                'Evolución de aciertos de ${s.name}: ${s.trend.join(', ')} por ciento',
          ),
        ),
        const SectionTitle('Errores frecuentes'),
        if (s.errors.isEmpty)
          Text(
            'Aún no hay datos de errores frecuentes.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        for (final e in s.errors)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: OkListTile(
              leading: IconBox(
                Icons.lightbulb_outline_rounded,
                bg: c.tintYellow,
                fg: c.inkYellow,
              ),
              title: e,
            ),
          ),
        const SectionTitle('Intentos recientes'),
        if (attempts.isEmpty)
          Text(
            'Todavía no llegan intentos de este estudiante.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        for (final a in attempts)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: OkListTile(
              title: a.$2,
              subtitle: s.recent.isEmpty
                  ? 'ID ${a.$1} · semana del ${a.$4}'
                  : 'ID ${a.$1.substring(0, 8)} · ${a.$4}',
              trailing: Text(
                a.$3,
                style: AppTextStyles.number(16, color: c.ink),
              ),
            ),
          ),
        const SectionTitle('Recomendaciones'),
        InfoBanner(
          icon: Icons.auto_awesome_rounded,
          text: s.status == StudentStatus.needsSupport
              ? s.errors.isEmpty
                    ? 'Refuerzo sugerido. Una actividad corta con apoyo visual puede ayudar (regla R4).'
                    : 'Refuerzo sugerido en «${s.errors.first}». Una actividad corta con apoyo visual puede ayudar (regla R4).'
              : 'Va al día. Puedes proponerle el siguiente nivel cuando acierte 90 % o más (regla R2).',
        ),
        Gap.h6,
        Text(
          'Estas son sugerencias pedagógicas, no diagnósticos.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Gap.h14,
        FilledButton.icon(
          onPressed: () =>
              context.push(AppRoutes.createActivity(groupId: s.groupId)),
          icon: const Icon(Icons.add_task_rounded),
          label: const Text('Asignar refuerzo'),
        ),
      ],
    );
  }
}
