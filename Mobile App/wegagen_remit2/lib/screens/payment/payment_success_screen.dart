import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/payment_providers.dart';
import '../../widgets/activity_tracker.dart';

class PaymentSuccessScreen extends ConsumerStatefulWidget {
  final String transactionRef;
  final double amount;
  final String currency;
  final String recipientName;

  const PaymentSuccessScreen({
    super.key,
    required this.transactionRef,
    required this.amount,
    required this.currency,
    required this.recipientName,
  });

  @override
  ConsumerState<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends ConsumerState<PaymentSuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
    ));
    
    _animationController.forward();
    
    // Reset payment form
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(paymentFormProvider.notifier).reset();
      ref.read(paymentProcessingProvider.notifier).reset();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(symbol: '', decimalDigits: 2);
    
    return PopScope(
      canPop: false, // Prevent back navigation
      child: Scaffold(
        backgroundColor: Colors.white,
        body: ActivityTracker(
          interactionType: 'payment_success_screen',
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Success animation
                        AnimatedBuilder(
                          animation: _scaleAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _scaleAnimation.value,
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.green.shade200,
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  Icons.check_circle,
                                  size: 80,
                                  color: Colors.green.shade600,
                                ),
                              ),
                            );
                          },
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Success message
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Column(
                            children: [
                              const Text(
                                'Payment Successful!',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              
                              const SizedBox(height: 16),
                              
                              Text(
                                'Your money has been sent successfully to ${widget.recipientName}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // Transaction details
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: _buildTransactionDetails(currencyFormatter),
                        ),
                      ],
                    ),
                  ),
                  
                  // Action buttons
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildActionButtons(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionDetails(NumberFormat currencyFormatter) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Transaction Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          
          const SizedBox(height: 20),
          
          _buildDetailRow(
            'Transaction ID',
            widget.transactionRef,
            showCopy: true,
          ),
          
          const SizedBox(height: 16),
          
          _buildDetailRow(
            'Amount Sent',
            '${currencyFormatter.format(widget.amount)} ${widget.currency}',
          ),
          
          const SizedBox(height: 16),
          
          _buildDetailRow(
            'Recipient',
            widget.recipientName,
          ),
          
          const SizedBox(height: 16),
          
          _buildDetailRow(
            'Date & Time',
            DateFormat('MMM dd, yyyy • hh:mm a').format(DateTime.now()),
          ),
          
          const SizedBox(height: 16),
          
          _buildDetailRow(
            'Status',
            'Completed',
            statusColor: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool showCopy = false,
    Color? statusColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: statusColor ?? Colors.black87,
                  ),
                ),
              ),
              if (showCopy)
                GestureDetector(
                  onTap: () => _copyToClipboard(value),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.copy,
                      size: 16,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _shareTransaction,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF37021),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Share Receipt',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _goToHome,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFF37021),
              side: const BorderSide(color: Color(0xFFF37021)),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Back to Home',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        TextButton(
          onPressed: _sendAnother,
          child: const Text(
            'Send Another Transfer',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFFF37021),
            ),
          ),
        ),
      ],
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Transaction ID copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _shareTransaction() {
    final shareText = '''
🎉 Payment Successful!

Transaction ID: ${widget.transactionRef}
Amount: ${NumberFormat.currency(symbol: '', decimalDigits: 2).format(widget.amount)} ${widget.currency}
Recipient: ${widget.recipientName}
Date: ${DateFormat('MMM dd, yyyy • hh:mm a').format(DateTime.now())}

Sent via Wegagen Remit
''';

    // You can implement share functionality here
    // For now, copy to clipboard
    Clipboard.setData(ClipboardData(text: shareText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Receipt copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _goToHome() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _sendAnother() {
    Navigator.of(context).popUntil((route) => route.isFirst);
    // Navigate to transfer screen
    // You can implement navigation to transfer screen here
  }
}