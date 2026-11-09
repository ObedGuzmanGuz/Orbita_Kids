import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:orbita_kids/config/routes/app_routes.dart';
import 'package:orbita_kids/core/network/connectivity.dart';
import 'package:orbita_kids/features/settings/presentation/providers/settings_controller.dart';
import 'package:orbita_kids/shared/presentation/art/mascot.dart';
import 'package:orbita_kids/shared/presentation/art/space_art.dart';
import 'package:orbita_kids/shared/domain/content/catalog.dart';
import 'package:orbita_kids/shared/domain/entities/content.dart';
import 'package:orbita_kids/shared/presentation/widgets/ui.dart';
import 'package:orbita_kids/features/auth/presentation/providers/auth_controller.dart';
import 'package:orbita_kids/features/auth/presentation/widgets/auth_ui.dart';
import 'package:orbita_kids/features/notifications/presentation/widgets/notices_view.dart';
import 'package:orbita_kids/features/student/presentation/providers/student_controller.dart';
import 'package:orbita_kids/features/student/presentation/providers/student_state_providers.dart';
import 'package:orbita_kids/features/student/presentation/screens/student_home_screen.dart';

/// 16 · Mis actividades: «De mi maestra» y «Mis misiones».
class AssignedScreen extends ConsumerStatefulWidget {
  const AssignedScreen({super.key});

  @override
  ConsumerState<AssignedScreen> createState() => _AssignedScreenState();
}

class _AssignedScreenState extends ConsumerState<AssignedScreen> {
  bool teacherTab = true;

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(studentProvider);
    final tasks = ref.watch(studentTasksProvider);
    final online = ref.watch(onlineProvider);
    final c = context.ok;
    final mine = Catalog.planets
        .where((p) => s.planetUnlocked(p.id))
        .expand((p) => Catalog.missionsOf(p.id))
        .toList();
    return OkPage(
      title: 'Mis actividades',
      subtitle: 'Lo que te pide tu maestra y tus misiones',
      children: [
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(
              value: true,
              icon: Icon(Icons.assignment_rounded),
              label: Text('De mi maestra'),
            ),
            ButtonSegment(
              value: false,
              icon: Icon(Icons.rocket_launch_rounded),
              label: Text('Mis misiones'),
            ),
          ],
          selected: {teacherTab},
          onSelectionChanged: (v) => setState(() => teacherTab = v.first),
        ),
        Gap.h12,
        if (teacherTab) ...[
          const InfoBanner(
            text: 'Las tareas de la maestra tienen fecha y ella verá tus resultados.',
          ),
          Gap.h12,
          ...tasks.when(
            loading: () => [const Center(child: CircularProgressIndicator())],
            error: (e, _) => [
              InfoBanner(
                tone: Tone.err,
                text: 'No pudimos cargar las tareas: $e',
              ),
            ],
            data: (list) => list.isEmpty
                ? [
                    const InfoBanner(
                      icon: Icons.inbox_rounded,
                      text: 'Aún no tienes tareas de tu maestra.',
                    ),
                  ]
                : [
                    for (final a in list)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _TaskCard(
                          a: a,
                          done:
                              s.tasksDone.contains(a.id) ||
                              a.status == ActivityStatus.closed,
                          offline: true,
                        ),
                      ),
                  ],
          ),
          if (!online)
            Text(
              'Las tareas nuevas llegarán cuando vuelva Internet.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
        ] else
          for (final m in mine)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: OkListTile(
                leading: PlanetArt.of(Catalog.planet(m.planetId), size: 40),
                title: m.name,
                subtitle:
                    '${Catalog.planet(m.planetId).name} · ${Catalog.level(m.level).short} · ${m.type.label}',
                trailing: s.done.containsKey(m.id)
                    ? StarRow(value: s.done[m.id]!, size: 14)
                    : TagChip('Pendiente', tone: Tone.info),
                onTap: () => context.push(AppRoutes.mission(m.id)),
              ),
            ),
        Gap.h4,
        if (!teacherTab)
          Text(
            '${s.done.length} de ${Catalog.missions.length} misiones',
            style: TextStyle(color: c.muted),
          ),
      ],
    );
  }
}

