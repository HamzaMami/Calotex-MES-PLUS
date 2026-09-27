import '../../domain/entities/dashboard_entities.dart';

class ProductModel extends ProductEntity {
  ProductModel({
    required super.id,
    required super.name,
    super.leadEngineerId,
    super.technicalMilestone,
    super.validationStatus,
    required super.finalApproval,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      name: json['name'],
      leadEngineerId: json['lead_engineer_id'],
      technicalMilestone: json['technical_milestone'],
      validationStatus: json['validation_status'],
      finalApproval: json['final_approval'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

class ManufacturingOrderModel extends ManufacturingOrderEntity {
  ManufacturingOrderModel({
    required super.id,
    required super.productId,
    required super.status,
    required super.targetQuantity,
    required super.goodQuantity,
    required super.rejectQuantity,
    required super.qaQuantity,
    super.startDate,
    super.endDate,
  });

  factory ManufacturingOrderModel.fromJson(Map<String, dynamic> json) {
    return ManufacturingOrderModel(
      id: json['id'],
      productId: json['product_id'],
      status: json['status'],
      targetQuantity: json['target_quantity'],
      goodQuantity: json['good_quantity'] ?? 0,
      rejectQuantity: json['reject_quantity'] ?? 0,
      qaQuantity: json['qa_quantity'] ?? 0,
      startDate: json['start_date'] != null ? DateTime.parse(json['start_date']) : null,
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
    );
  }
}

class EventModel extends EventEntity {
  EventModel({
    required super.id,
    required super.title,
    required super.type,
    required super.eventDate,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'],
      title: json['title'],
      type: json['type'],
      eventDate: DateTime.parse(json['event_date']),
    );
  }
}

/// Aggregated dashboard response model — wraps the three data sources
/// returned by the single `/api/dashboard` endpoint.
class DashboardDataEntityModel {
  final List<ProductModel> products;
  final List<ManufacturingOrderModel> manufacturingOrders;
  final List<EventModel> events;

  const DashboardDataEntityModel({
    required this.products,
    required this.manufacturingOrders,
    required this.events,
  });

  factory DashboardDataEntityModel.fromJson(Map<String, dynamic> json) {
    final products = (json['products'] as List<dynamic>? ?? const [])
        .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
        .toList();
    final orders = (json['manufacturing_orders'] as List<dynamic>? ?? const [])
        .map((e) => ManufacturingOrderModel.fromJson(e as Map<String, dynamic>))
        .toList();
    final events = (json['events'] as List<dynamic>? ?? const [])
        .map((e) => EventModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return DashboardDataEntityModel(
      products: products,
      manufacturingOrders: orders,
      events: events,
    );
  }
}
