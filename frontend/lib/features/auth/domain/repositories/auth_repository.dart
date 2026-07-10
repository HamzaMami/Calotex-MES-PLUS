import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

/// Abstract repository contract for authentication operations.
/// Returns [Either] type results to handle both success and failure cases.
abstract class AuthRepository {
  /// Login with email and password.
  /// Returns [Either<Failure, UserEntity>] - Success with user data or Failure.
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  });

  /// Register a new user account.
  /// Returns [Either<Failure, UserEntity>] - Success with created user or Failure.
  Future<Either<Failure, UserEntity>> register({
    required String name,
    required String email,
    required String password,
  });

  /// Logout the current user and clear tokens.
  /// Returns [Either<Failure, void>] - Success or Failure.
  Future<Either<Failure, void>> logout();

  /// Check if user is currently logged in (tokens exist and valid).
  /// Returns [Either<Failure, bool>] - Success with login status or Failure.
  Future<Either<Failure, bool>> isUserLoggedIn();

  /// Refresh the access token using the stored refresh token.
  /// Returns [Either<Failure, UserEntity>] - Success with user data or Failure.
  Future<Either<Failure, UserEntity>> refreshToken();
}