class _TaskCard extends ConsumerWidget {
  const _TaskCard({required this.a, required this.done, required this.offline});
  final Activity a;
  final bool done;
  final bool offline;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.ok;
    return OkCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconBox(Icons.assignment_rounded, bg: c.tintTeal, fg: c.inkTeal),
              Gap.w12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      a.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${a.type == MissionType.visual ? 'Sumas con dibujos' : 'Elige la respuesta'} · ${Catalog.level(a.level).short} · ${a.count} ejercicios',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              TagChip(
                done ? 'Terminada' : 'Nueva',
                tone: done ? Tone.ok : Tone.info,
              ),
            ],
          ),
          Gap.h8,
          Wrap(
            spacing: 10,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Entrega ${DateFormat('d MMM', 'es_MX').format(a.due)}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              if (offline)
                const TagChip(
                  'Disponible sin Internet',
                  icon: Icons.download_done_rounded,
                  tone: Tone.mint,
                ),
            ],
          ),
          if (a.instructions.isNotEmpty) ...[
            Gap.h8,
            Text('«${a.instructions}»', style: const TextStyle(fontSize: 14.5)),
          ],
          Gap.h8,
          ProgressLine(value: done ? 1 : 0, label: 'Avance de la tarea'),
          if (!done) ...[
            Gap.h12,
            FilledButton.icon(
              onPressed: () => startTask(context, ref, a),
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Empezar'),
            ),
          ],
        ],
      ),
    );
  }
}

/// 17 · Personaliza tu astronauta (sin compras).
class AvatarScreen extends ConsumerStatefulWidget {
  const AvatarScreen({super.key});

  @override
  ConsumerState<AvatarScreen> createState() => _AvatarScreenState();
}

class _AvatarScreenState extends ConsumerState<AvatarScreen> {
  AvatarLook? sel;

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(studentProvider);
    final v = sel ??= s.look;
    final c = context.ok;
    final unl = {
      'galactico': s.doneCount('nebula') == 3,
      'cometa': s.stars >= 60,
      'insignia': s.badges.length >= 3,
      'bufanda': s.done.length >= 5,
    };
    void set(AvatarLook l) => setState(() => sel = l);
    void locked(String why) =>
        toast(context, 'Bloqueado. $why.', icon: Icons.lock_rounded);

