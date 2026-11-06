/// Catálogo de rutas de Órbita Kids.
///
/// Las pantallas navegan con estas constantes y constructores en lugar de
/// escribir cadenas: un cambio de ruta se hace en un solo lugar.
abstract final class AppRoutes {
  // ---------------- Bienvenida ----------------
  static const splash = '/';
  static const studios = '/studios';
  static const onboarding = '/onboarding';
  static const loading = '/loading';

  /// Pantalla de carga que avanza sola a [next].
  static String loadingTo(
    String next, {
    String? message,
    String? sub,
    bool authFlow = false,
  }) => _withQuery(loading, {
    'next': next,
    'msg': ?message,
    'sub': ?sub,
    if (authFlow) 'flow': '1',
  });

  // ---------------- Acceso ----------------
  static const login = '/login';
  static const institution = '/login/institution';
  static const demoProviderPattern = '/login/demo/:method';
  static const authStatePattern = '/auth-state/:code';
  static const register = '/register';
  static const registerCode = '/register/code';
  static const recover = '/recover';
  static const lock = '/lock';
  static const unlock = '/unlock';
  static const logout = '/logout';

  /// Selector de identidades demo de un proveedor (`google`, `facebook`,
  /// `institution`).
  static String demoProvider(String method, {String? institutionId}) =>
      _withQuery('/login/demo/$method', {'inst': ?institutionId});

  /// Estado de autenticación (pantalla 09) con el método que lo originó.
  static String authState(String code, {String? method}) =>
      _withQuery('/auth-state/$code', {'m': ?method});

  // ---------------- Modo explorar ----------------
  static const explore = '/explore';
  static const guestHome = '/g';
  static const guestMore = '/g/more';
  static const guestLocked = '/g/locked';

  // ---------------- Estudiante ----------------
  static const studentHome = '/s';
  static const map = '/s/map';
  static const progress = '/s/progress';
  static const pause = '/s/pause';
  static const studentProfile = '/s/profile';
  static const assigned = '/s/assigned';
  static const avatar = '/s/avatar';
  static const play = '/s/play';
  static const results = '/s/results';
  static const studentNotices = '/s/notifications';
  static const galaxies = '/s/galaxies';
  static const meetOrbi = '/s/orbi';
  static const missionPattern = '/s/mission/:id';
  static const pauseDetailPattern = '/s/pause/:id';
  static const pauseDoingPattern = '/s/pause/:id/doing';

  static String mission(String id) => '/s/mission/$id';
  static String pauseDetail(String id) => '/s/pause/$id';
  static String pauseDoing(String id) => '/s/pause/$id/doing';

  // ---------------- Docente ----------------
  static const teacherHome = '/t';
  static const groups = '/t/groups';
  static const activities = '/t/activities';
  static const reports = '/t/reports';
  static const teacherProfile = '/t/profile';
  static const teacherNotices = '/t/notifications';
  static const plans = '/t/plans';
  static const createActivityPath = '/t/create';
  static const groupPattern = '/t/group/:id';
  static const studentDetailPattern = '/t/student/:id';

  static String group(String id) => '/t/group/$id';
  static String studentDetail(String id) => '/t/student/$id';
  static String createActivity({String? draftId, String? groupId}) =>
      _withQuery(createActivityPath, {'draft': ?draftId, 'group': ?groupId});

  // ---------------- Cuenta, ajustes e información ----------------
  static const settings = '/settings';
  static const accessibility = '/settings/a11y';
  static const theme = '/settings/theme';
  static const editProfile = '/profile/edit';
  static const security = '/security';
  static const about = '/about';
  static const aboutStudios = '/about/studios';
  static const privacy = '/privacy';
  static const terms = '/terms';
  static const help = '/help';

  // ---------------- Conexión y sincronización ----------------
  static const connection = '/connection';
  static const downloads = '/downloads';
  static const sync = '/sync';

  /// Ruta con parámetros de consulta; sin parámetros no agrega «?».
  static String _withQuery(String path, Map<String, String> query) =>
      query.isEmpty ? path : Uri(path: path, queryParameters: query).toString();
}
