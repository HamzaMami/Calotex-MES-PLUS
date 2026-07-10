// ─── Entities ────────────────────────────────────────────────────────────────

class ProductEntity {
  final int id;
  final String name;
  final int? leadEngineerId;
  final String? technicalMilestone;
  final String? validationStatus;
  final bool finalApproval;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductEntity({
    required this.id,
    required this.name,
    this.leadEngineerId,
    this.technicalMilestone,
    this.validationStatus,
    required this.finalApproval,
    required this.createdAt,
    required this.updatedAt,
  });
}

class ManufacturingOrderEntity {
  final int id;
  final int productId;
  final String status;
  final int targetQuantity;
  final int goodQuantity;
  final int rejectQuantity;
  final int qaQuantity;
  final DateTime? startDate;
  final DateTime? endDate;

  ManufacturingOrderEntity({
    required this.id,
    required this.productId,
    required this.status,
    required this.targetQuantity,
    required this.goodQuantity,
    required this.rejectQuantity,
    required this.qaQuantity,
    this.startDate,
    this.endDate,
  });
}

class EventEntity {
  final int id;
  final String title;
  final String type; // technical, quality, export
  final DateTime eventDate;

  EventEntity({
    required this.id,
    required this.title,
    required this.type,
    required this.eventDate,
  });
}

/// Composite entity holding all data needed for the dashboard.
class DashboardDataEntity {
  final List<ProductEntity> products;
  final List<ManufacturingOrderEntity> manufacturingOrders;
  final List<EventEntity> events;

  DashboardDataEntity({
    required this.products,
    required this.manufacturingOrders,
    required this.events,
  });
}
