import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:orbita_kids/config/routes/app_routes.dart';
import 'package:orbita_kids/core/network/connectivity.dart';
import 'package:orbita_kids/config/providers/core_providers.dart';
import 'package:orbita_kids/shared/domain/content/catalog.dart';
import 'package:orbita_kids/shared/domain/entities/content.dart';
import 'package:orbita_kids/shared/presentation/widgets/skeleton.dart';
import 'package:orbita_kids/shared/presentation/widgets/ui.dart';
import 'package:orbita_kids/features/teacher/presentation/providers/teacher_state_providers.dart';
import 'package:orbita_kids/features/teacher/presentation/screens/teacher_home_screen.dart';

/// 34 · Actividades con filtros por grupo y estado.
class ActivitiesScreen extends ConsumerStatefulWidget {
  const ActivitiesScreen({super.key});

  @override
  ConsumerState<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends ConsumerState<ActivitiesScreen> {
  String? group;
  ActivityStatus? status;
  bool byDue = false;

  @override
  Widget build(BuildContext context) {
    final groups = ref.watch(groupsProvider).value ?? const [];
    final all = ref.watch(activitiesProvider);
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.createActivityPath),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Crear actividad'),
      ),
      body: OkPage(
        title: 'Actividades',
        subtitle: 'Borradores, programadas, activas y cerradas',
        showBack: false,
        children: [
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: const Text('Todos los grupos'),
                    selected: group == null,
                    onSelected: (_) => setState(() => group = null),
                  ),
                ),
                for (final g in groups)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(g.name),
                      selected: group == g.id,
                      onSelected: (_) => setState(() => group = g.id),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: const Text('Todas'),
                    selected: status == null,
                    onSelected: (_) => setState(() => status = null),
                  ),
                ),
                for (final st in ActivityStatus.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(st.label),
                      selected: status == st,
                      onSelected: (_) => setState(() => status = st),
                    ),
                  ),
                FilterChip(
                  avatar: const Icon(Icons.sort_rounded, size: 18),
                  label: const Text('Por fecha de entrega'),
                  selected: byDue,
                  onSelected: (v) => setState(() => byDue = v),
                ),
              ],
            ),
          ),
          Gap.h10,
          ...all.when(
            loading: () => [const ListSkeleton()],
            error: (e, _) => [
              InfoBanner(
                tone: Tone.err,
                text: 'No pudimos cargar las actividades.',
              ),
            ],
            data: (list) {
              var l = list
                  .where((a) => group == null || a.groupId == group)
                  .where((a) => status == null || a.status == status)
                  .toList();
              if (byDue) l = [...l]..sort((a, b) => a.due.compareTo(b.due));
              if (l.isEmpty) {
                return [
                  const InfoBanner(
                    icon: Icons.inbox_rounded,
                    text: 'No hay actividades con estos filtros.',
                  ),
                ];
              }
              return [
                for (final a in l)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ActivityCard(activity: a),
                  ),
              ];
            },
          ),
          const InfoBanner(
            icon: Icons.cloud_upload_outlined,
            text: 'Los borradores se guardan en el teléfono. Lo publicado se envía al servidor cuando hay conexión y aparece como pendiente hasta que se confirma.',
          ),
          const SizedBox(height: 70),
        ],
      ),
    );
  }
}

/// 33 · Crear actividad (borradores offline, publicar requiere Internet).
class CreateActivityScreen extends ConsumerStatefulWidget {
  const CreateActivityScreen({super.key, this.draftId, this.groupId});
  final String? draftId;
  final String? groupId;

  @override
  ConsumerState<CreateActivityScreen> createState() =>
      _CreateActivityScreenState();
}

class _CreateActivityScreenState extends ConsumerState<CreateActivityScreen> {
  final name = TextEditingController();
  final instr = TextEditingController();
  String? groupId;
  MissionType type = MissionType.visual;
  int level = 2;
  int count = 8;
  late DateTime start;
  late DateTime due;
  bool schedule = false;
  String? id;
  bool loaded = false;
  final e = <String, String>{};

  @override
  void initState() {
    super.initState();
    final now = ref.read(clockProvider)();
    start = DateTime(now.year, now.month, now.day);
    due = start.add(const Duration(days: 7));
    groupId = widget.groupId;
  }

  @override
  void dispose() {
    name.dispose();
    instr.dispose();
    super.dispose();
  }

