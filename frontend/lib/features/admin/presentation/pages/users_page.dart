import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/string_utils.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/calotex_sidebar.dart';
import '../../../../shared/widgets/calotex_top_bar.dart';
import '../../../../shared/widgets/calotex_card.dart';
import '../../../../shared/widgets/calotex_data_table.dart';
import '../../../../shared/widgets/calotex_gradient_button.dart';
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
    context.read<AdminBloc>().add(const LoadUsers());
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
          CalotexSidebar(
            activeRoute: '/users',
            userRole: userRole,
            onNavItemTap: (route) {
              if (route == '/logout') {
                context.read<AuthBloc>().add(const LogoutRequested());
                Navigator.pushReplacementNamed(context, '/login');
                return;
              }
              if (route != '/users') Navigator.pushReplacementNamed(context, route);
            },
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CalotexTopBar(
                  userName: userName,
                  userRole: StringUtils.formatRole(userRole),
                ),
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
                        context.read<AdminBloc>().add(const LoadUsers());
                      } else if (state is AdminOperationSuccess) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                            backgroundColor: AppTheme.accentGreen,
                          ),
                        );
                        context.read<AdminBloc>().add(const LoadUsers());
                      }
                    },
                    builder: (context, state) {
                      if (state is AdminLoading) {
                        return const Center(
                          child: CircularProgressIndicator(color: AppTheme.accentCyan),
                        );
                      }
                      if (state is AdminError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SelectableText(
                                  'Error loading users:\n${state.message}',
                                  style: const TextStyle(color: AppTheme.accentRed),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                CalotexGradientButton(
                                  label: 'Retry',
                                  width: 120,
                                  onPressed: () {
                                    context.read<AdminBloc>().add(const LoadUsers());
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      if (state is UsersLoaded) {
                        return _buildContent(context, state.users, state.roles);
                      }
                      return const Center(
                        child: Text(
                          'No users found',
                          style: TextStyle(color: AppTheme.textMuted),
                        ),
                      );
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
              const Text('Users', style: AppTheme.heading1),
              SizedBox(
                width: 160,
                child: CalotexGradientButton(
                  label: 'Create User',
                  onPressed: () => _showCreateUserDialog(context, roles),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingLg),
          CalotexCard(
            title: 'All Users',
            padding: EdgeInsets.zero,
            child: CalotexDataTable(
              columns: const [
                CalotexTableColumn(label: 'Name', flex: 1.2),
                CalotexTableColumn(label: 'Email', flex: 1.6),
                CalotexTableColumn(label: 'Role', flex: 1.0),
                CalotexTableColumn(label: 'Status', flex: 0.9),
                CalotexTableColumn(label: 'Actions', flex: 1.1),
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
      SizedBox(
        height: 36,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: AppTheme.bgInput,
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              isExpanded: true,
              value: roles.any((r) => r.id == user.roleId) ? user.roleId : null,
              hint: user.roleName != null
                  ? Text(user.roleName!, style: AppTheme.bodySmall)
                  : null,
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
                  value: selectedRoleId,
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
            CalotexGradientButton(
              label: 'Create',
              onPressed: () {
                if (nameCtrl.text.isEmpty || emailCtrl.text.isEmpty || selectedRoleId == null) {
                  return;
                }
                Navigator.pop(ctx);
                context.read<AdminBloc>().add(
                      CreateUser(nameCtrl.text.trim(), emailCtrl.text.trim(), selectedRoleId!),
                    );
              },
            ),
          ],
        ),
      ),
    );
  }
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
