import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/payment_providers.dart';
import '../../widgets/activity_tracker.dart';
import 'payment_screen.dart';

class PaymentErrorScreen extends ConsumerStatefulWidget {
  final String error;
  final bool canRetry;

  const PaymentErrorScreen({
    super.key,
    required this.error,
    this.canRetry = true,
  });

  @override
  ConsumerState<PaymentErrorScreen> createState() => _PaymentErrorScreenState();
}

class _PaymentErrorScreenState extends ConsumerState<PaymentErrorScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
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
    
    // Reset payment processing state
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
    return PopScope(
      canPop: false, // Prevent back navigation
      child: Scaffold(
        backgroundColor: Colors.white,
        body: ActivityTracker(
          interactionType: 'payment_error_screen',
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Error animation
                        AnimatedBuilder(
                          animation: _scaleAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _scaleAnimation.value,
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.red.shade200,
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  Icons.error_outline,
                                  size: 80,
                                  color: Colors.red.shade600,
                                ),
                              ),
                            );
                          },
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Error message
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Column(
                            children: [
                              const Text(
                                'Payment Failed',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              
                              const SizedBox(height: 16),
                              
                              Text(
                                _getErrorMessage(widget.error),
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
                        
                        // Error details
                        if (_shouldShowErrorDetails()) ...[
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: _buildErrorDetails(),
                          ),
                          const SizedBox(height: 40),
                        ],
                        
                        // Help section
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: _buildHelpSection(),
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

  Widget _buildErrorDetails() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.red.shade600,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Error Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.error,
            style: TextStyle(
              fontSize: 14,
              color: Colors.red.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _getHelpMessage(),
            style: TextStyle(
              fontSize: 14,
              color: Colors.blue.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        if (widget.canRetry) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _retryPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF37021),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Try Again',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _goToPaymentForm,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFF37021),
              side: const BorderSide(color: Color(0xFFF37021)),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Back to Payment Form',
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
          child: TextButton(
            onPressed: _goToHome,
            child: const Text(
              'Back to Home',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 20),
        
        TextButton(
          onPressed: _contactSupport,
          child: const Text(
            'Contact Support',
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

  String _getErrorMessage(String error) {
    // Map technical errors to user-friendly messages
    if (error.toLowerCase().contains('network') || 
        error.toLowerCase().contains('connection')) {
      return 'Please check your internet connection and try again.';
    } else if (error.toLowerCase().contains('timeout')) {
      return 'The request timed out. Please try again.';
    } else if (error.toLowerCase().contains('declined') || 
               error.toLowerCase().contains('insufficient')) {
      return 'Your payment was declined. Please check your card details or try a different payment method.';
    } else if (error.toLowerCase().contains('expired')) {
      return 'Your session has expired. Please start a new payment.';
    } else if (error.toLowerCase().contains('invalid')) {
      return 'Invalid payment information. Please check your details and try again.';
    } else {
      return 'We encountered an issue processing your payment. Please try again or contact support.';
    }
  }

  String _getHelpMessage() {
    if (widget.error.toLowerCase().contains('network') || 
        widget.error.toLowerCase().contains('connection')) {
      return 'Check your internet connection and ensure you have a stable network before retrying.';
    } else if (widget.error.toLowerCase().contains('declined')) {
      return 'Contact your bank to ensure your card is active and has sufficient funds. You can also try a different payment method.';
    } else {
      return 'If this problem persists, please contact our support team for assistance. We\'re here to help!';
    }
  }

  bool _shouldShowErrorDetails() {
    // Show technical details for debugging in development
    return widget.error.isNotEmpty && widget.error.length < 200;
  }

  void _retryPayment() {
    // Go back to WebView to retry payment
    Navigator.of(context).pop();
  }

  void _goToPaymentForm() {
    // Go back to payment form
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const PaymentScreen()),
      (route) => route.isFirst,
    );
  }

  void _goToHome() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _contactSupport() {
    // Implement support contact functionality
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Contact Support'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Need help? Contact our support team:'),
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
}