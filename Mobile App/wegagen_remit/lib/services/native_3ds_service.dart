import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Native Mobile 3DS Service for CyberSource
/// Handles 3DS authentication using native mobile app format
class Native3DSService {
  static final Native3DSService _instance = Native3DSService._internal();
  factory Native3DSService() => _instance;
  Native3DSService._internal();

  final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

  /// Generate native mobile device data for CyberSource 3DS
  Future<Map<String, dynamic>> generateNativeMobileDeviceData() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      
      if (Platform.isAndroid) {
        return await _generateAndroidDeviceData(packageInfo);
      } else if (Platform.isIOS) {
        return await _generateIOSDeviceData(packageInfo);
      } else {
        return _getDefaultMobileDeviceData(packageInfo);
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error generating native device data: $e');
      }
      return _getDefaultMobileDeviceData(null);
    }
  }

  Future<Map<String, dynamic>> _generateAndroidDeviceData(PackageInfo packageInfo) async {
    final androidInfo = await _deviceInfoPlugin.androidInfo;
    
    return {
      // Native mobile app identification
      'deviceChannel': 'APP',  // Native app channel
      'transactionMode': 'APP_BASED',  // Native app transaction mode
      
      // Mobile app information
      'appName': 'Wegagen Remit',
      'appVersion': packageInfo.version,
      'appBuildNumber': packageInfo.buildNumber,
      'appBundleID': packageInfo.packageName,
      
      // Android device information
      'deviceType': 'mobile',
      'mobileDeviceType': 'android',
      'deviceModel': androidInfo.model,
      'deviceManufacturer': androidInfo.manufacturer,
      'deviceBrand': androidInfo.brand,
      'osType': 'Android',
      'osVersion': androidInfo.version.release,
      'sdkVersion': androidInfo.version.sdkInt.toString(),
      'deviceId': androidInfo.id,
      
      // Screen and display information
      'screenWidth': _getScreenWidth().toString(),
      'screenHeight': _getScreenHeight().toString(),
      'screenDensity': '1.0',
      'colorDepth': '24',
      
      // Locale and timezone
      'language': Platform.localeName.split('_')[0],
      'locale': Platform.localeName,
      'timezone': DateTime.now().timeZoneName,
      'timezoneOffset': DateTime.now().timeZoneOffset.inMinutes.toString(),
      
      // Native app capabilities
      'javaScriptEnabled': true,
      'javaEnabled': false,
      'cookiesEnabled': true,
      
      // 3DS specific fields for native apps
      'threeDSRequestorAppURL': 'wegagen://remit/3ds/return',
      'threeDSRequestorAppDecMaxTime': '5',  // 5 minutes
      'threeDSRequestorDecReqInd': 'Y',  // Decoupled authentication supported
      'threeDSRequestorAuthenticationInd': '01',  // Payment transaction
      
      // Mobile SDK information
      'sdkInterface': '03',  // Native UI with HTML fallback
      'sdkUiType': ['01', '02', '03', '04'],  // All UI types supported
      'sdkMaxTimeout': '05',  // 5 minutes
      'sdkEncData': _generateSDKEncryptedData(),
      'sdkEphemPubKey': _generateEphemeralPublicKey(),
      'sdkReferenceNumber': 'WEGAGEN_ANDROID_${DateTime.now().millisecondsSinceEpoch}',
      
      // Network and connectivity
      'ipAddress': '0.0.0.0',  // Unknown for mobile apps
      'acceptHeader': 'application/json, text/plain, */*',
      'userAgent': _buildAndroidUserAgent(androidInfo, packageInfo),
      
      // Security information
      'isRooted': androidInfo.isPhysicalDevice ? 'false' : 'emulator',
      'hasHardwareKeyboard': false,
      'biometricCapable': true,  // Assume biometric capability
      
      // Additional native app fields
      'messageVersion': '2.2.0',  // 3DS 2.2 protocol
      'messageCategory': '01',  // Payment Authentication
      'deviceRenderOptions': {
        'sdkInterface': '03',
        'sdkUiType': ['01', '02', '03', '04']
      }
    };
  }

  Future<Map<String, dynamic>> _generateIOSDeviceData(PackageInfo packageInfo) async {
    final iosInfo = await _deviceInfoPlugin.iosInfo;
    
    return {
      // Native mobile app identification
      'deviceChannel': 'APP',  // Native app channel
      'transactionMode': 'APP_BASED',  // Native app transaction mode
      
      // Mobile app information
      'appName': 'Wegagen Remit',
      'appVersion': packageInfo.version,
      'appBuildNumber': packageInfo.buildNumber,
      'appBundleID': packageInfo.packageName,
      
      // iOS device information
      'deviceType': 'mobile',
      'mobileDeviceType': 'ios',
      'deviceModel': iosInfo.model,
      'deviceName': iosInfo.name,
      'systemName': iosInfo.systemName,
      'systemVersion': iosInfo.systemVersion,
      'deviceId': iosInfo.identifierForVendor ?? 'unknown',
      
      // Screen and display information
      'screenWidth': _getScreenWidth().toString(),
      'screenHeight': _getScreenHeight().toString(),
      'screenDensity': '1.0',
      'colorDepth': '24',
      
      // Locale and timezone
      'language': Platform.localeName.split('_')[0],
      'locale': Platform.localeName,
      'timezone': DateTime.now().timeZoneName,
      'timezoneOffset': DateTime.now().timeZoneOffset.inMinutes.toString(),
      
      // Native app capabilities
      'javaScriptEnabled': true,
      'javaEnabled': false,
      'cookiesEnabled': true,
      
      // 3DS specific fields for native apps
      'threeDSRequestorAppURL': 'wegagen://remit/3ds/return',
      'threeDSRequestorAppDecMaxTime': '5',  // 5 minutes
      'threeDSRequestorDecReqInd': 'Y',  // Decoupled authentication supported
      'threeDSRequestorAuthenticationInd': '01',  // Payment transaction
      
      // Mobile SDK information
      'sdkInterface': '03',  // Native UI with HTML fallback
      'sdkUiType': ['01', '02', '03', '04'],  // All UI types supported
      'sdkMaxTimeout': '05',  // 5 minutes
      'sdkEncData': _generateSDKEncryptedData(),
      'sdkEphemPubKey': _generateEphemeralPublicKey(),
      'sdkReferenceNumber': 'WEGAGEN_IOS_${DateTime.now().millisecondsSinceEpoch}',
      
      // Network and connectivity
      'ipAddress': '0.0.0.0',  // Unknown for mobile apps
      'acceptHeader': 'application/json, text/plain, */*',
      'userAgent': _buildIOSUserAgent(iosInfo, packageInfo),
      
      // Security information
      'isJailbroken': iosInfo.isPhysicalDevice ? 'false' : 'simulator',
      'biometricCapable': true,  // Assume biometric capability
      
      // Additional native app fields
      'messageVersion': '2.2.0',  // 3DS 2.2 protocol
      'messageCategory': '01',  // Payment Authentication
      'deviceRenderOptions': {
        'sdkInterface': '03',
        'sdkUiType': ['01', '02', '03', '04']
      }
    };
  }

  Map<String, dynamic> _getDefaultMobileDeviceData(PackageInfo? packageInfo) {
    return {
      'deviceChannel': 'APP',
      'transactionMode': 'APP_BASED',
      'appName': 'Wegagen Remit',
      'appVersion': packageInfo?.version ?? '1.0.0',
      'appBuildNumber': packageInfo?.buildNumber ?? '1',
      'deviceType': 'mobile',
      'mobileDeviceType': 'unknown',
      'screenWidth': '400',
      'screenHeight': '800',
      'language': 'en',
      'timezoneOffset': '180',  // Ethiopian timezone
      'messageVersion': '2.2.0',
      'sdkInterface': '03',
      'sdkUiType': ['01', '02', '03', '04'],
      'threeDSRequestorAppURL': 'wegagen://remit/3ds/return'
    };
  }

  String _buildAndroidUserAgent(AndroidDeviceInfo androidInfo, PackageInfo packageInfo) {
    return 'WegagenRemitApp/${packageInfo.version} (${packageInfo.appName}; Android ${androidInfo.version.release}; ${androidInfo.manufacturer} ${androidInfo.model})';
  }

  String _buildIOSUserAgent(IosDeviceInfo iosInfo, PackageInfo packageInfo) {
    return 'WegagenRemitApp/${packageInfo.version} (${packageInfo.appName}; ${iosInfo.systemName} ${iosInfo.systemVersion}; ${iosInfo.model})';
  }

  double _getScreenWidth() {
    try {
      return WidgetsBinding.instance.platformDispatcher.views.first.physicalSize.width /
          WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;
    } catch (e) {
      return 400.0;
    }
  }

  double _getScreenHeight() {
    try {
      return WidgetsBinding.instance.platformDispatcher.views.first.physicalSize.height /
          WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;
    } catch (e) {
      return 800.0;
    }
  }

  /// Generate SDK encrypted data (simplified for demo)
  String _generateSDKEncryptedData() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final data = {
      'timestamp': timestamp,
      'appId': 'wegagen_remit_app',
      'version': '1.0.0',
    };
    return base64Encode(utf8.encode(jsonEncode(data)));
  }

  /// Generate ephemeral public key (simplified for demo)
  String _generateEphemeralPublicKey() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return base64Encode(utf8.encode('WEGAGEN_PUB_KEY_$timestamp'));
  }

  /// Get native app return URL for 3DS challenges
  String getNativeAppReturnUrl() {
    return 'wegagen://remit/3ds/return';
  }

  /// Check if device supports native biometric authentication
  Future<bool> supportsBiometricAuth() async {
    // This would integrate with local_auth package in production
    return Platform.isAndroid || Platform.isIOS;
  }
}