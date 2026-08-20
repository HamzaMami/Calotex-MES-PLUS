import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/siltex_sidebar.dart';
import '../../../../shared/widgets/siltex_top_bar.dart';
import '../../../../shared/widgets/siltex_card.dart';
import '../../../../shared/widgets/siltex_data_table.dart';
import '../../../../shared/widgets/siltex_gradient_button.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/admin_bloc.dart';
import '../../data/models/rbac_models.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  @override
  void initState() {
    super.initState();
    context.read<AdminBloc>().add(LoadUsers());
  }

  @override
  Widget build(BuildContext context) {
    final userName = context.select<AuthBloc, String>((b) {
      final s = b.state;
      return s is Authenticated ? s.user.firstName : 'User';
    });
    final userRole = context.select<AuthBloc, String>((b) {
      final s = b.state;
      return s is Authenticated ? s.user.role : '';
    });

    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SiltexSidebar(
            activeRoute: '/users',
            onNavItemTap: (route) {
              if (route == '/logout') {
                context.read<AuthBloc>().add(const LogoutRequested());
                return;
              }
              if (route != '/users') Navigator.pushReplacementNamed(context, route);
            },
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SiltexTopBar(userName: userName, userRole: _formatRole(userRole)),
                Expanded(
                  child: BlocConsumer<AdminBloc, AdminState>(
                    listener: (context, state) {
                      if (state is AdminError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                            backgroundColor: AppTheme.accentRed,
                          ),
                        );
                      } else if (state is AdminOperationSuccess) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                            backgroundColor: AppTheme.accentGreen,
                          ),
                        );
                        context.read<AdminBloc>().add(LoadUsers());
                      }
                    },
                    builder: (context, state) {
                      if (state is AdminLoading) {
                        return const Center(
                          child: CircularProgressIndicator(color: AppTheme.accentCyan),
                        );
                      }
                      if (state is UsersLoaded) {
                        return _buildContent(context, state.users, state.roles);
                      }
                      return const Center(child: Text('No users found', style: TextStyle(color: AppTheme.textMuted)));
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    List<UserModel> users,
    List<RoleModel> roles,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Users', style: AppTheme.heading1),
              SiltexGradientButton(
                label: 'Create User',
                onPressed: () => _showCreateUserDialog(context, roles),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingLg),
          SiltexCard(
            title: 'All Users',
            padding: EdgeInsets.zero,
            child: SiltexDataTable(
              columns: const [
                SiltexTableColumn(label: 'Name', flex: 1.2),
                SiltexTableColumn(label: 'Email', flex: 1.6),
                SiltexTableColumn(label: 'Role', flex: 1.0),
                SiltexTableColumn(label: 'Status', flex: 0.9),
                SiltexTableColumn(label: 'Actions', flex: 1.1),
              ],
              rows: users.map((u) => _userRow(context, u, roles)).toList(),
              currentPage: 1,
              totalPages: 1,
              onPreviousPage: () {},
              onNextPage: () {},
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _userRow(
    BuildContext context,
    UserModel user,
    List<RoleModel> roles,
  ) {
    return [
      Text(user.name ?? '-', style: AppTheme.bodyMedium),
      Text(user.email, style: AppTheme.bodyMedium),
      // Role dropdown
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.bgInput,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            value: user.roleId,
            isDense: true,
            dropdownColor: AppTheme.bgElevated,
            icon: const Icon(Icons.arrow_drop_down, color: AppTheme.textMuted),
            items: roles
                .map((r) => DropdownMenuItem(
                      value: r.id,
                      child: Text(r.name, style: AppTheme.bodySmall),
                    ))
                .toList(),
            onChanged: (roleId) {
              if (roleId != null && roleId != user.roleId) {
                context.read<AdminBloc>().add(UpdateUserRole(user.id, roleId));
              }
            },
          ),
        ),
      ),
      _statusChip(user.status),
      Row(
        children: [
          _StatusAction(
            label: user.status == 'active' ? 'Deactivate' : 'Activate',
            color: user.status == 'active' ? AppTheme.accentOrange : AppTheme.accentGreen,
            onPressed: () => context.read<AdminBloc>().add(
              SetUserStatus(user.id, user.status == 'active' ? 'inactive' : 'active'),
            ),
          ),
          const SizedBox(width: 8),
          _StatusAction(
            label: 'Delete',
            color: AppTheme.accentRed,
            onPressed: () => _confirmDelete(context, user),
          ),
        ],
      ),
    ];
  }

  Widget _statusChip(String status) {
    final color = status == 'active'
        ? AppTheme.accentGreen
        : status == 'inactive'
            ? AppTheme.accentRed
            : AppTheme.accentYellow;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppTheme.radiusXs),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }

  void _confirmDelete(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        title: const Text('Delete user?', style: TextStyle(color: AppTheme.textPrimary)),
        content: Text('Delete ${user.email}? This cannot be undone.',
            style: AppTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AdminBloc>().add(DeleteUser(user.id));
            },
            child: const Text('Delete', style: TextStyle(color: AppTheme.accentRed)),
          ),
        ],
      ),
    );
  }

  void _showCreateUserDialog(BuildContext context, List<RoleModel> roles) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    int? selectedRoleId = roles.isNotEmpty ? roles.first.id : null;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          backgroundColor: AppTheme.bgCard,
          title: const Text('Create User', style: TextStyle(color: AppTheme.textPrimary)),
          content: SizedBox(
            width: 360,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: AppTheme.inputDecoration(hint: 'Full name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailCtrl,
                  decoration: AppTheme.inputDecoration(hint: 'Email'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  initialValue: selectedRoleId,
                  dropdownColor: AppTheme.bgElevated,
                  decoration: AppTheme.inputDecoration(hint: 'Role'),
                  items: roles
                      .map((r) => DropdownMenuItem(value: r.id, child: Text(r.name)))
                      .toList(),
                  onChanged: (v) => setState(() => selectedRoleId = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            SiltexGradientButton(
              label: 'Create',
              onPressed: () {
                if (nameCtrl.text.isEmpty || emailCtrl.text.isEmpty || selectedRoleId == null) {
                  return;
                }
                Navigator.pop(ctx);
                context.read<AdminBloc>().add(
                      CreateUser(nameCtrl.text, emailCtrl.text, selectedRoleId!),
                    );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatRole(String role) =>
      role.split('_').map((w) => w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1)).join(' ');
}

class _StatusAction extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _StatusAction({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 12)),
    );
  }
}
