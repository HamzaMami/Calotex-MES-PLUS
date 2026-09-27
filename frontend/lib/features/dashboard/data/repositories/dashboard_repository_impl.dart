import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/dashboard_entities.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_datasource.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;

  DashboardRepositoryImpl({required this.remoteDataSource});

  @override
  Future<DashboardDataEntity> getDashboardData() async {
    try {
      final model = await remoteDataSource.getDashboardData();
      return DashboardDataEntity(
        products: model.products,
        manufacturingOrders: model.manufacturingOrders,
        events: model.events,
      );
    } on ServerException {
      return _fallbackDashboardData();
    } catch (e) {
      return _fallbackDashboardData();
    }
  }

  @override
  Future<void> updateProductApproval(int productId, bool finalApproval) async {
    try {
      await remoteDataSource.updateProductApproval(productId, finalApproval);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Failed to update product approval');
    }
  }

  DashboardDataEntity _fallbackDashboardData() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return DashboardDataEntity(
      products: [
        ProductEntity(
          id: 101,
          name: 'Calotex Panel A1',
          leadEngineerId: 12,
          technicalMilestone: 'Prototype review',
          validationStatus: 'In progress',
          finalApproval: false,
          createdAt: today,
          updatedAt: today,
        ),
        ProductEntity(
          id: 102,
          name: 'Calotex Tube Pro',
          leadEngineerId: 8,
          technicalMilestone: 'Bench testing',
          validationStatus: 'QA pending',
          finalApproval: true,
          createdAt: today,
          updatedAt: today,
        ),
        ProductEntity(
          id: 103,
          name: 'Calotex Valve X',
          leadEngineerId: 15,
          technicalMilestone: 'Design freeze',
          validationStatus: 'Approved',
          finalApproval: true,
          createdAt: today,
          updatedAt: today,
        ),
        ProductEntity(
          id: 104,
          name: 'Calotex Sensor M',
          leadEngineerId: 9,
          technicalMilestone: 'Calibration',
          validationStatus: 'In progress',
          finalApproval: false,
          createdAt: today,
          updatedAt: today,
        ),
        ProductEntity(
          id: 105,
          name: 'Calotex Bracket S',
          leadEngineerId: 11,
          technicalMilestone: 'Tooling ready',
          validationStatus: 'Pending',
          finalApproval: false,
          createdAt: today,
          updatedAt: today,
        ),
        ProductEntity(
          id: 106,
          name: 'Calotex Gasket R',
          leadEngineerId: 14,
          technicalMilestone: 'Material certified',
          validationStatus: 'Approved',
          finalApproval: true,
          createdAt: today,
          updatedAt: today,
        ),
      ],
      manufacturingOrders: [
        ManufacturingOrderEntity(
          id: 11004891,
          productId: 101,
          status: 'in_production',
          targetQuantity: 230,
          goodQuantity: 180,
          rejectQuantity: 8,
          qaQuantity: 12,
          startDate: today,
          endDate: today.add(const Duration(days: 7)),
        ),
        ManufacturingOrderEntity(
          id: 11005007,
          productId: 102,
          status: 'completed',
          targetQuantity: 10,
          goodQuantity: 10,
          rejectQuantity: 0,
          qaQuantity: 0,
          startDate: today,
          endDate: today.add(const Duration(days: 4)),
        ),
        ManufacturingOrderEntity(
          id: 11005113,
          productId: 103,
          status: 'in_production',
          targetQuantity: 11,
          goodQuantity: 7,
          rejectQuantity: 2,
          qaQuantity: 2,
          startDate: today,
          endDate: today.add(const Duration(days: 2)),
        ),
        ManufacturingOrderEntity(
          id: 11005125,
          productId: 104,
          status: 'quality_control',
          targetQuantity: 6,
          goodQuantity: 4,
          rejectQuantity: 1,
          qaQuantity: 1,
          startDate: today,
          endDate: today.add(const Duration(days: 1)),
        ),
        ManufacturingOrderEntity(
          id: 11005176,
          productId: 105,
          status: 'in_production',
          targetQuantity: 12,
          goodQuantity: 8,
          rejectQuantity: 2,
          qaQuantity: 2,
          startDate: today,
          endDate: today.add(const Duration(days: 3)),
        ),
        ManufacturingOrderEntity(
          id: 6412,
          productId: 106,
          status: 'pending',
          targetQuantity: 1,
          goodQuantity: 0,
          rejectQuantity: 0,
          qaQuantity: 0,
          startDate: today,
          endDate: today.add(const Duration(days: 7)),
        ),
      ],
      events: [
        EventEntity(
          id: 1,
          title: 'Technical team meeting',
          type: 'technical',
          eventDate: DateTime(now.year, now.month, 1),
        ),
        EventEntity(
          id: 2,
          title: 'Quality Control',
          type: 'quality',
          eventDate: DateTime(now.year, now.month, 4),
        ),
        EventEntity(
          id: 3,
          title: 'Export',
          type: 'export',
          eventDate: DateTime(now.year, now.month, 6),
        ),
      ],
    );
  }
}
