import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/string_utils.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/calotex_sidebar.dart';
import '../../../../shared/widgets/calotex_top_bar.dart';
import '../../../../shared/widgets/calotex_gradient_button.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/admin_bloc.dart';
import '../widgets/permission_matrix.dart';
import '../../data/models/rbac_models.dart';

class RolesPage extends StatefulWidget {
  const RolesPage({super.key});

  @override
  State<RolesPage> createState() => _RolesPageState();
}

class _RolesPageState extends State<RolesPage> {
  @override
  void initState() {
    super.initState();
    context.read<AdminBloc>().add(const LoadRolesAndPermissions());
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
            activeRoute: '/roles',
            userRole: userRole,
            onNavItemTap: (route) {
              if (route == '/logout') {
                context.read<AuthBloc>().add(const LogoutRequested());
                Navigator.pushReplacementNamed(context, '/login');
                return;
              }
              if (route != '/roles') Navigator.pushReplacementNamed(context, route);
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
                        context.read<AdminBloc>().add(const LoadRolesAndPermissions());
                      } else if (state is AdminOperationSuccess) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message),
                            backgroundColor: AppTheme.accentGreen,
                          ),
                        );
                        context.read<AdminBloc>().add(const LoadRolesAndPermissions());
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
                                  'Error loading roles:\n${state.message}',
                                  style: const TextStyle(color: AppTheme.accentRed),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                CalotexGradientButton(
                                  label: 'Retry',
                                  width: 120,
                                  onPressed: () {
                                    context
                                        .read<AdminBloc>()
                                        .add(const LoadRolesAndPermissions());
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      if (state is RolesLoaded) {
                        return _buildContent(
                            context, state.roles, state.permissions);
                      }
                      return const Center(
                        child: Text('No roles found',
                            style: TextStyle(color: AppTheme.textMuted)),
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
    List<RoleModel> roles,
    List<PermissionModel> permissions,
  ) {
    final systemRoles = roles.where((r) => r.isSystem).toList();
    final customRoles = roles.where((r) => !r.isSystem).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Roles & Permissions', style: AppTheme.heading1),
              CalotexGradientButton(
                label: 'Create Custom Role',
                width: 200,
                onPressed: () => _showCreateRoleDialog(context),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingLg),

          // ── CUSTOM ROLES SECTION ─────────────────────────────
          const Row(
            children: [
              Icon(Icons.tune_rounded, color: AppTheme.accentOrange, size: 20),
              SizedBox(width: 8),
              Text('Custom Roles (Configurable Permissions)', style: AppTheme.heading2),
            ],
          ),
          const SizedBox(height: 12),
          if (customRoles.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: AppTheme.cardDecoration(),
              child: const Center(
                child: Text(
                  'No custom roles created yet. Click "Create Custom Role" to add one.',
                  style: TextStyle(color: AppTheme.textMuted),
                ),
              ),
            )
          else
            ...customRoles.map((role) => Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.spacingMd),
                  child: PermissionMatrix(
                    role: role,
                    allPermissions: permissions,
                    onSave: (ids) => context
                        .read<AdminBloc>()
                        .add(SetRolePermissionsEvent(role.id, ids)),
                    onDelete: () => _confirmDeleteRole(context, role),
                  ),
                )),

          const SizedBox(height: AppTheme.spacingLg),

          // ── SYSTEM ROLES SECTION ─────────────────────────────
          if (systemRoles.isNotEmpty) ...[
            const Row(
              children: [
                Icon(Icons.verified_user_rounded, color: AppTheme.accentCyan, size: 20),
                SizedBox(width: 8),
                Text('System Roles (Fixed System Defaults)', style: AppTheme.heading2),
              ],
            ),
            const SizedBox(height: 12),
            ...systemRoles.map((role) => Padding(
                  padding: const EdgeInsets.only(bottom: AppTheme.spacingMd),
                  child: PermissionMatrix(
                    role: role,
                    allPermissions: permissions,
                  ),
                )),
          ],
        ],
      ),
    );
  }

  void _confirmDeleteRole(BuildContext context, RoleModel role) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        title: const Text('Delete Role', style: TextStyle(color: AppTheme.textPrimary)),
        content: Text('Are you sure you want to delete the role "${role.name}"? Users assigned to this role will lose their permissions.',
            style: AppTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AdminBloc>().add(RemoveRole(role.id));
            },
            child: const Text('Delete', style: TextStyle(color: AppTheme.accentRed)),
          ),
        ],
      ),
    );
  }

  void _showCreateRoleDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        title: const Text('Create Role',
            style: TextStyle(color: AppTheme.textPrimary)),
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration:
                    AppTheme.inputDecoration(hint: 'Role name (e.g. Quality Manager)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                decoration: AppTheme.inputDecoration(hint: 'Description'),
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
            width: 120,
            onPressed: () {
              if (nameCtrl.text.isEmpty) return;
              Navigator.pop(ctx);
              context
                  .read<AdminBloc>()
                  .add(CreateRole(nameCtrl.text.trim(), descCtrl.text.trim()));
            },
          ),
        ],
      ),
    );
  }
}
