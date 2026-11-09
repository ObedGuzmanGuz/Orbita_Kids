import 'package:orbita_kids/shared/domain/entities/content.dart';

/// ============================================================
///  DATOS DE DEMOSTRACIÓN — NO SON DATOS REALES
/// ============================================================
/// Solo se usan en modo demo (sin Keycloak/backend configurados).
/// Nombres, correos, grupos y códigos son ficticios (`*.example`).
abstract final class DemoData {
  /// Fecha de referencia del prototipo: jueves 29 de octubre de 2026.
  static final today = DateTime(2026, 10, 29);

  static const studentGroupId = 'g2a';

  static const groups = <SchoolGroup>[
    SchoolGroup(
      id: 'g2a',
      name: '2° A',
      grade: '2.º de primaria',
      code: 'ORB-2A7K',
      status: GroupStatus.active,
    ),
    SchoolGroup(
      id: 'g2b',
      name: '2° B',
      grade: '2.º de primaria',
      code: 'ORB-2B3M',
      status: GroupStatus.active,
    ),
    SchoolGroup(
      id: 'g3a',
      name: '3° A',
      grade: '3.º de primaria',
      code: 'ORB-3A9Q',
      status: GroupStatus.active,
    ),
    SchoolGroup(
      id: 'g1c',
      name: '1° C',
      grade: '1.º de primaria · ciclo 2025-26',
      code: 'ORB-1C2P',
      status: GroupStatus.archived,
    ),
  ];

  static const _seeds = {'g2a': 3, 'g2b': 11, 'g3a': 23, 'g1c': 31};

  static const _names = {
    'g2a': [
      'Luna M.',
      'Mateo R.',
      'Sofía G.',
      'Diego L.',
      'Valeria P.',
      'Emiliano C.',
      'Camila H.',
      'Santiago T.',
      'Regina V.',
      'Iker S.',
      'Ximena D.',
      'Leonardo F.',
    ],
    'g2b': [
      'Renata A.',
      'Gael M.',
      'Natalia B.',
      'Thiago R.',
      'Paula E.',
      'Adrián O.',
      'Julieta N.',
      'Bruno C.',
      'Ivanna Z.',
      'Matías Q.',
    ],
    'g3a': [
      'Andrea S.',
      'Nicolás P.',
      'Mariana L.',
      'Sebastián G.',
      'Fernanda U.',
      'Daniel K.',
      'Abril T.',
      'Rodrigo V.',
      'Victoria H.',
      'Joaquín E.',
      'Elena W.',
    ],
    'g1c': [
      'Hugo A.',
      'Alma B.',
      'Pablo C.',
      'Lía D.',
      'Tomás E.',
      'Zoe F.',
      'Iván G.',
      'Ana H.',
      'Leo I.',
      'Mía J.',
      'Ciro K.',
      'Eva L.',
      'Noé M.',
      'Ada N.',
      'Gil O.',
      'Isa P.',
      'Uriel Q.',
      'Sara R.',
      'Teo S.',
      'Vera T.',
    ],
  };

  /// Colores ARGB de los avatares de iniciales.
  static const avatarColors = <int>[
    0xFF746BE8,
    0xFF3FBCC6,
    0xFF4DBB98,
    0xFFE0A53A,
    0xFFA35BD6,
    0xFF5776E0,
  ];

  static const frequentErrors = [
    'Sumas que pasan de 10',
    'Volver a contar el primer grupo',
    'Confundir +1 y +2',
    'Sumar decenas con unidades',
    'Respuestas con un número de más',
  ];

  /// Generador congruencial con la misma semilla del prototipo.
  static double Function() _rng(int seed) {
    var s = seed & 0xFFFFFFFF;
    if (s == 0) s = 1;
    return () {
      s = (s * 1664525 + 1013904223) & 0xFFFFFFFF;
      return s / 4294967296;
    };
  }

  static final Map<String, List<StudentSummary>> students = _buildStudents();

