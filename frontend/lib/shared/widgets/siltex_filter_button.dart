import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Outlined filter button with icon, used in Schedule and Product Maturity cards.
class SiltexFilterButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String label;

  const SiltexFilterButton({
    super.key,
    this.onPressed,
    this.label = 'Filter',
  });

  @override
  State<SiltexFilterButton> createState() => _SiltexFilterButtonState();
}

class _SiltexFilterButtonState extends State<SiltexFilterButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: _hovered
                ? AppTheme.accentCyan.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            border: Border.all(
              color: _hovered ? AppTheme.accentCyan : AppTheme.divider,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: TextStyle(
                  color: _hovered ? AppTheme.accentCyan : AppTheme.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.tune_rounded,
                size: 15,
                color: _hovered ? AppTheme.accentCyan : AppTheme.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
