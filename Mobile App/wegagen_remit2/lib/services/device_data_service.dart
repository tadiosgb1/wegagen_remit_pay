import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

class DeviceDataService {
  static final DeviceDataService _instance = DeviceDataService._internal();
  factory DeviceDataService() => _instance;
  DeviceDataService._internal();

  final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

  /// Collect device data for 3DS authentication
  /// This replaces browser info for native mobile apps
  Future<Map<String, dynamic>> collectDeviceData() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();

      if (Platform.isAndroid) {
        return await _collectAndroidDeviceData(packageInfo);
      } else if (Platform.isIOS) {
        return await _collectIOSDeviceData(packageInfo);
      } else {
        return _getDefaultDeviceData(packageInfo);
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error collecting device data: $e');
      }
      return _getDefaultDeviceData(null);
    }
  }

  Future<Map<String, dynamic>> _collectAndroidDeviceData(
      PackageInfo packageInfo) async {
    final androidInfo = await _deviceInfoPlugin.androidInfo;

    return {
      // CyberSource required fields for mobile
      'browserUserAgent': _buildAndroidUserAgent(androidInfo, packageInfo),
      'browserLanguage': Platform.localeName.split('_')[0],
      'browserAcceptHeader': 'application/json,*/*',
      'browserColorDepth': '24',
      'browserScreenHeight': _getScreenHeight().toString(),
      'browserScreenWidth': _getScreenWidth().toString(),
      'browserTimeZone': DateTime.now().timeZoneOffset.inMinutes.toString(),
      'javaEnabled': false,

      // Mobile-specific fields
      'deviceChannel': 'mobile_app',
      'deviceType': 'mobile',
      'mobileDeviceType': 'android',
      'appVersion': packageInfo.version,
      'appBuildNumber': packageInfo.buildNumber,

      // Android device information
      'deviceModel': androidInfo.model,
      'deviceManufacturer': androidInfo.manufacturer,
      'deviceBrand': androidInfo.brand,
      'osVersion': androidInfo.version.release,
      'sdkVersion': androidInfo.version.sdkInt.toString(),
      'deviceId': androidInfo.id, // Android ID

      // Security information
      'isRooted': androidInfo.isPhysicalDevice ? 'unknown' : 'emulator',
      'hasHardwareKeyboard':
          androidInfo.systemFeatures.contains('android.hardware.type.pc'),

      // Display information
      'screenDensity': '1.0', // Simplified - density property not available
      'screenSize':
          '${androidInfo.displayMetrics.widthPx}x${androidInfo.displayMetrics.heightPx}',
    };
  }

  Future<Map<String, dynamic>> _collectIOSDeviceData(
      PackageInfo packageInfo) async {
    final iosInfo = await _deviceInfoPlugin.iosInfo;

    return {
      // CyberSource required fields for mobile
      'browserUserAgent': _buildIOSUserAgent(iosInfo, packageInfo),
      'browserLanguage': Platform.localeName.split('_')[0],
      'browserAcceptHeader': 'application/json,*/*',
      'browserColorDepth': '24',
      'browserScreenHeight': _getScreenHeight().toString(),
      'browserScreenWidth': _getScreenWidth().toString(),
      'browserTimeZone': DateTime.now().timeZoneOffset.inMinutes.toString(),
      'javaEnabled': false,

      // Mobile-specific fields
      'deviceChannel': 'mobile_app',
      'deviceType': 'mobile',
      'mobileDeviceType': 'ios',
      'appVersion': packageInfo.version,
      'appBuildNumber': packageInfo.buildNumber,

      // iOS device information
      'deviceModel': iosInfo.model,
      'deviceName': iosInfo.name,
      'systemName': iosInfo.systemName,
      'systemVersion': iosInfo.systemVersion,
      'deviceId': iosInfo.identifierForVendor ?? 'unknown',

      // iOS-specific information
      'isJailbroken': iosInfo.isPhysicalDevice ? 'unknown' : 'simulator',
      'localizedModel': iosInfo.localizedModel,
      'utsname': '${iosInfo.utsname.machine} ${iosInfo.utsname.release}',
    };
  }

  Map<String, dynamic> _getDefaultDeviceData(PackageInfo? packageInfo) {
    return {
      'browserUserAgent': _buildDefaultUserAgent(packageInfo),
      'browserLanguage': 'en_US',
      'browserAcceptHeader': 'application/json,*/*',
      'browserColorDepth': '24',
      'browserScreenHeight': '800',
      'browserScreenWidth': '400',
      'browserTimeZone': '0',
      'javaEnabled': false,
      'deviceChannel': 'mobile_app',
      'deviceType': 'mobile',
      'mobileDeviceType': 'unknown',
      'appVersion': packageInfo?.version ?? '1.0.0',
      'appBuildNumber': packageInfo?.buildNumber ?? '1',
    };
  }

  String _buildAndroidUserAgent(
      AndroidDeviceInfo androidInfo, PackageInfo packageInfo) {
    return 'WegagenRemitApp/${packageInfo.version} (${packageInfo.appName}; Android ${androidInfo.version.release}; ${androidInfo.manufacturer} ${androidInfo.model})';
  }

  String _buildIOSUserAgent(IosDeviceInfo iosInfo, PackageInfo packageInfo) {
    return 'WegagenRemitApp/${packageInfo.version} (${packageInfo.appName}; ${iosInfo.systemName} ${iosInfo.systemVersion}; ${iosInfo.model})';
  }

  String _buildDefaultUserAgent(PackageInfo? packageInfo) {
    return 'WegagenRemitApp/${packageInfo?.version ?? "1.0.0"} (Flutter; Mobile)';
  }

  double _getScreenWidth() {
    try {
      return WidgetsBinding
              .instance.platformDispatcher.views.first.physicalSize.width /
          WidgetsBinding
              .instance.platformDispatcher.views.first.devicePixelRatio;
    } catch (e) {
      return 400.0; // Default width
    }
  }

  double _getScreenHeight() {
    try {
      return WidgetsBinding
              .instance.platformDispatcher.views.first.physicalSize.height /
          WidgetsBinding
              .instance.platformDispatcher.views.first.devicePixelRatio;
    } catch (e) {
      return 800.0; // Default height
    }
  }

  /// Get device fingerprint for enhanced security
  Future<Map<String, dynamic>> getDeviceFingerprint() async {
    final deviceData = await collectDeviceData();

    return {
      ...deviceData,
      'timestamp': DateTime.now().toIso8601String(),
      'timezone': DateTime.now().timeZoneName,
      'timezoneOffset': DateTime.now().timeZoneOffset.inMinutes,
      'locale': Platform.localeName,
      'platform': Platform.operatingSystem,
      'isPhysicalDevice': kDebugMode ? 'debug' : 'release',
    };
  }

  /// For CyberSource Device Data Collection (DDC)
  Future<Map<String, dynamic>> prepareForDDC() async {
    final deviceData = await collectDeviceData();

    if (kDebugMode) {
      print('📱 Device Data for CyberSource DDC:');
      print('🔧 User Agent: ${deviceData['browserUserAgent']}');
      print(
          '📏 Screen: ${deviceData['browserScreenWidth']}x${deviceData['browserScreenHeight']}');
      print('🌍 Language: ${deviceData['browserLanguage']}');
      print('⏰ Timezone: ${deviceData['browserTimeZone']}');
      print('📱 Device Type: ${deviceData['mobileDeviceType']}');
    }

    return deviceData;
  }
}
