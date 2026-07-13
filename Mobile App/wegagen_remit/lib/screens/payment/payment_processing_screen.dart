import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/three_ds_service.dart';
import '../../providers/payment_providers.dart';
import '../../config/url_container.dart';
import '../transfer/transfer_success_screen.dart';
import 'three_ds_auth_screen.dart';

class PaymentProcessingScreen extends ConsumerStatefulWidget {
  final String paymentToken;
  final double? amount;
  final String? currency;
  final Map<String, dynamic>? billingInfo;
  final Map<String, dynamic>? recipientInfo;
  final String? remark;
  final ThreeDSAuthResult? threeDSResult;
  final String? transactionId;
  final String? transferType; // Add transfer type to detect cash pickup

  const PaymentProcessingScreen({
    super.key,
    required this.paymentToken,
    this.amount,
    this.currency,
    this.billingInfo,
    this.recipientInfo,
    this.remark,
    this.threeDSResult,
    this.transactionId,
    this.transferType,
  });

  @override
  ConsumerState<PaymentProcessingScreen> createState() =>
      _PaymentProcessingScreenState();
}

class _PaymentProcessingScreenState
    extends ConsumerState<PaymentProcessingScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  final ThreeDSService _threeDSService = ThreeDSService();

  String _currentStep = 'Initializing payment...';
  bool _isProcessing = true;
  bool _hasError = false;
  String? _errorMessage;
  PaymentResult? _paymentResult;

  final List<String> _steps = [
    'Initializing payment...',
    'Validating card details...',
    'Processing 3D Secure authentication...',
    'Completing payment...',
    'Payment successful!',
  ];

  int _currentStepIndex = 0;
  Timer? _stepTimer;

  @override
  void initState() {
    super.initState();
    
    if (kDebugMode) {
      print('\n🎯 === PAYMENT PROCESSING SCREEN INIT ===');
      print('📱 Received transferType: ${widget.transferType}');
      print('💳 Received paymentToken: ${widget.paymentToken.substring(0, 20)}...');
      print('💰 Received amount: ${widget.amount}');
      print('💱 Received currency: ${widget.currency}');
      print('🎯 === INIT COMPLETE ===\n');
    }
    
    _initializeAnimations();
    _processPayment();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _stepTimer?.cancel();
    super.dispose();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_animationController);
  }

  Future<void> _processPayment() async {
    try {
      // Start step animation
      _startStepAnimation();

      if (kDebugMode) {
        print('\n🚀 === PAYMENT PROCESSING SCREEN STARTED ===');
      }

      // Get form data from provider
      final formData = ref.read(paymentFormProvider);

      // Prepare payment data
      final billingInfo =
          widget.billingInfo ?? _getBillingInfoFromForm(formData);
      final recipientInfo =
          widget.recipientInfo ?? _getRecipientInfoFromForm(formData);
      final amount = widget.amount ?? formData.amount;
      final currency = widget.currency ?? formData.currency;

      if (kDebugMode) {
        print('💰 Payment Details:');
        print('   💵 Amount: $amount $currency');
        print(
            '   👤 Billing: ${billingInfo['first_name']} ${billingInfo['last_name']}');
        print('   📧 Email: ${billingInfo['email']}');
        print('   📱 Recipient: ${recipientInfo['account_holder']}');
        print('   🎫 Token: ${widget.paymentToken.length > 20 ? widget.paymentToken.substring(0, 20) + '...' : widget.paymentToken}');
      }

      if (amount <= 0) {
        throw Exception('Invalid payment amount');
      }

      _updateStep(1); // Validating card details

      if (kDebugMode) {
        print('\n🔄 Starting 3DS flow via ThreeDSService...');
      }

      // Process payment with 3DS - route to correct endpoint based on transfer type
      final paymentResult = await _threeDSService.processPaymentWith3DS(
        paymentToken: widget.paymentToken,
        amount: amount,
        currency: currency,
        billingInfo: billingInfo,
        recipientInfo: recipientInfo,
        remark: widget.remark ?? formData.remark,
        transferType: widget.transferType, // Pass transfer type for endpoint routing
      );

      if (kDebugMode) {
        print('\n✅ 3DS Flow completed. Analyzing result...');
        print('🎯 Payment Result Analysis:');
        print('   ✅ Success: ${paymentResult.success}');
        print('   📋 Status: ${paymentResult.status}');
        print('   🔐 Requires 3DS: ${paymentResult.requires3DS}');
        print(
            '   🎮 Needs Authentication: ${paymentResult.needsAuthentication}');

        if (paymentResult.threeDSEnrollment != null) {
          print('   📊 Enrollment Details:');
          print(
              '      🔐 Is Enrolled: ${paymentResult.threeDSEnrollment!.isEnrolled}');
          print(
              '      🔗 Step Up URL: ${paymentResult.threeDSEnrollment!.stepUpUrl != null ? 'Present' : 'Missing'}');
          print(
              '      🆔 Auth Transaction ID: ${paymentResult.threeDSEnrollment!.authenticationTransactionId}');
        }
      }

      _updateStep(2); // Processing 3D Secure authentication

      // Handle 3DS requirement - Check if challenge is actually needed
      if (paymentResult.needsAuthentication &&
          paymentResult.threeDSEnrollment != null) {
        // Check if we actually need to show challenge based on enrollment status
        final enrollmentStatus = paymentResult.threeDSEnrollment!.success;
        final isEnrolled = paymentResult.threeDSEnrollment!.isEnrolled;

        if (kDebugMode) {
          print('\n🎮 === CHALLENGE DECISION LOGIC ===');
          print('📊 Enrollment Status: $enrollmentStatus');
          print('🔐 Is Enrolled: $isEnrolled');
          print(
              '🔗 Step Up URL: ${paymentResult.threeDSEnrollment!.stepUpUrl != null ? 'Present' : 'Missing'}');
          print(
              '🆔 Auth Transaction ID: ${paymentResult.threeDSEnrollment!.authenticationTransactionId}');
        }

        // Only show OTP page if status is PENDING_AUTHENTICATION
        if (enrollmentStatus &&
            isEnrolled &&
            paymentResult.threeDSEnrollment!.stepUpUrl != null) {
          if (kDebugMode) {
            print('\n🎮 === CHALLENGE REQUIRED - OPENING 3DS SCREEN ===');
            print('📱 Status is PENDING_AUTHENTICATION - showing OTP page');
            print('📱 Opening ThreeDSAuthScreen...');
            print(
                '🔗 stepUpUrl: ${paymentResult.threeDSEnrollment!.stepUpUrl}');
            print(
                '🆔 authTransactionId: ${paymentResult.threeDSEnrollment!.authenticationTransactionId}');
          }

          await _handle3DSAuthentication(
              paymentResult, billingInfo, recipientInfo);
          return;
        } else {
          if (kDebugMode) {
            print('\n📋 === NO CHALLENGE REQUIRED - FRICTIONLESS FLOW ===');
            print(
                '🎯 Status is not PENDING_AUTHENTICATION - skipping OTP page');
            print('✅ Proceeding directly to payment finalization');
          }
        }
      } else {
        if (kDebugMode) {
          print('\n📋 === NO 3DS REQUIRED ===');
          print('🎯 Card does not require 3D Secure authentication');
          print('✅ Proceeding directly to payment finalization');
        }
      }

      // Proceed directly to payment finalization (skip OTP)
      if (kDebugMode) {
        print('\n💳 === DIRECT PAYMENT FINALIZATION ===');
        print('🚀 Calling finalizePayment without 3DS challenge...');
      }

      _updateStep(3); // Completing payment

      try {
        // Determine if this is a cash pickup transfer
        final isCashPickup = widget.transferType == 'cash_pickup';
        
        if (kDebugMode) {
          print('💳 Transfer Type: ${widget.transferType}');
          print('💰 Is Cash Pickup: $isCashPickup');
          if (isCashPickup) {
            print('🏪 Using Cash Pickup endpoint: ${UrlContainer.processPaymentWith3DSForCashPicup}');
          } else {
            print('🏦 Using Regular endpoint: ${UrlContainer.processPaymentWith3DS}');
          }
        }

        // Call appropriate payment finalization method
        final PaymentResult finalPaymentResult;
        
        if (isCashPickup) {
          // Call cash pickup payment finalization with recipient info
          finalPaymentResult = await _threeDSService.finalizeCashPickupPayment(
            transientToken: paymentResult.transientToken ?? widget.paymentToken,
            customerId: paymentResult.customerId ?? '',
            amount: paymentResult.amount ?? 0,
            exchangeRate: 1.0,
            authenticationPayload: {
              'consumerAuthenticationInformation': {
                'authenticationTransactionId':
                    paymentResult.threeDSEnrollment?.authenticationTransactionId,
                'cavv': null, // No CAVV for frictionless
                'xid': null, // No XID for frictionless
                'eciRaw': '07', // Internet transaction
                'ucafAuthenticationData': null,
                'ucafCollectionIndicator': null,
              }
            },
            recipientInfo: recipientInfo, // Pass recipient info for account search
          );
        } else {
          // Call regular payment finalization
          finalPaymentResult = await _threeDSService.finalizePayment(
            transientToken: paymentResult.transientToken ?? widget.paymentToken,
            customerId: paymentResult.customerId ?? '',
            amount: paymentResult.amount ?? 0,
            exchangeRate: 1.0,
            authenticationPayload: {
              'consumerAuthenticationInformation': {
                'authenticationTransactionId':
                    paymentResult.threeDSEnrollment?.authenticationTransactionId,
                'cavv': null, // No CAVV for frictionless
                'xid': null, // No XID for frictionless
                'eciRaw': '07', // Internet transaction
                'ucafAuthenticationData': null,
                'ucafCollectionIndicator': null,
              }
            },
          );
        }

        if (kDebugMode) {
          print('✅ Payment finalization successful!');
          print('🆔 Final Transaction ID: ${finalPaymentResult.transactionId}');
        }

        _updateStep(4); // Payment successful

        setState(() {
          _paymentResult = finalPaymentResult;
          _isProcessing = false;
        });

        if (kDebugMode) {
          print('🎉 === DIRECT PAYMENT FLOW COMPLETED SUCCESSFULLY ===\n');
        }

        _navigateToSuccess();
      } catch (e) {
        if (kDebugMode) {
          print('\n❌ === DIRECT PAYMENT FINALIZATION FAILED ===');
          print('💥 Error during direct finalization: $e');
          print('❌ === DIRECT FINALIZATION ERROR END ===\n');
        }

        setState(() {
          _hasError = true;
          _errorMessage = 'Payment finalization failed: ${e.toString()}';
          _isProcessing = false;
        });
        _animationController.stop();
      }
    } catch (e) {
      if (kDebugMode) {
        print('\n❌ === PAYMENT PROCESSING FAILED ===');
        print('💥 Error: $e');
        print('🔍 Check logs above for where the flow stopped');
        print('❌ === PAYMENT PROCESSING ERROR END ===\n');
      }

      debugPrint('💳 Payment processing error: $e');
      setState(() {
        _hasError = true;
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isProcessing = false;
      });
      _animationController.stop();
    }
  }

  Future<void> _handle3DSAuthentication(
    PaymentResult paymentResult,
    Map<String, dynamic> billingInfo,
    Map<String, dynamic> recipientInfo,
  ) async {
    // Navigate to 3DS authentication screen
    if (!mounted) return;

    if (kDebugMode) {
      print('\n🎮 === _handle3DSAuthentication CALLED ===');
      print('📱 About to navigate to ThreeDSAuthScreen');
      print('🔗 stepUpUrl: ${paymentResult.threeDSEnrollment!.stepUpUrl}');
      print(
          '🆔 authTransactionId: ${paymentResult.threeDSEnrollment!.authenticationTransactionId}');
      print('👤 customerId: ${paymentResult.customerId}');
      print('💰 Amount: ${paymentResult.amount}');
      print('💱 Currency: ${paymentResult.currency}');
      print(
          '🎫 Payment Token: ${paymentResult.transientToken ?? widget.paymentToken}');
      print(
          '👤 Billing Name: ${billingInfo['first_name']} ${billingInfo['last_name']}');
      print('📱 Recipient: ${recipientInfo['account_holder']}');
    }

    final authResult = await Navigator.of(context).push<ThreeDSAuthResult>(
      MaterialPageRoute(
        builder: (context) => ThreeDSAuthScreen(
          threeDSEnrollment: paymentResult.threeDSEnrollment!,
          paymentToken: paymentResult.transientToken ?? widget.paymentToken,
          amount: paymentResult.amount ?? 0,
          currency: paymentResult.currency ?? 'USD',
          billingInfo: billingInfo,
          recipientInfo: recipientInfo,
          customerId: paymentResult.customerId ?? '', // Pass the customer ID
          remark: widget.remark,
        ),
      ),
    );

    if (kDebugMode) {
      print('\n🔙 === RETURNED FROM ThreeDSAuthScreen ===');
      print('📱 3DS Screen closed, analyzing result...');
      if (authResult != null) {
        print(' Auth Result received:');
        print('   🔐 Success: ${authResult.success}');
        print('   📊 Status: ${authResult.status}');
        print('   🎯 Is Authenticated: ${authResult.isAuthenticated}');
        print('   🎲 Is Attempted: ${authResult.isAttempted}');
        print(
            '   🔑 Auth Transaction ID: ${authResult.authenticationTransactionId}');
        print('   🛡️ CAVV: ${authResult.cavv}');
        print('   🔒 ECI: ${authResult.eci}');
      } else {
        print('❌ Auth Result is NULL - user cancelled or error occurred');
      }
    }

    if (authResult != null &&
        (authResult.isAuthenticated || authResult.isAttempted)) {
      if (kDebugMode) {
        print('\n === 3DS AUTHENTICATION SUCCESSFUL ===');
        print('🔄 Proceeding to finalize payment...');
      }

      // 3DS authentication successful, finalize payment
      _updateStep(3); // Completing payment

      try {
        if (kDebugMode) {
          print('💳 Calling finalizePayment with 3DS data...');
        }

        // Determine if this is a cash pickup transfer  
        final isCashPickup = widget.transferType == 'cash_pickup';
        
        if (kDebugMode) {
          print('💳 3DS Auth - Transfer Type: ${widget.transferType}');
          print('💰 3DS Auth - Is Cash Pickup: $isCashPickup');
        }

        // Call appropriate payment finalization method with 3DS data
        final PaymentResult finalPaymentResult;
        
        if (isCashPickup) {
          // Call cash pickup payment finalization with 3DS authentication
          finalPaymentResult = await _threeDSService.finalizeCashPickupPayment(
            transientToken: paymentResult.transientToken ?? widget.paymentToken,
            customerId: paymentResult.customerId ?? '',
            amount: paymentResult.amount ?? 0,
            exchangeRate: 1.0,
            authenticationPayload: {
              'consumerAuthenticationInformation': {
                'authenticationTransactionId':
                    authResult.authenticationTransactionId,
                'cavv': authResult.cavv,
                'xid': authResult.xid,
                'eciRaw': authResult.eci,
                'ucafAuthenticationData': authResult.ucafAuthenticationData,
                'ucafCollectionIndicator': authResult.ucafCollectionIndicator,
              }
            },
            recipientInfo: recipientInfo, // Pass recipient info for account search
          );
        } else {
          // Call regular payment finalization with 3DS authentication
          finalPaymentResult = await _threeDSService.finalizePayment(
            transientToken: paymentResult.transientToken ?? widget.paymentToken,
            customerId: paymentResult.customerId ?? '',
            amount: paymentResult.amount ?? 0,
            exchangeRate: 1.0,
            authenticationPayload: {
              'consumerAuthenticationInformation': {
                'authenticationTransactionId':
                    authResult.authenticationTransactionId,
                'cavv': authResult.cavv,
                'xid': authResult.xid,
                'eciRaw': authResult.eci,
                'ucafAuthenticationData': authResult.ucafAuthenticationData,
                'ucafCollectionIndicator': authResult.ucafCollectionIndicator,
              }
            },
          );
        }

        if (kDebugMode) {
          print('✅ Payment finalization successful!');
          print('🆔 Final Transaction ID: ${finalPaymentResult.transactionId}');
        }

        _updateStep(4); // Payment successful

        setState(() {
          _paymentResult = finalPaymentResult;
          _isProcessing = false;
        });

        if (kDebugMode) {
          print('🎉 === 3DS PAYMENT FLOW COMPLETED SUCCESSFULLY ===\n');
        }

        _navigateToSuccess();
      } catch (e) {
        if (kDebugMode) {
          print('\n❌ === PAYMENT FINALIZATION FAILED ===');
          print('💥 Error during finalization: $e');
          print('❌ === FINALIZATION ERROR END ===\n');
        }

        setState(() {
          _hasError = true;
          _errorMessage = 'Payment finalization failed: ${e.toString()}';
          _isProcessing = false;
        });
        _animationController.stop();
      }
    } else {
      if (kDebugMode) {
        print('\n❌ === 3DS AUTHENTICATION FAILED ===');
        print(
            '💥 Reason: ${authResult == null ? 'User cancelled' : 'Authentication not successful'}');
        print('🔍 Auth result: $authResult');
        print('❌ === 3DS AUTH FAILURE END ===\n');
      }

      // 3DS authentication failed or cancelled
      setState(() {
        _hasError = true;
        _errorMessage = '3D Secure authentication failed. Please try again.';
        _isProcessing = false;
      });
      _animationController.stop();
    }
  }

  Map<String, dynamic> _getBillingInfoFromForm(dynamic formData) {
    return {
      'first_name': formData.firstName ?? '',
      'last_name': formData.lastName ?? '',
      'email': formData.email ?? '',
      'address1': formData.address1 ?? '',
      'locality': formData.locality ?? '',
      'administrative_area': formData.administrativeArea ?? '',
      'postal_code': formData.postalCode ?? '',
      'country': formData.country ?? 'ET',
    };
  }

  Map<String, dynamic> _getRecipientInfoFromForm(dynamic formData) {
    return {
      'account_holder': formData.toAccountHolder ?? '',
      'account_number': formData.toAccount ?? '',
      'amount': formData.amount ?? 0,
      'currency': formData.currency ?? 'USD',
    };
  }

  void _startStepAnimation() {
    _stepTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_currentStepIndex < _steps.length - 1 && _isProcessing) {
        _updateStep(_currentStepIndex + 1);
      } else {
        timer.cancel();
      }
    });
  }

  void _updateStep(int stepIndex) {
    if (stepIndex < _steps.length && mounted) {
      setState(() {
        _currentStepIndex = stepIndex;
        _currentStep = _steps[stepIndex];
      });
    }
  }

  void _navigateToSuccess() {
    Timer(const Duration(seconds: 1), () {
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => TransferSuccessScreen(
              transactionId: _paymentResult?.transactionId ??
                  widget.transactionId ??
                  'N/A',
              transferType: 'payment',
              amount: _paymentResult?.amount ?? widget.amount ?? 0,
              currency: _paymentResult?.currency ?? widget.currency ?? 'USD',
              etbAmount: (_paymentResult?.amount ?? widget.amount ?? 0) *
                  1.0, // exchange rate
              recipientName:
                  widget.recipientInfo?['account_holder'] ?? 'Recipient',
              exchangeRate:
                  1, // You might want to get this from the payment result
            ),
          ),
          (route) => route.isFirst,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Animation
              if (_isProcessing) ...[
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Transform.rotate(
                        angle: _rotationAnimation.value * 2 * 3.14159,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFFF37021),
                                const Color(0xFFF37021).withValues(alpha: 0.6),
                              ],
                            ),
                          ),
                          child: const Icon(
                            Icons.credit_card,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ] else if (_hasError) ...[
                Container(
                  width: 120,
                  height: 120,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                  ),
                  child: const Icon(
                    Icons.error_outline,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
              ] else ...[
                Container(
                  width: 120,
                  height: 120,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // Status Text
              Text(
                _hasError
                    ? 'Payment Failed'
                    : _isProcessing
                        ? 'Processing Payment'
                        : 'Payment Successful!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Current Step or Error
              Text(
                _hasError ? _errorMessage! : _currentStep,
                style: TextStyle(
                  fontSize: 16,
                  color: _hasError ? Colors.red : Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),

              if (_isProcessing) ...[
                const SizedBox(height: 24),
                LinearProgressIndicator(
                  value: (_currentStepIndex + 1) / _steps.length,
                  backgroundColor: Colors.grey.shade200,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Color(0xFFF37021)),
                ),
              ],

              const Spacer(),

              // Action Buttons
              if (_hasError) ...[
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Go Back'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _hasError = false;
                            _isProcessing = true;
                            _currentStepIndex = 0;
                            _currentStep = _steps[0];
                          });
                          _animationController.repeat();
                          _processPayment();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF37021),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Retry Payment'),
                      ),
                    ),
                  ],
                ),
              ] else if (!_isProcessing) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _navigateToSuccess(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF37021),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Continue'),
                  ),
                ),
              ],

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
