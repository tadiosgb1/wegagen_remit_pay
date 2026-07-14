// Mobile-optimized account info response model
// Matches the backend response format from internal-transfer service

import 'package:flutter/foundation.dart';

class AccountInfoResponse {
  final bool success;
  final AccountInfo? account;
  final String? error;
  final String? message;

  AccountInfoResponse({
    required this.success,
    this.account,
    this.error,
    this.message,
  });

  factory AccountInfoResponse.fromJson(Map<String, dynamic> json) {
    try {
      // Handle the nested response structure from backend
      // The backend returns: {"status": "success", "data": {"success": true, "account": {...}}}
      Map<String, dynamic> responseData;
      
      if (kDebugMode) {
        print('🔍 AccountInfoResponse.fromJson - Input JSON: $json');
        print('🔍 JSON keys: ${json.keys}');
        print('🔍 Status field: ${json['status']}');
        print('🔍 Data field type: ${json['data']?.runtimeType}');
      }
      
      if (json.containsKey('data') && json['data'] is Map<String, dynamic>) {
        // Extract the nested data
        responseData = json['data'] as Map<String, dynamic>;
        if (kDebugMode) {
          print('🔍 Using nested data structure');
          print('🔍 Data keys: ${responseData.keys}');
        }
      } else {
        // Use the json directly if it's already in the expected format
        responseData = json;
        if (kDebugMode) {
          print('🔍 Using direct JSON structure');
        }
      }
      
      // Check for different success indicators
      bool isSuccessful = false;
      if (responseData.containsKey('success')) {
        isSuccessful = responseData['success'] == true;
      } else if (json.containsKey('status')) {
        isSuccessful = json['status'] == 'success';
      }
      
      if (kDebugMode) {
        print('🔍 Success determined as: $isSuccessful');
        print('🔍 Account field exists: ${responseData.containsKey('account')}');
        if (responseData.containsKey('account')) {
          print('🔍 Account data type: ${responseData['account']?.runtimeType}');
          print('🔍 Account data: ${responseData['account']}');
        }
      }
      
      AccountInfo? account;
      if (responseData['account'] != null) {
        if (responseData['account'] is Map<String, dynamic>) {
          account = AccountInfo.fromJson(responseData['account'] as Map<String, dynamic>);
        } else {
          if (kDebugMode) {
            print('❌ Account data is not a Map: ${responseData['account']}');
          }
        }
      }
      
      final result = AccountInfoResponse(
        success: isSuccessful,
        account: account,
        error: responseData['error'] ?? json['error'],
        message: responseData['message'] ?? json['message'],
      );
      
      if (kDebugMode) {
        print('🔍 Final AccountInfoResponse: success=${result.success}, hasAccount=${result.account != null}');
      }
      
      return result;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Error parsing AccountInfoResponse: $e');
        print('❌ Stack trace: $stackTrace');
        print('❌ Original JSON: $json');
      }
      
      return AccountInfoResponse(
        success: false,
        error: 'Parsing error: $e',
        message: 'Failed to parse account info response',
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'account': account?.toJson(),
      'error': error,
      'message': message,
    };
  }
}

class AccountInfo {
  final String accountNumber;
  final String accountHolderName;
  final String customerNumber;
  final String branchCode;
  final String currency;
  final String accountType;
  final String accountTypeDescription;
  final String accountStatus;
  final String accountStatusDescription;
  final String? alternateAccount;
  final String? openDate;
  final bool frozen;
  final AddressInfo address;
  final BalanceInfo balance;
  final AccountFeatures features;
  final AccountRestrictions restrictions;
  final bool canSendMoney;
  final bool canReceiveMoney;

  AccountInfo({
    required this.accountNumber,
    required this.accountHolderName,
    required this.customerNumber,
    required this.branchCode,
    required this.currency,
    required this.accountType,
    required this.accountTypeDescription,
    required this.accountStatus,
    required this.accountStatusDescription,
    this.alternateAccount,
    this.openDate,
    required this.frozen,
    required this.address,
    required this.balance,
    required this.features,
    required this.restrictions,
    required this.canSendMoney,
    required this.canReceiveMoney,
  });

