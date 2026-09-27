part of 'admin_bloc.dart';

/// Base class for all admin states.
sealed class AdminState {
  const AdminState();
}

class AdminInitial extends AdminState {
  const AdminInitial();
}

class AdminLoading extends AdminState {
  const AdminLoading();
}

class AdminError extends AdminState {
  final String message;
  const AdminError(this.message);
}

class UsersLoaded extends AdminState {
  final List<UserModel> users;
  final List<RoleModel> roles;
  const UsersLoaded(this.users, this.roles);
}

class RolesLoaded extends AdminState {
  final List<RoleModel> roles;
  final List<PermissionModel> permissions;
  const RolesLoaded(this.roles, this.permissions);
}

class AdminOperationSuccess extends AdminState {
  final String message;
  const AdminOperationSuccess(this.message);
}
