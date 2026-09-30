import 'package:get_it/get_it.dart';

// Core
import '../network/http_client.dart';
import '../services/token_storage_service.dart';

// Auth feature
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

// Dashboard feature
import '../../features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import '../../features/dashboard/data/repositories/dashboard_repository_impl.dart';
import '../../features/dashboard/domain/repositories/dashboard_repository.dart';
import '../../features/dashboard/presentation/bloc/dashboard_bloc.dart';

// Admin (RBAC) feature
import '../../features/admin/data/datasources/admin_remote_datasource.dart';
import '../../features/admin/data/repositories/admin_repository.dart';
import '../../features/admin/presentation/bloc/admin_bloc.dart';

// Export planning feature
import '../../features/export_planning/data/datasources/export_planning_remote_datasource.dart';
import '../../features/export_planning/data/repositories/export_planning_repository_impl.dart';
import '../../features/export_planning/domain/repositories/export_planning_repository.dart';
import '../../features/export_planning/presentation/bloc/export_planning_bloc.dart';

final sl = GetIt.instance;

/// Initialize all dependencies (Services, Data Sources, Repositories, BLoCs).
Future<void> initDependencies() async {
  // ── 1. Core Services ───────────────────────────────────────────────────
  sl.registerLazySingleton<TokenStorageService>(() => TokenStorageService());

  final tokenStorage = sl<TokenStorageService>();
  final httpClient = HttpClient()..initialize(tokenStorage: tokenStorage);
  sl.registerLazySingleton<HttpClient>(() => httpClient);

  // ── 2. Data Sources ───────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(httpClient: sl<HttpClient>()),
  );

  sl.registerLazySingleton<DashboardRemoteDataSource>(
    () => DashboardRemoteDataSourceImpl(httpClient: sl<HttpClient>().dio),
  );

  sl.registerLazySingleton<AdminRemoteDataSource>(
    () => AdminRemoteDataSource(httpClient: sl<HttpClient>()),
  );

  sl.registerLazySingleton<ExportPlanningRemoteDataSource>(
    () => ExportPlanningRemoteDataSourceImpl(httpClient: sl<HttpClient>()),
  );

  // ── 3. Repositories ───────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl<AuthRemoteDataSource>(),
      tokenStorage: sl<TokenStorageService>(),
    ),
  );

  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(
      remoteDataSource: sl<DashboardRemoteDataSource>(),
    ),
  );

  sl.registerLazySingleton<AdminRepository>(
    () => AdminRepository(
      remoteDataSource: sl<AdminRemoteDataSource>(),
    ),
  );

  sl.registerLazySingleton<ExportPlanningRepository>(
    () => ExportPlanningRepositoryImpl(
      remoteDataSource: sl<ExportPlanningRemoteDataSource>(),
    ),
  );

  // ── 4. BLoCs ──────────────────────────────────────────────────────────
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(authRepository: sl<AuthRepository>()),
  );

  sl.registerFactory<DashboardBloc>(
    () => DashboardBloc(dashboardRepository: sl<DashboardRepository>()),
  );

  sl.registerFactory<AdminBloc>(
    () => AdminBloc(adminRepository: sl<AdminRepository>()),
  );

  sl.registerFactory<ExportPlanningBloc>(
    () => ExportPlanningBloc(repository: sl<ExportPlanningRepository>()),
  );
}
