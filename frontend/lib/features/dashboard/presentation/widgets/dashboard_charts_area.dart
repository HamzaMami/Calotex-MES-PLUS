import 'package:flutter/material.dart';
import 'package:calotex_app/features/dashboard/domain/entities/dashboard_entities.dart';
import '../../../../shared/theme/app_theme.dart';
import '../widgets/calotex_charts.dart';
import 'product_assembly_panel.dart';
import 'production_order_list.dart';

class DashboardChartsArea extends StatelessWidget {
  final DashboardDataEntity data;
  final List<double> statusVals;
  final List<double> volume;
  final int produced;
  final int target;
  final double kv39Productivity;
  final double kv38Productivity;
  final double kv37Productivity;
  final double kv36Productivity;

  const DashboardChartsArea({
    super.key,
    required this.data,
    required this.statusVals,
    required this.volume,
    required this.produced,
    required this.target,
    required this.kv39Productivity,
    required this.kv38Productivity,
    required this.kv37Productivity,
    required this.kv36Productivity,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 900) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 6,
                child: _buildLeftCharts(),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 4,
                child: _buildRightPanel(),
              ),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildLeftCharts()),
            const SizedBox(height: 16),
            Expanded(child: _buildRightPanel()),
          ],
        );
      },
    );
  }

  Widget _buildLeftCharts() {
    return Column(
      children: [
        Expanded(
          flex: 6,
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: AppTheme.cardDecoration(),
                  padding: const EdgeInsets.all(16),
                  child: CalotexGauge(
                    actual: '$produced',
                    target: '$target',
                    progress: target > 0
                        ? (produced / target).clamp(0.0, 1.0)
                        : 0.75,
                    caption: 'Export Progress This Week',
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  decoration: AppTheme.cardDecoration(),
                  padding: const EdgeInsets.all(16),
                  child: CalotexHistogram(
                    title: 'Productivity',
                    values: [
                      kv39Productivity,
                      kv38Productivity,
                      kv37Productivity,
                      kv36Productivity,
                    ],
                    labels: const [
                      'KV 39',
                      'KV 38',
                      'KV 37',
                      'KV 36',
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          flex: 4,
          child: Container(
            decoration: AppTheme.cardDecoration(),
            padding: const EdgeInsets.all(16),
            child: ProductionOrderList(
              orders: data.manufacturingOrders,
              produced: produced,
              target: target,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRightPanel() {
    return Container(
      decoration: AppTheme.cardDecoration(),
      padding: const EdgeInsets.all(24),
      child: ProductAssemblyPanel(products: data.products),
    );
  }
}
