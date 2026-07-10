import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Generic reusable dark card container used for all dashboard panels.
class SiltexCard extends StatelessWidget {
  final Widget child;
  final String? title;
  final Widget? action;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final double radius;
  final Color? color;

  const SiltexCard({
    super.key,
    required this.child,
    this.title,
    this.action,
    this.padding,
    this.width,
    this.height,
    this.radius = AppTheme.radiusLg,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: AppTheme.cardDecoration(color: color, radius: radius),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null || action != null) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (title != null)
                    Text(title!, style: AppTheme.heading3),
                  if (action != null) action!,
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Divider(color: AppTheme.divider, height: 1),
          ],
          Padding(
            padding: padding ?? const EdgeInsets.all(AppTheme.spacingMd),
            child: child,
          ),
        ],
      ),
    );
  }
}
