import 'package:dio/dio.dart';

import 'package:orbita_kids/core/network/api_client.dart';
import 'package:orbita_kids/features/auth/domain/entities/auth_entities.dart';
import 'package:orbita_kids/features/auth/domain/repositories/auth_repositories.dart';

/// `GET /me`: grupo, institución y nombre que guarda el backend.
class HttpProfileRepository implements ProfileRepository {
  const HttpProfileRepository(this._dio);
  final Dio _dio;

  @override
  Future<AppUser?> fetch(AppUser local) async {
    final res = await _dio.get<Map<String, dynamic>>(ApiEndpoints.me);
    final j = res.data;
    if (j == null) return null;
    return local.copyWith(
      name: j['name'] as String?,
      role: switch (j['role']) {
        'teacher' => UserRole.teacher,
        'student' => UserRole.student,
        _ => null,
      },
      email: j['email'] as String?,
      username: j['username'] as String?,
      groupId: j['groupId'] as String?,
      institution: j['institution'] as String?,
    );
  }
}

/// Sin servidor: el perfil es el de la sesión.
class NoServerProfileRepository implements ProfileRepository {
  const NoServerProfileRepository();

  @override
  Future<AppUser?> fetch(AppUser local) async => null;
}

/// Registro contra el backend: el código se valida con la licencia
/// (`POST /group-codes/check`, público). El nombre de usuario lo valida
/// Keycloak al crear la cuenta.
class HttpRegistrationRepository implements RegistrationRepository {
  const HttpRegistrationRepository(this._dio);
  final Dio _dio;

  @override
  Future<GroupCodeCheck> validateGroupCode(String code) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '${ApiEndpoints.groupCodes}/check',
        data: {'code': code},
      );
      final j = res.data ?? const {};
      return j['valid'] == true
          ? GroupCodeCheck.valid(j['groupName'] as String)
          : GroupCodeCheck.invalid(
              j['error'] as String? ?? 'Ese código no es válido.',
            );
    } on DioException catch (e) {
      if (e.response?.statusCode == 429) {
        return GroupCodeCheck.invalid(apiErrorMessage(e));
      }
      throw const BackendUnavailable('validar códigos de grupo');
    }
  }

  @override
  Future<bool> isUsernameTaken(String username) async => false;
}
