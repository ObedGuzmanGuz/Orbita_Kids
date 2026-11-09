import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:orbita_kids/shared/domain/entities/avatar_look.dart';

export 'package:orbita_kids/shared/domain/entities/avatar_look.dart';

/// Personajes del prototipo: Orbi (perrito astronauta) y los astronautas
/// personalizables. Se dibujan con vectores para verse nítidos en cualquier
/// tamaño y no depender de imágenes externas.

@immutable
class CharacterDef {
  const CharacterDef(this.id, this.name, this.skin, this.hair, this.style);
  final String id;
  final String name;
  final Color skin;
  final Color hair;
  final String style;
}

abstract final class AvatarCatalog {
  static const all = <CharacterDef>[
    CharacterDef('luna', 'Luna', Color(0xFFF2C7A5), Color(0xFF3B2A20), 'long'),
    CharacterDef('teo', 'Teo', Color(0xFFC68B5E), Color(0xFF1E1A1A), 'short'),
    CharacterDef('ari', 'Ari', Color(0xFF8D5A3B), Color(0xFF1B1414), 'curly'),
    CharacterDef('nico', 'Nico', Color(0xFFF5D3BA), Color(0xFFB97A33), 'wavy'),
    CharacterDef('sol', 'Sol', Color(0xFFE3A97F), Color(0xFF2B1B14), 'bun'),
    CharacterDef('mar', 'Mar', Color(0xFFA86B47), Color(0xFF3A2418), 'pony'),
    CharacterDef('kai', 'Kai', Color(0xFF6E4530), Color(0xFF140F0D), 'puffs'),
    CharacterDef('noa', 'Noa', Color(0xFFFADCC4), Color(0xFF8C5A3C), 'buzz'),
  ];

  static CharacterDef byId(String id) =>
      all.firstWhere((c) => c.id == id, orElse: () => all.first);

  static const helmets = <(String, String, Color)>[
    ('morado', 'Morado', Color(0xFF746BE8)),
    ('turquesa', 'Turquesa', Color(0xFF3FBCC6)),
    ('menta', 'Menta', Color(0xFF4DBB98)),
    ('estelar', 'Estelar', Color(0xFFF2B33D)),
  ];

  static Color helmetColor(String id) =>
      helmets.firstWhere((h) => h.$1 == id, orElse: () => helmets.first).$3;

  /// (id, nombre, base, sombra, condición de desbloqueo)
  static const suits = <(String, String, Color, Color, String?)>[
    ('clasico', 'Clásico', Color(0xFFF7F6FF), Color(0xFFDCD8F7), null),
    ('explorador', 'Explorador', Color(0xFFF2FBF7), Color(0xFFCFEBDF), null),
    (
      'galactico',
      'Galáctico',
      Color(0xFFDCD7FF),
      Color(0xFFB4ACF2),
      'Completa el planeta Nébula',
    ),
    (
      'cometa',
      'Cometa',
      Color(0xFFFFF6DF),
      Color(0xFFF3DDA5),
      'Reúne 60 estrellas',
    ),
  ];

  /// (id, nombre, condición de desbloqueo)
  static const accessories = <(String, String, String?)>[
    ('ninguno', 'Ninguno', null),
    ('antena', 'Antena', null),
    ('mochila', 'Propulsor', null),
    ('insignia', 'Insignia estelar', 'Gana 3 insignias'),
    ('gafas', 'Gafas de vuelo', null),
    ('bufanda', 'Bufanda cósmica', 'Completa 5 misiones'),
  ];

  static const expressions = <(String, String)>[
    ('smile', 'Sonrisa'),
    ('grin', 'Alegría'),
    ('surprised', 'Sorpresa'),
    ('think', 'Pensando'),
  ];
}