    return OkPage(
      title: 'Tu astronauta',
      subtitle: 'Elige cómo te ves en el espacio',
      children: [
        Center(
          child: Floating(
            enabled: !reduceMotion(context, ref),
            child: Mascot(
              look: v,
              pose: 'wave',
              size: 170,
              semanticLabel: 'Vista previa de tu astronauta',
            ),
          ),
        ),
        const SectionTitle('Personaje'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final ch in AvatarCatalog.all)
              ChoiceChip(
                avatar: Mascot(
                  look: v.copyWith(character: ch.id, accessory: 'ninguno'),
                  pose: 'stand',
                  size: 30,
                ),
                label: Text(ch.name),
                selected: v.character == ch.id,
                onSelected: (_) => set(v.copyWith(character: ch.id)),
              ),
          ],
        ),
        const SectionTitle('Color del casco'),
        Wrap(
          spacing: 12,
          children: [
            for (final h in AvatarCatalog.helmets)
              Semantics(
                button: true,
                selected: v.helmet == h.$1,
                label: 'Casco ${h.$2}',
                excludeSemantics: true,
                child: InkResponse(
                  onTap: () => set(v.copyWith(helmet: h.$1)),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: h.$3,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: v.helmet == h.$1 ? c.ink : c.card,
                        width: 4,
                      ),
                    ),
                    child: v.helmet == h.$1
                        ? const Icon(Icons.check_rounded, color: Colors.white)
                        : null,
                  ),
                ),
              ),
          ],
        ),
        const SectionTitle('Trajes'),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.2,
          children: [
            for (final su in AvatarCatalog.suits)
              () {
                final isLocked = su.$5 != null && !(unl[su.$1] ?? false);
                return OkCard(
                  color: isLocked
                      ? c.tintGray
                      : (v.suit == su.$1 ? c.tintViolet : null),
                  onTap: () =>
                      isLocked ? locked(su.$5!) : set(v.copyWith(suit: su.$1)),
                  semanticLabel:
                      'Traje ${su.$2}. ${isLocked
                          ? 'Bloqueado: ${su.$5}'
                          : v.suit == su.$1
                          ? 'Puesto'
                          : 'Desbloqueado'}',
                  padding: const EdgeInsets.all(12),
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: su.$3,
                              borderRadius: AppRadius.small,
                              border: Border.all(color: su.$4, width: 3),
                            ),
                          ),
                          Gap.h6,
                          Text(
                            su.$2,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          Text(
                            isLocked
                                ? su.$5!
                                : v.suit == su.$1
                                ? 'Puesto'
                                : 'Desbloqueado',
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      if (isLocked)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Icon(Icons.lock_rounded, color: c.muted),
                        ),
                    ],
                  ),
                );
              }(),
          ],
        ),
        const SectionTitle('Expresión'),
        Wrap(
          spacing: 8,
          children: [
            for (final e in AvatarCatalog.expressions)
              ChoiceChip(
                label: Text(e.$2),
                selected: v.expression == e.$1,
                onSelected: (_) => set(v.copyWith(expression: e.$1)),
              ),
          ],
        ),
        const SectionTitle('Accesorios'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final a in AvatarCatalog.accessories)
              () {
                final isLocked = a.$3 != null && !(unl[a.$1] ?? false);
                return ChoiceChip(
                  avatar: isLocked
                      ? const Icon(Icons.lock_rounded, size: 16)
                      : null,
                  label: Text(a.$2),
                  selected: v.accessory == a.$1,
                  onSelected: (_) => isLocked
                      ? locked(a.$3!)
                      : set(v.copyWith(accessory: a.$1)),
                );
              }(),
          ],
        ),
        const SectionTitle('Recompensas desbloqueadas'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final b in Catalog.badges.where(
              (b) => s.badges.contains(b.id),
            ))
              Chip(
                avatar: const Icon(Icons.military_tech_rounded, size: 16),
                label: Text(b.name),
                backgroundColor: b.color.withValues(alpha: .35),
              ),
          ],
        ),
        Gap.h12,
        Text(
          'Los trajes se ganan con logros. En Órbita Kids no hay compras.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Gap.h14,
        FilledButton.icon(
          onPressed: () async {
            await ref.read(studentProvider.notifier).saveLook(v);
            if (!context.mounted) return;
            final guest = ref.read(authControllerProvider).isGuest;
            toast(
              context,
              guest
                  ? 'Listo. En modo explorar se usa mientras exploras y luego se borra.'
                  : '¡Personaje guardado en tu teléfono!',
              icon: Icons.check_rounded,
            );
            context.pop();
          },
          icon: const Icon(Icons.check_rounded),
          label: const Text('Guardar personaje'),
        ),
      ],
    );
  }
}

