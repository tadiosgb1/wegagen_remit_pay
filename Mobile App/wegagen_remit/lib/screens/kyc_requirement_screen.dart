import 'package:flutter/material.dart';
import '../models/kyc_data.dart';
import '../widgets/kyc_status_widget.dart';
import 'auth/kyc_screen.dart';

class KycRequirementScreen extends StatelessWidget {
  final String transferType;
  final double amount;
  final String currency;
  final double etbAmount;
  final double fee;
  final double exchangeRate;
  final KycStatus kycStatus;

  const KycRequirementScreen({
    super.key,
    required this.transferType,
    required this.amount,
    required this.currency,
    required this.etbAmount,
    required this.fee,
    required this.exchangeRate,
    required this.kycStatus,
  });

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
        title: const Text(
          'KYC Verification Required',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            
            // KYC Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFF37021).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.verified_user,
                size: 60,
                color: Color(0xFFF37021),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Title
            const Text(
              'Identity Verification Required',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            // Description
            const Text(
              'To comply with financial regulations and ensure secure transactions, you need to complete KYC verification before sending money.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            
            // Transfer Summary
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
                    'Your Transfer Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildSummaryRow('Transfer Type', _getTransferTypeName()),
                  const SizedBox(height: 12),
                  _buildSummaryRow('You Send', '$amount $currency'),
                  const SizedBox(height: 12),
                  _buildSummaryRow('Recipient Gets', '${etbAmount.toStringAsFixed(2)} ETB'),
                  const SizedBox(height: 12),
                  _buildSummaryRow('Exchange Rate', '1 $currency = ${exchangeRate.toStringAsFixed(2)} ETB'),
                  const SizedBox(height: 12),
                  _buildSummaryRow('Transfer Fee', '${fee.toStringAsFixed(2)} $currency'),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // KYC Status Widget
            KycStatusWidget(
              status: kycStatus,
              onKycComplete: () {
                // Return to previous screen after KYC completion
                Navigator.of(context).pop(true);
              },
            ),
            
            const SizedBox(height: 24),
            
            // Information Box
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
                      Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'What happens next?',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('• Complete KYC verification (takes 5-10 minutes)'),
                      Text('• We review your documents (24-48 hours)'),
                      Text('• Once approved, you can send money instantly'),
                      Text('• Your transfer details will be saved'),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancel Transfer'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _navigateToKyc(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF37021),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Start KYC',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
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

  String _getTransferTypeName() {
    switch (transferType) {
      case 'wegagen_bank':
        return 'Bank Transfer';
      case 'wegagen_ebirr':
        return 'Wegagen E-birr';
      case 'cash_pickup':
        return 'Cash Pickup';
      case 'school_pay':
        return 'School Payment';
      default:
        return 'Money Transfer';
    }
  }

  void _navigateToKyc(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const KycScreen(),
      ),
    ).then((_) {
      // Return to previous screen after KYC completion
      Navigator.of(context).pop(true);
    });
  }
}