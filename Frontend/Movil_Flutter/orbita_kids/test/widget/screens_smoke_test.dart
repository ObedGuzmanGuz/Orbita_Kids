import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbita_kids/config/routes/app_router.dart';
import 'package:orbita_kids/features/settings/presentation/providers/settings_controller.dart';
import 'package:orbita_kids/features/auth/presentation/providers/auth_controller.dart';
import 'package:orbita_kids/features/auth/domain/entities/auth_entities.dart';

import '../helpers.dart';

const studentRoutes = [
  '/s',
  '/s/map',
  '/s/progress',
  '/s/pause',
  '/s/profile',
  '/s/assigned',
  '/s/avatar',
  '/s/mission/m1',
  '/s/mission/m4',
  '/s/mission/m13',
  '/s/notifications',
  '/s/galaxies',
  '/s/orbi',
  '/s/pause/saltos',
  '/s/pause/saltos/doing',
  '/s/pause/tesoros',
  '/connection',
  '/downloads',
  '/sync',
  '/settings',
  '/settings/a11y',
  '/settings/theme',
  '/profile/edit',
  '/security',
  '/logout',
  '/about',
  '/about/studios',
  '/privacy',
  '/terms',
  '/help',
  '/s/play',
  '/s/results',
];

const teacherRoutes = [
  '/t',
  '/t/groups',
  '/t/activities',
  '/t/reports',
  '/t/profile',
  '/t/group/g2a',
  '/t/group/g1c',
  '/t/student/g2a-3',
  '/t/student/g2a-0',
  '/t/create',
  '/t/notifications',
  '/t/plans',
  '/sync',
  '/settings',
  '/profile/edit',
  '/security',
  '/connection',
];

final publicRoutes = [
  '/login',
  '/login/institution',
  '/login/demo/google',
  '/login/demo/facebook',
  '/login/demo/institution?inst=edu1',
  '/register',
  '/register/code',
  '/recover',
  '/lock',
  '/unlock',
  '/onboarding',
  '/about',
  '/privacy',
  '/help',
  '/settings/a11y',
  '/explore',
  '/s/orbi',
  for (final c in AuthFailureCode.values) '/auth-state/${c.name}?m=google',
];

Future<ProviderContainer> _boot(
  WidgetTester tester, {
  String? user,
  double textScale = 1,
}) async {
  await pumpApp(tester, TestDeps());
  await advance(tester, const Duration(milliseconds: 4000));
  final c = ProviderScope.containerOf(
    tester.element(find.byType(MaterialApp).first),
  );
  if (textScale != 1) {
    // Se aplica igual que en Accesibilidad.
    c
        .read(settingsProvider.notifier)
        .update((s) => s.copyWith(textScale: textScale));
  }
  if (user != null) {
    await c
        .read(authControllerProvider.notifier)
        .signInWithPassword(user, 'orbita123');
    await advance(tester, const Duration(milliseconds: 300));
  }
  return c;
}

Future<void> _visit(
  WidgetTester tester,
  ProviderContainer c,
  List<String> routes,
) async {
  final router = c.read(routerProvider);
  for (final r in routes) {
    router.go(r);
    await advance(tester, const Duration(milliseconds: 500));
    final at = router.routeInformationProvider.value.uri.toString();
    expect(at, r, reason: 'La ruta $r redirigió a $at');
    final e = tester.takeException();
    if (e != null) {
      debugPrint(
        'RUTA $r :: ${e is FlutterError ? e.diagnostics.map((d) => d.toStringDeep()).join(' | ') : e}',
      );
    }
    expect(e, isNull, reason: 'La ruta $r lanzó: $e');
  }
}

void main() {
  setUpAll(initTestEnv);

  testWidgets('todas las pantallas públicas se construyen', (tester) async {
    final c = await _boot(tester);
    await _visit(tester, c, publicRoutes);
  });

  testWidgets('todas las pantallas del estudiante se construyen', (
    tester,
  ) async {
    final c = await _boot(tester, user: 'luna.astro');
    await _visit(tester, c, studentRoutes);
  });

  testWidgets('todas las pantallas del docente se construyen', (tester) async {
    final c = await _boot(tester, user: 'ana.rios');
    await _visit(tester, c, teacherRoutes);
  });

  testWidgets('pantallas del modo explorar se construyen', (tester) async {
    final c = await _boot(tester);
    c.read(authControllerProvider.notifier).startGuest();
    await advance(tester, const Duration(milliseconds: 300));
    await _visit(tester, c, [
      '/g',
      '/g/more',
      '/g/locked',
      '/s/map',
      '/s/pause',
      '/s/avatar',
      '/s/mission/m1',
      '/s/orbi',
    ]);
    // 57 · Lo personal se explica en lugar de ocultarse.
    c.read(routerProvider).go('/s/progress');
    await advance(tester, const Duration(milliseconds: 400));
    expect(
      find.text('Tu progreso está disponible con una cuenta'),
      findsOneWidget,
    );
  });

  testWidgets('pantallas clave con texto muy grande', (tester) async {
    final c = await _boot(tester, user: 'luna.astro', textScale: 1.3);
    await _visit(tester, c, [
      '/s',
      '/s/map',
      '/s/mission/m1',
      '/s/progress',
      '/s/pause',
      '/settings/a11y',
    ]);
  });

  testWidgets('modo oscuro y alto contraste', (tester) async {
    final c = await _boot(tester, user: 'ana.rios');
    c
        .read(settingsProvider.notifier)
        .update(
          (s) => s.copyWith(highContrast: true, theme: AppThemeChoice.dark),
        );
    await _visit(tester, c, [
      '/t',
      '/t/reports',
      '/t/create',
      '/settings/theme',
    ]);
  });
}
