import 'package:flutter/widgets.dart';

/// Escala de espaciado de Órbita Kids (múltiplos de 2 px, como el prototipo).
abstract final class AppSpacing {
  static const xxs = 2.0;
  static const xs = 4.0;
  static const sm = 6.0;
  static const md = 8.0;
  static const ml = 10.0;
  static const lg = 12.0;
  static const xl = 16.0;
  static const xxl = 20.0;
  static const xxxl = 24.0;

  /// Margen lateral de las pantallas.
  static const screen = 20.0;

  /// Relleno de una página con encabezado.
  static const page = EdgeInsets.fromLTRB(screen, 4, screen, 32);

  /// Relleno interno de tarjetas.
  static const card = EdgeInsets.all(xl);
}

/// Separadores verticales (`Gap.h12`) y horizontales (`Gap.w12`) listos
/// para usar en columnas y filas.
abstract final class Gap {
  static const h2 = SizedBox(height: 2);
  static const h4 = SizedBox(height: 4);
  static const h6 = SizedBox(height: 6);
  static const h8 = SizedBox(height: 8);
  static const h10 = SizedBox(height: 10);
  static const h12 = SizedBox(height: 12);
  static const h14 = SizedBox(height: 14);
  static const h16 = SizedBox(height: 16);
  static const h18 = SizedBox(height: 18);
  static const h20 = SizedBox(height: 20);
  static const h22 = SizedBox(height: 22);
  static const h24 = SizedBox(height: 24);

  static const w4 = SizedBox(width: 4);
  static const w6 = SizedBox(width: 6);
  static const w8 = SizedBox(width: 8);
  static const w10 = SizedBox(width: 10);
  static const w12 = SizedBox(width: 12);
  static const w14 = SizedBox(width: 14);
  static const w18 = SizedBox(width: 18);
}

/// Radios de esquina (`--r-s`, `--r-m`, `--r-l` del prototipo).
abstract final class AppRadius {
  static const xs = 6.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 18.0;
  static const xl = 22.0;
  static const xxl = 26.0;
  static const pill = 999.0;

  static const small = BorderRadius.all(Radius.circular(sm));
  static const field = BorderRadius.all(Radius.circular(md));
  static const card = BorderRadius.all(Radius.circular(lg));
  static const sheet = BorderRadius.all(Radius.circular(xxl));
}
