import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orbita_kids/core/sync/data/sync_gateways.dart';
import 'package:orbita_kids/core/sync/domain/sync_models.dart';
import 'package:orbita_kids/features/teacher/data/repositories/server_teacher_repositories.dart';
import 'package:orbita_kids/shared/domain/entities/content.dart';

/// Responde siempre con [status] y guarda la última petición.
class _FixedAdapter implements HttpClientAdapter {
  _FixedAdapter(this.status, [this.body = const {}]);
  final int status;
  final Map<String, dynamic> body;
  RequestOptions? last;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    last = options;
    return ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

SyncItem _item({String? baseVersion}) => SyncItem(
  id: '0b6f2c1e-6d3a-4f5e-9a1b-2c3d4e5f6a7b',
  kind: SyncKind.attempt,
  owner: 'u1',
  title: 'Misión',
  detail: '',
  createdAt: DateTime(2026, 10, 29),
  payload: const {'missionId': 'm1'},
  baseVersion: baseVersion,
);

Future<(SyncOutcome, RequestOptions)> _send(
  int status, {
  String? baseVersion,
  Map<String, dynamic> body = const {},
}) async {
  final adapter = _FixedAdapter(status, body);
  final dio = Dio(BaseOptions(baseUrl: 'http://api.test/v1'))
    ..httpClientAdapter = adapter;
  final out = await HttpSyncGateway(dio).send(_item(baseVersion: baseVersion));
  return (out, adapter.last!);
}

void main() {
  group('HttpSyncGateway', () {
    test('2xx confirma y manda id + Idempotency-Key', () async {
      final (out, req) = await _send(201);
      expect(out, isA<SyncConfirmed>());
      expect(req.path, '/attempts');
      expect(req.headers['Idempotency-Key'], _item().id);
      expect((req.data as Map)['id'], _item().id);
      expect(req.headers.containsKey('If-Match'), isFalse);
    });

    test('409 y 412 son conflicto', () async {
      expect((await _send(409)).$1, isA<SyncConflict>());
      expect((await _send(412)).$1, isA<SyncConflict>());
    });

    test('un rechazo de datos espera a la persona con el mensaje del servidor', () async {
      final (out, _) = await _send(
        422,
        body: {
          'error': {'code': 'bad_request', 'message': 'Datos inválidos'},
        },
      );
      expect(out, isA<SyncConflict>());
      expect((out as SyncConflict).message, contains('Datos inválidos'));
    });

    test('5xx y 401 se reintentan', () async {
      expect((await _send(500)).$1, isA<SyncRetry>());
      expect((await _send(401)).$1, isA<SyncRetry>());
    });

    test('If-Match solo con versiones del servidor', () async {
      expect((await _send(200, baseVersion: '3')).$2.headers['If-Match'], '"3"');
      expect(
        (await _send(200, baseVersion: 'server-latest')).$2.headers
            .containsKey('If-Match'),
        isFalse,
      );
    });
  });

  group('resumen de estudiante del servidor', () {
    Map<String, dynamic> json({
      Object? accuracy = 80,
      List<Object?> trend = const [70, 75, 80, 80, 85, 80],
      Object? lastDays = 2,
    }) => {
      'id': 's1',
      'name': 'Luna',
      'groupId': 'g1',
      'accuracy': accuracy,
      'missed': 3,
      'pending': 1,
      'operations': 12,
      'status': 'upToDate',
      'colorArgb': 0xFF746BE8,
      'trend': trend,
      'errors': <String>[],
      'lastDays': lastDays,
      'recent': [
        {
          'id': 't1',
          'missionId': 'm1',
          'title': null,
          'firstTry': 5,
          'total': 6,
          'finishedAt': '2026-10-28T15:00:00.000Z',
        },
      ],
    };

    test('convierte los campos y resuelve el nombre de la misión', () {
      final s = HttpUsersRepository.studentFromJson(json());
      expect(s.accuracy, 80);
      expect(s.status, StudentStatus.upToDate);
      expect(s.recent.single.title, 'Enciende las luces');
      expect(s.recent.single.ok, 5);
    });

    test('sin datos: 0 % y semanas vacías repiten el valor anterior', () {
      final s = HttpUsersRepository.studentFromJson(
        json(accuracy: null, trend: [null, 60, null, null, 80, null], lastDays: null),
      );
      expect(s.accuracy, 0);
      expect(s.trend, [60, 60, 60, 60, 80, 80]);
      expect(s.lastDays, isNull);
      expect(
        HttpUsersRepository.studentFromJson(json(trend: List.filled(6, null))).trend,
        List.filled(6, 0),
      );
    });

    test('semanas iguales a las del servidor (lunes, UTC)', () {
      expect(
        HttpUsersRepository.weekLabels(DateTime.utc(2026, 10, 29, 15)),
        ['21 sep', '28 sep', '5 oct', '12 oct', '19 oct', '26 oct'],
      );
    });
  });
}
