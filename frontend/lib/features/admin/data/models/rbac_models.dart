class PermissionModel {
  final int id;
  final String name;
  final String? description;

  PermissionModel({
    required this.id,
    required this.name,
    this.description,
  });

  factory PermissionModel.fromJson(Map<String, dynamic> json) {
    return PermissionModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
    );
  }
}

class RoleModel {
  final int id;
  final String name;
  final String? description;
  final bool isSystem;
  final List<PermissionModel> permissions;

  RoleModel({
    required this.id,
    required this.name,
    this.description,
    required this.isSystem,
    this.permissions = const [],
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      isSystem: json['is_system'] as bool? ?? false,
      permissions: (json['permissions'] as List<dynamic>?)
              ?.map((e) => PermissionModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}

class UserModel {
  final int id;
  final String? name;
  final String email;
  final String status;
  final int? roleId;
  final String? roleName;
  final DateTime createdAt;

  UserModel({
    required this.id,
    this.name,
    required this.email,
    required this.status,
    this.roleId,
    this.roleName,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      name: json['name'] as String?,
      email: json['email'] as String,
      status: json['status'] as String? ?? 'pending',
      roleId: json['role_id'] as int?,
      roleName: json['role_name'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }
}
