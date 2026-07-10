import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../services/token_storage_service.dart';
import 'interceptors/auth_interceptor.dart';

/// HTTP client wrapper for managing Dio instance with authentication.
class HttpClient {
  static final HttpClient _instance = HttpClient._internal();
  late Dio _dio;

  factory HttpClient() {
    return _instance;
  }

  HttpClient._internal();

  /// Initialize the Dio instance with interceptors and configuration.
  /// Call this once during app startup (typically in main.dart or app initialization).
  void initialize({
    required TokenStorageService tokenStorage,
    String? baseUrl,
    int? timeoutSeconds,
  }) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? ApiConstants.baseUrl,
        connectTimeout:
            Duration(seconds: timeoutSeconds ?? ApiConstants.timeoutDuration),
        receiveTimeout:
            Duration(seconds: timeoutSeconds ?? ApiConstants.timeoutDuration),
        sendTimeout:
            Duration(seconds: timeoutSeconds ?? ApiConstants.timeoutDuration),
        contentType: ApiConstants.contentType,
        headers: {
          'Accept': ApiConstants.acceptHeader,
          'Content-Type': ApiConstants.contentType,
        },
      ),
    );

    // Add auth interceptor
    _dio.interceptors.add(
      AuthInterceptor(
        dio: _dio,
        tokenStorage: tokenStorage,
        refreshTokenUrl: ApiConstants.refreshTokenEndpoint,
      ),
    );

    // Optional: Add logging interceptor for debugging.
    // NOTE: Never print full auth tokens in logs.
    // Keep response bodies disabled to avoid leaking JWT/user data.
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: false,
        responseBody: false,
        error: true,
        requestHeader: false,
        responseHeader: true,
      ),
    );
  }

  /// Get the initialized Dio instance.
  Dio get instance {
    return _dio;
  }

  /// Get Dio instance (alias for instance getter)
  Dio get dio => instance;

  /// Update base URL dynamically if needed.
  void setBaseUrl(String newBaseUrl) {
    _dio.options.baseUrl = newBaseUrl;
  }

  /// Add custom interceptor (if needed).
  void addInterceptor(Interceptor interceptor) {
    _dio.interceptors.add(interceptor);
  }

  /// Close Dio instance (cleanup).
  Future<void> close() async {
    _dio.close();
  }
}
