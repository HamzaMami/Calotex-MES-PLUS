import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/utils/fullscreen_utils.dart';
import '../../../../shared/widgets/calotex_sidebar.dart';
import '../../../../shared/widgets/calotex_top_bar.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../utils/dashboard_helpers.dart';
import '../widgets/dashboard_charts_area.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/dashboard_loading.dart';
import '../../domain/entities/dashboard_entities.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _isPresenting = false;
  final FocusNode _presentationFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(const FetchDashboardData());
    _presentationFocus.requestFocus();
  }

  @override
  void dispose() {
    _presentationFocus.dispose();
    super.dispose();
  }

  Future<void> _togglePresentation() async {
    if (_isPresenting) {
      await exitFullscreen();
    } else {
      await enterFullscreen();
    }
    setState(() => _isPresenting = !_isPresenting);
  }

  void _handleKey(KeyEvent event) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.escape) {
      if (_isPresenting) {
        _togglePresentation();
      }
    }
  }

  void _onAuthStateChanged(BuildContext context, AuthState state) {
    if (state is Unauthenticated) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _presentationFocus,
      onKeyEvent: _handleKey,
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) => _onAuthStateChanged(context, state),
        builder: (context, authState) {
          final userName =
          authState is Authenticated ? authState.user.firstName : 'User';
          final userRole =
          authState is Authenticated ? authState.user.role.toDisplayRole() : '';

          return Scaffold(
            backgroundColor: AppTheme.bgPrimary,
            body: Stack(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!_isPresenting)
                      CalotexSidebar(
                        activeRoute: '/home',
                        userRole: authState is Authenticated ? authState.user.role : '',
                        onNavItemTap: (route) {
                          if (route == '/logout') {
                            context.read<AuthBloc>().add(const LogoutRequested());
                            return;
                          }
                          Navigator.pushReplacementNamed(context, route);
                        },
                      ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!_isPresenting)
                            CalotexTopBar(
                              userName: userName,
                              userRole: userRole,
                              avatar: authState is Authenticated ? authState.user.avatar : null,
                              onProfileTap: () => Navigator.pushNamed(context, '/profile'),
                              isPresenting: _isPresenting,
                              onTogglePresentation: _togglePresentation,
                            ),
                          Expanded(
                            child: BlocBuilder<DashboardBloc, DashboardState>(
                              builder: (context, state) {
                                final isLoading = state is DashboardLoading ||
                                    state is DashboardInitial;
                                final errorMessage =
                                state is DashboardError ? state.message : null;
                                final data =
                                state is DashboardLoaded ? state.data : null;

                                return Padding(
                                  padding: EdgeInsets.all(
                                    _isPresenting ? 16.0 : AppTheme.spacingLg,
                                  ),
                                  child: Align(
                                    alignment: Alignment.topCenter,
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxWidth: _isPresenting ? double.infinity : 1800,
                                      ),
                                      child: _DashboardContent(
                                        isLoading: isLoading,
                                        errorMessage: errorMessage,
                                        data: data,
                                        isPresenting: _isPresenting,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (_isPresenting)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: IconButton(
                      onPressed: _togglePresentation,
                      icon: const Icon(Icons.fullscreen_exit, color: Colors.white70),
                      tooltip: 'Exit Fullscreen (Esc)',
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black.withValues(alpha: 0.45),
                        hoverColor: Colors.black.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  final bool isLoading;
  final String? errorMessage;
  final DashboardDataEntity? data;
  final bool isPresenting;

  const _DashboardContent({
    required this.isLoading,
    this.errorMessage,
    this.data,
    required this.isPresenting,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const DashboardLoader();
    }

    if (errorMessage != null) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: AppTheme.cardDecoration(
            color: AppTheme.accentRed.withValues(alpha: 0.08),
            radius: AppTheme.radiusMd,
          ),
          child: Text(
            'Failed to load live dashboard data: $errorMessage',
            style: const TextStyle(color: AppTheme.accentRed),
          ),
        ),
      );
    }

    if (data == null) {
      return const Center(
        child: Text('No dashboard data available', style: TextStyle(color: AppTheme.textMuted)),
      );
    }

    final metrics = DashboardMetrics.from(data!);
    final currentWeek = DashboardMetrics.getISOWeekAndYear(DateTime.now());
    final currentExportPlans = data!.exportPlans
        .where((plan) =>
            plan.year == currentWeek['year'] &&
            plan.calendarWeekKw == currentWeek['kw'])
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DashboardHeader(data: data),
        const SizedBox(height: 20),
        Expanded(
          child: DashboardChartsArea(
            data: data!,
            statusVals: metrics.statusVals,
            volume: metrics.volume,
            produced: metrics.produced,
            target: metrics.target,
            monthlyProductivity: metrics.monthlyProductivity,
            productivityMonthLabel: metrics.productivityMonthLabel,
            exportPlans: currentExportPlans,
          ),
        ),
      ],
    );
  }
}