import '../../domain/entities/dashboard_entities.dart';

class ProductModel extends ProductEntity {
  ProductModel({
    required super.id,
    required super.productCode,
    super.productPhoto,
    required super.name,
    super.leadEngineerId,
    super.technicalMilestone,
    super.validationStatus,
    required super.finalApproval,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as int;
    final rawProductCode = json['product_code']?.toString().trim();
    return ProductModel(
      id: id,
      productCode: rawProductCode == null || rawProductCode.isEmpty
          ? 'W0000-${id.toString().padLeft(4, '0')}'
          : rawProductCode,
      productPhoto: json['product_photo'],
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
      id: (json['id'] as num?)?.toInt() ?? 0,
      productId: (json['product_id'] as num?)?.toInt() ?? 0,
      status: json['status']?.toString() ?? 'pending',
      targetQuantity: (json['target_quantity'] as num?)?.toInt() ?? 0,
      goodQuantity: (json['good_quantity'] as num?)?.toInt() ?? 0,
      rejectQuantity: (json['reject_quantity'] as num?)?.toInt() ?? 0,
      qaQuantity: (json['qa_quantity'] as num?)?.toInt() ?? 0,
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

class ExportPlanModel extends ExportPlanEntity {
  const ExportPlanModel({
    required super.id,
    required super.calendarWeekKw,
    required super.year,
    super.orderNumber,
    required super.productCode,
    required super.quantity,
    required super.destination,
    required super.status,
  });

  factory ExportPlanModel.fromJson(Map<String, dynamic> json) => ExportPlanModel(
        id: (json['id'] as num?)?.toInt() ?? 0,
        calendarWeekKw: (json['calendar_week_kw'] as num?)?.toInt() ?? 0,
        year: (json['year'] as num?)?.toInt() ?? 0,
        orderNumber: json['order_number']?.toString(),
        productCode: json['product_code']?.toString() ?? '',
        quantity: (json['quantity'] as num?)?.toInt() ?? 0,
        destination: json['destination']?.toString() ?? '',
        status: json['status']?.toString() ?? 'pending',
      );
}

class ProductivityRecordModel extends ProductivityRecordEntity {
  const ProductivityRecordModel({
    required super.calendarWeekKw,
    required super.year,
    required super.productivityPercentage,
  });

  factory ProductivityRecordModel.fromJson(Map<String, dynamic> json) =>
      ProductivityRecordModel(
        calendarWeekKw: (json['calendar_week_kw'] as num?)?.toInt() ?? 0,
        year: (json['year'] as num?)?.toInt() ?? 0,
        productivityPercentage:
            double.tryParse('${json['productivity_percentage']}') ?? 0,
      );
}

/// Aggregated dashboard response model — wraps the three data sources
/// returned by the single `/api/dashboard` endpoint.
class DashboardDataEntityModel {
  final List<ProductModel> products;
  final List<ManufacturingOrderModel> manufacturingOrders;
  final List<EventModel> events;
  final List<ExportPlanModel> exportPlans;
  final List<ProductivityRecordModel> productivityRecords;

  const DashboardDataEntityModel({
    required this.products,
    required this.manufacturingOrders,
    required this.events,
    this.exportPlans = const [],
    this.productivityRecords = const [],
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
    final exportPlans = (json['export_plans'] as List<dynamic>? ?? const [])
        .map((e) => ExportPlanModel.fromJson(e as Map<String, dynamic>))
        .toList();
    final rawProductivityRecords = json['productivity_records'];
    final productivityRecords =
        (rawProductivityRecords is List ? rawProductivityRecords : const <dynamic>[])
            .map((e) => ProductivityRecordModel.fromJson(e as Map<String, dynamic>))
            .toList();
    return DashboardDataEntityModel(
      products: products,
      manufacturingOrders: orders,
      events: events,
      exportPlans: exportPlans,
      productivityRecords: productivityRecords,
    );
  }
}
