import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Model for a navigation item in the sidebar.
class SidebarNavItem {
  final String label;
  final IconData icon;
  final String route;

  const SidebarNavItem({
    required this.label,
    required this.icon,
    required this.route,
  });
}

/// SILTEX main navigation sidebar with logo, nav items, and support section.
class SiltexSidebar extends StatelessWidget {
  final String activeRoute;
  final ValueChanged<String>? onNavItemTap;

  static const List<SidebarNavItem> _mainItems = [
    SidebarNavItem(label: 'Dashboard',     icon: Icons.dashboard_rounded,          route: '/home'),
    SidebarNavItem(label: 'Users',         icon: Icons.people_alt_outlined,         route: '/users'),
    SidebarNavItem(label: 'Roles',         icon: Icons.admin_panel_settings_outlined, route: '/roles'),
    SidebarNavItem(label: 'Inventory',     icon: Icons.inventory_2_outlined,        route: '/inventory'),
    SidebarNavItem(label: 'Products',      icon: Icons.category_outlined,           route: '/products'),
    SidebarNavItem(label: 'Drafts',        icon: Icons.edit_document,               route: '/drafts'),
    SidebarNavItem(label: 'Documents',     icon: Icons.description_outlined,        route: '/documents'),
    SidebarNavItem(label: 'Manufacturing', icon: Icons.precision_manufacturing_outlined, route: '/manufacturing'),
  ];

  static const List<SidebarNavItem> _supportItems = [
    SidebarNavItem(label: 'Settings', icon: Icons.settings_outlined,    route: '/settings'),
    SidebarNavItem(label: 'Log Out',  icon: Icons.logout_rounded,        route: '/logout'),
  ];

  const SiltexSidebar({
    super.key,
    required this.activeRoute,
    this.onNavItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppTheme.sidebarWidth,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: AppTheme.bgSidebar,
        border: Border(
          right: BorderSide(color: AppTheme.divider, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Logo ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('SILTEX', style: AppTheme.logoText),
                const SizedBox(height: 4),
                Text(
                  'Seamless Manufacturing,\nStreamlined Monitoring.',
                  style: AppTheme.bodySmall.copyWith(fontSize: 10, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Divider(color: AppTheme.divider, height: 1),
          const SizedBox(height: 16),

          // ── GENERAL section ──────────────────────────────
          _sectionLabel('GENERAL'),
          const SizedBox(height: 6),
          ..._mainItems.map((item) => _NavTile(
                item: item,
                isActive: activeRoute == item.route,
                onTap: () => onNavItemTap?.call(item.route),
              )),

          const Spacer(),
          const Divider(color: AppTheme.divider, height: 1),
          const SizedBox(height: 8),

          // ── SUPPORT section ──────────────────────────────
          _sectionLabel('SUPPORT'),
          const SizedBox(height: 6),
          ..._supportItems.map((item) => _NavTile(
                item: item,
                isActive: activeRoute == item.route,
                onTap: () => onNavItemTap?.call(item.route),
                isDestructive: item.route == '/logout',
              )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        child: Text(text, style: AppTheme.label),
      );
}

class _NavTile extends StatefulWidget {
  final SidebarNavItem item;
  final bool isActive;
  final VoidCallback? onTap;
  final bool isDestructive;

  const _NavTile({
    required this.item,
    required this.isActive,
    this.onTap,
    this.isDestructive = false,
  });

  @override
  State<_NavTile> createState() => _NavTileState();
}

class _NavTileState extends State<_NavTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final Color iconColor = widget.isDestructive
        ? AppTheme.accentRed
        : widget.isActive
            ? AppTheme.accentCyan
            : _hovered
                ? AppTheme.textPrimary
                : AppTheme.textMuted;

    final Color textColor = widget.isDestructive
        ? AppTheme.accentRed
        : widget.isActive
            ? AppTheme.textPrimary
            : _hovered
                ? AppTheme.textPrimary
                : AppTheme.textMuted;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: widget.isActive
                ? AppTheme.accentCyan.withValues(alpha: 0.1)
                : _hovered
                    ? Colors.white.withValues(alpha: 0.04)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            border: widget.isActive
                ? Border(
                    left: BorderSide(
                      color: AppTheme.accentCyan,
                      width: 3,
                    ),
                  )
                : null,
          ),
          child: Row(
            children: [
              Icon(widget.item.icon, size: 18, color: iconColor),
              const SizedBox(width: 10),
              Text(
                widget.item.label,
                style: TextStyle(
                  color: textColor,
                  fontSize: 13,
                  fontWeight:
                      widget.isActive ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
