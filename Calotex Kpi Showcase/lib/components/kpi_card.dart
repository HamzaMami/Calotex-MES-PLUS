import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData? icon;

  const KpiCard({
    super.key,
    required this.title,
    required this.value,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isLarge = MediaQuery.of(context).size.width > 1200;
    return Container(
      decoration: AppTheme.cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: AppTheme.heading2.copyWith(fontSize: isLarge ? 22 : 18),
              ),
              const SizedBox(height: 6),
              Text(title, style: AppTheme.bodySmall),
            ],
          ),
          Icon(
            icon ?? Icons.bar_chart_rounded,
            color: color.withValues(alpha: 0.7),
            size: isLarge ? 32 : 26,
          ),
        ],
      ),
    );
  }
}
