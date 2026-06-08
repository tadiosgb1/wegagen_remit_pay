import 'package:flutter/material.dart';
import '../models/kyc_data.dart';
import '../services/kyc_service.dart';

class KycProvider with ChangeNotifier {
  final KycService _kycService = KycService();
  
  KycStatus _kycStatus = KycStatus.notStarted;
  bool _isLoading = false;
  String? _error;

  KycStatus get kycStatus => _kycStatus;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> loadKycStatus() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _kycStatus = await _kycService.getKycStatus();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
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

  Future<KycSubmissionResponse> submitKyc(KycData kycData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _kycService.submitKyc(kycData);
      
      if (response.success) {
        _kycStatus = response.status;
      }
      
      _isLoading = false;
      notifyListeners();
      return response;
    } catch (e) {
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
}