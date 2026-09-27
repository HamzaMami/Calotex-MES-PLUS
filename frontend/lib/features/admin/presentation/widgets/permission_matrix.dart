import 'package:flutter/material.dart';

import '../../../../shared/theme/app_theme.dart';
import '../../../../shared/widgets/calotex_gradient_button.dart';
import '../../data/models/rbac_models.dart';

/// Action columns rendered for every resource group.
enum PermissionAction { read, create, update, delete }

extension PermissionActionX on PermissionAction {
  String get label {
    switch (this) {
      case PermissionAction.read:
        return 'Read';
      case PermissionAction.create:
        return 'Create';
      case PermissionAction.update:
        return 'Update';
      case PermissionAction.delete:
        return 'Delete';
    }
  }

  /// Maps to the backend permission suffix, e.g. "read" -> "users:read".
  String get suffix {
    switch (this) {
      case PermissionAction.read:
        return 'read';
      case PermissionAction.create:
        return 'create';
      case PermissionAction.update:
        return 'update';
      case PermissionAction.delete:
        return 'delete';
    }
  }
}

/// Logical resource modules, in display order.
enum PermissionResource {
  dashboard,
  users,
  roles,
  permissions,
  products,
  inventory,
  manufacturing,
  events,
}

extension PermissionResourceX on PermissionResource {
  String get label {
    switch (this) {
      case PermissionResource.dashboard:
        return 'Dashboard';
      case PermissionResource.users:
        return 'Users';
      case PermissionResource.roles:
        return 'Roles';
      case PermissionResource.permissions:
        return 'Permissions';
      case PermissionResource.products:
        return 'Products';
      case PermissionResource.inventory:
        return 'Inventory';
      case PermissionResource.manufacturing:
        return 'Manufacturing';
      case PermissionResource.events:
        return 'Events';
    }
  }

  /// Backend permission prefix, e.g. "users" -> "users:read".
  String get prefix {
    switch (this) {
      case PermissionResource.dashboard:
        return 'dashboard';
      case PermissionResource.users:
        return 'users';
      case PermissionResource.roles:
        return 'roles';
      case PermissionResource.permissions:
        return 'permissions';
      case PermissionResource.products:
        return 'products';
      case PermissionResource.inventory:
        return 'inventory';
      case PermissionResource.manufacturing:
        return 'manufacturing';
      case PermissionResource.events:
        return 'events';
    }
  }

  /// Some resources support fewer actions than the full CRUD set.
  List<PermissionAction> get supportedActions {
    switch (this) {
      case PermissionResource.dashboard:
      case PermissionResource.events:
        return const [PermissionAction.read];
      default:
        return PermissionAction.values;
    }
  }
}

/// Parses a backend permission name ("users:create") into its parts.
class ParsedPermission {
  final PermissionResource? resource;
  final PermissionAction? action;

  const ParsedPermission(this.resource, this.action);

  static ParsedPermission parse(String name) {
    final parts = name.split(':');
    if (parts.length != 2) return const ParsedPermission(null, null);
    final resource = PermissionResource.values
        .where((r) => r.prefix == parts[0])
        .firstOrNull;
    final action = PermissionAction.values
        .where((a) => a.suffix == parts[1])
        .firstOrNull;
    return ParsedPermission(resource, action);
  }
}

/// A single role's editable permission matrix.
///
/// Shows permissions grouped by resource with Read/Create/Update/Delete
/// toggle columns and a per-category "Select All" control. Supports a clean
/// [viewMode] (read-only) and an [editMode] with local draft state and Save.
class PermissionMatrix extends StatefulWidget {
  final RoleModel role;
  final List<PermissionModel> allPermissions;
  final ValueChanged<List<int>>? onSave;

  const PermissionMatrix({
    super.key,
    required this.role,
    required this.allPermissions,
    this.onSave,
  });

  @override
  State<PermissionMatrix> createState() => _PermissionMatrixState();
}

class _PermissionMatrixState extends State<PermissionMatrix> {
  late Set<int> _selected;
  late bool _editing;

  @override
  void initState() {
    super.initState();
    _selected = {for (final p in widget.role.permissions) p.id};
    // System roles are protected: start in view mode and cannot be edited.
    _editing = !widget.role.isSystem;
  }

