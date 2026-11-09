import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:orbita_kids/config/routes/app_routes.dart';
import 'package:orbita_kids/core/network/connectivity.dart';
import 'package:orbita_kids/core/sync/providers/sync_providers.dart';
import 'package:orbita_kids/core/sync/domain/sync_models.dart';
import 'package:orbita_kids/core/sync/presentation/providers/sync_controller.dart';
import 'package:orbita_kids/shared/presentation/art/mascot.dart';
import 'package:orbita_kids/shared/presentation/art/space_art.dart';
import 'package:orbita_kids/shared/domain/content/catalog.dart';
import 'package:orbita_kids/shared/presentation/widgets/ui.dart';
import 'package:orbita_kids/features/auth/presentation/providers/auth_controller.dart';
import 'package:orbita_kids/features/auth/domain/entities/auth_entities.dart';
import 'package:orbita_kids/features/student/presentation/providers/student_controller.dart';

/// 38 · Estado de conexión: qué funciona con y sin Internet.
class ConnectionScreen extends ConsumerWidget {
  const ConnectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final online = ref.watch(onlineProvider);
    final user = ref.watch(currentUserProvider);
    final sync = ref.watch(syncControllerProvider);
    final pending = user == null ? 0 : sync.of(user.id).length;
    final student = user?.role != UserRole.teacher;
    final c = context.ok;
    final offline = student
        ? [
            'Jugar misiones de planetas descargados',
            'Pausa Estelar',
            'Ver tu progreso',
            'Personalizar tu astronauta',
            'Guardar resultados para enviarlos después',
          ]
        : [
            'Consultar grupos y resultados sincronizados',
            'Crear borradores de actividades',
            'Ver avisos guardados',
          ];
    final needs = student
        ? [
            'Entrar por primera vez',
            'Recibir tareas nuevas',
            'Descargar planetas',
            'Enviar resultados a tu maestra',
          ]
        : [
            'Publicar actividades',
            'Crear grupos',
            'Recibir resultados nuevos',
            'Cerrar otras sesiones',
          ];
    return OkPage(
      title: 'Estado de conexión',
      children: [
        Center(
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: online ? c.okBg : c.tintGray,
              shape: BoxShape.circle,
            ),
            child: Icon(
              online ? Icons.wifi_rounded : Icons.wifi_off_rounded,
              size: 56,
              color: online ? c.ok : c.muted,
            ),
          ),
        ),
        Gap.h10,
        Semantics(
          liveRegion: true,
          child: Text(
            online
                ? 'Tienes conexión'
                : (student ? '¡Podemos seguir sin Internet!' : 'Sin conexión'),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        Text(
          pending == 0
              ? 'No hay registros pendientes.'
              : '$pending registro${pending == 1 ? '' : 's'} esperando enviarse.',
          textAlign: TextAlign.center,
          style: TextStyle(color: c.muted),
        ),
        const SectionTitle('Funciona sin Internet'),
        OkCard(
          child: Column(
            children: [
              for (final t in offline)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_rounded, color: c.ok),
                      Gap.w8,
                      Expanded(child: Text(t)),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SectionTitle('Necesita Internet'),
        OkCard(
          child: Column(
            children: [
              for (final t in needs)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(Icons.cloud_rounded, color: c.muted),
                      Gap.w8,
                      Expanded(child: Text(t)),
                    ],
                  ),
                ),
            ],
          ),
        ),
        Gap.h12,
        Text(
          sync.lastSync == null
              ? 'Última sincronización confirmada: ninguna todavía.'
              : 'Última sincronización confirmada: ${DateFormat('d MMM, HH:mm', 'es_MX').format(sync.lastSync!)}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Gap.h14,
        if (user != null) ...[
          if (student)
            OutlinedButton.icon(
              onPressed: () => context.push(AppRoutes.downloads),
              icon: const Icon(Icons.download_rounded),
              label: const Text('Ver descargas'),
            ),
          Gap.h10,
          FilledButton.icon(
            onPressed: () => context.push(AppRoutes.sync),
            icon: const Icon(Icons.sync_rounded),
            label: const Text('Sincronización'),
          ),
        ],
      ],
    );
  }
}

/// 39 · Centro de descargas (contenido para usar sin Internet).
class DownloadsScreen extends ConsumerWidget {
  const DownloadsScreen({super.key});

