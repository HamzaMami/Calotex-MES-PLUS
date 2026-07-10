
/// User entity - pure business object representing a logged-in user.
/// No framework dependencies, used throughout the domain layer.
class UserEntity {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? avatar;
  final String role;
  final DateTime createdAt;

  UserEntity({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.avatar,
    required this.role,
    required this.createdAt,
  });

  /// Get full name.
  String get fullName => '$firstName $lastName'.trim();

  @override
  String toString() => 'UserEntity(id: $id, email: $email, role: $role)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email &&
          role == other.role;

  @override
  int get hashCode => id.hashCode ^ email.hashCode ^ role.hashCode;
}
