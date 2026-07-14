import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/bonus_provider.dart';
import '../../providers/exchange_rate_provider.dart';
import '../../services/bonus_calculation_service.dart';

class BonusCalculationDemoScreen extends StatefulWidget {
  const BonusCalculationDemoScreen({super.key});

  @override
  State<BonusCalculationDemoScreen> createState() => _BonusCalculationDemoScreenState();
}

class _BonusCalculationDemoScreenState extends State<BonusCalculationDemoScreen> {
  final _amountController = TextEditingController(text: '100');
  String _selectedCurrency = 'USD';
  TransferCalculationResult? _calculationResult;

  final List<String> _currencies = ['USD', 'EUR', 'GBP', 'SAR', 'AED'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final bonusProvider = Provider.of<BonusProvider>(context, listen: false);
    final exchangeProvider = Provider.of<ExchangeRateProvider>(context, listen: false);

    // Load bonuses and exchange rates
    await Future.wait([
      bonusProvider.loadBonuses(),
      exchangeProvider.loadExchangeRates(),
    ]);

    _calculateAmount();
  }

  void _calculateAmount() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) {
      setState(() {
        _calculationResult = null;
      });
      return;
    }

    final bonusProvider = Provider.of<BonusProvider>(context, listen: false);
    final exchangeProvider = Provider.of<ExchangeRateProvider>(context, listen: false);

    final calculationService = BonusCalculationService(
      bonusProvider: bonusProvider,
      exchangeRateProvider: exchangeProvider,
    );

    final result = calculationService.calculateTransferAmount(
      foreignAmount: amount,
      fromCurrency: _selectedCurrency,
      toCurrency: 'ETB',
    );

    setState(() {
      _calculationResult = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Dynamic Bonus Calculator',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF37021), Color(0xFFE55A00)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calculate,
                        color: Colors.white,
                        size: 24,
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dynamic Bonus System',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Fixed ETB bonus per foreign currency unit',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Input Section
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Calculate Transfer Amount',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Amount Input
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Amount',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (_) => _calculateAmount(),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedCurrency,
                            decoration: const InputDecoration(
                              labelText: 'Currency',
                              border: OutlineInputBorder(),
                            ),
                            items: _currencies.map((currency) {
                              return DropdownMenuItem(
                                value: currency,
                                child: Text(currency),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedCurrency = value!;
                              });
                              _calculateAmount();
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Calculate Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _calculateAmount,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF37021),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Recalculate'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Bonus Status
            Consumer<BonusProvider>(
              builder: (context, bonusProvider, child) {
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.card_giftcard,
                              color: bonusProvider.hasBonusActive ? Colors.green : Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Bonus Status',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: bonusProvider.hasBonusActive ? Colors.green : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        if (bonusProvider.isLoading)
                          const Center(child: CircularProgressIndicator())
                        else if (bonusProvider.error != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error, color: Colors.red.shade600),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Error: ${bonusProvider.error}',
                                    style: TextStyle(color: Colors.red.shade700),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else if (bonusProvider.bonuses.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.orange.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info, color: Colors.orange.shade600),
                                const SizedBox(width: 8),
                                const Text('No bonuses available'),
                              ],
                            ),
                          )
                        else
                          Column(
                            children: bonusProvider.bonuses.map((bonus) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: bonus.status ? Colors.green.shade50 : Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: bonus.status ? Colors.green.shade200 : Colors.grey.shade300,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      bonus.status ? Icons.check_circle : Icons.cancel,
                                      color: bonus.status ? Colors.green : Colors.grey,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            bonus.description,
                                            style: const TextStyle(fontWeight: FontWeight.w600),
                                          ),
                                          Text(
                                            '+${bonus.amount.toStringAsFixed(2)} ETB per unit',
                                            style: TextStyle(
                                              color: bonus.status ? Colors.green.shade700 : Colors.grey.shade600,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: bonus.status ? Colors.green : Colors.grey,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        bonus.status ? 'ACTIVE' : 'INACTIVE',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),

                        const SizedBox(height: 16),
                        
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              bonusProvider.refreshBonuses();
                            },
                            child: const Text('Refresh Bonuses'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Calculation Result
            if (_calculationResult != null) ...[
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.receipt_long,
                            color: Color(0xFFF37021),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Calculation Result',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      if (!_calculationResult!.isSuccess)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error, color: Colors.red.shade600),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _calculationResult!.errorMessage!,
                                  style: TextStyle(color: Colors.red.shade700),
                                ),
                              ),
                            ],
                          ),
                        )
                      else ...[
                        _buildCalculationRow(
                          '💸 Send Amount',
                          '${_calculationResult!.foreignAmount.toStringAsFixed(2)} ${_calculationResult!.fromCurrency}',
                          isHeader: true,
                        ),
                        _buildCalculationRow(
                          '📈 Exchange Rate',
                          '${_calculationResult!.exchangeRate.toStringAsFixed(2)} ETB per ${_calculationResult!.fromCurrency}',
                        ),
                        _buildCalculationRow(
                          '💰 Base Amount',
                          '${_calculationResult!.baseAmountETB.toStringAsFixed(2)} ETB',
                        ),
                        if (_calculationResult!.hasBonusActive && _calculationResult!.bonusAmountETB > 0)
                          _buildCalculationRow(
                            '🎁 Bonus Amount',
                            '+${_calculationResult!.bonusAmountETB.toStringAsFixed(2)} ETB',
                            isBonus: true,
                          ),
                        const Divider(),
                        _buildCalculationRow(
                          '📥 Total Amount',
                          '${_calculationResult!.totalAmountETB.toStringAsFixed(2)} ETB',
                          isTotal: true,
                        ),

                        if (_calculationResult!.hasBonusActive) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.celebration, color: Colors.green.shade600),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _calculationResult!.bonusDescription,
                                    style: TextStyle(
                                      color: Colors.green.shade700,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCalculationRow(
    String label,
    String value, {
    bool isHeader = false,
    bool isBonus = false,
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isHeader || isTotal ? FontWeight.bold : FontWeight.normal,
              color: isBonus ? Colors.green.shade700 : Colors.black87,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isHeader || isTotal ? FontWeight.bold : FontWeight.w600,
              color: isBonus 
                  ? Colors.green.shade700 
                  : isTotal 
                      ? const Color(0xFFF37021)
                      : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
}