  static const _mb = {
    'uno': 12.4,
    'nebula': 14.1,
    'saturnia': 15.8,
    'cometa': 16.2,
    'rubi': 17.1,
    'galaxia': 18.0,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(studentProvider);
    final online = ref.watch(onlineProvider);
    final c = context.ok;
    final used =
        s.downloads.fold<double>(0, (a, id) => a + (_mb[id] ?? 0)) + 3.8;
    const total = 200.0;
    return OkPage(
      title: 'Centro de descargas',
      subtitle: 'Contenido disponible sin Internet',
      children: [
        OkCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${used.toStringAsFixed(1)} MB usados de ${total.toInt()} MB reservados',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              Gap.h8,
              ProgressLine(value: used / total, label: 'Espacio usado'),
              Gap.h6,
              Text(
                'Las misiones vienen incluidas en la app; «descargar» las marca como disponibles sin Internet.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        if (!online) ...[
          Gap.h10,
          const InfoBanner(
            icon: Icons.wifi_off_rounded,
            text: 'Descargar o actualizar necesita Internet. Puedes eliminar descargas sin conexión.',
          ),
        ],
        const SectionTitle('Planetas'),
        for (final p in Catalog.planets)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: OkListTile(
              leading: PlanetArt.of(p, size: 40),
              title: p.name,
              subtitle: s.isDownloaded(p.id)
                  ? '${_mb[p.id]} MB · disponible sin Internet'
                  : '${_mb[p.id]} MB · ${s.planetUnlocked(p.id) ? 'no descargado' : 'bloqueado'}',
              trailing: s.isDownloaded(p.id)
                  ? IconButton(
                      tooltip: 'Eliminar descarga de ${p.name}',
                      icon: Icon(Icons.delete_outline_rounded, color: c.err),
                      onPressed: () async {
                        final ok = await confirm(
                          context,
                          title: '¿Eliminar la descarga?',
                          text:
                              '${p.name} dejará de estar disponible sin Internet. Tu progreso no se borra.',
                          ok: 'Eliminar',
                          destructive: true,
                        );
                        if (ok) {
                          ref
                              .read(studentProvider.notifier)
                              .setDownloaded(p.id, false);
                        }
                      },
                    )
                  : IconButton(
                      tooltip: 'Descargar ${p.name}',
                      icon: const Icon(Icons.download_rounded),
                      onPressed: !online
                          ? null
                          : () {
                              ref
                                  .read(studentProvider.notifier)
                                  .setDownloaded(p.id, true);
                              toast(
                                context,
                                '${p.name} disponible sin Internet.',
                                icon: Icons.download_done_rounded,
                              );
                            },
                    ),
            ),
          ),
        const SectionTitle('Incluido siempre'),
        const OkListTile(
          leading: Mascot.orbi(pose: 'jump', size: 40, semanticLabel: null),
          title: 'Pausa Estelar',
          subtitle: '3.2 MB · incluida en la app',
        ),
        Gap.h8,
        const OkListTile(
          leading: Icon(Icons.assignment_rounded),
          title: 'Tareas de la maestra',
          subtitle: 'Se guardan al sincronizar',
        ),
        Gap.h10,
        Text(
          'Si una descarga es pesada, pide ayuda a un adulto y usa wifi.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

/// 40 · Sincronización: cola con ID único. Solo se retiran los confirmados.
class SyncScreen extends ConsumerWidget {
  const SyncScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final sync = ref.watch(syncControllerProvider);
    final online = ref.watch(onlineProvider);
    final gateway = ref.watch(syncGatewayProvider);
    final items = user == null ? const <SyncItem>[] : sync.of(user.id);
    final done = sync.confirmed.where((r) => r.owner == user?.id).toList();
    final c = context.ok;
    final noBackend = items.any((i) => !gateway.supports(i.kind));
    final fmt = DateFormat('d MMM, HH:mm', 'es_MX');

    return OkPage(
      title: 'Sincronización',
      subtitle: 'Registros guardados en el teléfono',
      children: [
        Row(
          children: [
            Icon(
              sync.running
                  ? Icons.sync_rounded
                  : online
                  ? Icons.cloud_rounded
                  : Icons.cloud_off_rounded,
              color: c.purpleDark,
              size: 30,
            ),
            Gap.w10,
            Expanded(
              child: Text(
                sync.running
                    ? 'Sincronizando…'
                    : items.isEmpty
                    ? 'Todo al día: no hay registros pendientes.'
                    : '${items.length} pendiente${items.length == 1 ? '' : 's'} en este teléfono.',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        if (noBackend && items.isNotEmpty) ...[
          Gap.h10,
          const InfoBanner(
            tone: Tone.warn,
            icon: Icons.dns_outlined,
            title: 'Servidor pendiente',
            text: 'El servidor de Órbita Kids aún no está disponible. Tus registros siguen guardados y protegidos en el teléfono; no se marcan como enviados hasta que el servidor los confirme.',
          ),
        ],
        Gap.h12,
        FilledButton.icon(
          onPressed: !online || items.isEmpty || sync.running
              ? null
              : () => ref
                    .read(syncControllerProvider.notifier)
                    .syncNow(force: true, owner: user?.id),
          icon: const Icon(Icons.sync_rounded),
          label: Text(online ? 'Sincronizar ahora' : 'Sin conexión'),
        ),
        const SectionTitle('Pendientes'),
        if (items.isEmpty)
          const InfoBanner(
            tone: Tone.ok,
            icon: Icons.check_circle_rounded,
            text: 'Nada por enviar.',
          ),
        for (final it in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: OkCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          it.title,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                      TagChip(
                        switch (it.status) {
                          SyncStatus.pending => 'Pendiente',
                          SyncStatus.syncing => 'Sincronizando',
                          SyncStatus.error => 'Error',
                          SyncStatus.conflict => 'Conflicto',
                        },
                        tone: switch (it.status) {
                          SyncStatus.pending => Tone.warn,
                          SyncStatus.syncing => Tone.info,
                          SyncStatus.error || SyncStatus.conflict => Tone.err,
                        },
                      ),
                    ],
                  ),
                  Text(
                    '${it.kind.label} · ${it.detail}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  SelectableText(
                    'ID ${it.id}',
                    style: TextStyle(fontSize: 12, color: c.muted),
                  ),
                  Text(
                    'Creado ${fmt.format(it.createdAt)}${it.attempts > 0 ? ' · ${it.attempts} intento${it.attempts == 1 ? '' : 's'}' : ''}',
                    style: TextStyle(fontSize: 12, color: c.muted),
                  ),
                  if (it.lastError != null) ...[
                    Gap.h4,
                    Text(
                      it.lastError!,
                      style: TextStyle(
                        color: c.err,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                  if (it.nextRetryAt != null && it.status == SyncStatus.error)
                    Text(
                      'Reintento automático: ${fmt.format(it.nextRetryAt!)}',
                      style: TextStyle(fontSize: 12, color: c.muted),
                    ),
                  if (it.status == SyncStatus.error) ...[
                    Gap.h6,
                    OutlinedButton(
                      onPressed: online
                          ? () => ref
                                .read(syncControllerProvider.notifier)
                                .syncNow(force: true, owner: user?.id)
                          : null,
                      child: const Text('Reintentar'),
                    ),
                  ],
                  if (it.status == SyncStatus.conflict) ...[
                    Gap.h6,
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => ref
                                .read(syncControllerProvider.notifier)
                                .keepMine(it.id),
                            child: const Text('Enviar mi versión'),
                          ),
                        ),
                        Gap.w8,
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              final ok = await confirm(
                                context,
                                title: '¿Descartar tu versión?',
                                text: 'Se conservará la versión del servidor y se eliminará la de este teléfono.',
                                ok: 'Descartar',
                                destructive: true,
                              );
                              if (ok) {
                                ref
                                    .read(syncControllerProvider.notifier)
                                    .discard(it.id);
                              }
                            },
                            child: const Text('Usar la del servidor'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        const SectionTitle('Confirmados por el servidor'),
        if (done.isEmpty)
          Text(
            'Aquí aparecerán los registros que el servidor confirme.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        for (final r in done.take(20))
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: OkListTile(
              leading: Icon(Icons.check_circle_rounded, color: c.ok),
              title: r.title,
              subtitle:
                  '${r.kind.label} · ${fmt.format(r.at)} · ID ${r.id.substring(0, 8)}',
            ),
          ),
        Gap.h8,
        Text(
          'Nunca se sobrescribe con datos antiguos: los conflictos se revisan aquí.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
