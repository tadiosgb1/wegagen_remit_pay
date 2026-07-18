import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/bonus_service.dart';
import '../widgets/bonus_display_widget.dart';
import '../providers/exchange_rate_provider.dart';
import '../constants/colors.dart';

/// Demo screen to showcase the ETB bonus system
class BonusDemoScreen extends ConsumerStatefulWidget {
  const BonusDemoScreen({super.key});

  @override
  ConsumerState<BonusDemoScreen> createState() => _BonusDemoScreenState();
}

class _BonusDemoScreenState extends ConsumerState<BonusDemoScreen> {
  double senderAmount = 100.0;
  String selectedCurrency = 'USD';
  
  final List<String> currencies = ['USD', 'EUR', 'GBP', 'SAR', 'AED', 'ETB'];
  final Map<String, double> exchangeRates = {
    'USD': 128.97,
    'EUR': 139.18,
    'GBP': 166.60,
    'SAR': 34.32,
    'AED': 35.12,
    'ETB': 1.0, // No conversion for ETB
  };

  @override
  Widget build(BuildContext context) {
    // Calculate bonus for current selection
    BonusCalculation? bonusCalculation;
    if (senderAmount > 0 && exchangeRates[selectedCurrency] != null) {
      if (BonusCalculator.bonusApplies(selectedCurrency)) {
        bonusCalculation = BonusCalculator.calculateBonus(
          senderAmount: senderAmount,
          senderCurrency: selectedCurrency,
          exchangeRate: exchangeRates[selectedCurrency]!,
        );
      }
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Bonus Calculator Demo'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade600),
                      const SizedBox(width: 8),
                      const Text(
                        'How the Bonus Works:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '• 10% bonus ALWAYS calculated and displayed in Ethiopian Birr (ETB)\n'
                    '• Bonus only applies when sending in foreign currencies (USD, EUR, etc.)\n'
                    '• No bonus when sending ETB to ETB\n'
                    '• Recipient gets: Base ETB amount + 10% bonus in ETB',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Input Controls
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Test Different Amounts & Currencies',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Amount Input
                  TextFormField(
                    initialValue: senderAmount.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Amount to Send',
                      prefixIcon: Icon(Icons.payments),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        senderAmount = double.tryParse(value) ?? 0.0;
                      });
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Currency Selection
                  DropdownButtonFormField<String>(
                    value: selectedCurrency,
                    decoration: const InputDecoration(
                      labelText: 'Sending Currency',
                      prefixIcon: Icon(Icons.monetization_on),
                      border: OutlineInputBorder(),
                    ),
                    items: currencies.map((currency) {
                      return DropdownMenuItem(
                        value: currency,
                        child: Row(
                          children: [
                            Text(currency),
                            const SizedBox(width: 8),
                            Text(
                              currency == 'ETB' 
                                ? '(No bonus)'
                                : '(1 $currency = ${exchangeRates[currency]?.toStringAsFixed(2)} ETB)',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedCurrency = value;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Results Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Calculation Result',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  if (selectedCurrency == 'ETB') ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info, color: Colors.orange.shade600),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'No bonus applies when sending ETB to ETB. '
                              'Bonus is only for foreign currency transfers.',
                              style: TextStyle(
                                color: Colors.orange.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSummaryRow(
                      'Sender Sends:', 
                      '${senderAmount.toStringAsFixed(2)} ETB'
                    ),
                    const SizedBox(height: 8),
                    _buildSummaryRow(
                      'Recipient Gets:', 
                      '${senderAmount.toStringAsFixed(2)} ETB',
                      isTotal: true,
                    ),
                  ] else if (bonusCalculation != null) ...[
                    _buildSummaryRow(
                      'Sender Sends:', 
                      bonusCalculation.formattedSenderAmount
                    ),
                    const SizedBox(height: 8),
                    _buildSummaryRow(
                      'Exchange Rate:', 
                      bonusCalculation.formattedExchangeRate
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    _buildSummaryRow(
                      'Base Amount (ETB):', 
                      bonusCalculation.formattedBaseETB
                    ),
                    const SizedBox(height: 8),
                    _buildSummaryRow(
                      'Bonus (10% in ETB):', 
                      bonusCalculation.formattedBonusETB,
                      isBonus: true,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _buildSummaryRow(
                        'Total Recipient Gets:', 
                        bonusCalculation.formattedTotalETB,
                        isTotal: true,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Bonus Display Widget Demo
            if (bonusCalculation != null) ...[
              const Text(
                'Bonus Display Widget:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              BonusDisplayWidget(
                bonusCalculation: bonusCalculation,
                showDetailed: true,
              ),
              
              const SizedBox(height: 16),
              
              const Text(
                'Compact Version:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              CompactBonusDisplay(
                bonusCalculation: bonusCalculation,
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildSummaryRow(
    String label, 
    String value, {
    bool isTotal = false,
    bool isBonus = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isTotal ? AppColors.primary : Colors.grey.shade600,
          ),
        ),
        Row(
          children: [
            if (isBonus) ...[
              Icon(
                Icons.add_circle,
                color: Colors.green.shade600,
                size: 16,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              value,
              style: TextStyle(
                fontSize: isTotal ? 16 : 14,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
                color: isTotal 
                  ? AppColors.primary 
                  : isBonus 
                    ? Colors.green.shade600 
                    : Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }
}