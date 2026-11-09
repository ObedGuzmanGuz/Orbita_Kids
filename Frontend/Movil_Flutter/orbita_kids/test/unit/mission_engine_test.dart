import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:orbita_kids/features/student/data/datasources/demo_progress.dart';
import 'package:orbita_kids/features/student/domain/services/mission_engine.dart';
import 'package:orbita_kids/features/student/domain/entities/student_progress.dart';
import 'package:orbita_kids/shared/domain/content/catalog.dart';
import 'package:orbita_kids/shared/domain/entities/content.dart';

MissionRun _run(List<SumItem> items, {int level = 1}) => MissionRun(
  missionId: 'm1',
  name: 'Enciende las luces',
  level: level,
  type: MissionType.visual,
  planetId: 'uno',
  items: items,
  random: Random(1),
);

void main() {
  group('generateItems por nivel', () {
    for (var seed = 0; seed < 20; seed++) {
      final r = Random(seed);
      test('semilla $seed respeta las reglas de cada nivel', () {
        for (final it in generateItems(
          1,
          MissionType.visual,
          n: 5,
          random: r,
        )) {
          expect(it.answer, lessThanOrEqualTo(5));
        }
        for (final it in generateItems(
          2,
          MissionType.choice,
          n: 5,
          random: r,
        )) {
          expect(it.answer, lessThanOrEqualTo(10));
        }
        for (final it in generateItems(
          3,
          MissionType.visual,
          n: 5,
          random: r,
        )) {
          expect(it.a, inInclusiveRange(10, 19));
          expect(
            it.a % 10 + it.b,
            lessThan(10),
            reason: 'nivel 3 no pasa la decena',
          );
        }
        for (final it in generateItems(
          4,
          MissionType.visual,
          n: 5,
          random: r,
        )) {
          expect(
            it.answer,
            inInclusiveRange(11, 20),
            reason: 'nivel 4 pasa la decena',
          );
        }
        for (final it in generateItems(
          5,
          MissionType.visual,
          n: 5,
          random: r,
        )) {
          expect(
            it.a % 10 + it.b % 10,
            lessThan(10),
            reason: 'nivel 5 sin llevar',
          );
          expect(it.answer, lessThanOrEqualTo(99));
        }
        for (final it in generateItems(
          6,
          MissionType.visual,
          n: 5,
          random: r,
        )) {
          expect(
            it.a % 10 + it.b % 10,
            greaterThanOrEqualTo(10),
            reason: 'nivel 6 llevando',
          );
          expect(it.answer, lessThanOrEqualTo(99));
        }
      });
    }

    test('las opciones son 4, positivas, únicas e incluyen la respuesta', () {
      final items = generateItems(
        2,
        MissionType.choice,
        n: 5,
        random: Random(3),
      );
      for (final it in items) {
        expect(it.options.length, 4);
        expect(it.options.toSet().length, 4);
        expect(it.options, contains(it.answer));
        expect(it.options.every((o) => o > 0), isTrue);
      }
    });

    test('la modalidad mixta alterna dibujos y opciones', () {
      final items = generateItems(2, MissionType.mix, n: 4, random: Random(5));
      expect(items.map((i) => i.kind), [
        MissionType.visual,
        MissionType.choice,
        MissionType.visual,
        MissionType.choice,
      ]);
    });

    test('no repite sumas dentro de una misión', () {
      final items = generateItems(
        2,
        MissionType.visual,
        n: 6,
        random: Random(9),
      );
      expect(items.map((i) => '${i.a}+${i.b}').toSet().length, items.length);
    });
  });

  group('MissionRun y reglas', () {
    List<SumItem> fixed(int n) => [
      for (var i = 0; i < n; i++)
        const SumItem(
          a: 2,
          b: 1,
          kind: MissionType.visual,
          options: [3, 4, 2, 5],
          object: 'star',
        ),
    ];

    test('estrellas: 3 con 80 %, 2 con 60 %, 1 en otro caso', () {
      final r = _run(fixed(5));
      for (var i = 0; i < 4; i++) {
        r.answer(3, 'a$i');
        r.next();
      }
      r.answer(9, 'x');
      r.answer(3, 'y');
      r.next();
      expect(r.finished, isTrue);
      expect(r.percent, 80);
      expect(r.stars, 3);
      expect(r.hints, 1, reason: 'corrigió después de una pista');
      expect(r.attempts, 6);
    });

    test('R1: dos errores seguidos al primer intento activan apoyo visual', () {
      final items = generateItems(
        3,
        MissionType.choice,
        n: 5,
        random: Random(2),
      );
      final r = MissionRun(
        missionId: 'm8',
        name: 'Motor encendido',
        level: 3,
        type: MissionType.choice,
        items: items,
        random: Random(2),
      );
      r.answer(-1, 'a');
      r.next();
      r.answer(-1, 'b');
      r.next();
      expect(r.support, isTrue);
      expect(r.ruleJustApplied, isTrue);
      for (var i = r.index; i < r.total; i++) {
        expect(r.items[i].kind, MissionType.visual);
        expect(
          r.items[i].answer,
          lessThanOrEqualTo(6),
          reason: 'sumas más pequeñas',
        );
      }
    });

    test('R2 con 90 % o más y R3 con menos de 60 %', () {
      final good = _run(fixed(5));
      for (var i = 0; i < 5; i++) {
        good.answer(3, 'g$i');
        good.next();
      }
      expect(good.rule, AdaptRule.r2Advance);

      final low = _run(fixed(5));
      for (var i = 0; i < 5; i++) {
        low.answer(i < 2 ? 3 : 0, 'l$i');
        if (i >= 2) low.answer(3, 'l$i-b');
        low.next();
      }
      expect(low.percent, 40);
      expect(low.rule, AdaptRule.r3Reinforce);
      expect(low.stars, 1, reason: 'nunca 0 estrellas');
    });

    test('R4 avisa al docente tras 2 misiones seguidas bajo 60 %', () {
      expect(shouldNotifyTeacher(1), isFalse);
      expect(shouldNotifyTeacher(2), isTrue);
    });
  });

  group('StudentProgress', () {
    test('desbloqueo progresivo de planetas', () {
      const p = StudentProgress(done: {'m1': 3, 'm2': 2});
      expect(p.planetUnlocked('uno'), isTrue);
      expect(p.planetUnlocked('nebula'), isFalse);
      final p2 = p.copyWith(done: {'m1': 3, 'm2': 2, 'm3': 1});
      expect(p2.planetUnlocked('nebula'), isTrue);
      expect(p2.planetUnlocked('saturnia'), isFalse);
      expect(p2.nextMission().id, 'm4');
    });

    test('en modo explorar solo el Planeta Verde', () {
      const p = StudentProgress(done: {'m1': 3, 'm2': 3, 'm3': 3});
      expect(p.planetUnlocked('nebula', guest: true), isFalse);
    });

    test('se serializa sin perder datos', () {
      final p = DemoProgress.luna(DateTime(2026, 10, 29));
      final back = StudentProgress.fromJson(p.toJson());
      expect(back.done, p.done);
      expect(back.badges, p.badges);
      expect(back.history.length, p.history.length);
      expect(back.downloads, p.downloads);
    });

    test('el catálogo tiene 6 planetas con 3 misiones cada uno', () {
      expect(Catalog.planets.length, 6);
      for (final pl in Catalog.planets) {
        expect(Catalog.missionsOf(pl.id).length, 3);
      }
      expect(Catalog.pauseActivities.map((a) => a.category).toSet().length, 4);
    });
  });
}
