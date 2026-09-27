import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    context.read<AdminBloc>().add(LoadRolesAndPermissions());
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
            onNavItemTap: (route) {
              if (route == '/logout') {
                context.read<AuthBloc>().add(const LogoutRequested());
                return;
              }
              if (route != '/roles') Navigator.pushReplacementNamed(context, route);
            },
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CalotexTopBar(userName: userName, userRole: _formatRole(userRole)),
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
                        context.read<AdminBloc>().add(LoadRolesAndPermissions());
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
                            child: SelectableText(
                              'Error loading roles:\n${state.message}',
                              style: const TextStyle(color: AppTheme.accentRed),
                              textAlign: TextAlign.center,
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Roles & Permissions', style: AppTheme.heading1),
              CalotexGradientButton(
                label: 'Create Role',
                width: 160,
                onPressed: () => _showCreateRoleDialog(context),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingLg),
          ...roles.map((role) => Padding(
                padding: const EdgeInsets.only(bottom: AppTheme.spacingMd),
                child: PermissionMatrix(
                  role: role,
                  allPermissions: permissions,
                  onSave: (ids) => context
                      .read<AdminBloc>()
                      .add(SetRolePermissionsEvent(role.id, ids)),
                ),
              )),
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
                    AppTheme.inputDecoration(hint: 'Role name (e.g. quality_lead)'),
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
                  .add(CreateRole(nameCtrl.text, descCtrl.text));
            },
          ),
        ],
      ),
    );
  }

  String _formatRole(String role) =>
      role.split('_').map((w) => w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1)).join(' ');
}
