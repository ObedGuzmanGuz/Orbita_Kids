import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:orbita_kids/app.dart';
import 'package:orbita_kids/config/providers/app_overrides.dart';

/// Inicializa la infraestructura real y arranca la app.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_MX');
  runApp(
    ProviderScope(
      overrides: await productionOverrides(),
      child: const OrbitaKidsApp(),
    ),
  );
}
