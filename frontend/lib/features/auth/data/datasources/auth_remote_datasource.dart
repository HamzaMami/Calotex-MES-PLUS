import 'dart:io';

import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/http_client.dart';
import '../models/login_response_model.dart';
import '../models/user_model.dart';

/// Abstract interface for remote authentication data source.
abstract class AuthRemoteDataSource {
  /// Login with email and password.
  /// Throws [ServerException] or [NetworkException] on failure.
  Future<LoginResponseModel> login({
    required String email,
    required String password,
  });

  /// Register a new user.
  /// Throws [ServerException] or [NetworkException] on failure.
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  });

  /// Refresh access token using refresh token.
  /// Throws [ServerException] or [NetworkException] on failure.
  Future<LoginResponseModel> refreshToken({
    required String refreshToken,
  });

  /// Logout (optional - may call backend to invalidate token).
  /// Throws [ServerException] or [NetworkException] on failure.
  Future<void> logout();
}

/// Implementation of AuthRemoteDataSource.
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final HttpClient _httpClient;

  AuthRemoteDataSourceImpl({required HttpClient httpClient})
      : _httpClient = httpClient;

  @override
  Future<LoginResponseModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _httpClient.dio.post(
        ApiConstants.loginEndpoint,
        data: {
          'email': email,
          'password': password,
        },
        options: Options(
          extra: {'skipAuthInterceptor': true}, // Skip auth for login endpoint
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data['data'] as Map<String, dynamic>? ?? response.data as Map<String, dynamic>;
        return LoginResponseModel.fromJson(responseData);
      }

      throw ServerException(
        message: response.data['message'] ?? 'Login failed',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      _handleDioException(e);
    } catch (e) {
      throw ServerException(
        message: 'An unexpected error occurred during login',
        originalError: e,
      );
    }
  }

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _httpClient.dio.post(
        ApiConstants.registerEndpoint,
        data: {
          'name': name,
          'email': email,
          'password': password,
          'roleId': 2,
        },
        options: Options(
          extra: {'skipAuthInterceptor': true}, // Skip auth for register endpoint
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data['data'] as Map<String, dynamic>? ?? response.data as Map<String, dynamic>;
        return UserModel.fromJson(responseData);
      }

      throw ServerException(
        message: response.data['message'] ?? 'Registration failed',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      _handleDioException(e);
    } catch (e) {
      throw ServerException(
        message: 'An unexpected error occurred during registration',
        originalError: e,
      );
    }
  }

  @override
  Future<LoginResponseModel> refreshToken({
    required String refreshToken,
  }) async {
    try {
      final response = await _httpClient.dio.post(
        ApiConstants.refreshTokenEndpoint,
        data: {
          'refresh_token': refreshToken,
        },
        options: Options(
          extra: {'skipAuthInterceptor': true}, // Skip auth for refresh endpoint
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return LoginResponseModel.fromJson(response.data as Map<String, dynamic>);
      }

      throw ServerException(
        message: response.data['message'] ?? 'Token refresh failed',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      _handleDioException(e);
    } catch (e) {
      throw ServerException(
        message: 'An unexpected error occurred during token refresh',
        originalError: e,
      );
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _httpClient.dio.post(
        ApiConstants.logoutEndpoint,
        options: Options(
          headers: {'Authorization': 'Bearer'},
        ),
      );
    } on DioException catch (e) {
      _handleDioException(e);
    } catch (e) {
      throw ServerException(
        message: 'An unexpected error occurred during logout',
        originalError: e,
      );
    }
  }

  /// Helper method to handle DioException and throw appropriate custom exceptions.
  Never _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw NetworkException(
          message: 'Connection timeout. Please check your network.',
          originalError: e,
        );

      case DioExceptionType.unknown:
        if (e.error is SocketException) {
          throw NetworkException(
            message: 'No internet connection',
            originalError: e,
          );
        }
        throw ServerException(
          message: 'Unknown error occurred',
          originalError: e,
        );

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = _extractErrorMessage(e.response?.data);

        if (statusCode == 401 || statusCode == 403) {
          throw AuthException(
            message: message,
            statusCode: statusCode,
            originalError: e,
          );
        }

        throw ServerException(
          message: message,
          statusCode: statusCode,
          originalError: e,
        );

      case DioExceptionType.cancel:
        throw NetworkException(
          message: 'Request was cancelled',
          originalError: e,
        );

      case DioExceptionType.badCertificate:
        throw NetworkException(
          message: 'Bad certificate error',
          originalError: e,
        );

      case DioExceptionType.connectionError:
        throw NetworkException(
          message: 'Connection error. Please check your network.',
          originalError: e,
        );
    }
  }

  /// Extract error message from response data.
  String _extractErrorMessage(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      // Try common error message field names
      if (responseData.containsKey('message')) {
        return responseData['message'] as String? ?? 'An error occurred';
      }
      if (responseData.containsKey('error')) {
        return responseData['error'] as String? ?? 'An error occurred';
      }
      if (responseData.containsKey('errors')) {
        final errors = responseData['errors'];
        if (errors is Map<String, dynamic> && errors.isNotEmpty) {
          return errors.values.first.toString();
        }
      }
    }
    return 'An error occurred';
  }
}