/// Pose: brazos (polilíneas en un lienzo de 200×220), expresión y efecto.
class _Pose {
  const _Pose({
    this.left = const [Offset(76, 150), Offset(66, 182)],
    this.right = const [Offset(124, 150), Offset(134, 182)],
    this.expr,
    this.dy = 0,
    this.fx,
    this.tilt = 0,
  });
  final List<Offset> left;
  final List<Offset> right;
  final String? expr;
  final double dy;
  final String? fx;
  final double tilt;
}

const _poses = <String, _Pose>{
  'stand': _Pose(),
  'wave': _Pose(
    right: [Offset(124, 150), Offset(146, 132), Offset(152, 104)],
    fx: 'wave',
  ),
  'celebrate': _Pose(
    left: [Offset(76, 150), Offset(58, 128), Offset(52, 100)],
    right: [Offset(124, 150), Offset(142, 128), Offset(148, 100)],
    expr: 'grin',
    dy: -6,
    fx: 'spark',
  ),
  'explore': _Pose(
    right: [Offset(124, 150), Offset(146, 148), Offset(160, 138)],
    fx: 'lens',
  ),
  'think': _Pose(
    right: [Offset(124, 150), Offset(142, 154), Offset(128, 140)],
    expr: 'think',
    fx: 'dots',
    tilt: .06,
  ),
  'learn': _Pose(
    left: [Offset(76, 150), Offset(82, 174)],
    right: [Offset(124, 150), Offset(118, 174)],
    fx: 'book',
  ),
  'surprised': _Pose(
    left: [Offset(76, 150), Offset(50, 138)],
    right: [Offset(124, 150), Offset(150, 138)],
    expr: 'surprised',
    fx: 'bang',
  ),
  'cheer': _Pose(
    right: [Offset(124, 150), Offset(140, 126), Offset(144, 100)],
    expr: 'grin',
    fx: 'star',
  ),
  'rest': _Pose(expr: 'calm', fx: 'z', tilt: -.07),
  'walk': _Pose(
    left: [Offset(76, 150), Offset(60, 176)],
    right: [Offset(124, 150), Offset(142, 172)],
    tilt: .04,
    fx: 'lines',
  ),
  'jump': _Pose(
    left: [Offset(76, 150), Offset(58, 130), Offset(50, 106)],
    right: [Offset(124, 150), Offset(142, 130), Offset(150, 106)],
    expr: 'grin',
    dy: -16,
    fx: 'shadow',
  ),
  'point': _Pose(right: [Offset(124, 150), Offset(150, 146), Offset(172, 140)]),
  'stretch': _Pose(
    left: [Offset(76, 150), Offset(52, 146), Offset(32, 138)],
    right: [Offset(124, 150), Offset(148, 146), Offset(168, 138)],
  ),
};

/// Dibuja a Orbi o a un astronauta. Incluye etiqueta para lectores de pantalla.
class Mascot extends StatelessWidget {
  const Mascot({
    super.key,
    this.look = AvatarLook.orbi,
    this.pose = 'wave',
    this.size = 120,
    this.semanticLabel,
  });

  /// Orbi, el perrito astronauta de Órbita Kids.
  const Mascot.orbi({
    super.key,
    this.pose = 'wave',
    this.size = 120,
    this.semanticLabel = 'Orbi, el perrito astronauta de Órbita Kids',
  }) : look = AvatarLook.orbi;

  final AvatarLook look;
  final String pose;
  final double size;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final painter = CustomPaint(
      size: Size(size, size * 1.1),
      painter: _MascotPainter(look, _poses[pose] ?? _poses['stand']!),
    );
    if (semanticLabel == null) return ExcludeSemantics(child: painter);
    return Semantics(label: semanticLabel, image: true, child: painter);
  }
}

class _MascotPainter extends CustomPainter {
  _MascotPainter(this.look, this.pose);

  final AvatarLook look;
  final _Pose pose;

  bool get isDog => look.character == 'orbi';

