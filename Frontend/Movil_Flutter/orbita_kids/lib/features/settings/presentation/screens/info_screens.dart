import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:orbita_kids/config/routes/app_routes.dart';
import 'package:orbita_kids/config/providers/core_providers.dart';
import 'package:orbita_kids/core/sync/domain/sync_models.dart';
import 'package:orbita_kids/core/sync/presentation/providers/sync_controller.dart';
import 'package:orbita_kids/shared/presentation/art/mascot.dart';
import 'package:orbita_kids/shared/domain/content/catalog.dart';
import 'package:orbita_kids/shared/presentation/widgets/ui.dart';
import 'package:orbita_kids/features/auth/presentation/providers/auth_controller.dart';

const appVersion = '1.0.0';

/// 50 · Acerca de Órbita Kids.
class AboutAppScreen extends ConsumerWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cfg = ref.watch(appConfigProvider);
    final c = context.ok;
    return OkPage(
      title: 'Acerca de Órbita Kids',
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Brand.indigo,
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Center(child: BrandLogo(width: 220)),
        ),
        Gap.h14,
        const Text(
          'Órbita Kids es una app para que niñas y niños de primaria practiquen sumas explorando planetas, con apoyo visual, retroalimentación amable y pausas para moverse fuera de la pantalla.',
          style: TextStyle(fontSize: 16),
        ),
        const SectionTitle('Cómo se aprende'),
        OkCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Misiones',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              const Text(
                '6 planetas con 3 misiones cada uno. Al completar un planeta se abre el siguiente y se gana una pieza de la nave.',
              ),
              Gap.h10,
              const Text(
                'Modalidades',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              const Text(
                'A · Sumas con apoyo visual y teclado. B · Selección entre 4 opciones. Mixta: ambas.',
              ),
              Gap.h10,
              Text(
                'Estrellas',
                style: const TextStyle(fontWeight: FontWeight.w900),
                semanticsLabel: 'Estrellas',
              ),
              const Text(
                '3 estrellas con 80 % o más al primer intento, 2 con 60 % o más y 1 por terminar. Nunca hay mensajes negativos.',
              ),
            ],
          ),
        ),
        const SectionTitle('Niveles'),
        for (final l in Catalog.levels.values)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: OkListTile(
              leading: CircleAvatar(
                backgroundColor: c.tintViolet,
                child: Text(
                  '${l.n}',
                  style: TextStyle(
                    color: c.inkViolet,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              title: l.name,
              subtitle: l.desc,
            ),
          ),
        const SectionTitle('Reglas de adaptación'),
        for (final r in Catalog.rules)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: OkListTile(
              leading: TagChip(r.$1),
              title: r.$2,
              subtitle: r.$3,
            ),
          ),
        const SectionTitle('Beneficios'),
        const OkCard(
          child: Text(
            'Práctica a su ritmo · Funciona sin Internet · Accesible (texto grande, alto contraste, lectura en voz alta) · Seguimiento para docentes sin rankings · Bienestar digital con Pausa Estelar.',
          ),
        ),
        const SectionTitle('Versión'),
        OkCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Órbita Kids $appVersion',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              Text(
                cfg.devServer
                    ? 'Modo demo con servidor de desarrollo: ${cfg.apiBaseUrl}'
                    : cfg.isDemo
                    ? 'Modo demo (Keycloak sin configurar)'
                    : 'Conectado a Keycloak: ${cfg.keycloakIssuer}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (cfg.missing.isNotEmpty)
                Text(
                  'Configuración pendiente: ${cfg.missing.join(', ')}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
        ),
        Gap.h10,
        Row(
          children: [
            TextButton(
              onPressed: () => context.push(AppRoutes.aboutStudios),
              child: const Text('Órbita Kids Studios'),
            ),
            TextButton(
              onPressed: () => context.push(AppRoutes.terms),
              child: const Text('Términos'),
            ),
            TextButton(
              onPressed: () => showLicensePage(
                context: context,
                applicationName: 'Órbita Kids',
                applicationVersion: appVersion,
              ),
              child: const Text('Licencias'),
            ),
          ],
        ),
      ],
    );
  }
}

