import 'package:flutter/material.dart';
import '../../models/transfer.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Completed', 'Pending', 'Failed'];

  // Mock transaction data
  final List<Transfer> _mockTransactions = [
    Transfer(
      id: 'WR1704123456789',
      type: TransferType.wegagenBank,
      amount: 500.00,
      fromCurrency: 'USD',
      etbAmount: 77300.00,
      exchangeRate: 154.60,
      fee: 5.00,
      recipientName: 'TADESSE GEBREMICHEL BERHE',
      recipientDetails: {
        'accountNumber': '1000000099839',
        'accountType': 'Savings Account',
      },
      status: TransferStatus.completed,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      completedAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    Transfer(
      id: 'WR1704123456790',
      type: TransferType.wegagenEbirr,
      amount: 200.00,
      fromCurrency: 'USD',
      etbAmount: 30920.00,
      exchangeRate: 154.60,
      fee: 2.00,
      recipientName: 'KIDUS ATSBIH',
      recipientDetails: {
        'phoneNumber': '0911234567',
      },
      status: TransferStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
    Transfer(
      id: 'WR1704123456791',
      type: TransferType.cashPickup,
      amount: 1000.00,
      fromCurrency: 'EUR',
      etbAmount: 168450.00,
      exchangeRate: 168.45,
      fee: 10.00,
      recipientName: 'MERON TESFAYE',
      recipientDetails: {
        'phoneNumber': '0922345678',
        'fullName': 'MERON TESFAYE SOLOMON',
        'address': 'Addis Ababa, Ethiopia',
        'city': 'Addis Ababa',
        'region': 'Addis Ababa',
      },
      status: TransferStatus.completed,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      completedAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      pickupCode: 'PK789123',
    ),
  ];

  List<Transfer> get _filteredTransactions {
    if (_selectedFilter == 'All') {
      return _mockTransactions;
    }
    
    TransferStatus? status;
    switch (_selectedFilter) {
      case 'Completed':
        status = TransferStatus.completed;
        break;
      case 'Pending':
        status = TransferStatus.pending;
        break;
      case 'Failed':
        status = TransferStatus.failed;
        break;
      default:
        return _mockTransactions;
    }
    
    return _mockTransactions.where((transaction) => transaction.status == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Transactions'),
        backgroundColor: const Color(0xFFF37021),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((filter) {
                  final isSelected = filter == _selectedFilter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      },
                      selectedColor: const Color(0xFFF37021).withValues(alpha: 0.2),
                      checkmarkColor: const Color(0xFFF37021),
                      labelStyle: TextStyle(
                        color: isSelected ? const Color(0xFFF37021) : Colors.grey.shade600,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          
          // Transactions List
          Expanded(
            child: _filteredTransactions.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredTransactions.length,
                    itemBuilder: (context, index) {
                      final transaction = _filteredTransactions[index];
                      return _buildTransactionCard(transaction);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No transactions found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your transaction history will appear here',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(Transfer transaction) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          // Header Row
          Row(
            children: [
              // Transfer Type Icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getTransferTypeColor(transaction.type).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getTransferTypeIcon(transaction.type),
                  color: _getTransferTypeColor(transaction.type),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              // Transfer Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getTransferTypeName(transaction.type),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      transaction.recipientName,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusChip(transaction.status),
            ],
          ),

          const SizedBox(height: 16),

          // Amount Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'You Sent',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  Text(
                    '${transaction.amount.toStringAsFixed(2)} ${transaction.fromCurrency}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Recipient Gets',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  Text(
                    '${transaction.etbAmount.toStringAsFixed(2)} ETB',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF37021),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),
          
          // Transaction ID and Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ID: ${transaction.id}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
              Text(
                _formatDate(transaction.createdAt),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
          
          // Additional info for specific transfer types
          if (transaction.type == TransferType.cashPickup && transaction.pickupCode != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.qr_code,
                    color: Colors.blue.shade600,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Pickup Code: ${transaction.pickupCode}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusChip(TransferStatus status) {
    Color backgroundColor;
    Color textColor;
    String text;

    switch (status) {
      case TransferStatus.completed:
        backgroundColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        text = 'Completed';
        break;
      case TransferStatus.pending:
        backgroundColor = Colors.orange.shade50;
        textColor = Colors.orange.shade700;
        text = 'Pending';
        break;
      case TransferStatus.processing:
        backgroundColor = Colors.blue.shade50;
        textColor = Colors.blue.shade700;
        text = 'Processing';
        break;
      case TransferStatus.failed:
        backgroundColor = Colors.red.shade50;
        textColor = Colors.red.shade700;
        text = 'Failed';
        break;
      case TransferStatus.cancelled:
        backgroundColor = Colors.grey.shade50;
        textColor = Colors.grey.shade700;
        text = 'Cancelled';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Color _getTransferTypeColor(TransferType type) {
    switch (type) {
      case TransferType.wegagenBank:
        return const Color(0xFF2E7D7D);
      case TransferType.wegagenEbirr:
        return const Color(0xFFF37021);
      case TransferType.cashPickup:
        return Colors.purple;
      case TransferType.schoolPay:
        return Colors.blue;
    }
  }

  IconData _getTransferTypeIcon(TransferType type) {
    switch (type) {
      case TransferType.wegagenBank:
        return Icons.account_balance;
      case TransferType.wegagenEbirr:
        return Icons.phone_android;
      case TransferType.cashPickup:
        return Icons.send;
      case TransferType.schoolPay:
        return Icons.school;
    }
  }

  String _getTransferTypeName(TransferType type) {
    switch (type) {
      case TransferType.wegagenBank:
        return 'Bank Transfer';
      case TransferType.wegagenEbirr:
        return 'Wegagen E-birr';
      case TransferType.cashPickup:
        return 'Cash Pickup';
      case TransferType.schoolPay:
        return 'School Payment';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}