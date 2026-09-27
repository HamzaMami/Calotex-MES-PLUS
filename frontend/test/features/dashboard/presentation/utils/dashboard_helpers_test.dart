import 'package:flutter_test/flutter_test.dart';
import 'package:calotex_app/features/dashboard/domain/entities/dashboard_entities.dart';
import 'package:calotex_app/features/dashboard/presentation/utils/dashboard_helpers.dart';

void main() {
  group('DashboardMetrics', () {
    test('calculates metrics from non-empty data', () {
      final data = DashboardDataEntity(
        products: [
          ProductEntity(
            id: 1,
            name: 'KV 30',
            finalApproval: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ],
        manufacturingOrders: [
          ManufacturingOrderEntity(
            id: 1,
            productId: 1,
            status: 'in_production',
            targetQuantity: 100,
            goodQuantity: 60,
            rejectQuantity: 10,
            qaQuantity: 20,
          ),
        ],
        events: const [],
      );

      final metrics = DashboardMetrics.from(data);

      expect(metrics.produced, 80);
      expect(metrics.target, 100);
      expect(metrics.exportPct, 80);
      expect(metrics.semiCompliance, 89);
      expect(metrics.finishedCompliance, 100);
      expect(metrics.volume, equals([80.0, 80.0, 80.0, 80.0]));
    });

    test('returns fallback values for empty data', () {
      final data = DashboardDataEntity(
        products: const [],
        manufacturingOrders: const [],
        events: const [],
      );

      final metrics = DashboardMetrics.from(data);

      expect(metrics.produced, 0);
      expect(metrics.target, 0);
      expect(metrics.exportPct, 0);
      expect(metrics.semiCompliance, 0);
      expect(metrics.finishedCompliance, 0);
      expect(metrics.volume, equals([130, 142, 148, 112]));
    });
  });

  group('RoleFormatting', () {
    test('converts snake_case to display role', () {
      expect('admin'.toDisplayRole(), 'Admin');
      expect('in_production'.toDisplayRole(), 'In Production');
      expect('quality_control'.toDisplayRole(), 'Quality Control');
    });
  });

  group('VolumeSeries', () {
    test('extracts volume series from orders', () {
      final orders = [
        ManufacturingOrderEntity(
          id: 1,
          productId: 1,
          status: 'in_production',
          targetQuantity: 100,
          goodQuantity: 30,
          rejectQuantity: 10,
          qaQuantity: 20,
        ),
        ManufacturingOrderEntity(
          id: 2,
          productId: 1,
          status: 'pending',
          targetQuantity: 100,
          goodQuantity: 40,
          rejectQuantity: 5,
          qaQuantity: 15,
        ),
      ];

      expect(orders.toVolumeSeries(), equals([50.0, 55.0, 55.0, 55.0]));
    });

    test('pads short series to length 4', () {
      final orders = [
        ManufacturingOrderEntity(
          id: 1,
          productId: 1,
          status: 'in_production',
          targetQuantity: 100,
          goodQuantity: 10,
          rejectQuantity: 0,
          qaQuantity: 0,
        ),
      ];

      expect(orders.toVolumeSeries(), equals([10.0, 10.0, 10.0, 10.0]));
    });
  });
}
