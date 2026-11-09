import 'package:orbita_kids/shared/domain/entities/content.dart';

/// Actividades asignadas (las usan docente y estudiante).
/// Los borradores viven en el teléfono.
abstract interface class ActivitiesRepository {
  bool get available;
  Future<List<Activity>> list();
  Future<void> saveLocal(Activity activity);
  Future<void> deleteLocal(String id);
}
