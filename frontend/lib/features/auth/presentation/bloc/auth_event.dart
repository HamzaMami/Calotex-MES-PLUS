/// Base class for all authentication events.
sealed class AuthEvent {
  const AuthEvent();
}

/// Check if user is already logged in (on app startup).
final class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Login with email and password.
final class LoginSubmitted extends AuthEvent {
  final String email;
  final String password;

  const LoginSubmitted({required this.email, required this.password});
}

/// Register a new user account.
final class RegisterSubmitted extends AuthEvent {
  final String name;
  final String email;
  final String password;

  const RegisterSubmitted({
    required this.name,
    required this.email,
    required this.password,
  });
}

/// Logout the current user.
final class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

/// Refresh the access token.
final class TokenRefreshRequested extends AuthEvent {
  const TokenRefreshRequested();
}
