/// Configuración de la app leída de `--dart-define`.
///
/// La app no guarda secretos: solo identificadores públicos de un cliente
/// OIDC público (PKCE). Si falta la configuración de Keycloak, la app entra en
/// **modo demo**, que se señala en pantalla y nunca simula integraciones reales.
class AppConfig {
  const AppConfig({
    required this.keycloakIssuer,
    required this.keycloakClientId,
    required this.keycloakRedirectUri,
    required this.keycloakPostLogoutRedirectUri,
    required this.apiBaseUrl,
    required this.idpHintGoogle,
    required this.idpHintFacebook,
    required this.idpHintInstitution,
    required this.roleStudent,
    required this.roleTeacher,
    this.apiDevAuth = false,
  });

  factory AppConfig.fromEnvironment() => const AppConfig(
    keycloakIssuer: String.fromEnvironment('KEYCLOAK_ISSUER'),
    keycloakClientId: String.fromEnvironment('KEYCLOAK_CLIENT_ID'),
    keycloakRedirectUri: String.fromEnvironment(
      'KEYCLOAK_REDIRECT_URI',
      defaultValue: 'com.orbitastudio.orbitakids:/oauthredirect',
    ),
    keycloakPostLogoutRedirectUri: String.fromEnvironment(
      'KEYCLOAK_POST_LOGOUT_REDIRECT_URI',
      defaultValue: 'com.orbitastudio.orbitakids:/logout',
    ),
    apiBaseUrl: String.fromEnvironment('API_BASE_URL'),
    idpHintGoogle: String.fromEnvironment(
      'KEYCLOAK_IDP_GOOGLE',
      defaultValue: 'google',
    ),
    idpHintFacebook: String.fromEnvironment(
      'KEYCLOAK_IDP_FACEBOOK',
      defaultValue: 'facebook',
    ),
    idpHintInstitution: String.fromEnvironment('KEYCLOAK_IDP_INSTITUTION'),
    roleStudent: String.fromEnvironment(
      'KEYCLOAK_ROLE_STUDENT',
      defaultValue: 'student',
    ),
    roleTeacher: String.fromEnvironment(
      'KEYCLOAK_ROLE_TEACHER',
      defaultValue: 'teacher',
    ),
    apiDevAuth: bool.fromEnvironment('API_DEV_AUTH'),
  );

  /// Configuración vacía: fuerza modo demo (útil en pruebas).
  static const demo = AppConfig(
    keycloakIssuer: '',
    keycloakClientId: '',
    keycloakRedirectUri: 'com.orbitastudio.orbitakids:/oauthredirect',
    keycloakPostLogoutRedirectUri: 'com.orbitastudio.orbitakids:/logout',
    apiBaseUrl: '',
    idpHintGoogle: 'google',
    idpHintFacebook: 'facebook',
    idpHintInstitution: '',
    roleStudent: 'student',
    roleTeacher: 'teacher',
  );

  final String keycloakIssuer;
  final String keycloakClientId;
  final String keycloakRedirectUri;
  final String keycloakPostLogoutRedirectUri;
  final String apiBaseUrl;
  final String idpHintGoogle;
  final String idpHintFacebook;
  final String idpHintInstitution;
  final String roleStudent;
  final String roleTeacher;

  /// Solo desarrollo: sin Keycloak, las cuentas demo se identifican ante el
  /// backend con `Bearer dev:<id>` (el backend debe correr con AUTH_MODE=dev).
  final bool apiDevAuth;

  bool get hasKeycloak =>
      keycloakIssuer.isNotEmpty && keycloakClientId.isNotEmpty;

  bool get hasBackend => apiBaseUrl.isNotEmpty;

  /// Sin Keycloak la app funciona con cuentas y datos de demostración.
  bool get isDemo => !hasKeycloak;

  /// Cuentas demo, pero los datos van y vienen del backend de desarrollo.
  bool get devServer => isDemo && hasBackend && apiDevAuth;

  /// Hay un backend con el que la sesión se puede identificar: los datos del
  /// docente, las actividades y la cola usan el servidor.
  bool get usesServer => hasBackend && (hasKeycloak || devServer);

  /// Lista legible de lo que falta configurar (se muestra en Acerca de).
  List<String> get missing => [
    if (keycloakIssuer.isEmpty) 'KEYCLOAK_ISSUER',
    if (keycloakClientId.isEmpty) 'KEYCLOAK_CLIENT_ID',
    if (apiBaseUrl.isEmpty) 'API_BASE_URL',
    if (idpHintInstitution.isEmpty) 'KEYCLOAK_IDP_INSTITUTION',
  ];
}
