import '../datasources/admin_remote_datasource.dart';
import '../models/rbac_models.dart';

/// Repository for RBAC admin operations.
class AdminRepository {
  final AdminRemoteDataSource remoteDataSource;

  AdminRepository({required this.remoteDataSource});

  // Users
  Future<List<UserModel>> getUsers() => remoteDataSource.getUsers();
  Future<UserModel> createUser(String name, String email, int roleId) =>
      remoteDataSource.createUser(name, email, roleId);
  Future<UserModel> updateUser(int id, {String? name, int? roleId, String? status}) =>
      remoteDataSource.updateUser(id, name: name, roleId: roleId, status: status);
  Future<void> deleteUser(int id) => remoteDataSource.deleteUser(id);

  // Roles
  Future<List<RoleModel>> getRoles() => remoteDataSource.getRoles();
  Future<RoleModel> getRole(int id) => remoteDataSource.getRole(id);
  Future<RoleModel> createRole(String name, String description) =>
      remoteDataSource.createRole(name, description);
  Future<void> deleteRole(int id) => remoteDataSource.deleteRole(id);
  Future<void> setRolePermissions(int id, List<int> permissionIds) =>
      remoteDataSource.setRolePermissions(id, permissionIds);

  // Permissions
  Future<List<PermissionModel>> getPermissions() => remoteDataSource.getPermissions();
  Future<PermissionModel> createPermission(String name, String description) =>
      remoteDataSource.createPermission(name, description);
}
