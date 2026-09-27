import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Secure token storage service.
///
/// Uses [FlutterSecureStorage] on mobile/desktop and falls back to
/// [SharedPreferences] on the web, where secure storage is unreliable.
class TokenStorageService {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenExpiryKey = 'token_expiry';

  final FlutterSecureStorage _secureStorage;

  TokenStorageService({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _webPrefs async =>
      _prefs ??= await SharedPreferences.getInstance();

  /// Save both access and refresh tokens along with expiry timestamp.
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required DateTime expiresAt,
  }) async {
    try {
      if (kIsWeb) {
        final prefs = await _webPrefs;
        await Future.wait([
          prefs.setString(_accessTokenKey, accessToken),
          prefs.setString(_refreshTokenKey, refreshToken),
          prefs.setString(_tokenExpiryKey, expiresAt.toIso8601String()),
        ]);
        return;
      }
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
      if (kIsWeb) {
        final prefs = await _webPrefs;
        return prefs.getString(_accessTokenKey);
      }
      return await _secureStorage.read(key: _accessTokenKey);
    } catch (e) {
      throw TokenStorageException('Failed to read access token: $e');
    }
  }

  /// Retrieve the refresh token.
  Future<String?> getRefreshToken() async {
    try {
      if (kIsWeb) {
        final prefs = await _webPrefs;
        return prefs.getString(_refreshTokenKey);
      }
      return await _secureStorage.read(key: _refreshTokenKey);
    } catch (e) {
      throw TokenStorageException('Failed to read refresh token: $e');
    }
  }

  /// Retrieve token expiry timestamp.
  Future<DateTime?> getTokenExpiry() async {
    try {
      final expiryString = kIsWeb
          ? (await _webPrefs).getString(_tokenExpiryKey)
          : await _secureStorage.read(key: _tokenExpiryKey);
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
      if (kIsWeb) {
        final prefs = await _webPrefs;
        await Future.wait([
          prefs.remove(_accessTokenKey),
          prefs.remove(_refreshTokenKey),
          prefs.remove(_tokenExpiryKey),
        ]);
        return;
      }
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
