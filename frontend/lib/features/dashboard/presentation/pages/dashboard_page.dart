import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/siltex_card.dart';
import '../../../../shared/widgets/siltex_data_table.dart';
import '../../../../shared/widgets/siltex_donut_chart.dart';
import '../../../../shared/widgets/siltex_filter_button.dart';
import '../../../../shared/widgets/siltex_schedule_calendar.dart';
import '../../../../shared/widgets/siltex_sidebar.dart';
import '../../../../shared/widgets/siltex_stat_badge.dart';
import '../../../../shared/widgets/siltex_toggle_switch.dart';
import '../../../../shared/widgets/siltex_top_bar.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../../domain/entities/dashboard_entities.dart';

/// Main SILTEX MES Dashboard — matches the premium dark industrial template.
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _maturityPage = 1;

  @override
  void initState() {
    super.initState();
    // Fetch dashboard data as soon as the page loads
    context.read<DashboardBloc>().add(const FetchDashboardData());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      },
      builder: (context, authState) {
        final userName =
            authState is Authenticated ? authState.user.firstName : 'User';
        final userRole =
            authState is Authenticated ? _formatRole(authState.user.role) : '';

        return Scaffold(
          backgroundColor: AppTheme.bgPrimary,
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Sidebar ──────────────────────────────────────────
              SiltexSidebar(
                activeRoute: '/home',
                onNavItemTap: (route) {
                  if (route == '/logout') {
                    context.read<AuthBloc>().add(const LogoutRequested());
                    return;
                  }
                  Navigator.pushReplacementNamed(context, route);
                },
              ),

              // ── Main area ────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top bar
                    SiltexTopBar(
                      userName: userName,
                      userRole: userRole,
                    ),

                    // Scrollable content
                    Expanded(
                      child: BlocBuilder<DashboardBloc, DashboardState>(
                        builder: (context, state) {
                          final isLoading = state is DashboardLoading ||
                              state is DashboardInitial;
                          final errorMessage =
                              state is DashboardError ? state.message : null;
                          final data =
                              state is DashboardLoaded ? state.data : null;

                          return SingleChildScrollView(
                            padding: const EdgeInsets.all(AppTheme.spacingLg),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (errorMessage != null) ...[
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(16),
                                    decoration: AppTheme.cardDecoration(
                                      color: AppTheme.accentRed
                                          .withValues(alpha: 0.08),
                                      radius: AppTheme.radiusMd,
                                    ),
                                    child: Text(
                                      'Dashboard data could not be loaded: $errorMessage',
                                      style: const TextStyle(
                                          color: AppTheme.accentRed),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ],

                                // ── Schedule card ─────────────────────
                                _buildScheduleCard(data?.events ?? const []),
                                const SizedBox(height: 20),

                                if (isLoading) ...[
                                  const _DashboardLoadingCard(),
                                  const SizedBox(height: 20),
                                  const _DashboardLoadingRow(),
                                  const SizedBox(height: 20),
                                  const _DashboardLoadingTable(),
                                ] else if (data != null) ...[
                                  // ── Production + Orders row ───────────
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                          child: _buildProductionVolumeCard(
                                              data.manufacturingOrders)),
                                      const SizedBox(width: 20),
                                      Expanded(
                                          child: _buildActiveOrdersCard(
                                              data.manufacturingOrders)),
                                    ],
                                  ),
                                  const SizedBox(height: 20),

                                  // ── Product Maturity table ────────────
                                  _buildProductMaturityCard(data.products),
                                ],
                              ],
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
        );
      },
    );
  }

  // ── Card builders ──────────────────────────────────────────────────────────

  Widget _buildScheduleCard(List<EventEntity> events) {
    return SiltexCard(
      title: 'Schedule',
      action: SiltexFilterButton(onPressed: () {}),
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: SiltexScheduleCalendar(
        onChangeSchedule: () {},
      ),
    );
  }

  Widget _buildProductionVolumeCard(List<ManufacturingOrderEntity> orders) {
    int totalTarget = 0;
    int totalGood = 0;
    int totalReject = 0;
    int totalQA = 0;

    for (var o in orders) {
      totalTarget += o.targetQuantity;
      totalGood += o.goodQuantity;
      totalReject += o.rejectQuantity;
      totalQA += o.qaQuantity;
    }

    final totalProcessed = totalGood + totalReject + totalQA;
    final totalUnitsText = totalTarget > 0 ? '$totalTarget Units' : '0 Units';

    // Percentages
    final goodPct =
        totalProcessed > 0 ? (totalGood / totalProcessed * 100).round() : 0;
    final rejectPct =
        totalProcessed > 0 ? (totalReject / totalProcessed * 100).round() : 0;
    final qaPct =
        totalProcessed > 0 ? (totalQA / totalProcessed * 100).round() : 0;

    return Container(
      decoration: AppTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Production Volume', style: AppTheme.heading3),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      totalUnitsText,
                      style: AppTheme.bodyMedium
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(width: 8),
                    const _TrendBadge(
                        label: '↑ 3.6%', color: AppTheme.accentGreen),
                  ],
                ),
              ],
            ),
          ),
          const Divider(color: AppTheme.divider, height: 1),

          // Donut + legend
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: Row(
              children: [
                SiltexDonutChart(
                  segments: [
                    if (goodPct > 0)
                      DonutSegment(
                          value: goodPct.toDouble(),
                          color: AppTheme.accentGreen),
                    if (rejectPct > 0)
                      DonutSegment(
                          value: rejectPct.toDouble(),
                          color: AppTheme.accentRed),
                    if (qaPct > 0)
                      DonutSegment(
                          value: qaPct.toDouble(),
                          color: AppTheme.accentYellow),
                    if (totalProcessed == 0)
                      const DonutSegment(
                          value: 100,
                          color: AppTheme.bgElevated), // Empty state
                  ],
                  centerText: '$goodPct%',
                  size: 110,
                  strokeWidth: 16,
                ),
                const SizedBox(width: 28),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DonutLegendRow(
                        label: 'Good',
                        value: '$goodPct%',
                        color: AppTheme.accentGreen),
                    const SizedBox(height: 10),
                    _DonutLegendRow(
                        label: 'Reject',
                        value: '$totalReject',
                        color: AppTheme.accentRed),
                    const SizedBox(height: 10),
                    _DonutLegendRow(
                        label: 'For QA',
                        value: '$totalQA',
                        color: AppTheme.accentYellow),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveOrdersCard(List<ManufacturingOrderEntity> orders) {
    int inProduction = orders.where((o) => o.status == 'in_production').length;
    int pending = orders.where((o) => o.status == 'pending').length;
    int qc = orders.where((o) => o.status == 'quality_control').length;

    final activeCount = inProduction + qc;
    final totalCount = orders.length;

    // Percentages for Donut
    final inProdPct =
        totalCount > 0 ? (inProduction / totalCount * 100).round() : 0;
    final pendingPct =
        totalCount > 0 ? (pending / totalCount * 100).round() : 0;
    final qcPct = totalCount > 0 ? (qc / totalCount * 100).round() : 0;

    // The center text is usually an overall progress. Let's use inProdPct.
    final centerText = totalCount > 0 ? '$inProdPct%' : '0%';

    return Container(
      decoration: AppTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Active Orders', style: AppTheme.heading3),
                    const SizedBox(height: 4),
                    Text(
                      '$activeCount / $totalCount',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                if (activeCount > 0)
                  const SiltexStatBadge(
                    label: 'LIVE',
                    variant: SiltexBadgeVariant.live,
                    showDot: true,
                  ),
              ],
            ),
          ),
          const Divider(color: AppTheme.divider, height: 1),

          // Donut + legend
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: Row(
              children: [
                SiltexDonutChart(
                  segments: [
                    if (inProduction > 0)
                      DonutSegment(
                          value: inProdPct.toDouble(),
                          color: AppTheme.accentBlue),
                    if (pending > 0)
                      DonutSegment(
                          value: pendingPct.toDouble(),
                          color: AppTheme.accentOrange),
                    if (qc > 0)
                      DonutSegment(
                          value: qcPct.toDouble(), color: AppTheme.accentRed),
                    if (totalCount == 0)
                      const DonutSegment(
                          value: 100, color: AppTheme.bgElevated),
                  ],
                  centerText: centerText,
                  size: 110,
                  strokeWidth: 16,
                ),
                const SizedBox(width: 28),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _OrderLegendRow(
                        label: 'In Production',
                        count: inProduction,
                        variant: SiltexBadgeVariant.info),
                    const SizedBox(height: 10),
                    _OrderLegendRow(
                        label: 'Pending',
                        count: pending,
                        variant: SiltexBadgeVariant.warning),
                    const SizedBox(height: 10),
                    _OrderLegendRow(
                        label: 'Quality Control',
                        count: qc,
                        variant: SiltexBadgeVariant.error),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductMaturityCard(List<ProductEntity> products) {
    return SiltexCard(
      title: 'Product Maturity',
      action: SiltexFilterButton(onPressed: () {}),
      padding: EdgeInsets.zero,
      child: products.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(24.0),
              child: Center(
                  child: Text('No products available',
                      style: TextStyle(color: AppTheme.textMuted))),
            )
          : SiltexDataTable(
              columns: const [
                SiltexTableColumn(label: 'Product Name', flex: 1.2),
                SiltexTableColumn(label: 'Lead Engineer', flex: 0.9),
                SiltexTableColumn(label: 'Technical Milestone', flex: 1.4),
                SiltexTableColumn(label: 'Validation Status', flex: 1.4),
                SiltexTableColumn(label: 'Final Approval', flex: 1.1),
              ],
              rows: products.map((product) => _maturityRow(product)).toList(),
              currentPage: _maturityPage,
              totalPages: 1, // Add pagination logic later if needed
              onPreviousPage: () => setState(() => _maturityPage--),
              onNextPage: () => setState(() => _maturityPage++),
            ),
    );
  }

  List<Widget> _maturityRow(ProductEntity product) {
    // Map final approval state to color
    final color = product.finalApproval
        ? SiltexToggleColor.green
        : SiltexToggleColor.orange;
    final statusText = product.finalApproval ? 'Approved' : 'Pending';

    return [
      Text(product.name, style: AppTheme.bodyMedium),
      Text(
          product.leadEngineerId != null
              ? 'Eng. ${product.leadEngineerId}'
              : 'Unassigned',
          style: AppTheme.bodyMedium),
      Text(product.technicalMilestone ?? '-', style: AppTheme.bodySmall),
      Text(product.validationStatus ?? '-', style: AppTheme.bodySmall),
      Row(
        children: [
          Text(statusText, style: AppTheme.bodySmall),
          const SizedBox(width: 6),
          SiltexToggleSwitch(
            value: product.finalApproval,
            activeColor: color,
            onChanged: (val) {
              context.read<DashboardBloc>().add(ToggleProductApproval(
                    productId: product.id,
                    finalApproval: val,
                  ));
            },
          ),
        ],
      ),
    ];
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _formatRole(String role) {
    return role
        .split('_')
        .map((w) => w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }
}

class _DashboardLoadingCard extends StatelessWidget {
  const _DashboardLoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      decoration: AppTheme.cardDecoration(),
      child: const Center(
        child: CircularProgressIndicator(color: AppTheme.accentCyan),
      ),
    );
  }
}

class _DashboardLoadingRow extends StatelessWidget {
  const _DashboardLoadingRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            height: 220,
            decoration: AppTheme.cardDecoration(),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Container(
            height: 220,
            decoration: AppTheme.cardDecoration(),
          ),
        ),
      ],
    );
  }
}

class _DashboardLoadingTable extends StatelessWidget {
  const _DashboardLoadingTable();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      decoration: AppTheme.cardDecoration(),
      child: const Center(
        child: Text(
          'Loading dashboard data...',
          style: TextStyle(color: AppTheme.textMuted),
        ),
      ),
    );
  }
}

// ── Small helper widgets ───────────────────────────────────────────────────────

class _TrendBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _TrendBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppTheme.radiusXs),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DonutLegendRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _DonutLegendRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 56,
          child: Text(label, style: AppTheme.bodySmall),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(AppTheme.radiusXs),
          ),
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _OrderLegendRow extends StatelessWidget {
  final String label;
  final int count;
  final SiltexBadgeVariant variant;

  const _OrderLegendRow({
    required this.label,
    required this.count,
    required this.variant,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 104,
          child: Text(label, style: AppTheme.bodySmall),
        ),
        SiltexCountBadge(count: count, variant: variant),
      ],
    );
  }
}
