import 'package:dio/dio.dart';

import '../../services/token_storage_service.dart';

/// Dio interceptor for JWT authentication.
/// Automatically injects Bearer token into requests and handles token refresh on 401.
class AuthInterceptor extends Interceptor {
  final Dio _dio;
  final TokenStorageService _tokenStorage;
  final String _refreshTokenUrl;
  bool _isRefreshing = false;
  late List<RequestInterceptorHandler> _pendingRequests;

  AuthInterceptor({
    required Dio dio,
    required TokenStorageService tokenStorage,
    required String refreshTokenUrl,
  })  : _dio = dio,
        _tokenStorage = tokenStorage,
        _refreshTokenUrl = refreshTokenUrl {
    _pendingRequests = [];
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final accessToken = await _tokenStorage.getAccessToken();

      if (accessToken != null && accessToken.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $accessToken';
      }

      return handler.next(options);
    } catch (e) {
      return handler.reject(
        DioException(
          requestOptions: options,
          error: 'Failed to attach token: $e',
          type: DioExceptionType.unknown,
        ),
      );
    }
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Only handle 401 Unauthorized errors
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    final requestOptions = err.requestOptions;

    // Prevent refresh token endpoint from triggering refresh loop
    if (requestOptions.path.contains(_refreshTokenUrl)) {
      return handler.next(err);
    }

    if (_isRefreshing) {
      // Queue request while token refresh is in progress
      _pendingRequests.add(RequestInterceptorHandler());
      return;
    }

    _isRefreshing = true;

    try {
      // Attempt to refresh the token
      final newAccessToken = await _refreshAccessToken();

      if (newAccessToken != null) {
        // Update the failed request with new token
        requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

        // Retry the original request
        final response = await _dio.request(
          requestOptions.path,
          options: Options(
            method: requestOptions.method,
            headers: requestOptions.headers,
          ),
          data: requestOptions.data,
          queryParameters: requestOptions.queryParameters,
        );

        _isRefreshing = false;
        _processQueue(newAccessToken);

        return handler.resolve(response);
      } else {
        // Token refresh failed, clear tokens and reject
        await _tokenStorage.clearTokens();
        _isRefreshing = false;
        _clearQueue();

        return handler.next(err);
      }
    } on DioException catch (e) {
      _isRefreshing = false;
      _clearQueue();
      return handler.next(e);
    } catch (e) {
      _isRefreshing = false;
      _clearQueue();

      return handler.reject(
        DioException(
          requestOptions: requestOptions,
          error: 'Token refresh failed: $e',
          type: DioExceptionType.unknown,
        ),
      );
    }
  }

  /// Refresh the access token using the refresh token.
  Future<String?> _refreshAccessToken() async {
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        return null;
      }

      final response = await _dio.post(
        _refreshTokenUrl,
        data: {'refresh_token': refreshToken},
        options: Options(
          // Bypass this interceptor to prevent infinite loop
          extra: {'skipAuthInterceptor': true},
        ),
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['access_token'] as String?;
        final newRefreshToken = response.data['refresh_token'] as String?;
        final expiresIn = response.data['expires_in'] as int?;

        if (newAccessToken != null) {
          final expiresAt = DateTime.now().add(
            Duration(seconds: expiresIn ?? 3600),
          );

          await _tokenStorage.saveTokens(
            accessToken: newAccessToken,
            refreshToken: newRefreshToken ?? refreshToken,
            expiresAt: expiresAt,
          );

          return newAccessToken;
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Process queued requests after successful token refresh.
  void _processQueue(String newAccessToken) {
    for (final handler in _pendingRequests) {
      handler.next(RequestOptions(path: ''));
    }
    _pendingRequests.clear();
  }

  /// Clear queued requests on refresh failure.
  void _clearQueue() {
    _pendingRequests.clear();
  }
}

