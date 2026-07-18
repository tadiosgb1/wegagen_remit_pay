import 'dart:async';
import 'package:flutter/material.dart';

class SessionTimeoutService {
  static final SessionTimeoutService _instance = SessionTimeoutService._internal();
  factory SessionTimeoutService() => _instance;
  SessionTimeoutService._internal();

  Timer? _sessionTimer;
  Timer? _warningTimer;
  VoidCallback? _onTimeout;
  
  // Session timeout duration (15 minutes for better UX)
  static const Duration _timeoutDuration = Duration(minutes: 15);
  
  bool _isActive = false;
  VoidCallback? _onWarning;
  DateTime? _lastActivity;

  /// Start the session timeout timer
  void startSession({
    required VoidCallback onTimeout,
    VoidCallback? onWarning,
  }) {
    _onTimeout = onTimeout;
    _onWarning = onWarning;
    _isActive = true;
    _lastActivity = DateTime.now();
    _resetTimer();
  }

  /// Reset the session timer (call this on meaningful user activity)
  void resetTimer() {
    if (_isActive) {
      _lastActivity = DateTime.now();
      _resetTimer();
    }
  }

  /// Stop the session timeout
  void stopSession() {
    _isActive = false;
    _sessionTimer?.cancel();
    _warningTimer?.cancel();
    _sessionTimer = null;
    _warningTimer = null;
    _onTimeout = null;
    _onWarning = null;
    _lastActivity = null;
  }

  /// Check if session is active
  bool get isActive => _isActive;

  /// Get time since last activity
  Duration? get timeSinceLastActivity {
    if (_lastActivity == null) return null;
    return DateTime.now().difference(_lastActivity!);
  }

  void _resetTimer() {
    _sessionTimer?.cancel();
    _warningTimer?.cancel();
    
    if (!_isActive) return;

    // Set timer for warning (13 minutes)
    _warningTimer = Timer(Duration(minutes: 13), () {
      if (_isActive && _onWarning != null) {
        _onWarning!();
      }
    });

    // Set timer for timeout (15 minutes)
    _sessionTimer = Timer(_timeoutDuration, () {
      if (_isActive && _onTimeout != null) {
        _onTimeout!();
      }
    });
  }
}