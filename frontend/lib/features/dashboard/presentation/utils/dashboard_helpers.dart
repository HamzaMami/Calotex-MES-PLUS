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
    if (isEmpty) return const [130, 142, 148, 112];
    final series = map((o) => (o.goodQuantity + o.qaQuantity).toDouble()).toList();
    while (series.length < 4) {
      series.add(series.isEmpty ? 0 : series.last);
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
  final double kv39Productivity;
  final double kv38Productivity;
  final double kv37Productivity;
  final double kv36Productivity;

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
    required this.kv39Productivity,
    required this.kv38Productivity,
    required this.kv37Productivity,
    required this.kv36Productivity,
  });

  factory DashboardMetrics.from(DashboardDataEntity data) {
    final orders = data.manufacturingOrders;
    var target = 0, good = 0, reject = 0, qa = 0;
    for (final o in orders) {
      target += o.targetQuantity;
      good += o.goodQuantity;
      reject += o.rejectQuantity;
      qa += o.qaQuantity;
    }
    final produced = good + qa;
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

    final totalOrders = orders.length;
    final statusVals = totalOrders > 0
        ? [
            orders.where((o) => o.status == 'in_production').length / totalOrders,
            orders.where((o) => o.status == 'pending').length / totalOrders,
            orders.where((o) => o.status == 'quality_control').length / totalOrders,
          ]
        : const [0.85, 0.65, 0.45];

    final now = DateTime.now();
    final dayStr = now.day.toString().padLeft(2, '0');
    final today = '$dayStr ${monthName(now.month)} ${now.year}';
    final productName = data.products.isNotEmpty ? data.products.first.name : 'KV 40';

    final workshopProductivities = _computeWorkshopProductivities(orders);

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
      kv39Productivity: workshopProductivities.kv39,
      kv38Productivity: workshopProductivities.kv38,
      kv37Productivity: workshopProductivities.kv37,
      kv36Productivity: workshopProductivities.kv36,
    );
  }

  static ({double kv39, double kv38, double kv37, double kv36}) _computeWorkshopProductivities(
    List<ManufacturingOrderEntity> orders,
  ) {
    if (orders.isEmpty) {
      return (kv39: 0.88, kv38: 0.72, kv37: 0.55, kv36: 0.40);
    }

    final workshops = <String, List<ManufacturingOrderEntity>>{
      'kv39': [],
      'kv38': [],
      'kv37': [],
      'kv36': [],
    };

    for (var i = 0; i < orders.length; i++) {
      final key = workshops.keys.elementAt(i % workshops.length);
      workshops[key]!.add(orders[i]);
    }

    double productivity(List<ManufacturingOrderEntity> list) {
      var t = 0, p = 0;
      for (final o in list) {
        t += o.targetQuantity;
        p += o.goodQuantity + o.qaQuantity;
      }
      return t > 0 ? (p / t).clamp(0.0, 1.0) : 0.0;
    }

    return (
      kv39: productivity(workshops['kv39']!),
      kv38: productivity(workshops['kv38']!),
      kv37: productivity(workshops['kv37']!),
      kv36: productivity(workshops['kv36']!),
    );
  }
}
