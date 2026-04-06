import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Mock successful login
      if (email.isNotEmpty && password.length >= 6) {
        _user = User(
          id: '1',
          firstName: 'Tesfay',
          lastName: 'Gebremichel',
          email: email,
          phoneNumber: '+251911234567',
          isVerified: true,
          createdAt: DateTime.now(),
        );

        // Save login state
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_logged_in', true);
        await prefs.setString('user_email', email);

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Invalid email or password';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Login failed. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(
    String firstName,
    String lastName,
    String email,
    String phoneNumber,
    String password,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Mock successful registration
      _user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
        isVerified: false,
        createdAt: DateTime.now(),
      );

      // Save registration state
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_logged_in', true);
      await prefs.setString('user_email', email);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Registration failed. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _user = null;
    
    // Clear saved login state
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('is_logged_in');
    await prefs.remove('user_email');
    
    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    final userEmail = prefs.getString('user_email');

    if (isLoggedIn && userEmail != null) {
      // Mock user data - in real app, fetch from API
      _user = User(
        id: '1',
        firstName: 'Tesfay',
        lastName: 'Gebremichel',
        email: userEmail,
        phoneNumber: '+251911234567',
        isVerified: true,
        createdAt: DateTime.now(),
      );
      notifyListeners();
    }
  }
}