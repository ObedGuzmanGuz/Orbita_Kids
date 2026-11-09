import 'package:dio/dio.dart';

import 'package:orbita_kids/core/network/api_cache.dart';
import 'package:orbita_kids/core/network/api_client.dart';
import 'package:orbita_kids/features/teacher/domain/repositories/groups_repository.dart';
import 'package:orbita_kids/features/teacher/domain/repositories/users_repository.dart';
import 'package:orbita_kids/shared/domain/content/catalog.dart';
import 'package:orbita_kids/shared/domain/entities/content.dart';

// ===================== CON SERVIDOR (backend/) =====================

/// Convierte un error de Dio en lo que la UI sabe mostrar.
Never _fail(DioException e, String what) {
  if (e.response == null) throw BackendUnavailable(what);
  throw ServerRejected(apiErrorMessage(e));
}

/// `GET/POST /groups`, `PATCH /groups/:id`.
class HttpGroupsRepository implements GroupsRepository {
  const HttpGroupsRepository(this._dio, this._cache);
  final Dio _dio;
  final ApiCache _cache;

  @override
  bool get available => true;

  @override
  Future<List<SchoolGroup>> list() async {
    final data = await _cache.get(ApiEndpoints.groups) as Map;
    return [
      for (final g in data['items'] as List)
        SchoolGroup.fromJson(Map<String, dynamic>.from(g as Map)),
    ];
  }

  @override
  Future<SchoolGroup> create(String name, String grade) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        ApiEndpoints.groups,
        data: {'name': name, 'grade': grade},
      );
      return SchoolGroup.fromJson(res.data!);
    } on DioException catch (e) {
      _fail(e, 'crear grupos');
    }
  }

  @override
  Future<SchoolGroup> update(SchoolGroup group) async {
    try {
      final res = await _dio.patch<Map<String, dynamic>>(
        '${ApiEndpoints.groups}/${group.id}',
        data: {
          'name': group.name,
          'grade': group.grade,
          'status': group.status.name,
        },
      );
      return SchoolGroup.fromJson(res.data!);
    } on DioException catch (e) {
      _fail(e, 'editar grupos');
    }
  }
}

/// `GET /groups/:id/students` y `GET /students/:id`.
class HttpUsersRepository implements UsersRepository {
  const HttpUsersRepository(this._cache);
  final ApiCache _cache;

  @override
  bool get available => true;

  @override
  Future<List<StudentSummary>> studentsOf(String groupId) async {
    final data =
        await _cache.get('${ApiEndpoints.groups}/$groupId/students') as Map;
    return [
      for (final s in data['items'] as List)
        studentFromJson(Map<String, dynamic>.from(s as Map)),
    ];
  }

  @override
  Future<StudentSummary?> student(String id) async {
    try {
      final data = await _cache.get('${ApiEndpoints.students}/$id');
      return studentFromJson(Map<String, dynamic>.from(data as Map));
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  /// Las mismas 6 semanas que calcula el servidor (de lunes a domingo, UTC).
  @override
  List<String> trendLabels() => weekLabels(DateTime.now().toUtc());

  static const _months = [
    'ene', 'feb', 'mar', 'abr', 'may', 'jun',
    'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
  ];

  static List<String> weekLabels(DateTime nowUtc, {int weeks = 6}) {
    final monday = DateTime.utc(
      nowUtc.year,
      nowUtc.month,
      nowUtc.day - (nowUtc.weekday - 1),
    );
    return [
      for (var i = weeks - 1; i >= 0; i--)
        () {
          final d = DateTime.utc(monday.year, monday.month, monday.day - 7 * i);
          return '${d.day} ${_months[d.month - 1]}';
        }(),
    ];
  }

  /// El servidor manda `null` donde no hay datos. La UI espera números:
  /// sin intentos, los aciertos cuentan como 0, y una semana sin intentos
  /// repite el valor anterior para no hundir la gráfica.
  static StudentSummary studentFromJson(Map<String, dynamic> j) {
    final raw = [for (final v in j['trend'] as List? ?? const []) v as int?];
    var prev = raw.firstWhere((v) => v != null, orElse: () => 0) ?? 0;
    final trend = [for (final v in raw) prev = v ?? prev];
    return StudentSummary(
      id: j['id'] as String,
      name: j['name'] as String,
      groupId: j['groupId'] as String,
      accuracy: j['accuracy'] as int? ?? 0,
      missed: j['missed'] as int? ?? 0,
      pending: j['pending'] as int? ?? 0,
      operations: j['operations'] as int? ?? 0,
      status: StudentStatus.values.byName(j['status'] as String),
      colorArgb: j['colorArgb'] as int,
      trend: trend,
      errors: List<String>.from(j['errors'] as List? ?? const []),
      lastDays: j['lastDays'] as int?,
      recent: [
        for (final a in j['recent'] as List? ?? const [])
          _attemptFromJson(Map<String, dynamic>.from(a as Map)),
      ],
    );
  }

  static RecentAttempt _attemptFromJson(Map<String, dynamic> j) {
    final missionId = j['missionId'] as String;
    final mission = Catalog.missions.where((m) => m.id == missionId);
    return RecentAttempt(
      id: j['id'] as String,
      title:
          j['title'] as String? ??
          (mission.isEmpty ? 'Misión' : mission.first.name),
      ok: j['firstTry'] as int,
      total: j['total'] as int,
      date: DateTime.parse(j['finishedAt'] as String),
    );
  }
}
