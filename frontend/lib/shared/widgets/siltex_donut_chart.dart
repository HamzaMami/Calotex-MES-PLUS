import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Data model for a donut chart segment.
class DonutSegment {
  final double value;
  final Color color;
  final String? label;

  const DonutSegment({
    required this.value,
    required this.color,
    this.label,
  });
}

/// Circular donut chart used in Production Volume and Active Orders cards.
class SiltexDonutChart extends StatelessWidget {
  final List<DonutSegment> segments;
  final String centerText;
  final String? centerSubText;
  final double size;
  final double strokeWidth;
  final Color trackColor;

  const SiltexDonutChart({
    super.key,
    required this.segments,
    required this.centerText,
    this.centerSubText,
    this.size = 120,
    this.strokeWidth = 14,
    this.trackColor = AppTheme.bgElevated,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _DonutPainter(
              segments: segments,
              strokeWidth: strokeWidth,
              trackColor: trackColor,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                centerText,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (centerSubText != null)
                Text(
                  centerSubText!,
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<DonutSegment> segments;
  final double strokeWidth;
  final Color trackColor;

  _DonutPainter({
    required this.segments,
    required this.strokeWidth,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - strokeWidth / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Draw track (background ring)
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    final total = segments.fold(0.0, (sum, s) => sum + s.value);
    if (total == 0) return;

    double startAngle = -math.pi / 2; // Start from the top
    const gap = 0.04; // gap in radians between segments

    for (final segment in segments) {
      final sweepAngle =
          (segment.value / total) * (2 * math.pi) - (segments.length > 1 ? gap : 0);

      final paint = Paint()
        ..color = segment.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) =>
      oldDelegate.segments != segments;
}
