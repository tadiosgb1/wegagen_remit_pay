import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

/// Mobile-optimized 3DS enrollment payload for CyberSource
/// Uses real device data for mobile apps
class Mobile3DSPayload {
  static Map<String, dynamic> createEnrollmentPayload({
    required String customerId,
    required String referenceId,
    required double amount,
    required String currency,
    required Map<String, dynamic> billingInfo,
    required Map<String, dynamic> deviceData,
    String? merchantId,
    bool forceChallenge = false,
  }) {
    return {
      "clientReferenceInformation": {
        "code": referenceId,
        "partner": {
          "developerId": _getDynamicDeveloperId(),
          "solutionId": _getDynamicSolutionId(deviceData)
        }
      },
      "orderInformation": {
        "amountDetails": {
          "currency": currency,
          "totalAmount": amount.toStringAsFixed(2)
        },
        "billTo": {
          "address1": billingInfo['address1'] ?? _getDefaultAddress(),
          "locality": billingInfo['locality'] ?? _getDefaultCity(),
          "administrativeArea":
              billingInfo['administrative_area'] ?? _getDefaultState(),
          "country": billingInfo['country'] ?? _getDefaultCountry(),
          "firstName": billingInfo['first_name'] ?? _getRandomFirstName(),
          "lastName": billingInfo['last_name'] ?? _getRandomLastName(),
          "phoneNumber": billingInfo['phone_number'] ?? _getRandomPhoneNumber(),
          "email": billingInfo['email'] ?? _getRandomEmail(),
          "postalCode": billingInfo['postal_code'] ?? _getRandomPostalCode(),
        }
      },
      "paymentInformation": {
        "customer": {
          "customerId": customerId,
        }
      },
      "deviceInformation": _buildDynamicMobileDeviceInfo(deviceData),
      "consumerAuthenticationInformation":
          _buildDynamic3DSInfo(deviceData, forceChallenge),
      "merchantInformation": {"merchantName": "Wegagen Bank Remit Service"},
    };
  }

  /// Dynamic mobile-specific device information based on actual device
  static Map<String, dynamic> _buildDynamicMobileDeviceInfo(
      Map<String, dynamic> deviceData) {
    final isAndroid = deviceData['mobileDeviceType'] == 'android';
    final isIOS = deviceData['mobileDeviceType'] == 'ios';

    return {
      // Dynamic IP based on testing environment
      "ipAddress": _getDynamicIP(),

      // Real device user agent
      "userAgentBrowserValue":
          deviceData['browserUserAgent'] ?? _buildFallbackUserAgent(deviceData),

      // Dynamic browser fields adapted for mobile testing
      "httpAcceptBrowserValue": _getDynamicAcceptHeader(isAndroid, isIOS),
      "httpBrowserLanguage":
          deviceData['browserLanguage'] ?? _getDynamicLanguage(),
      "httpBrowserJavaEnabled": false, // Always false for mobile
      "httpBrowserJavaScriptEnabled": true, // Flutter uses JS engine
      "httpBrowserColorDepth":
          deviceData['browserColorDepth'] ?? _getDynamicColorDepth(),
      "httpBrowserScreenHeight": deviceData['browserScreenHeight'] ??
          _getDynamicScreenHeight(deviceData),
      "httpBrowserScreenWidth": deviceData['browserScreenWidth'] ??
          _getDynamicScreenWidth(deviceData),
      "httpBrowserTimeDifference":
          deviceData['browserTimeZone'] ?? _getDynamicTimezone(),

      // Dynamic mobile-specific raw data
      "rawData": [
        {
          "data": jsonEncode(_buildDynamicRawData(deviceData)),
          "provider": "wegagen_mobile_${_getDeviceIdentifier(deviceData)}"
        }
      ]
    };
  }

