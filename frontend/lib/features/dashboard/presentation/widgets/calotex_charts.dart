import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../shared/theme/app_theme.dart';

/// Semi-circular progress gauge (mirrors the CALOTEX reference gauge).
class CalotexGauge extends StatelessWidget {
  final double progress; // 0..1
  final String actual;
  final String target;
  final String caption;

  const CalotexGauge({
    super.key,
    required this.progress,
    required this.actual,
    required this.target,
    this.caption = 'Export Progress This Week',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          caption,
          style: AppTheme.heading3.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
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

                  // Center "Actual" Box (Improved Contrast & Text Legibility)
                  Positioned(
                    bottom: h * 0.05,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 10),
                      decoration: BoxDecoration(
                        color:
                            const Color(0xFF1E1E38), // High contrast dark card
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        border: Border.all(color: Colors.white12, width: 1),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          )
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            actual,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Actual',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(
                                  0xFFA0A0C0), // Brightened subtitle label
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // "Target" Tooltip Label (Sharper & Larger Text)
                  Positioned(
                    top: h * 0.05,
                    right: w * 0.12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.accentBlue,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black38,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            target,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight:
                                  FontWeight.w800, // Fixed from .extrabold
                            ),
                          ),
                          const Text(
                            'Target',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            );
          },
        ),

        // Gauge Baseline Labels (0% & 100%) - Increased Legibility
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 28.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '0%',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors
                      .white70, // Replaced muted '00' with visible white '0%'
                ),
              ),
              Text(
                '100%',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                ),
              ),
            ],
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
      ..color =
          const Color(0xFF262646) // Slightly brighter track for visibility
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
      ..color = Colors.white70
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, needleEnd, needle);
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// Vertical histogram (mirrors the reference "Workshop Workload" as bars).
class CalotexHistogram extends StatelessWidget {
  final String title;
  final List<double> values; // 0..1
  final List<String> labels;
  final List<Color> gradient;

  const CalotexHistogram({
    super.key,
    required this.title,
    required this.values,
    required this.labels,
    this.gradient = const [AppTheme.accentCyan, AppTheme.accentBlue],
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            title,
            style: AppTheme.heading3.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(values.length, (index) {
                final v = values[index].clamp(0.0, 1.0);
                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // High-contrast bar percentage labels
                      Text(
                        '${(v * 100).round()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: FractionallySizedBox(
                          heightFactor: v,
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            width: 44,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: gradient,
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: gradient.last.withValues(alpha: 0.25),
                                  blurRadius: 8,
                                  offset: const Offset(0, -2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: 76,
                        child: Text(
                          labels[index],
                          style: const TextStyle(
                            color: Color(0xFFC0C0DB), // Sharper grey-white
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}
