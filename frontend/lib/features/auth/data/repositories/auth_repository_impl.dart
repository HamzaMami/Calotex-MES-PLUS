import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/services/token_storage_service.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

/// Concrete implementation of AuthRepository.
/// Handles data layer operations and maps exceptions to failures.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final TokenStorageService _tokenStorage;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required TokenStorageService tokenStorage,
  })  : _remoteDataSource = remoteDataSource,
        _tokenStorage = tokenStorage;

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _remoteDataSource.login(
        email: email,
        password: password,
      );

      // Save tokens to secure storage
      await _tokenStorage.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        expiresAt: response.expiresAt,
      );

      // Convert model to entity and return
      return Right(_modelToEntity(response.user));
    } on ServerException catch (e) {
      return Left(
        ServerFailure(
          message: e.message,
          statusCode: e.statusCode,
        ),
      );
    } on AuthException catch (e) {
      return Left(
        AuthFailure(
          message: e.message,
          statusCode: e.statusCode,
        ),
      );
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(
        UnknownFailure(message: 'An unexpected error occurred: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final userModel = await _remoteDataSource.register(
        name: name,
        email: email,
        password: password,
      );

      // Convert model to entity and return
      return Right(_modelToEntity(userModel));
    } on ServerException catch (e) {
      return Left(
        ServerFailure(
          message: e.message,
          statusCode: e.statusCode,
        ),
      );
    } on ValidationException catch (e) {
      return Left(
        ValidationFailure(
          message: e.message,
          fieldErrors: e.fieldErrors,
        ),
      );
    } on AuthException catch (e) {
      return Left(
        AuthFailure(
          message: e.message,
          statusCode: e.statusCode,
        ),
      );
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(
        UnknownFailure(message: 'An unexpected error occurred: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      // Call remote logout (optional backend notification)
      await _remoteDataSource.logout();

      // Clear all stored tokens
      await _tokenStorage.clearTokens();

      return const Right(null);
    } on ServerException catch (e) {
      return Left(
        ServerFailure(
          message: e.message,
          statusCode: e.statusCode,
        ),
      );
    } on AuthException catch (e) {
      return Left(
        AuthFailure(
          message: e.message,
          statusCode: e.statusCode,
        ),
      );
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(
        UnknownFailure(message: 'Logout failed: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> isUserLoggedIn() async {
    try {
      // Check if tokens exist and are not expired
      final hasTokens = await _tokenStorage.hasTokens();
      if (!hasTokens) {
        return const Right(false);
      }

      final isExpired = await _tokenStorage.isTokenExpired();
      return Right(!isExpired);
    } catch (e) {
      return Left(
        CacheFailure(message: 'Failed to check login status: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, UserEntity>> refreshToken() async {
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        return Left(
          TokenFailure(message: 'No refresh token available'),
        );
      }

      final response = await _remoteDataSource.refreshToken(
        refreshToken: refreshToken,
      );

      // Update stored tokens
      await _tokenStorage.saveTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        expiresAt: response.expiresAt,
      );

      return Right(_modelToEntity(response.user));
    } on TokenException catch (e) {
      return Left(
        TokenFailure(message: e.message),
      );
    } on ServerException catch (e) {
      return Left(
        ServerFailure(
          message: e.message,
          statusCode: e.statusCode,
        ),
      );
    } on AuthException catch (e) {
      // Token refresh failed - likely 401
      await _tokenStorage.clearTokens();
      return Left(
        AuthFailure(
          message: e.message,
          statusCode: e.statusCode,
        ),
      );
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(
        UnknownFailure(message: 'Token refresh failed: $e'),
      );
    }
  }

  /// Convert UserModel (data layer) to UserEntity (domain layer).
  UserEntity _modelToEntity(UserModel model) {
    return UserEntity(
      id: model.id,
      email: model.email,
      firstName: model.firstName,
      lastName: model.lastName,
      avatar: model.avatar,
      role: model.role,
      createdAt: model.createdAt,
    );
  }
}
