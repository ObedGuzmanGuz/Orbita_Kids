import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:orbita_kids/shared/domain/entities/content.dart';
import 'package:orbita_kids/shared/presentation/content_ui.dart';

/// Estrella de 5 puntas (recompensas y calificación).
class StarIcon extends StatelessWidget {
  const StarIcon({
    super.key,
    this.size = 22,
    this.color = const Color(0xFFFFD166),
    this.filled = true,
  });

  final double size;
  final Color color;
  final bool filled;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: CustomPaint(
      size: Size.square(size),
      painter: _StarPainter(color, filled),
    ),
  );
}

class _StarPainter extends CustomPainter {
  _StarPainter(this.color, this.filled);
  final Color color;
  final bool filled;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final rr = i.isEven ? r : r * .48;
      final a = -math.pi / 2 + i * math.pi / 5;
      final p = c + Offset(rr * math.cos(a), rr * math.sin(a) + r * .06);
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    path.close();
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = filled ? PaintingStyle.fill : PaintingStyle.stroke
        ..strokeWidth = size.width * .08
        ..strokeJoin = StrokeJoin.round,
    );
    if (filled && color.a > .9) {
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.width * .05
          ..strokeJoin = StrokeJoin.round
          ..color = Color.lerp(color, Colors.black, .14)!,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StarPainter o) =>
      o.color != color || o.filled != filled;
}

/// Fila de 3 estrellas con etiqueta accesible.
class StarRow extends StatelessWidget {
  const StarRow({super.key, required this.value, this.size = 16, this.off});

  final int value;
  final double size;
  final Color? off;

  @override
  Widget build(BuildContext context) => Semantics(
    label: '$value de 3 estrellas',
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var k = 1; k <= 3; k++)
          StarIcon(
            size: size,
            color: k <= value
                ? const Color(0xFFFFD166)
                : (off ?? Theme.of(context).colorScheme.outline),
          ),
      ],
    ),
  );
}

/// Planeta con degradado, superficie por tipo y anillo opcional.
class PlanetArt extends StatelessWidget {
  const PlanetArt({
    super.key,
    required this.light,
    required this.dark,
    this.size = 104,
    this.ring = false,
    this.kind,
  });

  factory PlanetArt.of(Planet p, {double size = 104, Key? key}) => PlanetArt(
    key: key,
    light: p.light,
    dark: p.dark,
    size: size,
    ring: p.ring,
    kind: p.kind,
  );

  final Color light;
  final Color dark;
  final double size;
  final bool ring;
  final PlanetKind? kind;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: CustomPaint(
      size: Size(size * (ring ? 1.3 : 1), size),
      painter: _PlanetPainter(light, dark, ring, kind),
    ),
  );
}

