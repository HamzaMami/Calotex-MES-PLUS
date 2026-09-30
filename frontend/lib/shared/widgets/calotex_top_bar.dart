import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CalotexTopBar extends StatelessWidget {
  final String userName;
  final String userRole;
  final String? avatar;
  final String welcomeMessage;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;
  final ValueChanged<String>? onSearch;
  final bool isPresenting;
  final VoidCallback? onTogglePresentation;

  const CalotexTopBar({
    super.key,
    required this.userName,
    this.userRole = '',
    this.avatar,
    this.welcomeMessage = 'Here are your daily updates.',
    this.onNotificationTap,
    this.onProfileTap,
    this.onSearch,
    this.isPresenting = false,
    this.onTogglePresentation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: const BoxDecoration(
        color: AppTheme.bgPrimary,
        border: Border(
          bottom: BorderSide(color: AppTheme.divider, width: 1),
        ),
      ),
      child: Row(
        children: [
          // ── Welcome message ────────────────────────────
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: AppTheme.heading2,
                    children: [
                      const TextSpan(text: 'Welcome Back, '),
                      TextSpan(
                        text: userName,
                        style: AppTheme.heading2.copyWith(
                          color: AppTheme.accentOrange,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(welcomeMessage, style: AppTheme.bodySmall),
              ],
            ),
          ),

          // ── Search bar ────────────────────────────────
          Container(
            width: 240,
            height: 38,
            decoration: BoxDecoration(
              color: AppTheme.bgCard,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(color: AppTheme.divider, width: 1),
            ),
            child: TextField(
              onChanged: onSearch,
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
              decoration: const InputDecoration(
                hintText: 'Search...',
                hintStyle: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                prefixIcon: Icon(Icons.search_rounded, color: AppTheme.textMuted, size: 18),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 16),

          if (onTogglePresentation != null) ...[
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: isPresenting
                    ? Colors.redAccent
                    : const Color(0xFF2B2F45),
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: IconButton(
                onPressed: onTogglePresentation,
                tooltip: isPresenting ? 'Exit Present' : 'Present',
                icon: Icon(
                  isPresenting ? Icons.fullscreen_exit : Icons.slideshow,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],

          // ── Notification bell ─────────────────────────
          _TopBarIconButton(
            icon: Icons.notifications_none_rounded,
            badgeCount: 3,
            onTap: onNotificationTap,
          ),
          const SizedBox(width: 16),

          // ── Divider ───────────────────────────────────
          Container(width: 1, height: 32, color: AppTheme.divider),
          const SizedBox(width: 16),

          // ── User avatar + name ────────────────────────
          _ProfileHoverMenu(
            userName: userName,
            userRole: userRole,
            avatar: avatar,
            onEdit: onProfileTap,
          ),
        ],
      ),
    );
  }
}

class _ProfileHoverMenu extends StatefulWidget {
  final String userName;
  final String userRole;
  final String? avatar;
  final VoidCallback? onEdit;

  const _ProfileHoverMenu({
    required this.userName,
    required this.userRole,
    required this.avatar,
    required this.onEdit,
  });

  @override
  State<_ProfileHoverMenu> createState() => _ProfileHoverMenuState();
}

class _ProfileHoverMenuState extends State<_ProfileHoverMenu> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: SizedBox(
        width: 190,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppTheme.primaryGradient,
                    border: Border.all(
                      color: AppTheme.accentCyan.withValues(alpha: 0.4),
                      width: 2,
                    ),
                  ),
                  child: widget.avatar == null
                      ? Center(
                          child: Text(
                            widget.userName.isNotEmpty
                                ? widget.userName[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        )
                      : ClipOval(
                          child: Image.network(
                            widget.avatar!,
                            width: 38,
                            height: 38,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.person,
                              color: Colors.white,
                            ),
                          ),
                        ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.userName,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (widget.userRole.isNotEmpty)
                        Text(
                          widget.userRole,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.bodySmall.copyWith(fontSize: 11),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (_hovered && widget.onEdit != null)
              Positioned(
                top: 46,
                right: 0,
                child: Material(
                  color: AppTheme.bgCard,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  elevation: 8,
                  child: InkWell(
                    onTap: widget.onEdit,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.edit_outlined,
                              size: 17, color: AppTheme.accentCyan),
                          SizedBox(width: 8),
                          Text(
                            'Edit profile',
                            style: TextStyle(color: AppTheme.textPrimary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TopBarIconButton extends StatefulWidget {
  final IconData icon;
  final int badgeCount;
  final VoidCallback? onTap;

  const _TopBarIconButton({
    required this.icon,
    this.badgeCount = 0,
    this.onTap,
  });

  @override
  State<_TopBarIconButton> createState() => _TopBarIconButtonState();
}

class _TopBarIconButtonState extends State<_TopBarIconButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: _hovered
                    ? AppTheme.accentCyan.withValues(alpha: 0.1)
                    : AppTheme.bgCard,
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                border: Border.all(color: AppTheme.divider, width: 1),
              ),
              child: Icon(
                widget.icon,
                color: _hovered ? AppTheme.accentCyan : AppTheme.textMuted,
                size: 20,
              ),
            ),
            if (widget.badgeCount > 0)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: AppTheme.accentRed,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${widget.badgeCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
