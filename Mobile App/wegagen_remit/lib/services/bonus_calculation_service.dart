import 'package:flutter/material.dart';
import '../providers/bonus_provider.dart';
import '../providers/exchange_rate_provider.dart';

class BonusCalculationService {
  final BonusProvider bonusProvider;
  final ExchangeRateProvider exchangeRateProvider;

  BonusCalculationService({
    required this.bonusProvider,
    required this.exchangeRateProvider,
  });

  /// Calculate the complete transfer amount with exchange rate and bonus
  /// 
  /// Formula: Final Amount = (Foreign Amount × Exchange Rate) + (Foreign Amount × Bonus per Unit)
  /// 
  /// Example:
  /// - Send: 100 USD
  /// - Exchange Rate: 130 ETB per USD  
  /// - Bonus: 5 ETB per USD
  /// - Final Amount: (100 × 130) + (100 × 5) = 13,000 + 500 = 13,500 ETB
  TransferCalculationResult calculateTransferAmount({
    required double foreignAmount,
    required String fromCurrency,
    required String toCurrency,
  }) {
    // Validate inputs
    if (foreignAmount <= 0) {
      return TransferCalculationResult.error('Amount must be greater than zero');
    }

    if (toCurrency != 'ETB') {
      return TransferCalculationResult.error('Only transfers to ETB are supported');
    }

    // Get exchange rate
    final exchangeRate = exchangeRateProvider.getExchangeRate(fromCurrency);
    if (exchangeRate == null) {
      return TransferCalculationResult.error('Exchange rate not available for $fromCurrency');
    }

    // Use selling rate (what bank charges for foreign currency)
    final rate = exchangeRate.sellingRate;
    
    // Calculate base amount in ETB
    final baseAmountETB = foreignAmount * rate;
    
    // Calculate bonus amount in ETB (fixed amount per foreign currency unit)
    final bonusAmountETB = bonusProvider.calculateBonusAmount(foreignAmount, fromCurrency);
    
    // Calculate total
    final totalAmountETB = baseAmountETB + bonusAmountETB;

    debugPrint('🧮 Transfer Calculation:');
    debugPrint('   📤 Send: $foreignAmount $fromCurrency');
    debugPrint('   📈 Exchange Rate: $rate ETB per $fromCurrency');
    debugPrint('   💰 Base Amount: ${baseAmountETB.toStringAsFixed(2)} ETB');
    debugPrint('   🎁 Bonus: ${bonusAmountETB.toStringAsFixed(2)} ETB');
    debugPrint('   📥 Total Receive: ${totalAmountETB.toStringAsFixed(2)} ETB');

    return TransferCalculationResult.success(
      foreignAmount: foreignAmount,
      fromCurrency: fromCurrency,
      toCurrency: toCurrency,
      exchangeRate: rate,
      baseAmountETB: baseAmountETB,
      bonusAmountETB: bonusAmountETB,
      totalAmountETB: totalAmountETB,
      bonusDescription: bonusProvider.getBonusDescription(),
      hasBonusActive: bonusProvider.hasBonusActive,
    );
  }

  /// Calculate what the recipient will receive after all fees
  TransferCalculationResult calculateRecipientAmount({
    required double foreignAmount,
    required String fromCurrency,
    required String toCurrency,
    double transferFee = 0.0,
    double processingFee = 0.0,
  }) {
    final result = calculateTransferAmount(
      foreignAmount: foreignAmount,
      fromCurrency: fromCurrency,
      toCurrency: toCurrency,
    );

    if (!result.isSuccess) {
      return result;
    }

    // Subtract fees from total (fees are usually in ETB)
    final totalFees = transferFee + processingFee;
    final finalRecipientAmount = result.totalAmountETB - totalFees;

    debugPrint('💸 Fee Calculation:');
    debugPrint('   🧾 Transfer Fee: ${transferFee.toStringAsFixed(2)} ETB');
    debugPrint('   ⚙️ Processing Fee: ${processingFee.toStringAsFixed(2)} ETB');
    debugPrint('   📊 Total Fees: ${totalFees.toStringAsFixed(2)} ETB');
    debugPrint('   👤 Recipient Gets: ${finalRecipientAmount.toStringAsFixed(2)} ETB');

    return TransferCalculationResult.success(
      foreignAmount: result.foreignAmount,
      fromCurrency: result.fromCurrency,
      toCurrency: result.toCurrency,
      exchangeRate: result.exchangeRate,
      baseAmountETB: result.baseAmountETB,
      bonusAmountETB: result.bonusAmountETB,
      totalAmountETB: finalRecipientAmount, // Amount after fees
      transferFee: transferFee,
      processingFee: processingFee,
      bonusDescription: result.bonusDescription,
      hasBonusActive: result.hasBonusActive,
    );
  }