  /// Dynamic 3DS authentication information with risk variations
  static Map<String, dynamic> _buildDynamic3DSInfo(
      Map<String, dynamic> deviceData, bool forceChallenge) {
    final challengePreference =
        forceChallenge ? "01" : _getDynamicChallengePreference(deviceData);

    return {
      // Dynamic device channel
      "deviceChannel": _getDynamicDeviceChannel(deviceData),

      // Dynamic transaction mode
      "transactionMode": _getDynamicTransactionMode(deviceData),

      // Dynamic challenge preferences
      "challengePreference": challengePreference,
      "challengeWindowSize": _getDynamicWindowSize(deviceData),

      // Dynamic app information
      "appUrl": _getDynamicAppUrl(deviceData),
      "appName": "Wegagen Remit",

      // Dynamic reference ID
      "referenceId": _generateDynamicReferenceId(deviceData),

      // Dynamic mobile authentication data
      "mobilePhone": _getDynamicPhoneNumber(deviceData),
      "mobileAppType": "flutter",
      "mobileDeviceFingerprint": _generateDynamicFingerprint(deviceData),

      // Dynamic return URL
      "returnUrl": _getDynamicReturnUrl(deviceData),

      // Dynamic risk indicators
      "messageCategory": _getDynamicMessageCategory(deviceData),
      "merchantScore": _getDynamicMerchantScore(deviceData),

      // Dynamic browser info for 3DS (required fields)
      "browserAcceptHeader": _getDynamicAcceptHeader(
          deviceData['mobileDeviceType'] == 'android',
          deviceData['mobileDeviceType'] == 'ios'),
      "browserColorDepth": deviceData['browserColorDepth'] ?? "24",
      "browserJavaEnabled": false,
      "browserJavaScriptEnabled": true,
      "browserLanguage": deviceData['browserLanguage'] ?? _getDynamicLanguage(),
      "browserScreenHeight": deviceData['browserScreenHeight'] ??
          _getDynamicScreenHeight(deviceData),
      "browserScreenWidth": deviceData['browserScreenWidth'] ??
          _getDynamicScreenWidth(deviceData),
      "browserTimeZone": deviceData['browserTimeZone'] ?? _getDynamicTimezone(),
      "browserUserAgent":
          deviceData['browserUserAgent'] ?? _buildFallbackUserAgent(deviceData),
    };
  }

  // Dynamic helper methods for different testing scenarios
  static String _getDynamicDeveloperId() {
    return "N2RC3Q4K"; // Your actual developer ID
  }

  static String _getDynamicSolutionId(Map<String, dynamic> deviceData) {
    final platform = deviceData['mobileDeviceType'] ?? 'unknown';
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return "wegagen_remit_${platform}_$timestamp";
  }

  static String _getDynamicIP() {
    // Mobile apps don't have access to their external IP address
    // Always use unknown IP indicator for mobile apps
    return "0.0.0.0"; // Standard "unknown IP" for mobile apps
  }

  static String _getDynamicAcceptHeader(bool isAndroid, bool isIOS) {
    if (isAndroid) {
      return "application/json,text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8";
    } else if (isIOS) {
      return "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8";
    }
    return "application/json,*/*";
  }

  static String _getDynamicLanguage() {
    // Vary language based on time for testing
    final languages = ["en-US", "en-GB", "am-ET", "or-ET", "ti-ET"];
    return languages[DateTime.now().second % languages.length];
  }

  static String _getDynamicColorDepth() {
    final depths = ["24", "32", "16"];
    return depths[DateTime.now().millisecond % depths.length];
  }

  static String _getDynamicScreenHeight(Map<String, dynamic> deviceData) {
    // Use actual device data or generate realistic mobile dimensions
    return deviceData['browserScreenHeight'] ??
        "${800 + (DateTime.now().millisecond % 600)}";
  }

  static String _getDynamicScreenWidth(Map<String, dynamic> deviceData) {
    return deviceData['browserScreenWidth'] ??
        "${375 + (DateTime.now().millisecond % 250)}";
  }

  static String _getDynamicTimezone() {
    // Ethiopian timezone is +3 (180 minutes), but vary for testing
    final timezones = ["180", "0", "60", "120", "240", "300", "-300", "480"];
    return timezones[DateTime.now().minute % timezones.length];
  }

