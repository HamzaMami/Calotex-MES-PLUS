import '../../domain/entities/user_entity.dart';

/// Base class for all authentication states.
sealed class AuthState {
  const AuthState();
}

/// Initial state before any authentication check.
final class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading state during authentication operation.
final class AuthLoading extends AuthState {
  const AuthLoading();
}

/// User is authenticated - holds user data.
final class Authenticated extends AuthState {
  final UserEntity user;

  const Authenticated({required this.user});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Authenticated && runtimeType == other.runtimeType && user == other.user;

  @override
  int get hashCode => user.hashCode;
}

/// User is not authenticated.
final class Unauthenticated extends AuthState {
  const Unauthenticated();
}

/// Authentication failed with error message.
final class AuthFailureState extends AuthState {
  final String errorMessage;

  const AuthFailureState({required this.errorMessage});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthFailureState &&
          runtimeType == other.runtimeType &&
          errorMessage == other.errorMessage;

  @override
  int get hashCode => errorMessage.hashCode;
}
