import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/exchange_rate_provider.dart';
import '../../providers/bonus_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/bonus_calculation_service.dart';
import '../../widgets/auth_guard.dart';
import '../../models/kyc_data.dart';
import '../kyc_requirement_screen.dart';
import 'recipient_details_screen.dart';
import '../../constants/colors.dart';

class AmountEntryScreen extends StatefulWidget {
  final String transferType;
  final String selectedCurrency;
  final String? selectedBank;

  const AmountEntryScreen({
    super.key,
    required this.transferType,
    required this.selectedCurrency,
    this.selectedBank,
  });

  @override
  State<AmountEntryScreen> createState() => _AmountEntryScreenState();
}

class _AmountEntryScreenState extends State<AmountEntryScreen> {
  final _amountController = TextEditingController();
  double _etbAmount = 0.0;
  double _bonusAmount = 0.0;
  double _baseAmount = 0.0;
  double _exchangeRate = 0.0;
  TransferCalculationResult? _calculationResult;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_calculateAmount);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDataAndCalculate();
    });
  }

  Future<void> _loadDataAndCalculate() async {
    final bonusProvider = Provider.of<BonusProvider>(context, listen: false);
    final exchangeProvider =
        Provider.of<ExchangeRateProvider>(context, listen: false);

    // Load bonuses and exchange rates
    await Future.wait([
      bonusProvider.loadBonuses(),
      if (exchangeProvider.exchangeRates.isEmpty)
        exchangeProvider.loadExchangeRates(),
    ]);

    _exchangeRate =
        exchangeProvider.getRate(widget.selectedCurrency, 'ETB') ?? 0.0;
    _calculateAmount();
  }

  void _calculateAmount() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;

    if (amount > 0) {
      final bonusProvider = Provider.of<BonusProvider>(context, listen: false);
      final exchangeProvider =
          Provider.of<ExchangeRateProvider>(context, listen: false);

      final calculationService = BonusCalculationService(
        bonusProvider: bonusProvider,
        exchangeRateProvider: exchangeProvider,
      );

      final result = calculationService.calculateTransferAmount(
        foreignAmount: amount,
        fromCurrency: widget.selectedCurrency,
        toCurrency: 'ETB',
      );

      setState(() {
        _calculationResult = result;
        if (result.isSuccess) {
          _baseAmount = result.baseAmountETB;
          _bonusAmount = result.bonusAmountETB;
          _etbAmount = result.totalAmountETB;
          _exchangeRate = result.exchangeRate;
        } else {
          _baseAmount = 0.0;
          _bonusAmount = 0.0;
          _etbAmount = 0.0;
        }
      });
    } else {
      setState(() {
        _calculationResult = null;
        _baseAmount = 0.0;
        _bonusAmount = 0.0;
        _etbAmount = 0.0;
      });
    }
  }

  String get _transferTitle {
    switch (widget.transferType) {
      case 'wegagen_bank':
        return 'Wegagen Bank Transfer';
      case 'rooha_ebirr':
        return 'Rooha E-birr Transfer';
      case 'cash_pickup':
        return 'Cash Pickup Transfer';
      case 'other_banks':
        return 'Other Banks Transfer';
      case 'school_pay':
        return 'School Payment';
      default:
        return 'Money Transfer';
    }
  }

  IconData get _transferIcon {
    switch (widget.transferType) {
      case 'wegagen_bank':
        return Icons.account_balance;
      case 'rooha_ebirr':
        return Icons.phone_android;
      case 'cash_pickup':
        return Icons.send;
      case 'other_banks':
        return Icons.account_balance_outlined;
      case 'school_pay':
        return Icons.school;
      default:
        return Icons.send;
    }
  }

  String _getCurrencyFlag(String code) {
    switch (code) {
      case 'USD':
        return '🇺🇸';
      case 'EUR':
        return '🇪🇺';
      case 'GBP':
        return '🇬🇧';
      case 'SAR':
        return '🇸🇦';
      case 'AED':
        return '🇦🇪';
      default:
        return '💱';
    }
  }

  Widget _buildProgressStep(bool isActive) {
    return Container(
      width: isActive ? 28 : 8,
      height: 4,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  // ==================== IMPORTANT: KYC & Navigation Logic ====================
  Future<void> _proceedToRecipientDetails() async {
    if (_amountController.text.isNotEmpty && _etbAmount > 0) {
      final amount = double.parse(_amountController.text);
      if (amount >= 10) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final user = authProvider.user;

        if (mounted) {
          if (user?.kyc != null && user!.kyc!.verified) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => RecipientDetailsScreen(
                  transferType: widget.transferType,
                  amount: amount,
                  currency: widget.selectedCurrency,
                  etbAmount: _etbAmount,
                  fee: _bonusAmount,
                  exchangeRate: _exchangeRate,
                  selectedBank: widget.selectedBank,
                ),
              ),
            );
          } else {
            KycStatus kycStatus = user?.kyc == null
                ? KycStatus.notStarted
                : !user!.kyc!.verified
                    ? KycStatus.underReview
                    : KycStatus.approved;

            final result = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => KycRequirementScreen(
                  transferType: widget.transferType,
                  amount: amount,
                  currency: widget.selectedCurrency,
                  etbAmount: _etbAmount,
                  fee: _bonusAmount,
                  exchangeRate: _exchangeRate,
                  kycStatus: kycStatus,
                ),
              ),
            );

            if (result == true && mounted) {
              final updatedUser = authProvider.user;
              if (updatedUser?.kyc != null && updatedUser!.kyc!.verified) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => RecipientDetailsScreen(
                      transferType: widget.transferType,
                      amount: amount,
                      currency: widget.selectedCurrency,
                      etbAmount: _etbAmount,
                      fee: _bonusAmount,
                      exchangeRate: _exchangeRate,
                      selectedBank: widget.selectedBank,
                    ),
                  ),
                );
              }
            }
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFlag = _getCurrencyFlag(widget.selectedCurrency);

    return AuthGuard(
      redirectMessage: 'Please login to continue with your transfer',
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_transferIcon, size: 22, color: Colors.black87),
              const SizedBox(width: 10),
              Text(
                _transferTitle,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Progress Indicator
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildProgressStep(true),
                    const SizedBox(width: 6),
                    _buildProgressStep(true),
                    const SizedBox(width: 6),
                    _buildProgressStep(false),
                    const SizedBox(width: 6),
                    _buildProgressStep(false),
                  ],
                ),
              ),

              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Enter Amount',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'How much would you like to send?',
                        style: TextStyle(
                            fontSize: 16, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 32),

                      // Amount Input Card
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withValues(alpha: 0.12),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Text(currencyFlag,
                                      style: const TextStyle(fontSize: 32)),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextField(
                                    controller: _amountController,
                                    keyboardType:
                                        TextInputType.numberWithOptions(
                                            decimal: true),
                                    style: const TextStyle(
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold),
                                    decoration: InputDecoration(
                                      hintText: '0.00',
                                      hintStyle: TextStyle(
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade300,
                                      ),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                                Text(
                                  widget.selectedCurrency,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 32),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Total Amount',
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey.shade600)),
                                Row(
                                  children: [
                                    Text(
                                      _etbAmount > 0
                                          ? _etbAmount.toStringAsFixed(2)
                                          : '0.00',
                                      style: const TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Text('ETB',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey)),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Fee Breakdown
                      if (_etbAmount > 0)
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.grey.withValues(alpha: 0.1),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4)),
                            ],
                          ),
                          child: Column(
                            children: [
                              const Text('Breakdown',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 16),
                              _buildFeeRow('You send',
                                  '${_amountController.text} ${widget.selectedCurrency}'),
                              const Divider(),
                              _buildFeeRow('Bonus',
                                  '${_bonusAmount.toStringAsFixed(2)} ETB'),
                              const Divider(),
                              _buildFeeRow(
                                  'Total (ETB)', _etbAmount.toStringAsFixed(2),
                                  isTotal: true),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Fixed Bottom Button
              Container(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 12,
                        offset: const Offset(0, -4)),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: _etbAmount > 0 &&
                            double.tryParse(_amountController.text) != null &&
                            double.parse(_amountController.text) >= 10
                        ? _proceedToRecipientDetails
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textOnPrimary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18)),
                      elevation: 0,
                    ),
                    child: const Text('Continue',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeeRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: isTotal ? Colors.black87 : Colors.grey.shade700,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: isTotal ? AppColors.primary : Colors.black87,
          ),
        ),
      ],
    );
  }
}
