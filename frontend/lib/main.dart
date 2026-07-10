import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

// Core
import 'core/network/http_client.dart';
import 'core/services/token_storage_service.dart';

// Auth feature
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';

// Dashboard feature
import 'features/dashboard/presentation/pages/dashboard_page.dart';
import 'features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'features/dashboard/domain/repositories/dashboard_repository.dart';
import 'features/dashboard/presentation/bloc/dashboard_bloc.dart';

// Design system
import 'shared/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SiltexApp());
}

class SiltexApp extends StatelessWidget {
  const SiltexApp({super.key});

  @override
  Widget build(BuildContext context) {
    final tokenStorage = TokenStorageService();
    final httpClient = HttpClient()..initialize(tokenStorage: tokenStorage);

    // Auth
    final authRemoteDataSource =
        AuthRemoteDataSourceImpl(httpClient: httpClient);
    final authRepository = AuthRepositoryImpl(
      remoteDataSource: authRemoteDataSource,
      tokenStorage: tokenStorage,
    );

    // Dashboard
    final dashboardRemoteDataSource =
        DashboardRemoteDataSourceImpl(httpClient: httpClient.dio);
    final dashboardRepository =
        DashboardRepositoryImpl(remoteDataSource: dashboardRemoteDataSource);

    // Build the theme: AppTheme base + Poppins text theme
    final theme = AppTheme.theme.copyWith(
      textTheme: GoogleFonts.poppinsTextTheme(AppTheme.theme.textTheme).apply(
        bodyColor: AppTheme.textPrimary,
        displayColor: AppTheme.textPrimary,
      ),
    );

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: authRepository),
        RepositoryProvider<DashboardRepository>.value(
            value: dashboardRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(authRepository: authRepository)
              ..add(const AuthCheckRequested()),
          ),
          BlocProvider<DashboardBloc>(
            create: (context) =>
                DashboardBloc(dashboardRepository: dashboardRepository),
          ),
        ],
        child: MaterialApp(
          title: 'Calotex MES — SILTEX',
          debugShowCheckedModeBanner: false,
          theme: theme,
          home: const LoginPage(),
          routes: {
            '/login': (context) => const LoginPage(),
            '/register': (context) => const RegisterPage(),
            '/home': (context) => const DashboardPage(),
            // Placeholder routes for future features
            '/inventory': (context) => const _ComingSoon(title: 'Inventory'),
            '/products': (context) => const _ComingSoon(title: 'Products'),
            '/drafts': (context) => const _ComingSoon(title: 'Drafts'),
            '/documents': (context) => const _ComingSoon(title: 'Documents'),
            '/manufacturing': (context) =>
                const _ComingSoon(title: 'Manufacturing'),
            '/settings': (context) => const _ComingSoon(title: 'Settings'),
          },
        ),
      ),
    );
  }
}

/// Temporary "coming soon" scaffold for routes not yet implemented.
class _ComingSoon extends StatelessWidget {
  final String title;

  const _ComingSoon({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.construction_rounded,
                color: AppTheme.accentCyan, size: 56),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTheme.heading1,
            ),
            const SizedBox(height: 8),
            Text(
              'Coming soon — under construction',
              style: AppTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
              child: const Text('← Back to Dashboard',
                  style: TextStyle(color: AppTheme.accentCyan)),
            ),
          ],
        ),
      ),
    );
  }
}
