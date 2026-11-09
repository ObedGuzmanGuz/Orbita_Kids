import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbita_kids/config/routes/app_router.dart';
import 'package:orbita_kids/core/sync/domain/sync_models.dart';
import 'package:orbita_kids/core/sync/presentation/providers/sync_controller.dart';
import 'package:orbita_kids/features/student/presentation/providers/student_controller.dart';
import 'package:orbita_kids/features/student/domain/services/mission_engine.dart';
import 'package:orbita_kids/shared/domain/entities/content.dart';

import '../helpers.dart';

Future<void> _toLogin(WidgetTester tester) async {
  await advance(tester, const Duration(milliseconds: 2200));
  await advance(tester, const Duration(milliseconds: 1700));
  expect(find.text('¡Bienvenido a bordo!'), findsOneWidget);
}

Future<void> _demoSignIn(WidgetTester tester, String user) async {
  await tester.tap(find.text('Entrar con cuenta Órbita Kids'));
  await tester.pump();
  await tester.enterText(
    find.widgetWithText(TextField, 'Usuario Órbita Kids'),
    user,
  );
  await tester.enterText(
    find.widgetWithText(TextField, 'Contraseña'),
    'orbita123',
  );
  await tester.ensureVisible(find.widgetWithText(FilledButton, 'Entrar'));
  await tester.tap(find.widgetWithText(FilledButton, 'Entrar'));
  await advance(tester, const Duration(milliseconds: 1800));
}

ProviderContainer _container(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(MaterialApp).first));

void main() {
  setUpAll(initTestEnv);

  testWidgets('splash → studios → login con modo demo señalado', (
    tester,
  ) async {
    await pumpApp(tester, TestDeps());
    expect(find.text('Saltar'), findsOneWidget);
    expect(find.text('¡Guau! Soy Orbi'), findsOneWidget);
    await _toLogin(tester);
    expect(find.textContaining('MODO DEMO'), findsOneWidget);
    expect(find.text('Continuar con Google'), findsOneWidget);
    expect(find.text('Continuar con Facebook'), findsOneWidget);
    expect(find.text('Acceder con mi institución'), findsOneWidget);
    expect(find.text('Explorar sin cuenta'), findsOneWidget);
  });

  testWidgets('validaciones y contador de intentos en el login', (
    tester,
  ) async {
    await pumpApp(tester, TestDeps());
    await _toLogin(tester);
    await tester.tap(find.text('Entrar con cuenta Órbita Kids'));
    await tester.pump();
    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Entrar'));
    await tester.tap(find.widgetWithText(FilledButton, 'Entrar'));
    await tester.pump();
    expect(find.text('Escribe tu usuario.'), findsOneWidget);
    expect(find.text('Escribe tu contraseña.'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextField, 'Usuario Órbita Kids'),
      'luna.astro',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Contraseña'),
      'equivocada',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Entrar'));
    await tester.pump();
    expect(find.textContaining('Te quedan 2 intentos'), findsOneWidget);
  });

  testWidgets('mostrar y ocultar contraseña', (tester) async {
    await pumpApp(tester, TestDeps());
    await _toLogin(tester);
    await tester.tap(find.text('Entrar con cuenta Órbita Kids'));
    await tester.pump();
    TextField pw() =>
        tester.widget<TextField>(find.widgetWithText(TextField, 'Contraseña'));
    expect(pw().obscureText, isTrue);
    await tester.tap(find.byTooltip('Mostrar contraseña'));
    await tester.pump();
    expect(pw().obscureText, isFalse);
  });

  testWidgets('estudiante demo entra a su home', (tester) async {
    await pumpApp(tester, TestDeps());
    await _toLogin(tester);
    await _demoSignIn(tester, 'luna.astro');
    expect(find.text('¡Hola, Luna!'), findsOneWidget);
    expect(find.text('Continuar misión'), findsOneWidget);
    expect(find.text('Mi progreso'), findsOneWidget);
  });

  testWidgets('docente demo entra a su dashboard', (tester) async {
    await pumpApp(tester, TestDeps());
    await _toLogin(tester);
    await _demoSignIn(tester, 'ana.rios');
    expect(find.text('Hola, Ana'), findsOneWidget);
    expect(find.text('estudiantes activos'), findsOneWidget);
    expect(find.text('Grupos'), findsWidgets);
  });

  testWidgets('modo explorar sin cuenta', (tester) async {
    await pumpApp(tester, TestDeps());
    await _toLogin(tester);
    await tester.ensureVisible(find.text('Explorar sin cuenta'));
    await tester.tap(find.text('Explorar sin cuenta'));
    await advance(tester, const Duration(milliseconds: 400));
    // 54 · Antes de entrar se explica qué se puede hacer sin cuenta.
    expect(find.text('Mira cómo es Órbita Kids'), findsOneWidget);
    await tester.tap(find.text('Empezar a explorar'));
    await advance(tester, const Duration(milliseconds: 400));
    expect(find.text('¡Hola, explorador!'), findsOneWidget);
    expect(find.textContaining('no guardamos datos'), findsOneWidget);

    // 56 · Pestaña «Más» del invitado.
    await tester.tap(find.text('Más'));
    await advance(tester, const Duration(milliseconds: 400));
    expect(find.text('¿Cómo obtengo una cuenta?'), findsOneWidget);
  });

  testWidgets(
    'misión con apoyo visual: respuesta correcta y resultado en cola',
    (tester) async {
      await pumpApp(tester, TestDeps());
      await _toLogin(tester);
      await _demoSignIn(tester, 'luna.astro');
      final c = _container(tester);

      // Misión controlada de un ejercicio para la prueba.
      c
          .read(runProvider.notifier)
          .begin(
            MissionRun(
              missionId: 'm1',
              name: 'Enciende las luces',
              level: 1,
              type: MissionType.visual,
              planetId: 'uno',
              items: [
                const SumItem(
                  a: 2,
                  b: 1,
                  kind: MissionType.visual,
                  options: [3, 4, 2, 5],
                  object: 'star',
                ),
              ],
            ),
          );
      c.read(routerProvider).push('/s/play');
      await advance(tester, const Duration(milliseconds: 400));

      expect(find.text('2 + 1 ='), findsOneWidget);
      await tester.tap(find.text('3').last);
      await tester.pump();
      await tester.tap(find.text('Comprobar'));
      await tester.pump();
      expect(find.textContaining('¡Excelente!'), findsOneWidget);

      await tester.tap(find.text('Continuar'));
      await advance(tester, const Duration(milliseconds: 600));
      expect(find.text('¡Misión perfecta, astronauta!'), findsOneWidget);

      // Sin backend: queda en el teléfono, nunca «Guardado en la base».
      final items = c.read(syncControllerProvider).of('u-luna');
      expect(items.single.kind, SyncKind.attempt);
      expect(find.text('Guardado en la base'), findsNothing);
      expect(c.read(studentProvider).done['m1'], 3);
    },
  );
}
