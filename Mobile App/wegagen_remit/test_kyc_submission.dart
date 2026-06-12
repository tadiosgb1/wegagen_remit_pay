import 'dart:io';
import 'package:flutter/foundation.dart';
import 'lib/services/kyc_service.dart';
import 'lib/models/kyc_data.dart';
import 'package:image_picker/image_picker.dart';

/// Quick test to verify KYC submission functionality
/// Run this with: dart test_kyc_submission.dart
void main() async {
  print('🧪 Testing KYC Submission Functionality\n');
  
  try {
    final kycService = KycService();
    
    print('1. Testing KYC Status Check...');
    final status = await kycService.getKycStatus();
    print('✅ Current KYC Status: $status\n');
    
    print('2. Testing KYC Data Validation...');
    
    // Test incomplete KYC data
    final incompleteKyc = KycData(
      idType: '',
      dob: '',
      address: '',
      city: '',
      country: '',
    );
    
    print('📝 Incomplete KYC validation:');
    print('   Is complete: ${incompleteKyc.isComplete}');
    print('   Missing fields: ${incompleteKyc.missingFields}');
    
    // Test complete KYC data (without actual files for testing)
    final completeKyc = KycData(
      idType: 'passport',
      dob: '1990-01-01',
      address: '123 Test Street',
      city: 'Test City',
      country: 'Test Country',
      // Note: In real usage, you'd have actual XFile objects here
      // idPhoto: XFile('path/to/id.jpg'),
      // selfie: XFile('path/to/selfie.jpg'),
    );
    
    print('\n📝 Complete KYC data (without files):');
    print('   Data: ${completeKyc.toJson()}');
    print('   Form data: ${completeKyc.toFormData()}');
    print('   Is complete: ${completeKyc.isComplete}');
    print('   Missing fields: ${completeKyc.missingFields}');
    
    print('\n3. Testing KYC Submission (dry run)...');
    
    // Test with incomplete data
    final incompleteResult = await kycService.submitKyc(incompleteKyc);
    print('❌ Incomplete submission result:');
    print('   Success: ${incompleteResult.success}');
    print('   Message: ${incompleteResult.message}');
    print('   Status: ${incompleteResult.status}');
    
  } catch (e, stackTrace) {
    print('❌ Test failed: $e');
    print('Stack trace: $stackTrace');
  }
  
  print('\n📋 KYC Submission Requirements:');
  print('✓ All text fields must be filled');
  print('✓ ID photo must be provided');
  print('✓ Selfie photo must be provided');
  print('✓ Backend must be running at the configured URL');
  print('✓ User must be authenticated');
  
  print('\n📱 To test with real files:');
  print('1. Use ImagePicker to select photos in your app');
  print('2. Create KycData with actual XFile objects');
  print('3. Call kycService.submitKyc(kycData)');
  print('4. Check the response for success/failure');
  
  exit(0);
}