  void _loadDraft(List<Activity> all) {
    if (loaded) return;
    loaded = true;
    if (widget.draftId == null) return;
    final d = all.where((a) => a.id == widget.draftId).firstOrNull;
    if (d == null) return;
    id = d.id;
    name.text = d.name;
    instr.text = d.instructions;
    groupId = d.groupId;
    type = d.type;
    level = d.level;
    count = d.count;
    start = d.assigned;
    due = d.due;
  }

  Activity _build() => Activity(
    id: id ??= ref.read(teacherActionsProvider).newId(),
    name: name.text.trim(),
    groupId: groupId ?? '',
    type: type,
    level: level,
    count: count,
    assigned: start,
    due: due,
    status: ActivityStatus.draft,
    done: 0,
    instructions: instr.text.trim(),
  );

  bool _validate({required bool publish}) {
    e.clear();
    if (name.text.trim().isEmpty) {
      e['name'] = 'Escribe un nombre para la actividad.';
    }
    if (publish && groupId == null) e['group'] = 'Elige el grupo.';
    if (due.isBefore(start)) {
      e['date'] = 'La entrega debe ser después del inicio.';
    }
    setState(() {});
    return e.isEmpty;
  }

  Future<void> _saveDraft() async {
    if (!_validate(publish: false)) return;
    await ref.read(teacherActionsProvider).saveDraft(_build());
    if (!mounted) return;
    toast(
      context,
      'Borrador guardado en el teléfono.',
      icon: Icons.save_rounded,
    );
    context.pop();
  }

  Future<void> _publish() async {
    if (!ref.read(onlineProvider)) {
      toast(
        context,
        'Publicar necesita Internet. Guarda un borrador y publícalo al reconectar.',
        icon: Icons.wifi_off_rounded,
      );
      return;
    }
    if (!_validate(publish: true)) return;
    final g = (ref.read(groupsProvider).value ?? const [])
        .where((x) => x.id == groupId)
        .firstOrNull;
    final ok = await confirm(
      context,
      title: schedule ? '¿Programar actividad?' : '¿Publicar actividad?',
      text:
          '«${name.text.trim()}» para ${g?.name ?? 'el grupo'} · $count ejercicios · nivel $level. '
          '${schedule ? 'Se activará el ${DateFormat('d MMM', 'es_MX').format(start)}.' : 'Los estudiantes la verán al sincronizar.'}',
      ok: schedule ? 'Programar' : 'Publicar',
    );
    if (!ok) return;
    await ref
        .read(teacherActionsProvider)
        .publish(_build(), scheduled: schedule);
    if (!mounted) return;
    toast(
      context,
      'Guardada y en cola de envío. Aparecerá como pendiente hasta que el servidor la confirme.',
      icon: Icons.cloud_upload_outlined,
    );
    context.pop();
  }

  Future<void> _pickDate(bool isStart) async {
    final d = await showDatePicker(
      context: context,
      initialDate: isStart ? start : due,
      firstDate: DateTime(2025),
      lastDate: DateTime(2028),
      helpText: isStart ? 'Fecha de inicio' : 'Fecha de entrega',
    );
    if (d != null) setState(() => isStart ? start = d : due = d);
  }

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(activitiesProvider).value;
    if (all != null) _loadDraft(all);
    final groups = ref.watch(activeGroupsProvider);
    final online = ref.watch(onlineProvider);
    final c = context.ok;
    final fmt = DateFormat("d 'de' MMM", 'es_MX');
    final g = groups.where((x) => x.id == groupId).firstOrNull;

