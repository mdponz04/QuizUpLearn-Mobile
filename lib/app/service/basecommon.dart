import 'dart:developer';
import 'package:quizkahoot/app/model/login_response.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BaseCommon {
  // Singleton instance
  static BaseCommon? _instance;
  static BaseCommon get instance {
    _instance ??= BaseCommon._internal();
    return _instance!;
  }

  // Private constructor
  BaseCommon._internal();

  // Token storage keys
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenExpiryKey = 'token_expiry';
  static const String _refreshTokenExpiryKey = 'refresh_token_expiry';
  static const String _userInfoKey = 'user_info';
  String userId = ''; 
  // SharedPreferences instance
  SharedPreferences? _prefs;

  /// Initialize SharedPreferences
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    log('BaseCommon initialized');
  }

  /// Save access token
  Future<bool> saveAccessToken(String token) async {
    await _ensureInitialized();
    final result = await _prefs!.setString(_accessTokenKey, token);
    log('Access token saved: ${result ? 'success' : 'failed'}');
    return result;
  }

  /// Get access token
  Future<String?> getAccessToken() async {
    await _ensureInitialized();
    final token = _prefs!.getString(_accessTokenKey);
    log('Access token retrieved: ${token != null ? 'exists' : 'null'}');
    return token;
  }

  /// Save refresh token
  Future<bool> saveRefreshToken(String token) async {
    await _ensureInitialized();
    final result = await _prefs!.setString(_refreshTokenKey, token);
    log('Refresh token saved: ${result ? 'success' : 'failed'}');
    return result;
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    await _ensureInitialized();
    final token = _prefs!.getString(_refreshTokenKey);
    log('Refresh token retrieved: ${token != null ? 'exists' : 'null'}');
    return token;
  }

  /// Save token expiry time
  Future<bool> saveTokenExpiry(DateTime expiry) async {
    await _ensureInitialized();
    final result = await _prefs!.setString(_tokenExpiryKey, expiry.toIso8601String());
    log('Token expiry saved: ${expiry.toIso8601String()}');
    return result;
  }

  /// Get token expiry time
  Future<DateTime?> getTokenExpiry() async {
    await _ensureInitialized();
    final expiryString = _prefs!.getString(_tokenExpiryKey);
    if (expiryString != null) {
      try {
        final expiry = DateTime.parse(expiryString);
        log('Token expiry retrieved: ${expiry.toIso8601String()}');
        return expiry;
      } catch (e) {
        log('Error parsing token expiry: $e');
        return null;
      }
    }
    return null;
  }

  /// Save refresh token expiry time
  Future<bool> saveRefreshTokenExpiry(DateTime expiry) async {
    await _ensureInitialized();
    final result = await _prefs!.setString(_refreshTokenExpiryKey, expiry.toIso8601String());
    log('Refresh token expiry saved: ${expiry.toIso8601String()}');
    return result;
  }

  /// Get refresh token expiry time
  Future<DateTime?> getRefreshTokenExpiry() async {
    await _ensureInitialized();
    final expiryString = _prefs!.getString(_refreshTokenExpiryKey);
    if (expiryString != null) {
      try {
        final expiry = DateTime.parse(expiryString);
        log('Refresh token expiry retrieved: ${expiry.toIso8601String()}');
        return expiry;
      } catch (e) {
        log('Error parsing refresh token expiry: $e');
        return null;
      }
    }
    return null;
  }

  /// Save user information
  Future<bool> saveUserInfo(Map<String, dynamic> userInfo) async {
    await _ensureInitialized();
    final userInfoJson = userInfo.toString();
    final result = await _prefs!.setString(_userInfoKey, userInfoJson);
    log('User info saved: ${result ? 'success' : 'failed'}');
    return result;
  }

  /// Get user information
  Future<Map<String, dynamic>?> getUserInfo() async {
    await _ensureInitialized();
    final userInfoString = _prefs!.getString(_userInfoKey);
    if (userInfoString != null) {
      try {
        // Parse the string representation back to Map
        // Note: This is a simple implementation, you might want to use JSON encoding/decoding
        log('User info retrieved: exists');
        return {}; // Return empty map for now, implement proper parsing as needed
      } catch (e) {
        log('Error parsing user info: $e');
        return null;
      }
    }
    return null;
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final accessToken = await getAccessToken();
    final tokenExpiry = await getTokenExpiry();
    
    if (accessToken == null || tokenExpiry == null) {
      return false;
    }
    
    // Check if token is expired
    final now = DateTime.now();
    final isExpired = now.isAfter(tokenExpiry);
    
    log('User login status: ${!isExpired ? 'logged in' : 'token expired'}');
    return !isExpired;
  }

  /// Check if access token is expired
  Future<bool> isAccessTokenExpired() async {
    final tokenExpiry = await getTokenExpiry();
    if (tokenExpiry == null) return true;
    
    final now = DateTime.now();
    final isExpired = now.isAfter(tokenExpiry);
    log('Access token expired: $isExpired');
    return isExpired;
  }

  /// Check if refresh token is expired
  Future<bool> isRefreshTokenExpired() async {
    final refreshTokenExpiry = await getRefreshTokenExpiry();
    if (refreshTokenExpiry == null) return true;
    
    final now = DateTime.now();
    final isExpired = now.isAfter(refreshTokenExpiry);
    log('Refresh token expired: $isExpired');
    return isExpired;
  }

  /// Clear all tokens and user data
  Future<bool> clearAllTokens() async {
    await _ensureInitialized();
    final result = await _prefs!.clear();
    log('All tokens cleared: ${result ? 'success' : 'failed'}');
    return result;
  }

  /// Clear only access token
  Future<bool> clearAccessToken() async {
    await _ensureInitialized();
    final result = await _prefs!.remove(_accessTokenKey);
    log('Access token cleared: ${result ? 'success' : 'failed'}');
    return result;
  }

  /// Clear only refresh token
  Future<bool> clearRefreshToken() async {
    await _ensureInitialized();
    final result = await _prefs!.remove(_refreshTokenKey);
    log('Refresh token cleared: ${result ? 'success' : 'failed'}');
    return result;
  }

  /// Get authorization header value
  Future<String?> getAuthorizationHeader() async {
    final accessToken = await getAccessToken();
    if (accessToken != null) {
      return 'Bearer $accessToken';
    }
    return null;
  }

  /// Save complete authentication data
  Future<bool> saveAuthData({
    required String accessToken,
    required String refreshToken,
    required DateTime accessTokenExpiry,
    required DateTime refreshTokenExpiry,
    Map<String, dynamic>? userInfo,
  }) async {
    await _ensureInitialized();
    
    final results = await Future.wait([
      saveAccessToken(accessToken),
      saveRefreshToken(refreshToken),
      saveTokenExpiry(accessTokenExpiry),
      saveRefreshTokenExpiry(refreshTokenExpiry),
      if (userInfo != null) saveUserInfo(userInfo) else Future.value(true),
    ]);
    
    final allSuccess = results.every((result) => result == true);
    log('Auth data saved: ${allSuccess ? 'success' : 'failed'}');
    return allSuccess;
  }

  /// Ensure SharedPreferences is initialized
  Future<void> _ensureInitialized() async {
    if (_prefs == null) {
      await init();
    }
  }
}