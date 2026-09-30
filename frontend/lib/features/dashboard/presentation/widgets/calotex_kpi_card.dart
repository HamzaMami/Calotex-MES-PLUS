import 'package:flutter/material.dart';

import '../../../../shared/theme/app_theme.dart';

/// KPI stat card matching the CALOTEX reference design:
/// large metric value on the left, small title beneath, and a tinted
/// icon on the right. Colored by [color].
class CalotexKpiCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData? icon;
  final String? trend;
  final double? height;
  final EdgeInsetsGeometry padding;

  const CalotexKpiCard({
    super.key,
    required this.title,
    required this.value,
    required this.color,
    this.icon,
    this.trend,
    this.height,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    final isLarge = MediaQuery.of(context).size.width > 1200;
    return Container(
      height: height,
      decoration: AppTheme.cardDecoration(),
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: AppTheme.heading2.copyWith(
                    fontSize: isLarge ? 28 : 24,
                  ),
                ),
                const SizedBox(height: 6),
                if (trend != null) ...[
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppTheme.radiusXs),
                    ),
                    child: Text(
                      trend!,
                      style: TextStyle(
                        color: color,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
                Text(
                  title,
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Icon(
            icon ?? Icons.bar_chart_rounded,
            color: color.withValues(alpha: 0.7),
            size: isLarge ? 38 : 32,
          ),
        ],
      ),
    );
  }
}
