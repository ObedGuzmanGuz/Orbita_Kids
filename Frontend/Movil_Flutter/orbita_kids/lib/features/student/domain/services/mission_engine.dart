import 'dart:math';

import 'package:meta/meta.dart';

import 'package:orbita_kids/shared/domain/entities/content.dart';

/// Ejercicio de suma.
@immutable
class SumItem {
  const SumItem({
    required this.a,
    required this.b,
    required this.kind,
    required this.options,
    required this.object,
  });

  final int a;
  final int b;

  /// `visual` (teclado con objetos) o `choice` (4 opciones).
  final MissionType kind;
  final List<int> options;

  /// Objeto a contar: `star`, `planet` o `rocket`.
  final String object;

  int get answer => a + b;
}

/// Genera sumas por nivel (equivalente a `genItems` del prototipo).
List<SumItem> generateItems(
  int level,
  MissionType type, {
  int n = 5,
  bool easy = false,
  Random? random,
}) {
  final r = random ?? Random();
  int rnd(int k) => r.nextInt(max(1, k));
  final items = <SumItem>[];
  final seen = <String>{};
  var guard = 0;
  while (items.length < n && guard++ < 400) {
    int a, b;
    if (level == 6) {
      final u1 = 2 + rnd(8);
      final lo = max(1, 10 - u1);
      final u2 = lo + rnd(9 - lo + 1);
      final t1 = 1 + rnd(4);
      final t2 = 1 + rnd(max(1, 8 - t1));
      a = t1 * 10 + u1;
      b = t2 * 10 + u2;
      if (u1 + u2 < 10 || a + b > 99) continue;
    } else if (level == 5) {
      final t1 = 1 + rnd(4);
      final t2 = 1 + rnd(9 - t1 - 1);
      final u1 = rnd(8);
      final u2 = rnd(9 - u1);
      a = t1 * 10 + u1;
      b = t2 * 10 + u2;
    } else if (level == 4) {
      a = 5 + rnd(5);
      final bmin = 11 - a;
      b = bmin + rnd(9 - bmin + 1);
    } else if (level == 3) {
      final u1 = rnd(9);
      a = 10 + u1;
      b = 1 + rnd(9 - u1);
      if (u1 + b > 9) continue;
    } else {
      final m = easy ? 6 : (level == 1 ? 5 : 10);
      a = 1 + rnd(m - 2);
      b = 1 + rnd(m - a);
    }
    final key = '$a+$b';
    if (!seen.add(key)) continue;
    final kind = type == MissionType.mix
        ? (items.length.isOdd ? MissionType.choice : MissionType.visual)
        : type;
    final ans = a + b;
    final opts = <int>{ans};
    final cand = level >= 5
        ? [ans + 10, ans - 10, ans + 1, ans - 1, ans + 11]
        : [ans + 1, ans - 1, ans + 2, ans - 2, ans + 3];
    cand.shuffle(r);
    for (final c in cand) {
      if (opts.length >= 4) break;
      if (c > 0) opts.add(c);
    }
    final options = opts.toList()..shuffle(r);
    items.add(
      SumItem(
        a: a,
        b: b,
        kind: kind,
        options: options,
        object: const ['star', 'planet', 'rocket'][items.length % 3],
      ),
    );
  }
  return items;
}

/// Regla de adaptación aplicada al terminar.
enum AdaptRule { r2Advance, r3Reinforce }

/// Estado de una misión en curso (`ST.run` del prototipo).
class MissionRun {
  MissionRun({
    required this.missionId,
    required this.name,
    required this.level,
    required this.type,
    required this.items,
    this.planetId,
    this.assigned = false,
    this.reinforcement = false,
    Random? random,
  }) : _random = random ?? Random();

  final String missionId;
  final String name;
  final int level;
  final MissionType type;
  final String? planetId;

  /// Tarea de la maestra (no cuenta para el mapa).
  final bool assigned;

  /// Misión de refuerzo (R3).
  final bool reinforcement;
  final List<SumItem> items;
  final Random _random;

  int index = 0;
  int firstTry = 0;
  int attempts = 0;

  /// Intentos del ejercicio actual.
  int tries = 0;
  int hints = 0;
  int consecutiveFirstTryErrors = 0;

  /// R1 activado: el resto usa apoyo visual con números más pequeños.
  bool support = false;

  /// R1 se activó al pasar al ejercicio actual (para avisar).
  bool ruleJustApplied = false;
  final attemptIds = <String>[];

  SumItem get current => items[index];
  bool get finished => index >= items.length;
  int get total => items.length;

  /// Registra una respuesta. Devuelve `true` si es correcta.
  bool answer(int value, String attemptId) {
    final ok = value == current.answer;
    attempts++;
    tries++;
    attemptIds.add(attemptId);
    if (tries == 1) {
      if (ok) {
        firstTry++;
        consecutiveFirstTryErrors = 0;
      } else {
        consecutiveFirstTryErrors++;
      }
    } else if (ok) {
      // Corrigió después de una pista (insignia «Paciencia lunar»).
      hints++;
    }
    return ok;
  }

  /// Avanza al siguiente ejercicio y aplica R1 si corresponde.
  void next() {
    index++;
    tries = 0;
    ruleJustApplied = false;
    if (consecutiveFirstTryErrors >= 2 && !support && index < items.length) {
      support = true;
      ruleJustApplied = true;
      final easy = generateItems(
        1,
        MissionType.visual,
        n: items.length - index,
        easy: true,
        random: _random,
      );
      items.replaceRange(index, items.length, easy);
    }
  }

  int get percent => total == 0 ? 0 : (firstTry * 100 / total).round();

  /// 3 estrellas ≥ 80 %, 2 ≥ 60 %, 1 en otro caso (nunca 0).
  int get stars => percent >= 80
      ? 3
      : percent >= 60
      ? 2
      : 1;

  /// R2 (≥ 90 %) o R3 (< 60 %).
  AdaptRule? get rule => percent >= 90
      ? AdaptRule.r2Advance
      : percent < 60
      ? AdaptRule.r3Reinforce
      : null;
}

/// R4: 2 misiones seguidas por debajo de 60 % → avisar al docente.
bool shouldNotifyTeacher(int lowStreak) => lowStreak >= 2;
