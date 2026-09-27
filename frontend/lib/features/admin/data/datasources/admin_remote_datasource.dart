import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/http_client.dart';
import '../models/rbac_models.dart';

/// Remote data source for RBAC (users, roles, permissions).
class AdminRemoteDataSource {
  final HttpClient httpClient;

  AdminRemoteDataSource({required this.httpClient});

  String _extractErrorMessage(DioException e, String fallback) {
    if (e.response?.data is Map<String, dynamic>) {
      final data = e.response!.data as Map<String, dynamic>;
      if (data['details'] is List && (data['details'] as List).isNotEmpty) {
        return (data['details'] as List).join(', ');
      }
      if (data['message'] != null && data['message'].toString().isNotEmpty) {
        return data['message'].toString();
      }
    }
    return fallback;
  }

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
      throw ServerException(message: _extractErrorMessage(e, 'Failed to load users'));
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
      throw ServerException(message: _extractErrorMessage(e, 'Failed to create user'));
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
      throw ServerException(message: _extractErrorMessage(e, 'Failed to update user'));
    }
  }

  Future<void> deleteUser(int id) async {
    try {
      final response = await httpClient.dio.delete('${ApiConstants.usersEndpoint}/$id');
      if (response.statusCode != 200) {
        throw ServerException(message: response.data['message'] ?? 'Failed to delete user');
      }
    } on DioException catch (e) {
      throw ServerException(message: _extractErrorMessage(e, 'Failed to delete user'));
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
      throw ServerException(message: _extractErrorMessage(e, 'Failed to load roles'));
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
      throw ServerException(message: _extractErrorMessage(e, 'Failed to load role'));
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
      throw ServerException(message: _extractErrorMessage(e, 'Failed to create role'));
    }
  }

  Future<void> deleteRole(int id) async {
    try {
      final response = await httpClient.dio.delete('${ApiConstants.rolesEndpoint}/$id');
      if (response.statusCode != 200) {
        throw ServerException(message: response.data['message'] ?? 'Failed to delete role');
      }
    } on DioException catch (e) {
      throw ServerException(message: _extractErrorMessage(e, 'Failed to delete role'));
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
      throw ServerException(message: _extractErrorMessage(e, 'Failed to update permissions'));
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
      throw ServerException(message: _extractErrorMessage(e, 'Failed to load permissions'));
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
      throw ServerException(message: _extractErrorMessage(e, 'Failed to create permission'));
    }
  }
}
