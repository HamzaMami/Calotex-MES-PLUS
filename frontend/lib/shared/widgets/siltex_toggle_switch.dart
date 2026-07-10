import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum SiltexToggleColor { green, orange, blue, muted }

/// Colored toggle switch used in data table rows (e.g. Final Approval status).
class SiltexToggleSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final SiltexToggleColor activeColor;

  const SiltexToggleSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.activeColor = SiltexToggleColor.green,
  });

  Color get _activeColor {
    switch (activeColor) {
      case SiltexToggleColor.green:
        return AppTheme.accentGreen;
      case SiltexToggleColor.orange:
        return AppTheme.accentOrange;
      case SiltexToggleColor.blue:
        return AppTheme.accentBlue;
      case SiltexToggleColor.muted:
        return AppTheme.textSubtle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 0.85,
      child: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: Colors.white,
        activeTrackColor: _activeColor,
        inactiveThumbColor: AppTheme.textSubtle,
        inactiveTrackColor: AppTheme.bgElevated,
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _activeColor;
          }
          return AppTheme.divider;
        }),
      ),
    );
  }
}