  factory AccountInfo.fromJson(Map<String, dynamic> json) {
    return AccountInfo(
      accountNumber: json['accountNumber'] ?? '',
      accountHolderName: json['accountHolderName'] ?? '',
      customerNumber: json['customerNumber'] ?? '',
      branchCode: json['branchCode'] ?? '',
      currency: json['currency'] ?? '',
      accountType: json['accountType'] ?? '',
      accountTypeDescription: json['accountTypeDescription'] ?? '',
      accountStatus: json['accountStatus'] ?? '',
      accountStatusDescription: json['accountStatusDescription'] ?? '',
      alternateAccount: json['alternateAccount'],
      openDate: json['openDate'],
      frozen: json['frozen'] ?? false,
      address: AddressInfo.fromJson(json['address'] ?? {}),
      balance: BalanceInfo.fromJson(json['balance'] ?? {}),
      features: AccountFeatures.fromJson(json['features'] ?? {}),
      restrictions: AccountRestrictions.fromJson(json['restrictions'] ?? {}),
      canSendMoney: json['canSendMoney'] ?? false,
      canReceiveMoney: json['canReceiveMoney'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accountNumber': accountNumber,
      'accountHolderName': accountHolderName,
      'customerNumber': customerNumber,
      'branchCode': branchCode,
      'currency': currency,
      'accountType': accountType,
      'accountTypeDescription': accountTypeDescription,
      'accountStatus': accountStatus,
      'accountStatusDescription': accountStatusDescription,
      'alternateAccount': alternateAccount,
      'openDate': openDate,
      'frozen': frozen,
      'address': address.toJson(),
      'balance': balance.toJson(),
      'features': features.toJson(),
      'restrictions': restrictions.toJson(),
      'canSendMoney': canSendMoney,
      'canReceiveMoney': canReceiveMoney,
    };
  }

  // Helper getters for UI
  String get displayName => accountHolderName;
  String get displayAccountNumber => accountNumber;
  String get displayBalance => balance.formattedAvailable;
  bool get isActive => accountStatus == 'NORM' && !frozen;
  String get statusDisplay => frozen ? 'Frozen' : accountStatusDescription;
}

class AddressInfo {
  final String? line1;
  final String? line2;
  final String? line3;
  final String? line4;

  AddressInfo({
    this.line1,
    this.line2,
    this.line3,
    this.line4,
  });

  factory AddressInfo.fromJson(Map<String, dynamic> json) {
    return AddressInfo(
      line1: json['line1'],
      line2: json['line2'],
      line3: json['line3'],
      line4: json['line4'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'line1': line1,
      'line2': line2,
      'line3': line3,
      'line4': line4,
    };
  }

  String get fullAddress {
    final lines = [line1, line2, line3, line4]
        .where((line) => line != null && line.isNotEmpty)
        .join(', ');
    return lines;
  }
}

class BalanceInfo {
  final double current;
  final double available;
  final String currency;
  final double blocked;
  final String? lastCreditDate;
  final String? lastDebitDate;
  final FormattedBalance? formatted;

  BalanceInfo({
    required this.current,
    required this.available,
    required this.currency,
    required this.blocked,
    this.lastCreditDate,
    this.lastDebitDate,
    this.formatted,
  });

  factory BalanceInfo.fromJson(Map<String, dynamic> json) {
    return BalanceInfo(
      current: (json['current'] ?? 0).toDouble(),
      available: (json['available'] ?? 0).toDouble(),
      currency: json['currency'] ?? '',
      blocked: (json['blocked'] ?? 0).toDouble(),
      lastCreditDate: json['lastCreditDate'],
      lastDebitDate: json['lastDebitDate'],
      formatted: json['formatted'] != null 
          ? FormattedBalance.fromJson(json['formatted']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current': current,
      'available': available,
      'currency': currency,
      'blocked': blocked,
      'lastCreditDate': lastCreditDate,
      'lastDebitDate': lastDebitDate,
      'formatted': formatted?.toJson(),
    };
  }

  // Helper getters for UI display
  String get formattedCurrent => formatted?.current ?? '$current $currency';
  String get formattedAvailable => formatted?.available ?? '$available $currency';
  bool get hasBlocked => blocked > 0;
  String get formattedBlocked => '$blocked $currency';
}

class FormattedBalance {
  final String current;
  final String available;

