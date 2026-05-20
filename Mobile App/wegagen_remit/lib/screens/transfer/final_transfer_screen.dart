import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../payment/payment_screen.dart';

class FinalTransferScreen extends ConsumerStatefulWidget {
  final String transferType;
  final double amount;
  final String currency;
  final double etbAmount;
  final double fee;
  final double exchangeRate;
  final Map<String, dynamic> recipientData;

  const FinalTransferScreen({
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
  ConsumerState<FinalTransferScreen> createState() => _FinalTransferScreenState();
}

class _FinalTransferScreenState extends ConsumerState<FinalTransferScreen> {
  final _remarkController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _remarkController.dispose();
    super.dispose();
  }

  String get _transferTitle {
    switch (widget.transferType) {
      case 'wegagen_bank':
        return 'Wegagen Bank Transfer';
      case 'wegagen_ebirr':
        return 'Wegagen E-birr Transfer';
      case 'cash_pickup':
        return 'Cash Pickup Transfer';
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
      case 'school_pay':
        return Icons.school;
      default:
        return Icons.send;
    }
  }

  Future<void> _submitTransfer() async {
    if (_remarkController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a remark for your transfer'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Extract account holder name and number
      String accountHolderName = '';
      String accountNumber = '';
      
      switch (widget.transferType) {
        case 'wegagen_bank':
          accountNumber = widget.recipientData['accountNumber'] ?? '';
          accountHolderName = widget.recipientData['accountHolderName'] ?? '';
          break;
        case 'wegagen_ebirr':
          accountNumber = widget.recipientData['phoneNumber'] ?? '';
          accountHolderName = widget.recipientData['holderName'] ?? '';
          break;
        case 'cash_pickup':
          accountNumber = widget.recipientData['phoneNumber'] ?? '';
          accountHolderName = widget.recipientData['fullName'] ?? '';
          break;
        case 'school_pay':
          accountNumber = widget.recipientData['studentId'] ?? '';
          accountHolderName = widget.recipientData['studentName'] ?? '';
          break;
      }

      // Navigate to payment screen with all data
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PaymentScreen(
              prefilledAccountHolder: accountHolderName,
              prefilledAccount: accountNumber,
              prefilledAmount: widget.etbAmount,
              prefilledCurrency: 'ETB',
              prefilledExchangeRate: widget.exchangeRate,
              prefilledRemark: _remarkController.text.trim(),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
            Icon(_transferIcon, size: 20, color: Colors.black87),
            const SizedBox(width: 8),
            const Text(
              'Review & Send',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Review Your Transfer',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please review all details before sending',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),

            const SizedBox(height: 32),

            // Transfer Summary Card
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
                  // Transfer Type Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF37021).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _transferIcon,
                          color: const Color(0xFFF37021),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _transferTitle,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Transfer Summary',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Amount Details
                  _buildDetailRow('You Send', '${widget.amount.toStringAsFixed(2)} ${widget.currency}'),
                  const SizedBox(height: 12),
                  _buildDetailRow('Bones', '${widget.fee.toStringAsFixed(2)} ETB'),
                  const SizedBox(height: 12),
                  _buildDetailRow('Exchange Rate', '1 ${widget.currency} = ${widget.exchangeRate.toStringAsFixed(2)} ETB'),
                  
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Total Amount
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Amount',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        '${widget.etbAmount.toStringAsFixed(2)} ETB',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF37021),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Recipient Details Card
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recipient Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._buildRecipientDetails(),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Remark Input Card
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Transfer Purpose',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _remarkController,
                    decoration: const InputDecoration(
                      labelText: 'Remark',
                      prefixIcon: Icon(Icons.note_outlined),
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    maxLength: 100,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Important Notice
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.amber.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'By proceeding, you confirm that all details are correct. This transfer cannot be cancelled once processed.',
                      style: TextStyle(fontSize: 12, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Send Money Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _submitTransfer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF37021),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: _isProcessing
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Processing...',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ],
                      )
                    : const Text(
                        'Send Money',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildRecipientDetails() {
    List<Widget> details = [];

    switch (widget.transferType) {
      case 'wegagen_bank':
        details.addAll([
          _buildDetailRow('Account Number', widget.recipientData['accountNumber']),
          const SizedBox(height: 8),
          _buildDetailRow('Account Holder', widget.recipientData['accountHolderName']),
          const SizedBox(height: 8),
          _buildDetailRow('Account Type', widget.recipientData['accountType']),
        ]);
        break;
      case 'wegagen_ebirr':
        details.addAll([
          _buildDetailRow('Phone Number', widget.recipientData['phoneNumber']),
          const SizedBox(height: 8),
          _buildDetailRow('Account Holder', widget.recipientData['holderName']),
        ]);
        break;
      case 'cash_pickup':
        details.addAll([
          _buildDetailRow('Full Name', widget.recipientData['fullName']),
          const SizedBox(height: 8),
          _buildDetailRow('Phone Number', widget.recipientData['phoneNumber']),
          const SizedBox(height: 8),
          _buildDetailRow('Address', widget.recipientData['address']),
          const SizedBox(height: 8),
          _buildDetailRow('City', widget.recipientData['city']),
          const SizedBox(height: 8),
          _buildDetailRow('Region', widget.recipientData['region']),
        ]);
        break;
    }

    return details;
  }
}