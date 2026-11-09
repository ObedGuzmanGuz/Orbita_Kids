import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Regla de dependencias de la arquitectura limpia:
///
/// * `domain/`: Dart puro. No conoce Flutter, Riverpod, plugins ni las capas
///   `data/` y `presentation/`.
/// * `data/`: implementa contratos del dominio. No conoce la presentación
///   ni widgets.
/// * `presentation/`: usa casos de uso y entidades. No importa `data/`
///   directamente: las implementaciones se inyectan desde `di.dart`.
void main() {
  final files = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .map(
        (f) => (path: f.path.replaceAll(r'\', '/'), src: f.readAsStringSync()),
      )
      .toList();

  List<String> importsOf(String src) => RegExp(
    r"""^(?:import|export) '([^']+)'""",
    multiLine: true,
  ).allMatches(src).map((m) => m.group(1)!).toList();

  const platformPackages = [
    'package:flutter/',
    'package:flutter_riverpod/',
    'package:riverpod/',
    'package:go_router/',
    'package:dio/',
    'package:sqflite/',
    'package:shared_preferences/',
    'package:flutter_secure_storage/',
    'package:flutter_appauth/',
    'package:connectivity_plus/',
    'package:flutter_local_notifications/',
    'package:flutter_tts/',
  ];

  bool inLayer(String path, String layer) => path.contains('/$layer/');

  test('el dominio es Dart puro y no depende de otras capas', () {
    final violations = <String>[];
    for (final f in files.where((f) => inLayer(f.path, 'domain'))) {
      for (final i in importsOf(f.src)) {
        if (platformPackages.any(i.startsWith) ||
            i.contains('/data/') ||
            i.contains('/presentation/')) {
          violations.add('${f.path} → $i');
        }
      }
    }
    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('la capa de datos no depende de la presentación ni de widgets', () {
    final violations = <String>[];
    for (final f in files.where((f) => inLayer(f.path, 'data'))) {
      for (final i in importsOf(f.src)) {
        if (i.contains('/presentation/') ||
            i.startsWith('package:flutter/material') ||
            i.startsWith('package:flutter/widgets')) {
          violations.add('${f.path} → $i');
        }
      }
    }
    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('la presentación no importa implementaciones de datos', () {
    final violations = <String>[];
    for (final f in files.where((f) => inLayer(f.path, 'presentation'))) {
      for (final i in importsOf(f.src)) {
        if (i.contains('/data/')) violations.add('${f.path} → $i');
      }
    }
    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('cada feature con lógica tiene sus tres capas', () {
    for (final feature in [
      'auth',
      'student',
      'teacher',
      'notifications',
      'plans',
      'settings',
    ]) {
      for (final layer in ['domain', 'data', 'presentation']) {
        expect(
          Directory('lib/features/$feature/$layer').existsSync(),
          isTrue,
          reason: '$feature/$layer',
        );
      }
    }
  });

  test('la navegación usa AppRoutes, nunca rutas escritas a mano', () {
    final literal = RegExp(r"""\.(go|push|pushReplacement)(<\w+>)?\(\s*'/""");
    final violations = [
      for (final f in files.where((f) => !f.path.contains('/routes/')))
        if (literal.hasMatch(f.src)) f.path,
    ];
    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('los GoRoute solo se declaran en carpetas routes/', () {
    final violations = [
      for (final f in files)
        if (f.src.contains('GoRoute(') && !f.path.contains('/routes/')) f.path,
    ];
    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('los espacios comunes usan los tokens del tema (Gap)', () {
    final raw = RegExp(
      r'const SizedBox\((height|width): (4|6|8|10|12|14|16|18|20|22|24)\)',
    );
    final violations = [
      for (final f in files.where((f) => !f.path.contains('/themes/')))
        if (raw.hasMatch(f.src)) f.path,
    ];
    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('cada feature con lógica expone sus proveedores de dependencias', () {
    for (final feature in [
      'auth',
      'student',
      'teacher',
      'notifications',
      'plans',
      'settings',
    ]) {
      expect(
        Directory('lib/features/$feature/providers').existsSync(),
        isTrue,
        reason: '$feature/providers',
      );
    }
  });
}
