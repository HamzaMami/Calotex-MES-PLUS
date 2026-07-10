import '../../domain/entities/dashboard_entities.dart';

sealed class DashboardState {
  const DashboardState();
}

final class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

final class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

final class DashboardLoaded extends DashboardState {
  final DashboardDataEntity data;

  const DashboardLoaded({required this.data});
}

final class DashboardError extends DashboardState {
  final String message;

  const DashboardError({required this.message});
}
