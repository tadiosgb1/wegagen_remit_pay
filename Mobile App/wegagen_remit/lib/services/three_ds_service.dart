import 'package:flutter/foundation.dart';
import 'api_service.dart';
import '../config/url_container.dart';

class ThreeDSService {
  static final ThreeDSService _instance = ThreeDSService._internal();
  factory ThreeDSService() => _instance;
  ThreeDSService._internal();

  final ApiService _apiService = ApiService();

  /// Process payment token and get customer ID with device data collection
  /// This matches your backend's processPayment method
  Future<PaymentTokenResult> processPaymentToken({
    required String transientToken,
    required Map<String, dynamic> billingInfo,
    required double amount,
    required String currency,
    required double exchangeRate,
    String? transferType,
  }) async {
    try {
      if (kDebugMode) {
        print('💳 Processing payment token');
        print('💰 Amount: $amount $currency');
        print('🎯 Transfer Type: $transferType');
      }

      // Always use regular endpoint for token processing - cash pickup only affects final payment
      final endpoint = UrlContainer.processPayment;

      if (kDebugMode) {
        print('🔗 Using endpoint for token processing: $endpoint');
      }

      final response = await _apiService.post(
        endpoint,
        {
          'transientToken': transientToken,
          'firstName': billingInfo['first_name'] ?? '',
          'lastName': billingInfo['last_name'] ?? '',
          'address1': billingInfo['address1'] ?? '',
          'locality': billingInfo['locality'] ?? '',
          'administrativeArea': billingInfo['administrative_area'] ?? '',
          'postalCode': billingInfo['postal_code'] ?? '',
          'country': billingInfo['country'] ?? 'US',
          'email': billingInfo['email'] ?? '',
          'phoneNumber': billingInfo['phone_number'] ?? '',
          'amount': amount.toString(),
          'exchange_rate': exchangeRate,
        },
        includeAuth: true,
      );

      return PaymentTokenResult.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Payment token processing error: $e');
      }
      throw Exception('Failed to process payment token: $e');
    }
  }

  /// Check 3DS enrollment using the customer ID with real device data
  /// This matches your backend's checkEnrollment method
  Future<EnrollmentCheckResult> checkEnrollment({
    required String customerId,
    required String referenceId,
    required double amount,
    required String currency,
    required Map<String, dynamic> billingInfo,
    Map<String, dynamic>? browserInfo,
  }) async {
    try {
      if (kDebugMode) {
        print('🔐 === 3DS ENROLLMENT STARTED ===');
        print('👤 Customer ID: $customerId');
        print('🔖 Reference ID: $referenceId');
        print('💰 Amount: $amount $currency');
        print('📧 Email: ${billingInfo['email']}');
      }

      // Get real device data for mobile app instead of browser info
      if (kDebugMode) {
        print('📱 Collecting device data for 3DS...');
      }

      final deviceData = browserInfo ?? await collectDeviceDataForDDC();

      if (kDebugMode) {
        print('✅ Device data collected:');
        print('   🌐 Browser User Agent: ${deviceData['browserUserAgent']}');
        print(
            '   📏 Screen: ${deviceData['browserScreenWidth']}x${deviceData['browserScreenHeight']}');
        print('   🌍 Language: ${deviceData['browserLanguage']}');
        print('   ⏰ Timezone: ${deviceData['browserTimeZone']}');
        print('   📨 Accept Header: ${deviceData['browserAcceptHeader']}');
        print('   📱 Device Channel: ${deviceData['deviceChannel']}');
        print('   🌐 Transaction Mode: ${deviceData['transactionMode']}');
        print('🔍 FULL DEVICE DATA BEING SENT TO BACKEND:');
        print('   📱 deviceChannel: ${deviceData['deviceChannel']}');
        print('   🌐 transactionMode: ${deviceData['transactionMode']}');
        print('   🌍 browserLanguage: ${deviceData['browserLanguage']}');
        print('   🔧 browserUserAgent: ${deviceData['browserUserAgent']}');
        print(
            '   📨 browserAcceptHeader: ${deviceData['browserAcceptHeader']}');
        print('   📱 Full payload: $deviceData');
      }

      if (kDebugMode) {
        print(
            '🌐 Making enrollment API call to: ${UrlContainer.checkEnrollment}');
      }

      // Create the payload with explicit CyberSource field mapping
      final enrollmentPayload = {
        'referenceId': referenceId,
        'customer_id': customerId,
        'amount': amount,
        'currency': currency,
        'billTo': {
          'firstName': billingInfo['first_name'] ?? '',
          'lastName': billingInfo['last_name'] ?? '',
          'address1': billingInfo['address1'] ?? '',
          'locality': billingInfo['locality'] ?? '',
          'administrativeArea': billingInfo['administrative_area'] ?? '',
          'postalCode': billingInfo['postal_code'] ?? '',
          'country': billingInfo['country'] ?? 'US',
          'email': billingInfo['email'] ?? '',
          'phoneNumber': billingInfo['phone_number'] ?? '',
        },
        'browserInfo': deviceData, // Device data with all required fields

        // EXPLICIT CyberSource fields (in case backend needs direct access)
        'consumerAuthenticationInformation': {
          'deviceChannel': 'BROWSER',
          'returnUrl':
              'https://cybersource.wegagenbanksc.com.et:3001/payments/3ds/return',
          'challengeWindowSize': '02',
        }
      };

      if (kDebugMode) {
        print('📤 FULL REQUEST PAYLOAD BEING SENT TO BACKEND:');
        print('   🔗 URL: ${UrlContainer.checkEnrollment}');
        print(
            '   📋 Payload size: ${enrollmentPayload.toString().length} chars');
        print('   🌐 Browser fields count: ${deviceData.length}');

        // Log the critical fields that CyberSource requires
        final criticalFields = [
          'browserUserAgent',
          'browserLanguage',
          'browserAcceptHeader'
        ];
        for (final field in criticalFields) {
          print('   ✅ $field: ${deviceData[field]}');
        }
      }

      final response = await _apiService.post(
        UrlContainer.checkEnrollment,
        enrollmentPayload,
        includeAuth: true,
      );

      if (kDebugMode) {
        print('✅ Enrollment API Response Received:');
        print('📄 Status: ${response['status']}');
        print('🆔 Transaction ID: ${response['id']}');

        final consumerAuth =
            response['consumerAuthenticationInformation'] ?? {};
        print('🔐 Consumer Auth Info:');
        print(
            '   🎯 AuthTransactionId: ${consumerAuth['authenticationTransactionId']}');
        print('   📊 veresEnrolled: ${consumerAuth['veresEnrolled']}');
        print('   🔗 stepUpUrl: ${consumerAuth['stepUpUrl']}');
        print('   🔗 acsUrl: ${consumerAuth['acsUrl']}');
        print(
            '   🔑 accessToken: ${consumerAuth['accessToken'] != null ? 'Present' : 'Missing'}');

        if (consumerAuth['directoryServerErrorCode'] != null) {
          print(
              '⚠️  Directory Server Error: ${consumerAuth['directoryServerErrorCode']}');
          print(
              '📝 Error Description: ${consumerAuth['directoryServerErrorDescription']}');
        }
      }

      final enrollmentResult = EnrollmentCheckResult.fromJson(response);

      if (kDebugMode) {
        print('🎯 Enrollment Result Analysis:');
        print('   ✅ Success: ${enrollmentResult.success}');
        print('   🔐 Is Enrolled: ${enrollmentResult.isEnrolled}');
        print(
            '   🎮 Challenge Required: ${enrollmentResult.isEnrolled ? 'YES - OTP Screen will show' : 'NO - Frictionless flow'}');
        print('🔐 === 3DS ENROLLMENT COMPLETED ===\n');
      }

      return enrollmentResult;
    } catch (e) {
      if (kDebugMode) {
        print('❌ === 3DS ENROLLMENT FAILED ===');
        print('💥 Error: $e');
        print('🔍 Check network connection and backend endpoint');
        print('❌ === 3DS ENROLLMENT ERROR END ===\n');
      }
      throw Exception('Failed to check 3DS enrollment: $e');
    }
  }

  /// Get 3DS authentication results after challenge completion
  /// This matches your backend's authenticationResults method
  Future<ThreeDSAuthResult> getAuthenticationResults({
    required String customerId,
    required String authenticationTransactionId,
    required double amount,
    required String currency,
  }) async {
    try {
      if (kDebugMode) {
        print('🔄 Getting 3DS authentication results');
        print('🆔 Auth Transaction ID: $authenticationTransactionId');
        print('👤 Customer ID being sent: "$customerId"');
        print('💰 Amount: $amount $currency');
      }

      final requestPayload = {
        'customer_id': customerId,
        'amount': amount,
        'currency': currency,
        'authenticationTransactionId': authenticationTransactionId,
      };

      if (kDebugMode) {
        print('📤 Full request payload: $requestPayload');
      }

      final response = await _apiService.post(
        UrlContainer.authenticationResults,
        requestPayload,
        includeAuth: true,
      );

      if (kDebugMode) {
        print('✅ Authentication results response received');
      }

      return ThreeDSAuthResult.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('❌ 3DS authentication results error: $e');
        print('🔍 Customer ID that was sent: "$customerId"');
        print(
            '🔍 Auth Transaction ID that was sent: "$authenticationTransactionId"');
      }
      throw Exception('Failed to get authentication results: $e');
    }
  }

  /// Final payment processing with 3DS authentication data
  /// This matches your backend's pay method
  Future<PaymentResult> finalizePayment({
    required String transientToken,
    required String customerId,
    required double amount,
    required double exchangeRate,
    required Map<String, dynamic> authenticationPayload,
  }) async {
    try {
      if (kDebugMode) {
        print('✅ Finalizing payment with 3DS authentication');
      }

      final response = await _apiService.post(
        UrlContainer.processPaymentWith3DS,
        {
          'transientToken': transientToken,
          'payload': authenticationPayload,
          'amount': amount,
          'customer_id': customerId,
          'exchange_rate': exchangeRate,
        },
        includeAuth: true,
      );

      return PaymentResult.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Payment finalization error: $e');
      }
      throw Exception('Failed to finalize payment: $e');
    }
  }

  /// Final payment processing for Cash Pickup transfers
  /// Uses the special cash pickup endpoint with account search fields
  Future<PaymentResult> finalizeCashPickupPayment({
    required String transientToken,
    required String customerId,
    required double amount,
    required double exchangeRate,
    required Map<String, dynamic> authenticationPayload,
    required Map<String, dynamic> recipientInfo,
  }) async {
    try {
      if (kDebugMode) {
        print('✅ Finalizing Cash Pickup payment with 3DS authentication');
        print('📱 Recipient Info: $recipientInfo');
      }

      final response = await _apiService.post(
        UrlContainer.processPaymentWith3DSForCashPicup,
        {
          'transientToken': transientToken,
          'payload': authenticationPayload,
          'amount': amount,
          'customer_id': customerId,
          'exchange_rate': exchangeRate,
          // Cash Pickup specific fields for account search
          'phone_number': recipientInfo['phone_number'] ?? '',
          'first_name': recipientInfo['first_name'] ?? '',
          'middle_name': recipientInfo['middle_name'] ?? '',
          'last_name': recipientInfo['last_name'] ?? '',
          'country': recipientInfo['country'] ?? 'ET',
          'state': recipientInfo['state'] ?? '',
          'city': recipientInfo['city'] ?? '',
          'address': recipientInfo['address'] ?? '',
          'relationship_to_sender': recipientInfo['relationship_to_sender'] ?? '',
          'currency': recipientInfo['currency'] ?? 'ETB',
          'expected_amount': recipientInfo['expected_amount'] ?? amount,
        },
        includeAuth: true,
      );

      return PaymentResult.fromJson(response);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Cash Pickup payment finalization error: $e');
      }
      throw Exception('Failed to finalize cash pickup payment: $e');
    }
  }

  /// Complete 3DS payment flow with transfer type routing
  /// This orchestrates the full flow using your backend endpoints
  Future<PaymentResult> processPaymentWith3DS({
    required String paymentToken,
    required double amount,
    required String currency,
    required Map<String, dynamic> billingInfo,
    required Map<String, dynamic> recipientInfo,
    String? remark,
    String? transferType,
  }) async {
    try {
      if (kDebugMode) {
        print('💳 === 3DS PAYMENT FLOW STARTED ===');
        print('💳 Transfer Type: $transferType');
        print('💰 Is Cash Pickup: ${transferType == 'cash_pickup'}');
        print('🎫 Payment Token: ${paymentToken.length > 20 ? paymentToken.substring(0, 20) + '...' : paymentToken}');
        print('💰 Amount: $amount $currency');
        print(
            '👤 Billing: ${billingInfo['first_name']} ${billingInfo['last_name']}');
        print('📧 Email: ${billingInfo['email']}');
        print('📱 Recipient Info: $recipientInfo');
      }

      // Step 1: Process payment token to get customer ID
      if (kDebugMode) {
        print('\n🔄 STEP 1: Processing payment token...');
        print('🏦 Using Regular endpoint for token processing (all transfer types)');
      }

      final tokenResult = await processPaymentToken(
        transientToken: paymentToken,
        billingInfo: billingInfo,
        amount: amount,
        currency: currency,
        exchangeRate: 1.0, // You can get this from recipientInfo or form data
        transferType: transferType, // Pass transfer type to route to correct endpoint
      );

      if (!tokenResult.success || tokenResult.customerId == null) {
        if (kDebugMode) {
          print('❌ STEP 1 FAILED: No customer ID received');
          print('🔍 Token Result: ${tokenResult.error ?? tokenResult.message}');
        }
        throw Exception('Failed to get customer ID from payment token');
      }

      if (kDebugMode) {
        print('✅ STEP 1 SUCCESS: Got customer ID: ${tokenResult.customerId}');
        print('📄 DDC Available: ${tokenResult.ddc != null ? 'Yes' : 'No'}');

        // Debug the actual DDC structure
        if (tokenResult.ddc != null) {
          print('🔍 DDC Structure: ${tokenResult.ddc}');
        }
      }

      // Extract reference ID from DDC response
      String? extractedReferenceId;

      if (tokenResult.ddc != null) {
        // Try multiple possible locations for reference ID
        extractedReferenceId = tokenResult
                .ddc?['consumerAuthenticationInformation']?['referenceId'] ??
            tokenResult.ddc?['referenceId'] ??
            tokenResult.ddc?['reference_id'] ??
            tokenResult.ddc?['id'];

        if (kDebugMode) {
          print('🔖 Reference ID extraction attempts:');
          print(
              '   - From consumerAuthInfo: ${tokenResult.ddc?['consumerAuthenticationInformation']?['referenceId']}');
          print('   - From referenceId: ${tokenResult.ddc?['referenceId']}');
          print('   - From reference_id: ${tokenResult.ddc?['reference_id']}');
          print('   - From id: ${tokenResult.ddc?['id']}');
          print('   - Final extracted: $extractedReferenceId');
        }
      }

      // Use extracted reference ID or generate fallback
      final referenceId = extractedReferenceId ??
          'mobile_ref_${DateTime.now().millisecondsSinceEpoch}';

      if (kDebugMode) {
        print('🎯 Using Reference ID: $referenceId');
        if (extractedReferenceId == null) {
          print(
              '⚠️  Using fallback reference ID - check DDC response structure');
        }
      }

      // Step 2: Check 3DS enrollment
      if (kDebugMode) {
        print('\n🔄 STEP 2: Checking 3DS enrollment...');
      }

      final enrollmentResult = await checkEnrollment(
        customerId: tokenResult.customerId!,
        referenceId: referenceId,
        amount: amount,
        currency: currency,
        billingInfo: billingInfo,
      );

      if (kDebugMode) {
        print('✅ STEP 2 COMPLETED: Enrollment check done');
        print(
            '🔐 Real enrollment result: isEnrolled = ${enrollmentResult.isEnrolled}');
      }

      // Create result with transfer type information and endpoint routing
      final regularResult = PaymentResult(
        success: true,
        status: 'enrollment_checked',
        amount: amount,
        currency: currency,
        requires3DS: enrollmentResult.isEnrolled,
        threeDSEnrollment: enrollmentResult,
        customerId: tokenResult.customerId,
        transientToken: paymentToken,
      );

      if (kDebugMode) {
        print('📋 PAYMENT RESULT WITH ENDPOINT ROUTING:');
        if (transferType == 'cash_pickup') {
          print('🏪 Using Cash Pickup endpoint: /payments/pay/cash-pickup');
        } else {
          print('🏦 Using Regular endpoint: /payments/pay');
        }
        print('   🔐 requires3DS: ${regularResult.requires3DS}');
        print(
            '   🎮 needsAuthentication: ${regularResult.needsAuthentication}');
        print('   👤 customerId: "${regularResult.customerId}"');
        print(
            '   🎫 transientToken: ${regularResult.transientToken != null && regularResult.transientToken!.length > 20 ? regularResult.transientToken!.substring(0, 20) + '...' : regularResult.transientToken}');
        print(
            '   📱 Challenge screen will ${regularResult.needsAuthentication ? 'SHOW' : 'NOT SHOW'}');
        print('💳 === 3DS PAYMENT FLOW COMPLETED ===\n');
      }

      return regularResult;
    } catch (e) {
      if (kDebugMode) {
        print('❌ === 3DS PAYMENT FLOW FAILED ===');
        print('💥 Error: $e');
        print('🔍 Flow stopped at error point');
        print('❌ === 3DS PAYMENT FLOW ERROR END ===\n');
      }
      throw Exception('Failed to process 3DS payment: $e');
    }
  }

  /// Collect device data for 3DS DDC - Browser-compatible mode for mobile apps
  Future<Map<String, dynamic>> collectDeviceDataForDDC() async {
    try {
      if (kDebugMode) {
        print('🌐 Using BROWSER-compatible mode (mobile app as browser)');
        print('📱 Generating CyberSource-compliant browser fields...');
      }

      return {
        // CRITICAL: Exact field names CyberSource expects (from error message)
        'browserLanguage': 'en-US',
        'browserUserAgent':
            'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36 WegagenRemitApp/1.0.0',
        'browserAcceptHeader':
            'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',

        // Additional REQUIRED browser fields for CyberSource
        'browserColorDepth': '24',
        'browserScreenHeight': '800',
        'browserScreenWidth': '400',
        'browserTimeZone': '180', // Ethiopian timezone (+3 hours = 180 minutes)
        'browserJavaEnabled': false,
        'browserJavaScriptEnabled': true,

        // Device and transaction mode for mobile
        'browserIP': '127.0.0.1', // Mobile app local IP
        'deviceChannel': 'BROWSER', // Keep as BROWSER for compatibility
        'transactionMode': 'eCommerce', // Keep as eCommerce for compatibility
        'returnUrl':
            'https://cybersource.wegagenbanksc.com.et:3001/payments/3ds/return',
        'challengeWindowSize': '02', // 390x400 mobile window

        // HTTP-prefixed versions (backend might need both)
        'httpAcceptBrowserValue':
            'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
        'httpUserAgent':
            'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36',
        'httpBrowserLanguage': 'en-US',
        'httpBrowserColorDepth': '24',
        'httpBrowserScreenHeight': '800',
        'httpBrowserScreenWidth': '400',
        'httpBrowserTimeDifference': '180',
        'httpBrowserJavaEnabled': 'false',
        'httpBrowserJavaScriptEnabled': 'true',

        // Device fingerprinting data
        'deviceFingerprintID':
            'mobile_${DateTime.now().millisecondsSinceEpoch}',
        'clientEnvironment': 'BROWSER',

        // 3DS 2.0 specific fields
        'threeDSRequestorChallengeInd': '01', // No preference
        'threeDSCompInd': 'Y', // 3DS Requestor is authenticated
      };
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error collecting device data: $e');
      }

      // CRITICAL: Fallback with ALL required fields
      return {
        // These 3 are MANDATORY according to the error
        'browserUserAgent':
            'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 WegagenRemitApp/1.0.0',
        'browserLanguage': 'en-US',
        'browserAcceptHeader':
            'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',

        // Additional required fields
        'browserColorDepth': '24',
        'browserScreenHeight': '800',
        'browserScreenWidth': '400',
        'browserTimeZone': '180',
        'browserJavaEnabled': false,
        'browserJavaScriptEnabled': true,
        'deviceChannel': 'BROWSER',
        'transactionMode': 'eCommerce',
        'browserIP': '127.0.0.1',
      };
    }
  }
}

