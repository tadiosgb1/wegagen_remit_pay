import 'dart:async';
import 'package:flutter/material.dart';
import '../models/kyc_data.dart';
import '../services/kyc_service.dart';
import 'auth_provider.dart';

class KycProvider with ChangeNotifier {
  final KycService _kycService = KycService();
  
  KycStatus _kycStatus = KycStatus.notStarted;  // Reset to ensure clean state
  bool _isLoading = false;
  String? _error;
  DateTime? _lastRefresh;
  Timer? _statusCheckTimer;

  KycStatus get kycStatus {
    print('🔍 KYC PROVIDER - kycStatus getter called, returning: $_kycStatus');
    return _kycStatus;
  }
  
  /// Force reset KYC status (useful for new login sessions)
  void resetStatus() {
    print('🔄 KYC PROVIDER - Resetting status to notStarted');
    _kycStatus = KycStatus.notStarted;
    _lastRefresh = null;
    _error = null;
    stopPeriodicStatusCheck();
    notifyListeners();
  }
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastRefresh => _lastRefresh;
  bool get isPeriodicCheckingActive => _statusCheckTimer?.isActive ?? false;

  /// Check if we need to refresh (older than 30 seconds)
  bool get needsRefresh {
    if (_lastRefresh == null) return true;
    return DateTime.now().difference(_lastRefresh!).inSeconds > 30;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> loadKycStatus({AuthProvider? authProvider}) async {
    print('🔄 KYC PROVIDER - loadKycStatus called, current status: $_kycStatus');
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final previousStatus = _kycStatus;
      
      print('🔄 KYC PROVIDER - Calling KYC service...');
      // Always force refresh to get latest status from server
      _kycStatus = await _kycService.getKycStatus(forceRefresh: true);
      print('🔄 KYC PROVIDER - KYC service returned: $_kycStatus');
      
      _lastRefresh = DateTime.now();
      
      // Also refresh the AuthProvider to keep user data in sync
      if (authProvider != null) {
        await authProvider.refreshUser();
      }
      
      // Start periodic checking if KYC is pending
      if (_kycStatus == KycStatus.underReview || _kycStatus == KycStatus.inProgress) {
        startPeriodicStatusCheck(authProvider: authProvider);
      } else {
        // Stop checking if status is final
        stopPeriodicStatusCheck();
      }
      
      // Show notification if status changed to approved
      if (previousStatus != KycStatus.approved && _kycStatus == KycStatus.approved) {
        print('🎉 KYC STATUS UPDATED: Your identity verification has been approved!');
      }
      
      _isLoading = false;
      notifyListeners();
      print('🔄 KYC PROVIDER - loadKycStatus completed successfully');
    } catch (e, stackTrace) {
      print('❌ KYC PROVIDER ERROR: $e');
      print('❌ KYC PROVIDER STACK TRACE: $stackTrace');
      _error = e.toString();
      _kycStatus = KycStatus.notStarted;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateKycStatus(KycStatus status) async {
    _kycStatus = status;
    notifyListeners();
  }

  Future<KycSubmissionResponse> submitKyc(KycData kycData, {AuthProvider? authProvider}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('📤 SUBMITTING KYC - Starting submission...');
      final response = await _kycService.submitKyc(kycData);
      print('📤 KYC SUBMISSION RESPONSE: ${response.success ? "SUCCESS" : "FAILED"}');
      
      if (response.success) {
        // Immediately update status from response
        _kycStatus = response.status;
        print('📤 IMMEDIATE STATUS UPDATE: $_kycStatus');
        
        // Force refresh KYC status from server to get the latest data
        print('📤 REFRESHING STATUS FROM SERVER...');
        await loadKycStatus(authProvider: authProvider);
        print('📤 SERVER STATUS REFRESH COMPLETE: $_kycStatus');
        
        // Start periodic checking if status is now under review
        if (_kycStatus == KycStatus.underReview || _kycStatus == KycStatus.inProgress) {
          print('📤 STARTING PERIODIC STATUS MONITORING...');
          startPeriodicStatusCheck(authProvider: authProvider);
        }
      }
      
      _isLoading = false;
      notifyListeners();
      return response;
    } catch (e) {
      print('📤 KYC SUBMISSION ERROR: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return KycSubmissionResponse(
        success: false,
        message: 'Failed to submit KYC. Please try again.',
        status: KycStatus.notStarted,
      );
    }
  }

  /// Force refresh KYC status from server
  Future<void> refreshKycStatus({AuthProvider? authProvider}) async {
    await loadKycStatus(authProvider: authProvider);
  }

  /// Smart refresh - only refreshes if data is stale
  Future<void> refreshIfNeeded({AuthProvider? authProvider}) async {
    if (needsRefresh) {
      await loadKycStatus(authProvider: authProvider);
    }
  }

  /// Start periodic status checking for pending KYC
  void startPeriodicStatusCheck({AuthProvider? authProvider}) {
    // Only check if KYC is under review or in progress
    if (_kycStatus != KycStatus.underReview && _kycStatus != KycStatus.inProgress) {
      return;
    }

    _statusCheckTimer?.cancel();
    
    // Check every 30 seconds for status updates
    _statusCheckTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      if (_kycStatus == KycStatus.approved || _kycStatus == KycStatus.rejected) {
        // Stop checking once we get a final status
        timer.cancel();
        return;
      }
      
      await refreshIfNeeded(authProvider: authProvider);
    });
  }

  /// Stop periodic status checking
  void stopPeriodicStatusCheck() {
    _statusCheckTimer?.cancel();
    _statusCheckTimer = null;
  }

  @override
  void dispose() {
    _statusCheckTimer?.cancel();
    super.dispose();
  }
}