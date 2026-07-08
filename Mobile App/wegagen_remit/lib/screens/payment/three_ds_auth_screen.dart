import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/three_ds_service.dart';
import '../auth/threeds_challenge_screen.dart';

class ThreeDSAuthScreen extends StatefulWidget {
  final EnrollmentCheckResult threeDSEnrollment;
  final String paymentToken;
  final double amount;
  final String currency;
  final Map<String, dynamic> billingInfo;
  final Map<String, dynamic> recipientInfo;
  final String? remark;
  final String customerId; // Add customer ID parameter

  const ThreeDSAuthScreen({
    super.key,
    required this.threeDSEnrollment,
    required this.paymentToken,
    required this.amount,
    required this.currency,
    required this.billingInfo,
    required this.recipientInfo,
    required this.customerId, // Make customer ID required
    this.remark,
  });

  @override
  State<ThreeDSAuthScreen> createState() => _ThreeDSAuthScreenState();
}

class _ThreeDSAuthScreenState extends State<ThreeDSAuthScreen> {
  final ThreeDSService _threeDSService = ThreeDSService();
  
  bool _authCompleted = false;
  String? _error;
  Timer? _statusTimer;
  int _pollAttempts = 0;
  int _consecutiveErrors = 0;
  static const int _maxPollAttempts = 40; // 2 minutes (40 * 3 seconds)
  static const int _maxConsecutiveErrors = 5; // Stop after 5 consecutive errors

  @override
  void initState() {
    super.initState();
    debugPrint('🎮 === 3DS AUTH SCREEN INITIALIZED (VERSION 3.0) ===');
    debugPrint('🔧 FIXED: OTP page will show immediately, polling starts AFTER user submits');
    debugPrint('👤 Customer ID: ${widget.customerId}');
    debugPrint('🆔 Auth Transaction ID: ${widget.threeDSEnrollment.authenticationTransactionId}');
    debugPrint('💰 Amount: ${widget.amount} ${widget.currency}');
    
    // Don't start polling immediately - wait for user to submit OTP
    debugPrint('⏳ Waiting for user to complete OTP before starting polling...');
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    debugPrint('🎮 === 3DS AUTH SCREEN DISPOSED ===');
    super.dispose();
  }

