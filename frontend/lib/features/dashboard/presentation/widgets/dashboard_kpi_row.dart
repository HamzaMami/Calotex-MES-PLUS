import 'package:flutter/material.dart';
import '../../../../shared/theme/app_theme.dart';
import '../widgets/calotex_kpi_card.dart';

const double _kpiCardHeight = 136.0;
const EdgeInsets _kpiCardPadding = EdgeInsets.symmetric(
  horizontal: 20,
  vertical: 18,
);

class DashboardKpiRow extends StatelessWidget {
  final String exportProgressTitle;
  final String exportProgressValue;
  final String semiComplianceValue;
  final String finishedComplianceValue;

  const DashboardKpiRow({
    super.key,
    required this.exportProgressTitle,
    required this.exportProgressValue,
    required this.semiComplianceValue,
    required this.finishedComplianceValue,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 720) {
          return Row(
            children: [
              Expanded(
                child: CalotexKpiCard(
                  title: exportProgressTitle,
                  value: exportProgressValue,
                  color: AppTheme.accentGreen,
                  icon: Icons.bar_chart_rounded,
                  height: _kpiCardHeight,
                  padding: _kpiCardPadding,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CalotexKpiCard(
                  title: 'Compliance Semi-finished',
                  value: semiComplianceValue,
                  color: AppTheme.accentBlue,
                  icon: Icons.bar_chart_rounded,
                  height: _kpiCardHeight,
                  padding: _kpiCardPadding,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CalotexKpiCard(
                  title: 'Compliance Finished',
                  value: finishedComplianceValue,
                  color: AppTheme.accentCyan,
                  icon: Icons.bar_chart_rounded,
                  height: _kpiCardHeight,
                  padding: _kpiCardPadding,
                ),
              ),
            ],
          );
        }
        return Column(
          children: [
            CalotexKpiCard(
              title: exportProgressTitle,
              value: exportProgressValue,
              color: AppTheme.accentGreen,
              icon: Icons.bar_chart_rounded,
              height: _kpiCardHeight,
              padding: _kpiCardPadding,
            ),
            const SizedBox(height: 16),
            CalotexKpiCard(
              title: 'Compliance Semi-finished',
              value: semiComplianceValue,
              color: AppTheme.accentBlue,
              icon: Icons.bar_chart_rounded,
              height: _kpiCardHeight,
              padding: _kpiCardPadding,
            ),
            const SizedBox(height: 16),
            CalotexKpiCard(
              title: 'Compliance Finished',
              value: finishedComplianceValue,
              color: AppTheme.accentCyan,
              icon: Icons.bar_chart_rounded,
              height: _kpiCardHeight,
              padding: _kpiCardPadding,
            ),
          ],
        );
      },
    );
  }
}
