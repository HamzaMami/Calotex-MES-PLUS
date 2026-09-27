import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // ─── Background Colors ───────────────────────────────────────
  static const Color bgPrimary = Color(0xFF121224);
  static const Color bgCard = Color(0xFF1D1B37);
  static const Color bgInput = Color(0xFF201F37);
  static const Color bgSidebar = Color(0xFF171630);
  static const Color bgElevated = Color(0xFF282747);

  // ─── Accent Colors ───────────────────────────────────────────
  static const Color accentCyan = Color(0xFF00E5FF);
  static const Color accentBlue = Color(0xFF3D8BFF);
  static const Color accentGreen = Color(0xFF00E096);
  static const Color accentOrange = Color(0xFFFF8A00);
  static const Color accentRed = Color(0xFFFF5E5E);
  static const Color accentYellow = Color(0xFFFFD60A);

  // ─── Text Colors ─────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFF8A8AA8);
  static const Color textSubtle = Color(0xFF4A4A6A);

  // ─── Utility ─────────────────────────────────────────────────
  static const Color divider = Color(0x14FFFFFF); // rgba(white, 0.08)
  static const Color sidebarActiveIndicator = accentCyan;

  // ─── Border Radius ───────────────────────────────────────────
  static const double radiusXs = 6.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;

  // ─── Spacing ─────────────────────────────────────────────────
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;

  // ─── Sidebar ─────────────────────────────────────────────────
  static const double sidebarWidth = 220.0;

  // ─── Gradients ───────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [accentCyan, accentBlue],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient subtleGradient = LinearGradient(
    colors: [Color(0xFF1D1B37), Color(0xFF282747)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ─── Text Styles ─────────────────────────────────────────────
  static const TextStyle heading1 = TextStyle(
    color: textPrimary,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );

  static const TextStyle heading2 = TextStyle(
    color: textPrimary,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const TextStyle heading3 = TextStyle(
    color: textPrimary,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static const TextStyle bodyLarge = TextStyle(
    color: textPrimary,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    color: textPrimary,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    color: textMuted,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static const TextStyle label = TextStyle(
    color: textMuted,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.8,
  );

  static const TextStyle logoText = TextStyle(
    color: accentCyan,
    fontSize: 28,
    fontWeight: FontWeight.w900,
    letterSpacing: 2.0,
  );

  // ─── Card decoration ─────────────────────────────────────────
  static BoxDecoration cardDecoration({
    Color? color,
    double radius = radiusLg,
    bool hasBorder = true,
    List<BoxShadow>? shadows,
  }) {
    return BoxDecoration(
      color: color ?? bgCard,
      borderRadius: BorderRadius.circular(radius),
      border: hasBorder ? Border.all(color: divider, width: 1) : null,
      boxShadow: shadows ??
          [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
    );
  }

  // ─── Input decoration factory ─────────────────────────────────
  static InputDecoration inputDecoration({
    required String hint,
    Widget? prefix,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: textMuted, fontSize: 14),
      prefixIcon: prefix,
      suffixIcon: suffix,
      filled: true,
      fillColor: bgInput,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: accentCyan, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: accentRed, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: accentRed, width: 1.5),
      ),
    );
  }

  // ─── MaterialApp Theme ───────────────────────────────────────
  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: bgPrimary,
        colorScheme: const ColorScheme.dark(
          primary: accentCyan,
          secondary: accentBlue,
          surface: bgCard,
          error: accentRed,
        ),
        dividerColor: divider,
      );
}
