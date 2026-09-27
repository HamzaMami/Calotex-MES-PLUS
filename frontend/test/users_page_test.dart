import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calotex_app/features/admin/presentation/pages/users_page.dart';
import 'package:calotex_app/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:calotex_app/features/admin/data/models/rbac_models.dart';
import 'package:calotex_app/features/admin/data/repositories/admin_repository.dart';
import 'package:calotex_app/features/admin/data/datasources/admin_remote_datasource.dart';
import 'package:calotex_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:calotex_app/features/auth/domain/entities/user_entity.dart';
import 'package:calotex_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:calotex_app/core/errors/failures.dart';
import 'package:calotex_app/core/network/http_client.dart';
import 'package:dartz/dartz.dart';

void main() {
  testWidgets('UsersPage renders UsersLoaded without throwing', (tester) async {
    final users = [
      UserModel(
        id: 1,
        name: 'Admin',
        email: 'admin@calotex.com',
        status: 'active',
        roleId: 1,
        createdAt: DateTime.now(),
      ),
    ];
    final roles = [
      RoleModel(id: 1, name: 'admin', isSystem: true),
      RoleModel(id: 2, name: 'manager', isSystem: false),
    ];

    final adminBloc = AdminBloc(adminRepository: _FakeAdminRepo())
      ..emit(UsersLoaded(users, roles));

    final authBloc = AuthBloc(authRepository: _FakeAuthRepo())
      ..emit(Authenticated(
        user: UserEntity(
          id: '1',
          email: 'a@b.com',
          firstName: 'Admin',
          lastName: '',
          role: 'admin',
          createdAt: DateTime.now(),
        ),
      ));

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: authBloc),
          BlocProvider<AdminBloc>.value(value: adminBloc),
        ],
        child: const MaterialApp(home: UsersPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Users'), findsWidgets);
    expect(find.text('admin@calotex.com'), findsOneWidget);
  });
}

class _FakeAdminRepo extends AdminRepository {
  _FakeAdminRepo() : super(remoteDataSource: AdminRemoteDataSource(httpClient: HttpClient()));

  @override
  Future<List<UserModel>> getUsers() async => [
        UserModel(
          id: 1,
          name: 'Admin',
          email: 'admin@calotex.com',
          status: 'active',
          roleId: 1,
          createdAt: DateTime.now(),
        ),
      ];

  @override
  Future<List<RoleModel>> getRoles() async => [
        RoleModel(id: 1, name: 'admin', isSystem: true),
        RoleModel(id: 2, name: 'manager', isSystem: false),
      ];
}

class _FakeAuthRepo extends AuthRepository {
  @override
  Future<Either<Failure, UserEntity>> login(
          {required String email, required String password}) async =>
      Left(UnknownFailure(message: 'no'));
  @override
  Future<Either<Failure, UserEntity>> register(
          {required String name,
          required String email,
          required String password}) async =>
      Left(UnknownFailure(message: 'no'));
  @override
  Future<Either<Failure, void>> logout() async => const Right(null);
  @override
  Future<Either<Failure, bool>> isUserLoggedIn() async => const Right(false);
  @override
  Future<Either<Failure, UserEntity>> refreshToken() async =>
      Left(UnknownFailure(message: 'no'));
}
