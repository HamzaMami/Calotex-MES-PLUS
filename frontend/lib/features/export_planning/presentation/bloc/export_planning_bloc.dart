import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/export_plan.dart';
import '../../domain/repositories/export_planning_repository.dart';
import 'export_planning_event.dart';
import 'export_planning_state.dart';

class ExportPlanningBloc extends Bloc<ExportPlanningEvent, ExportPlanningState> {
  final ExportPlanningRepository repository;

  ExportPlanningBloc({required this.repository}) : super(const ExportPlanningInitial()) {
    on<LoadExportPlans>(_load);
    on<CreateExportPlan>(_create);
    on<UpdateExportPlan>(_update);
    on<DeleteExportPlan>(_delete);
    on<ClearExportPlans>(_clear);
    on<PreviewExportPlans>(_preview);
    on<UploadExportPlans>(_upload);
  }

  Future<void> _load(LoadExportPlans event, Emitter<ExportPlanningState> emit) async {
    final current = state is ExportPlanningLoaded
        ? (state as ExportPlanningLoaded).plans
        : const <ExportPlan>[];
    emit(ExportPlanningLoading(current));
    final result = await repository.list(year: event.year);
    result.fold(
      (failure) => emit(ExportPlanningError(failure.userMessage, current)),
      (plans) => emit(ExportPlanningLoaded(plans)),
    );
  }

  Future<void> _create(CreateExportPlan event, Emitter<ExportPlanningState> emit) async {
    final result = await repository.create(event.input);
    result.fold(
      (failure) => emit(ExportPlanningError(failure.userMessage)),
      (_) => add(const LoadExportPlans()),
    );
  }

  Future<void> _update(UpdateExportPlan event, Emitter<ExportPlanningState> emit) async {
    final result = await repository.update(event.id, event.input);
    result.fold(
      (failure) => emit(ExportPlanningError(failure.userMessage)),
      (_) => add(const LoadExportPlans()),
    );
  }

  Future<void> _delete(DeleteExportPlan event, Emitter<ExportPlanningState> emit) async {
    final result = await repository.delete(event.id);
    result.fold(
      (failure) => emit(ExportPlanningError(failure.userMessage)),
      (_) => add(const LoadExportPlans()),
    );
  }

  Future<void> _clear(ClearExportPlans event, Emitter<ExportPlanningState> emit) async {
    final result = await repository.clearAll(year: event.year, week: event.week);
    result.fold(
      (failure) => emit(ExportPlanningError(failure.userMessage)),
      (_) => add(const LoadExportPlans()),
    );
  }

  Future<void> _preview(PreviewExportPlans event, Emitter<ExportPlanningState> emit) async {
    final current = state is ExportPlanningLoaded
        ? (state as ExportPlanningLoaded).plans
        : const <ExportPlan>[];
    emit(const ExportPlanningLoading());
    final result = await repository.preview(event.bytes, event.fileName);
    result.fold(
      (failure) => emit(ExportPlanningError(failure.userMessage)),
      (preview) => emit(ExportPlanningLoaded(current, preview: preview)),
    );
  }

  Future<void> _upload(UploadExportPlans event, Emitter<ExportPlanningState> emit) async {
    emit(const ExportPlanningLoading());
    final result = await repository.upload(event.bytes, event.fileName);
    result.fold(
      (failure) => emit(ExportPlanningError(failure.userMessage)),
      (plans) => emit(ExportPlanningSuccess('Export plan uploaded successfully', plans)),
    );
  }
}
