import 'dart:async';
import 'package:flutter/material.dart';
import 'package:calotex_app/features/dashboard/domain/entities/dashboard_entities.dart';
import '../../../../shared/theme/app_theme.dart';

enum OrderStatus { notStarted, inProgress, finished }

extension OrderStatusExtension on ManufacturingOrderEntity {
  OrderStatus get orderStatus {
    switch (status) {
      case 'pending':
        return OrderStatus.notStarted;
      case 'in_production':
      case 'quality_control':
        return OrderStatus.inProgress;
      case 'completed':
        return OrderStatus.finished;
      default:
        return OrderStatus.inProgress;
    }
  }

  Color get statusColor {
    switch (orderStatus) {
      case OrderStatus.notStarted:
        return AppTheme.accentRed;
      case OrderStatus.inProgress:
        return AppTheme.accentOrange;
      case OrderStatus.finished:
        return AppTheme.accentGreen;
    }
  }

  String get statusLabel {
    switch (orderStatus) {
      case OrderStatus.notStarted:
        return 'Not Started';
      case OrderStatus.inProgress:
        return 'In Progress';
      case OrderStatus.finished:
        return 'Finished';
    }
  }
}

class ProductionOrderList extends StatefulWidget {
  final List<ManufacturingOrderEntity> orders;
  final int produced;
  final int target;
  final List<ExportPlanEntity> exportPlans;
  final bool canEditStatus;
  final bool autoScroll;
  final ValueChanged<ManufacturingOrderEntity> onStatusChanged;
  final void Function(ExportPlanEntity plan, String status) onExportPlanStatusChanged;

  const ProductionOrderList({
    super.key,
    required this.orders,
    required this.produced,
    required this.target,
    this.exportPlans = const [],
    this.canEditStatus = false,
    this.autoScroll = true,
    this.onStatusChanged = _ignoreStatusChange,
    this.onExportPlanStatusChanged = _ignoreExportPlanStatusChange,
  });

  static void _ignoreStatusChange(ManufacturingOrderEntity order) {}
  static void _ignoreExportPlanStatusChange(ExportPlanEntity plan, String status) {}

  @override
  State<ProductionOrderList> createState() => _ProductionOrderListState();
}

