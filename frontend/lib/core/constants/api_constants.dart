/// API configuration constants
class ApiConstants {
  // Base URL - Update this based on your backend environment
  // Use http://10.0.2.2:5000/api for Android Emulator, http://localhost:5000/api for iOS/Web
  static const String baseUrl = 'http://localhost:5000/api';

  // Auth endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String refreshTokenEndpoint = '/auth/refresh';
  static const String logoutEndpoint = '/auth/logout';

  // RBAC endpoints
  static const String usersEndpoint = '/users';
  static const String rolesEndpoint = '/roles';
  static const String permissionsEndpoint = '/permissions';

  // Request timeout duration in seconds
  static const int timeoutDuration = 30;

  // Headers
  static const String contentType = 'application/json';
  static const String acceptHeader = 'application/json';
}
