class PaymentFormData {
  final String toAccountHolder;
  final String toAccount;
  final double amount;
  final String currency;
  final String remark;
  final double exchangeRate;

  const PaymentFormData({
    required this.toAccountHolder,
    required this.toAccount,
    required this.amount,
    required this.currency,
    required this.remark,
    required this.exchangeRate,
  });

  PaymentFormData copyWith({
    String? toAccountHolder,
    String? toAccount,
    double? amount,
    String? currency,
    String? remark,
    double? exchangeRate,
  }) {
    return PaymentFormData(
      toAccountHolder: toAccountHolder ?? this.toAccountHolder,
      toAccount: toAccount ?? this.toAccount,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      remark: remark ?? this.remark,
      exchangeRate: exchangeRate ?? this.exchangeRate,
    );
  }

  bool get isValid {
    return toAccountHolder.isNotEmpty &&
           toAccount.isNotEmpty &&
           amount > 0 &&
           currency.isNotEmpty &&
           remark.isNotEmpty &&
           exchangeRate > 0;
  }
}