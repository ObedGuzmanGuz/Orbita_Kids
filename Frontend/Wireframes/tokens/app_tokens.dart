// Órbita Kids · Design tokens MÓVIL (Flutter). Unidades: píxeles lógicos (lp = dp).
// No multiplicar por devicePixelRatio: Flutter ya trabaja en lp. Generado por tools/export_specs.py

import 'package:flutter/material.dart';

abstract final class AppSpacing {
  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 20.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
}

abstract final class AppRadius {
  static const double card = 12.0;
  static const double button = 10.0;
  static const double row = 10.0;
  static const double input = 8.0;
  static const double doc = 4.0;
  static const double checkbox = 4.0;
  static const double track = 4.0;
  static const double chip = 18.0;
  static const double search = 24.0;
  static const double searchHeader = 22.0;
  static const double switchTrack = 12.0;
  static const BorderRadius cardR = BorderRadius.all(Radius.circular(card));
  static const BorderRadius buttonR = BorderRadius.all(Radius.circular(button));
  static const BorderRadius inputR = BorderRadius.all(Radius.circular(input));
}

abstract final class AppSize {
  static const double button = 48.0;
  static const double input = 48.0;
  static const double textarea = 96.0;
  static const double chip = 36.0;
  static const double cellButton = 28.0;
  static const double icon = 24.0;
  static const double iconSm = 20.0;
  static const double iconMd = 32.0;
  static const double iconXl = 56.0;
  static const double avatar = 40.0;
  static const double avatarAppBar = 32.0;
  static const double avatarLg = 72.0;
  static const double stepBadge = 24.0;
  static const double radio = 20.0;
  static const double radioDot = 10.0;
  static const double radioRubric = 18.0;
  static const double checkbox = 20.0;
  static const double switchW = 44.0;
  static const double switchH = 24.0;
  static const double switchThumb = 16.0;
  static const double progress = 8.0;
  static const double timerRing = 116.0;
  static const double playButton = 56.0;
  static const double rowList = 64.0;
  static const double rowToggle = 56.0;
  static const double rowCheck = 52.0;
  static const double rowTable = 44.0;
  static const double rowStepMobile = 44.0;
  static const double rowStepWeb = 48.0;
  static const double tapTarget = 48.0;
}

abstract final class AppLayout {
  static const double canvasW = 375.0;
  static const double canvasH = 812.0;
  static const double statusBar = 44.0;
  static const double appBar = 56.0;
  static const double navBar = 64.0;
  static const double body = 648.0;
  static const double pagePadding = 16.0;
  static const double contentWidth = 343.0;
  static const double blockGap = 12.0;
  static const double listGap = 8.0;
  static const double cardPadding = 16.0;
  static const double heroPadding = 20.0;
  static const double navItemW = 93.75;
  static const EdgeInsets page = EdgeInsets.fromLTRB(16, 16, 16, 16);
  static const EdgeInsets card = EdgeInsets.all(16);
  static const EdgeInsets hero = EdgeInsets.all(20);
}

abstract final class AppText {
  // height = lineHeight / fontSize (Flutter usa multiplicador)
  static const TextStyle h1Web = TextStyle(fontSize: 28, height: 36/28, fontWeight: FontWeight.w700); // 28/36
  static const TextStyle h1Mobile = TextStyle(fontSize: 22, height: 28/22, fontWeight: FontWeight.w700); // 22/28
  static const TextStyle h2 = TextStyle(fontSize: 20, height: 28/20, fontWeight: FontWeight.w700); // 20/28
  static const TextStyle timer = TextStyle(fontSize: 26, height: 32/26, fontWeight: FontWeight.w700); // 26/32
  static const TextStyle statValue = TextStyle(fontSize: 28, height: 36/28, fontWeight: FontWeight.w700); // 28/36
  static const TextStyle cardTitle = TextStyle(fontSize: 17, height: 24/17, fontWeight: FontWeight.w700); // 17/24
  static const TextStyle brandWeb = TextStyle(fontSize: 16, height: 22/16, fontWeight: FontWeight.w700); // 16/22
  static const TextStyle title = TextStyle(fontSize: 14, height: 20/14, fontWeight: FontWeight.w700); // 14/20
  static const TextStyle body = TextStyle(fontSize: 13, height: 18/13, fontWeight: FontWeight.w400); // 13/18
  static const TextStyle bodyStrong = TextStyle(fontSize: 13, height: 18/13, fontWeight: FontWeight.w700); // 13/18
  static const TextStyle small = TextStyle(fontSize: 12, height: 16/12, fontWeight: FontWeight.w400); // 12/16
  static const TextStyle caption = TextStyle(fontSize: 11, height: 16/11, fontWeight: FontWeight.w400); // 11/16
  static const TextStyle label = TextStyle(fontSize: 11, height: 16/11, fontWeight: FontWeight.w700); // 11/16
  static const TextStyle nav = TextStyle(fontSize: 10, height: 14/10, fontWeight: FontWeight.w400); // 10/14
  static const TextStyle paragraph = TextStyle(fontSize: 14, height: 20/14, fontWeight: FontWeight.w400); // 14/20
}