  @override
  void didUpdateWidget(covariant PermissionMatrix oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.role != widget.role) {
      _selected = {for (final p in widget.role.permissions) p.id};
      _editing = !widget.role.isSystem;
    }
  }

  PermissionModel? _permissionFor(
    PermissionResource resource,
    PermissionAction action,
  ) {
    for (final p in widget.allPermissions) {
      final parsed = ParsedPermission.parse(p.name);
      if (parsed.resource == resource && parsed.action == action) return p;
    }
    return null;
  }

  bool _isOn(PermissionResource resource, PermissionAction action) {
    final perm = _permissionFor(resource, action);
    return perm != null && _selected.contains(perm.id);
  }

  void _toggle(PermissionResource resource, PermissionAction action, bool value) {
    final perm = _permissionFor(resource, action);
    if (perm == null) return;
    setState(() {
      if (value) {
        _selected.add(perm.id);
      } else {
        _selected.remove(perm.id);
      }
    });
  }

  bool _allSelected(PermissionResource resource) {
    return resource.supportedActions.every((a) => _isOn(resource, a));
  }

  void _toggleAll(PermissionResource resource, bool value) {
    setState(() {
      for (final a in resource.supportedActions) {
        final perm = _permissionFor(resource, a);
        if (perm == null) continue;
        if (value) {
          _selected.add(perm.id);
        } else {
          _selected.remove(perm.id);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final resources = PermissionResource.values;
    final readOnly = !_editing || widget.role.isSystem;

    return CalotexCardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: title + view/edit controls.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.role.name, style: AppTheme.heading3),
                    if (widget.role.description != null &&
                        widget.role.description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          widget.role.description!,
                          style: AppTheme.bodySmall,
                        ),
                      ),
                  ],
                ),
              ),
              if (widget.role.isSystem)
                _SystemBadge()
              else if (readOnly)
                TextButton.icon(
                  onPressed: () => setState(() => _editing = true),
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Edit'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.accentCyan,
                  ),
                )
              else
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selected = {
                            for (final p in widget.role.permissions) p.id
                          };
                          _editing = false;
                        });
                      },
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    CalotexGradientButton(
                      label: 'Save',
                      width: 110,
                      height: 38,
                      onPressed: () =>
                          widget.onSave?.call(_selected.toList()),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMd),
          // Column headers.
          _MatrixHeader(readOnly: readOnly),
          const SizedBox(height: 4),
          // Resource groups.
          ...resources.map((r) => _ResourceRow(
                resource: r,
                allOn: _allSelected(r),
                readOnly: readOnly,
                isOn: (a) => _isOn(r, a),
                onToggle: _toggle,
                onToggleAll: _toggleAll,
              )),
        ],
      ),
    );
  }
}

class _MatrixHeader extends StatelessWidget {
  final bool readOnly;
  const _MatrixHeader({required this.readOnly});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.bgInput,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Row(
        children: [
          const Expanded(
            flex: 3,
            child: Text('Resource', style: AppTheme.label),
          ),
          if (!readOnly)
            const Expanded(
              flex: 2,
              child: Text('All', style: AppTheme.label, textAlign: TextAlign.center),
            ),
          ...PermissionAction.values.map((a) => Expanded(
                flex: 2,
                child: Text(a.label,
                    style: AppTheme.label, textAlign: TextAlign.center),
              )),
        ],
      ),
    );
  }
}

class _ResourceRow extends StatelessWidget {
  final PermissionResource resource;
  final bool allOn;
  final bool readOnly;
  final bool Function(PermissionAction) isOn;
  final void Function(PermissionResource, PermissionAction, bool) onToggle;
  final void Function(PermissionResource, bool) onToggleAll;

  const _ResourceRow({
    required this.resource,
    required this.allOn,
    required this.readOnly,
    required this.isOn,
    required this.onToggle,
    required this.onToggleAll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.divider, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(resource.label, style: AppTheme.bodyMedium),
          ),
          if (!readOnly)
            Expanded(
              flex: 2,
              child: Center(
                child: Transform.scale(
                  scale: 0.9,
                  child: Checkbox(
                    value: allOn,
                    activeColor: AppTheme.accentCyan,
                    onChanged: (v) => onToggleAll(resource, v ?? false),
                  ),
                ),
              ),
            ),
          ...PermissionAction.values.map((action) {
            final enabled = resource.supportedActions.contains(action);
            final on = isOn(action);
            return Expanded(
              flex: 2,
              child: Center(
                child: enabled
                    ? _Toggle(
                        value: on,
                        readOnly: readOnly,
                        onChanged: (v) => onToggle(resource, action, v),
                      )
                    : const Text('—',
                        style: TextStyle(color: AppTheme.textSubtle)),
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// A compact cyan toggle (switch-like) for a single permission.
class _Toggle extends StatelessWidget {
  final bool value;
  final bool readOnly;
  final ValueChanged<bool> onChanged;

  const _Toggle({
    required this.value,
    required this.readOnly,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: readOnly ? null : () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 40,
        height: 22,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(11),
          color: value ? AppTheme.accentCyan : AppTheme.bgElevated,
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 150),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 18,
            height: 18,
            margin: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _SystemBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}

/// Thin wrapper that reuses the app card styling for the matrix.
class CalotexCardShell extends StatelessWidget {
  final Widget child;
  const CalotexCardShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.cardDecoration(),
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: child,
    );
  }
}
