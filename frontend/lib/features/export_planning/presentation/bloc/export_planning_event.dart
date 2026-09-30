import 'dart:typed_data';
import '../../domain/entities/export_plan.dart';

abstract class ExportPlanningEvent {
  const ExportPlanningEvent();
}

class LoadExportPlans extends ExportPlanningEvent {
  final int? year;
  const LoadExportPlans({this.year});
}

class CreateExportPlan extends ExportPlanningEvent {
  final ExportPlanInput input;
  const CreateExportPlan(this.input);
}

class UpdateExportPlan extends ExportPlanningEvent {
  final int id;
  final ExportPlanInput input;
  const UpdateExportPlan(this.id, this.input);
}

class DeleteExportPlan extends ExportPlanningEvent {
  final int id;
  const DeleteExportPlan(this.id);
}

class ClearExportPlans extends ExportPlanningEvent {
  final int year;
  final int week;
  const ClearExportPlans({required this.year, required this.week});
}

class PreviewExportPlans extends ExportPlanningEvent {
  final Uint8List bytes;
  final String fileName;
  const PreviewExportPlans(this.bytes, this.fileName);
}

class UploadExportPlans extends ExportPlanningEvent {
  final Uint8List bytes;
  final String fileName;
  const UploadExportPlans(this.bytes, this.fileName);
}
