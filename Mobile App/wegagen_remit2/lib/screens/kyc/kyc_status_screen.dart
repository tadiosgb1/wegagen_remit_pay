import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../models/user.dart';
import '../../widgets/activity_tracker.dart';
import '../auth/kyc_screen.dart';

class KycStatusScreen extends StatefulWidget {
  const KycStatusScreen({super.key});

  @override
  State<KycStatusScreen> createState() => _KycStatusScreenState();
}

class _KycStatusScreenState extends State<KycStatusScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('KYC Status'),
        backgroundColor: const Color(0xFFF37021),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ActivityTracker(
        interactionType: 'kyc_status_screen',
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            final user = authProvider.user;
            
            if (user == null) {
              return const Center(
                child: Text('User data not available'),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusCard(user),
                  const SizedBox(height: 20),
                  
                  if (user.kyc != null) ...[
                    _buildKycDetailsCard(user.kyc!),
                    const SizedBox(height: 20),
                    _buildDocumentsCard(user.kyc!),
                    const SizedBox(height: 20),
                  ],
                  
                  _buildActionButtons(user),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatusCard(User user) {
    Color statusColor;
    IconData statusIcon;
    String statusText;
    String statusDescription;

    if (user.kyc == null) {
      statusColor = Colors.orange;
      statusIcon = Icons.warning_outlined;
      statusText = 'KYC Not Started';
      statusDescription = 'You need to complete KYC verification to access all features.';
    } else if (user.kyc!.verified) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle_outline;
      statusText = 'KYC Verified';
      statusDescription = 'Your identity has been successfully verified.';
    } else {
      statusColor = Colors.blue;
      statusIcon = Icons.hourglass_empty;
      statusText = 'KYC Under Review';
      statusDescription = 'Your documents are being reviewed. This usually takes 1-2 business days.';
    }

    return Container(
      width: double.infinity,
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  statusIcon,
                  color: statusColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      statusDescription,
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
          
          if (user.kyc != null) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Submitted On',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    Text(
                      DateFormat('MMM dd, yyyy').format(user.kyc!.createdAt),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                
                if (user.kyc!.verified && user.kyc!.verifiedAt != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Verified On',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      Text(
                        DateFormat('MMM dd, yyyy').format(user.kyc!.verifiedAt!),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildKycDetailsCard(KycData kyc) {
    return Container(
      width: double.infinity,
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
            'Personal Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildDetailRow('ID Type', _formatIdType(kyc.idType)),
          const SizedBox(height: 12),
          _buildDetailRow('Date of Birth', _formatDate(kyc.dob)),
          const SizedBox(height: 12),
          _buildDetailRow('Address', kyc.address),
          const SizedBox(height: 12),
          _buildDetailRow('City', kyc.city),
          const SizedBox(height: 12),
          _buildDetailRow('Country', kyc.country),
        ],
      ),
    );
  }

  Widget _buildDocumentsCard(KycData kyc) {
    return Container(
      width: double.infinity,
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
            'Uploaded Documents',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildDocumentStatus(
                  'ID Document',
                  kyc.idPhotoPath != null,
                  Icons.credit_card,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDocumentStatus(
                  'Selfie Photo',
                  kyc.selfiePhotoPath != null,
                  Icons.face,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentStatus(String title, bool isUploaded, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUploaded ? Colors.green.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUploaded ? Colors.green.shade200 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Icon(
            isUploaded ? Icons.check_circle : icon,
            color: isUploaded ? Colors.green : Colors.grey,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            isUploaded ? 'Uploaded' : 'Not Uploaded',
            style: TextStyle(
              fontSize: 10,
              color: isUploaded ? Colors.green : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value.isNotEmpty ? value : 'Not provided',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: value.isNotEmpty ? Colors.black87 : Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(User user) {
    return Column(
      children: [
        if (user.kyc == null) ...[
          // No KYC - Show start button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const KycScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.start),
              label: const Text('Start KYC Verification'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF37021),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ] else if (!user.kyc!.verified) ...[
          // KYC submitted but not verified - Show update button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const KycScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.edit),
              label: const Text('Update KYC Information'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFF37021),
                side: const BorderSide(color: Color(0xFFF37021)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ] else ...[
          // KYC verified - Show view button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                _showKycDetailsDialog(user.kyc!);
              },
              icon: const Icon(Icons.visibility),
              label: const Text('View Full Details'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.green,
                side: const BorderSide(color: Colors.green),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
        
        const SizedBox(height: 16),
        
        // Help section
        Container(
          width: double.infinity,
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
                  Icon(
                    Icons.help_outline,
                    color: Colors.blue.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Need Help?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'If you have questions about your KYC status or need assistance, please contact our support team.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue.shade700,
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  _showContactSupportDialog();
                },
                child: const Text('Contact Support'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showKycDetailsDialog(KycData kyc) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('KYC Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('ID Type', _formatIdType(kyc.idType)),
                const SizedBox(height: 8),
                _buildDetailRow('Date of Birth', _formatDate(kyc.dob)),
                const SizedBox(height: 8),
                _buildDetailRow('Address', kyc.address),
                const SizedBox(height: 8),
                _buildDetailRow('City', kyc.city),
                const SizedBox(height: 8),
                _buildDetailRow('Country', kyc.country),
                const SizedBox(height: 8),
                _buildDetailRow('Submitted', DateFormat('MMM dd, yyyy • hh:mm a').format(kyc.createdAt)),
                if (kyc.verified && kyc.verifiedAt != null) ...[
                  const SizedBox(height: 8),
                  _buildDetailRow('Verified', DateFormat('MMM dd, yyyy • hh:mm a').format(kyc.verifiedAt!)),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showContactSupportDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Contact Support'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Get help with your KYC verification:'),
              SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.phone, size: 16),
                  SizedBox(width: 8),
                  Text('+251-11-XXX-XXXX'),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.email, size: 16),
                  SizedBox(width: 8),
                  Text('support@wegagenremit.com'),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.schedule, size: 16),
                  SizedBox(width: 8),
                  Text('Mon-Fri: 9:00 AM - 6:00 PM'),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  String _formatIdType(String idType) {
    switch (idType.toLowerCase()) {
      case 'passport':
        return 'Passport';
      case 'national_id':
        return 'National ID';
      case 'driving_license':
        return 'Driving License';
      default:
        return idType.toUpperCase();
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }
}