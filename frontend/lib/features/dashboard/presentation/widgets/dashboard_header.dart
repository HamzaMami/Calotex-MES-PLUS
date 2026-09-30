import 'package:flutter/material.dart';
import 'package:calotex_app/features/dashboard/domain/entities/dashboard_entities.dart';
import '../../../../shared/theme/app_theme.dart';
import '../utils/dashboard_helpers.dart';

class DashboardHeader extends StatelessWidget {
  final DashboardDataEntity? data;
  const DashboardHeader({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final currentKWInfo = DashboardMetrics.getISOWeekAndYear(DateTime.now());
    final workWeek = 'KW ${currentKWInfo['kw']}';
    final today = _defaultToday();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Text(
            'CALOTEX-1 PERFORMANCE DASHBOARD',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              workWeek,
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            Text(
              today,
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _defaultToday() {
    final now = DateTime.now();
    final dayStr = now.day.toString().padLeft(2, '0');
    return '$dayStr ${monthName(now.month)} ${now.year}';
  }
}
