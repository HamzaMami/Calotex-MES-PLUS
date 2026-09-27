import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/rbac_models.dart';
import '../../data/repositories/admin_repository.dart';

part 'admin_event.dart';
part 'admin_state.dart';

/// AdminBloc handles all RBAC operations.
class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final AdminRepository adminRepository;

  AdminBloc({required this.adminRepository}) : super(const AdminInitial()) {
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
    emit(const AdminLoading());
    
    final usersResult = await adminRepository.getUsers();
    final rolesResult = await adminRepository.getRoles();

    usersResult.fold(
      (failure) => emit(AdminError(failure.userMessage)),
      (users) {
        rolesResult.fold(
          (failure) => emit(AdminError(failure.userMessage)),
          (roles) => emit(UsersLoaded(users, roles)),
        );
      },
    );
  }

  Future<void> _onCreateUser(CreateUser event, Emitter<AdminState> emit) async {
    emit(const AdminLoading());
    final result = await adminRepository.createUser(event.name, event.email, event.roleId);
    
    result.fold(
      (failure) => emit(AdminError(failure.userMessage)),
      (_) => emit(const AdminOperationSuccess('User created. Registration email sent.')),
    );
  }

  Future<void> _onUpdateUserRole(UpdateUserRole event, Emitter<AdminState> emit) async {
    emit(const AdminLoading());
    final result = await adminRepository.updateUser(event.userId, roleId: event.roleId);
    
    result.fold(
      (failure) => emit(AdminError(failure.userMessage)),
      (_) => emit(const AdminOperationSuccess('User role updated')),
    );
  }

  Future<void> _onSetUserStatus(SetUserStatus event, Emitter<AdminState> emit) async {
    emit(const AdminLoading());
    final result = await adminRepository.updateUser(event.userId, status: event.status);
    
    result.fold(
      (failure) => emit(AdminError(failure.userMessage)),
      (_) => emit(const AdminOperationSuccess('User status updated')),
    );
  }

  Future<void> _onDeleteUser(DeleteUser event, Emitter<AdminState> emit) async {
    emit(const AdminLoading());
    final result = await adminRepository.deleteUser(event.userId);
    
    result.fold(
      (failure) => emit(AdminError(failure.userMessage)),
      (_) => emit(const AdminOperationSuccess('User deleted')),
    );
  }

  Future<void> _onLoadRoles(LoadRoles event, Emitter<AdminState> emit) async {
    emit(const AdminLoading());
    final result = await adminRepository.getRoles();
    
    result.fold(
      (failure) => emit(AdminError(failure.userMessage)),
      (roles) => emit(RolesLoaded(roles, const [])),
    );
  }

  Future<void> _onLoadRolesAndPermissions(
      LoadRolesAndPermissions event, Emitter<AdminState> emit) async {
    emit(const AdminLoading());
    
    final rolesResult = await adminRepository.getRoles();
    final permissionsResult = await adminRepository.getPermissions();

    rolesResult.fold(
      (failure) => emit(AdminError(failure.userMessage)),
      (roles) {
        permissionsResult.fold(
          (failure) => emit(AdminError(failure.userMessage)),
          (permissions) => emit(RolesLoaded(roles, permissions)),
        );
      },
    );
  }

  Future<void> _onCreateRole(CreateRole event, Emitter<AdminState> emit) async {
    emit(const AdminLoading());
    final result = await adminRepository.createRole(event.name, event.description);
    
    result.fold(
      (failure) => emit(AdminError(failure.userMessage)),
      (_) => emit(const AdminOperationSuccess('Role created')),
    );
  }

  Future<void> _onRemoveRole(RemoveRole event, Emitter<AdminState> emit) async {
    emit(const AdminLoading());
    final result = await adminRepository.deleteRole(event.roleId);
    
    result.fold(
      (failure) => emit(AdminError(failure.userMessage)),
      (_) => emit(const AdminOperationSuccess('Role deleted')),
    );
  }

  Future<void> _onSetRolePermissions(
      SetRolePermissionsEvent event, Emitter<AdminState> emit) async {
    emit(const AdminLoading());
    final result = await adminRepository.setRolePermissions(event.roleId, event.permissionIds);
    
    result.fold(
      (failure) => emit(AdminError(failure.userMessage)),
      (_) => emit(const AdminOperationSuccess('Role permissions updated')),
    );
  }
}
