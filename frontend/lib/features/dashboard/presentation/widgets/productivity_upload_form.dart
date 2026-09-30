import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/network/http_client.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../domain/entities/dashboard_entities.dart';

class ProductivityUploadForm extends StatefulWidget {
  final VoidCallback? onSaved;
  final List<ProductivityRecordEntity> records;
  final bool canEdit;

  const ProductivityUploadForm({
    super.key,
    this.onSaved,
    this.records = const [],
    this.canEdit = false,
  });

  @override
  State<ProductivityUploadForm> createState() => _ProductivityUploadFormState();
}

class _ProductivityUploadFormState extends State<ProductivityUploadForm> {
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _saveMonth(DateTime month, double percentage, PlatformFile file) async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await sl<HttpClient>().dio.post(
        '/productivity/upload',
        data: FormData.fromMap({
          'file': MultipartFile.fromBytes(file.bytes!, filename: file.name),
          'year': month.year,
          'month': month.month,
          'productivity_percentage': percentage,
        }),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Monthly productivity uploaded successfully')),
        );
      }

      widget.onSaved?.call();
    } on DioException catch (error) {
      setState(() {
        _error = (error.response?.data is Map
                ? error.response?.data['message']
                : null)
            ?.toString() ?? 'Could not upload productivity workbook';
      });
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _openMonthDialog() async {
    DateTime selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
    final percentageController = TextEditingController();
    PlatformFile? selectedFile;
    String? dialogError;
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add monthly productivity'),
          content: SizedBox(
            width: 460,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Choose the month, enter the percentage, and archive the workbook.',
                    style: AppTheme.bodySmall),
                const SizedBox(height: 18),
                OutlinedButton.icon(
                  onPressed: () async {
                    final value = await showDatePicker(
                      context: context,
                      initialDate: selectedMonth,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      initialDatePickerMode: DatePickerMode.year,
                    );
                    if (value != null) {
                      setDialogState(() => selectedMonth = DateTime(value.year, value.month));
                    }
                  },
                  icon: const Icon(Icons.calendar_month_outlined),
                  label: Text('${_monthName(selectedMonth.month)} ${selectedMonth.year}'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: percentageController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Productivity percentage',
                    hintText: '84.93',
                    suffixText: '%',
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () async {
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: const ['xlsx'],
                      withData: true,
                    );
                    final file = result?.files.single;
                    if (file?.bytes != null) {
                      setDialogState(() => selectedFile = file);
                    }
                  },
                  icon: const Icon(Icons.attach_file_outlined),
                  label: Text(selectedFile?.name ?? 'Choose Excel archive'),
                ),
                if (dialogError != null) ...[
                  const SizedBox(height: 8),
                  Text(dialogError!, style: const TextStyle(color: AppTheme.accentRed)),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              onPressed: () async {
                final percentage = double.tryParse(
                  percentageController.text.trim().replaceAll(',', '.'),
                );
                if (percentage == null || percentage < 0 || percentage > 100 ||
                    selectedFile?.bytes == null) {
                  setDialogState(() => dialogError =
                      'Enter a percentage from 0 to 100 and choose an Excel file.');
                  return;
                }
                Navigator.pop(dialogContext, true);
                await _saveMonth(selectedMonth, percentage, selectedFile!);
              },
              icon: const Icon(Icons.save_outlined),
              label: const Text('Save'),
            ),
          ],
        ),
      ),
    );
    percentageController.dispose();
    if (saved == true && mounted) {
      setState(() {});
    }
  }

  Future<void> _deleteMonth(ProductivityRecordEntity record) async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Delete monthly productivity?'),
          content: Text('Delete ${_monthName(record.calendarWeekKw)} ${record.year}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: FilledButton.styleFrom(backgroundColor: AppTheme.accentRed),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
      setState(() => _saving = true);
      try {
        await sl<HttpClient>().dio.delete(
          '/productivity/records/${record.year}/${record.calendarWeekKw}',
        );
        widget.onSaved?.call();
      } on DioException catch (error) {
        final data = error.response?.data;
        setState(() => _error = data is Map
            ? data['message']?.toString() ?? 'Could not delete monthly productivity'
            : 'Could not delete monthly productivity');
      } finally {
        if (mounted) setState(() => _saving = false);
      }
  }

  String _monthName(int month) => const [
        '', 'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December',
      ][month.clamp(1, 12)];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: AppTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.canEdit ? 'Upload monthly productivity' : 'Monthly productivity',
            style: AppTheme.heading3,
          ),
          const SizedBox(height: 4),
          Text(
            widget.canEdit
                ? 'Select a month and upload its productivity workbook.'
                : 'Productivity data can only be edited by an administrator or production manager.',
            style: AppTheme.bodySmall,
          ),
          if (widget.canEdit) ...[
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: _saving ? null : _openMonthDialog,
              icon: const Icon(Icons.add_chart_outlined),
              label: const Text('Add month data'),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(_error!, style: const TextStyle(color: AppTheme.accentRed)),
          ],
          if (widget.records.isNotEmpty) ...[
            const SizedBox(height: 18),
            Text('Saved monthly data', style: AppTheme.heading3),
            const SizedBox(height: 8),
            ...widget.records.map(
              (record) => ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text('${_monthName(record.calendarWeekKw)} ${record.year}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${record.productivityPercentage.toStringAsFixed(2)}%'),
                    if (widget.canEdit)
                      IconButton(
                        onPressed: _saving ? null : () => _deleteMonth(record),
                        icon: const Icon(Icons.delete_outline, color: AppTheme.accentRed),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

}
