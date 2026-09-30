/// API configuration constants
class ApiConstants {
  // Base URL - Reads from --dart-define=API_BASE_URL at build time, defaults to localhost for development
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:5000/api',
  );

  // Auth endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String refreshTokenEndpoint = '/auth/refresh';
  static const String logoutEndpoint = '/auth/logout';

  // RBAC endpoints
  static const String usersEndpoint = '/users';
  static const String rolesEndpoint = '/roles';
  static const String permissionsEndpoint = '/permissions';
  static const String exportPlanningEndpoint = '/export-planning';

  // Request timeout duration in seconds
  static const int timeoutDuration = 30;

  // Headers
  static const String contentType = 'application/json';
  static const String acceptHeader = 'application/json';
}
