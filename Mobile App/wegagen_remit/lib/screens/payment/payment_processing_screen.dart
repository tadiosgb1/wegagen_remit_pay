import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/payment_providers.dart';
import '../../services/bonus_service.dart';
import '../../widgets/activity_tracker.dart';
import '../transfer/transfer_success_screen.dart';

class PaymentProcessingScreen extends ConsumerStatefulWidget {
  final String paymentToken;

  const PaymentProcessingScreen({
    super.key,
    required this.paymentToken,
  });

  @override
  ConsumerState<PaymentProcessingScreen> createState() => _PaymentProcessingScreenState();
}

class _PaymentProcessingScreenState extends ConsumerState<PaymentProcessingScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isProcessing = true;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _processPayment();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    try {
      // Get form data from provider
      final formData = ref.read(paymentFormProvider);
      
      // Process payment
      await ref.read(paymentProcessingProvider.notifier).processPayment(
        formData,
        widget.paymentToken,
      );
      
      // Wait a bit for animation
      await Future.delayed(const Duration(seconds: 2));
      
      setState(() {
        _isProcessing = false;
      });
      
      // Navigate to success screen after a short delay
      await Future.delayed(const Duration(seconds: 1));
      
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => TransferSuccessScreen(
              transferType: 'card_payment',
              recipientName: formData.toAccountHolder,
              // Show the exact sender input amount and currency
              amount: formData.amount,
              currency: formData.currency,
              // ETB amount should include the bonus if available
              etbAmount: formData.bonusCalculation?.totalRecipientETB ?? (formData.amount * formData.exchangeRate),
              exchangeRate: formData.exchangeRate,
              bonusCalculation: formData.bonusCalculation,
              transactionId: 'TXN${DateTime.now().millisecondsSinceEpoch}',
            ),
          ),
          (route) => route.isFirst,
        );
      }
    } catch (error) {
      setState(() {
        _isProcessing = false;
      });
      
      if (mounted) {
        _showErrorDialog(error.toString());
      }
    }
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Payment Failed'),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to payment screen
            },
            child: const Text('Try Again'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).popUntil((route) => route.isFirst); // Go to home
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final paymentState = ref.watch(paymentProcessingProvider);
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: ActivityTracker(
        interactionType: 'payment_processing_screen',
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Processing animation
                AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: _isProcessing 
                              ? const Color(0xFFF37021) 
                              : Colors.green,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (_isProcessing 
                                  ? const Color(0xFFF37021) 
                                  : Colors.green).withValues(alpha: 0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Icon(
                          _isProcessing ? Icons.credit_card : Icons.check,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 40),
                
                // Status text
                Text(
                  _isProcessing ? 'Processing Payment...' : 'Payment Successful!',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 16),
                
                Text(
                  _isProcessing 
                      ? 'Please wait while we securely process your payment'
                      : 'Your payment has been processed successfully',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 40),
                
                // Progress indicator
                if (_isProcessing) ...[
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF37021)),
                  ),
                  const SizedBox(height: 24),
                ],
                
                // Payment details
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
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
                      _buildDetailRow('Payment Token', 
                          '${widget.paymentToken.substring(0, 20)}...'),
                      const Divider(),
                      _buildDetailRow('Status', 
                          _isProcessing ? 'Processing' : 'Completed'),
                      const Divider(),
                      _buildDetailRow('Security', 'Bank-level encryption'),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Security info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.security,
                        color: Colors.blue.shade600,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Your payment is secured with industry-standard encryption and processed by CyberSource.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
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
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}