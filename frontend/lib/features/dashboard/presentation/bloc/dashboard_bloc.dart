import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/dashboard_repository.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepository dashboardRepository;

  DashboardBloc({required this.dashboardRepository})
      : super(const DashboardInitial()) {
    on<FetchDashboardData>(_onFetchDashboardData);
    on<ToggleProductApproval>(_onToggleProductApproval);
  }

  Future<void> _onFetchDashboardData(
    FetchDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading());
    try {
      final data = await dashboardRepository.getDashboardData();
      emit(DashboardLoaded(data: data));
    } catch (e) {
      emit(DashboardError(message: e.toString()));
    }
  }

  Future<void> _onToggleProductApproval(
    ToggleProductApproval event,
    Emitter<DashboardState> emit,
  ) async {
    // If we're not currently in Loaded state, we shouldn't handle this
    if (state is! DashboardLoaded) return;

    try {
      // Actually, since we need to mutate `finalApproval`, and we didn't add `copyWith` to entities,
      // it's easier to just call API and then re-fetch the dashboard.
      await dashboardRepository.updateProductApproval(
        event.productId,
        event.finalApproval,
      );

      // Re-fetch all data to ensure we are in sync with the backend
      add(const FetchDashboardData());
    } catch (e) {
      emit(DashboardError(message: e.toString()));
      // We could revert back to Loaded state if needed
    }
  }
}
