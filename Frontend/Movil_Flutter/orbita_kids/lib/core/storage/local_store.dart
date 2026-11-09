import 'dart:convert';

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Almacén local de documentos JSON por colección (offline first).
///
/// Colecciones usadas: `progress`, `sync_queue`, `sync_done`, `drafts`,
/// `downloads`, `notifications`, `reports`, `avatar`, `pause_log`.
abstract interface class LocalStore {
  Future<List<Map<String, dynamic>>> all(String collection);
  Future<Map<String, dynamic>?> get(String collection, String id);
  Future<void> put(String collection, String id, Map<String, dynamic> data);
  Future<void> delete(String collection, String id);
  Future<void> clear(String collection);
}

/// Implementación con SQLite (sqflite). Una tabla `records` indexada por
/// colección; `updated_at` permite resolver conflictos por fecha.
class SqliteLocalStore implements LocalStore {
  SqliteLocalStore._(this._db);

  final Database _db;

  static Future<SqliteLocalStore> open() async {
    final dir = await getDatabasesPath();
    final db = await openDatabase(
      p.join(dir, 'orbita_kids.db'),
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE records(
            collection TEXT NOT NULL,
            id TEXT NOT NULL,
            json TEXT NOT NULL,
            updated_at INTEGER NOT NULL,
            PRIMARY KEY(collection, id)
          )''');
        await db.execute(
          'CREATE INDEX idx_records_collection ON records(collection, updated_at)',
        );
      },
    );
    return SqliteLocalStore._(db);
  }

  @override
  Future<List<Map<String, dynamic>>> all(String collection) async {
    final rows = await _db.query(
      'records',
      where: 'collection = ?',
      whereArgs: [collection],
      orderBy: 'updated_at DESC',
    );
    return [
      for (final r in rows)
        jsonDecode(r['json']! as String) as Map<String, dynamic>,
    ];
  }

  @override
  Future<Map<String, dynamic>?> get(String collection, String id) async {
    final rows = await _db.query(
      'records',
      where: 'collection = ? AND id = ?',
      whereArgs: [collection, id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return jsonDecode(rows.first['json']! as String) as Map<String, dynamic>;
  }

  @override
  Future<void> put(String collection, String id, Map<String, dynamic> data) =>
      _db.insert('records', {
        'collection': collection,
        'id': id,
        'json': jsonEncode(data),
        'updated_at': DateTime.now().microsecondsSinceEpoch,
      }, conflictAlgorithm: ConflictAlgorithm.replace);

  @override
  Future<void> delete(String collection, String id) => _db.delete(
    'records',
    where: 'collection = ? AND id = ?',
    whereArgs: [collection, id],
  );

  @override
  Future<void> clear(String collection) =>
      _db.delete('records', where: 'collection = ?', whereArgs: [collection]);
}

/// Implementación en memoria (pruebas y respaldo si SQLite no abre).
class MemoryLocalStore implements LocalStore {
  final _data = <String, Map<String, Map<String, dynamic>>>{};
  final _order = <String, int>{};
  int _tick = 0;

  @override
  Future<List<Map<String, dynamic>>> all(String collection) async {
    final m = _data[collection] ?? {};
    final keys = m.keys.toList()
      ..sort(
        (a, b) => (_order['$collection/$b'] ?? 0).compareTo(
          _order['$collection/$a'] ?? 0,
        ),
      );
    return [for (final k in keys) _copy(m[k]!)];
  }

  @override
  Future<Map<String, dynamic>?> get(String collection, String id) async {
    final v = _data[collection]?[id];
    return v == null ? null : _copy(v);
  }

  @override
  Future<void> put(
    String collection,
    String id,
    Map<String, dynamic> data,
  ) async {
    (_data[collection] ??= {})[id] = _copy(data);
    _order['$collection/$id'] = ++_tick;
  }

  @override
  Future<void> delete(String collection, String id) async {
    _data[collection]?.remove(id);
  }

  @override
  Future<void> clear(String collection) async => _data.remove(collection);

  Map<String, dynamic> _copy(Map<String, dynamic> m) =>
      jsonDecode(jsonEncode(m)) as Map<String, dynamic>;
}
