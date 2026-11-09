import 'package:orbita_kids/features/plans/domain/repositories/plans_repository.dart';
import 'package:orbita_kids/shared/domain/entities/content.dart';

class GetPlans {
  const GetPlans(this._repo);
  final PlansRepository _repo;

  List<Plan> call() => _repo.plans();
}

/// Valida y guarda una solicitud de información (sin pagos).
class RequestPlanInformation {
  const RequestPlanInformation(this._repo);
  final PlansRepository _repo;

  static final _mail = RegExp(r'^\S+@\S+\.\S+$');

  /// Devuelve un mensaje de error o `null` si quedó guardada.
  Future<String?> call(PlanInfoRequest r) async {
    if (r.institution.trim().isEmpty || !_mail.hasMatch(r.contact.trim())) {
      return 'Escribe la institución y un correo válido.';
    }
    await _repo.requestInfo(r);
    return null;
  }
}
