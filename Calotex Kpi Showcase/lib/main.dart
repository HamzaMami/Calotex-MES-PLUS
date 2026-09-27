import 'package:flutter/material.dart';
import 'package:kpi_showcase/theme/app_theme.dart';
import 'package:kpi_showcase/product_kpi_example.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CALOTEX-1 Performance Dashboard',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const DashboardScreen(),
    );
  }
}
