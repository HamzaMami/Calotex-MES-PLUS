class ProductEntity {
  final int id;
  final String productCode;
  final String? productPhoto;
  final String name;
  final int? leadEngineerId;
  final String? technicalMilestone;
  final String? validationStatus;
  final bool finalApproval;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProductEntity({
    required this.id,
    required this.productCode,
    this.productPhoto,
    required this.name,
    this.leadEngineerId,
    this.technicalMilestone,
    this.validationStatus,
    required this.finalApproval,
    required this.createdAt,
    required this.updatedAt,
  });

  ProductEntity copyWith({
    int? id,
    String? productCode,
    String? productPhoto,
    String? name,
    int? leadEngineerId,
    String? technicalMilestone,
    String? validationStatus,
    bool? finalApproval,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductEntity(
      id: id ?? this.id,
      productCode: productCode ?? this.productCode,
      productPhoto: productPhoto ?? this.productPhoto,
      name: name ?? this.name,
      leadEngineerId: leadEngineerId ?? this.leadEngineerId,
      technicalMilestone: technicalMilestone ?? this.technicalMilestone,
      validationStatus: validationStatus ?? this.validationStatus,
      finalApproval: finalApproval ?? this.finalApproval,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory ProductEntity.fromJson(Map<String, dynamic> json) => ProductEntity(
        id: json['id'] as int,
        productCode: json['product_code']?.toString() ??
            'W0000-${(json['id'] as int).toString().padLeft(4, '0')}',
        productPhoto: json['product_photo'] as String?,
        name: json['name'] as String,
        leadEngineerId: json['lead_engineer_id'] as int?,
        technicalMilestone: json['technical_milestone'] as String?,
        validationStatus: json['validation_status'] as String?,
        finalApproval: json['final_approval'] as bool? ?? false,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'product_code': productCode,
        'product_photo': productPhoto,
        'name': name,
        'lead_engineer_id': leadEngineerId,
        'technical_milestone': technicalMilestone,
        'validation_status': validationStatus,
        'final_approval': finalApproval,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
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

  const ManufacturingOrderEntity({
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

  ManufacturingOrderEntity copyWith({
    int? id,
    int? productId,
    String? status,
    int? targetQuantity,
    int? goodQuantity,
    int? rejectQuantity,
    int? qaQuantity,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return ManufacturingOrderEntity(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      status: status ?? this.status,
      targetQuantity: targetQuantity ?? this.targetQuantity,
      goodQuantity: goodQuantity ?? this.goodQuantity,
      rejectQuantity: rejectQuantity ?? this.rejectQuantity,
      qaQuantity: qaQuantity ?? this.qaQuantity,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  factory ManufacturingOrderEntity.fromJson(Map<String, dynamic> json) =>
      ManufacturingOrderEntity(
        id: json['id'] as int,
        productId: json['product_id'] as int,
        status: json['status'] as String,
        targetQuantity: json['target_quantity'] as int? ?? 0,
        goodQuantity: json['good_quantity'] as int? ?? 0,
        rejectQuantity: json['reject_quantity'] as int? ?? 0,
        qaQuantity: json['qa_quantity'] as int? ?? 0,
        startDate:
            json['start_date'] != null ? DateTime.parse(json['start_date'] as String) : null,
        endDate:
            json['end_date'] != null ? DateTime.parse(json['end_date'] as String) : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'product_id': productId,
        'status': status,
        'target_quantity': targetQuantity,
        'good_quantity': goodQuantity,
        'reject_quantity': rejectQuantity,
        'qa_quantity': qaQuantity,
        'start_date': startDate?.toIso8601String(),
        'end_date': endDate?.toIso8601String(),
      };
}

class EventEntity {
  final int id;
  final String title;
  final String type;
  final DateTime eventDate;

  const EventEntity({
    required this.id,
    required this.title,
    required this.type,
    required this.eventDate,
  });

  EventEntity copyWith({
    int? id,
    String? title,
    String? type,
    DateTime? eventDate,
  }) {
    return EventEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      eventDate: eventDate ?? this.eventDate,
    );
  }

  factory EventEntity.fromJson(Map<String, dynamic> json) => EventEntity(
        id: json['id'] as int,
        title: json['title'] as String,
        type: json['type'] as String,
        eventDate: DateTime.parse(json['event_date'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'type': type,
        'event_date': eventDate.toIso8601String(),
      };
}

class ExportPlanEntity {
  final int id;
  final int calendarWeekKw;
  final int year;
  final String? orderNumber;
  final String productCode;
  final int quantity;
  final String destination;
  final String status;

  const ExportPlanEntity({
    required this.id,
    required this.calendarWeekKw,
    required this.year,
    this.orderNumber,
    required this.productCode,
    required this.quantity,
    required this.destination,
    this.status = 'pending',
  });
}

class ProductivityRecordEntity {
  final int calendarWeekKw;
  final int year;
  final double productivityPercentage;

  const ProductivityRecordEntity({
    required this.calendarWeekKw,
    required this.year,
    required this.productivityPercentage,
  });
}

class DashboardDataEntity {
  final List<ProductEntity> products;
  final List<ManufacturingOrderEntity> manufacturingOrders;
  final List<EventEntity> events;
  final List<ExportPlanEntity> exportPlans;
  final List<ProductivityRecordEntity> productivityRecords;

  const DashboardDataEntity({
    required this.products,
    required this.manufacturingOrders,
    required this.events,
    this.exportPlans = const [],
    this.productivityRecords = const [],
  });

  DashboardDataEntity copyWith({
    List<ProductEntity>? products,
    List<ManufacturingOrderEntity>? manufacturingOrders,
    List<EventEntity>? events,
    List<ExportPlanEntity>? exportPlans,
    List<ProductivityRecordEntity>? productivityRecords,
  }) {
    return DashboardDataEntity(
      products: List<ProductEntity>.from(products ?? this.products),
      manufacturingOrders: List<ManufacturingOrderEntity>.from(
          manufacturingOrders ?? this.manufacturingOrders),
      events: List<EventEntity>.from(events ?? this.events),
      exportPlans: List<ExportPlanEntity>.from(exportPlans ?? this.exportPlans),
      productivityRecords: List<ProductivityRecordEntity>.from(
        productivityRecords ?? this.productivityRecords,
      ),
    );
  }
}
