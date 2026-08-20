import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/siltex_sidebar.dart';
import '../../../../shared/widgets/siltex_top_bar.dart';
import '../../../../shared/widgets/siltex_card.dart';
import '../../../../shared/widgets/siltex_gradient_button.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/admin_bloc.dart';
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
          SiltexSidebar(
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
                        context.read<AdminBloc>().add(LoadRolesAndPermissions());
                      }
                    },
                    builder: (context, state) {
                      if (state is AdminLoading) {
                        return const Center(
                          child: CircularProgressIndicator(color: AppTheme.accentCyan),
                        );
                      }
                      if (state is RolesLoaded) {
                        return _buildContent(context, state.roles, state.permissions);
                      }
                      return const Center(
                        child: Text('No roles found', style: TextStyle(color: AppTheme.textMuted)),
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
              SiltexGradientButton(
                label: 'Create Role',
                width: 160,
                onPressed: () => _showCreateRoleDialog(context),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingLg),
          ...roles.map((role) => _roleCard(context, role, permissions)),
        ],
      ),
    );
  }

  Widget _roleCard(
    BuildContext context,
    RoleModel role,
    List<PermissionModel> allPermissions,
  ) {
    final selected = <int>{for (var p in role.permissions) p.id};

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      child: SiltexCard(
        title: role.name,
        action: role.isSystem
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.accentCyan.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppTheme.radiusXs),
                ),
                child: const Text(
                  'SYSTEM',
                  style: TextStyle(
                    color: AppTheme.accentCyan,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
            : IconButton(
                icon: const Icon(Icons.delete_outline, color: AppTheme.accentRed, size: 18),
                onPressed: () => context.read<AdminBloc>().add(RemoveRole(role.id)),
              ),
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          if (role.description != null && role.description!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(role.description!, style: AppTheme.bodySmall),
            ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: allPermissions.map((perm) {
              final isOn = selected.contains(perm.id);
              return FilterChip(
                label: Text(perm.name),
                selected: isOn,
                onSelected: role.isSystem
                    ? null
                    : (on) {
                        if (on) {
                          selected.add(perm.id);
                        } else {
                          selected.remove(perm.id);
                        }
                        context.read<AdminBloc>().add(
                              LoadRolesAndPermissions(),
                            );
                        // Persist on toggle for non-system roles.
                        if (!role.isSystem) {
                          context.read<AdminBloc>().add(
                                SetRolePermissionsEvent(role.id, selected.toList()),
                              );
                        }
                      },
                selectedColor: AppTheme.accentCyan.withValues(alpha: 0.2),
                checkmarkColor: AppTheme.accentCyan,
                labelStyle: TextStyle(
                  color: isOn ? AppTheme.accentCyan : AppTheme.textMuted,
                  fontSize: 12,
                ),
                backgroundColor: AppTheme.bgInput,
              );
            }).toList(),
          ),
        ],
      ),
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
        title: const Text('Create Role', style: TextStyle(color: AppTheme.textPrimary)),
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: AppTheme.inputDecoration(hint: 'Role name (e.g. quality_lead)'),
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
          SiltexGradientButton(
            label: 'Create',
            width: 120,
            onPressed: () {
              if (nameCtrl.text.isEmpty) return;
              Navigator.pop(ctx);
              context.read<AdminBloc>().add(
                    CreateRole(nameCtrl.text, descCtrl.text),
                  );
            },
          ),
        ],
      ),
    );
  }

  String _formatRole(String role) =>
      role.split('_').map((w) => w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1)).join(' ');
}
