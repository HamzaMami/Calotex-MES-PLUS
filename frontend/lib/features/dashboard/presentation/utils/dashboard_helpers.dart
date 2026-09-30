import '../../domain/entities/dashboard_entities.dart';

String monthName(int m) => const [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ][m - 1];

extension RoleFormatting on String {
  String toDisplayRole() {
    return split('_').map((w) => w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1)).join(' ');
  }
}

extension VolumeSeries on List<ManufacturingOrderEntity> {
  List<double> toVolumeSeries() {
    if (isEmpty) return const [0, 0, 0, 0];
    final series = map((o) => (o.goodQuantity + o.qaQuantity).toDouble()).toList();
    while (series.length < 4) {
      series.add(0);
    }
    return series.take(4).toList();
  }
}

class DashboardMetrics {
  final String productName;
  final String today;
  final int produced;
  final int target;
  final int exportPct;
  final int semiCompliance;
  final int finishedCompliance;
  final List<double> statusVals;
  final List<double> volume;
  final List<double> productivityValues;
  final List<String> productivityLabels;
  final double monthlyProductivity;
  final String productivityMonthLabel;

  const DashboardMetrics({
    required this.productName,
    required this.today,
    required this.produced,
    required this.target,
    required this.exportPct,
    required this.semiCompliance,
    required this.finishedCompliance,
    required this.statusVals,
    required this.volume,
    required this.productivityValues,
    required this.productivityLabels,
    required this.monthlyProductivity,
    required this.productivityMonthLabel,
  });

  factory DashboardMetrics.from(DashboardDataEntity data) {
    final orders = data.manufacturingOrders;
    final now = DateTime.now();
    final currentWeek = getISOWeekAndYear(now);
    final currentExportPlans = data.exportPlans
        .where((plan) =>
            plan.year == currentWeek['year'] &&
            plan.calendarWeekKw == currentWeek['kw'])
        .toList();
    final currentMonday = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    final nextMonday = currentMonday.add(const Duration(days: 7));
    final currentOrders = orders.where((order) {
      final orderDate = order.startDate ?? order.endDate;
      return orderDate != null &&
          !orderDate.isBefore(currentMonday) &&
          orderDate.isBefore(nextMonday);
    }).toList();
    final metricOrders = currentOrders;
    var manufacturingTarget = 0, good = 0, reject = 0, qa = 0;
    for (final o in metricOrders) {
      manufacturingTarget += o.targetQuantity;
      good += o.status == 'completed' ? o.targetQuantity : o.goodQuantity;
      reject += o.rejectQuantity;
      qa += o.qaQuantity;
    }
    
    final exportTarget = currentExportPlans.fold<int>(
      0,
      (total, plan) => total + plan.quantity,
    );

    // Sum all QA passed items across orders and completed export plans
    int totalPassedQaItems = 0;
    for (final o in metricOrders) {
      totalPassedQaItems += (o.goodQuantity > o.qaQuantity ? o.goodQuantity : o.qaQuantity);
    }
    for (final plan in currentExportPlans) {
      if (plan.status == 'completed') {
        totalPassedQaItems += plan.quantity;
      }
    }

    final produced = totalPassedQaItems > 0 ? totalPassedQaItems : (good + qa);
    final target = exportTarget > 0
        ? exportTarget
        : (currentOrders.isNotEmpty ? manufacturingTarget : 0);
    final exportPct = target > 0 ? (produced / target * 100).clamp(0, 100).round() : 0;

    final totalInspected = produced + reject;
    final semiCompliance = totalInspected > 0
        ? (100 - (reject / totalInspected * 100)).round()
        : 0;

    final finishedCompliance = data.products.isNotEmpty
        ? (data.products.where((p) => p.finalApproval).length /
                data.products.length *
                100)
            .round()
        : 0;

    final totalOrders = metricOrders.length;
    final statusVals = totalOrders > 0
        ? [
            metricOrders.where((o) => o.status == 'in_production').length / totalOrders,
            metricOrders.where((o) => o.status == 'pending').length / totalOrders,
            metricOrders.where((o) => o.status == 'quality_control').length / totalOrders,
          ]
        : const [0.0, 0.0, 0.0];

    final dayStr = now.day.toString().padLeft(2, '0');
    final currentKWInfo = getISOWeekAndYear(now);
    final currentKW = currentKWInfo['kw']!;
    final today = '$dayStr ${monthName(now.month)} ${now.year}';
    final productName = data.products.isNotEmpty
        ? data.products.first.name
        : 'KW $currentKW';

    final productivityData = _computeProductivitySeries(
      data.productivityRecords,
      orders,
      now,
    );
    final monthlyRecords = data.productivityRecords
        .where((record) =>
            record.year == now.year &&
            record.calendarWeekKw == now.month)
        .toList();
    final monthlyProductivity = monthlyRecords.isEmpty
        ? _computeMonthlyProductivity(orders, now)
        : monthlyRecords.fold<double>(
                0, (sum, record) => sum + record.productivityPercentage) /
            monthlyRecords.length /
            100;

    return DashboardMetrics(
      productName: productName,
      today: today,
      produced: produced,
      target: target,
      exportPct: exportPct,
      semiCompliance: semiCompliance,
      finishedCompliance: finishedCompliance,
      statusVals: statusVals,
      volume: orders.toVolumeSeries(),
      productivityValues: productivityData.values,
      productivityLabels: productivityData.labels,
      monthlyProductivity: monthlyProductivity,
      productivityMonthLabel: monthName(now.month),
    );
  }

