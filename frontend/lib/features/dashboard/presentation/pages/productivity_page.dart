import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/calotex_sidebar.dart';
import '../../../../shared/widgets/calotex_top_bar.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../utils/dashboard_helpers.dart';
import '../widgets/dashboard_loading.dart';
import '../widgets/monthly_productivity_panel.dart';
import '../widgets/productivity_upload_form.dart';

class ProductivityPage extends StatefulWidget {
  const ProductivityPage({super.key});

  @override
  State<ProductivityPage> createState() => _ProductivityPageState();
}

class _ProductivityPageState extends State<ProductivityPage> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(const FetchDashboardData());
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final user = authState is Authenticated ? authState.user : null;
    final canEditProductivity = user?.role == 'admin' ||
        user?.role == 'ctx1_production_manager';

    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CalotexSidebar(
            activeRoute: '/productivity',
            userRole: user?.role ?? '',
            onNavItemTap: (route) {
              if (route == '/logout') {
                context.read<AuthBloc>().add(const LogoutRequested());
                Navigator.pushReplacementNamed(context, '/login');
              } else if (route != '/productivity') {
                Navigator.pushReplacementNamed(context, route);
              }
            },
          ),
          Expanded(
            child: Column(
              children: [
                CalotexTopBar(
                  userName: user?.firstName ?? 'User',
                  userRole: user?.role ?? '',
                  avatar: user?.avatar,
                  onProfileTap: () => Navigator.pushNamed(context, '/profile'),
                  isPresenting: false,
                  onTogglePresentation: () {},
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacingLg),
                    child: BlocBuilder<DashboardBloc, DashboardState>(
                      builder: (context, state) {
                        if (state is DashboardLoading ||
                            state is DashboardInitial) {
                          return const DashboardLoader();
                        }
                        if (state is DashboardError) {
                          return Center(
                            child: Text(
                              'Failed to load productivity data: ${state.message}',
                              style: const TextStyle(
                                color: AppTheme.accentRed,
                              ),
                            ),
                          );
                        }
                        if (state is! DashboardLoaded) {
                          return const Center(
                            child: Text(
                              'No productivity data available',
                              style: TextStyle(color: AppTheme.textMuted),
                            ),
                          );
                        }

                        final metrics = DashboardMetrics.from(state.data);
                        return SingleChildScrollView(
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 900),
                              child: Column(
                                children: [
                                  Container(
                                    height: 420,
                                    padding: const EdgeInsets.all(24),
                                    decoration: AppTheme.cardDecoration(),
                                    child: MonthlyProductivityPanel(
                                      monthLabel: metrics.productivityMonthLabel,
                                      productivity: metrics.monthlyProductivity,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ProductivityUploadForm(
                                    records: state.data.productivityRecords,
                                    canEdit: canEditProductivity,
                                    onSaved: () => context
                                        .read<DashboardBloc>()
                                        .add(const FetchDashboardData()),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
