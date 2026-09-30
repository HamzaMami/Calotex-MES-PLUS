import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/calotex_sidebar.dart';
import '../../../../shared/widgets/calotex_top_bar.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../widgets/dashboard_loading.dart';
import '../widgets/production_order_list.dart';

class ManufacturingPage extends StatefulWidget {
  const ManufacturingPage({super.key});

  @override
  State<ManufacturingPage> createState() => _ManufacturingPageState();
}

class _ManufacturingPageState extends State<ManufacturingPage> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(const FetchDashboardData());
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final user = authState is Authenticated ? authState.user : null;
    final canEditStatus = user?.role == 'admin' ||
        user?.role == 'ctx1_production_manager';

    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CalotexSidebar(
            activeRoute: '/manufacturing',
            userRole: user?.role ?? '',
            onNavItemTap: (route) {
              if (route == '/logout') {
                context.read<AuthBloc>().add(const LogoutRequested());
              } else if (route != '/manufacturing') {
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
                              'Failed to load production orders: ${state.message}',
                              style: const TextStyle(color: AppTheme.accentRed),
                            ),
                          );
                        }
                        if (state is! DashboardLoaded) {
                          return const Center(
                            child: Text(
                              'No production orders available',
                              style: TextStyle(color: AppTheme.textMuted),
                            ),
                          );
                        }

                        return Container(
                          constraints: const BoxConstraints(maxWidth: 1100),
                          padding: const EdgeInsets.all(24),
                          decoration: AppTheme.cardDecoration(),
                          child: ProductionOrderList(
                            orders: state.data.manufacturingOrders,
                            exportPlans: state.data.exportPlans,
                            autoScroll: false,
                            produced: 0,
                            target: 0,
                            canEditStatus: canEditStatus,
                            onStatusChanged: (order) {
                              context.read<DashboardBloc>().add(
                                    UpdateProductionOrderStatus(
                                      orderId: order.id,
                                      status: order.status,
                                    ),
                                  );
                            },
                            onExportPlanStatusChanged: (plan, status) {
                                  context.read<DashboardBloc>().add(
                                        UpdateExportPlanStatus(
                                          planId: plan.id,
                                          status: status,
                                        ),
                                      );
                            },
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
