import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:orbita_kids/config/routes/app_routes.dart';
import 'package:orbita_kids/core/audio/speech.dart';
import 'package:orbita_kids/core/network/api_client.dart';
import 'package:orbita_kids/core/network/connectivity.dart';
import 'package:orbita_kids/config/providers/core_providers.dart';
import 'package:orbita_kids/core/sync/domain/sync_models.dart';
import 'package:orbita_kids/core/sync/presentation/providers/sync_controller.dart';
import 'package:orbita_kids/features/settings/presentation/providers/settings_controller.dart';
import 'package:orbita_kids/shared/presentation/art/mascot.dart';
import 'package:orbita_kids/shared/presentation/widgets/ui.dart';
import 'package:orbita_kids/features/auth/presentation/providers/auth_controller.dart';
import 'package:orbita_kids/features/auth/domain/entities/auth_entities.dart';
import 'package:orbita_kids/features/student/presentation/providers/student_controller.dart';

/// 41 · Configuración.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final upd = ref.read(settingsProvider.notifier).update;
    final user = ref.watch(currentUserProvider);
    ListTile link(IconData i, String t, String route, {String? sub}) =>
        ListTile(
          leading: Icon(i),
          title: Text(t),
          subtitle: sub == null ? null : Text(sub),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => context.push(route),
        );
    return OkPage(
      title: 'Configuración',
      children: [
        SettingsGroup(
          title: 'Apariencia',
          children: [
            link(
              Icons.palette_rounded,
              'Tema',
              AppRoutes.theme,
              sub: switch (s.theme) {
                AppThemeChoice.auto => 'Automático',
                AppThemeChoice.light => 'Claro',
                AppThemeChoice.dark => 'Oscuro',
              },
            ),
            const ListTile(
              leading: Icon(Icons.language_rounded),
              title: Text('Idioma'),
              subtitle: Text('Español (México)'),
            ),
            link(
              Icons.accessibility_new_rounded,
              'Accesibilidad',
              AppRoutes.accessibility,
              sub: 'Texto, contraste, movimiento, lectura',
            ),
          ],
        ),
        SettingsGroup(
          title: 'Sonido',
          children: [
            SwitchListTile(
              secondary: const Icon(Icons.vibration_rounded),
              title: const Text('Efectos al responder'),
              subtitle: const Text('Vibración suave al acertar o fallar'),
              value: s.sounds,
              onChanged: (v) => upd((x) => x.copyWith(sounds: v)),
            ),
            ListTile(
              leading: const Icon(Icons.volume_up_rounded),
              title: const Text('Volumen de lectura'),
              subtitle: Slider(
                value: s.volume.toDouble(),
                max: 100,
                divisions: 10,
                label: '${s.volume}',
                semanticFormatterCallback: (v) => '${v.round()} por ciento',
                onChanged: (v) => upd((x) => x.copyWith(volume: v.round())),
              ),
            ),
          ],
        ),
        SettingsGroup(
          title: 'Avisos y datos',
          children: [
            link(
              Icons.notifications_rounded,
              'Avisos',
              user?.role == UserRole.teacher
                  ? AppRoutes.teacherNotices
                  : AppRoutes.studentNotices,
            ),
            if (user?.role != UserRole.teacher)
              link(
                Icons.download_for_offline_rounded,
                'Descargas',
                AppRoutes.downloads,
              ),
            SwitchListTile(
              secondary: const Icon(Icons.wifi_rounded),
              title: const Text('Descargar solo con wifi'),
              value: s.wifiOnlyDownloads,
              onChanged: (v) => upd((x) => x.copyWith(wifiOnlyDownloads: v)),
            ),
            link(
              Icons.wifi_tethering_rounded,
              'Estado de conexión',
              AppRoutes.connection,
            ),
            if (user != null)
              link(Icons.sync_rounded, 'Sincronización', AppRoutes.sync),
          ],
        ),
        SettingsGroup(
          title: 'Cuenta y seguridad',
          children: [
            link(Icons.privacy_tip_rounded, 'Privacidad', AppRoutes.privacy),
            if (user != null)
              link(
                Icons.shield_rounded,
                'Seguridad y sesiones',
                AppRoutes.security,
              ),
            if (user != null)
              link(Icons.edit_rounded, 'Editar perfil', AppRoutes.editProfile),
          ],
        ),
        SettingsGroup(
          title: 'Información',
          children: [
            link(Icons.help_rounded, 'Ayuda y soporte', AppRoutes.help),
            link(Icons.info_rounded, 'Acerca de Órbita Kids', AppRoutes.about),
            link(
              Icons.rocket_launch_rounded,
              'Órbita Kids Studios',
              AppRoutes.aboutStudios,
            ),
            link(
              Icons.description_rounded,
              'Términos y condiciones',
              AppRoutes.terms,
            ),
          ],
        ),
        if (user != null) ...[
          Gap.h16,
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(foregroundColor: context.ok.err),
            onPressed: () => context.push(AppRoutes.logout),
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Cerrar sesión'),
          ),
        ],
        Gap.h8,
        Text(
          'Las preferencias se guardan en este teléfono.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

/// 42 · Accesibilidad: cambios visibles al instante en toda la app.
class AccessibilityScreen extends ConsumerWidget {
  const AccessibilityScreen({super.key});

  static const _sizes = [
    (1.0, 'Normal'),
    (1.15, 'Grande'),
    (1.3, 'Muy grande'),
    (1.5, 'Máxima'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final upd = ref.read(settingsProvider.notifier).update;
    final c = context.ok;
    return OkPage(
      title: 'Accesibilidad',
      subtitle: 'Adapta Órbita Kids a ti',
      children: [
        OkCard(
          color: c.tintViolet,
          child: Row(
            children: [
              const Mascot.orbi(pose: 'learn', size: 64, semanticLabel: null),
              Gap.w10,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vista previa',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const Text(
                      '¿Cuánto es 3 + 2?',
                      style: TextStyle(
                        fontFamily: kDisplayFont,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Text('Así se verán los textos de la app.'),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SectionTitle('Tamaño de texto'),
        SegmentedButton<double>(
          showSelectedIcon: false,
          segments: [
            for (final z in _sizes)
              ButtonSegment(value: z.$1, label: Text(z.$2)),
          ],
          selected: {
            _sizes.map((e) => e.$1).contains(s.textScale) ? s.textScale : 1.0,
          },
          onSelectionChanged: (v) => upd((x) => x.copyWith(textScale: v.first)),
        ),
        Gap.h6,
        Text(
          'Se suma al tamaño de letra del sistema.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        SettingsGroup(
          title: 'Ver y moverse',
          children: [
            SwitchListTile(
              secondary: const Icon(Icons.contrast_rounded),
              title: const Text('Alto contraste'),
              subtitle: const Text('Bordes y textos más marcados'),
              value: s.highContrast,
              onChanged: (v) => upd((x) => x.copyWith(highContrast: v)),
            ),
            SwitchListTile(
              secondary: const Icon(Icons.motion_photos_off_rounded),
              title: const Text('Movimiento reducido'),
              subtitle: const Text('Sin flotación ni rebotes'),
              value: s.reducedMotion,
              onChanged: (v) => upd((x) => x.copyWith(reducedMotion: v)),
            ),
            const ListTile(
              leading: Icon(Icons.category_rounded),
              title: Text('Refuerzo con símbolos'),
              subtitle: Text(
                'Siempre activo: los estados usan ícono y texto además de color',
              ),
            ),
          ],
        ),
        SettingsGroup(
          title: 'Escuchar',
          children: [
            SwitchListTile(
              secondary: const Icon(Icons.record_voice_over_rounded),
              title: const Text('Leer instrucciones en voz alta'),
              subtitle: const Text('Al empezar cada ejercicio'),
              value: s.readAloud,
              onChanged: (v) => upd((x) => x.copyWith(readAloud: v)),
            ),
            ListTile(
              leading: const Icon(Icons.play_circle_rounded),
              title: const Text('Probar lectura'),
              onTap: () =>
                  ref.speak('Hola, soy Orbi. ¿Cuánto es tres más dos?'),
            ),
          ],
        ),
        SettingsGroup(
          title: 'Tema',
          children: [
            ListTile(
              leading: const Icon(Icons.palette_rounded),
              title: const Text('Claro, oscuro o automático'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.push(AppRoutes.theme),
            ),
          ],
        ),
        Gap.h14,
        OutlinedButton.icon(
          onPressed: () {
            ref.read(settingsProvider.notifier).restoreAccessibility();
            toast(
              context,
              'Ajustes restaurados.',
              icon: Icons.restart_alt_rounded,
            );
          },
          icon: const Icon(Icons.restart_alt_rounded),
          label: const Text('Restaurar'),
        ),
        Gap.h8,
        Text(
          'Compatible con TalkBack y VoiceOver: los botones, dibujos y gráficos tienen descripciones.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

/// 43 · Apariencia: claro, oscuro o automático.
class ThemeScreen extends ConsumerWidget {
  const ThemeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final upd = ref.read(settingsProvider.notifier).update;
    Widget preview(bool dark) {
      final t = buildTheme(dark: dark, highContrast: s.highContrast);
      final c = t.extension<OkColors>()!;
      return Expanded(
        child: Semantics(
          label: dark
              ? 'Vista previa del tema oscuro'
              : 'Vista previa del tema claro',
          excludeSemantics: true,
          child: Container(
            height: 170,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: c.bg,
              borderRadius: AppRadius.card,
              border: Border.all(color: c.line, width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 36,
                  decoration: BoxDecoration(
                    color: Brand.indigo,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Gap.h8,
                Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: c.card,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: c.line),
                  ),
                ),
                const Spacer(),
                Container(
                  height: 26,
                  decoration: BoxDecoration(
                    color: dark ? Brand.violet : Brand.purple,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Gap.h6,
                Text(
                  dark ? 'Oscuro' : 'Claro',
                  style: TextStyle(color: c.ink, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return OkPage(
      title: 'Apariencia',
      children: [
        Row(children: [preview(false), Gap.w12, preview(true)]),
        Gap.h16,
        RadioGroup<AppThemeChoice>(
          groupValue: s.theme,
          onChanged: (v) => upd((x) => x.copyWith(theme: v)),
          child: const Column(
            children: [
              RadioListTile(
                value: AppThemeChoice.auto,
                title: Text('Automático'),
                subtitle: Text('Sigue al sistema'),
              ),
              RadioListTile(value: AppThemeChoice.light, title: Text('Claro')),
              RadioListTile(value: AppThemeChoice.dark, title: Text('Oscuro')),
            ],
          ),
        ),
      ],
    );
  }
}

/// 44 · Editar perfil.
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController name;
  String? err;

  @override
  void initState() {
    super.initState();
    final u = ref.read(currentUserProvider);
    final st = ref.read(studentProvider);
    name = TextEditingController(
      text: u?.role == UserRole.student ? st.name : u?.name,
    );
  }

  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final v = name.text.trim();
    final student = ref.read(currentUserProvider)?.role == UserRole.student;
    if (v.length < 2) {
      setState(() => err = 'Escribe al menos 2 letras.');
      return;
    }
    if (student && v.contains(' ') && v.split(' ').length > 2) {
      setState(() => err = 'Usa solo tu nombre o un apodo, sin apellidos.');
      return;
    }
    if (student) await ref.read(studentProvider.notifier).rename(v);
    await ref.read(authControllerProvider.notifier).updateUserName(v);
    final server = ref.read(appConfigProvider).usesServer;
    if (server) {
      await ref
          .read(syncControllerProvider.notifier)
          .enqueue(
            kind: SyncKind.profile,
            owner: ref.read(ownerIdProvider),
            title: 'Perfil: $v',
            detail: 'Nuevo nombre visible',
            payload: {'name': v},
          );
    }
    if (!mounted) return;
    toast(
      context,
      server
          ? 'Guardado. Se enviará al servidor.'
          : 'Guardado en este teléfono.',
      icon: Icons.check_rounded,
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final u = ref.watch(currentUserProvider);
    final student = u?.role == UserRole.student;
    final look = ref.watch(studentProvider).look;
    return OkPage(
      title: 'Editar perfil',
      children: [
        Center(
          child: student
              ? Mascot(
                  look: look,
                  pose: 'wave',
                  size: 120,
                  semanticLabel: 'Tu astronauta',
                )
              : InitialsAvatar(
                  name: u?.name ?? '',
                  color: Brand.turquoiseDark,
                  size: 84,
                ),
        ),
        if (student)
          Center(
            child: TextButton(
              onPressed: () => context.push(AppRoutes.avatar),
              child: const Text('Cambiar astronauta'),
            ),
          ),
        Gap.h12,
        TextField(
          controller: name,
          decoration: InputDecoration(
            labelText: student ? 'Nombre de uso' : 'Nombre visible',
            helperText: student ? 'Solo tu nombre de pila o un apodo.' : null,
            errorText: err,
          ),
          onChanged: (_) => setState(() => err = null),
        ),
        Gap.h14,
        InfoBanner(
          icon: Icons.lock_outline_rounded,
          text: student
              ? 'Tu usuario y tu escuela los administra la institución.'
              : 'El correo (${u?.email ?? '—'}) y la institución vienen de tu proveedor de acceso y no se editan aquí.',
        ),
        Gap.h16,
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => context.pop(),
                child: const Text('Cancelar'),
              ),
            ),
            Gap.w10,
            Expanded(
              child: FilledButton(
                onPressed: _save,
                child: const Text('Guardar'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// 46 · Seguridad y sesiones.
class SecurityScreen extends ConsumerWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final u = auth.user;
    final online = ref.watch(onlineProvider);
    final demo = ref.watch(appConfigProvider).isDemo;
    final c = context.ok;
    return OkPage(
      title: 'Seguridad y sesiones',
      children: [
        OkCard(
          child: Row(
            children: [
              IconBox(
                Icons.verified_user_rounded,
                bg: c.tintViolet,
                fg: c.purpleDark,
              ),
              Gap.w12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Método vinculado',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      u?.methodLabel ?? '—',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    Text(
                      auth.session?.demo ?? true
                          ? 'Sesión de demostración (sin tokens)'
                          : 'Tokens guardados de forma cifrada en el teléfono',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SectionTitle('Dispositivos con sesión'),
        const OkListTile(
          leading: Icon(Icons.smartphone_rounded),
          title: 'Este teléfono',
          subtitle: 'Sesión activa ahora',
          trailing: TagChip('Actual', tone: Tone.ok),
        ),
        Gap.h6,
        Text(
          'La lista completa de dispositivos llegará del servidor cuando esté disponible.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Gap.h14,
        OutlinedButton.icon(
          onPressed: () {
            if (!online) {
              toast(
                context,
                'Cerrar otras sesiones necesita Internet.',
                icon: Icons.wifi_off_rounded,
              );
            } else {
              toast(
                context,
                ApiEndpoints.sessions == null
                    ? 'Esta acción necesita el servidor de Órbita Kids (pendiente).'
                    : 'Solicitud enviada.',
                icon: Icons.info_outline_rounded,
              );
            }
          },
          icon: const Icon(Icons.devices_other_rounded),
          label: const Text('Cerrar otras sesiones'),
        ),
        Gap.h10,
        if (u?.method == AuthMethod.orbita)
          OutlinedButton.icon(
            onPressed: () => context.push(AppRoutes.recover),
            icon: const Icon(Icons.password_rounded),
            label: const Text('Cambiar contraseña'),
          )
        else
          Text(
            'Tu contraseña se administra en ${u?.methodLabel ?? 'tu proveedor'}.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        if (demo) ...[
          const SectionTitle('Herramientas de demostración'),
          OutlinedButton.icon(
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).expire();
              if (context.mounted) context.go(AppRoutes.authState('expired'));
            },
            icon: const Icon(Icons.timer_off_rounded),
            label: const Text('Simular sesión vencida'),
          ),
        ],
      ],
    );
  }
}