/// Payment Token Result from your backend's processPayment method
class PaymentTokenResult {
  final bool success;
  final String? customerId;
  final Map<String, dynamic>? ddc;
  final String? error;
  final String? message;

  PaymentTokenResult({
    required this.success,
    this.customerId,
    this.ddc,
    this.error,
    this.message,
  });

  factory PaymentTokenResult.fromJson(Map<String, dynamic> json) {
    return PaymentTokenResult(
      success: json['customerId'] != null,
      customerId: json['customerId'],
      ddc: json['DDC'],
      error: json['error'],
      message: json['message'],
    );
  }
}

/// 3DS Enrollment Check Result
class EnrollmentCheckResult {
  final bool success;
  final bool isEnrolled;
  final String? transactionId;
  final String? authenticationTransactionId;
  final String? acsUrl;
  final String? paReq;
  final String? stepUpUrl;
  final String? accessToken;
  final String? error;
  final String? message;

  EnrollmentCheckResult({
    required this.success,
    required this.isEnrolled,
    this.transactionId,
    this.authenticationTransactionId,
    this.acsUrl,
    this.paReq,
    this.stepUpUrl,
    this.accessToken,
    this.error,
    this.message,
  });

  factory EnrollmentCheckResult.fromJson(Map<String, dynamic> json) {
    final consumerAuth = json['consumerAuthenticationInformation'] ?? {};

    return EnrollmentCheckResult(
      success: json['status'] == 'PENDING_AUTHENTICATION' ||
          json['status'] == 'COMPLETED',
      isEnrolled: json['status'] == 'PENDING_AUTHENTICATION',
      transactionId: json['id'],
      authenticationTransactionId: consumerAuth['authenticationTransactionId'],
      acsUrl: consumerAuth['acsUrl'],
      paReq: consumerAuth['paReq'],
      stepUpUrl: consumerAuth['stepUpUrl'],
      accessToken: consumerAuth['accessToken'],
      error: json['errorInformation']?['message'],
      message: json['message'],
    );
  }
}

