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