/// 51 · Órbita Kids Studios.
class AboutStudiosScreen extends StatelessWidget {
  const AboutStudiosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const areas = [
      (
        Icons.school_rounded,
        'Pedagogía',
        'Diseño de misiones, niveles y reglas de adaptación.',
      ),
      (
        Icons.brush_rounded,
        'Diseño y personajes',
        'Identidad, Orbi, astronautas y planetas.',
      ),
      (
        Icons.phone_android_rounded,
        'Desarrollo móvil',
        'App Flutter offline first y accesible.',
      ),
      (
        Icons.security_rounded,
        'Seguridad y datos',
        'Acceso con Keycloak y privacidad infantil.',
      ),
    ];
    return Scaffold(
      backgroundColor: const Color(0xFF0D0F1C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0F1C),
        foregroundColor: Colors.white,
        title: const Text(
          'Órbita Kids Studios',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          const Center(child: StudiosLogo(width: 320)),
          Gap.h16,
          const Text(
            'Creamos experiencias que inspiran. Órbita Kids Studios desarrolla Órbita Kids para que aprender matemáticas se sienta como explorar el universo.',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          Gap.h18,
          for (final a in areas)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .07),
                  borderRadius: AppRadius.card,
                ),
                child: Row(
                  children: [
                    Icon(a.$1, color: Brand.violet),
                    Gap.w12,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            a.$2,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            a.$3,
                            style: const TextStyle(color: Brand.lavenderText),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Gap.h6,
          const Text(
            'Contacto: el canal de soporte se publica en Ayuda. Proyecto académico.',
            style: TextStyle(color: Brand.lavenderText),
          ),
          Gap.h12,
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white38, width: 2),
            ),
            onPressed: () => context.push(AppRoutes.help),
            child: const Text('Ir a Ayuda'),
          ),
        ],
      ),
    );
  }
}

/// 45 · Privacidad (lenguaje sencillo para niños y detalle para docentes).
class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  bool kids = true;

  @override
  Widget build(BuildContext context) {
    final c = context.ok;
    Widget block(
      IconData i,
      Color bg,
      Color fg,
      String t,
      List<String> items,
    ) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: OkCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconBox(i, bg: bg, fg: fg, size: 36),
                Gap.w10,
                Text(t, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
            Gap.h6,
            for (final x in items)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('· $x'),
              ),
          ],
        ),
      ),
    );
    return OkPage(
      title: 'Privacidad',
      children: [
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: true, label: Text('Para niños')),
            ButtonSegment(value: false, label: Text('Para adultos')),
          ],
          selected: {kids},
          onSelectionChanged: (v) => setState(() => kids = v.first),
        ),
        Gap.h12,
        if (kids) ...[
          const OrbiSays(
            text: 'Cuidamos tus datos como cuidamos la nave: solo guardamos lo necesario para que aprendas.',
            pose: 'point',
          ),
          Gap.h12,
          block(Icons.save_rounded, c.tintViolet, c.inkViolet, 'Guardamos', [
            'Tu nombre o apodo',
            'Tu astronauta',
            'Tus estrellas y misiones',
          ]),
          block(Icons.block_rounded, c.errBg, c.errInk, 'No guardamos', [
            'Dónde estás',
            'Fotos ni videos',
            'Tu voz',
            'Anuncios',
          ]),
          block(
            Icons.visibility_rounded,
            c.tintTeal,
            c.inkTeal,
            'Quién lo ve',
            ['Tú', 'Tu maestra', 'El adulto que te ayuda'],
          ),
        ] else ...[
          block(
            Icons.save_rounded,
            c.tintViolet,
            c.inkViolet,
            'Datos que se guardan',
            [
              'Nombre de uso y usuario (sin apellidos para estudiantes)',
              'Resultados e intentos de misiones con identificador único',
              'Preferencias de accesibilidad',
              'Correo institucional y nombre (docentes)',
            ],
          ),
          block(
            Icons.block_rounded,
            c.errBg,
            c.errInk,
            'Datos que no se recolectan',
            [
              'Ubicación',
              'Cámara ni micrófono',
              'Publicidad ni rastreadores',
              'Contactos',
            ],
          ),
          block(
            Icons.visibility_rounded,
            c.tintTeal,
            c.inkTeal,
            'Quién tiene acceso',
            [
              'El docente del grupo',
              'La institución según su licencia',
              'El adulto responsable',
            ],
          ),
          block(
            Icons.phone_android_rounded,
            c.tintMint,
            c.inkMint,
            'Datos en el teléfono',
            [
              'Tokens de sesión cifrados (Keychain/Keystore)',
              'Progreso y cola de envío en una base local',
              'Al cerrar sesión se retiran los tokens; el progreso pendiente queda aislado por cuenta',
            ],
          ),
        ],
        Gap.h6,
        TextButton(
          onPressed: () => context.push(AppRoutes.terms),
          child: const Text('Leer términos y condiciones'),
        ),
      ],
    );
  }
}

