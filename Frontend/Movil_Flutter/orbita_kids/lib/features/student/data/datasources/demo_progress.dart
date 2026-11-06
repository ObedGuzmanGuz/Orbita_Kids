import 'package:orbita_kids/features/student/domain/entities/student_progress.dart';
import 'package:orbita_kids/shared/domain/entities/avatar_look.dart';
import 'package:orbita_kids/shared/domain/entities/content.dart';

/// DATOS DE DEMOSTRACIÓN: progreso inicial de la cuenta demo «Luna».
abstract final class DemoProgress {
  static StudentProgress luna(DateTime today) => StudentProgress(
    name: 'Luna',
    look: const AvatarLook(),
    stars: 42,
    minutesToday: 12,
    minutesDate: today,
    done: const {'m1': 3, 'm2': 3, 'm3': 2, 'm4': 2},
    pieces: const ['luces'],
    history: [
      HistoryEntry(
        name: 'Recoge estrellas',
        date: DateTime(2026, 10, 28),
        ok: 4,
        total: 5,
        stars: 2,
        type: MissionType.visual,
      ),
      HistoryEntry(
        name: 'Revisa el tablero',
        date: DateTime(2026, 10, 27),
        ok: 3,
        total: 5,
        stars: 2,
        type: MissionType.mix,
      ),
      HistoryEntry(
        name: 'Cuenta los cometas',
        date: DateTime(2026, 10, 24),
        ok: 5,
        total: 5,
        stars: 3,
        type: MissionType.choice,
      ),
      HistoryEntry(
        name: 'Enciende las luces',
        date: DateTime(2026, 10, 22),
        ok: 4,
        total: 5,
        stars: 3,
        type: MissionType.visual,
      ),
      HistoryEntry(
        name: 'Enciende las luces',
        date: DateTime(2026, 10, 21),
        ok: 3,
        total: 5,
        stars: 2,
        type: MissionType.visual,
      ),
    ],
    sessionAccuracy: const [60, 64, 72, 70, 80],
    badges: const {'b1', 'b2', 'b3', 'b6'},
    downloads: const {'uno', 'nebula'},
  );
}
