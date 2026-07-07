import 'package:flutter/foundation.dart';
import 'lib/services/three_ds_service.dart';

/// Test script to verify 3DS device data collection
void main() async {
  print('🧪 === 3DS DEVICE DATA TEST ===');
  
  final threeDSService = ThreeDSService();
  
  // Test device data collection
  try {
    // Test the public device data collection method
    final deviceData = await threeDSService.collectDeviceDataForDDC();
    
    print('📱 Collected Device Data:');
    deviceData.forEach((key, value) {
      print('   $key: $value');
    });
    
    // Check for required CyberSource fields
    final requiredFields = [
      'browserUserAgent',
      'browserLanguage', 
      'browserAcceptHeader',
      'browserColorDepth',
      'browserScreenHeight',
      'browserScreenWidth',
      'browserTimeZone',
      'browserJavaEnabled',
      'browserJavaScriptEnabled'
    ];
    
    print('\n✅ Checking Required Fields:');
    bool allPresent = true;
    for (final field in requiredFields) {
      final present = deviceData.containsKey(field) && deviceData[field] != null;
      print('   $field: ${present ? '✅' : '❌'}');
      if (!present) allPresent = false;
    }
    
    print('\n🎯 Result: ${allPresent ? 'ALL REQUIRED FIELDS PRESENT' : 'MISSING REQUIRED FIELDS'}');
    
    if (allPresent) {
      print('🔧 The device data collection is working correctly.');
      print('🔍 The issue might be in the backend mapping or CyberSource configuration.');
      print('💡 Check that your backend forwards these exact field names to CyberSource.');
    }
    
  } catch (e) {
    print('❌ Test failed: $e');
  }
}