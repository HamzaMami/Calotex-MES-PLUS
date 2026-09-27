import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../datasources/admin_remote_datasource.dart';
import '../models/rbac_models.dart';

/// Repository for RBAC admin operations.
class AdminRepository {
  final AdminRemoteDataSource remoteDataSource;

  AdminRepository({required this.remoteDataSource});

  // Users
  Future<Either<Failure, List<UserModel>>> getUsers() async {
    try {
      final result = await remoteDataSource.getUsers();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, UserModel>> createUser(String name, String email, int roleId) async {
    try {
      final result = await remoteDataSource.createUser(name, email, roleId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, UserModel>> updateUser(int id, {String? name, int? roleId, String? status}) async {
    try {
      final result = await remoteDataSource.updateUser(id, name: name, roleId: roleId, status: status);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, void>> deleteUser(int id) async {
    try {
      await remoteDataSource.deleteUser(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  // Roles
  Future<Either<Failure, List<RoleModel>>> getRoles() async {
    try {
      final result = await remoteDataSource.getRoles();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, RoleModel>> getRole(int id) async {
    try {
      final result = await remoteDataSource.getRole(id);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, RoleModel>> createRole(String name, String description) async {
    try {
      final result = await remoteDataSource.createRole(name, description);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, void>> deleteRole(int id) async {
    try {
      await remoteDataSource.deleteRole(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, void>> setRolePermissions(int id, List<int> permissionIds) async {
    try {
      await remoteDataSource.setRolePermissions(id, permissionIds);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  // Permissions
  Future<Either<Failure, List<PermissionModel>>> getPermissions() async {
    try {
      final result = await remoteDataSource.getPermissions();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, PermissionModel>> createPermission(String name, String description) async {
    try {
      final result = await remoteDataSource.createPermission(name, description);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