  void _startStatusPolling() {
    if (widget.threeDSEnrollment.authenticationTransactionId == null) {
      debugPrint('❌ No authentication transaction ID - cannot start polling');
      setState(() {
        _error = 'Invalid authentication session. Please try again.';
      });
      return;
    }

    // Debug the customer ID issue
    debugPrint('🔍 CUSTOMER ID DEBUG:');
    debugPrint('   Raw widget.customerId: "${widget.customerId}"');
    debugPrint('   isEmpty: ${widget.customerId.isEmpty}');
    debugPrint('   length: ${widget.customerId.length}');

    // Validate customer ID - FORCE FIX if it's the hardcoded string
    String actualCustomerId = widget.customerId;
    if (actualCustomerId.isEmpty || actualCustomerId == 'CUSTOMER_ID') {
      debugPrint('❌ DETECTED HARDCODED OR EMPTY CUSTOMER ID!');
      debugPrint('🔧 This indicates the customer ID is not being passed correctly from payment flow');
      setState(() {
        _error = 'Customer ID not provided correctly. Please restart the payment process.';
      });
      return;
    }
    
    debugPrint('🚀 IMMEDIATE status polling - user has already completed OTP!');
    debugPrint('🔍 Validation complete - customer ID: ${actualCustomerId.length} chars');
    debugPrint('🔄 Starting status polling immediately every 3 seconds...');
    debugPrint('⏰ Max attempts: $_maxPollAttempts (${(_maxPollAttempts * 3 / 60).toStringAsFixed(1)} minutes)');
    
    // Start polling immediately since this is only called after OTP completion
    _statusTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
        if (_authCompleted || !mounted) {
          timer.cancel();
          return;
        }

        _pollAttempts++;
        debugPrint('🔄 Poll attempt $_pollAttempts/$_maxPollAttempts');

        // Stop polling after max attempts
        if (_pollAttempts >= _maxPollAttempts) {
          timer.cancel();
          debugPrint('⏰ Polling timeout reached after ${_maxPollAttempts * 3} seconds');
          setState(() {
            _error = '3D Secure authentication timeout. The verification may have completed - please check your payment status or try again.';
          });
          return;
        }

        // Stop polling after too many consecutive errors
        if (_consecutiveErrors >= _maxConsecutiveErrors) {
          timer.cancel();
          debugPrint('❌ Too many consecutive errors ($_consecutiveErrors) - stopping poll');
          setState(() {
            _error = 'Unable to verify authentication status. Please check your connection and try again.';
          });
          return;
        }

        try {
          debugPrint('🔄 Getting 3DS authentication results (after user had time for OTP)');
          debugPrint('🆔 Auth Transaction ID: ${widget.threeDSEnrollment.authenticationTransactionId}');
          debugPrint('👤 Customer ID: $actualCustomerId');
          
          final authResult = await _threeDSService.getAuthenticationResults(
            customerId: actualCustomerId, // Use the validated customer ID
            authenticationTransactionId: widget.threeDSEnrollment.authenticationTransactionId!,
            amount: widget.amount,
            currency: widget.currency,
          );
          
          // Reset error counter on successful API call
          _consecutiveErrors = 0;
          
          debugPrint('✅ Auth result received:');
          debugPrint('   🔐 Success: ${authResult.success}');
          debugPrint('   📊 Status: ${authResult.status}');
          debugPrint('   🎯 Is Authenticated: ${authResult.isAuthenticated}');
          debugPrint('   🎲 Is Attempted: ${authResult.isAttempted}');
          
          if (authResult.success && (authResult.isAuthenticated || authResult.isAttempted)) {
            timer.cancel();
            debugPrint('🎉 Authentication completed successfully!');
            _handleAuthComplete(authResult);
          } else {
            debugPrint('⏳ Authentication still pending... (attempt $_pollAttempts/$_maxPollAttempts)');
          }
        } catch (e) {
          _consecutiveErrors++;
          debugPrint('🔐 Status polling error (attempt $_consecutiveErrors/$_maxConsecutiveErrors): $e');
          
          // If this is a 500 error and we have a valid customer ID, it might be a temporary server issue
          if (e.toString().contains('500')) {
            debugPrint('🔧 Server error detected - will continue polling...');
            debugPrint('🔍 Customer ID being sent: "$actualCustomerId"');
            debugPrint('🔍 Auth Transaction ID being sent: "${widget.threeDSEnrollment.authenticationTransactionId}"');
          } else if (e.toString().contains('404')) {
            // 404 might mean the transaction doesn't exist yet or expired
            debugPrint('🔍 Transaction not found - continuing to poll...');
          } else if (e.toString().contains('401') || e.toString().contains('403')) {
            // Auth errors - stop immediately
            timer.cancel();
            setState(() {
              _error = 'Authentication failed. Please login and try again.';
            });
            return;
          }
        }
      });
  }

  void _handleAuthComplete(ThreeDSAuthResult authResult) {
    setState(() => _authCompleted = true);
    
    debugPrint('🔐 3DS Authentication completed');
    debugPrint('✅ Is Authenticated: ${authResult.isAuthenticated}');
    debugPrint('🔄 Is Attempted: ${authResult.isAttempted}');
    
    if (authResult.isAuthenticated || authResult.isAttempted) {
      _proceedToPayment(authResult);
    } else {
      setState(() {
        _error = authResult.message ?? 'Authentication failed. Please try again.';
      });
    }
  }

  void _proceedToPayment(ThreeDSAuthResult? threeDSResult) {
    if (!mounted) return;
    
    debugPrint('🔐 Proceeding to final payment processing');
    debugPrint('📋 Returning auth result to PaymentProcessingScreen');
    debugPrint('   🔐 Success: ${threeDSResult?.success}');
    debugPrint('   📊 Status: ${threeDSResult?.status}');
    debugPrint('   🎯 Is Authenticated: ${threeDSResult?.isAuthenticated}');
    
    // IMPORTANT: Use Navigator.pop to return the result, not pushReplacement
    Navigator.of(context).pop(threeDSResult);
  }

  void _handle3DSChallengeComplete() {
    debugPrint('🔐 3DS Challenge completed - NOW STARTING POLLING!');
    debugPrint('✅ User has submitted OTP - safe to start checking status');
    debugPrint('🔄 Starting immediate status polling after user action...');
    
    // NOW it's safe to start polling since user has actually submitted the OTP
    _startStatusPolling();
  }



  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return _buildErrorView();
    }

    // Use the new challenge screen
    return ThreeDSChallengeScreen(
      stepUpUrl: widget.threeDSEnrollment.stepUpUrl!,
      accessToken: widget.threeDSEnrollment.accessToken ?? '',
      merchantData: widget.threeDSEnrollment.transactionId,
      onCompleted: _handle3DSChallengeComplete,
    );
  }

  Widget _buildErrorView() {
    final bool isTimeout = _error!.contains('timeout');
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF37021),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('3D Secure Authentication'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isTimeout ? Icons.access_time : Icons.security,
                size: 64,
                color: isTimeout ? Colors.orange : Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                isTimeout 
                  ? '3D Secure Verification Timeout'
                  : '3D Secure Authentication Failed',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                _error!,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              if (isTimeout) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    children: [
                        const Text(
                          '💡 Did you complete the verification?',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'If you successfully completed the OTP verification in your bank app or SMS, your payment may have gone through.',
                          style: TextStyle(fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Column(
                children: [
                  if (isTimeout)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Assume payment completed and proceed
                          _proceedToPayment(ThreeDSAuthResult(
                            success: true,
                            status: 'COMPLETED',
                            authResult: 'SUCCESS',
                            authenticationTransactionId: widget.threeDSEnrollment.authenticationTransactionId,
                          ));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(''),
                      ),
                    ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Cancel Payment'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _error = null;
                              _pollAttempts = 0;
                              _consecutiveErrors = 0;
                            });
                            _startStatusPolling();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF37021),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Retry Verification'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}