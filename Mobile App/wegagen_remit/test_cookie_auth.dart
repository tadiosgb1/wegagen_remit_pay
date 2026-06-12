import 'dart:io';
import 'package:flutter/foundation.dart';
import 'lib/services/api_service.dart';
import 'lib/services/auth_service.dart';

/// Quick test to verify HTTP-only cookie authentication
/// Run this with: flutter run test_cookie_auth.dart
void main() async {
  print('🧪 Testing HTTP-Only Cookie Authentication\n');
  
  try {
    // Initialize services
    final apiService = ApiService();
    final authService = AuthService();
    
    await apiService.initialize();
    
    print('📱 Platform: ${kIsWeb ? 'Web' : 'Mobile'}');
    print('🔗 Backend URL: ${apiService.workingBaseUrl}\n');
    
    // Test 1: Health Check
    print('1. Testing backend connectivity...');
    final isHealthy = await apiService.healthCheck();
    if (isHealthy) {
      print('✅ Backend is reachable\n');
    } else {
      print('❌ Backend is not responding\n');
      return;
    }
    
    // Test 2: Check current authentication status
    print('2. Checking current auth status...');
    final isAuth = await authService.isAuthenticated();
    print('🔐 Currently authenticated: $isAuth');
    
    if (isAuth) {
      final currentUser = await authService.getCurrentUser();
      print('👤 Current user: ${currentUser?.email ?? 'Unknown'}\n');
    } else {
      print('👤 No current user session\n');
    }
    
    // Test 3: Cookie inspection (mobile only)
    if (!kIsWeb) {
      print('3. Inspecting stored cookies...');
      final cookies = await apiService.getCookies(apiService.workingBaseUrl);
      if (cookies.isNotEmpty) {
        print('🍪 Found ${cookies.length} cookies:');
        for (final cookie in cookies) {
          print('   ${cookie.name}=${cookie.value}');
          print('   - Domain: ${cookie.domain}');
          print('   - Path: ${cookie.path}');
          print('   - HttpOnly: ${cookie.httpOnly}');
          print('   - Secure: ${cookie.secure}');
        }
      } else {
        print('🍪 No cookies found');
      }
      print('');
    }
    
    // Test 4: Try an authenticated endpoint
    print('4. Testing authenticated endpoint...');
    try {
      final response = await apiService.get('/users/me');
      print('✅ Authenticated request successful');
      print('📝 Response: ${response.toString().substring(0, 100)}...\n');
    } catch (e) {
      print('❌ Authenticated request failed: $e\n');
      
      if (e.toString().contains('401')) {
        print('💡 This suggests cookies are not being sent properly');
        print('   - For web: Check CORS configuration allows credentials');
        print('   - For mobile: Check cookie jar is working');
        print('   - Backend: Ensure HTTP-only cookies are set correctly\n');
      }
    }
    
    // Test 5: Backend requirements check
    print('5. Backend requirements for HTTP-only cookies:');
    print('   ✓ Login endpoint should set httpOnly cookie');
    print('   ✓ CORS should allow credentials: {credentials: true}');
    print('   ✓ Cookie should have sameSite: "lax" or "none"');
    print('   ✓ Protected routes should read cookie from req.cookies');
    print('   ✓ Logout should clear the cookie with res.clearCookie()');
    
  } catch (e, stackTrace) {
    print('❌ Test failed: $e');
    print('Stack trace: $stackTrace');
  }
  
  print('\n📋 Next Steps:');
  print('1. Ensure your backend sets HTTP-only cookies on login');
  print('2. Configure CORS to allow credentials');
  print('3. Test with a real login attempt');
  print('4. Use browser dev tools to verify cookie behavior on web');
  
  exit(0);
}