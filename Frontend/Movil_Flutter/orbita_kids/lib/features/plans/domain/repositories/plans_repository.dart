import 'package:orbita_kids/shared/domain/entities/content.dart';

/// Planes institucionales: solo consulta y solicitud de información.
/// No hay pagos ni checkout.
abstract interface class PlansRepository {
  List<Plan> plans();

  /// Guarda la solicitud para enviarla. Nunca se marca como enviada hasta
  /// que el backend la confirme.
  Future<void> requestInfo(PlanInfoRequest request);
}

/// Datos de una solicitud de información de un plan.
class PlanInfoRequest {
  const PlanInfoRequest({
    required this.owner,
    required this.plan,
    required this.yearly,
    required this.institution,
    required this.contact,
    required this.students,
    this.message = '',
  });

  final String owner;
  final Plan plan;
  final bool yearly;
  final String institution;
  final String contact;
  final int students;
  final String message;
}
