import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Dependency Injection
import 'core/di/injection_container.dart';

// Auth feature
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';

// Dashboard feature
import 'features/dashboard/presentation/pages/dashboard_page.dart';
import 'features/dashboard/presentation/pages/productivity_page.dart';
import 'features/dashboard/domain/repositories/dashboard_repository.dart';
import 'features/dashboard/presentation/bloc/dashboard_bloc.dart';

// Admin (RBAC) feature
import 'features/admin/data/repositories/admin_repository.dart';
import 'features/admin/presentation/bloc/admin_bloc.dart';
import 'features/admin/presentation/pages/users_page.dart';
import 'features/admin/presentation/pages/roles_page.dart';
import 'features/export_planning/presentation/bloc/export_planning_bloc.dart';
import 'features/export_planning/presentation/pages/export_planning_page.dart';
import 'features/export_planning/domain/repositories/export_planning_repository.dart';
import 'features/auth/presentation/pages/profile_page.dart';
import 'features/products/presentation/pages/products_page.dart';
import 'features/dashboard/presentation/pages/manufacturing_page.dart';
import 'features/dashboard/presentation/pages/qa_control_page.dart';

// Design system
import 'shared/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://oduccyvpothyweyqrcwt.supabase.co',
    publishableKey: 'sb_publishable_I1uYSxrDkTFOouetQBbY2w_2FUx5Aku',
  );
  await initDependencies();
  runApp(const CalotexApp());
}

class CalotexApp extends StatelessWidget {
  const CalotexApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Build the theme: AppTheme base + Poppins text theme
    final theme = AppTheme.theme.copyWith(
      textTheme: GoogleFonts.poppinsTextTheme(AppTheme.theme.textTheme).apply(
        bodyColor: AppTheme.textPrimary,
        displayColor: AppTheme.textPrimary,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: _NoPageTransitionBuilder(),
          TargetPlatform.iOS: _NoPageTransitionBuilder(),
          TargetPlatform.linux: _NoPageTransitionBuilder(),
          TargetPlatform.macOS: _NoPageTransitionBuilder(),
          TargetPlatform.windows: _NoPageTransitionBuilder(),
          TargetPlatform.fuchsia: _NoPageTransitionBuilder(),
        },
      ),
    );

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: sl<AuthRepository>()),
        RepositoryProvider<DashboardRepository>.value(
            value: sl<DashboardRepository>()),
        RepositoryProvider<AdminRepository>.value(value: sl<AdminRepository>()),
        RepositoryProvider<ExportPlanningRepository>.value(
          value: sl<ExportPlanningRepository>(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) =>
                sl<AuthBloc>()..add(const AuthCheckRequested()),
          ),
          BlocProvider<DashboardBloc>(
            create: (context) => sl<DashboardBloc>(),
          ),
          BlocProvider<AdminBloc>(
            create: (context) => sl<AdminBloc>(),
          ),
          BlocProvider<ExportPlanningBloc>(
            create: (context) => sl<ExportPlanningBloc>(),
          ),
        ],
        child: MaterialApp(
          title: 'Calotex MES',
          debugShowCheckedModeBanner: false,
          theme: theme,
          home: const LoginPage(),
          routes: {
            '/login': (context) => const LoginPage(),
            '/register': (context) => const RegisterPage(),
            '/home': (context) => const DashboardPage(),
            '/productivity': (context) => const ProductivityPage(),
            '/profile': (context) => const ProfilePage(),
            // Admin (RBAC) screens
            '/users': (context) => const UsersPage(),
            '/roles': (context) => const RolesPage(),
            '/export-planning': (context) => const ExportPlanningPage(),
            '/export-plan': (context) => const ExportPlanningPage(),
            // Placeholder routes for future features
            '/inventory': (context) => const _ComingSoon(title: 'Inventory'),
            '/products': (context) => const ProductsPage(),
            '/drafts': (context) => const _ComingSoon(title: 'Drafts'),
            '/documents': (context) => const _ComingSoon(title: 'Documents'),
            '/manufacturing': (context) => const ManufacturingPage(),
            '/qa-control': (context) => const QaControlPage(),
            '/settings': (context) => const _ComingSoon(title: 'Settings'),
          },
        ),
      ),
    );
  }

}

class _NoPageTransitionBuilder extends PageTransitionsBuilder {
  const _NoPageTransitionBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
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
