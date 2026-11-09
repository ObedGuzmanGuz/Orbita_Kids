export 'package:orbita_kids/config/themes/app_themes.dart';
export 'package:orbita_kids/shared/presentation/content_ui.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:orbita_kids/core/audio/speech.dart';
import 'package:orbita_kids/features/settings/presentation/providers/settings_controller.dart';
import 'package:orbita_kids/config/themes/app_themes.dart';
import 'package:orbita_kids/shared/presentation/art/mascot.dart';

/// Piezas de interfaz compartidas, equivalentes a `.card`, `.banner`, `.tag`,
/// `.stat`, `.sec-t`, `.say` del prototipo.

class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.width = 150});
  final double width;

  @override
  Widget build(BuildContext context) => Image.asset(
    'assets/brand/appT.png',
    width: width,
    semanticLabel:
        'Órbita Kids. Matemáticas en órbita. Explora el universo numérico.',
  );
}

class StudiosLogo extends StatelessWidget {
  const StudiosLogo({super.key, this.width = 300});
  final double width;

  @override
  Widget build(BuildContext context) => Image.asset(
    'assets/brand/studiosT.png',
    width: width,
    semanticLabel: 'Órbita Kids Studios. Creamos experiencias que inspiran.',
  );
}

/// Página estándar con encabezado, regreso y contenido desplazable.
class OkPage extends StatelessWidget {
  const OkPage({
    super.key,
    required this.title,
    required this.children,
    this.subtitle,
    this.actions,
    this.bottom,
    this.showBack = true,
    this.padding = const EdgeInsets.fromLTRB(20, 4, 20, 32),
    this.background,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;
  final List<Widget>? actions;
  final Widget? bottom;
  final bool showBack;
  final EdgeInsets padding;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final canPop = showBack && GoRouter.of(context).canPop();
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        automaticallyImplyLeading: false,
        leading: canPop
            ? IconButton(
                tooltip: 'Regresar',
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => context.pop(),
              )
            : null,
        titleSpacing: canPop ? 0 : 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(header: true, child: Text(title)),
            if (subtitle != null)
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        toolbarHeight: subtitle == null ? 64 : 76,
        actions: actions,
      ),
      body: ListView(padding: padding, children: children),
      bottomNavigationBar: bottom,
    );
  }
}

class OkCard extends StatelessWidget {
  const OkCard({
    super.key,
    required this.child,
    this.onTap,
    this.color,
    this.padding = const EdgeInsets.all(16),
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final Color? color;
  final EdgeInsets padding;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final card = Card(
      color: color,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
    if (semanticLabel == null) return card;
    return Semantics(
      label: semanticLabel,
      button: onTap != null,
      excludeSemantics: true,
      child: card,
    );
  }
}

enum Tone { info, ok, err, warn, mint, neutral }

class InfoBanner extends StatelessWidget {
  const InfoBanner({
    super.key,
    required this.text,
    this.icon = Icons.info_outline_rounded,
    this.tone = Tone.info,
    this.title,
    this.action,
  });

  final String text;
  final String? title;
  final IconData icon;
  final Tone tone;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final c = context.ok;
    final (bg, fg) = switch (tone) {
      Tone.info => (c.tintViolet, c.inkViolet),
      Tone.ok => (c.okBg, c.ok),
      Tone.err => (c.errBg, c.errInk),
      Tone.warn => (c.tintYellow, c.inkYellow),
      Tone.mint => (c.tintMint, c.inkMint),
      Tone.neutral => (c.tintGray, c.ink),
    };
    return Semantics(
      liveRegion: tone == Tone.err,
      container: true,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: AppRadius.field,
          border: c.highContrast ? Border.all(color: c.ink, width: 2) : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: fg, size: 22),
            Gap.w10,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null)
                    Text(
                      title!,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: fg,
                        fontSize: 15.5,
                      ),
                    ),
                  Text(
                    text,
                    style: TextStyle(
                      color: tone == Tone.neutral ? c.ink : fg,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.5,
                    ),
                  ),
                  if (action != null) ...[Gap.h8, action!],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TagChip extends StatelessWidget {
  const TagChip(this.text, {super.key, this.tone = Tone.info, this.icon});
  final String text;
  final Tone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final c = context.ok;
    final (bg, fg) = switch (tone) {
      Tone.info => (c.tintViolet, c.inkViolet),
      Tone.ok => (c.okBg, c.ok),
      Tone.err => (c.errBg, c.errInk),
      Tone.warn => (c.tintYellow, c.inkYellow),
      Tone.mint => (c.tintMint, c.inkMint),
      Tone.neutral => (c.tintGray, c.muted),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 14, color: fg), Gap.w4],
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                color: fg,
                fontWeight: FontWeight.w800,
                fontSize: 12.5,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class StatTile extends StatelessWidget {
  const StatTile({super.key, required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Semantics(
    label: '$value $label',
    excludeSemantics: true,
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.ok.card,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: context.ok.highContrast ? context.ok.ink : context.ok.line,
          width: context.ok.highContrast ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
          ),
          Gap.h2,
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    ),
  );
}

class StatGrid extends StatelessWidget {
  const StatGrid({super.key, required this.tiles});
  final List<StatTile> tiles;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      final w = (c.maxWidth - 10) / 2;
      return Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [for (final t in tiles) SizedBox(width: w, child: t)],
      );
    },
  );
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.action, this.onAction});
  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 22, bottom: 8),
    child: Row(
      children: [
        Expanded(
          child: Semantics(
            header: true,
            child: Text(title, style: Theme.of(context).textTheme.titleLarge),
          ),
        ),
        if (action != null)
          TextButton(onPressed: onAction, child: Text(action!)),
      ],
    ),
  );
}

