import 'dart:async';

import 'package:dio/dio.dart';

import '../../services/token_storage_service.dart';

/// Dio interceptor for JWT authentication.
/// Automatically injects the Bearer token into requests and transparently
/// refreshes the access token on a 401, retrying the original request.
///
/// Concurrent requests that fail with 401 while a refresh is already in
/// progress wait for that single refresh to finish (via [Completer]s) and are
/// then retried with the new token, avoiding a stampede of refresh calls.
class AuthInterceptor extends Interceptor {
  final Dio _dio;
  final TokenStorageService _tokenStorage;
  final String _refreshTokenUrl;

  bool _isRefreshing = false;
  final List<Completer<String?>> _waiters = [];

  AuthInterceptor({
    required Dio dio,
    required TokenStorageService tokenStorage,
    required String refreshTokenUrl,
  })  : _dio = dio,
        _tokenStorage = tokenStorage,
        _refreshTokenUrl = refreshTokenUrl;

  bool _shouldSkip(RequestOptions options) =>
      options.extra['skipAuthInterceptor'] == true;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_shouldSkip(options)) {
      return handler.next(options);
    }

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
    final requestOptions = err.requestOptions;

    // Only handle 401s, and never for requests that opted out.
    if (err.response?.statusCode != 401 || _shouldSkip(requestOptions)) {
      return handler.next(err);
    }

    // The refresh endpoint itself returning 401 means the session is dead.
    if (requestOptions.path.contains(_refreshTokenUrl)) {
      await _tokenStorage.clearTokens();
      return handler.next(err);
    }

    // If a refresh is already running, wait for its result instead of
    // triggering another one.
    if (_isRefreshing) {
      final completer = Completer<String?>();
      _waiters.add(completer);

      final newToken = await completer.future;
      if (newToken == null) {
        return handler.next(err);
      }
      return _retry(requestOptions, newToken, handler, err);
    }

    _isRefreshing = true;
    try {
      final newToken = await _refreshAccessToken();

      _isRefreshing = false;

      if (newToken == null) {
        await _tokenStorage.clearTokens();
        _completeWaiters(null);
        return handler.next(err);
      }

      _completeWaiters(newToken);
      return _retry(requestOptions, newToken, handler, err);
    } catch (e) {
      _isRefreshing = false;
      _completeWaiters(null);
      return handler.next(err);
    }
  }

  /// Retry the original request with a fresh access token.
  Future<void> _retry(
    RequestOptions requestOptions,
    String newAccessToken,
    ErrorInterceptorHandler handler,
    DioException originalError,
  ) async {
    try {
      requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
      // Bypass this interceptor on the retry to avoid recursion loops.
      requestOptions.extra = {
        ...requestOptions.extra,
        'skipAuthInterceptor': true,
      };

      final response = await _dio.fetch(requestOptions);
      return handler.resolve(response);
    } on DioException catch (e) {
      return handler.next(e);
    } catch (e) {
      return handler.next(originalError);
    }
  }

  /// Refresh the access token using the stored refresh token.
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
          // Bypass this interceptor to prevent an infinite loop.
          extra: {'skipAuthInterceptor': true},
        ),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        return null;
      }

      // Backend wraps the payload as { success, data: {...} }.
      final body = response.data as Map<String, dynamic>;
      final data = (body['data'] as Map<String, dynamic>?) ?? body;

      final newAccessToken = data['access_token'] as String?;
      final newRefreshToken = data['refresh_token'] as String?;
      final expiresIn = data['expires_in'] as int?;

      if (newAccessToken == null || newAccessToken.isEmpty) {
        return null;
      }

      final expiresAt = DateTime.now().add(
        Duration(seconds: expiresIn ?? 900),
      );

      await _tokenStorage.saveTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken ?? refreshToken,
        expiresAt: expiresAt,
      );

      return newAccessToken;
    } catch (e) {
      return null;
    }
  }

  /// Release all queued requests with the refresh result.
  void _completeWaiters(String? newToken) {
    for (final completer in _waiters) {
      if (!completer.isCompleted) {
        completer.complete(newToken);
      }
    }
    _waiters.clear();
  }
}
