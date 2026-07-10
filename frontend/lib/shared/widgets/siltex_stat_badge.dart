import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum SiltexBadgeVariant { success, error, warning, info, neutral, live }

/// Colored status badge/chip for labels like Good, Reject, Live, Pending etc.
class SiltexStatBadge extends StatelessWidget {
  final String label;
  final SiltexBadgeVariant variant;
  final bool showDot;

  const SiltexStatBadge({
    super.key,
    required this.label,
    this.variant = SiltexBadgeVariant.neutral,
    this.showDot = false,
  });

  Color get _color {
    switch (variant) {
      case SiltexBadgeVariant.success: return AppTheme.accentGreen;
      case SiltexBadgeVariant.error:   return AppTheme.accentRed;
      case SiltexBadgeVariant.warning: return AppTheme.accentOrange;
      case SiltexBadgeVariant.info:    return AppTheme.accentCyan;
      case SiltexBadgeVariant.live:    return AppTheme.accentGreen;
      case SiltexBadgeVariant.neutral: return AppTheme.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(color: _color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: _color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: TextStyle(
              color: _color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

/// Number badge used for counts in the active orders legend.
class SiltexCountBadge extends StatelessWidget {
  final int count;
  final SiltexBadgeVariant variant;

  const SiltexCountBadge({
    super.key,
    required this.count,
    this.variant = SiltexBadgeVariant.info,
  });

  Color get _color {
    switch (variant) {
      case SiltexBadgeVariant.success: return AppTheme.accentGreen;
      case SiltexBadgeVariant.error:   return AppTheme.accentRed;
      case SiltexBadgeVariant.warning: return AppTheme.accentOrange;
      case SiltexBadgeVariant.info:    return AppTheme.accentBlue;
      case SiltexBadgeVariant.live:    return AppTheme.accentGreen;
      case SiltexBadgeVariant.neutral: return AppTheme.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _color,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
