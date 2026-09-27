class StringUtils {
  /// Formats a role string from snake_case to Title Case (e.g., 'quality_lead' -> 'Quality Lead').
  static String formatRole(String role) {
    if (role.isEmpty) return '';
    return role
        .split('_')
        .map((w) => w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }
}