    return OkPage(
      title: widget.draftId == null ? 'Crear actividad' : 'Continuar borrador',
      subtitle: 'Prepara y publica para tu grupo',
      children: [
        if (!online)
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: InfoBanner(
              icon: Icons.wifi_off_rounded,
              text: 'Sin conexión: puedes guardar el borrador; publicar requiere Internet.',
            ),
          ),
        TextField(
          controller: name,
          decoration: InputDecoration(
            labelText: 'Nombre de la actividad',
            hintText: 'ej. Estrellas hasta 10',
            errorText: e['name'],
          ),
        ),
        Gap.h12,
        DropdownButtonFormField<String>(
          isExpanded: true,
          initialValue: groupId,
          decoration: InputDecoration(
            labelText: 'Grupo',
            errorText: e['group'],
          ),
          items: [
            for (final g in groups)
              DropdownMenuItem(
                value: g.id,
                child: Text('Grupo ${g.name} · ${g.grade}'),
              ),
          ],
          onChanged: (v) => setState(() => groupId = v),
        ),
        Gap.h6,
        Text(
          'Destinatarios: todo el grupo${g == null ? '' : ' ${g.name}'}.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SectionTitle('Modalidad'),
        for (final t in MissionType.values)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Semantics(
              selected: type == t,
              child: OkCard(
                color: type == t ? c.tintViolet : null,
                onTap: () => setState(() => type = t),
                child: Row(
                  children: [
                    Icon(switch (t) {
                      MissionType.visual => Icons.star_rounded,
                      MissionType.choice => Icons.grid_view_rounded,
                      MissionType.mix => Icons.auto_awesome_mosaic_rounded,
                    }, color: c.purpleDark),
                    Gap.w12,
                    Expanded(
                      child: Text(
                        t.longLabel,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    Icon(
                      type == t
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_off_rounded,
                      color: c.purpleDark,
                    ),
                  ],
                ),
              ),
            ),
          ),
        const SectionTitle('Nivel'),
        SegmentedButton<int>(
          showSelectedIcon: false,
          segments: [
            for (var k = 1; k <= 6; k++)
              ButtonSegment(
                value: k,
                label: Text('$k'),
                tooltip: Catalog.level(k).name,
              ),
          ],
          selected: {level},
          onSelectionChanged: (v) => setState(() => level = v.first),
        ),
        Gap.h6,
        Text(
          Catalog.level(level).desc,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SectionTitle('Cantidad de ejercicios'),
        Row(
          children: [
            IconButton.outlined(
              tooltip: 'Menos ejercicios',
              onPressed: count > 3 ? () => setState(() => count--) : null,
              icon: const Icon(Icons.remove_rounded),
            ),
            Expanded(
              child: Semantics(
                label: '$count ejercicios',
                excludeSemantics: true,
                child: Text(
                  '$count',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.number(32, color: c.ink),
                ),
              ),
            ),
            IconButton.outlined(
              tooltip: 'Más ejercicios',
              onPressed: count < 15 ? () => setState(() => count++) : null,
              icon: const Icon(Icons.add_rounded),
            ),
          ],
        ),
        Text(
          'En la app del estudiante se presentan en bloques de hasta 6.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SectionTitle('Fechas'),
        OutlinedButton.icon(
          onPressed: () => _pickDate(true),
          icon: const Icon(Icons.event_rounded),
          label: Text('Inicio: ${fmt.format(start)}'),
        ),
        Gap.h8,
        OutlinedButton.icon(
          onPressed: () => _pickDate(false),
          icon: const Icon(Icons.event_available_rounded),
          label: Text('Entrega: ${fmt.format(due)}'),
        ),
        if (e['date'] != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              e['date']!,
              style: TextStyle(color: c.err, fontWeight: FontWeight.w700),
            ),
          ),
        Gap.h12,
        TextField(
          controller: instr,
          maxLines: 3,
          maxLength: 200,
          decoration: const InputDecoration(
            labelText: 'Instrucciones para los estudiantes',
            hintText: 'ej. Cuenta los objetos antes de responder.',
          ),
        ),
        const SectionTitle('Estado al publicar'),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: false, label: Text('Activa ahora')),
            ButtonSegment(value: true, label: Text('Programada')),
          ],
          selected: {schedule},
          onSelectionChanged: (v) => setState(() => schedule = v.first),
        ),
        const SectionTitle('Vista previa'),
        OkCard(
          color: c.tintTeal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name.text.isEmpty ? 'Nombre de la actividad' : name.text,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              Text(
                '${type.label} · ${Catalog.level(level).short} · $count ejercicios',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                'Entrega ${fmt.format(due)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (instr.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text('«${instr.text}»'),
                ),
            ],
          ),
        ),
        Gap.h16,
        FilledButton.icon(
          onPressed: _publish,
          icon: Icon(
            schedule ? Icons.schedule_send_rounded : Icons.send_rounded,
          ),
          label: Text(schedule ? 'Programar' : 'Publicar'),
        ),
        Gap.h10,
        OutlinedButton.icon(
          onPressed: _saveDraft,
          icon: const Icon(Icons.save_outlined),
          label: const Text('Guardar borrador'),
        ),
        if (id != null && widget.draftId != null) ...[
          Gap.h10,
          TextButton.icon(
            style: TextButton.styleFrom(foregroundColor: c.err),
            onPressed: () async {
              final ok = await confirm(
                context,
                title: '¿Eliminar borrador?',
                text: 'Se borrará de este teléfono.',
                ok: 'Eliminar',
                destructive: true,
              );
              if (!ok) return;
              await ref.read(teacherActionsProvider).deleteDraft(id!);
              if (context.mounted) context.pop();
            },
            icon: const Icon(Icons.delete_outline_rounded),
            label: const Text('Eliminar borrador'),
          ),
        ],
      ],
    );
  }
}
