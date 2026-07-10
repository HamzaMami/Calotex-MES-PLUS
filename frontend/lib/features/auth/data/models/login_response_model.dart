import 'user_model.dart';

/// Login response model for JSON serialization.
/// Maps the backend authentication response containing tokens and user data.
class LoginResponseModel {
  final String accessToken;
  final String refreshToken;
  final int expiresIn; // Token validity duration in seconds
  final UserModel user;
  final String tokenType; // Usually "Bearer"

  LoginResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.user,
    this.tokenType = 'Bearer',
  });

  /// Create LoginResponseModel from JSON response.
  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      accessToken: json['access_token'] as String? ?? json['token'] as String? ?? '',
      refreshToken: json['refresh_token'] as String? ?? '',
      expiresIn: json['expires_in'] as int? ?? 3600,
      tokenType: json['token_type'] as String? ?? 'Bearer',
      user: json['user'] != null
          ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
          : UserModel(
              id: '',
              email: '',
              firstName: '',
              lastName: '',
              role: 'user',
              createdAt: DateTime.now(),
            ),
    );
  }

  /// Convert LoginResponseModel to JSON.
  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'expires_in': expiresIn,
      'token_type': tokenType,
      'user': user.toJson(),
    };
  }

  /// Calculate token expiry datetime from current time.
  DateTime get expiresAt => DateTime.now().add(Duration(seconds: expiresIn));

  /// Copy with method for immutability patterns.
  LoginResponseModel copyWith({
    String? accessToken,
    String? refreshToken,
    int? expiresIn,
    UserModel? user,
    String? tokenType,
  }) {
    return LoginResponseModel(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      expiresIn: expiresIn ?? this.expiresIn,
      user: user ?? this.user,
      tokenType: tokenType ?? this.tokenType,
    );
  }

  @override
  String toString() {
    String mask(String token) =>
        token.length > 10 ? '${token.substring(0, 10)}...' : '***';
    return '''LoginResponseModel(
    accessToken: ${mask(accessToken)},
    refreshToken: ${mask(refreshToken)},
    expiresIn: $expiresIn,
    user: ${user.email},
    tokenType: $tokenType,
  )''';
  }
}
