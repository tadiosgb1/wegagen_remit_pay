import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/colors.dart';
import '../../models/transfer.dart';
import '../../services/transactions_service.dart';
import '../../widgets/activity_tracker.dart';

class TransactionDetailScreen extends StatefulWidget {
  final String transactionId;

  const TransactionDetailScreen({
    super.key,
    required this.transactionId,
  });

  @override
  State<TransactionDetailScreen> createState() => _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  final TransactionsService _transactionsService = TransactionsService();
  Transfer? _transaction;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTransactionDetails();
  }

  Future<void> _loadTransactionDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final transaction = await _transactionsService.getTransactionById(widget.transactionId);
      
      if (mounted) {
        setState(() {
          _transaction = transaction;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Transaction Details'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        actions: [
          if (_transaction != null)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _shareTransaction,
            ),
        ],
      ),
      body: ActivityTracker(
        interactionType: 'transaction_detail',
        child: _isLoading
            ? _buildLoadingState()
            : _error != null
                ? _buildErrorState()
                : _buildTransactionDetail(),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.primary,
          ),
          SizedBox(height: 16),
          Text(
            'Loading transaction details...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red.shade400,
          ),
          const SizedBox(height: 24),
          Text(
            'Failed to Load Transaction',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Something went wrong',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _loadTransactionDetails,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Retry',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionDetail() {
    final transaction = _transaction!;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Status Header Card
          _buildStatusCard(transaction),
          
          const SizedBox(height: 16),
          
          // Amount Details Card
          _buildAmountCard(transaction),
          
          const SizedBox(height: 16),
          
          // Transaction Info Card
          _buildTransactionInfoCard(transaction),
          
          const SizedBox(height: 16),
          
          // Recipient Details Card
          _buildRecipientCard(transaction),
          
          const SizedBox(height: 16),
          
          // Sender Details Card (if available)
          if (transaction.senderInfo != null) ...[
            _buildSenderCard(transaction),
            const SizedBox(height: 16),
          ],
          
          // Timeline Card
          _buildTimelineCard(transaction),
          
          const SizedBox(height: 16),
          
          // Additional Info Card
          _buildAdditionalInfoCard(transaction),
          
          const SizedBox(height: 24),
          
          // Action Buttons
          _buildActionButtons(transaction),
        ],
      ),
    );
  }

  Widget _buildStatusCard(Transfer transaction) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
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
        children: [
          // Status Icon
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _getStatusColor(transaction.status).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getStatusIcon(transaction.status),
              color: _getStatusColor(transaction.status),
              size: 40,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Status Text
          Text(
            _getStatusText(transaction.status),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: _getStatusColor(transaction.status),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Transfer Type
          Text(
            _getTransferTypeName(transaction.type),
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          
          // Failure Reason (if applicable)
          if (transaction.status == TransferStatus.failed && transaction.failureReason != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                transaction.failureReason!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red.shade700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAmountCard(Transfer transaction) {
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
        children: [
          // Amount Sent
          Column(
            children: [
              Text(
                'Amount Sent',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${transaction.amount.toStringAsFixed(2)} ${transaction.currency}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Exchange Rate (if different currencies)
          if (transaction.exchangeRate != null && transaction.currency != 'ETB') ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.swap_horiz,
                    color: Colors.blue.shade600,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Rate: 1 ${transaction.currency} = ${transaction.exchangeRate!.toStringAsFixed(2)} ETB',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
          
          // Amount Received
          Column(
            children: [
              Text(
                'Recipient Receives',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${transaction.etbAmount.toStringAsFixed(2)} ETB',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionInfoCard(Transfer transaction) {
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
          Text(
            'Transaction Information',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          
          const SizedBox(height: 16),
          
          _buildInfoRow('Transaction ID', transaction.id.toString(), copyable: true),
          _buildInfoRow('Reference', transaction.transactionRef, copyable: true),
          _buildInfoRow('Transfer Method', _getTransferTypeName(transaction.type)),
          _buildInfoRow('Currency', transaction.currency),
          
          // Pickup Code (for cash pickup)
          if (transaction.type == TransferType.cashPickup && transaction.pickupCode != null)
            _buildInfoRow('Pickup Code', transaction.pickupCode!, copyable: true, highlighted: true),
        ],
      ),
    );
  }

  Widget _buildRecipientCard(Transfer transaction) {
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
              Icon(
                Icons.person_outline,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Recipient Details',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          _buildInfoRow('Name', transaction.recipientName),
          _buildInfoRow('Account/Phone', transaction.recipientAccount, copyable: true),
        ],
      ),
    );
  }

  Widget _buildSenderCard(Transfer transaction) {
    final senderInfo = transaction.senderInfo!;
    
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
              Icon(
                Icons.account_circle_outlined,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Sender Details',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          if (senderInfo['name'] != null) _buildInfoRow('Name', senderInfo['name']),
          if (senderInfo['email'] != null) _buildInfoRow('Email', senderInfo['email']),
          if (senderInfo['phone'] != null) _buildInfoRow('Phone', senderInfo['phone']),
        ],
      ),
    );
  }

  Widget _buildTimelineCard(Transfer transaction) {
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
              Icon(
                Icons.timeline,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Transaction Timeline',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          _buildTimelineItem(
            'Transaction Created',
            _formatDateTime(transaction.createdAt),
            Icons.add_circle_outline,
            true,
          ),
          
          if (transaction.status != TransferStatus.pending)
            _buildTimelineItem(
              'Processing Started',
              'Transaction is being processed',
              Icons.sync,
              true,
            ),
          
          if (transaction.completedAt != null)
            _buildTimelineItem(
              transaction.status == TransferStatus.completed ? 'Completed' : 'Failed',
              _formatDateTime(transaction.completedAt!),
              transaction.status == TransferStatus.completed 
                  ? Icons.check_circle_outline 
                  : Icons.cancel_outlined,
              true,
            ),
          
          if (transaction.status == TransferStatus.pending)
            _buildTimelineItem(
              'Pending Completion',
              'Waiting for processing',
              Icons.hourglass_empty,
              false,
            ),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfoCard(Transfer transaction) {
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
          Text(
            'Additional Information',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Processing time estimate
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.blue.shade600,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getProcessingInfo(transaction.type, transaction.status),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Transfer transaction) {
    return Column(
      children: [
        // Primary Action Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _shareTransaction,
            icon: const Icon(Icons.share),
            label: const Text('Share Transaction'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Secondary Actions
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _copyToClipboard('Transaction ID: ${transaction.id}'),
                icon: const Icon(Icons.copy),
                label: const Text('Copy ID'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 12),
            
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _refreshTransaction,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {bool copyable = false, bool highlighted = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: copyable ? () => _copyToClipboard(value) : null,
              child: Container(
                padding: highlighted ? const EdgeInsets.all(8) : EdgeInsets.zero,
                decoration: highlighted
                    ? BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(6),
                      )
                    : null,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        value,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: highlighted ? FontWeight.w600 : FontWeight.normal,
                          color: highlighted ? Colors.green.shade700 : Colors.black87,
                        ),
                      ),
                    ),
                    if (copyable) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.copy,
                        size: 16,
                        color: Colors.grey.shade500,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String title, String subtitle, IconData icon, bool completed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: completed
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 16,
              color: completed ? AppColors.primary : Colors.grey.shade500,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: completed ? Colors.black87 : Colors.grey.shade600,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(TransferStatus status) {
    switch (status) {
      case TransferStatus.completed:
        return Colors.green;
      case TransferStatus.pending:
        return Colors.orange;
      case TransferStatus.processing:
        return Colors.blue;
      case TransferStatus.failed:
        return Colors.red;
      case TransferStatus.cancelled:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(TransferStatus status) {
    switch (status) {
      case TransferStatus.completed:
        return Icons.check_circle;
      case TransferStatus.pending:
        return Icons.access_time;
      case TransferStatus.processing:
        return Icons.sync;
      case TransferStatus.failed:
        return Icons.error;
      case TransferStatus.cancelled:
        return Icons.cancel;
    }
  }

  String _getStatusText(TransferStatus status) {
    switch (status) {
      case TransferStatus.completed:
        return 'Completed';
      case TransferStatus.pending:
        return 'Pending';
      case TransferStatus.processing:
        return 'Processing';
      case TransferStatus.failed:
        return 'Failed';
      case TransferStatus.cancelled:
        return 'Cancelled';
    }
  }

  String _getTransferTypeName(TransferType type) {
    switch (type) {
      case TransferType.wegagenBank:
        return 'Wegagen Bank Transfer';
      case TransferType.wegagenEbirr:
        return 'Wegagen E-birr Transfer';
      case TransferType.cashPickup:
        return 'Cash Pickup';
      case TransferType.schoolPay:
        return 'School Payment';
      case TransferType.don:
        return 'Bank Transfer';
    }
  }

  String _getProcessingInfo(TransferType type, TransferStatus status) {
    if (status == TransferStatus.completed) {
      return 'Transaction completed successfully. Recipient should receive funds within 24 hours.';
    } else if (status == TransferStatus.failed) {
      return 'Transaction failed. Please contact support for assistance.';
    } else {
      switch (type) {
        case TransferType.wegagenBank:
          return 'Bank transfers typically process within 1-2 business days.';
        case TransferType.wegagenEbirr:
          return 'E-birr transfers are usually instant but may take up to 1 hour.';
        case TransferType.cashPickup:
          return 'Cash pickup is available once processing is complete (usually within 30 minutes).';
        case TransferType.schoolPay:
          return 'School payments process within 1 business day.';
        case TransferType.don:
          return 'Bank transfers typically process within 1-2 business days.';
      }
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    final day = dateTime.day;
    final month = months[dateTime.month - 1];
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    
    return '$day $month $year at $hour:$minute';
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied to clipboard'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _shareTransaction() {
    final transaction = _transaction!;
    final shareText = '''
Transaction Details - Wegagen Remit

ID: ${transaction.id}
Reference: ${transaction.transactionRef}
Status: ${_getStatusText(transaction.status)}
Amount: ${transaction.amount.toStringAsFixed(2)} ${transaction.currency}
Recipient: ${transaction.recipientName}
Date: ${_formatDateTime(transaction.createdAt)}

Wegagen Remit - Send Money Worldwide
    '''.trim();

    // For now, copy to clipboard as sharing implementation
    _copyToClipboard(shareText);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Transaction details copied to clipboard'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _refreshTransaction() {
    _loadTransactionDetails();
  }
}