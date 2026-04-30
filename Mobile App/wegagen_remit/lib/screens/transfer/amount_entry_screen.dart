import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/exchange_rate_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/auth_guard.dart';
import '../../models/kyc_data.dart';
import '../kyc_requirement_screen.dart';
import 'recipient_details_screen.dart';

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
  double _fee = 0.0;
  double _exchangeRate = 0.0;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_calculateAmount);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExchangeRate();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _loadExchangeRate() {
    final exchangeProvider = Provider.of<ExchangeRateProvider>(
      context,
      listen: false,
    );
    _exchangeRate =
        exchangeProvider.getRate(widget.selectedCurrency, 'ETB') ?? 0.0;
    _calculateAmount();
  }

  void _calculateAmount() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;

    if (amount > 0 && _exchangeRate > 0) {
      setState(() {
        _fee = _calculateFee(amount);
        _etbAmount = amount * _exchangeRate;
      });
    } else {
      setState(() {
        _etbAmount = 0.0;
        _fee = 0.0;
      });
    }
  }

  double _calculateFee(double amount) {
    // Simple fee calculation - 1% with min 4 and max 50
    double fee = amount * 0.01;
    if (fee < 4.0) fee = 4.0;
    if (fee > 50.0) fee = 50.0;
    return fee;
  }

  String get _transferTitle {
    switch (widget.transferType) {
      case 'wegagen_bank':
        return 'Bank Account Transfer';
      case 'wegagen_ebirr':
        return 'Wegagen E-birr Transfer';
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
      case 'wegagen_ebirr':
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

  Widget _buildProgressStep(bool isActive) {
    return Container(
      width: isActive ? 24 : 8,
      height: 4,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFF37021) : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildProgressConnector(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        color: isActive ? const Color(0xFFF37021) : Colors.grey.shade300,
      ),
    );
  }

  Future<void> _proceedToRecipientDetails() async {
    if (_amountController.text.isNotEmpty && _etbAmount > 0) {
      final amount = double.parse(_amountController.text);
      if (amount >= 10) {
        // Get user's KYC status from AuthProvider
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final user = authProvider.user;
        
        if (mounted) {
          if (user?.kyc != null && user!.kyc!.verified) {
            // KYC is verified, proceed to recipient details
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => RecipientDetailsScreen(
                  transferType: widget.transferType,
                  amount: amount,
                  currency: widget.selectedCurrency,
                  etbAmount: _etbAmount,
                  fee: _fee,
                  exchangeRate: _exchangeRate,
                  selectedBank: widget.selectedBank,
                ),
              ),
            );
          } else {
            // KYC not verified, show KYC requirement screen
            // Determine KYC status from user data
            KycStatus kycStatus;
            if (user?.kyc == null) {
              kycStatus = KycStatus.notStarted;
            } else if (!user!.kyc!.verified) {
              kycStatus = KycStatus.underReview;
            } else {
              kycStatus = KycStatus.approved;
            }
            
            final result = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => KycRequirementScreen(
                  transferType: widget.transferType,
                  amount: amount,
                  currency: widget.selectedCurrency,
                  etbAmount: _etbAmount,
                  fee: _fee,
                  exchangeRate: _exchangeRate,
                  kycStatus: kycStatus,
                ),
              ),
            );
            
            // If user completed KYC, check updated user data and proceed
            if (result == true) {
              // Refresh user data from AuthProvider
              final updatedUser = authProvider.user;
              if (updatedUser?.kyc != null && updatedUser!.kyc!.verified && mounted) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => RecipientDetailsScreen(
                      transferType: widget.transferType,
                      amount: amount,
                      currency: widget.selectedCurrency,
                      etbAmount: _etbAmount,
                      fee: _fee,
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
    return AuthGuard(
      redirectMessage: 'Please login to continue with your transfer',
      child: Scaffold(
      backgroundColor: Colors.grey.shade50,
      resizeToAvoidBottomInset: true,
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
            Icon(_transferIcon, size: 20, color: Colors.black87),
            const SizedBox(width: 8),
            Text(
              _transferTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            // Progress Indicator
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  _buildProgressStep(true),
                  _buildProgressConnector(true),
                  _buildProgressStep(true),
                  _buildProgressConnector(false),
                  _buildProgressStep(false),
                  _buildProgressConnector(false),
                  _buildProgressStep(false),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  24,
                  24,
                  24,
                  24 + MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Enter Amount',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sending with us ${widget.selectedCurrency == 'USD' ? 'US Dollar' : widget.selectedCurrency}',
                      style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                    ),

                    const SizedBox(height: 32),

                    // Amount Input Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'You send',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            decoration: InputDecoration(
                              hintText: '100',
                              hintStyle: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade300,
                              ),
                              border: InputBorder.none,
                              suffixText: widget.selectedCurrency,
                              suffixStyle: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),
                          const Divider(),
                          const SizedBox(height: 16),

                          Text(
                            'Recipient gets',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _etbAmount > 0
                                    ? _etbAmount.toStringAsFixed(2)
                                    : '0.00',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFF37021),
                                ),
                              ),
                              const Text(
                                'ETB',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Exchange Rate Info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Consumer<ExchangeRateProvider>(
                        builder: (context, exchangeProvider, child) {
                          final exchangeRate = exchangeProvider.getExchangeRate(widget.selectedCurrency);
                          
                          return Column(
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Colors.blue.shade600,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Exchange Rate',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.blue.shade700,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        if (exchangeRate != null)
                                          Text(
                                            '1 ${widget.selectedCurrency} = ${exchangeRate.buyingRate.toStringAsFixed(2)} ETB',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue.shade700,
                                            ),
                                          )
                                        else
                                          Text(
                                            '1 ${widget.selectedCurrency} = ${_exchangeRate.toStringAsFixed(2)} ETB',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.blue.shade700,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Fee Breakdown
                    if (_etbAmount > 0) ...[
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withValues(alpha: 0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Amount',
                                  style: TextStyle(fontSize: 16),
                                ),
                                Text(
                                  '${_amountController.text} ${widget.selectedCurrency}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Transfer fee (1%)',
                                  style: TextStyle(fontSize: 16),
                                ),
                                Text(
                                  '${_fee.toStringAsFixed(2)} ${widget.selectedCurrency}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Continue Button
            Container(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed:
                      _etbAmount > 0 &&
                          double.tryParse(_amountController.text) != null &&
                          double.parse(_amountController.text) >= 10
                      ? _proceedToRecipientDetails
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF37021),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}