  FormattedBalance({
    required this.current,
    required this.available,
  });

  factory FormattedBalance.fromJson(Map<String, dynamic> json) {
    return FormattedBalance(
      current: json['current'] ?? '',
      available: json['available'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current': current,
      'available': available,
    };
  }
}

class AccountFeatures {
  final bool atmEnabled;
  final bool passbookEnabled;
  final bool chequebookEnabled;
  final bool directBankingEnabled;

  AccountFeatures({
    required this.atmEnabled,
    required this.passbookEnabled,
    required this.chequebookEnabled,
    required this.directBankingEnabled,
  });

  factory AccountFeatures.fromJson(Map<String, dynamic> json) {
    return AccountFeatures(
      atmEnabled: json['atmEnabled'] ?? false,
      passbookEnabled: json['passbookEnabled'] ?? false,
      chequebookEnabled: json['chequebookEnabled'] ?? false,
      directBankingEnabled: json['directBankingEnabled'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'atmEnabled': atmEnabled,
      'passbookEnabled': passbookEnabled,
      'chequebookEnabled': chequebookEnabled,
      'directBankingEnabled': directBankingEnabled,
    };
  }
}

class AccountRestrictions {
  final bool noDebit;
  final bool noCredit;
  final bool noStopPayment;

  AccountRestrictions({
    required this.noDebit,
    required this.noCredit,
    required this.noStopPayment,
  });

  factory AccountRestrictions.fromJson(Map<String, dynamic> json) {
    return AccountRestrictions(
      noDebit: json['noDebit'] ?? false,
      noCredit: json['noCredit'] ?? false,
      noStopPayment: json['noStopPayment'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'noDebit': noDebit,
      'noCredit': noCredit,
      'noStopPayment': noStopPayment,
    };
  }

  bool get hasRestrictions => noDebit || noCredit || noStopPayment;
  
  List<String> get restrictionsList {
    List<String> restrictions = [];
    if (noDebit) restrictions.add('No Debit');
    if (noCredit) restrictions.add('No Credit');
    if (noStopPayment) restrictions.add('No Stop Payment');
    return restrictions;
  }
}

// Helper class for recipient validation response
class RecipientValidationResponse {
  final bool success;
  final bool valid;
  final RecipientInfo? recipient;
  final String? error;
  final String? message;

  RecipientValidationResponse({
    required this.success,
    required this.valid,
    this.recipient,
    this.error,
    this.message,
  });

  factory RecipientValidationResponse.fromJson(Map<String, dynamic> json) {
    return RecipientValidationResponse(
      success: json['success'] ?? false,
      valid: json['valid'] ?? false,
      recipient: json['recipient'] != null 
          ? RecipientInfo.fromJson(json['recipient']) 
          : null,
      error: json['error'],
      message: json['message'],
    );
  }
}

class RecipientInfo {
  final String accountNumber;
  final String accountHolderName;
  final String bankName;
  final String accountStatus;
  final bool canReceive;

  RecipientInfo({
    required this.accountNumber,
    required this.accountHolderName,
    required this.bankName,
    required this.accountStatus,
    required this.canReceive,
  });

  factory RecipientInfo.fromJson(Map<String, dynamic> json) {
    return RecipientInfo(
      accountNumber: json['accountNumber'] ?? '',
      accountHolderName: json['accountHolderName'] ?? '',
      bankName: json['bankName'] ?? '',
      accountStatus: json['accountStatus'] ?? '',
      canReceive: json['canReceive'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accountNumber': accountNumber,
      'accountHolderName': accountHolderName,
      'bankName': bankName,
      'accountStatus': accountStatus,
      'canReceive': canReceive,
    };
  }
}