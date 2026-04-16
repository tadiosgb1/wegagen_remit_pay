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
      final response = await _apiService.post(
        UrlContainer.login,
        {
          'email': email,
          'pin': pin,
        },
        includeAuth: false,
      );

      final authResponse = AuthResponse.fromJson(response);
      
      // Store token and user data
      await _storeAuthData(authResponse);
      
      return authResponse;
    } catch (e) {
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
      final response = await _apiService.post(
        UrlContainer.register,
        {
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'phone_number': phoneNumber,
          'pin': pin,
          'pin_confirmation': confirmPin,
          if (referralCode != null) 'referral_code': referralCode,
        },
        includeAuth: false,
      );

      final authResponse = AuthResponse.fromJson(response);
      
      // Store token and user data
      await _storeAuthData(authResponse);
      
      return authResponse;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _apiService.post(UrlContainer.logout, {});
    } catch (e) {
      // Continue with logout even if API call fails
    } finally {
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

      final response = await _apiService.post(
        UrlContainer.refreshToken,
        {'refresh_token': refreshToken},
        includeAuth: false,
      );

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
      await _apiService.post(
        UrlContainer.forgotPassword,
        {'email': email},
        includeAuth: false,
      );
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
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Verify email
  Future<void> verifyEmail(String token) async {
    try {
      await _apiService.post(
        UrlContainer.verifyEmail,
        {'token': token},
      );
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

  // Get current user
  Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user_data');
      
      if (userJson != null) {
        return User.fromJson(userJson);
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return token != null;
  }

  // Store auth data
  Future<void> _storeAuthData(AuthResponse authResponse) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setString('auth_token', authResponse.accessToken);
    await prefs.setString('refresh_token', authResponse.refreshToken);
    await prefs.setString('user_data', authResponse.user.toJson());
    await prefs.setBool('is_logged_in', true);
    
    // Set token in API service
    _apiService.setAuthToken(authResponse.accessToken);
  }

  // Clear auth data
  Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.remove('auth_token');
    await prefs.remove('refresh_token');
    await prefs.remove('user_data');
    await prefs.setBool('is_logged_in', false);
    
    // Clear token from API service
    _apiService.clearAuthToken();
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
    return AuthResponse(
      accessToken: json['access_token'] ?? '',
      refreshToken: json['refresh_token'] ?? '',
      user: User.fromMap(json['user'] ?? {}),
      tokenType: json['token_type'] ?? 'Bearer',
      expiresIn: json['expires_in'] ?? 3600,
    );
  }
}

class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}