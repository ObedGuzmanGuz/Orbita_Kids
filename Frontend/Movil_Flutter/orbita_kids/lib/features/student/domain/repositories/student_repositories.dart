import 'package:orbita_kids/features/student/domain/entities/student_progress.dart';
import 'package:orbita_kids/shared/domain/entities/content.dart';

/// Contenido de misiones. Hoy viene empaquetado con la app (funciona sin
/// Internet); un backend podría publicar planetas nuevos más adelante.
abstract interface class MissionsRepository {
  List<Planet> planets();
  List<Mission> missionsOf(String planetId);
  Mission mission(String id);
}

/// Progreso del estudiante guardado en el teléfono.
abstract interface class ProgressRepository {
  Future<StudentProgress?> load(String owner);
  Future<void> save(String owner, StudentProgress progress);

  /// Progreso con el que empieza una cuenta sin datos guardados.
  StudentProgress initialFor(String name, DateTime today);
}
