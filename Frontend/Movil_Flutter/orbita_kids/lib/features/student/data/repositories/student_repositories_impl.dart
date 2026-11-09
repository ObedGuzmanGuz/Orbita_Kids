import 'package:orbita_kids/core/storage/local_store.dart';
import 'package:orbita_kids/features/student/data/datasources/demo_progress.dart';
import 'package:orbita_kids/features/student/domain/entities/student_progress.dart';
import 'package:orbita_kids/features/student/domain/repositories/student_repositories.dart';
import 'package:orbita_kids/shared/domain/content/catalog.dart';
import 'package:orbita_kids/shared/domain/entities/content.dart';

/// Misiones empaquetadas con la app (disponibles sin Internet).
class BundledMissionsRepository implements MissionsRepository {
  const BundledMissionsRepository();

  @override
  List<Planet> planets() => Catalog.planets;

  @override
  List<Mission> missionsOf(String planetId) => Catalog.missionsOf(planetId);

  @override
  Mission mission(String id) => Catalog.mission(id);
}

/// Progreso guardado en el teléfono (SQLite). En modo demo, una cuenta sin
/// datos empieza con el progreso de «Luna» del prototipo.
class LocalProgressRepository implements ProgressRepository {
  const LocalProgressRepository(this._store, {required this.demo});
  final LocalStore _store;
  final bool demo;

  static const col = 'progress';

  @override
  Future<StudentProgress?> load(String owner) async {
    final j = await _store.get(col, owner);
    return j == null ? null : StudentProgress.fromJson(j);
  }

  @override
  Future<void> save(String owner, StudentProgress progress) =>
      _store.put(col, owner, progress.toJson());

  @override
  StudentProgress initialFor(String name, DateTime today) => demo
      ? DemoProgress.luna(today)
      : StudentProgress(name: name, downloads: const {'uno'});
}