  static Map<String, List<StudentSummary>> _buildStudents() {
    final out = <String, List<StudentSummary>>{};
    for (final g in groups) {
      final r = _rng(_seeds[g.id]!);
      final archived = g.status == GroupStatus.archived;
      out[g.id] = [
        for (var i = 0; i < _names[g.id]!.length; i++)
          () {
            final n = _names[g.id]![i];
            var acc = (58 + r() * 38).round();
            var miss = (3 + r() * 9).round();
            List<String>? fixed;
            if (n == 'Luna M.') {
              acc = 84;
              miss = 4;
              fixed = [
                'Sumas que pasan de 10',
                'Respuestas con un número de más',
              ];
            }
            if (n == 'Diego L.') {
              acc = 61;
              miss = 3;
              fixed = [
                'Sumas que pasan de 10',
                'Volver a contar el primer grupo',
              ];
            }
            final pend = archived ? 0 : (r() * 3).floor();
            final last = (r() * 9).floor();
            final status = archived
                ? StudentStatus.finished
                : last > 6
                ? StudentStatus.inactive
                : acc < 68
                ? StudentStatus.needsSupport
                : StudentStatus.upToDate;
            final trend = List.generate(
              6,
              (k) =>
                  (acc - 14 + k * 3 + ((r() - .5) * 10).round()).clamp(35, 98),
            );
            trend[5] = acc;
            final ops = miss * 6 + (r() * 12).round();
            final errs =
                fixed ??
                [
                  frequentErrors[(r() * 3).floor()],
                  frequentErrors[3 + (r() * 2).floor()],
                ];
            return StudentSummary(
              id: '${g.id}-$i',
              name: n,
              groupId: g.id,
              accuracy: acc,
              missed: miss,
              pending: pend,
              operations: ops,
              status: status,
              colorArgb: avatarColors[i % avatarColors.length],
              trend: trend,
              errors: errs,
              lastDays: last,
            );
          }(),
      ];
    }
    return out;
  }

  static final activities = <Activity>[
    Activity(
      id: 'a1',
      name: 'Estrellas hasta 10',
      groupId: 'g2a',
      type: MissionType.visual,
      level: 2,
      count: 8,
      assigned: DateTime(2026, 10, 20),
      due: DateTime(2026, 10, 31),
      status: ActivityStatus.active,
      done: 9,
      instructions: 'Cuenta los objetos antes de responder.',
    ),
    Activity(
      id: 'a2',
      name: 'Selección rápida',
      groupId: 'g2b',
      type: MissionType.choice,
      level: 2,
      count: 10,
      assigned: DateTime(2026, 10, 22),
      due: DateTime(2026, 11, 2),
      status: ActivityStatus.active,
      done: 6,
      instructions: 'Lee la suma con calma y elige una opción.',
    ),
    Activity(
      id: 'a3',
      name: 'Sumas hasta 20',
      groupId: 'g2a',
      type: MissionType.choice,
      level: 4,
      count: 6,
      assigned: DateTime(2026, 10, 27),
      due: DateTime(2026, 11, 3),
      status: ActivityStatus.active,
      done: 4,
      instructions: 'Puedes usar tus dedos o dibujos para contar.',
    ),
    Activity(
      id: 'a4',
      name: 'Decenas en órbita',
      groupId: 'g3a',
      type: MissionType.visual,
      level: 5,
      count: 8,
      assigned: DateTime(2026, 10, 13),
      due: DateTime(2026, 10, 24),
      status: ActivityStatus.closed,
      done: 11,
      instructions: 'Las barras son decenas y los puntos, unidades.',
    ),
    Activity(
      id: 'a5',
      name: 'Repaso de la semana',
      groupId: 'g3a',
      type: MissionType.choice,
      level: 3,
      count: 10,
      assigned: DateTime(2026, 11, 4),
      due: DateTime(2026, 11, 11),
      status: ActivityStatus.scheduled,
      done: 0,
      instructions: 'Repaso de sumas hasta 20.',
    ),
  ];

  static const institutions = <Institution>[
    Institution(
      id: 'edu1',
      name: 'Escuela Primaria Demo Órbita',
      idp: 'Google Workspace for Education',
      protocol: 'OIDC',
    ),
    Institution(
      id: 'edu2',
      name: 'Colegio Demo Horizonte',
      idp: 'Microsoft Entra ID',
      protocol: 'SAML 2.0',
    ),
    Institution(
      id: 'edu3',
      name: 'Instituto Demo Cometa',
      idp: 'Proveedor institucional compatible',
      protocol: 'OIDC',
      down: true,
    ),
  ];

  /// Códigos de grupo de demostración y su resultado.
  static const groupCodeStates = {
    'ORB-OLD1': 'Este código venció. Pide uno nuevo a tu escuela.',
    'ORB-1C2P': 'Ese grupo ya no está disponible: su ciclo escolar terminó.',
    'ORB-FULL':
        'La licencia de la escuela ya no tiene lugares. Avísale a tu maestra.',
  };

  static const weeks = [
    '22 sep',
    '29 sep',
    '6 oct',
    '13 oct',
    '20 oct',
    '27 oct',
  ];
}
