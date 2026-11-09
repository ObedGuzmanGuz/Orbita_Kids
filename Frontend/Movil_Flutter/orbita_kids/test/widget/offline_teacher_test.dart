import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbita_kids/config/routes/app_router.dart';
import 'package:orbita_kids/features/settings/presentation/providers/settings_controller.dart';
import 'package:orbita_kids/core/sync/domain/sync_models.dart';
import 'package:orbita_kids/core/sync/presentation/providers/sync_controller.dart';
import 'package:orbita_kids/features/auth/presentation/providers/auth_controller.dart';
import 'package:orbita_kids/shared/data/repositories/activities_repository_impl.dart';
import 'package:orbita_kids/shared/domain/entities/content.dart';

import '../helpers.dart';

Future<ProviderContainer> _boot(
  WidgetTester tester,
  TestDeps deps, {
  String? user,
}) async {
  await pumpApp(tester, deps);
  await advance(tester, const Duration(milliseconds: 4000));
  final c = ProviderScope.containerOf(
    tester.element(find.byType(MaterialApp).first),
  );
  if (user != null) {
    await c
        .read(authControllerProvider.notifier)
        .signInWithPassword(user, 'orbita123');
    await advance(tester, const Duration(milliseconds: 300));
  }
  return c;
}

void main() {
  setUpAll(initTestEnv);

  testWidgets('sin Internet: el borrador se guarda y publicar se bloquea', (
    tester,
  ) async {
    final deps = TestDeps(online: false);
    final c = await _boot(tester, deps, user: 'ana.rios');
    expect(
      find.textContaining('Sin conexión'),
      findsWidgets,
      reason: 'indicador de estado visible',
    );

    c.read(routerProvider).push('/t/create?group=g2a');
    await advance(tester, const Duration(milliseconds: 400));
    await tester.enterText(
      find.widgetWithText(TextField, 'Nombre de la actividad'),
      'Repaso offline',
    );
    await tester.tap(find.text('Publicar'));
    await advance(tester, const Duration(milliseconds: 300));
    expect(find.textContaining('Publicar necesita Internet'), findsOneWidget);
    expect(c.read(syncControllerProvider).items, isEmpty);

    await tester.tap(find.text('Guardar borrador'));
    await advance(tester, const Duration(milliseconds: 400));
    final saved = await deps.store.all(LocalActivitiesRepository.col);
    expect(saved.single['name'], 'Repaso offline');
    expect(saved.single['status'], ActivityStatus.draft.name);
  });

  testWidgets('publicar con conexión deja la actividad pendiente de envío', (
    tester,
  ) async {
    final deps = TestDeps();
    final c = await _boot(tester, deps, user: 'ana.rios');
    c.read(routerProvider).push('/t/create?group=g2a');
    await advance(tester, const Duration(milliseconds: 400));
    await tester.enterText(
      find.widgetWithText(TextField, 'Nombre de la actividad'),
      'Sumas del viernes',
    );
    await tester.tap(find.text('Publicar'));
    await advance(tester, const Duration(milliseconds: 300));
    expect(find.text('¿Publicar actividad?'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Publicar').last);
    await advance(tester, const Duration(milliseconds: 600));

    final items = c.read(syncControllerProvider).of('u-ana');
    expect(items.single.kind, SyncKind.activityDraft);
    expect(items.single.status, isNot(SyncStatus.syncing));
    expect(
      c.read(syncControllerProvider).confirmed,
      isEmpty,
      reason: 'sin servidor nada se confirma',
    );

    c.read(routerProvider).go('/sync');
    await advance(tester, const Duration(milliseconds: 400));
    expect(find.text('Servidor pendiente'), findsOneWidget);
    expect(find.text('Sumas del viernes'), findsOneWidget);
  });

  testWidgets('3 contraseñas incorrectas llevan a la pantalla de pausa', (
    tester,
  ) async {
    final deps = TestDeps();
    await _boot(tester, deps);
    await tester.tap(find.text('Entrar con cuenta Órbita Kids'));
    await tester.pump();
    for (var i = 0; i < 3; i++) {
      await tester.enterText(
        find.widgetWithText(TextField, 'Usuario Órbita Kids'),
        'luna.astro',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Contraseña'),
        'nop',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Entrar'));
      await advance(tester, const Duration(milliseconds: 300));
    }
    expect(find.text('Tu cuenta está en pausa'), findsOneWidget);
    expect(find.text('15:00'), findsOneWidget);
  });

  testWidgets('accesibilidad: el tamaño de texto se aplica a toda la app', (
    tester,
  ) async {
    final deps = TestDeps();
    final c = await _boot(tester, deps);
    c.read(routerProvider).push('/settings/a11y');
    await advance(tester, const Duration(milliseconds: 400));
    await tester.tap(find.text('Muy grande'));
    await advance(tester, const Duration(milliseconds: 200));
    expect(c.read(settingsProvider).textScale, 1.3);
    final ctx = tester.element(find.text('Vista previa'));
    expect(MediaQuery.textScalerOf(ctx).scale(10), closeTo(13, .01));

    await tester.tap(find.text('Alto contraste'));
    await advance(tester, const Duration(milliseconds: 200));
    expect(c.read(settingsProvider).highContrast, isTrue);
  });
}
