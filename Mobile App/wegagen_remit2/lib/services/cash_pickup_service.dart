import 'package:flutter/foundation.dart';
import '../config/url_container.dart';
import 'api_service.dart';

class CashPickupService {
  static final CashPickupService _instance = CashPickupService._internal();
  factory CashPickupService() => _instance;
  CashPickupService._internal();

  final ApiService _apiService = ApiService();

  /// Send cash pickup transfer - same process as internal transfer
  /// but with different recipient payload + billing info
  Future<CashPickupResponse> sendCashPickupTransfer({
    required String paymentToken,
    required double amount,
    required String currency,
    required Map<String, dynamic> recipientInfo,
    required Map<String, dynamic> billingInfo, // Add billing info
    String? remark,
  }) async {
    try {
      if (!_apiService.isInitialized) {
        await _apiService.initialize();
      }

      if (kDebugMode) {
        print('💸 CashPickupService: Initiating cash pickup transfer');
        print('💰 Amount: $amount $currency');
        print('📱 Recipient: ${recipientInfo['first_name']} ${recipientInfo['last_name']}');
        print('📞 Phone: ${recipientInfo['phone_number']}');
        print('👤 Billing: ${billingInfo['first_name']} ${billingInfo['last_name']}');
        print('📧 Email: ${billingInfo['email']}');
      }

      // Full payload with billing info + cash pickup recipient fields
      final response = await _apiService.post(
        UrlContainer.processPaymentWith3DSForCashPicup, // Use cash pickup endpoint
        {
          'transientToken': paymentToken,
          'amount': amount,
          'currency': currency,
          'remark': remark ?? 'Cash pickup transfer',
          'exchange_rate': 1.0,
          
          // Billing information (required by backend)
          'firstName': billingInfo['first_name'] ?? '',
          'lastName': billingInfo['last_name'] ?? '',
          'address1': billingInfo['address1'] ?? '',
          'locality': billingInfo['locality'] ?? '',
          'administrativeArea': billingInfo['administrative_area'] ?? '',
          'postalCode': billingInfo['postal_code'] ?? '',
          'country': billingInfo['country'] ?? 'US',
          'email': billingInfo['email'] ?? '',
          'phoneNumber': billingInfo['phone_number'] ?? '',
          
          // Cash pickup specific recipient fields (different from internal transfer)
          'phone_number': recipientInfo['phone_number'] ?? '',
          'first_name': recipientInfo['first_name'] ?? '',
          'middle_name': recipientInfo['middle_name'] ?? '',
          'last_name': recipientInfo['last_name'] ?? '',
          'country': recipientInfo['country'] ?? 'ET',
          'state': recipientInfo['state'] ?? '',
          'city': recipientInfo['city'] ?? '',
          'address': recipientInfo['address'] ?? '',
          'relationship_to_sender': recipientInfo['relationship_to_sender'] ?? '',
          'expected_amount': amount, // Amount recipient expects to receive
        },
        includeAuth: true,
      );

      final cashPickupResponse = CashPickupResponse.fromJson(response);

      if (cashPickupResponse.success) {
        if (kDebugMode) {
          print('✅ Cash pickup transfer successful: ${cashPickupResponse.transactionId}');
        }
      } else {
        if (kDebugMode) {
          print('❌ Cash pickup transfer failed: ${cashPickupResponse.message}');
        }
      }

      return cashPickupResponse;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Cash pickup transfer error: $e');
      }

      return CashPickupResponse(
        success: false,
        error: 'Network error',
        message: 'Unable to process cash pickup transfer: ${e.toString()}',
      );
    }
  }
}

// Cash pickup response model - same structure as TransferResponse
class CashPickupResponse {
  final bool success;
  final Map<String, dynamic>? data;
  final String? message;
  final String? transactionId;
  final String? status;
  final String? error;

  CashPickupResponse({
    required this.success,
    this.data,
    this.message,
    this.transactionId,
    this.status,
    this.error,
  });

  factory CashPickupResponse.fromJson(Map<String, dynamic> json) {
    return CashPickupResponse(
      success: json['success'] ?? false,
      data: json['data'],
      message: json['message'],
      transactionId: json['transactionId'] ?? json['transaction_id'],
      status: json['status'],
      error: json['error'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data,
      'message': message,
      'transactionId': transactionId,
      'status': status,
      'error': error,
    };
  }
}