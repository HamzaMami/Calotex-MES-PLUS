import 'package:flutter/material.dart';

import '../../../../shared/theme/app_theme.dart';

class MonthlyProductivityPanel extends StatelessWidget {
  final String monthLabel;
  final double productivity;

  const MonthlyProductivityPanel({
    super.key,
    required this.monthLabel,
    required this.productivity,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = productivity * 100;
    final progress = productivity.clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            'Monthly Productivity',
            style: AppTheme.heading3.copyWith(
              color: AppTheme.textPrimary,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            monthLabel,
            style: AppTheme.bodyLarge.copyWith(
              color: AppTheme.accentCyan,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const Spacer(),
        Center(
          child: Text(
            '${percentage.toStringAsFixed(1)}%',
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 34,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 14,
            backgroundColor: AppTheme.bgInput,
            color: percentage >= 100
                ? AppTheme.accentGreen
                : AppTheme.accentCyan,
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            'Produced against monthly target',
            textAlign: TextAlign.center,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        const Spacer(),
      ],
    );
  }
}
