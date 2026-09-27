import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum CalotexToggleColor { green, orange, blue, muted }

/// Colored toggle switch used in data table rows (e.g. Final Approval status).
class CalotexToggleSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final CalotexToggleColor activeColor;

  const CalotexToggleSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.activeColor = CalotexToggleColor.green,
  });

  Color get _activeColor {
    switch (activeColor) {
      case CalotexToggleColor.green:
        return AppTheme.accentGreen;
      case CalotexToggleColor.orange:
        return AppTheme.accentOrange;
      case CalotexToggleColor.blue:
        return AppTheme.accentBlue;
      case CalotexToggleColor.muted:
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
