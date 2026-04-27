import 'package:flutter/material.dart';
import '../models/kyc_data.dart';
import '../screens/auth/kyc_screen.dart';

class KycStatusWidget extends StatelessWidget {
  final KycStatus status;
  final VoidCallback? onKycComplete;

  const KycStatusWidget({
    super.key,
    required this.status,
    this.onKycComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _getBorderColor()),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getIconBackgroundColor(),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getStatusIcon(),
                  color: _getIconColor(),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getStatusTitle(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _getTextColor(),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getStatusDescription(),
                      style: TextStyle(
                        fontSize: 14,
                        color: _getTextColor().withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (status == KycStatus.notStarted || status == KycStatus.rejected) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _navigateToKyc(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF37021),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  status == KycStatus.rejected ? 'Resubmit KYC' : 'Complete KYC',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (status) {
      case KycStatus.approved:
        return Colors.green.shade50;
      case KycStatus.rejected:
        return Colors.red.shade50;
      case KycStatus.underReview:
        return Colors.orange.shade50;
      case KycStatus.inProgress:
        return Colors.blue.shade50;
      case KycStatus.notStarted:
        return Colors.grey.shade50;
    }
  }

  Color _getBorderColor() {
    switch (status) {
      case KycStatus.approved:
        return Colors.green.shade200;
      case KycStatus.rejected:
        return Colors.red.shade200;
      case KycStatus.underReview:
        return Colors.orange.shade200;
      case KycStatus.inProgress:
        return Colors.blue.shade200;
      case KycStatus.notStarted:
        return Colors.grey.shade300;
    }
  }

  Color _getIconBackgroundColor() {
    switch (status) {
      case KycStatus.approved:
        return Colors.green.shade100;
      case KycStatus.rejected:
        return Colors.red.shade100;
      case KycStatus.underReview:
        return Colors.orange.shade100;
      case KycStatus.inProgress:
        return Colors.blue.shade100;
      case KycStatus.notStarted:
        return Colors.grey.shade200;
    }
  }

  Color _getIconColor() {
    switch (status) {
      case KycStatus.approved:
        return Colors.green.shade700;
      case KycStatus.rejected:
        return Colors.red.shade700;
      case KycStatus.underReview:
        return Colors.orange.shade700;
      case KycStatus.inProgress:
        return Colors.blue.shade700;
      case KycStatus.notStarted:
        return Colors.grey.shade600;
    }
  }

  Color _getTextColor() {
    switch (status) {
      case KycStatus.approved:
        return Colors.green.shade800;
      case KycStatus.rejected:
        return Colors.red.shade800;
      case KycStatus.underReview:
        return Colors.orange.shade800;
      case KycStatus.inProgress:
        return Colors.blue.shade800;
      case KycStatus.notStarted:
        return Colors.grey.shade700;
    }
  }

  IconData _getStatusIcon() {
    switch (status) {
      case KycStatus.approved:
        return Icons.verified_user;
      case KycStatus.rejected:
        return Icons.error_outline;
      case KycStatus.underReview:
        return Icons.hourglass_empty;
      case KycStatus.inProgress:
        return Icons.pending;
      case KycStatus.notStarted:
        return Icons.assignment_outlined;
    }
  }

  String _getStatusTitle() {
    switch (status) {
      case KycStatus.approved:
        return 'KYC Verified';
      case KycStatus.rejected:
        return 'KYC Rejected';
      case KycStatus.underReview:
        return 'KYC Under Review';
      case KycStatus.inProgress:
        return 'KYC In Progress';
      case KycStatus.notStarted:
        return 'KYC Required';
    }
  }

  String _getStatusDescription() {
    switch (status) {
      case KycStatus.approved:
        return 'Your identity has been verified successfully';
      case KycStatus.rejected:
        return 'Your KYC was rejected. Please resubmit with correct documents';
      case KycStatus.underReview:
        return 'We are reviewing your documents. This may take 24-48 hours';
      case KycStatus.inProgress:
        return 'Please complete your KYC verification process';
      case KycStatus.notStarted:
        return 'Complete KYC verification to start sending money';
    }
  }

  void _navigateToKyc(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const KycScreen(),
      ),
    ).then((_) {
      // Call callback when returning from KYC screen
      onKycComplete?.call();
    });
  }
}