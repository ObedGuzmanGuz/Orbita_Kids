import 'package:flutter/material.dart';

import 'package:orbita_kids/config/themes/app_themes.dart';

/// Gráfico de línea (evolución por semana). Accesible mediante [label].
class LineChart extends StatelessWidget {
  const LineChart({
    super.key,
    required this.values,
    required this.labels,
    required this.label,
    this.height = 160,
    this.color = Brand.purple,
  });

  final List<num> values;
  final List<String> labels;
  final String label;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final c = context.ok;
    return Semantics(
      label: label,
      image: true,
      excludeSemantics: true,
      child: SizedBox(
        height: height,
        child: CustomPaint(
          size: Size.infinite,
          painter: _LinePainter(
            values.map((e) => e.toDouble()).toList(),
            labels,
            color,
            c.line,
            c.muted,
            c.card,
          ),
        ),
      ),
    );
  }
}

class _LinePainter extends CustomPainter {
  _LinePainter(this.v, this.labels, this.color, this.grid, this.text, this.bg);
  final List<double> v;
  final List<String> labels;
  final Color color, grid, text, bg;

  @override
  void paint(Canvas canvas, Size size) {
    const left = 36.0, bottom = 22.0, top = 10.0;
    final w = size.width - left - 8, h = size.height - bottom - top;
    final gp = Paint()
      ..color = grid
      ..strokeWidth = 1;
    for (final t in [0, 50, 100]) {
      final y = top + h - h * t / 100;
      canvas.drawLine(Offset(left, y), Offset(size.width - 4, y), gp);
      _text(canvas, '$t%', Offset(left - 6, y), align: TextAlign.right);
    }
    if (v.isEmpty) return;
    final step = v.length > 1 ? w / (v.length - 1) : 0.0;
    Offset pt(int i) =>
        Offset(left + 4 + step * i, top + h - h * v[i].clamp(0, 100) / 100);
    final path = Path()..moveTo(pt(0).dx, pt(0).dy);
    for (var i = 1; i < v.length; i++) {
      path.lineTo(pt(i).dx, pt(i).dy);
    }
    final area = Path.from(path)
      ..lineTo(pt(v.length - 1).dx, top + h)
      ..lineTo(pt(0).dx, top + h)
      ..close();
    canvas.drawPath(area, Paint()..color = color.withValues(alpha: .12));
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeJoin = StrokeJoin.round,
    );
    for (var i = 0; i < v.length; i++) {
      canvas.drawCircle(pt(i), 5, Paint()..color = bg);
      canvas.drawCircle(pt(i), 4, Paint()..color = color);
      if (i < labels.length) {
        _text(
          canvas,
          labels[i],
          Offset(pt(i).dx, size.height - 8),
          align: TextAlign.center,
        );
      }
    }
  }

  void _text(
    Canvas c,
    String s,
    Offset at, {
    TextAlign align = TextAlign.left,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: s,
        style: TextStyle(
          color: text,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final dx = switch (align) {
      TextAlign.right => at.dx - tp.width,
      TextAlign.center => at.dx - tp.width / 2,
      _ => at.dx,
    };
    tp.paint(c, Offset(dx, at.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _LinePainter o) =>
      o.v != v || o.color != color || o.grid != grid;
}

/// Barras horizontales con etiqueta y valor (reportes legibles en teléfono).
class HBar extends StatelessWidget {
  const HBar({
    super.key,
    required this.label,
    required this.value,
    required this.max,
    this.suffix = '',
    this.color = Brand.purple,
  });

  final String label;
  final num value;
  final num max;
  final String suffix;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final c = context.ok;
    final f = max == 0 ? 0.0 : (value / max).clamp(0, 1).toDouble();
    return Semantics(
      label: '$label: $value$suffix',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                Text(
                  '$value$suffix',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ],
            ),
            Gap.h4,
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: f,
                minHeight: 10,
                color: color,
                backgroundColor: c.line,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Barras verticales «tú contra tú» del estudiante.
class SelfBars extends StatelessWidget {
  const SelfBars({super.key, required this.values});
  final List<int> values;

  @override
  Widget build(BuildContext context) {
    final c = context.ok;
    return Semantics(
      label:
          'Aciertos de tus últimas misiones: ${values.join(', ')} por ciento',
      excludeSemantics: true,
      child: SizedBox(
        height: 150,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (var i = 0; i < values.length; i++)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '${values[i]}',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: c.ink,
                        ),
                      ),
                      Gap.h2,
                      Container(
                        height: values[i].clamp(4, 100).toDouble(),
                        decoration: BoxDecoration(
                          color: i == values.length - 1
                              ? Brand.purple
                              : Brand.lavender,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      Gap.h4,
                      Text(
                        i == values.length - 1 ? 'Hoy' : '#${i + 1}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: c.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
