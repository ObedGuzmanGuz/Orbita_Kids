import 'package:flutter/material.dart';

/// Familias de la marca.
const kDisplayFont = 'Fredoka';
const kBodyFont = 'Nunito';

/// Estilos de texto que no cubre el `TextTheme` de Material.
abstract final class AppTextStyles {
  /// Cifras y operaciones (`3 + 2 =`): Fredoka con números tabulares.
  static TextStyle number(double size, {Color? color}) => TextStyle(
    fontFamily: kDisplayFont,
    fontSize: size,
    fontWeight: FontWeight.w600,
    color: color,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  /// Encabezados de sección en mayúsculas («AJUSTES»).
  static TextStyle eyebrow(Color color) => TextStyle(
    fontSize: 12,
    letterSpacing: 1.2,
    fontWeight: FontWeight.w900,
    color: color,
  );

  /// Texto fuerte de tarjetas y filas.
  static const strong = TextStyle(fontWeight: FontWeight.w800);

  /// Etiquetas de chips y estados.
  static TextStyle tag(Color color) =>
      TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 12.5);
}