/// 48 · Términos y condiciones (borrador académico).
class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const sections = [
      (
        '1. Uso de la app',
        'Órbita Kids es una herramienta educativa para practicar sumas. Se usa con la cuenta que entrega la escuela o en modo explorar sin cuenta.',
      ),
      (
        '2. Cuentas',
        'Las cuentas de estudiantes las administra la institución o un adulto responsable. El rol lo asigna el servidor según la licencia.',
      ),
      (
        '3. Contenido',
        'Las misiones, personajes y logotipos son de Órbita Kids Studios. No se permite copiarlos con fines comerciales.',
      ),
      (
        '4. Datos',
        'Se tratan según el aviso de privacidad. No hay publicidad ni venta de datos.',
      ),
      (
        '5. Planes',
        'Los planes institucionales se informan dentro de la app; la contratación se realiza fuera de ella. La app no procesa pagos.',
      ),
      (
        '6. Cambios',
        'Estos términos pueden actualizarse; se avisará dentro de la app.',
      ),
    ];
    return OkPage(
      title: 'Términos y condiciones',
      subtitle: 'Borrador académico · versión 0.1',
      children: [
        const InfoBanner(
          tone: Tone.warn,
          icon: Icons.edit_note_rounded,
          text: 'Documento en borrador: debe revisarlo el área legal antes de publicarse.',
        ),
        Gap.h12,
        const OrbiSays(
          title: 'En pocas palabras',
          text: 'Usa Órbita Kids para aprender y divertirte, cuida tu cuenta y pide ayuda a un adulto si algo no entiendes.',
          pose: 'learn',
        ),
        Gap.h12,
        for (final s in sections)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: OkCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.$1, style: Theme.of(context).textTheme.titleMedium),
                  Gap.h4,
                  Text(s.$2),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// 47 · Ayuda y soporte.
class HelpScreen extends ConsumerStatefulWidget {
  const HelpScreen({super.key});

  @override
  ConsumerState<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends ConsumerState<HelpScreen> {
  final report = TextEditingController();
  String topic = 'Algo no funciona';
  String? err;

  static const faq = [
    (
      '¿Puedo usar Órbita Kids sin Internet?',
      'Sí. Las misiones de los planetas descargados, la Pausa Estelar y tu progreso funcionan sin conexión. Tus resultados se guardan en el teléfono y se envían cuando vuelve Internet.',
    ),
    (
      '¿Por qué un planeta está bloqueado?',
      'Cada planeta se abre al completar las 3 misiones del anterior. En modo explorar solo está el Planeta Verde.',
    ),
    (
      'Me equivoqué en una suma, ¿pierdo?',
      'No. Orbi te da una pista y luego te muestra la respuesta explicada. Siempre ganas al menos 1 estrella por terminar.',
    ),
    (
      '¿Cómo entro si soy estudiante?',
      'Con la cuenta que te dio tu escuela o con ayuda de un adulto. No necesitas redes sociales.',
    ),
    (
      'Mi cuenta está en pausa',
      'Pasa tras 3 contraseñas incorrectas. Espera 15 minutos o pide un código de desbloqueo.',
    ),
    (
      '¿Hay compras dentro de la app?',
      'No. Los trajes y accesorios se ganan con logros.',
    ),
  ];

  @override
  void dispose() {
    report.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (report.text.trim().length < 10) {
      setState(() => err = 'Cuéntanos un poco más (al menos 10 letras).');
      return;
    }
    final owner = ref.read(ownerIdProvider);
    await ref
        .read(syncControllerProvider.notifier)
        .enqueue(
          kind: SyncKind.supportReport,
          owner: owner,
          title: 'Reporte: $topic',
          detail: report.text.trim().length > 40
              ? '${report.text.trim().substring(0, 40)}…'
              : report.text.trim(),
          payload: {
            'topic': topic,
            'text': report.text.trim(),
            'version': appVersion,
          },
        );
    report.clear();
    if (!mounted) return;
    setState(() => err = null);
    toast(
      context,
      'Reporte guardado. Se enviará a soporte cuando el servidor esté disponible.',
      icon: Icons.cloud_upload_outlined,
    );
  }

  @override
  Widget build(BuildContext context) => OkPage(
    title: 'Ayuda y soporte',
    children: [
      const Center(child: Mascot.orbi(pose: 'think', size: 110)),
      const SectionTitle('Preguntas frecuentes'),
      Card(
        child: Column(
          children: [
            for (final q in faq)
              ExpansionTile(
                title: Text(
                  q.$1,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                children: [Text(q.$2)],
              ),
          ],
        ),
      ),
      Gap.h12,
      OutlinedButton.icon(
        onPressed: () => context.push(AppRoutes.onboarding),
        icon: const Icon(Icons.replay_rounded),
        label: const Text('Ver la introducción otra vez'),
      ),
      const SectionTitle('Reportar un problema'),
      DropdownButtonFormField<String>(
        isExpanded: true,
        initialValue: topic,
        decoration: const InputDecoration(labelText: 'Tema'),
        items: const [
          DropdownMenuItem(
            value: 'Algo no funciona',
            child: Text('Algo no funciona'),
          ),
          DropdownMenuItem(
            value: 'No puedo entrar',
            child: Text('No puedo entrar'),
          ),
          DropdownMenuItem(
            value: 'Una suma está mal',
            child: Text('Una suma está mal'),
          ),
          DropdownMenuItem(value: 'Otro', child: Text('Otro')),
        ],
        onChanged: (v) => setState(() => topic = v ?? topic),
      ),
      Gap.h10,
      TextField(
        controller: report,
        maxLines: 4,
        maxLength: 500,
        decoration: InputDecoration(labelText: '¿Qué pasó?', errorText: err),
      ),
      Gap.h6,
      const InfoBanner(
        icon: Icons.cloud_upload_outlined,
        text: 'El reporte se guarda aunque no haya Internet. No incluyas datos personales.',
      ),
      Gap.h10,
      FilledButton(onPressed: _send, child: const Text('Guardar reporte')),
      const SectionTitle('Más información'),
      Wrap(
        children: [
          TextButton(
            onPressed: () => context.push(AppRoutes.privacy),
            child: const Text('Privacidad'),
          ),
          TextButton(
            onPressed: () => context.push(AppRoutes.terms),
            child: const Text('Términos'),
          ),
          TextButton(
            onPressed: () => context.push(AppRoutes.about),
            child: const Text('Acerca de'),
          ),
        ],
      ),
    ],
  );
}