class _PlanetPainter extends CustomPainter {
  _PlanetPainter(this.light, this.dark, this.ring, this.kind);
  final Color light, dark;
  final bool ring;
  final PlanetKind? kind;

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.height / 2 * .86;
    final c = size.center(Offset.zero);
    final ringRect = Rect.fromCenter(
      center: c,
      width: size.width * .98,
      height: r * .62,
    );
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * .1
      ..color = Color.lerp(light, Colors.white, .35)!.withValues(alpha: .9);
    if (ring) {
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.rotate(-.28);
      canvas.translate(-c.dx, -c.dy);
      canvas.drawArc(ringRect, math.pi, math.pi, false, ringPaint);
      canvas.restore();
    }
    // Halo suave.
    canvas.drawCircle(
      c,
      r * 1.08,
      Paint()..color = light.withValues(alpha: .18),
    );
    final rect = Rect.fromCircle(center: c, radius: r);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-.35, -.4),
          radius: 1.05,
          colors: [light, dark, Color.lerp(dark, Colors.black, .25)!],
          stops: const [0, .7, 1],
        ).createShader(rect),
    );
    canvas.save();
    canvas.clipPath(Path()..addOval(rect));
    _surface(canvas, c, r);
    canvas.restore();
    // Brillo.
    canvas.drawCircle(
      c + Offset(-r * .38, -r * .42),
      r * .16,
      Paint()..color = Colors.white.withValues(alpha: .45),
    );
    if (ring) {
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.rotate(-.28);
      canvas.translate(-c.dx, -c.dy);
      canvas.drawArc(ringRect, 0, math.pi, false, ringPaint);
      canvas.restore();
    }
  }

  void _surface(Canvas canvas, Offset c, double r) {
    final p = Paint()
      ..color = Color.lerp(dark, Colors.black, .18)!.withValues(alpha: .35);
    final lightP = Paint()..color = Colors.white.withValues(alpha: .22);
    switch (kind) {
      case PlanetKind.terra:
        canvas.drawOval(
          Rect.fromCenter(
            center: c + Offset(-r * .3, r * .1),
            width: r * .7,
            height: r * .45,
          ),
          p,
        );
        canvas.drawOval(
          Rect.fromCenter(
            center: c + Offset(r * .35, -r * .35),
            width: r * .5,
            height: r * .3,
          ),
          p,
        );
      case PlanetKind.gas:
        for (var i = -2; i <= 2; i++) {
          canvas.drawRect(
            Rect.fromLTWH(c.dx - r, c.dy + i * r * .32, r * 2, r * .12),
            i.isEven ? p : lightP,
          );
        }
      case PlanetKind.lava:
        final s = Paint()
          ..color = const Color(0xFFFFD166).withValues(alpha: .55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = r * .06
          ..strokeCap = StrokeCap.round;
        canvas.drawPath(
          Path()
            ..moveTo(c.dx - r, c.dy - r * .2)
            ..quadraticBezierTo(c.dx, c.dy + r * .2, c.dx + r, c.dy - r * .1),
          s,
        );
        canvas.drawPath(
          Path()
            ..moveTo(c.dx - r * .8, c.dy + r * .5)
            ..quadraticBezierTo(
              c.dx,
              c.dy + r * .3,
              c.dx + r * .8,
              c.dy + r * .55,
            ),
          s,
        );
      case PlanetKind.crystal:
        for (final o in [
          Offset(-r * .4, -r * .2),
          Offset(r * .3, r * .3),
          Offset(r * .4, -r * .45),
        ]) {
          final q = c + o;
          canvas.drawPath(
            Path()
              ..moveTo(q.dx, q.dy - r * .16)
              ..lineTo(q.dx + r * .12, q.dy)
              ..lineTo(q.dx, q.dy + r * .16)
              ..lineTo(q.dx - r * .12, q.dy)
              ..close(),
            lightP,
          );
        }
      case PlanetKind.ice:
        canvas.drawOval(
          Rect.fromCenter(
            center: c + Offset(0, -r * .85),
            width: r * 1.2,
            height: r * .5,
          ),
          lightP,
        );
        canvas.drawOval(
          Rect.fromCenter(
            center: c + Offset(0, r * .9),
            width: r * 1.1,
            height: r * .45,
          ),
          lightP,
        );
      case PlanetKind.ocean:
        canvas.drawOval(
          Rect.fromCenter(
            center: c + Offset(r * .2, r * .2),
            width: r * .55,
            height: r * .35,
          ),
          lightP,
        );
      case null:
        canvas.drawCircle(c + Offset(r * .3, r * .25), r * .16, p);
        canvas.drawCircle(c + Offset(-r * .35, r * .05), r * .1, p);
    }
  }

  @override
  bool shouldRepaint(covariant _PlanetPainter o) =>
      o.light != light || o.dark != dark || o.ring != ring || o.kind != kind;
}

/// Cohete en órbita del logotipo.
class RocketArt extends StatelessWidget {
  const RocketArt({super.key, this.size = 34, this.angle = .6});
  final double size;
  final double angle;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Transform.rotate(
      angle: angle,
      child: CustomPaint(
        size: Size(size * .6, size),
        painter: _RocketPainter(),
      ),
    ),
  );
}