/// 25 · Perfil del estudiante.
class StudentProfileScreen extends ConsumerWidget {
  const StudentProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(studentProvider);
    final user = ref.watch(currentUserProvider);
    final next = s.nextMission();
    return OkPage(
      title: 'Mi perfil',
      showBack: false,
      children: [
        const DemoModeBanner(compact: true),
        Gap.h8,
        Center(
          child: Mascot(
            look: s.look,
            pose: 'wave',
            size: 150,
            semanticLabel: 'Tu astronauta',
          ),
        ),
        Text(
          s.name,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        Text(
          '${Catalog.level(next.level).name} · ${s.stars} estrellas',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        if (user?.institution != null)
          Text(
            user!.institution!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        Gap.h10,
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final b in Catalog.badges.where(
              (b) => s.badges.contains(b.id),
            ))
              Chip(
                avatar: const Icon(Icons.military_tech_rounded, size: 16),
                label: Text(b.name),
                backgroundColor: b.color.withValues(alpha: .35),
              ),
          ],
        ),
        SettingsGroup(
          title: 'Mi astronauta',
          children: [
            ListTile(
              leading: const Icon(Icons.brush_rounded),
              title: const Text('Personalizar astronauta'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.push(AppRoutes.avatar),
            ),
            ListTile(
              leading: const Icon(Icons.edit_rounded),
              title: const Text('Editar nombre de uso'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.push(AppRoutes.editProfile),
            ),
            ListTile(
              leading: const Icon(Icons.assignment_rounded),
              title: const Text('Mis actividades'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.push(AppRoutes.assigned),
            ),
            ListTile(
              leading: const Icon(Icons.notifications_rounded),
              title: const Text('Avisos'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.push(AppRoutes.studentNotices),
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
              leading: const Icon(Icons.accessibility_new_rounded),
              title: const Text('Accesibilidad'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.push(AppRoutes.accessibility),
            ),
            ListTile(
              leading: const Icon(Icons.download_for_offline_rounded),
              title: const Text('Descargas'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.push(AppRoutes.downloads),
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip_rounded),
              title: const Text('Privacidad'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.push(AppRoutes.privacy),
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
          style: OutlinedButton.styleFrom(foregroundColor: context.ok.err),
          onPressed: () => context.push(AppRoutes.logout),
          icon: const Icon(Icons.logout_rounded),
          label: const Text('Cerrar sesión'),
        ),
      ],
    );
  }
}

/// 24 · Avisos del estudiante.
class StudentNoticesScreen extends ConsumerWidget {
  const StudentNoticesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final st = ref.watch(settingsProvider);
    final upd = ref.read(settingsProvider.notifier).update;
    return OkPage(
      title: 'Avisos',
      subtitle: 'Lo importante, sin presión',
      children: [
        const NoticesList(),
        SettingsGroup(
          title: 'Qué avisos llegan',
          children: [
            SwitchListTile(
              title: const Text('Nuevas actividades'),
              value: st.notifActivities,
              onChanged: (v) => upd((s) => s.copyWith(notifActivities: v)),
            ),
            SwitchListTile(
              title: const Text('Resultados'),
              value: st.notifResults,
              onChanged: (v) => upd((s) => s.copyWith(notifResults: v)),
            ),
            SwitchListTile(
              title: const Text('Sincronización'),
              value: st.notifSync,
              onChanged: (v) => upd((s) => s.copyWith(notifSync: v)),
            ),
            SwitchListTile(
              title: const Text('Recordatorios de descanso'),
              value: st.notifRest,
              onChanged: (v) => upd((s) => s.copyWith(notifRest: v)),
            ),
            SwitchListTile(
              title: const Text('Horario sin avisos'),
              subtitle: const Text(
                'Ninguno entre 8:00 p. m. y 7:00 a. m. · máximo 3 al día',
              ),
              value: st.quietHours,
              onChanged: (v) => upd((s) => s.copyWith(quietHours: v)),
            ),
          ],
        ),
      ],
    );
  }
}

/// 53 · Nuevas Galaxias (próximamente, sin entrar a áreas futuras).
class GalaxiesScreen extends StatelessWidget {
  const GalaxiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.ok;
    return OkPage(
      title: 'Nuevas Galaxias',
      subtitle: 'Áreas que vienen en camino',
      children: [
        OkCard(
          color: c.tintMint,
          child: Row(
            children: [
              const PlanetArt(
                light: Color(0xFFC8F5B4),
                dark: Color(0xFF3FAE7A),
                size: 56,
                kind: PlanetKind.terra,
              ),
              Gap.w12,
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sumas',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 17,
                      ),
                    ),
                    Text('Disponible ahora · 6 planetas, 18 misiones'),
                  ],
                ),
              ),
              FilledButton(
                style: FilledButton.styleFrom(minimumSize: const Size(56, 48)),
                onPressed: () => context.go(AppRoutes.map),
                child: const Text('Jugar'),
              ),
            ],
          ),
        ),
        const SectionTitle('Próximamente'),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: .9,
          children: [
            for (final g in Catalog.galaxies)
              OkCard(
                semanticLabel:
                    '${g.name}. Próximamente. Toca para ver sus temas',
                onTap: () => showModalBottomSheet<void>(
                  context: context,
                  builder: (ctx) => SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              PlanetArt(
                                light: g.light,
                                dark: g.dark,
                                size: 60,
                                ring: true,
                              ),
                              Gap.w12,
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      g.name,
                                      style: Theme.of(ctx).textTheme.titleLarge,
                                    ),
                                    const TagChip(
                                      'Próximamente',
                                      icon: Icons.schedule_rounded,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Gap.h10,
                          Text(
                            g.desc,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          Gap.h10,
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              for (final t in g.topics) Chip(label: Text(t)),
                            ],
                          ),
                          Gap.h10,
                          Text(
                            'Aún no se puede entrar. Te avisaremos cuando esté lista.',
                            style: Theme.of(ctx).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Opacity(
                      opacity: .75,
                      child: PlanetArt(
                        light: g.light,
                        dark: g.dark,
                        size: 54,
                        ring: true,
                      ),
                    ),
                    Gap.h8,
                    Text(
                      g.name,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const Spacer(),
                    const TagChip(
                      'Próximamente',
                      icon: Icons.schedule_rounded,
                      tone: Tone.neutral,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// 59 · Conoce a Orbi, el perrito astronauta (ficha, cómo ayuda y qué nunca hace).
class MeetOrbiScreen extends ConsumerWidget {
  const MeetOrbiScreen({super.key});

  static const _intro =
      '¡Guau! Soy Orbi, tu copiloto. Vamos a sumar y explorar juntos.';

  static const _card = [
    ('Nombre', 'Orbi'),
    ('Es', 'Un perrito astronauta'),
    ('Su trabajo', 'Copiloto de tu nave'),
    ('Le encanta', 'Contar estrellas y explorar planetas'),
    ('Su casco', 'Tiene una antena para hablar con la base'),
  ];

  static const _helps = [
    (
      'think',
      'Te da pistas',
      'Cuando una suma se complica, te muestra los dibujos con números.',
    ),
    (
      'celebrate',
      'Festeja contigo',
      'Cada misión terminada merece un festejo, aunque te equivoques.',
    ),
    (
      'jump',
      'Te recuerda moverte',
      'Después de un rato te invita a una Pausa Estelar.',
    ),
    (
      'point',
      'Te muestra el camino',
      'En el mapa te señala el siguiente planeta.',
    ),
    (
      'learn',
      'Te lee en voz alta',
      'Toca «Escuchar» y Orbi lee las instrucciones.',
    ),
  ];

  static const _never = [
    'Te regaña',
    'Te apura',
    'Te pide comprar algo',
    'Te compara con otros niños',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.ok;
    return OkPage(
      title: 'Conoce a Orbi',
      subtitle: 'Tu perrito astronauta',
      children: [
        Center(
          child: Floating(
            enabled: !reduceMotion(context, ref),
            child: const Mascot.orbi(pose: 'wave', size: 170),
          ),
        ),
        Gap.h8,
        const OrbiSays(text: _intro, pose: 'cheer', size: 60),
        Center(child: SpeakButton(_intro, label: 'Escuchar a Orbi')),
        Gap.h8,
        OkCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FICHA DE ORBI',
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w900,
                  color: c.muted,
                ),
              ),
              for (final (k, v) in _card)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 96,
                        child: Text(
                          k,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          v,
                          textAlign: TextAlign.right,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SectionTitle('Cómo te ayuda'),
        for (final (pose, t, d) in _helps)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: OkCard(
              child: Row(
                children: [
                  Mascot.orbi(pose: pose, size: 48, semanticLabel: null),
                  Gap.w12,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        Text(d, style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SectionTitle('Orbi nunca…'),
        OkCard(
          child: Wrap(
            runSpacing: 10,
            children: [
              for (final n in _never)
                FractionallySizedBox(
                  widthFactor: .5,
                  child: Row(
                    children: [
                      Icon(Icons.close_rounded, size: 18, color: c.err),
                      Gap.w6,
                      Expanded(
                        child: Text(
                          n,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        Gap.h16,
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: Brand.yellow,
            foregroundColor: Brand.ink,
          ),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(AppRoutes.splash),
          icon: const Icon(Icons.rocket_launch_rounded),
          label: const Text('¡Vamos, Orbi!'),
        ),
      ],
    );
  }
}