  static Color _dk(Color c, double t) => Color.lerp(c, Colors.black, t)!;
  static Color _lt(Color c, double t) => Color.lerp(c, Colors.white, t)!;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 200, size.height / 220);

    final helmet = AvatarCatalog.helmetColor(look.helmet);
    final suit = AvatarCatalog.suits.firstWhere(
      (s) => s.$1 == look.suit,
      orElse: () => AvatarCatalog.suits.first,
    );
    final base = suit.$3, shade = suit.$4;
    final expr = look.expression == 'smile'
        ? (pose.expr ?? 'smile')
        : look.expression;

    // Sombra en el piso.
    final shadowW = pose.fx == 'shadow' ? 34.0 : 46.0;
    canvas.drawOval(
      Rect.fromCenter(
        center: const Offset(100, 212),
        width: shadowW * 2,
        height: 10,
      ),
      Paint()..color = Colors.black.withValues(alpha: .14),
    );

    canvas.translate(0, pose.dy);
    if (pose.tilt != 0) {
      canvas.translate(100, 200);
      canvas.rotate(pose.tilt);
      canvas.translate(-100, -200);
    }

    // Propulsor (mochila) detrás del cuerpo.
    if (look.accessory == 'mochila') {
      final r = RRect.fromRectAndRadius(
        const Rect.fromLTWH(60, 138, 80, 50),
        const Radius.circular(14),
      );
      canvas.drawRRect(r, Paint()..color = const Color(0xFF9C99C9));
      canvas.drawRRect(
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..color = const Color(0xFF66638A),
      );
      for (final x in [64.0, 126.0]) {
        canvas.drawPath(
          Path()
            ..moveTo(x, 188)
            ..lineTo(x + 10, 188)
            ..lineTo(x + 5, 200)
            ..close(),
          Paint()..color = const Color(0xFFFFA25E),
        );
      }
    }

    // Piernas y botas.
    final legPaint = Paint()
      ..color = base
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round;
    final legLine = Paint()
      ..color = _dk(shade, .22)
      ..strokeWidth = 21
      ..strokeCap = StrokeCap.round;
    final legs = pose.fx == 'shadow'
        ? [
            [const Offset(88, 182), const Offset(80, 198)],
            [const Offset(112, 182), const Offset(120, 198)],
          ]
        : pose.fx == 'lines'
        ? [
            [const Offset(88, 182), const Offset(80, 204)],
            [const Offset(112, 182), const Offset(122, 202)],
          ]
        : [
            [const Offset(88, 182), const Offset(87, 204)],
            [const Offset(112, 182), const Offset(113, 204)],
          ];
    for (final l in legs) {
      canvas.drawLine(l[0], l[1], legLine);
      canvas.drawLine(l[0], l[1], legPaint);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: l[1] + const Offset(0, 5),
            width: 26,
            height: 14,
          ),
          const Radius.circular(7),
        ),
        Paint()..color = _dk(helmet, .25),
      );
    }

    // Cuerpo (traje).
    final body = RRect.fromRectAndRadius(
      const Rect.fromLTWH(70, 136, 60, 54),
      const Radius.circular(24),
    );
    canvas.drawRRect(body, Paint()..color = base);
    canvas.drawRRect(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = _dk(shade, .22),
    );
    // Panel del pecho.
    final panel = RRect.fromRectAndRadius(
      const Rect.fromLTWH(86, 152, 28, 18),
      const Radius.circular(6),
    );
    canvas.drawRRect(panel, Paint()..color = _lt(helmet, .75));
    const dots = [Color(0xFF746BE8), Color(0xFFFFD166), Color(0xFF69D6DE)];
    for (var i = 0; i < 3; i++) {
      canvas.drawCircle(
        Offset(93 + i * 7.0, 161),
        2.6,
        Paint()..color = dots[i],
      );
    }
    if (look.accessory == 'insignia') {
      _star(canvas, const Offset(80, 150), 7, const Color(0xFFFFD166));
    }

    // Brazos.
    _arm(canvas, pose.left, base, shade, helmet);
    _arm(canvas, pose.right, base, shade, helmet);

    // Bufanda.
    if (look.accessory == 'bufanda') {
      final scarf = RRect.fromRectAndRadius(
        const Rect.fromLTWH(72, 132, 56, 12),
        const Radius.circular(6),
      );
      canvas.drawRRect(scarf, Paint()..color = const Color(0xFFE07A8E));
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(112, 138, 10, 22),
          const Radius.circular(4),
        ),
        Paint()..color = const Color(0xFFC8455E),
      );
    }

    // Antena.
    if (look.accessory == 'antena') {
      canvas.drawLine(
        const Offset(100, 38),
        const Offset(104, 14),
        Paint()
          ..color = _dk(helmet, .2)
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawCircle(
        const Offset(104, 12),
        7,
        Paint()..color = const Color(0xFFFFD166),
      );
      canvas.drawCircle(
        const Offset(102, 10),
        2.4,
        Paint()..color = Colors.white,
      );
    }

    // Casco: anillo + vidrio.
    const hc = Offset(100, 92);
    canvas.drawCircle(hc, 57, Paint()..color = helmet);
    canvas.drawCircle(hc, 50, Paint()..color = const Color(0xFFE9F6FF));
    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: hc, radius: 50)));
    canvas.drawCircle(
      hc,
      50,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-.3, -.4),
          colors: [Color(0xFFF4FAFF), Color(0xFFC9E4F5)],
        ).createShader(Rect.fromCircle(center: hc, radius: 50)),
    );
    if (isDog) {
      _dogFace(canvas, expr);
    } else {
      _kidFace(canvas, AvatarCatalog.byId(look.character), expr);
    }
    canvas.restore();
    // Brillo del vidrio.
    canvas.drawArc(
      Rect.fromCircle(center: hc, radius: 42),
      math.pi * 1.1,
      math.pi * .32,
      false,
      Paint()
        ..color = Colors.white.withValues(alpha: .75)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(
      hc,
      57,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = _dk(helmet, .28),
    );
    if (look.accessory == 'gafas') {
      final g = Paint()..color = const Color(0xFF292742);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(70, 36, 60, 10),
          const Radius.circular(5),
        ),
        g,
      );
      for (final x in [84.0, 116.0]) {
        canvas.drawCircle(Offset(x, 41), 9, g);
        canvas.drawCircle(
          Offset(x, 41),
          6,
          Paint()..color = const Color(0xFF69D6DE),
        );
      }
    }

    _effects(canvas);
    canvas.restore();
  }

  void _arm(Canvas c, List<Offset> pts, Color base, Color shade, Color helmet) {
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (final p in pts.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    c.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 19
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = _dk(shade, .22),
    );
    c.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 15
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = base,
    );
    c.drawCircle(
      pts.last,
      9.5,
      Paint()..color = isDog ? const Color(0xFFE2A35E) : helmet,
    );
    c.drawCircle(
      pts.last,
      9.5,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = _dk(isDog ? const Color(0xFFE2A35E) : helmet, .3),
    );
  }

  void _eyes(Canvas c, double y, String expr, Color ink) {
    final p = Paint()..color = ink;
    if (expr == 'calm') {
      for (final x in [86.0, 114.0]) {
        c.drawArc(
          Rect.fromCenter(center: Offset(x, y), width: 12, height: 8),
          0,
          math.pi,
          false,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3
            ..strokeCap = StrokeCap.round
            ..color = ink,
        );
      }
      return;
    }
    final dy = expr == 'think' ? -3.0 : 0.0;
    final r = expr == 'surprised' ? 6.5 : 5.5;
    for (final x in [86.0, 114.0]) {
      c.drawCircle(Offset(x, y + dy), r, p);
      c.drawCircle(
        Offset(x + 1.8, y + dy - 2),
        1.9,
        Paint()..color = Colors.white,
      );
    }
  }

  void _mouth(Canvas c, Offset at, String expr, Color ink) {
    final s = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = ink;
    switch (expr) {
      case 'grin':
        final path = Path()
          ..moveTo(at.dx - 9, at.dy - 2)
          ..quadraticBezierTo(at.dx, at.dy + 14, at.dx + 9, at.dy - 2)
          ..close();
        c.drawPath(path, Paint()..color = const Color(0xFF6B2737));
        c.drawCircle(
          at + const Offset(0, 5),
          4,
          Paint()..color = const Color(0xFFFF8FA3),
        );
      case 'surprised':
        c.drawOval(
          Rect.fromCenter(
            center: at + const Offset(0, 3),
            width: 9,
            height: 11,
          ),
          Paint()..color = const Color(0xFF6B2737),
        );
      case 'think':
        c.drawLine(at + const Offset(-6, 2), at + const Offset(6, 0), s);
      default:
        c.drawArc(
          Rect.fromCenter(center: at, width: 16, height: 10),
          .2,
          math.pi - .4,
          false,
          s,
        );
    }
  }

  void _dogFace(Canvas c, String expr) {
    const fur = Color(0xFFE2A35E),
        ear = Color(0xFF8A5530),
        cream = Color(0xFFFFF3E2);
    // Orejas caídas.
    for (final s in [-1.0, 1.0]) {
      c.save();
      c.translate(100 + s * 32, 92);
      c.rotate(s * .35);
      c.drawOval(
        Rect.fromCenter(center: Offset.zero, width: 20, height: 40),
        Paint()..color = ear,
      );
      c.restore();
    }
    c.drawOval(
      Rect.fromCenter(center: const Offset(100, 98), width: 64, height: 58),
      Paint()..color = fur,
    );
    // Mancha clara del hocico.
    c.drawOval(
      Rect.fromCenter(center: const Offset(100, 112), width: 36, height: 26),
      Paint()..color = cream,
    );
    _eyes(c, 92, expr, const Color(0xFF2B1D14));
    c.drawOval(
      Rect.fromCenter(center: const Offset(100, 105), width: 13, height: 9),
      Paint()..color = const Color(0xFF2B1D14),
    );
    _mouth(c, const Offset(100, 116), expr, const Color(0xFF2B1D14));
    // Mejillas.
    for (final x in [78.0, 122.0]) {
      c.drawCircle(
        Offset(x, 108),
        5,
        Paint()..color = const Color(0xFFFF8FA3).withValues(alpha: .45),
      );
    }
  }

  void _kidFace(Canvas c, CharacterDef ch, String expr) {
    final hair = Paint()..color = ch.hair;
    // Cabello trasero.
    switch (ch.style) {
      case 'long':
      case 'wavy':
        c.drawRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(66, 70, 68, 72),
            const Radius.circular(26),
          ),
          hair,
        );
      case 'pony':
        c.drawOval(
          Rect.fromCenter(center: const Offset(136, 96), width: 18, height: 40),
          hair,
        );
      case 'bun':
        c.drawCircle(const Offset(100, 56), 14, hair);
      case 'puffs':
        c.drawCircle(const Offset(68, 72), 14, hair);
        c.drawCircle(const Offset(132, 72), 14, hair);
      case 'curly':
        for (var i = 0; i < 7; i++) {
          final a = math.pi + i * math.pi / 6;
          c.drawCircle(
            Offset(100 + 34 * math.cos(a), 92 + 34 * math.sin(a)),
            12,
            hair,
          );
        }
    }
    c.drawCircle(const Offset(100, 98), 30, Paint()..color = ch.skin);
    // Flequillo/coronilla.
    final cap = Path()
      ..moveTo(70, 94)
      ..quadraticBezierTo(70, 62, 100, 62)
      ..quadraticBezierTo(130, 62, 130, 94)
      ..quadraticBezierTo(116, 78, 100, 82)
      ..quadraticBezierTo(82, 78, 70, 94)
      ..close();
    if (ch.style == 'buzz') {
      c.drawPath(cap, Paint()..color = ch.hair.withValues(alpha: .55));
    } else {
      c.drawPath(cap, hair);
    }
    _eyes(c, 98, expr, const Color(0xFF2B1D14));
    _mouth(c, const Offset(100, 112), expr, const Color(0xFF6B2737));
    for (final x in [80.0, 120.0]) {
      c.drawCircle(
        Offset(x, 108),
        5,
        Paint()..color = const Color(0xFFFF8FA3).withValues(alpha: .45),
      );
    }
  }

  void _star(Canvas c, Offset at, double r, Color color) {
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final rr = i.isEven ? r : r * .45;
      final a = -math.pi / 2 + i * math.pi / 5;
      final p = at + Offset(rr * math.cos(a), rr * math.sin(a));
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    path.close();
    c.drawPath(path, Paint()..color = color);
  }

  void _sparkle(Canvas c, Offset at, double r, Color color) {
    final path = Path()
      ..moveTo(at.dx, at.dy - r)
      ..quadraticBezierTo(at.dx, at.dy, at.dx + r, at.dy)
      ..quadraticBezierTo(at.dx, at.dy, at.dx, at.dy + r)
      ..quadraticBezierTo(at.dx, at.dy, at.dx - r, at.dy)
      ..quadraticBezierTo(at.dx, at.dy, at.dx, at.dy - r)
      ..close();
    c.drawPath(path, Paint()..color = color);
  }

  void _effects(Canvas c) {
    final ink = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFFC9C3FF);
    switch (pose.fx) {
      case 'spark':
        _sparkle(c, const Offset(26, 56), 10, const Color(0xFFFFD166));
        _sparkle(c, const Offset(174, 60), 8, const Color(0xFF69D6DE));
      case 'wave':
        c.drawArc(
          Rect.fromCircle(center: const Offset(152, 98), radius: 18),
          -1.2,
          .9,
          false,
          ink,
        );
      case 'lens':
        c.drawCircle(
          const Offset(168, 132),
          11,
          Paint()..color = const Color(0xFFC9F1F5).withValues(alpha: .6),
        );
        c.drawCircle(
          const Offset(168, 132),
          11,
          ink..color = const Color(0xFF3B3480),
        );
      case 'dots':
        c.drawCircle(const Offset(164, 36), 5, Paint()..color = Colors.white);
        c.drawCircle(const Offset(176, 20), 7, Paint()..color = Colors.white);
        c.drawCircle(const Offset(164, 36), 5, ink);
        c.drawCircle(const Offset(176, 20), 7, ink);
      case 'book':
        final r = RRect.fromRectAndRadius(
          const Rect.fromLTWH(78, 166, 44, 28),
          const Radius.circular(5),
        );
        c.drawRRect(r, Paint()..color = const Color(0xFF69D6DE));
        c.drawLine(
          const Offset(100, 166),
          const Offset(100, 194),
          Paint()
            ..color = const Color(0xFF1D8C96)
            ..strokeWidth = 2,
        );
      case 'bang':
        _star(c, const Offset(170, 36), 9, const Color(0xFFFFD166));
      case 'star':
        _star(c, const Offset(150, 84), 10, const Color(0xFFFFD166));
      case 'z':
        final tp = TextPainter(
          text: const TextSpan(
            text: 'z z',
            style: TextStyle(
              color: Color(0xFFC9C3FF),
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(c, const Offset(150, 22));
      case 'lines':
        for (var i = 0; i < 3; i++) {
          c.drawLine(
            Offset(24, 120 + i * 14.0),
            Offset(44, 120 + i * 14.0),
            ink,
          );
        }
    }
  }

  @override
  bool shouldRepaint(covariant _MascotPainter old) =>
      old.look != look || old.pose != pose;
}