class _ProductionOrderListState extends State<ProductionOrderList> {
  final ScrollController _scrollController = ScrollController();
  Timer? _scrollTimer;
  bool _scrollingDown = true;

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    if (!widget.autoScroll) return;
    if (_scrollTimer != null || !_scrollController.hasClients) return;
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 80), (_) {
      if (!_scrollController.hasClients ||
          !_scrollController.position.hasContentDimensions) {
        return;
      }
      final max = _scrollController.position.maxScrollExtent;
      if (max <= 0) return;
      final current = _scrollController.offset;
      if (_scrollingDown && current >= max) _scrollingDown = false;
      if (!_scrollingDown && current <= 0) _scrollingDown = true;
      final next = (current + (_scrollingDown ? 1.0 : -1.0)).clamp(0.0, max);
      _scrollController.jumpTo(next);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.autoScroll && _scrollTimer != null) {
      _scrollTimer?.cancel();
      _scrollTimer = null;
    }

    final orders = widget.orders;
    final exportPlans = widget.exportPlans;

    // Compute Summary Counts
    int finishedCount = 0;
    int inProgressCount = 0;
    int notStartedCount = 0;

    if (orders.isNotEmpty) {
      for (final o in orders) {
        switch (o.orderStatus) {
          case OrderStatus.finished:
            finishedCount++;
            break;
          case OrderStatus.inProgress:
            inProgressCount++;
            break;
          case OrderStatus.notStarted:
            notStartedCount++;
            break;
        }
      }
    } else {
      for (final p in exportPlans) {
        if (p.status == 'completed') finishedCount++;
        else if (p.status == 'in_production') inProgressCount++;
        else notStartedCount++;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header & Summary Metric Bar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Flexible(child: Text('Production Orders', style: AppTheme.heading3, overflow: TextOverflow.ellipsis)),
            const SizedBox(width: 8),
            // Summary Metric Pills
            Flexible(
              child: Wrap(
                spacing: 6,
                runSpacing: 4,
                alignment: WrapAlignment.end,
                children: [
                  _MetricPill(label: 'Finished', count: finishedCount, color: AppTheme.accentGreen),
                  _MetricPill(label: 'In Progress', count: inProgressCount, color: AppTheme.accentOrange),
                  _MetricPill(label: 'Not Started', count: notStartedCount, color: AppTheme.accentRed),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // List Container
        Expanded(
          child: orders.isEmpty && exportPlans.isEmpty
              ? Center(
                  child: Text(
                    'No orders available',
                    style: AppTheme.bodyLarge.copyWith(
                      color: AppTheme.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              : Builder(
                  builder: (context) {
                    if (widget.autoScroll) {
                      WidgetsBinding.instance.addPostFrameCallback(
                        (_) => _startAutoScroll(),
                      );
                    }
                    return ListView.separated(
                      controller: _scrollController,
                      itemCount: orders.isNotEmpty
                          ? orders.length
                          : exportPlans.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        if (orders.isEmpty) {
                          return _buildExportPlanRow(exportPlans[index]);
                        }
                        final order = orders[index];
                        final producedQty = order.goodQuantity + order.qaQuantity;
                        final progress = order.targetQuantity > 0
                            ? (producedQty / order.targetQuantity).clamp(0.0, 1.0)
                            : 0.0;
                        return _EnterpriseOrderCard(
                          order: order,
                          producedQty: producedQty,
                          progress: progress,
                          canEditStatus: widget.canEditStatus,
                          onStatusChanged: widget.onStatusChanged,
                        );
                      },
                    );
                  },
                ),
        ),
        const SizedBox(height: 12),
        // Bottom Legend with clean spacing
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.bgInput,
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            border: Border.all(color: AppTheme.divider),
          ),
          child: _buildLegend(),
        ),
      ],
    );
  }

  Widget _buildExportPlanRow(ExportPlanEntity plan) {
    final status = switch (plan.status) {
      'completed' => 'completed',
      'in_production' => 'in_production',
      _ => 'pending',
    };
    final statusColor = status == 'completed'
        ? AppTheme.accentGreen
        : status == 'pending'
            ? AppTheme.accentRed
            : AppTheme.accentOrange;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: AppTheme.cardDecoration(radius: AppTheme.radiusMd),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.productCode,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text('Order #${plan.orderNumber ?? '-'}', style: AppTheme.bodySmall.copyWith(fontSize: 11), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Planned: ${plan.quantity}',
            style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 12),
          ),
          const SizedBox(width: 10),
          if (widget.canEditStatus)
            _SleekStatusDropdown(
              currentStatus: status,
              onChanged: (val) => widget.onExportPlanStatusChanged(plan, val),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppTheme.radiusXs),
                border: Border.all(color: statusColor.withValues(alpha: 0.3)),
              ),
              child: Text(
                status == 'completed' ? 'Finished' : status == 'pending' ? 'Not Started' : 'In Progress',
                style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w800),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _legendItem(AppTheme.accentRed, 'Not Started'),
        _legendItem(AppTheme.accentOrange, 'In Progress'),
        _legendItem(AppTheme.accentGreen, 'Finished'),
      ],
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTheme.bodySmall.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _MetricPill extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _MetricPill({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppTheme.radiusXs),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ', style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
          Text('$count', style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _EnterpriseOrderCard extends StatefulWidget {
  final ManufacturingOrderEntity order;
  final int producedQty;
  final double progress;
  final bool canEditStatus;
  final ValueChanged<ManufacturingOrderEntity> onStatusChanged;

  const _EnterpriseOrderCard({
    required this.order,
    required this.producedQty,
    required this.progress,
    required this.canEditStatus,
    required this.onStatusChanged,
  });

  @override
  State<_EnterpriseOrderCard> createState() => _EnterpriseOrderCardState();
}

class _EnterpriseOrderCardState extends State<_EnterpriseOrderCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: _hovered ? AppTheme.accentCyan.withValues(alpha: 0.4) : AppTheme.divider,
            width: _hovered ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: widget.order.statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Command #${widget.order.id}',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                if (widget.canEditStatus)
                  _SleekStatusDropdown(
                    currentStatus: widget.order.status == 'completed'
                        ? 'completed'
                        : widget.order.status == 'pending'
                            ? 'pending'
                            : 'in_production',
                    onChanged: (status) {
                      if (status != widget.order.status) {
                        widget.onStatusChanged(widget.order.copyWith(status: status));
                      }
                    },
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: widget.order.statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppTheme.radiusXs),
                      border: Border.all(color: widget.order.statusColor.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      widget.order.statusLabel,
                      style: TextStyle(
                        color: widget.order.statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Produced: ${widget.producedQty} / ${widget.order.targetQuantity}',
                    style: AppTheme.bodySmall.copyWith(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 11.5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: widget.progress,
                backgroundColor: AppTheme.bgInput,
                color: widget.order.statusColor,
                minHeight: 4.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SleekStatusDropdown extends StatelessWidget {
  final String currentStatus;
  final ValueChanged<String> onChanged;

  const _SleekStatusDropdown({required this.currentStatus, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final label = currentStatus == 'completed'
        ? 'Finished'
        : currentStatus == 'pending'
            ? 'Not Started'
            : 'In Progress';
    final color = currentStatus == 'completed'
        ? AppTheme.accentGreen
        : currentStatus == 'pending'
            ? AppTheme.accentRed
            : AppTheme.accentOrange;

    return PopupMenuButton<String>(
      initialValue: currentStatus,
      color: AppTheme.bgElevated,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSm)),
      onSelected: onChanged,
      itemBuilder: (context) => const [
        PopupMenuItem(value: 'pending', child: Text('Not Started', style: TextStyle(color: AppTheme.textPrimary, fontSize: 11.5))),
        PopupMenuItem(value: 'in_production', child: Text('In Progress', style: TextStyle(color: AppTheme.textPrimary, fontSize: 11.5))),
        PopupMenuItem(value: 'completed', child: Text('Finished', style: TextStyle(color: AppTheme.textPrimary, fontSize: 11.5))),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppTheme.radiusXs),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800)),
            const SizedBox(width: 3),
            Icon(Icons.keyboard_arrow_down_rounded, color: color, size: 12),
          ],
        ),
      ),
    );
  }
}
