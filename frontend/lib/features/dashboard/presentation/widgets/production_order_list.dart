import 'package:flutter/material.dart';
import 'package:calotex_app/features/dashboard/domain/entities/dashboard_entities.dart';
import '../../../../shared/theme/app_theme.dart';

enum OrderStatus { notStarted, inProgress, passedFinalControl }

extension OrderStatusExtension on ManufacturingOrderEntity {
  OrderStatus get orderStatus {
    switch (status) {
      case 'pending':
        return OrderStatus.notStarted;
      case 'in_production':
      case 'quality_control':
        return OrderStatus.inProgress;
      case 'completed':
        return OrderStatus.passedFinalControl;
      default:
        return OrderStatus.notStarted;
    }
  }

  Color get statusColor {
    switch (orderStatus) {
      case OrderStatus.notStarted:
        return AppTheme.accentRed;
      case OrderStatus.inProgress:
        return AppTheme.accentOrange;
      case OrderStatus.passedFinalControl:
        return AppTheme.accentGreen;
    }
  }

  String get statusLabel {
    switch (orderStatus) {
      case OrderStatus.notStarted:
        return 'Not Started';
      case OrderStatus.inProgress:
        return 'In Progress';
      case OrderStatus.passedFinalControl:
        return 'Passed Final Control';
    }
  }
}

class ProductionOrderList extends StatelessWidget {
  final List<ManufacturingOrderEntity> orders;
  final int produced;
  final int target;

  const ProductionOrderList({
    super.key,
    required this.orders,
    required this.produced,
    required this.target,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Production Orders', style: AppTheme.heading3),
        const SizedBox(height: 16),
        Expanded(
          child: orders.isEmpty
              ? Center(
                  child: Text(
                    'No orders available',
                    style: AppTheme.bodySmall,
                  ),
                )
              : ListView.separated(
                  itemCount: orders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    final producedQty = order.goodQuantity + order.qaQuantity;
                    final progress = order.targetQuantity > 0
                        ? (producedQty / order.targetQuantity).clamp(0.0, 1.0)
                        : 0.0;
                    return _buildOrderRow(order, producedQty, progress);
                  },
                ),
        ),
        const SizedBox(height: 16),
        _buildLegend(),
      ],
    );
  }

  Widget _buildOrderRow(
    ManufacturingOrderEntity order,
    int producedQty,
    double progress,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: AppTheme.cardDecoration(radius: AppTheme.radiusSm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: order.statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Command ${order.id}',
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Text(
                order.statusLabel,
                style: TextStyle(
                  color: order.statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Qty: $producedQty / ${order.targetQuantity}',
                  style: AppTheme.bodySmall,
                ),
              ),
              Expanded(
                child: Text(
                  'Reject: ${order.rejectQuantity}',
                  style: AppTheme.bodySmall,
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppTheme.bgInput,
              color: order.statusColor,
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _legendItem(AppTheme.accentRed, 'Not Started'),
        _legendItem(AppTheme.accentOrange, 'In Progress'),
        _legendItem(AppTheme.accentGreen, 'Passed Final Control'),
      ],
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: AppTheme.bodySmall),
      ],
    );
  }
}
