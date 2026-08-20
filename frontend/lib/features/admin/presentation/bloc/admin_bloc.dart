import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/exceptions.dart';
import '../../data/models/rbac_models.dart';
import '../../data/repositories/admin_repository.dart';

// ── Events ────────────────────────────────────────────────────────
abstract class AdminEvent {}

class LoadUsers extends AdminEvent {}
class CreateUser extends AdminEvent {
  final String name;
  final String email;
  final int roleId;
  CreateUser(this.name, this.email, this.roleId);
}
class UpdateUserRole extends AdminEvent {
  final int userId;
  final int roleId;
  UpdateUserRole(this.userId, this.roleId);
}
class SetUserStatus extends AdminEvent {
  final int userId;
  final String status;
  SetUserStatus(this.userId, this.status);
}
class DeleteUser extends AdminEvent {
  final int userId;
  DeleteUser(this.userId);
}

class LoadRoles extends AdminEvent {}
class CreateRole extends AdminEvent {
  final String name;
  final String description;
  CreateRole(this.name, this.description);
}
class RemoveRole extends AdminEvent {
  final int roleId;
  RemoveRole(this.roleId);
}

class LoadRolesAndPermissions extends AdminEvent {}

class SetRolePermissionsEvent extends AdminEvent {
  final int roleId;
  final List<int> permissionIds;
  SetRolePermissionsEvent(this.roleId, this.permissionIds);
}

// ── States ───────────────────────────────────────────────────────
abstract class AdminState {}

class AdminInitial extends AdminState {}
class AdminLoading extends AdminState {}
class AdminError extends AdminState {
  final String message;
  AdminError(this.message);
}

class UsersLoaded extends AdminState {
  final List<UserModel> users;
  final List<RoleModel> roles;
  UsersLoaded(this.users, this.roles);
}

class RolesLoaded extends AdminState {
  final List<RoleModel> roles;
  final List<PermissionModel> permissions;
  RolesLoaded(this.roles, this.permissions);
}

class AdminOperationSuccess extends AdminState {
  final String message;
  AdminOperationSuccess(this.message);
}

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final AdminRepository adminRepository;

  AdminBloc({required this.adminRepository}) : super(AdminInitial()) {
    on<LoadUsers>(_onLoadUsers);
    on<CreateUser>(_onCreateUser);
    on<UpdateUserRole>(_onUpdateUserRole);
    on<SetUserStatus>(_onSetUserStatus);
    on<DeleteUser>(_onDeleteUser);
    on<LoadRoles>(_onLoadRoles);
    on<CreateRole>(_onCreateRole);
    on<RemoveRole>(_onRemoveRole);
    on<LoadRolesAndPermissions>(_onLoadRolesAndPermissions);
    on<SetRolePermissionsEvent>(_onSetRolePermissions);
  }

  Future<void> _onLoadUsers(LoadUsers event, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    try {
      final results = await Future.wait([
        adminRepository.getUsers(),
        adminRepository.getRoles(),
      ]);
      emit(UsersLoaded(results[0] as List<UserModel>, results[1] as List<RoleModel>));
    } on ServerException catch (e) {
      emit(AdminError(e.message));
    } catch (e) {
      emit(AdminError('Unexpected error: $e'));
    }
  }

  Future<void> _onCreateUser(CreateUser event, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    try {
      await adminRepository.createUser(event.name, event.email, event.roleId);
      emit(AdminOperationSuccess('User created. Registration email sent.'));
    } on ServerException catch (e) {
      emit(AdminError(e.message));
    } catch (e) {
      emit(AdminError('Unexpected error: $e'));
    }
  }

  Future<void> _onUpdateUserRole(UpdateUserRole event, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    try {
      await adminRepository.updateUser(event.userId, roleId: event.roleId);
      emit(AdminOperationSuccess('User role updated'));
    } on ServerException catch (e) {
      emit(AdminError(e.message));
    } catch (e) {
      emit(AdminError('Unexpected error: $e'));
    }
  }

  Future<void> _onSetUserStatus(SetUserStatus event, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    try {
      await adminRepository.updateUser(event.userId, status: event.status);
      emit(AdminOperationSuccess('User status updated'));
    } on ServerException catch (e) {
      emit(AdminError(e.message));
    } catch (e) {
      emit(AdminError('Unexpected error: $e'));
    }
  }

  Future<void> _onDeleteUser(DeleteUser event, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    try {
      await adminRepository.deleteUser(event.userId);
      emit(AdminOperationSuccess('User deleted'));
    } on ServerException catch (e) {
      emit(AdminError(e.message));
    } catch (e) {
      emit(AdminError('Unexpected error: $e'));
    }
  }

  Future<void> _onLoadRoles(LoadRoles event, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    try {
      final roles = await adminRepository.getRoles();
      emit(RolesLoaded(roles, []));
    } on ServerException catch (e) {
      emit(AdminError(e.message));
    } catch (e) {
      emit(AdminError('Unexpected error: $e'));
    }
  }

  Future<void> _onLoadRolesAndPermissions(
      LoadRolesAndPermissions event, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    try {
      final results = await Future.wait([
        adminRepository.getRoles(),
        adminRepository.getPermissions(),
      ]);
      emit(RolesLoaded(
        results[0] as List<RoleModel>,
        results[1] as List<PermissionModel>,
      ));
    } on ServerException catch (e) {
      emit(AdminError(e.message));
    } catch (e) {
      emit(AdminError('Unexpected error: $e'));
    }
  }

  Future<void> _onCreateRole(CreateRole event, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    try {
      await adminRepository.createRole(event.name, event.description);
      emit(AdminOperationSuccess('Role created'));
    } on ServerException catch (e) {
      emit(AdminError(e.message));
    } catch (e) {
      emit(AdminError('Unexpected error: $e'));
    }
  }

  Future<void> _onRemoveRole(RemoveRole event, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    try {
      await adminRepository.deleteRole(event.roleId);
      emit(AdminOperationSuccess('Role deleted'));
    } on ServerException catch (e) {
      emit(AdminError(e.message));
    } catch (e) {
      emit(AdminError('Unexpected error: $e'));
    }
  }

  Future<void> _onSetRolePermissions(
      SetRolePermissionsEvent event, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    try {
      await adminRepository.setRolePermissions(event.roleId, event.permissionIds);
      emit(AdminOperationSuccess('Role permissions updated'));
    } on ServerException catch (e) {
      emit(AdminError(e.message));
    } catch (e) {
      emit(AdminError('Unexpected error: $e'));
    }
  }
}
