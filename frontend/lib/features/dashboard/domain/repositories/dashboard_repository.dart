import '../entities/dashboard_entities.dart';

abstract class DashboardRepository {
  /// Fetch all aggregated dashboard data in one call
  Future<DashboardDataEntity> getDashboardData();
  
  /// Update the approval status of a specific product
  Future<void> updateProductApproval(int productId, bool finalApproval);
}
