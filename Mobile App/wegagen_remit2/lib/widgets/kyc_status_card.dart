import 'package:flutter/material.dart';
import '../models/kyc_data.dart';
import '../screens/auth/kyc_screen.dart';

class KycStatusCard extends StatelessWidget {
  final KycStatus kycStatus;
  final bool isKycVerified;

  const KycStatusCard({
    super.key,
    required this.kycStatus,
    required this.isKycVerified,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            _getStatusColor().withValues(alpha: 0.1),
            _getStatusColor().withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: _getStatusColor().withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 4),
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.white,
            blurRadius: 8,
            offset: const Offset(-2, -2),
          ),
        ],
        border: Border.all(
          color: _getStatusColor().withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            // Enhanced Status Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getStatusColor(),
                    _getStatusColor().withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _getStatusColor().withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(_getStatusIcon(), color: Colors.white, size: 32),
            ),
            const SizedBox(width: 16),

            // Content Section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'KYC Verification',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: _getStatusColor().withValues(alpha: 0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          _getStatusLabel(),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _getStatusText(),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Progress Bar for certain statuses
                  if (kycStatus == KycStatus.inProgress ||
                      kycStatus == KycStatus.underReview)
                    Column(
                      children: [
                        Container(
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: _getProgressValue(),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    _getStatusColor(),
                                    _getStatusColor().withValues(alpha: 0.8),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _getProgressText(),
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 14,
                              color: _getStatusColor(),
                            ),
                          ],
                        ),
                      ],
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: _getStatusColor(),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (kycStatus) {
      case KycStatus.approved:
        return const Color(0xFF4CAF50); // Green
      case KycStatus.underReview:
        return const Color(0xFFFF9800); // Orange
      case KycStatus.rejected:
        return const Color(0xFFF44336); // Red
      case KycStatus.inProgress:
        return const Color(0xFF2196F3); // Blue
      case KycStatus.notStarted:
        return const Color(0xFF9E9E9E); // Grey
    }
  }

  IconData _getStatusIcon() {
    switch (kycStatus) {
      case KycStatus.approved:
        return Icons.verified;
      case KycStatus.underReview:
        return Icons.hourglass_bottom;
      case KycStatus.rejected:
        return Icons.error;
      case KycStatus.inProgress:
        return Icons.upload_file;
      case KycStatus.notStarted:
        return Icons.assignment;
    }
  }

  String _getStatusLabel() {
    switch (kycStatus) {
      case KycStatus.approved:
        return 'Verified';
      case KycStatus.underReview:
        return 'Under Review';
      case KycStatus.rejected:
        return 'Rejected';
      case KycStatus.inProgress:
        return 'In Progress';
      case KycStatus.notStarted:
        return 'Required';
    }
  }

  String _getStatusText() {
    switch (kycStatus) {
      case KycStatus.approved:
        return 'Your profile is verified and ready for transfers';
      case KycStatus.underReview:
        return 'We\'re reviewing your documents (24-48 hours)';
      case KycStatus.rejected:
        return 'Please resubmit documents with corrections';
      case KycStatus.inProgress:
        return 'Complete your document upload';
      case KycStatus.notStarted:
        return 'Verify your identity to unlock all features';
    }
  }

  double _getProgressValue() {
    switch (kycStatus) {
      case KycStatus.inProgress:
        return 0.6; // 60% complete
      case KycStatus.underReview:
        return 0.9; // 90% complete
      case KycStatus.approved:
        return 1.0; // 100% complete
      default:
        return 0.3; // 30% for not started
    }
  }

  String _getProgressText() {
    switch (kycStatus) {
      case KycStatus.inProgress:
        return 'Documents uploaded • Review pending';
      case KycStatus.underReview:
        return 'Under review • Decision pending';
      case KycStatus.approved:
        return 'Verification complete';
      case KycStatus.rejected:
        return 'Resubmission required';
      default:
        return 'Tap to start verification';
    }
  }
}
