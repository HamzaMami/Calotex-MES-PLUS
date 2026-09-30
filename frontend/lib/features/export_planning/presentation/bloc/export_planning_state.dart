import '../../domain/entities/export_plan.dart';

abstract class ExportPlanningState {
  const ExportPlanningState();
}

class ExportPlanningInitial extends ExportPlanningState {
  const ExportPlanningInitial();
}

class ExportPlanningLoading extends ExportPlanningState {
  final List<ExportPlan> plans;
  const ExportPlanningLoading([this.plans = const []]);
}

class ExportPlanningLoaded extends ExportPlanningState {
  final List<ExportPlan> plans;
  final List<ExportPlanInput> preview;
  const ExportPlanningLoaded(this.plans, {this.preview = const []});
}

class ExportPlanningSuccess extends ExportPlanningState {
  final String message;
  final List<ExportPlan> plans;
  const ExportPlanningSuccess(this.message, this.plans);
}

class ExportPlanningError extends ExportPlanningState {
  final String message;
  final List<ExportPlan> plans;
  const ExportPlanningError(this.message, [this.plans = const []]);
}
