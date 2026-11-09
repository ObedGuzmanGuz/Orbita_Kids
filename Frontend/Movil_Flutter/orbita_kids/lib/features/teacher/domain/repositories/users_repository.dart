import 'package:orbita_kids/shared/domain/entities/content.dart';

/// Estudiantes (usuarios) visibles para el docente.
abstract interface class UsersRepository {
  bool get available;
  Future<List<StudentSummary>> studentsOf(String groupId);
  Future<StudentSummary?> student(String id);

  /// Etiquetas de las semanas que cubre `StudentSummary.trend`.
  List<String> trendLabels();
}
