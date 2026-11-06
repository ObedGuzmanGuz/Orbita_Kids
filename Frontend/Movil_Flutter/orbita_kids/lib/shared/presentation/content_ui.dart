import 'package:flutter/material.dart';

import 'package:orbita_kids/shared/domain/entities/content.dart';

/// Traducción de las entidades del dominio (colores ARGB y claves de ícono)
/// a tipos de Flutter. El dominio no conoce `Color` ni `IconData`.

extension PlanetUi on Planet {
  Color get light => Color(lightArgb);
  Color get dark => Color(darkArgb);
}

extension GalaxyUi on Galaxy {
  Color get light => Color(lightArgb);
  Color get dark => Color(darkArgb);

  IconData get icon => switch (iconKey) {
    'planet' => Icons.public_rounded,
    'book' => Icons.menu_book_rounded,
    'grid' => Icons.grid_view_rounded,
    'target' => Icons.track_changes_rounded,
    'leaf' => Icons.eco_rounded,
    'brush' => Icons.brush_rounded,
    _ => Icons.auto_awesome_rounded,
  };
}

extension BadgeUi on BadgeDef {
  Color get color => Color(colorArgb);
}

extension StudentSummaryUi on StudentSummary {
  Color get color => Color(colorArgb);
}

extension PauseCategoryUi on PauseCategory {
  IconData get icon => switch (this) {
    PauseCategory.movement => Icons.directions_run_rounded,
    PauseCategory.outdoor => Icons.eco_rounded,
    PauseCategory.creative => Icons.brush_rounded,
    PauseCategory.family => Icons.groups_rounded,
  };

  Color get color => switch (this) {
    PauseCategory.movement => const Color(0xFF4DBB98),
    PauseCategory.outdoor => const Color(0xFF3FBCC6),
    PauseCategory.creative => const Color(0xFFA99BF5),
    PauseCategory.family => const Color(0xFFE0A53A),
  };
}