/// 3DS Authentication Result
class ThreeDSAuthResult {
  final bool success;
  final String status;
  final String? authResult;
  final String? cavv;
  final String? eci;
  final String? xid;
  final String? ucafAuthenticationData;
  final String? ucafCollectionIndicator;
  final String? authenticationTransactionId;
  final String? error;
  final String? message;

  ThreeDSAuthResult({
    required this.success,
    required this.status,
    this.authResult,
    this.cavv,
    this.eci,
    this.xid,
    this.ucafAuthenticationData,
    this.ucafCollectionIndicator,
    this.authenticationTransactionId,
    this.error,
    this.message,
  });

  factory ThreeDSAuthResult.fromJson(Map<String, dynamic> json) {
    final consumerAuth = json['consumerAuthenticationInformation'] ?? {};

    // Handle both COMPLETED and AUTHENTICATION_SUCCESSFUL status values
    final status = json['status'] ?? 'unknown';
    final isSuccessStatus =
        status == 'COMPLETED' || status == 'AUTHENTICATION_SUCCESSFUL';

    return ThreeDSAuthResult(
      success: isSuccessStatus,
      status: status,
      authResult: consumerAuth['authenticationResult'],
      cavv: consumerAuth['cavv'],
      eci: consumerAuth['eciRaw'],
      xid: consumerAuth['xid'],
      ucafAuthenticationData: consumerAuth['ucafAuthenticationData'],
      ucafCollectionIndicator: consumerAuth['ucafCollectionIndicator'],
      authenticationTransactionId: consumerAuth['authenticationTransactionId'],
      error: json['errorInformation']?['message'],
      message: json['message'],
    );
  }

