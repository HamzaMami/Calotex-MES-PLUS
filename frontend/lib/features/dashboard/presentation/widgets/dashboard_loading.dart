import 'package:flutter/material.dart';
import '../../../../shared/theme/app_theme.dart';

class DashboardLoader extends StatelessWidget {
  const DashboardLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppTheme.accentCyan),
    );
  }
}
