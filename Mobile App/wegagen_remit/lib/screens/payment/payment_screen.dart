import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/payment_providers.dart';
import '../../widgets/activity_tracker.dart';
import 'payment_webview_screen.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final String? prefilledAccountHolder;
  final String? prefilledAccount;
  final double? prefilledAmount;
  final String? prefilledCurrency;
  final double? prefilledExchangeRate;
  final String? prefilledRemark;

  const PaymentScreen({
    super.key,
    this.prefilledAccountHolder,
    this.prefilledAccount,
    this.prefilledAmount,
    this.prefilledCurrency,
    this.prefilledExchangeRate,
    this.prefilledRemark,
  });

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _accountHolderController = TextEditingController();
  final _accountController = TextEditingController();
  final _amountController = TextEditingController();
  final _remarkController = TextEditingController();
  final _exchangeRateController = TextEditingController();
  
  final _currencyFormatter = NumberFormat.currency(symbol: '', decimalDigits: 2);
  
  @override
  void initState() {
    super.initState();
    
    // Pre-populate fields with provided data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Set default or provided values
      final accountHolder = widget.prefilledAccountHolder ?? '';
      final account = widget.prefilledAccount ?? '';
      final amount = widget.prefilledAmount ?? 0.0;
      final currency = widget.prefilledCurrency ?? 'ETB';
      final exchangeRate = widget.prefilledExchangeRate ?? 55.23;
      final remark = widget.prefilledRemark ?? '';
      
      // Update controllers
      _accountHolderController.text = accountHolder;
      _accountController.text = account;
      _amountController.text = amount > 0 ? amount.toStringAsFixed(2) : '';
      _exchangeRateController.text = exchangeRate.toStringAsFixed(2);
      _remarkController.text = remark;
      
      // Update provider state
      ref.read(paymentFormProvider.notifier).updateAccountHolder(accountHolder);
      ref.read(paymentFormProvider.notifier).updateAccount(account);
      ref.read(paymentFormProvider.notifier).updateAmount(amount);
      ref.read(paymentFormProvider.notifier).updateCurrency(currency);
      ref.read(paymentFormProvider.notifier).updateExchangeRate(exchangeRate);
      ref.read(paymentFormProvider.notifier).updateRemark(remark);
    });
  }

  @override
  void dispose() {
    _accountHolderController.dispose();
    _accountController.dispose();
    _amountController.dispose();
    _remarkController.dispose();
    _exchangeRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formData = ref.watch(paymentFormProvider);
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Send Money'),
        backgroundColor: const Color(0xFFF37021),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ActivityTracker(
        interactionType: 'payment_screen',
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Recipient Information'),
                const SizedBox(height: 16),
                _buildRecipientSection(),
                
                const SizedBox(height: 32),
                _buildSectionHeader('Payment Details'),
                const SizedBox(height: 16),
                _buildPaymentSection(),
                
                const SizedBox(height: 32),
                _buildSectionHeader('Exchange Rate'),
                const SizedBox(height: 16),
                _buildExchangeRateSection(),
                
                const SizedBox(height: 40),
                _buildProceedButton(),
                
                const SizedBox(height: 16),
                _buildSecurityInfo(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildRecipientSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          TextFormField(
            controller: _accountHolderController,
            readOnly: true, // Make read-only since it's pre-filled
            decoration: InputDecoration(
              labelText: 'Account Holder Name',
              hintText: 'Enter recipient full name',
              prefixIcon: const Icon(Icons.person_outline),
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            textCapitalization: TextCapitalization.words,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter account holder name';
              }
              if (value.trim().length < 2) {
                return 'Name must be at least 2 characters';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _accountController,
            readOnly: true, // Make read-only since it's pre-filled
            decoration: InputDecoration(
              labelText: 'Account Number',
              hintText: 'Enter recipient account number',
              prefixIcon: const Icon(Icons.account_balance_outlined),
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter account number';
              }
              if (value.trim().length < 10) {
                return 'Account number must be at least 10 digits';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          TextFormField(
            controller: _amountController,
            readOnly: true, // Make read-only since it comes from previous screen
            decoration: InputDecoration(
              labelText: 'Amount',
              hintText: '0.00',
              prefixIcon: const Icon(Icons.attach_money),
              suffixText: 'ETB',
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter amount';
              }
              final amount = double.tryParse(value.trim());
              if (amount == null || amount <= 0) {
                return 'Please enter a valid amount';
              }
              if (amount < 10) {
                return 'Minimum amount is 10.00 ETB';
              }
              if (amount > 100000) {
                return 'Maximum amount is 100,000.00 ETB';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _remarkController,
            decoration: const InputDecoration(
              labelText: 'Remark *',
              hintText: 'Purpose of transfer (required)',
              prefixIcon: Icon(Icons.note_outlined),
              border: OutlineInputBorder(),
              helperText: 'This is the only field you can edit',
            ),
            maxLines: 2,
            maxLength: 100,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a remark';
              }
              if (value.trim().length < 3) {
                return 'Remark must be at least 3 characters';
              }
              return null;
            },
            onChanged: (value) {
              ref.read(paymentFormProvider.notifier).updateRemark(value.trim());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExchangeRateSection() {
    final formData = ref.watch(paymentFormProvider);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          TextFormField(
            controller: _exchangeRateController,
            readOnly: true, // Make read-only since it comes from previous screen
            decoration: InputDecoration(
              labelText: 'Exchange Rate (1 USD = ? ETB)',
              hintText: '55.23',
              prefixIcon: const Icon(Icons.currency_exchange),
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter exchange rate';
              }
              final rate = double.tryParse(value.trim());
              if (rate == null || rate <= 0) {
                return 'Please enter a valid exchange rate';
              }
              return null;
            },
          ),
          
          if (formData.amount > 0 && formData.exchangeRate > 0) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF37021).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'You Send:',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '${_currencyFormatter.format(formData.amount / formData.exchangeRate)} USD',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recipient Gets:',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '${_currencyFormatter.format(formData.amount)} ETB',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFFF37021),
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
    );
  }

  Widget _buildProceedButton() {
    final formData = ref.watch(paymentFormProvider);
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: formData.isValid ? _proceedToPayment : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF37021),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: const Text(
          'Proceed to Payment',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.security,
            color: Colors.blue.shade600,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Your payment is secured with bank-level encryption. Card details are processed by CyberSource.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _proceedToPayment() {
    if (_formKey.currentState?.validate() ?? false) {
      // Navigate to WebView for secure payment
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const PaymentWebViewScreen(),
        ),
      );
    }
  }
}