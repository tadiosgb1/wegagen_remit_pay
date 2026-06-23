import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/url_container.dart';
import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiService _apiService = ApiService();

  // ================= LOGIN =================
  Future<AuthResponse> login(String email, String pin) async {
    if (!_apiService.isInitialized) {
      await _apiService.initialize();
    }

    final res = await _apiService.post(
      UrlContainer.login,
      {'email': email, 'pin': pin},
      includeAuth: false,
    );

    final auth = AuthResponse.fromJson(res);
    await _storeAuth(auth);

    return auth;
  }

  // ================= CHECK EMAIL EXISTS =================
  Future<bool> checkEmailExists(String email) async {
    if (!_apiService.isInitialized) {
      await _apiService.initialize();
    }

    try {
      final res = await _apiService.post(
        UrlContainer.checkEmail,
        {'email': email},
        includeAuth: false,
      );

      // Expected response: {"status":"success", "data":{"exists":true}}
      if (res is Map<String, dynamic>) {
        final data = res['data'] as Map<String, dynamic>?;
        return data?['exists'] ?? false;
      }
      return false;
    } catch (e) {
      print('❌ DEBUG: checkEmailExists failed: $e');
      rethrow;
    }
  }

  // ================= REGISTER =================
 // ================= REGISTER =================
Future<AuthResponse> register({
  required String firstName,
  required String lastName,
  required String email,
  required String phoneNumber,
  required String pin,
  required String confirmPin,
  String? referralCode,
}) async {
  if (!_apiService.isInitialized) {
    await _apiService.initialize();
  }

  // 1. Prepare ONLY the fields the backend validator expects.
  // 2. Map to 'snake_case' as required by your backend.
  // 3. Removed 'confirm_pin' because the server explicitly forbids it.
  final Map<String, dynamic> requestBody = {
    'first_name': firstName,
    'last_name': lastName,
    'email': email,
    'phone_number': phoneNumber,
    'pin': pin,
  };

  // Only add referral_code if it is provided
  if (referralCode != null && referralCode.isNotEmpty) {
    requestBody['referral_code'] = referralCode;
  }

  print("DEBUG: Sending payload to backend: $requestBody");

  // Perform the request
  final res = await _apiService.post(
    UrlContainer.register,
    requestBody,
    includeAuth: false, // Registration usually doesn't require a token
  );

  final auth = AuthResponse.fromJson(res);
  await _storeAuth(auth);

  return auth;
}

  // ================= LOGOUT =================
  Future<void> logout() async {
    try {
      await _apiService.post(UrlContainer.logout, {});
    } catch (_) {}

    await _clearAuth();
  }

  // ================= REFRESH TOKEN =================
  Future<AuthResponse> refreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refresh = prefs.getString('refresh_token');

    final res = await _apiService.post(
      UrlContainer.refreshToken,
      {'refresh_token': refresh},
      includeAuth: false,
    );

    final auth = AuthResponse.fromJson(res);
    await _storeAuth(auth);

    return auth;
  }

  // ================= FORGOT PASSWORD =================
  Future<void> forgotPassword(String email) async {
    await _apiService.post(
      UrlContainer.forgotPassword,
      {'email': email},
      includeAuth: false,
    );
  }

  // ================= RESET PASSWORD =================
  Future<void> resetPassword({
    required String email,
    required String token,
    required String password,
    required String confirmPassword,
  }) async {
    await _apiService.post(
      UrlContainer.resetPassword,
      {
        'email': email,
        'token': token,
        'password': password,
        'password_confirmation': confirmPassword,
      },
      includeAuth: false,
    );
  }

  // ================= VERIFY EMAIL =================
  Future<void> verifyEmail(String token) async {
    await _apiService.post(
      UrlContainer.verifyEmail,
      {'token': token},
    );
  }

  // ================= RESEND EMAIL =================
  Future<void> resendVerificationEmail() async {
    await _apiService.post(
      UrlContainer.resendVerification,
      {},
    );
  }

  // ================= FORGOT PIN =================
  Future<ApiResponse> forgotPin(String email) async {
    final res = await _apiService.post(
      UrlContainer.forgotPin,
      {'email': email},
      includeAuth: false,
    );

    return ApiResponse.fromJson(res);
  }

  // ================= VERIFY OTP =================
  Future<ApiResponse> verifyOtp(String email, String otp) async {
    final res = await _apiService.post(
      UrlContainer.verifyOtp,
      {'email': email, 'otp': otp},
      includeAuth: false,
    );

    return ApiResponse.fromJson(res);
  }

  // ================= RESET PIN =================
  Future<ApiResponse> resetPin(String email, String newPin) async {
    final res = await _apiService.post(
      UrlContainer.resetPin,
      {'email': email, 'newPin': newPin},
      includeAuth: false,
    );

    return ApiResponse.fromJson(res);
  }

  // ================= GET USER =================
  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('user_data');

    if (json == null) return null;

    return User.fromJson(json);
  }

  // ================= AUTH CHECK =================
  Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }

  // ================= STORE AUTH =================
  Future<void> _storeAuth(AuthResponse auth) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('user_data', auth.user.toJson());
    await prefs.setBool('is_logged_in', true);

    // With cookie authentication, tokens are handled by the backend
    // Just store for reference/debugging if needed
    if (auth.accessToken.isNotEmpty) {
      await prefs.setString('auth_token', auth.accessToken);
      await prefs.setString('refresh_token', auth.refreshToken);
    }

    if (kDebugMode) {
      print("✅ AUTH STORED - Cookie authentication active");
    }
  }

  // ================= CLEAR AUTH =================
  Future<void> _clearAuth() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('user_data');
    await prefs.remove('auth_token');
    await prefs.remove('refresh_token');
    await prefs.setBool('is_logged_in', false);

    // Clear cookies instead of tokens
    await _apiService.clearCookies();
    
    if (kDebugMode) {
      print("✅ AUTH CLEARED - Cookies cleared");
    }
  }
}

// ================= RESPONSE MODELS =================

class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final User user;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map ? json['data'] : json;

    return AuthResponse(
      accessToken: data['access_token'] ?? '',
      refreshToken: data['refresh_token'] ?? '',
      user: User.fromMap(data['user'] ?? {}),
    );
  }
}

class ApiResponse {
  final bool success;
  final String message;
  final dynamic data;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      success: json['success'] ?? true,
      message: json['message'] ?? '',
      data: json['data'],
    );
  }
}