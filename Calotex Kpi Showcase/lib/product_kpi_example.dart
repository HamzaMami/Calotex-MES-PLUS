import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:kpi_showcase/theme/app_theme.dart';
import 'package:kpi_showcase/components/kpi_card.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CALOTEX-1 Performance Dashboard',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const hPad = 48.0;
    const titleSize = 32.0;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1800),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: hPad, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'CALOTEX-1 PERFORMANCE DASHBOARD',
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('KV 30',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary)),
                      Text('26 July 2026',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    children: [
                      Expanded(
                        child: KpiCard(
                          title: 'Export Progress (112 / 150)',
                          value: '75%',
                          color: AppTheme.accentGreen,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: KpiCard(
                          title: 'Compliance Semi-finished',
                          value: '98%',
                          color: AppTheme.accentBlue,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: KpiCard(
                          title: 'Compliance Finished',
                          value: '99%',
                          color: AppTheme.accentCyan,
                        ),
                      ),
                      SizedBox(width: 16),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Main Left Section: Gauge + Bar Chart (Top) & Wide Export Volume (Bottom)
                        Expanded(
                          flex: 6,
                          child: Column(
                            children: [
                              // Upper Row: Gauge & Workshop Workload
                              Expanded(
                                flex: 6,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        decoration: AppTheme.cardDecoration(),
                                        padding: const EdgeInsets.all(16),
                                        child: const GaugeWidget(
                                          actual: '112',
                                          target: '150',
                                          progress: 0.747,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Container(
                                        decoration: AppTheme.cardDecoration(),
                                        padding: const EdgeInsets.all(16),
                                        child: const BarChartWidget(
                                          title: 'Workshop Workload',
                                          values: [0.9, 0.78, 0.6],
                                          labels: [
                                            'Workshop 1',
                                            'Workshop 2',
                                            'Workshop 3'
                                          ],
                                          gradient: [
                                            AppTheme.accentOrange,
                                            AppTheme.accentYellow
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Lower Row: Full-width Export Volume Timeline
                              Expanded(
                                flex: 4,
                                child: Container(
                                  decoration: AppTheme.cardDecoration(),
                                  padding: const EdgeInsets.all(16),
                                  child: const ExportVolumeCard(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Right Section: Product Assembly
                        Expanded(
                          flex: 4,
                          child: Container(
                            decoration: AppTheme.cardDecoration(),
                            padding: const EdgeInsets.all(24),
                            child: const ProductAssemblyWidget(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ExportVolumeCard extends StatelessWidget {
  const ExportVolumeCard({super.key});

  static const spots = [
    FlSpot(0, 130),
    FlSpot(1, 142),
    FlSpot(2, 148),
    FlSpot(3, 112),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Flexible(
              child: Text(
                'Export Volume — July',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: LineChart(
            LineChartData(
              minY: 0,
              maxY: 170,
              minX: -0.2,
              maxX: 3.2,
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1.0,
                    reservedSize: 28,
                    getTitlesWidget: (value, meta) {
                      if (value != value.roundToDouble()) {
                        return const SizedBox.shrink();
                      }

                      const style = TextStyle(
                        color: Color(0xFF8E8EA9),
                        fontSize: 10,
                      );

                      String text;
                      switch (value.toInt()) {
                        case 0:
                          text = 'Jul 1-7';
                          break;
                        case 1:
                          text = 'Jul 8-14';
                          break;
                        case 2:
                          text = 'Jul 15-21';
                          break;
                        case 3:
                          text = 'Jul 22-31';
                          break;
                        default:
                          return const SizedBox.shrink();
                      }

                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(text, style: style),
                      );
                    },
                  ),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: const Color(0xFF29B6F6),
                  barWidth: 3.0,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 4,
                        color: Colors.white,
                        strokeWidth: 2.5,
                        strokeColor: const Color(0xFF29B6F6),
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: const LinearGradient(
                      colors: [
                        Color(0x6600E5FF),
                        Color(0x00000000),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                enabled: true,
                handleBuiltInTouches: false,
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => Colors.transparent,
                  tooltipPadding: EdgeInsets.zero,
                  tooltipMargin: 6,
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      return LineTooltipItem(
                        '${spot.y.toInt()}',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class GaugeWidget extends StatelessWidget {
  final String actual;
  final String target;
  final double progress;

  const GaugeWidget({
    super.key,
    required this.actual,
    required this.target,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Export Progress This Week', style: AppTheme.heading2),
        const Spacer(),
        LayoutBuilder(
          builder: (context, constraints) {
            final w = (constraints.maxWidth * 0.85).clamp(180.0, 420.0);
            final h = w * 120 / 240;
            return SizedBox(
              height: h,
              width: w,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: Size(w, h),
                    painter: _GaugePainter(progress),
                  ),
                  Positioned(
                    bottom: h * 0.07,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.bgInput,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                      child: Column(
                        children: [
                          Text(actual,
                              style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary)),
                          Text('Actual', style: AppTheme.bodySmall),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: h * 0.07,
                    right: w * 0.15,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppTheme.accentBlue,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text('$target\nTarget',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            );
          },
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: DefaultTextStyle(
            style: TextStyle(fontSize: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('00'),
                Text('100%'),
              ],
            ),
          ),
        ),
        const Spacer(),
      ],
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double progress;
  const _GaugePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2 - 10;

    final base = Paint()
      ..color = AppTheme.bgInput
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    final progressShader = const LinearGradient(
      colors: [AppTheme.accentCyan, AppTheme.accentBlue],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final progressPaint = Paint()
      ..shader = progressShader
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), math.pi,
        math.pi, false, base);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), math.pi,
        math.pi * progress, false, progressPaint);

    final needleAngle = math.pi + (math.pi * progress);
    final needleEnd = Offset(
      center.dx + (radius - 15) * math.cos(needleAngle),
      center.dy + (radius - 15) * math.sin(needleAngle),
    );
    final needle = Paint()
      ..color = AppTheme.textMuted
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, needleEnd, needle);
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class BarChartWidget extends StatelessWidget {
  final String title;
  final List<double> values;
  final List<String> labels;
  final List<Color> gradient;
  const BarChartWidget({
    super.key,
    required this.title,
    required this.values,
    required this.labels,
    this.gradient = const [AppTheme.accentCyan, AppTheme.accentBlue],
  });

  @override
  Widget build(BuildContext context) {
    const barHeight = 18.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(child: Text(title, style: AppTheme.heading2)),
        const Spacer(),
        ...List.generate(values.length, (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Row(
              children: [
                SizedBox(
                  width: 84,
                  child: Text(labels[index], style: AppTheme.bodySmall),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                          height: barHeight,
                          decoration: BoxDecoration(
                              color: AppTheme.bgInput,
                              borderRadius:
                                  BorderRadius.circular(barHeight / 2))),
                      FractionallySizedBox(
                        widthFactor: values[index],
                        child: Container(
                          height: barHeight,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: gradient),
                            borderRadius: BorderRadius.circular(barHeight / 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
        const Spacer(),
      ],
    );
  }
}

class ProductAssemblyWidget extends StatefulWidget {
  const ProductAssemblyWidget({super.key});

  @override
  State<ProductAssemblyWidget> createState() => _ProductAssemblyWidgetState();
}

class _ProductAssemblyWidgetState extends State<ProductAssemblyWidget> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  Timer? _timer;

  static const Map<String, List<String>> assembly = {
    '1': ['assets/rvs.jpeg', 'productName'],
    '2': ['assets/rvs.jpeg', 'test'],
    '3': ['assets/workshop1.jpg', 'ok'],
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startAutoScroll());
  }

  void _startAutoScroll() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!_controller.hasClients) return;
      final next = (_currentPage + 1) % assembly.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Products Assembly', style: AppTheme.heading2),
        const SizedBox(height: 16),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            child: PageView.builder(
              controller: _controller,
              itemCount: assembly.length,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder: (context, index) {
                return Container(
                  color: Colors.white,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          assembly.values.toList()[index][0],
                          fit: BoxFit.contain,
                        ),
                      ),
                      Positioned(
                        left: 16,
                        bottom: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            assembly.values.toList()[index][1],
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(assembly.length, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 6),
              width: _currentPage == index ? 16 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? AppTheme.accentBlue
                    : AppTheme.textMuted,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }
}