class _RocketPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width, h = s.height;
    canvas.drawPath(
      Path()
        ..moveTo(w * .3, h * .82)
        ..lineTo(w * .5, h)
        ..lineTo(w * .7, h * .82)
        ..close(),
      Paint()..color = const Color(0xFFFFA25E),
    );
    for (final sgn in [-1.0, 1.0]) {
      canvas.drawPath(
        Path()
          ..moveTo(w * .5 + sgn * w * .2, h * .55)
          ..lineTo(w * .5 + sgn * w * .5, h * .85)
          ..lineTo(w * .5 + sgn * w * .2, h * .8)
          ..close(),
        Paint()..color = const Color(0xFF746BE8),
      );
    }
    final body = Path()
      ..moveTo(w * .5, 0)
      ..quadraticBezierTo(w * .9, h * .3, w * .72, h * .82)
      ..lineTo(w * .28, h * .82)
      ..quadraticBezierTo(w * .1, h * .3, w * .5, 0)
      ..close();
    canvas.drawPath(body, Paint()..color = const Color(0xFFF4F2FF));
    canvas.drawPath(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * .05
        ..color = const Color(0xFFC9C3FF),
    );
    canvas.drawCircle(
      Offset(w * .5, h * .36),
      w * .14,
      Paint()..color = const Color(0xFF69D6DE),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Campo de estrellas determinista (misma semilla, mismo cielo).
class StarField extends StatelessWidget {
  const StarField({super.key, this.count = 36, this.seed = 7});
  final int count;
  final int seed;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: CustomPaint(
      size: Size.infinite,
      painter: _StarFieldPainter(count, seed),
    ),
  );
}

class _StarFieldPainter extends CustomPainter {
  _StarFieldPainter(this.count, this.seed);
  final int count, seed;

  @override
  void paint(Canvas canvas, Size size) {
    final r = math.Random(seed);
    for (var i = 0; i < count; i++) {
      final p = Offset(
        r.nextDouble() * size.width,
        r.nextDouble() * size.height,
      );
      final rad = .6 + r.nextDouble() * 1.6;
      canvas.drawCircle(
        p,
        rad,
        Paint()
          ..color = Colors.white.withValues(alpha: .35 + r.nextDouble() * .55),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StarFieldPainter o) =>
      o.count != count || o.seed != seed;
}

/// Fondo espacial con degradado y estrellas.
class SpaceBackground extends StatelessWidget {
  const SpaceBackground({
    super.key,
    required this.child,
    this.seed = 7,
    this.stars = 40,
    this.colors = const [
      Color(0xFF262A7C),
      Color(0xFF191B58),
      Color(0xFF0D102B),
    ],
  });

  final Widget child;
  final int seed;
  final int stars;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      gradient: RadialGradient(
        center: const Alignment(0, -1),
        radius: 1.6,
        colors: colors,
      ),
    ),
    child: Stack(
      children: [
        Positioned.fill(
          child: StarField(count: stars, seed: seed),
        ),
        child,
      ],
    ),
  );
}

/// Flotación suave (Orbi, astronautas). Se detiene con movimiento reducido.
class Floating extends StatefulWidget {
  const Floating({
    super.key,
    required this.child,
    this.enabled = true,
    this.amplitude = 6,
  });

  final Widget child;
  final bool enabled;
  final double amplitude;

  @override
  State<Floating> createState() => _FloatingState();
}

class _FloatingState extends State<Floating>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  );

  @override
  void initState() {
    super.initState();
    if (widget.enabled) _c.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant Floating old) {
    super.didUpdateWidget(old);
    if (widget.enabled && !_c.isAnimating) _c.repeat(reverse: true);
    if (!widget.enabled && _c.isAnimating) _c.stop();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;
    return AnimatedBuilder(
      animation: _c,
      builder: (_, child) => Transform.translate(
        offset: Offset(
          0,
          -widget.amplitude * Curves.easeInOut.transform(_c.value),
        ),
        child: child,
      ),
      child: widget.child,
    );
  }
}
