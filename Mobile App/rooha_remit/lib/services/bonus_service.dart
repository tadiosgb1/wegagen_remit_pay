/// Bonus calculation for remittance transfers in Ethiopian Birr (ETB) only
/// The bonus is ALWAYS calculated and displayed in ETB regardless of sender currency
class BonusCalculator {
  static const double bonusPercentage = 10.0; // 10% bonus
  static const String bonusCurrency = 'ETB'; // Bonus ALWAYS in ETB

  /// Calculate bonus for remittance transfers
  /// [senderAmount] - Amount sender is sending in their currency
  /// [senderCurrency] - Currency sender is using (USD, EUR, etc.)
  /// [exchangeRate] - Rate to convert sender currency to ETB
  static BonusCalculation calculateBonus({
    required double senderAmount,
    required String senderCurrency,
    required double exchangeRate,
  }) {
    // Step 1: Convert sender amount to ETB
    double baseETBAmount = senderAmount * exchangeRate;
    
    // Step 2: Calculate 10% bonus in ETB (always in ETB regardless of sender currency)
    double bonusAmountETB = baseETBAmount * (bonusPercentage / 100);
    
    // Step 3: Calculate total recipient gets in ETB
    double totalRecipientETB = baseETBAmount + bonusAmountETB;
    
    return BonusCalculation(
      senderAmount: senderAmount,
      senderCurrency: senderCurrency,
      exchangeRate: exchangeRate,
      baseAmountETB: baseETBAmount,
      bonusAmountETB: bonusAmountETB,
      bonusPercentage: bonusPercentage,
      totalRecipientETB: totalRecipientETB,
    );
  }
  
  /// Check if bonus applies (sender not using ETB)
  static bool bonusApplies(String senderCurrency) {
    return senderCurrency.toUpperCase() != 'ETB';
  }
  
  /// Get formatted bonus text for display
  static String getFormattedBonusText(double bonusAmountETB) {
    return '+${bonusAmountETB.toStringAsFixed(2)} ETB (10% Bonus)';
  }
  
  /// Get formatted total display text
  static String getFormattedTotalText(double totalETB) {
    return '${totalETB.toStringAsFixed(2)} ETB (Total with Bonus)';
  }
}

/// Result of bonus calculation with all display information
class BonusCalculation {
  final double senderAmount;
  final String senderCurrency;
  final double exchangeRate;
  final double baseAmountETB;
  final double bonusAmountETB;
  final double bonusPercentage;
  final double totalRecipientETB;
  
  const BonusCalculation({
    required this.senderAmount,
    required this.senderCurrency,
    required this.exchangeRate,
    required this.baseAmountETB,
    required this.bonusAmountETB,
    required this.bonusPercentage,
    required this.totalRecipientETB,
  });
  
  /// What sender sends (in their currency)
  String get formattedSenderAmount {
    return '${senderAmount.toStringAsFixed(2)} $senderCurrency';
  }
  
  /// Base ETB amount (before bonus)
  String get formattedBaseETB {
    return '${baseAmountETB.toStringAsFixed(2)} ETB';
  }
  
  /// Bonus amount (always in ETB)
  String get formattedBonusETB {
    return '+${bonusAmountETB.toStringAsFixed(2)} ETB';
  }
  
  /// Total recipient gets (in ETB)
  String get formattedTotalETB {
    return '${totalRecipientETB.toStringAsFixed(2)} ETB';
  }
  
  /// Exchange rate display
  String get formattedExchangeRate {
    return '1 $senderCurrency = ${exchangeRate.toStringAsFixed(2)} ETB';
  }
  
  /// Check if bonus applies
  bool get hasBonusApplicable {
    return BonusCalculator.bonusApplies(senderCurrency);
  }
  
  @override
  String toString() {
    return 'BonusCalculation(sender: $formattedSenderAmount, '
           'base: $formattedBaseETB, bonus: $formattedBonusETB, '
           'total: $formattedTotalETB)';
  }
}