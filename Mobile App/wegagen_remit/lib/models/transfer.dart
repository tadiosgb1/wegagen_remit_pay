enum TransferType {
  wegagenBank,
  wegagenEbirr, 
  cashPickup,
  schoolPay,
  don, // Add support for "don" channel from API
}

enum TransferStatus {
  pending,
  processing,
  completed,
  failed,
  cancelled,
}

class Transfer {
  final int id;
  final String transactionRef;
  final TransferType type;
  final double amount;
  final String currency;
  final double? exchangeRate;
  final String recipientAccount;
  final String recipientName;
  final Map<String, dynamic>? senderInfo;
  final TransferStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? pickupCode;
  final String? failureReason;

  Transfer({
    required this.id,
    required this.transactionRef,
    required this.type,
    required this.amount,
    required this.currency,
    this.exchangeRate,
    required this.recipientAccount,
    required this.recipientName,
    this.senderInfo,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.pickupCode,
    this.failureReason,
  });

  // Helper getters for backward compatibility
  String get fromCurrency => currency;
  double get etbAmount => currency == 'ETB' ? amount : (exchangeRate != null ? amount * exchangeRate! : amount);
  double get fee => 0.0; // Calculate fee if needed
  Map<String, dynamic> get recipientDetails => {
    'account': recipientAccount,
    'name': recipientName,
  };

  factory Transfer.fromJson(Map<String, dynamic> json) {
    // Map API response fields to Transfer model
    TransferType transferType;
    switch (json['channel']?.toLowerCase()) {
      case 'don':
        transferType = TransferType.don;
        break;
      case 'wegagen_bank':
        transferType = TransferType.wegagenBank;
        break;
      case 'wegagen_ebirr':
        transferType = TransferType.wegagenEbirr;
        break;
      case 'cash_pickup':
        transferType = TransferType.cashPickup;
        break;
      default:
        transferType = TransferType.don; // Default fallback
    }

    TransferStatus transferStatus;
    switch (json['status']?.toUpperCase()) {
      case 'PENDING':
        transferStatus = TransferStatus.pending;
        break;
      case 'PROCESSING':
        transferStatus = TransferStatus.processing;
        break;
      case 'COMPLETED':
        transferStatus = TransferStatus.completed;
        break;
      case 'FAILED':
        transferStatus = TransferStatus.failed;
        break;
      case 'CANCELLED':
        transferStatus = TransferStatus.cancelled;
        break;
      default:
        transferStatus = TransferStatus.pending;
    }

    return Transfer(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      transactionRef: json['transaction_ref'] ?? '',
      type: transferType,
      amount: double.parse(json['amount'].toString()),
      currency: json['currency'] ?? 'ETB',
      exchangeRate: json['exchange_rate'] != null ? double.parse(json['exchange_rate'].toString()) : null,
      recipientAccount: json['beneficiary_acc'] ?? '',
      recipientName: _getRecipientName(json),
      senderInfo: json['sender'] as Map<String, dynamic>?,
      status: transferStatus,
      createdAt: DateTime.parse(json['created_at']),
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at']) : null,
      pickupCode: json['pickup_code'],
      failureReason: json['failure_reason'],
    );
  }

  static String _getRecipientName(Map<String, dynamic> json) {
    // Try to get recipient name from various possible fields
    if (json['recipient_name'] != null) return json['recipient_name'];
    if (json['beneficiary_name'] != null) return json['beneficiary_name'];
    if (json['beneficiary_acc'] != null) return json['beneficiary_acc'];
    return 'Unknown Recipient';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transaction_ref': transactionRef,
      'channel': type.toString().split('.').last,
      'amount': amount.toString(),
      'currency': currency,
      'exchange_rate': exchangeRate?.toString(),
      'beneficiary_acc': recipientAccount,
      'recipient_name': recipientName,
      'sender': senderInfo,
      'status': status.toString().split('.').last.toUpperCase(),
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'pickup_code': pickupCode,
      'failure_reason': failureReason,
    };
  }
}
