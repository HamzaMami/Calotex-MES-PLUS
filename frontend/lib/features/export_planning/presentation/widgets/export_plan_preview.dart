import 'package:flutter/material.dart';
import '../../domain/entities/export_plan.dart';
import '../../../../shared/theme/app_theme.dart';

class ExportPlanPreview extends StatelessWidget {
  final List<ExportPlanInput> plans;
  final VoidCallback? onUpload;

  const ExportPlanPreview({super.key, required this.plans, this.onUpload});

  @override
  Widget build(BuildContext context) {
    if (plans.isEmpty) {
      return const Text('Select an Excel file to preview its rows.',
          style: TextStyle(color: AppTheme.textMuted));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${plans.length} rows ready to upload', style: AppTheme.bodySmall),
        const SizedBox(height: 8),
        if (onUpload != null) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton.icon(
              onPressed: onUpload,
              icon: const Icon(Icons.cloud_upload_outlined),
              label: const Text('Finalize and upload plan'),
            ),
          ),
          const SizedBox(height: 12),
        ],
        SizedBox(
          height: 220,
          child: SingleChildScrollView(
            child: DataTable(
              columns: const [
                DataColumn(label: Text('KW')),
                DataColumn(label: Text('Year')),
                DataColumn(label: Text('Order number')),
                DataColumn(label: Text('Product')),
                DataColumn(label: Text('Quantity')),
                DataColumn(label: Text('Destination')),
              ],
              rows: plans
                  .map((plan) => DataRow(cells: [
                        DataCell(Text('${plan.calendarWeekKw}')),
                        DataCell(Text('${plan.year}')),
                        DataCell(Text(plan.orderNumber ?? '-')),
                        DataCell(Text(plan.productCode)),
                        DataCell(Text('${plan.quantity}')),
                        DataCell(Text(plan.destination)),
                      ]))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}
