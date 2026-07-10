import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure token storage service using flutter_secure_storage.
/// Handles persistence of JWT tokens with encryption.
class TokenStorageService {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenExpiryKey = 'token_expiry';

  final FlutterSecureStorage _secureStorage;

  TokenStorageService({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  /// Save both access and refresh tokens along with expiry timestamp.
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required DateTime expiresAt,
  }) async {
    try {
      await Future.wait([
        _secureStorage.write(key: _accessTokenKey, value: accessToken),
        _secureStorage.write(key: _refreshTokenKey, value: refreshToken),
        _secureStorage.write(
          key: _tokenExpiryKey,
          value: expiresAt.toIso8601String(),
        ),
      ]);
    } catch (e) {
      throw TokenStorageException('Failed to save tokens: $e');
    }
  }

  /// Retrieve the access token.
  Future<String?> getAccessToken() async {
    try {
      return await _secureStorage.read(key: _accessTokenKey);
    } catch (e) {
      throw TokenStorageException('Failed to read access token: $e');
    }
  }

  /// Retrieve the refresh token.
  Future<String?> getRefreshToken() async {
    try {
      return await _secureStorage.read(key: _refreshTokenKey);
    } catch (e) {
      throw TokenStorageException('Failed to read refresh token: $e');
    }
  }

  /// Retrieve token expiry timestamp.
  Future<DateTime?> getTokenExpiry() async {
    try {
      final expiryString = await _secureStorage.read(key: _tokenExpiryKey);
      if (expiryString == null) return null;
      return DateTime.parse(expiryString);
    } catch (e) {
      throw TokenStorageException('Failed to read token expiry: $e');
    }
  }

  /// Check if token is expired (with 30-second buffer).
  Future<bool> isTokenExpired() async {
    try {
      final expiry = await getTokenExpiry();
      if (expiry == null) return true;
      
      // Add 30-second buffer to refresh slightly before actual expiry
      return DateTime.now().isAfter(expiry.subtract(Duration(seconds: 30)));
    } catch (e) {
      throw TokenStorageException('Failed to check token expiry: $e');
    }
  }

  /// Clear all stored tokens.
  Future<void> clearTokens() async {
    try {
      await Future.wait([
        _secureStorage.delete(key: _accessTokenKey),
        _secureStorage.delete(key: _refreshTokenKey),
        _secureStorage.delete(key: _tokenExpiryKey),
      ]);
    } catch (e) {
      throw TokenStorageException('Failed to clear tokens: $e');
    }
  }

  /// Check if tokens exist (quick validation).
  Future<bool> hasTokens() async {
    try {
      final accessToken = await getAccessToken();
      return accessToken != null && accessToken.isNotEmpty;
    } catch (e) {
      throw TokenStorageException('Failed to check token existence: $e');
    }
  }
}

/// Custom exception for token storage errors.
class TokenStorageException implements Exception {
  final String message;

  TokenStorageException(this.message);

  @override
  String toString() => 'TokenStorageException: $message';
}
