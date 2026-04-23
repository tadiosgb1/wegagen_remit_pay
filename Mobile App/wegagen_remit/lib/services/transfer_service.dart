import '../config/url_container.dart';
import 'api_service.dart';

class TransferService {
  static final TransferService _instance = TransferService._internal();
  factory TransferService() => _instance;
  TransferService._internal();

  final ApiService _apiService = ApiService();

  // Get account information
  Future<AccountInfoResponse> getAccountInfo(String accountNumber) async {
    try {
      final response = await _apiService.post(
        UrlContainer.accountInfo,
        {'account_number': accountNumber},
        includeAuth: true,
      );
      
      return AccountInfoResponse.fromJson(response);
    } catch (e) {
      throw TransferException('Failed to get account information: $e');
    }
  }
}

class AccountInfoResponse {
  final bool success;
  final String message;
  final AccountInfo? data;

  AccountInfoResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory AccountInfoResponse.fromJson(Map<String, dynamic> json) {
    return AccountInfoResponse(
      success: json['status'] == 'success' || json['success'] == true,
      message: json['message'] ?? 'Operation completed',
      data: json['data'] != null ? AccountInfo.fromJson(json['data']) : null,
    );
  }
}

class AccountInfo {
  final String accountNumber;
  final String accountHolderName;
  final String? accountType;
  final String? bankName;

  AccountInfo({
    required this.accountNumber,
    required this.accountHolderName,
    this.accountType,
    this.bankName,
  });

  factory AccountInfo.fromJson(Map<String, dynamic> json) {
    return AccountInfo(
      accountNumber: json['account_number'] ?? '',
      accountHolderName: json['account_holder_name'] ?? json['name'] ?? '',
      accountType: json['account_type'],
      bankName: json['bank_name'],
    );
  }
}

class TransferException implements Exception {
  final String message;

  TransferException(this.message);

  @override
  String toString() => 'TransferException: $message';
}