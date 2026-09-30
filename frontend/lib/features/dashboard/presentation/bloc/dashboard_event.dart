sealed class DashboardEvent {
  const DashboardEvent();
}

final class FetchDashboardData extends DashboardEvent {
  const FetchDashboardData();
}

final class ToggleProductApproval extends DashboardEvent {
  final int productId;
  final bool finalApproval;

  const ToggleProductApproval({
    required this.productId,
    required this.finalApproval,
  });
}

final class UpdateProductionOrderStatus extends DashboardEvent {
  final int orderId;
  final String status;

  const UpdateProductionOrderStatus({
    required this.orderId,
    required this.status,
  });
}

final class UpdateExportPlanStatus extends DashboardEvent {
  final int planId;
  final String status;

  const UpdateExportPlanStatus({required this.planId, required this.status});
}
