import 'package:orbita_kids/shared/domain/entities/content.dart';

/// Grupos del docente.
abstract interface class GroupsRepository {
  /// `false` si los datos dependen de un backend que aún no existe.
  bool get available;
  Future<List<SchoolGroup>> list();
  Future<SchoolGroup> create(String name, String grade);
  Future<SchoolGroup> update(SchoolGroup group);
}
