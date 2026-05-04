import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/payment_providers.dart';
import '../../widgets/activity_tracker.dart';
import 'payment_success_screen.dart';
import 'payment_error_screen.dart';

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
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.repeat(reverse: true);
    
    // Start payment processing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _processPayment();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _processPayment() {
    final formData = ref.read(paymentFormProvider);
    ref.read(paymentProcessingProvider.notifier).processPayment(
      formData,
      widget.paymentToken,
    );
  }

  @override
  Widget build(BuildContext context) {
    final processingState = ref.watch(paymentProcessingProvider);
    
    // Listen to processing state changes
    ref.listen<AsyncValue<dynamic>>(paymentProcessingProvider, (previous, next) {
      next.whenOrNull(
        data: (response) {
          if (response != null) {
            _animationController.stop();
            if (response.isSuccess) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => PaymentSuccessScreen(
                    transactionRef: response.data?.transactionRef ?? '',
                    amount: ref.read(paymentFormProvider).amount,
                    currency: ref.read(paymentFormProvider).currency,
                    recipientName: ref.read(paymentFormProvider).toAccountHolder,
                  ),
                ),
              );
            } else {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => PaymentErrorScreen(
                    error: response.message ?? response.error ?? 'Payment failed',
                    canRetry: true,
                  ),
                ),
              );
            }
          }
        },
        error: (error, stack) {
          _animationController.stop();
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => PaymentErrorScreen(
                error: error.toString(),
                canRetry: true,
              ),
            ),
          );
        },
      );
    });

    return PopScope(
      canPop: false, // Prevent back navigation during processing
      child: Scaffold(
        backgroundColor: Colors.white,
        body: ActivityTracker(
          interactionType: 'payment_processing_screen',
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated processing icon
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF37021).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.payment,
                            size: 60,
                            color: Color(0xFFF37021),
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Processing text
                  const Text(
                    'Processing Payment',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  const Text(
                    'Please wait while we securely process your payment...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Progress indicator
                  const SizedBox(
                    width: 200,
                    child: LinearProgressIndicator(
                      color: Color(0xFFF37021),
                      backgroundColor: Color(0xFFFFE5D6),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Security message
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
                            'Your payment is being processed securely. Please do not close this screen.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Processing steps
                  _buildProcessingSteps(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProcessingSteps() {
    return Column(
      children: [
        _buildProcessingStep(
          icon: Icons.credit_card,
          title: 'Validating Payment',
          isCompleted: true,
        ),
        _buildProcessingStep(
          icon: Icons.security,
          title: 'Verifying Security',
          isCompleted: true,
        ),
        _buildProcessingStep(
          icon: Icons.account_balance,
          title: 'Processing Transfer',
          isCompleted: false,
          isActive: true,
        ),
        _buildProcessingStep(
          icon: Icons.check_circle,
          title: 'Confirming Transaction',
          isCompleted: false,
        ),
      ],
    );
  }

  Widget _buildProcessingStep({
    required IconData icon,
    required String title,
    required bool isCompleted,
    bool isActive = false,
  }) {
    Color iconColor;
    Color textColor;
    
    if (isCompleted) {
      iconColor = Colors.green;
      textColor = Colors.green.shade700;
    } else if (isActive) {
      iconColor = const Color(0xFFF37021);
      textColor = Colors.black87;
    } else {
      iconColor = Colors.grey.shade400;
      textColor = Colors.grey.shade500;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCompleted ? Icons.check : icon,
              size: 18,
              color: iconColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: textColor,
              ),
            ),
          ),
          if (isActive)
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: iconColor,
              ),
            ),
        ],
      ),
    );
  }
}