  static String _getDynamicDeviceChannel(Map<String, dynamic> deviceData) {
    return "APP"; // Always APP for mobile
  }

  static String _getDynamicTransactionMode(Map<String, dynamic> deviceData) {
    return "APP_BASED";
  }

  static String _getDynamicChallengePreference(
      Map<String, dynamic> deviceData) {
    // Dynamic challenge preference based on testing scenarios
    final hour = DateTime.now().hour;
    final amount = deviceData['amount'] ?? 0.0;

    // Force challenge during business hours or for higher amounts
    if (hour >= 9 && hour <= 17 || amount >= 50.0) {
      return "01"; // Force challenge
    }

    // Vary challenge preference for different testing
    final preferences = ["01", "02", "03"];
    return preferences[DateTime.now().second % preferences.length];
  }

  static String _getDynamicWindowSize(Map<String, dynamic> deviceData) {
    // Adapt window size based on screen dimensions
    final screenWidth =
        int.tryParse(deviceData['browserScreenWidth'] ?? '400') ?? 400;

    if (screenWidth > 600) {
      return "04"; // Larger window for tablets (600x400)
    } else if (screenWidth > 500) {
      return "03"; // Medium-large (500x600)
    } else {
      return "02"; // Standard mobile (390x400)
    }
  }

  static String _getDynamicAppUrl(Map<String, dynamic> deviceData) {
    final platform = deviceData['mobileDeviceType'] ?? 'unknown';
    final sessionId = DateTime.now().millisecondsSinceEpoch;
    return "wegagen://remit?platform=$platform&session=$sessionId";
  }

  static String _generateDynamicReferenceId(Map<String, dynamic> deviceData) {
    final platform = (deviceData['mobileDeviceType'] ?? 'mob').toUpperCase();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return "${platform}_3DS_$timestamp";
  }

  static String? _getDynamicPhoneNumber(Map<String, dynamic> deviceData) {
    // Generate realistic international phone numbers
    // since Wegagen Remit is used globally by Ethiopian diaspora
    final globalPrefixes = [
      "+1555", // USA/Canada (common for testing)
      "+44207", // UK London
      "+966555", // Saudi Arabia
      "+971555", // UAE Dubai
      "+251911", // Ethiopia (Ethio Telecom)
      "+251922", // Ethiopia (Ethio Telecom)
      "+251944", // Ethiopia (Safaricom)
      "+49555", // Germany
      "+46555", // Sweden
      "+33555", // France
      "+39555", // Italy
      "+61555", // Australia
      "+27555", // South Africa
    ];

    final prefix =
        globalPrefixes[DateTime.now().second % globalPrefixes.length];
    final number =
        (1000000 + (DateTime.now().microsecond % 9000000)).toString();
    return "$prefix$number";
  }

  static String _getDynamicReturnUrl(Map<String, dynamic> deviceData) {
    final platform = deviceData['mobileDeviceType'] ?? 'mobile';
    final sessionId = DateTime.now().millisecondsSinceEpoch;
    return "https://cybersource.wegagenbanksc.com.et:3001/payments/3ds/$platform/return?session=$sessionId";
  }

  static String _getDynamicMessageCategory(Map<String, dynamic> deviceData) {
    return "01"; // Payment authentication
  }

  static int _getDynamicMerchantScore(Map<String, dynamic> deviceData) {
    // Dynamic risk score based on device and transaction characteristics
    int score = 50; // Base score

    // Adjust based on device characteristics
    if (deviceData['isPhysicalDevice'] == 'debug')
      score += 15; // Debug mode = higher risk
    if (deviceData['mobileDeviceType'] == 'android') score += 3;
    if (deviceData['mobileDeviceType'] == 'ios')
      score -= 5; // iOS slightly lower risk

    // Adjust based on time (simulate different risk patterns)
    final hour = DateTime.now().hour;
    if (hour >= 22 || hour <= 6) score += 10; // Late night = higher risk
    if (hour >= 9 && hour <= 17) score -= 5; // Business hours = lower risk

    return score.clamp(1, 99);
  }