class ProgressLine extends StatelessWidget {
  const ProgressLine({
    super.key,
    required this.value,
    this.height = 10,
    this.color,
    this.track,
    this.label,
  });

  final double value;
  final double height;
  final Color? color;
  final Color? track;
  final String? label;

  @override
  Widget build(BuildContext context) => Semantics(
    label: label,
    value: '${(value * 100).round()} %',
    child: ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: LinearProgressIndicator(
        value: value.clamp(0, 1),
        minHeight: height,
        color: color ?? Brand.purple,
        backgroundColor: track ?? context.ok.line,
      ),
    ),
  );
}

/// Burbuja de diálogo de Orbi (`.say` del prototipo).
class OrbiSays extends StatelessWidget {
  const OrbiSays({
    super.key,
    required this.text,
    this.pose = 'wave',
    this.size = 78,
    this.title,
    this.dark = false,
  });

  final String text;
  final String? title;
  final String pose;
  final double size;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final c = context.ok;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Mascot.orbi(pose: pose, size: size, semanticLabel: null),
        Gap.w8,
        Expanded(
          child: Semantics(
            liveRegion: true,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: dark ? Colors.white.withValues(alpha: .1) : c.card,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                  bottomLeft: Radius.circular(4),
                ),
                border: Border.all(
                  color: dark
                      ? Colors.white24
                      : (c.highContrast ? c.ink : c.line),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null)
                    Text(
                      title!,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: dark ? Brand.lavender : c.muted,
                      ),
                    ),
                  Text(
                    text,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: dark ? Colors.white : c.ink,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Botón «Escuchar»: lee el texto en voz alta (lectura opcional).
class SpeakButton extends ConsumerWidget {
  const SpeakButton(
    this.text, {
    super.key,
    this.label = 'Escuchar',
    this.light = false,
  });
  final String text;
  final String label;
  final bool light;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fg = light ? Colors.white : context.ok.purpleDark;
    return Semantics(
      button: true,
      label: 'Escuchar en voz alta',
      excludeSemantics: true,
      child: TextButton.icon(
        style: TextButton.styleFrom(foregroundColor: fg),
        onPressed: () => ref.speak(text),
        icon: const Icon(Icons.volume_up_rounded),
        label: Text(label.isEmpty ? 'Escuchar' : label),
      ),
    );
  }
}

class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({
    super.key,
    required this.name,
    required this.color,
    this.size = 44,
  });

  final String name;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final parts = name.replaceAll('.', '').split(' ');
    final ini = parts.take(2).map((p) => p.isEmpty ? '' : p[0]).join();
    return ExcludeSemantics(
      child: CircleAvatar(
        radius: size / 2,
        backgroundColor: color,
        child: Text(
          ini,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: size * .36,
          ),
        ),
      ),
    );
  }
}

class IconBox extends StatelessWidget {
  const IconBox(
    this.icon, {
    super.key,
    required this.bg,
    required this.fg,
    this.size = 44,
  });

  final IconData icon;
  final Color bg;
  final Color fg;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(size * .32),
    ),
    child: Icon(icon, color: fg, size: size * .5),
  );
}

/// Fila de lista con ícono, título, subtítulo y acción.
class OkListTile extends StatelessWidget {
  const OkListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => OkCard(
    onTap: onTap,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    child: Row(
      children: [
        if (leading != null) ...[leading!, Gap.w12],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15.5,
                ),
              ),
              if (subtitle != null)
                Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
        if (trailing != null) ...[
          Gap.w8,
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * .4,
            ),
            child: trailing!,
          ),
        ] else if (onTap != null)
          Icon(Icons.chevron_right_rounded, color: context.ok.muted),
      ],
    ),
  );
}

/// Grupo de ajustes con encabezado (Configuración, Perfil).
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, this.title, required this.children});
  final String? title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (title != null)
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 18, 4, 8),
          child: Semantics(
            header: true,
            child: Text(
              title!.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w900,
                color: context.ok.muted,
              ),
            ),
          ),
        ),
      Card(
        child: Column(
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) const Divider(indent: 16, endIndent: 16),
              children[i],
            ],
          ],
        ),
      ),
    ],
  );
}

Future<bool> confirm(
  BuildContext context, {
  required String title,
  required String text,
  String ok = 'Aceptar',
  String cancel = 'Cancelar',
  bool destructive = false,
}) async {
  final r = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(text),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(cancel),
        ),
        FilledButton(
          style: destructive
              ? FilledButton.styleFrom(
                  backgroundColor: ctx.ok.err,
                  minimumSize: const Size(48, 48),
                )
              : FilledButton.styleFrom(minimumSize: const Size(48, 48)),
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(ok),
        ),
      ],
    ),
  );
  return r ?? false;
}

void toast(BuildContext context, String msg, {IconData? icon}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 20),
              Gap.w10,
            ],
            Expanded(child: Text(msg)),
          ],
        ),
      ),
    );
}

/// `true` si las animaciones deben omitirse.
bool reduceMotion(BuildContext context, WidgetRef ref) =>
    reduceMotionOf(context, ref.watch(settingsProvider));