  /// Calculates ISO Calendar Week (KW) and Year for any date.
  /// Guarantees Monday, Sept 28, 2026 = KW 40, Year 2026.
  static Map<String, int> getISOWeekAndYear(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    final day = d.weekday; // 1 = Monday, 7 = Sunday
    final thursday = d.add(Duration(days: 4 - day));
    final yearStart = DateTime(thursday.year, 1, 1);
    final diffDays = thursday.difference(yearStart).inDays;
    final weekNo = (diffDays / 7).floor() + 1;
    return {'kw': weekNo, 'year': thursday.year};
  }

  /// Calculates real productivity data for the last 4 completed Calendar Weeks (KW)
  /// prior to the current week (e.g. KW 39, KW 38, KW 37, KW 36 when current week is KW 40).
  static ({List<double> values, List<String> labels}) _computeLast4WeeksProductivity(
    List<ManufacturingOrderEntity> orders,
    DateTime referenceDate,
  ) {
    final List<double> values = [];
    final List<String> labels = [];

    // Find the Monday of the current reference week
    final currentWeekday = referenceDate.weekday;
    final currentMonday = DateTime(
      referenceDate.year,
      referenceDate.month,
      referenceDate.day,
    ).subtract(Duration(days: currentWeekday - 1));

    // Iterate backwards for the last 4 completed weeks (weeks i = 1, 2, 3, 4 back)
    for (int i = 1; i <= 4; i++) {
      final weekMonday = currentMonday.subtract(Duration(days: i * 7));
      final weekSunday = weekMonday.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));

      final weekInfo = getISOWeekAndYear(weekMonday);
      labels.add('KW ${weekInfo['kw']}');

      // Filter orders belonging to this Calendar Week
      final weekOrders = orders.where((order) {
        final orderDate = order.startDate ?? order.endDate;
        if (orderDate == null) return false;
        return orderDate.isAfter(weekMonday.subtract(const Duration(seconds: 1))) &&
            orderDate.isBefore(weekSunday.add(const Duration(seconds: 1)));
      }).toList();

      if (weekOrders.isEmpty) {
        values.add(0.0);
      } else {
        var totalTarget = 0;
        var totalProduced = 0;
        for (final o in weekOrders) {
          totalTarget += o.targetQuantity;
          totalProduced += (o.goodQuantity + o.qaQuantity);
        }
        final productivity = totalTarget > 0
            ? (totalProduced / totalTarget).clamp(0.0, 1.0)
            : 0.0;
        values.add(productivity);
      }
    }

    return (values: values, labels: labels);
  }

  static double _computeMonthlyProductivity(
    List<ManufacturingOrderEntity> orders,
    DateTime referenceDate,
  ) {
    final monthOrders = orders.where((order) {
      final orderDate = order.startDate ?? order.endDate;
      return orderDate != null &&
          orderDate.year == referenceDate.year &&
          orderDate.month == referenceDate.month;
    });

    var totalTarget = 0;
    var totalProduced = 0;
    for (final order in monthOrders) {
      totalTarget += order.targetQuantity;
      totalProduced += order.goodQuantity + order.qaQuantity;
    }

    return totalTarget > 0 ? totalProduced / totalTarget : 0.0;
  }

  static ({List<double> values, List<String> labels}) _computeProductivitySeries(
    List<ProductivityRecordEntity> records,
    List<ManufacturingOrderEntity> orders,
    DateTime now,
  ) {
    if (records.isEmpty) return _computeLast4WeeksProductivity(orders, now);
    final current = getISOWeekAndYear(now)['kw']!;
    final selected = records.where((r) => r.year == now.year).toList()
      ..sort((a, b) => b.calendarWeekKw.compareTo(a.calendarWeekKw));
    final values = <double>[];
    final labels = <String>[];
    for (final record in selected.take(4)) {
      values.add(record.productivityPercentage / 100);
      labels.add('KW ${record.calendarWeekKw}');
    }
    while (values.length < 4) {
      values.add(0);
      labels.add('KW ${current - values.length + 1}');
    }
    return (values: values.reversed.toList(), labels: labels.reversed.toList());
  }

}
