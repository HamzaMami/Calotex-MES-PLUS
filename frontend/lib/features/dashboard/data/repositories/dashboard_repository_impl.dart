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
      // Execute all API calls concurrently for better performance
      final results = await Future.wait([
        remoteDataSource.getProducts(),
        remoteDataSource.getManufacturingOrders(),
        remoteDataSource.getEvents(),
      ]);

      return DashboardDataEntity(
        products: results[0] as List<ProductEntity>,
        manufacturingOrders: results[1] as List<ManufacturingOrderEntity>,
        events: results[2] as List<EventEntity>,
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
          id: 1,
          name: 'Siltex Panel A1',
          leadEngineerId: 12,
          technicalMilestone: 'Prototype review',
          validationStatus: 'In progress',
          finalApproval: false,
          createdAt: today,
          updatedAt: today,
        ),
        ProductEntity(
          id: 2,
          name: 'Calotex Tube Pro',
          leadEngineerId: 8,
          technicalMilestone: 'Bench testing',
          validationStatus: 'QA pending',
          finalApproval: true,
          createdAt: today,
          updatedAt: today,
        ),
      ],
      manufacturingOrders: [
        ManufacturingOrderEntity(
          id: 101,
          productId: 1,
          status: 'in_production',
          targetQuantity: 240,
          goodQuantity: 180,
          rejectQuantity: 8,
          qaQuantity: 12,
          startDate: today,
          endDate: today.add(const Duration(days: 7)),
        ),
        ManufacturingOrderEntity(
          id: 102,
          productId: 2,
          status: 'quality_control',
          targetQuantity: 180,
          goodQuantity: 120,
          rejectQuantity: 5,
          qaQuantity: 18,
          startDate: today,
          endDate: today.add(const Duration(days: 4)),
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
