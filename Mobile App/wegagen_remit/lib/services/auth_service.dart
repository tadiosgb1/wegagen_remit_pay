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

  // Login
  Future<AuthResponse> login(String email, String pin) async {
    try {
      print('DEBUG: Starting login process for email: $email');
      
      // Ensure ApiService is initialized
      if (!_apiService.isInitialized) {
        await _apiService.initialize();
      }
      
      print('DEBUG: Making API call to login endpoint');
      final response = await _apiService.post(UrlContainer.login, {
        'email': email,
        'pin': pin,
      }, includeAuth: false);

      print('DEBUG: API call successful, response received: $response');
      print('DEBUG: Starting AuthResponse.fromJson parsing...');
      
      final authResponse = AuthResponse.fromJson(response);
      print('DEBUG: AuthResponse.fromJson completed successfully');
      print('DEBUG: Parsed user: ${authResponse.user}');
      print('DEBUG: Parsed access token: ${authResponse.accessToken}');

      // Store token and user data
      print('DEBUG: Starting _storeAuthData...');
      await _storeAuthData(authResponse);
      print('DEBUG: _storeAuthData completed successfully');

      print('DEBUG: Login process completed successfully');
      return authResponse;
    } catch (e, stackTrace) {
      print('DEBUG: Login failed with error: $e');
      print('DEBUG: Stack trace: $stackTrace');
      throw _handleAuthError(e);
    }
  }

  // Register
  Future<AuthResponse> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required String pin,
    required String confirmPin,
    String? referralCode,
  }) async {
    try {
      // Ensure ApiService is initialized
      if (!_apiService.isInitialized) {
        await _apiService.initialize();
      }
      
      if (kDebugMode) print('DEBUG: Making registration API call to ${UrlContainer.register}');
      final requestData = {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone_number': phoneNumber,
        'pin': pin,
        if (referralCode != null) 'referral_code': referralCode,
      };
      if (kDebugMode) print('DEBUG: Request data: $requestData');

      final response = await _apiService.post(
        UrlContainer.register,
        requestData,
        includeAuth: false,
      );

      if (kDebugMode) print('DEBUG: API Response: $response');

      final authResponse = AuthResponse.fromJson(response);
      if (kDebugMode) print('DEBUG: Parsed AuthResponse - User: ${authResponse.user}');

      // Store token and user data
      await _storeAuthData(authResponse);

      return authResponse;
    } catch (e) {
      if (kDebugMode) print('DEBUG: Registration error: $e');
      throw _handleAuthError(e);
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      // Ensure ApiService is initialized
      if (!_apiService.isInitialized) {
        await _apiService.initialize();
      }
      
      // Call server logout endpoint to clear HTTP-only cookies
      await _apiService.post(UrlContainer.logout, {});
    } catch (e) {
      // Continue with logout even if API call fails
      if (kDebugMode) print('Logout API call failed: $e');
    } finally {
      // Clear local auth data and cookies
      await _clearAuthData();
    }
  }

  // Refresh token
  Future<AuthResponse> refreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refresh_token');

      if (refreshToken == null) {
        throw AuthException('No refresh token available');
      }

      final response = await _apiService.post(UrlContainer.refreshToken, {
        'refresh_token': refreshToken,
      }, includeAuth: false);

      final authResponse = AuthResponse.fromJson(response);
      await _storeAuthData(authResponse);

      return authResponse;
    } catch (e) {
      await _clearAuthData();
      throw _handleAuthError(e);
    }
  }

  // Forgot password
  Future<void> forgotPassword(String email) async {
    try {
      await _apiService.post(UrlContainer.forgotPassword, {
        'email': email,
      }, includeAuth: false);
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Reset password
  Future<void> resetPassword({
    required String email,
    required String token,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      await _apiService.post(UrlContainer.resetPassword, {
        'email': email,
        'token': token,
        'password': password,
        'password_confirmation': confirmPassword,
      }, includeAuth: false);
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Verify email
  Future<void> verifyEmail(String token) async {
    try {
      await _apiService.post(UrlContainer.verifyEmail, {'token': token});
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Resend verification email
  Future<void> resendVerificationEmail() async {
    try {
      await _apiService.post(UrlContainer.resendVerification, {});
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Forgot PIN
  Future<ApiResponse> forgotPin(String email) async {
    try {
      final response = await _apiService.post(UrlContainer.forgotPin, {
        'email': email,
      }, includeAuth: false);

      return ApiResponse.fromJson(response);
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Verify OTP
  Future<ApiResponse> verifyOtp(String email, String otp) async {
    try {
      final response = await _apiService.post(UrlContainer.verifyOtp, {
        'email': email,
        'otp': otp,
      }, includeAuth: false);

      return ApiResponse.fromJson(response);
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Reset PIN
  Future<ApiResponse> resetPin(String email, String newPin) async {
    try {
      final response = await _apiService.post(UrlContainer.resetPin, {
        'email': email,
        'newPin': newPin,
      }, includeAuth: false);

      return ApiResponse.fromJson(response);
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Get current user
  Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user_data');

      print('DEBUG: getCurrentUser - stored userJson: $userJson');

      if (userJson != null) {
        final user = User.fromJson(userJson);
        print('DEBUG: getCurrentUser - parsed user: $user');
        return user;
      }

      print('DEBUG: getCurrentUser - no user data found');
      return null;
    } catch (e) {
      print('DEBUG: getCurrentUser - error: $e');
      return null;
    }
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;

    if (kIsWeb) {
      // For web, rely on HTTP-only cookies and login state
      // The server will validate the HTTP-only cookie automatically
      return isLoggedIn;
    } else {
      // For mobile, check both token and login state
      final token = prefs.getString('auth_token');
      return token != null || isLoggedIn;
    }
  }

  // Store auth data
  Future<void> _storeAuthData(AuthResponse authResponse) async {
    final prefs = await SharedPreferences.getInstance();

    print('DEBUG: Storing auth data...');
    print('DEBUG: Access token: ${authResponse.accessToken}');
    print('DEBUG: User to store: ${authResponse.user}');
    print('DEBUG: User JSON to store: ${authResponse.user.toJson()}');

    // Store user data and login state
    await prefs.setString('user_data', authResponse.user.toJson());
    await prefs.setBool('is_logged_in', true);

    // For mobile apps, store tokens only if they're not placeholder values
    // For web with HTTP-only cookies, we rely on cookies set by the server
    if (!kIsWeb && authResponse.accessToken != 'http-only-cookie') {
      await prefs.setString('auth_token', authResponse.accessToken);
      await prefs.setString('refresh_token', authResponse.refreshToken);
      // Set token in API service for mobile
      _apiService.setAuthToken(authResponse.accessToken);
    } else {
      print('DEBUG: Using HTTP-only cookie authentication - no token storage needed');
    }

    print('DEBUG: Auth data stored successfully');
  }

  // Clear auth data
  Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();

    // Clear user data and login state
    await prefs.remove('user_data');
    await prefs.setBool('is_logged_in', false);

    // For mobile, also clear tokens and cookies
    if (!kIsWeb) {
      await prefs.remove('auth_token');
      await prefs.remove('refresh_token');
      // Clear token and cookies from API service
      await _apiService.clearAuthToken();
    }
    // For web, HTTP-only cookies will be cleared by the server on logout
  }

  // Handle auth errors
  AuthException _handleAuthError(dynamic error) {
    if (error is ApiException) {
      return AuthException(error.message);
    }
    return AuthException('Authentication failed');
  }
}

class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final User user;
  final String tokenType;
  final int expiresIn;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
    required this.tokenType,
    required this.expiresIn,
  });



  factory AuthResponse.fromJson(Map<String, dynamic> json) {
  // 1. Safely navigate the nested structure without aggressive casting
  // We look for 'data' key, if it's not a Map, we stop drilling.
  final dynamic dataLevel1 = json['data'];
  
  // 2. If 'data' exists and is a map, look for inner 'data'
  final Map<String, dynamic> finalData = (dataLevel1 is Map && dataLevel1['data'] is Map) 
      ? dataLevel1['data'] 
      : (dataLevel1 is Map ? dataLevel1 : json);

  // 3. Extract user
  final Map<String, dynamic> userData = (finalData['user'] is Map) 
      ? finalData['user'] 
      : (finalData is Map ? finalData : {});

  return AuthResponse(
    accessToken: '', // Cookies handle this
    refreshToken: '',
    user: User.fromMap(userData),
    tokenType: 'Bearer',
    expiresIn: 3600,
  );
}

  
}

class ApiResponse {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;

  ApiResponse({required this.success, required this.message, this.data});

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      success: json['status'] == 'success' || json['success'] == true,
      message: json['message'] ?? json['msg'] ?? 'Operation completed',
      data: json['data'],
    );
  }
}

class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}
