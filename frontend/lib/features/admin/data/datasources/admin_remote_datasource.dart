import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/http_client.dart';
import '../models/rbac_models.dart';

/// Remote data source for RBAC (users, roles, permissions).
class AdminRemoteDataSource {
  final HttpClient httpClient;

  AdminRemoteDataSource({required this.httpClient});

  // ── Users ──────────────────────────────────────────────────────
  Future<List<UserModel>> getUsers() async {
    try {
      final response = await httpClient.dio.get(ApiConstants.usersEndpoint);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((e) => UserModel.fromJson(e)).toList();
      }
      throw ServerException(message: response.data['message'] ?? 'Failed to load users');
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final serverMsg = e.response?.data is Map ? e.response?.data['message'] : null;
      final msg = status != null
          ? 'Failed to load users (HTTP $status)${serverMsg != null ? ': $serverMsg' : ''}'
          : 'Network error loading users: ${e.message ?? e.type.name}';
      throw ServerException(message: msg);
    }
  }

  Future<UserModel> createUser(String name, String email, int roleId) async {
    try {
      final response = await httpClient.dio.post(
        ApiConstants.usersEndpoint,
        data: {'name': name, 'email': email, 'role_id': roleId},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return UserModel.fromJson(response.data['data']);
      }
      throw ServerException(message: response.data['message'] ?? 'Failed to create user');
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Network error creating user',
      );
    }
  }

  Future<UserModel> updateUser(
    int id, {
    String? name,
    int? roleId,
    String? status,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (roleId != null) body['role_id'] = roleId;
      if (status != null) body['status'] = status;
      final response =
          await httpClient.dio.patch('${ApiConstants.usersEndpoint}/$id', data: body);
      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data['data']);
      }
      throw ServerException(message: response.data['message'] ?? 'Failed to update user');
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Network error updating user',
      );
    }
  }

  Future<void> deleteUser(int id) async {
    try {
      final response = await httpClient.dio.delete('${ApiConstants.usersEndpoint}/$id');
      if (response.statusCode != 200) {
        throw ServerException(message: response.data['message'] ?? 'Failed to delete user');
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Network error deleting user',
      );
    }
  }

  // ── Roles ──────────────────────────────────────────────────────
  Future<List<RoleModel>> getRoles() async {
    try {
      final response = await httpClient.dio.get(ApiConstants.rolesEndpoint);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((e) => RoleModel.fromJson(e)).toList();
      }
      throw ServerException(message: response.data['message'] ?? 'Failed to load roles');
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Network error loading roles',
      );
    }
  }

  Future<RoleModel> getRole(int id) async {
    try {
      final response = await httpClient.dio.get('${ApiConstants.rolesEndpoint}/$id');
      if (response.statusCode == 200) {
        final data = response.data['data'];
        return RoleModel.fromJson(data['role'] ?? data);
      }
      throw ServerException(message: response.data['message'] ?? 'Failed to load role');
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Network error loading role',
      );
    }
  }

  Future<RoleModel> createRole(String name, String description) async {
    try {
      final response = await httpClient.dio.post(
        ApiConstants.rolesEndpoint,
        data: {'name': name, 'description': description},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return RoleModel.fromJson(response.data['data']);
      }
      throw ServerException(message: response.data['message'] ?? 'Failed to create role');
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Network error creating role',
      );
    }
  }

  Future<void> deleteRole(int id) async {
    try {
      final response = await httpClient.dio.delete('${ApiConstants.rolesEndpoint}/$id');
      if (response.statusCode != 200) {
        throw ServerException(message: response.data['message'] ?? 'Failed to delete role');
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Network error deleting role',
      );
    }
  }

  Future<void> setRolePermissions(int id, List<int> permissionIds) async {
    try {
      final response = await httpClient.dio.put(
        '${ApiConstants.rolesEndpoint}/$id/permissions',
        data: {'permission_ids': permissionIds},
      );
      if (response.statusCode != 200) {
        throw ServerException(message: response.data['message'] ?? 'Failed to update permissions');
      }
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Network error updating permissions',
      );
    }
  }

  // ── Permissions ────────────────────────────────────────────────
  Future<List<PermissionModel>> getPermissions() async {
    try {
      final response = await httpClient.dio.get(ApiConstants.permissionsEndpoint);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((e) => PermissionModel.fromJson(e)).toList();
      }
      throw ServerException(
          message: response.data['message'] ?? 'Failed to load permissions');
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Network error loading permissions',
      );
    }
  }

  Future<PermissionModel> createPermission(String name, String description) async {
    try {
      final response = await httpClient.dio.post(
        ApiConstants.permissionsEndpoint,
        data: {'name': name, 'description': description},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return PermissionModel.fromJson(response.data['data']);
      }
      throw ServerException(
          message: response.data['message'] ?? 'Failed to create permission');
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Network error creating permission',
      );
    }
  }
}
