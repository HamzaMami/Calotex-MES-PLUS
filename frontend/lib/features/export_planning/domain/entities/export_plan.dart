class ExportPlan {
  final int id;
  final int calendarWeekKw;
  final int year;
  final String? orderNumber;
  final String productCode;
  final int quantity;
  final String destination;
  final int? createdBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ExportPlan({
    required this.id,
    required this.calendarWeekKw,
    required this.year,
    this.orderNumber,
    required this.productCode,
    required this.quantity,
    required this.destination,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
  });
}

class ExportPlanInput {
  final int calendarWeekKw;
  final int year;
  final String? orderNumber;
  final String productCode;
  final int quantity;
  final String destination;

  const ExportPlanInput({
    required this.calendarWeekKw,
    required this.year,
    this.orderNumber,
    required this.productCode,
    required this.quantity,
    required this.destination,
  });

  Map<String, dynamic> toJson() => {
        'calendar_week_kw': calendarWeekKw,
        'year': year,
        'order_number': orderNumber,
        'product_code': productCode,
        'quantity': quantity,
        'destination': destination,
      };
}
