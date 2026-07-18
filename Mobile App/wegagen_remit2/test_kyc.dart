import 'package:flutter/material.dart';
import 'lib/services/kyc_service.dart';
import 'lib/providers/kyc_provider.dart';

void main() async {
  // Test KYC service
  final kycService = KycService();
  
  try {
    final status = await kycService.getKycStatus();
    print('KYC Status: $status');
    print('✅ KYC Service is working!');
  } catch (e) {
    print('❌ KYC Service error: $e');
  }
}