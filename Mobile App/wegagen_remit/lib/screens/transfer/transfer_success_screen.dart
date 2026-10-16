import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../main_navigation_screen.dart';
import '../../constants/colors.dart';

class TransferSuccessScreen extends StatelessWidget {
  final String transferType;
  final double amount;
  final String currency;
  final double etbAmount;
  final double bonusAmountETB;
  final Map<String, dynamic> recipientInfo;
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
    required this.recipientName,
    this.pickupCode,
    required this.transactionId,
  });

  String get _transferTypeTitle {
    switch (transferType) {
      case 'wegagen_bank':
        return 'Wegagen Bank Transfer';
      case 'wegagen_ebirr':
        return 'wegagen E-birr Transfer';
      case 'cash_pickup':
        return 'Cash Pickup';
      case 'school_pay':
        return 'School Payment';
      default:
        return 'Transfer';
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
                          _buildDetailRow(
                            'Amount Received',
                            '${etbAmount.toStringAsFixed(2)} ETB',
                          ),
                          const SizedBox(height: 16),
                          _buildDetailRow(
                            'Bonus',
                            '+${bonusAmountETB.toStringAsFixed(2)} ETB',
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
        add('Account Type', ['accountType']);
        break;
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
        if (location.isNotEmpty) {
          details.add(MapEntry('City / State', location));
        }
        add('Country', ['country']);
        add('Purpose', ['relationship', 'relationship_to_sender']);
        break;
    }
    return details;
  }

  Future<Uint8List> _createReceiptPdf() async {
    final pdf = pw.Document();
    final details = <MapEntry<String, String>>[
      MapEntry('Transfer Type', _transferTypeTitle),
      MapEntry('Amount Sent', '${amount.toStringAsFixed(2)} $currency'),
      MapEntry('Recipient', recipientName),
      ..._recipientDetails,
      MapEntry('Amount Received', '${etbAmount.toStringAsFixed(2)} ETB'),
      MapEntry('Bonus', '+${bonusAmountETB.toStringAsFixed(2)} ETB'),
      MapEntry('Transaction ID', transactionId),
      MapEntry('Status', 'Completed'),
      MapEntry('Date', DateTime.now().toLocal().toString()),
    ];

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Padding(
          padding: const pw.EdgeInsets.all(32),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'wegagen Remit - Transfer Receipt',
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              for (final detail in details) ...[
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.SizedBox(
                      width: 145,
                      child: pw.Text(
                        detail.key,
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Expanded(child: pw.Text(detail.value)),
                  ],
                ),
                pw.SizedBox(height: 12),
              ],
              pw.Divider(),
              pw.SizedBox(height: 8),
              pw.Text('Thank you for using wegagen Remit.'),
            ],
          ),
        ),
      ),
    );
    return pdf.save();
  }

  Future<void> _downloadReceipt(BuildContext context) async {
    try {
      final bytes = await _createReceiptPdf();
      await Printing.layoutPdf(
        onLayout: (_) async => bytes,
        name: 'wegagen-remit-$transactionId.pdf',
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not create receipt PDF: $error')),
      );
    }
  }

  Future<void> _shareReceipt(BuildContext context) async {
    try {
      final bytes = await _createReceiptPdf();
      await Printing.sharePdf(
        bytes: bytes,
        filename: 'wegagen-remit-$transactionId.pdf',
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not share receipt PDF: $error')),
      );
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
