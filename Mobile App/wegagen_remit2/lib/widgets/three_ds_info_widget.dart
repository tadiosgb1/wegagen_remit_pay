import 'package:flutter/material.dart';

/// Widget to display 3D Secure information and status
class ThreeDSInfoWidget extends StatelessWidget {
  final bool is3DSEnabled;
  final String? status;
  final VoidCallback? onLearnMore;

  const ThreeDSInfoWidget({
    super.key,
    this.is3DSEnabled = true,
    this.status,
    this.onLearnMore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: is3DSEnabled ? Colors.green.shade50 : Colors.blue.shade50,
        border: Border.all(
          color: is3DSEnabled ? Colors.green.shade200 : Colors.blue.shade200,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                is3DSEnabled ? Icons.verified_user : Icons.security,
                color: is3DSEnabled ? Colors.green.shade600 : Colors.blue.shade600,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  is3DSEnabled ? '3D Secure Protected' : '3D Secure Authentication',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: is3DSEnabled ? Colors.green.shade700 : Colors.blue.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            is3DSEnabled
                ? 'Your payment is protected by 3D Secure authentication for enhanced security.'
                : 'This payment will require additional authentication with your bank.',
            style: TextStyle(
              fontSize: 12,
              color: is3DSEnabled ? Colors.green.shade600 : Colors.blue.shade600,
            ),
          ),
          if (status != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  _getStatusIcon(status!),
                  size: 16,
                  color: _getStatusColor(status!),
                ),
                const SizedBox(width: 4),
                Text(
                  'Status: ${_getStatusText(status!)}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: _getStatusColor(status!),
                  ),
                ),
              ],
            ),
          ],
          if (onLearnMore != null) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: onLearnMore,
              child: Text(
                'Learn more about 3D Secure',
                style: TextStyle(
                  fontSize: 11,
                  color: is3DSEnabled ? Colors.green.shade700 : Colors.blue.shade700,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'authenticated':
      case 'completed':
        return Icons.check_circle;
      case 'pending':
      case 'processing':
        return Icons.hourglass_empty;
      case 'failed':
      case 'timeout':
        return Icons.error;
      default:
        return Icons.info;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'authenticated':
      case 'completed':
        return Colors.green.shade600;
      case 'pending':
      case 'processing':
        return Colors.orange.shade600;
      case 'failed':
      case 'timeout':
        return Colors.red.shade600;
      default:
        return Colors.blue.shade600;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'authenticated':
        return 'Authenticated';
      case 'completed':
        return 'Completed';
      case 'pending':
        return 'Pending Authentication';
      case 'processing':
        return 'Processing';
      case 'failed':
        return 'Authentication Failed';
      case 'timeout':
        return 'Timeout';
      default:
        return status;
    }
  }
}