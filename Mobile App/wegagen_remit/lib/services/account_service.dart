import 'package:flutter/foundation.dart';
import '../models/account_info_response.dart';
import '../config/url_container.dart';
import 'api_service.dart';

class AccountService {
  static final AccountService _instance = AccountService._internal();
  factory AccountService() => _instance;
  AccountService._internal();

  final ApiService _apiService = ApiService();
  
  /// Get account information by account number
  /// Returns mobile-optimized account data from the updated backend
  Future<AccountInfoResponse> getAccountInfo(String accountNumber) async {
    try {
      if (!_apiService.isInitialized) {
        await _apiService.initialize();
      }

      if (kDebugMode) {
        print('🔍 AccountService: Fetching account info for: $accountNumber');
        print('🔍 API Endpoint: ${UrlContainer.accountInfo}');
      }

      final response = await _apiService.post(
        UrlContainer.accountInfo,
        {'account_number': accountNumber},
        includeAuth: true,
      );

      if (kDebugMode) {
        print('📱 Raw Response: $response');
        print('📱 Response Type: ${response.runtimeType}');
        print('📱 Response Keys: ${response.keys}');
        
        // Check if response has expected structure
        if (response.containsKey('data')) {
          print('📱 Data field exists: ${response['data']}');
          if (response['data'] is Map) {
            final data = response['data'] as Map<String, dynamic>;
            print('📱 Data keys: ${data.keys}');
            if (data.containsKey('account')) {
              print('📱 Account field exists: ${data['account']}');
            } else {
              print('❌ No account field in data');
            }
          }
        } else {
          print('❌ No data field in response');
        }
      }

      final accountResponse = AccountInfoResponse.fromJson(response);

      if (kDebugMode) {
        print('📱 Parsed AccountInfoResponse: success=${accountResponse.success}');
        print('📱 Account exists: ${accountResponse.account != null}');
        print('📱 Error: ${accountResponse.error}');
        print('📱 Message: ${accountResponse.message}');
      }

      if (accountResponse.success && accountResponse.account != null) {
        if (kDebugMode) {
          print('✅ Account found: ${accountResponse.account!.accountHolderName}');
          print('💰 Account Number: ${accountResponse.account!.accountNumber}');
          print('💰 Available balance: ${accountResponse.account!.balance.formattedAvailable}');
        }
      } else {
        if (kDebugMode) {
          print('❌ Account lookup failed: ${accountResponse.message ?? accountResponse.error}');
        }
      }

      return accountResponse;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Network/parsing error: $e');
        print('❌ Error type: ${e.runtimeType}');
        if (e is Exception) {
          print('❌ Exception details: ${e.toString()}');
        }
      }

      // Handle network or parsing errors
      return AccountInfoResponse(
        success: false,
        error: 'Network error',
        message: 'Unable to fetch account information: ${e.toString()}',
      );
    }
  }

  /// Validate recipient account before transfer
  /// Uses the new backend endpoint for recipient validation
  Future<RecipientValidationResponse> validateRecipient(String accountNumber) async {
    try {
      if (!_apiService.isInitialized) {
        await _apiService.initialize();
      }

      if (kDebugMode) {
        print('🔍 AccountService: Validating recipient: $accountNumber');
      }

      final response = await _apiService.post(
        UrlContainer.validateRecipient,
        {'account_number': accountNumber},
        includeAuth: true,
      );

      final validationResponse = RecipientValidationResponse.fromJson(response);

      if (validationResponse.success && validationResponse.valid) {
        if (kDebugMode) {
          print('✅ Recipient validated: ${validationResponse.recipient?.accountHolderName}');
        }
      } else {
        if (kDebugMode) {
          print('❌ Recipient validation failed: ${validationResponse.message}');
        }
      }

      return validationResponse;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Validation error: $e');
      }

      return RecipientValidationResponse(
        success: false,
        valid: false,
        error: 'Network error',
        message: 'Unable to validate recipient: ${e.toString()}',
      );
    }
  }

  /// Send internal transfer
  /// Returns transfer result from updated backend
  Future<TransferResponse> sendTransfer({
    required String fromAccount,
    required String toAccount,
    required double amount,
    required String currency,
    String? remark,
  }) async {
    try {
      if (!_apiService.isInitialized) {
        await _apiService.initialize();
      }

      if (kDebugMode) {
        print('💸 AccountService: Initiating transfer');
        print('📊 Transfer details: $fromAccount → $toAccount ($amount $currency)');
      }

      final response = await _apiService.post(
        UrlContainer.sendTransfer,
        {
          'from_account': fromAccount,
          'to_account': toAccount,
          'amount': amount,
          'currency': currency,
          'remark': remark ?? '',
        },
        includeAuth: true,
      );

      final transferResponse = TransferResponse.fromJson(response);

      if (transferResponse.success) {
        if (kDebugMode) {
          print('✅ Transfer successful: ${transferResponse.transactionId}');
        }
      } else {
        if (kDebugMode) {
          print('❌ Transfer failed: ${transferResponse.message}');
        }
      }

      return transferResponse;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Transfer error: $e');
      }

      return TransferResponse(
        success: false,
        error: 'Network error',
        message: 'Unable to process transfer: ${e.toString()}',
      );
    }
  }
}

// Transfer response model
class TransferResponse {
  final bool success;
  final Map<String, dynamic>? data;
  final String? message;
  final String? transactionId;
  final String? status;
  final String? error;

  TransferResponse({
    required this.success,
    this.data,
    this.message,
    this.transactionId,
    this.status,
    this.error,
  });

  factory TransferResponse.fromJson(Map<String, dynamic> json) {
    return TransferResponse(
      success: json['success'] ?? false,
      data: json['data'],
      message: json['message'],
      transactionId: json['transactionId'],
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

// Account lookup helper for form fields
class AccountLookupHelper {
  static final AccountService _accountService = AccountService();

  /// Quick account holder name lookup for forms
  static Future<String?> getAccountHolderName(String accountNumber) async {
    if (accountNumber.isEmpty || accountNumber.length < 10) {
      return null;
    }

    try {
      final response = await _accountService.getAccountInfo(accountNumber);
      
      if (response.success && response.account != null) {
        return response.account!.accountHolderName;
      }
      
      return null;
    } catch (e) {
      print('Error looking up account holder: $e');
      return null;
    }
  }

  /// Check if account can receive transfers
  static Future<bool> canReceiveTransfer(String accountNumber) async {
    try {
      final response = await _accountService.validateRecipient(accountNumber);
      return response.success && response.valid && (response.recipient?.canReceive ?? false);
    } catch (e) {
      return false;
    }
  }

  /// Format account number for display (e.g., add spaces or dashes)
  static String formatAccountNumber(String accountNumber) {
    if (accountNumber.length >= 10) {
      // Format as: XXXX-XXXX-XXXX or similar based on your bank's format
      return accountNumber.replaceAllMapped(
        RegExp(r'.{4}'),
        (match) => '${match.group(0)} ',
      ).trim();
    }
    return accountNumber;
  }

  /// Validate account number format
  static bool isValidAccountNumber(String accountNumber) {
    // Adjust this regex based on your bank's account number format
    // This example assumes 10-15 digit account numbers
    return RegExp(r'^\d{10,15}$').hasMatch(accountNumber.replaceAll(' ', ''));
  }
}