  /// Format calculation for display in UI
  String formatCalculationSummary(TransferCalculationResult result) {
    if (!result.isSuccess) {
      return 'Calculation Error: ${result.errorMessage}';
    }

    final buffer = StringBuffer();
    buffer.writeln('💸 Send: ${result.foreignAmount.toStringAsFixed(2)} ${result.fromCurrency}');
    buffer.writeln('📈 Rate: ${result.exchangeRate.toStringAsFixed(2)} ETB per ${result.fromCurrency}');
    buffer.writeln('💰 Base: ${result.baseAmountETB.toStringAsFixed(2)} ETB');
    
    if (result.hasBonusActive && result.bonusAmountETB > 0) {
      buffer.writeln('🎁 Bonus: +${result.bonusAmountETB.toStringAsFixed(2)} ETB');
    }
    
    if (result.transferFee > 0 || result.processingFee > 0) {
      final totalFees = result.transferFee + result.processingFee;
      buffer.writeln('💸 Fees: -${totalFees.toStringAsFixed(2)} ETB');
    }
    
    buffer.writeln('📥 Total: ${result.totalAmountETB.toStringAsFixed(2)} ETB');
    
    return buffer.toString();
  }
}

/// Result of transfer calculation
class TransferCalculationResult {
  final bool isSuccess;
  final String? errorMessage;
  
  final double foreignAmount;
  final String fromCurrency;
  final String toCurrency;
  final double exchangeRate;
  final double baseAmountETB;
  final double bonusAmountETB;
  final double totalAmountETB;
  final double transferFee;
  final double processingFee;
  final String bonusDescription;
  final bool hasBonusActive;

  TransferCalculationResult._({
    required this.isSuccess,
    this.errorMessage,
    this.foreignAmount = 0.0,
    this.fromCurrency = '',
    this.toCurrency = '',
    this.exchangeRate = 0.0,
    this.baseAmountETB = 0.0,
    this.bonusAmountETB = 0.0,
    this.totalAmountETB = 0.0,
    this.transferFee = 0.0,
    this.processingFee = 0.0,
    this.bonusDescription = '',
    this.hasBonusActive = false,
  });

  factory TransferCalculationResult.success({
    required double foreignAmount,
    required String fromCurrency,
    required String toCurrency,
    required double exchangeRate,
    required double baseAmountETB,
    required double bonusAmountETB,
    required double totalAmountETB,
    double transferFee = 0.0,
    double processingFee = 0.0,
    required String bonusDescription,
    required bool hasBonusActive,
  }) {
    return TransferCalculationResult._(
      isSuccess: true,
      foreignAmount: foreignAmount,
      fromCurrency: fromCurrency,
      toCurrency: toCurrency,
      exchangeRate: exchangeRate,
      baseAmountETB: baseAmountETB,
      bonusAmountETB: bonusAmountETB,
      totalAmountETB: totalAmountETB,
      transferFee: transferFee,
      processingFee: processingFee,
      bonusDescription: bonusDescription,
      hasBonusActive: hasBonusActive,
    );
  }

  factory TransferCalculationResult.error(String message) {
    return TransferCalculationResult._(
      isSuccess: false,
      errorMessage: message,
    );
  }
}