enum TransferType {
  wegagenBank,
  wegagenEbirr,
  cashPickup,
  schoolPay,
}

enum TransferStatus {
  pending,
  processing,
  completed,
  failed,
  cancelled,
}

class Transfer {
  final String id;
  final TransferType type;
  final double amount;
  final String fromCurrency;
  final double etbAmount;
  final double exchangeRate;
  final double fee;
  final String recipientName;
  final Map<String, dynamic> recipientDetails;
  final TransferStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? pickupCode;

  Transfer({
    required this.id,
    required this.type,
    required this.amount,
    required this.fromCurrency,
    required this.etbAmount,
    required this.exchangeRate,
    required this.fee,
    required this.recipientName,
    required this.recipientDetails,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.pickupCode,
  });

  factory Transfer.fromJson(Map<String, dynamic> json) {
    return Transfer(
      id: json['id'],
      type: TransferType.values.firstWhere(
        (e) => e.toString() == 'TransferType.${json['type']}',
      ),
      amount: json['amount'].toDouble(),
      fromCurrency: json['fromCurrency'],
      etbAmount: json['etbAmount'].toDouble(),
      exchangeRate: json['exchangeRate'].toDouble(),
      fee: json['fee'].toDouble(),
      recipientName: json['recipientName'],
      recipientDetails: Map<String, dynamic>.from(json['recipientDetails']),
      status: TransferStatus.values.firstWhere(
        (e) => e.toString() == 'TransferStatus.${json['status']}',
      ),
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt']) 
          : null,
      pickupCode: json['pickupCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'amount': amount,
      'fromCurrency': fromCurrency,
      'etbAmount': etbAmount,
      'exchangeRate': exchangeRate,
      'fee': fee,
      'recipientName': recipientName,
      'recipientDetails': recipientDetails,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'pickupCode': pickupCode,
    };
  }
}