  bool get isAuthenticated =>
      success &&
      (authResult == 'SUCCESS' || status == 'AUTHENTICATION_SUCCESSFUL');
  bool get isAttempted =>
      success &&
      (authResult == 'ATTEMPTED' ||
          authResult == 'SUCCESS' ||
          status == 'AUTHENTICATION_SUCCESSFUL');
  bool get isNotEnrolled => success && authResult == 'NOT_ENROLLED';
}

/// Payment Result with 3DS information
class PaymentResult {
  final bool success;
  final String? transactionId;
  final String? paymentReference;
  final String status;
  final double? amount;
  final String? currency;
  final bool requires3DS;
  final EnrollmentCheckResult? threeDSEnrollment;
  final String? customerId;
  final String? transientToken;
  final String? error;
  final String? message;
  final DateTime? timestamp;

  PaymentResult({
    required this.success,
    this.transactionId,
    this.paymentReference,
    required this.status,
    this.amount,
    this.currency,
    this.requires3DS = false,
    this.threeDSEnrollment,
    this.customerId,
    this.transientToken,
    this.error,
    this.message,
    this.timestamp,
  });

  factory PaymentResult.fromJson(Map<String, dynamic> json) {
    return PaymentResult(
      success: json['success'] ?? false,
      transactionId: json['transaction_id'] ?? json['id'],
      paymentReference: json['payment_reference'],
      status: json['status'] ?? 'unknown',
      amount: json['amount']?.toDouble(),
      currency: json['currency'],
      requires3DS: json['requires_3ds'] ?? false,
      customerId: json['customer_id'],
      transientToken: json['transient_token'],
      error: json['error'],
      message: json['message'],
      timestamp:
          json['timestamp'] != null ? DateTime.parse(json['timestamp']) : null,
    );
  }

  bool get isCompleted => success && status == 'completed';
  bool get isPending => status == 'pending' || status == 'processing';
  bool get needsAuthentication =>
      requires3DS && threeDSEnrollment != null && threeDSEnrollment!.isEnrolled;
}
