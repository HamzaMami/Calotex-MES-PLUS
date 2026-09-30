import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/export_plan.dart';
import '../bloc/export_planning_bloc.dart';
import '../bloc/export_planning_event.dart';
import '../bloc/export_planning_state.dart';
import 'export_plan_preview.dart';
import '../../../../shared/theme/app_theme.dart';

class ExportPlanUploadForm extends StatefulWidget {
  const ExportPlanUploadForm({super.key});

  @override
  State<ExportPlanUploadForm> createState() => _ExportPlanUploadFormState();
}

class _ExportPlanUploadFormState extends State<ExportPlanUploadForm> {
  Uint8List? _bytes;
  String? _fileName;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['xlsx'],
      withData: true,
    );
    final file = result?.files.single;
    if (file?.bytes == null) return;
    setState(() {
      _bytes = file!.bytes;
      _fileName = file.name;
    });
    if (mounted) {
      context.read<ExportPlanningBloc>().add(PreviewExportPlans(_bytes!, _fileName!));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ExportPlanningBloc>().state;
    final preview = state is ExportPlanningLoaded
        ? state.preview
        : const <ExportPlanInput>[];
    return Card(
      color: AppTheme.bgCard,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Upload export plan', style: AppTheme.heading3),
            const SizedBox(height: 4),
            Text('Excel format: KW, year, product_code, quantity, destination',
                style: AppTheme.bodySmall),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _pickFile,
              icon: const Icon(Icons.attach_file),
              label: Text(_fileName ?? 'Choose .xlsx file'),
            ),
            const SizedBox(height: 12),
            ExportPlanPreview(
              plans: preview,
              onUpload: _bytes == null || preview.isEmpty
                  ? null
                  : () => context.read<ExportPlanningBloc>().add(
                      UploadExportPlans(_bytes!, _fileName!)),
            ),
          ],
        ),
      ),
    );
  }
}
