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

  const DashboardKpiRow({
    super.key,
    required this.exportProgressTitle,
    required this.exportProgressValue,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 720) {
          return Center(
            child: SizedBox(
              width: constraints.maxWidth / 2,
              child: CalotexKpiCard(
                title: exportProgressTitle,
                value: exportProgressValue,
                color: AppTheme.accentGreen,
                icon: Icons.bar_chart_rounded,
                height: _kpiCardHeight,
                padding: _kpiCardPadding,
              ),
            ),
          );
        }
        return Center(
          child: CalotexKpiCard(
            title: exportProgressTitle,
            value: exportProgressValue,
            color: AppTheme.accentGreen,
            icon: Icons.bar_chart_rounded,
            height: _kpiCardHeight,
            padding: _kpiCardPadding,
          ),
        );
      },
    );
  }
}
