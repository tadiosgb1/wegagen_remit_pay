import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../payment/streamlined_billing_screen.dart';

class ModernConfirmationScreen extends ConsumerStatefulWidget {
  final String transferType;
  final double amount;
  final String currency;
  final double etbAmount;
  final double fee;
  final double exchangeRate;
  final Map<String, dynamic> recipientData;

  const ModernConfirmationScreen({
    super.key,
    required this.transferType,
    required this.amount,
    required this.currency,
    required this.etbAmount,
    required this.fee,
    required this.exchangeRate,
    required this.recipientData,
  });

  @override
  ConsumerState<ModernConfirmationScreen> createState() => _ModernConfirmationScreenState();
}

class _ModernConfirmationScreenState extends ConsumerState<ModernConfirmationScreen> {
  bool _isProcessing = false;

  String get _transferTitle {
    switch (widget.transferType) {
      case 'wegagen_bank': return 'Wegagen Bank Account Transfer';
      case 'wegagen_ebirr': return 'Wegagen E-birr Transfer';
      case 'cash_pickup': return 'Cash Pickup Transfer';
      case 'school_pay': return 'School Payment';
      default: return 'Money Transfer';
    }
  }

  IconData get _transferIcon {
    switch (widget.transferType) {
      case 'wegagen_bank': return Icons.account_balance;
      case 'wegagen_ebirr': return Icons.phone_android;
      case 'cash_pickup': return Icons.send;
      case 'school_pay': return Icons.school;
      default: return Icons.send;
    }
  }

  String _getCurrencyFlag(String code) {
    switch (code) {
      case 'USD': return '🇺🇸';
      case 'EUR': return '🇪🇺';
      case 'GBP': return '🇬🇧';
      default: return '💱';
    }
  }

  Future<void> _processTransfer() async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isProcessing = false);

    String toAccount = '';
    String toAccountHolder = '';

    switch (widget.transferType) {
      case 'wegagen_bank':
        toAccount = widget.recipientData['accountNumber'] ?? '';
        toAccountHolder = widget.recipientData['accountHolderName'] ?? '';
        break;
      case 'wegagen_ebirr':
        toAccount = widget.recipientData['phoneNumber'] ?? '';
        toAccountHolder = widget.recipientData['holderName'] ?? '';
        break;
      case 'cash_pickup':
        toAccount = 'CASH_PICKUP';
        toAccountHolder = widget.recipientData['fullName'] ?? '';
        break;
      case 'school_pay':
        toAccount = widget.recipientData['accountNumber'] ?? '';
        toAccountHolder = widget.recipientData['schoolName'] ?? '';
        break;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (context) => StreamlinedBillingScreen(
            toAccountHolder: toAccountHolder,
            toAccount: toAccount,
            amount: widget.etbAmount,
            currency: 'ETB',
            exchangeRate: widget.exchangeRate,
            originalAmount: widget.amount,
            originalCurrency: widget.currency,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFlag = _getCurrencyFlag(widget.currency);

    return Scaffold(
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
            Text(_transferTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
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
                children: List.generate(4, (index) => Container(
                  width: 28,
                  height: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF37021),
                    borderRadius: BorderRadius.circular(4),
                  ),
                )),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Confirm Transfer', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text('Review details before sending', style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),

                    const SizedBox(height: 32),

                    // Amount Summary Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.12), blurRadius: 16, offset: const Offset(0, 6))],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF37021).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(currencyFlag, style: const TextStyle(fontSize: 34)),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${widget.amount.toStringAsFixed(2)} ${widget.currency}', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                                    Text('Amount Sent', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 32),
                          _buildDetailRow('Amount Received', '${widget.etbAmount.toStringAsFixed(2)} ETB', highlight: true),
                          const SizedBox(height: 12),
                          _buildDetailRow('Bonus', '+${widget.fee.toStringAsFixed(2)} ETB'),
                          const SizedBox(height: 12),
                          _buildDetailRow('Exchange Rate', '1 ${widget.currency} = ${widget.exchangeRate.toStringAsFixed(2)} ETB'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // **Fixed Sending To Card**
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 12, offset: const Offset(0, 4))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Sending To', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 20),
                          ..._buildRecipientDetails(),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Warning
                    // Container(
                    //   padding: const EdgeInsets.all(20),
                    //   decoration: BoxDecoration(
                    //     color: Colors.amber.shade50,
                    //     borderRadius: BorderRadius.circular(16),
                    //     border: Border.all(color: Colors.amber.shade200),
                    //   ),
                    //   child: const Row(
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     // children: [
                    //     //   Icon(Icons.info_outline, color: Colors.amber, size: 24),
                    //     //   SizedBox(width: 16),
                    //     //   Expanded(
                    //     //     child: Text(
                    //     //       'This transfer cannot be cancelled once confirmed. Please double-check all details.',
                    //     //       style: TextStyle(fontSize: 14, height: 1.4),
                    //     //     ),
                    //     //   ),
                    //     // ],
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),

            // Fixed Bottom Button
            Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 12, offset: const Offset(0, -4))],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _processTransfer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF37021),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 0,
                  ),
                  child: _isProcessing
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)),
                            SizedBox(width: 14),
                            Text('Processing...', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                          ],
                        )
                      : const Text('Confirm & Send Money', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool highlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 15, color: Colors.grey.shade700)),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 16,
              fontWeight: highlight ? FontWeight.bold : FontWeight.w600,
              color: highlight ? const Color(0xFFF37021) : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildRecipientDetails() {
    final data = widget.recipientData;
    List<Widget> widgets = [];

    switch (widget.transferType) {
      case 'wegagen_bank':
        widgets.addAll([
          _buildRecipientRow('Account Number', data['accountNumber'] ?? ''),
          const SizedBox(height: 12),
          _buildRecipientRow('Account Holder', data['accountHolderName'] ?? ''),
          const SizedBox(height: 12),
          _buildRecipientRow('Account Type', data['accountType'] ?? ''),
        ]);
        break;

      case 'wegagen_ebirr':
        widgets.addAll([
          _buildRecipientRow('Phone Number', data['phoneNumber'] ?? ''),
          const SizedBox(height: 12),
          _buildRecipientRow('Account Holder', data['holderName'] ?? ''),
        ]);
        break;

      case 'cash_pickup':
        widgets.addAll([
          _buildRecipientRow('Full Name', data['fullName'] ?? ''),
          const SizedBox(height: 12),
          _buildRecipientRow('Phone', data['phoneNumber'] ?? ''),
          const SizedBox(height: 12),
          _buildRecipientRow('Address', data['address'] ?? ''),
          const SizedBox(height: 12),
          _buildRecipientRow('City', data['city'] ?? ''),
        ]);
        break;

      case 'school_pay':
        widgets.addAll([
          _buildRecipientRow('School Name', data['schoolName'] ?? ''),
          const SizedBox(height: 12),
          _buildRecipientRow('Account Number', data['accountNumber'] ?? ''),
        ]);
        break;
    }
    return widgets;
  }

  // New helper to prevent overflow
  Widget _buildRecipientRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }
}