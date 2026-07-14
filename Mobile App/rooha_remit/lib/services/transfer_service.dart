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
    dynamic payload = json['data'];

    if (payload == null) {
      if (json['QUERYCUSTACC_IOFS_RES'] != null) {
        payload = json['QUERYCUSTACC_IOFS_RES']
            ['FCUBS_BODY']?['Cust-Account-Full'];
      } else if (json['ACC'] != null && json['CUSTNAME'] != null) {
        payload = json;
      }
    }

    return AccountInfoResponse(
      success: json['status'] == 'success' || json['success'] == true,
      message: json['message'] ?? 'Operation completed',
      data: payload != null ? AccountInfo.fromJson(payload as Map<String, dynamic>) : null,
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
      accountNumber: json['account_number'] ?? json['ACC'] ?? json['CLRACNO'] ?? '',
      accountHolderName: json['account_holder_name'] ?? json['CUSTNAME'] ?? json['ADESC'] ?? json['name'] ?? '',
      accountType: json['account_type'] ?? json['ACCTYPE'] ?? json['ACCLSTYP'],
      bankName: json['bank_name'] ?? json['BRN'] ?? 'Wegagen  bank',
    );
  }
}

class TransferException implements Exception {
  final String message;

  TransferException(this.message);

  @override
  String toString() => 'TransferException: $message';
}