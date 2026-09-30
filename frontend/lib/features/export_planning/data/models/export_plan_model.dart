import '../../domain/entities/export_plan.dart';

class ExportPlanModel extends ExportPlan {
  const ExportPlanModel({
    required super.id,
    required super.calendarWeekKw,
    required super.year,
    super.orderNumber,
    required super.productCode,
    required super.quantity,
    required super.destination,
    super.createdBy,
    super.createdAt,
    super.updatedAt,
  });

  factory ExportPlanModel.fromJson(Map<String, dynamic> json) {
    DateTime? date(dynamic value) =>
        value == null ? null : DateTime.tryParse(value.toString());
    return ExportPlanModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      calendarWeekKw: (json['calendar_week_kw'] as num?)?.toInt() ??
          (json['kw'] as num?)?.toInt() ??
          0,
      year: (json['year'] as num?)?.toInt() ?? 0,
      orderNumber: json['order_number']?.toString(),
      productCode: json['product_code']?.toString() ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      destination: json['destination']?.toString() ?? '',
      createdBy: (json['created_by'] as num?)?.toInt(),
      createdAt: date(json['created_at']),
      updatedAt: date(json['updated_at']),
    );
  }

  factory ExportPlanModel.fromInput(ExportPlanInput input) => ExportPlanModel(
        id: 0,
        calendarWeekKw: input.calendarWeekKw,
        year: input.year,
        orderNumber: input.orderNumber,
        productCode: input.productCode,
        quantity: input.quantity,
        destination: input.destination,
      );
}