  static Map<String, dynamic> _buildDynamicRawData(
      Map<String, dynamic> deviceData) {
    return {
      "deviceChannel": "mobile_app",
      "deviceType": "mobile",
      "mobileDeviceType": deviceData['mobileDeviceType'] ?? 'unknown',
      "appVersion": deviceData['appVersion'] ?? '1.0.0',
      "osVersion": deviceData['osVersion'] ?? 'unknown',
      "deviceModel": deviceData['deviceModel'] ?? 'unknown',
      "deviceManufacturer": deviceData['deviceManufacturer'] ?? 'unknown',
      "screenDensity": deviceData['screenDensity'] ?? '1.0',
      "isPhysicalDevice": deviceData['isPhysicalDevice'] ?? 'unknown',
      "timestamp": DateTime.now().toIso8601String(),
      "sessionId": _generateSessionId(deviceData),
      "locale": deviceData['locale'] ?? Platform.localeName,
      "timezone": DateTime.now().timeZoneName,
      "isDebugMode": kDebugMode.toString(),
    };
  }

  static String _generateSessionId(Map<String, dynamic> deviceData) {
    final deviceId = (deviceData['deviceId'] ?? 'unknown').toString();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final hash = deviceId.hashCode.abs();
    return "sess_${hash}_$timestamp";
  }

