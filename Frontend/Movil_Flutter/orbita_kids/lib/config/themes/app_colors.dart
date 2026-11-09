import 'package:flutter/material.dart';

/// Paleta de marca tomada del prototipo (variables CSS `--sp`, `--ind`, ...).
abstract final class Brand {
  static const space = Color(0xFF0D102B);
  static const indigo = Color(0xFF191B58);
  static const indigo2 = Color(0xFF2E3192);
  static const indigo3 = Color(0xFF2A2C7A);
  static const purple = Color(0xFF746BE8);
  static const purpleDark = Color(0xFF5E55D6);
  static const violet = Color(0xFF9186F5);
  static const lavender = Color(0xFFC9C3FF);
  static const lavenderText = Color(0xFFD7D3FF);
  static const white = Color(0xFFFAF9FF);
  static const yellow = Color(0xFFFFD166);
  static const turquoise = Color(0xFF69D6DE);
  static const mint = Color(0xFF82D9B4);
  static const ink = Color(0xFF292742);
  static const mintDark = Color(0xFF2E8C69);
  static const turquoiseDark = Color(0xFF1D8C96);
  static const orange = Color(0xFFFFA25E);
}

/// Tokens semánticos de la app (claro/oscuro), equivalentes a `.app` y
/// `.app[data-th="dark"]` del prototipo.
@immutable
class OkColors extends ThemeExtension<OkColors> {
  const OkColors({
    required this.bg,
    required this.card,
    required this.ink,
    required this.muted,
    required this.line,
    required this.soft,
    required this.tintViolet,
    required this.tintTeal,
    required this.tintYellow,
    required this.tintMint,
    required this.tintGray,
    required this.inkViolet,
    required this.inkTeal,
    required this.inkYellow,
    required this.inkMint,
    required this.purpleDark,
    required this.ok,
    required this.okBg,
    required this.err,
    required this.errBg,
    required this.errInk,
    required this.highContrast,
  });

  final Color bg, card, ink, muted, line, soft;
  final Color tintViolet, tintTeal, tintYellow, tintMint, tintGray;
  final Color inkViolet, inkTeal, inkYellow, inkMint, purpleDark;
  final Color ok, okBg, err, errBg, errInk;
  final bool highContrast;

  static const light = OkColors(
    bg: Color(0xFFFAF9FF),
    card: Colors.white,
    ink: Color(0xFF292742),
    muted: Color(0xFF66638A),
    line: Color(0xFFE4E1F5),
    soft: Color(0xFFF1EFFC),
    tintViolet: Color(0xFFECEAFF),
    tintTeal: Color(0xFFDDF5F7),
    tintYellow: Color(0xFFFFF1C7),
    tintMint: Color(0xFFDDF5EA),
    tintGray: Color(0xFFEEEDF3),
    inkViolet: Color(0xFF4D44C4),
    inkTeal: Color(0xFF156C74),
    inkYellow: Color(0xFF7A5600),
    inkMint: Color(0xFF17694A),
    purpleDark: Color(0xFF5E55D6),
    ok: Color(0xFF1F8F5F),
    okBg: Color(0xFFE3F7EE),
    err: Color(0xFFC8455E),
    errBg: Color(0xFFFDECEF),
    errInk: Color(0xFF8E2338),
    highContrast: false,
  );

  static const dark = OkColors(
    bg: Color(0xFF0E1130),
    card: Color(0xFF1A1E4C),
    ink: Color(0xFFEEECFF),
    muted: Color(0xFFADA9DF),
    line: Color(0xFF30357A),
    soft: Color(0xFF22265F),
    tintViolet: Color(0x389186F5),
    tintTeal: Color(0x2B69D6DE),
    tintYellow: Color(0x2BFFD166),
    tintMint: Color(0x2B82D9B4),
    tintGray: Color(0x17FFFFFF),
    inkViolet: Color(0xFFCCC6FF),
    inkTeal: Color(0xFF9BE8EE),
    inkYellow: Color(0xFFFFE08A),
    inkMint: Color(0xFFA6EBCB),
    purpleDark: Color(0xFFB9B2FF),
    ok: Color(0xFF7FE0B2),
    okBg: Color(0x2B82D9B4),
    err: Color(0xFFFF9EAA),
    errBg: Color(0x33E8697E),
    errInk: Color(0xFFFFC2CC),
    highContrast: false,
  );

  /// Alto contraste: textos secundarios con el color principal y bordes marcados.
  OkColors toHighContrast(bool isDark) => copyWith(
    muted: ink,
    line: isDark ? const Color(0xFFB9B2FF) : const Color(0xFF6B6890),
    highContrast: true,
  );

  @override
  OkColors copyWith({Color? muted, Color? line, bool? highContrast}) =>
      OkColors(
        bg: bg,
        card: card,
        ink: ink,
        muted: muted ?? this.muted,
        line: line ?? this.line,
        soft: soft,
        tintViolet: tintViolet,
        tintTeal: tintTeal,
        tintYellow: tintYellow,
        tintMint: tintMint,
        tintGray: tintGray,
        inkViolet: inkViolet,
        inkTeal: inkTeal,
        inkYellow: inkYellow,
        inkMint: inkMint,
        purpleDark: purpleDark,
        ok: ok,
        okBg: okBg,
        err: err,
        errBg: errBg,
        errInk: errInk,
        highContrast: highContrast ?? this.highContrast,
      );

  @override
  OkColors lerp(OkColors? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return OkColors(
      bg: l(bg, other.bg),
      card: l(card, other.card),
      ink: l(ink, other.ink),
      muted: l(muted, other.muted),
      line: l(line, other.line),
      soft: l(soft, other.soft),
      tintViolet: l(tintViolet, other.tintViolet),
      tintTeal: l(tintTeal, other.tintTeal),
      tintYellow: l(tintYellow, other.tintYellow),
      tintMint: l(tintMint, other.tintMint),
      tintGray: l(tintGray, other.tintGray),
      inkViolet: l(inkViolet, other.inkViolet),
      inkTeal: l(inkTeal, other.inkTeal),
      inkYellow: l(inkYellow, other.inkYellow),
      inkMint: l(inkMint, other.inkMint),
      purpleDark: l(purpleDark, other.purpleDark),
      ok: l(ok, other.ok),
      okBg: l(okBg, other.okBg),
      err: l(err, other.err),
      errBg: l(errBg, other.errBg),
      errInk: l(errInk, other.errInk),
      highContrast: t < .5 ? highContrast : other.highContrast,
    );
  }
}

extension OkColorsX on BuildContext {
  OkColors get ok => Theme.of(this).extension<OkColors>()!;
}
