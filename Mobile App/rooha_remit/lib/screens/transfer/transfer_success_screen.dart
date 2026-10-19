import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../services/bonus_service.dart';
import '../main_navigation_screen.dart';
import '../transactions/transactions_screen.dart';
import '../../constants/colors.dart';

class TransferSuccessScreen extends StatelessWidget {
  final String transferType;
  final double amount;
  final String currency;
  final double etbAmount;
  final double bonusAmountETB;
  final Map<String, dynamic> recipientInfo;
  final double? exchangeRate;
  final BonusCalculation? bonusCalculation;
  final String recipientName;
  final String? pickupCode;
  final String transactionId;

  const TransferSuccessScreen({
    super.key,
    required this.transferType,
    required this.amount,
    required this.currency,
    required this.etbAmount,
    this.bonusAmountETB = 0,
    this.recipientInfo = const {},
    this.exchangeRate,
    this.bonusCalculation,
    required this.recipientName,
    this.pickupCode,
    required this.transactionId,
  });

  String get _transferTypeTitle {
    switch (transferType) {
      case 'wegagen_bank':
        return 'Wegagen Bank Transfer';
      case 'rooha_ebirr':
        return 'Rooha E-birr Transfer';
      case 'cash_pickup':
        return 'Cash Pickup';
      case 'school_pay':
        return 'School Payment';
      default:
        return 'Transfer';
    }
  }

  IconData get _transferIcon {
    switch (transferType) {
      case 'wegagen_bank':
        return Icons.account_balance;
      case 'rooha_ebirr':
        return Icons.phone_android;
      case 'cash_pickup':
        return Icons.send;
      case 'school_pay':
        return Icons.school;
      default:
        return Icons.send;
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final formattedDate = '${_getMonthName(now.month)} ${now.day}, ${now.year}';

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 60),

                    // Success Animation - Concentric Circles with Check
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Success Title
                    const Text(
                      'Transfer Successful!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 8),

                    // Success Message
                    const Text(
                      'Your money is on its way',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 40),

                    // Transfer Details Card
                    Container(
                      width: double.infinity,
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
                          // Amount Sent - Large Display
                          const Text(
                            'Amount Sent',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${amount.toStringAsFixed(2)} $currency',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Transfer Details
                          _buildDetailRow('Recipient', recipientName),
                          for (final detail in _recipientDetails) ...[
                            const SizedBox(height: 16),
                            _buildDetailRow(detail.key, detail.value),
                          ],
                          const SizedBox(height: 16),
                          _buildDetailRow('Amount Received',
                              '${etbAmount.toStringAsFixed(2)} ETB'),
                          const SizedBox(height: 16),
                          _buildDetailRow(
                            'Bonus',
                            '+${(bonusAmountETB > 0 ? bonusAmountETB : (bonusCalculation?.bonusAmountETB ?? 0)).toStringAsFixed(2)} ETB',
                          ),
                          const SizedBox(height: 16),
                          _buildDetailRow('Transaction ID', transactionId),
                          const SizedBox(height: 16),
                          _buildDetailRow('Date', formattedDate),
                          const SizedBox(height: 16),

                          // Status
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Status',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Completed',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Pickup Code (for cash pickup only)
                          if (transferType == 'cash_pickup' &&
                              pickupCode != null) ...[
                            const SizedBox(height: 24),
                            const Divider(),
                            const SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    'Pickup Code',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    pickupCode!,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Share this code with the recipient',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // Action Buttons
            Container(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  // Download Button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _downloadReceipt(context),
                      icon: const Icon(Icons.download, size: 20),
                      label: const Text('Download PDF'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey.shade700,
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Share Button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _shareReceipt(context),
                      icon: const Icon(Icons.share, size: 20),
                      label: const Text('Share'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey.shade700,
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Done Button
            Container(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const MainNavigationScreen(),
                      ),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<MapEntry<String, String>> get _recipientDetails {
    String valueFor(List<String> keys) {
      for (final key in keys) {
        final value = recipientInfo[key]?.toString().trim();
        if (value != null && value.isNotEmpty) return value;
      }
      return '';
    }

    final details = <MapEntry<String, String>>[];
    void add(String label, List<String> keys) {
      final value = valueFor(keys);
      if (value.isNotEmpty) details.add(MapEntry(label, value));
    }

    switch (transferType) {
      case 'wegagen_bank':
        add('Account Number', ['accountNumber', 'account_number', 'toAccount']);
        break;
      case 'rooha_ebirr':
      case 'wegagen_ebirr':
        add('Phone Number', ['phoneNumber', 'phone_number']);
        break;
      case 'cash_pickup':
        add('Phone Number', ['phoneNumber', 'phone_number']);
        add('Address', ['address']);
        final city = valueFor(['city']);
        final state = valueFor(['state']);
        final location =
            [city, state].where((part) => part.isNotEmpty).join(', ');
        if (location.isNotEmpty)
          details.add(MapEntry('City / State', location));
        add('Country', ['country']);
        add('Purpose', ['relationship', 'relationship_to_sender']);
        break;
    }
    return details;
  }

  Future<Uint8List> _buildReceiptPdf() async {
    final document = pw.Document();
    final date =
        '${_getMonthName(DateTime.now().month)} ${DateTime.now().day}, ${DateTime.now().year}';
    final bonus = bonusAmountETB > 0
        ? bonusAmountETB
        : (bonusCalculation?.bonusAmountETB ?? 0);

    document.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (_) => pw.Padding(
          padding: const pw.EdgeInsets.all(32),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Rooha Remit - Transfer Receipt',
                  style: pw.TextStyle(
                      fontSize: 22, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              _pdfRow('Transfer Type', _transferTypeTitle),
              _pdfRow('Status', 'Completed'),
              _pdfRow('Amount Sent', '${amount.toStringAsFixed(2)} $currency'),
              _pdfRow('Recipient', recipientName),
              for (final detail in _recipientDetails)
                _pdfRow(detail.key, detail.value),
              _pdfRow('Amount Received', '${etbAmount.toStringAsFixed(2)} ETB'),
              _pdfRow('Bonus', '+${bonus.toStringAsFixed(2)} ETB'),
              _pdfRow('Transaction ID', transactionId),
              _pdfRow('Date', date),
              if (transferType == 'cash_pickup' && pickupCode != null)
                _pdfRow('Pickup Code', pickupCode!),
              pw.Spacer(),
              pw.Text('Thank you for using Rooha Remit.'),
            ],
          ),
        ),
      ),
    );

    return document.save();
  }

  pw.Widget _pdfRow(String label, String value) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 7),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(label),
            pw.SizedBox(width: 20),
            pw.Expanded(
              child: pw.Text(value, textAlign: pw.TextAlign.right),
            ),
          ],
        ),
      );

  Future<void> _downloadReceipt(BuildContext context) async {
    try {
      final bytes = await _buildReceiptPdf();
      await Printing.layoutPdf(onLayout: (_) async => bytes);
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not create receipt: $error')),
        );
      }
    }
  }

  Future<void> _shareReceipt(BuildContext context) async {
    try {
      final bytes = await _buildReceiptPdf();
      await Printing.sharePdf(
        bytes: bytes,
        filename: 'rooha-transfer-receipt-$transactionId.pdf',
      );
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not share receipt: $error')),
        );
      }
    }
  }

  String _getMonthName(int month) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month];
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
}