  static String _getDeviceIdentifier(Map<String, dynamic> deviceData) {
    final deviceType = deviceData['mobileDeviceType'] ?? 'unk';
    final model = (deviceData['deviceModel'] ?? 'device').toString();
    return "${deviceType}_${model}"
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]'), '_');
  }

  static String _buildFallbackUserAgent(Map<String, dynamic> deviceData) {
    final platform = deviceData['mobileDeviceType'] ?? 'Mobile';
    final version = deviceData['appVersion'] ?? '1.0.0';
    final osVersion = deviceData['osVersion'] ?? 'Unknown';
    final model = deviceData['deviceModel'] ?? 'Device';

    return "WegagenRemitApp/$version (Flutter; $platform $osVersion; $model)";
  }

  // Dynamic default values for missing billing info (Ethiopian context)
  static String _getDefaultAddress() {
    final addresses = [
      "Kazanchis Business Center",
      "Bole Road Atlas Building",
      "Megenagna CMC Area",
      "Addis Ababa Stadium Area"
    ];
    return addresses[DateTime.now().second % addresses.length];
  }

  static String _getDefaultCity() {
    final cities = [
      "Addis Ababa",
      "Dire Dawa",
      "Mekelle",
      "Gondar",
      "Bahir Dar"
    ];
    return cities[DateTime.now().second % cities.length];
  }

  static String _getDefaultState() {
    final states = ["AA", "DD", "TG", "AM", "BG"];
    return states[DateTime.now().second % states.length];
  }

  static String _getDefaultCountry() {
    return "ET"; // Ethiopia
  }

  static String _getRandomFirstName() {
    final names = [
      "Abebe",
      "Almaz",
      "Bekele",
      "Hanan",
      "Dawit",
      "Meron",
      "Tadele",
      "Senait"
    ];
    return names[DateTime.now().microsecond % names.length];
  }

  static String _getRandomLastName() {
    final names = [
      "Tadesse",
      "Kebede",
      "Haile",
      "Desta",
      "Tekle",
      "Girma",
      "Worku",
      "Tesema"
    ];
    return names[DateTime.now().microsecond % names.length];
  }

  static String _getRandomPhoneNumber() {
    // Global phone numbers for Wegagen Remit users worldwide
    final globalPrefixes = [
      "+1555", // USA/Canada
      "+44207", // UK London
      "+966555", // Saudi Arabia
      "+971555", // UAE Dubai
      "+251911", // Ethiopia (Ethio Telecom)
      "+251922", // Ethiopia (Ethio Telecom)
      "+251944", // Ethiopia (Safaricom)
      "+49555", // Germany
      "+46555", // Sweden
      "+33555", // France
      "+39555", // Italy
      "+61555", // Australia
    ];

    final prefix =
        globalPrefixes[DateTime.now().second % globalPrefixes.length];
    final number = (100000 + DateTime.now().microsecond % 900000).toString();
    return "$prefix$number";
  }

  static String _getRandomEmail() {
    final domains = ["test.et", "example.com", "demo.wegagen.et"];
    final firstName = _getRandomFirstName().toLowerCase();
    final domain = domains[DateTime.now().second % domains.length];
    final timestamp = DateTime.now().millisecondsSinceEpoch % 1000;
    return "$firstName.test$timestamp@$domain";
  }

  static String _getRandomPostalCode() {
    return (10000 + DateTime.now().microsecond % 90000).toString();
  }

  /// Generate dynamic mobile device fingerprint with enhanced data
  static String _generateDynamicFingerprint(Map<String, dynamic> deviceData) {
    final fingerprint = {
      'device_type': deviceData['mobileDeviceType'],
      'app_version': deviceData['appVersion'],
      'os_version': deviceData['osVersion'],
      'screen_size':
          '${deviceData['browserScreenWidth'] ?? '400'}x${deviceData['browserScreenHeight'] ?? '800'}',
      'timezone': deviceData['browserTimeZone'] ?? '180', // Ethiopian timezone
      'language': deviceData['browserLanguage'] ?? 'am-ET',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'session': _generateSessionId(deviceData),
      'platform_specific': _getPlatformSpecificData(deviceData),
      'risk_indicators': _getRiskIndicators(deviceData),
    };

    return base64Encode(utf8.encode(jsonEncode(fingerprint)));
  }

  static Map<String, dynamic> _getPlatformSpecificData(
      Map<String, dynamic> deviceData) {
    if (deviceData['mobileDeviceType'] == 'android') {
      return {
        'sdk_version': deviceData['sdkVersion'] ?? 'unknown',
        'manufacturer': deviceData['deviceManufacturer'] ?? 'unknown',
        'brand': deviceData['deviceBrand'] ?? 'unknown',
        'model': deviceData['deviceModel'] ?? 'unknown',
      };
    } else if (deviceData['mobileDeviceType'] == 'ios') {
      return {
        'system_name': deviceData['systemName'] ?? 'iOS',
        'system_version': deviceData['systemVersion'] ?? 'unknown',
        'localized_model': deviceData['localizedModel'] ?? 'iPhone',
        'identifier_for_vendor': deviceData['deviceId'] ?? 'unknown',
      };
    }
    return {'platform': 'unknown'};
  }

  static Map<String, dynamic> _getRiskIndicators(
      Map<String, dynamic> deviceData) {
    return {
      'is_emulator': deviceData['isPhysicalDevice'] != 'release',
      'debug_mode': kDebugMode,
      'device_age_estimate': _estimateDeviceAge(deviceData),
      'screen_ratio': _calculateScreenRatio(deviceData),
      'timezone_match': _checkTimezoneMatch(deviceData),
    };
  }

  static String _estimateDeviceAge(Map<String, dynamic> deviceData) {
    // Simple estimation based on OS version
    final osVersion = deviceData['osVersion'] ?? '';
    if (osVersion.contains('13') || osVersion.contains('14')) return 'new';
    if (osVersion.contains('11') || osVersion.contains('12')) return 'medium';
    return 'old';
  }

  static double _calculateScreenRatio(Map<String, dynamic> deviceData) {
    final width =
        double.tryParse(deviceData['browserScreenWidth'] ?? '400') ?? 400;
    final height =
        double.tryParse(deviceData['browserScreenHeight'] ?? '800') ?? 800;
    return height / width;
  }

  static bool _checkTimezoneMatch(Map<String, dynamic> deviceData) {
    final deviceTimezone = deviceData['browserTimeZone'] ?? '0';
    return deviceTimezone == '180'; // Ethiopian timezone offset
  }
}
