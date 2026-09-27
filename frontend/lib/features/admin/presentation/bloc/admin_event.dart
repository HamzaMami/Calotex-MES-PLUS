part of 'admin_bloc.dart';

/// Base class for all admin events.
sealed class AdminEvent {
  const AdminEvent();
}

class LoadUsers extends AdminEvent {
  const LoadUsers();
}

class CreateUser extends AdminEvent {
  final String name;
  final String email;
  final int roleId;
  const CreateUser(this.name, this.email, this.roleId);
}

class UpdateUserRole extends AdminEvent {
  final int userId;
  final int roleId;
  const UpdateUserRole(this.userId, this.roleId);
}

class SetUserStatus extends AdminEvent {
  final int userId;
  final String status;
  const SetUserStatus(this.userId, this.status);
}

class DeleteUser extends AdminEvent {
  final int userId;
  const DeleteUser(this.userId);
}

class LoadRoles extends AdminEvent {
  const LoadRoles();
}

class CreateRole extends AdminEvent {
  final String name;
  final String description;
  const CreateRole(this.name, this.description);
}

class RemoveRole extends AdminEvent {
  final int roleId;
  const RemoveRole(this.roleId);
}

class LoadRolesAndPermissions extends AdminEvent {
  const LoadRolesAndPermissions();
}

class SetRolePermissionsEvent extends AdminEvent {
  final int roleId;
  final List<int> permissionIds;
  const SetRolePermissionsEvent(this.roleId, this.permissionIds);
}
