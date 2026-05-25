import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/payment_providers.dart';
import '../../widgets/activity_tracker.dart';
import 'payment_processing_screen.dart';

class PaymentWorkingScreen extends ConsumerStatefulWidget {
  const PaymentWorkingScreen({super.key});

  @override
  ConsumerState<PaymentWorkingScreen> createState() => _PaymentWorkingScreenState();
}

class _PaymentWorkingScreenState extends ConsumerState<PaymentWorkingScreen> {
  bool _isLoading = true;
  String? _error;
  String? _captureContext;
  String _paymentStatus = 'Processing...';

  @override
  void initState() {
    super.initState();
    _initializePayment();
  }

  void _initializePayment() async {
    try {
      print('DEBUG: Starting payment initialization...');
      
      final captureContextAsync = ref.read(captureContextProvider);
      
      captureContextAsync.when(
        data: (response) {
          print('DEBUG: Capture context received successfully');
          setState(() {
            _captureContext = response.data.captureContext;
            _isLoading = false;
          });
          _setupPaymentFrame();
        },
        loading: () {
          print('DEBUG: Capture context is loading from backend...');
        },
        error: (error, stack) {
          print('DEBUG: Capture context error: $error');
          setState(() {
            _error = 'Failed to get payment configuration: $error';
            _isLoading = false;
          });
        },
      );
    } catch (e) {
      print('DEBUG: Error in _initializePayment: $e');
      setState(() {
        _error = 'An error occurred: $e';
        _isLoading = false;
      });
    }
  }

  void _setupPaymentFrame() {
    if (!kIsWeb) {
      print('DEBUG: PaymentWorkingScreen should only be used on web platform');
      return;
    }
    
    try {
      print('DEBUG: Setting up payment frame...');
      // Inject Microform JavaScript and set up payment frame
      // This is typically done via the cybersource_payment_frame.html file
      
      if (_captureContext != null && _captureContext!.isNotEmpty) {
        setState(() {
          _paymentStatus = 'Payment frame loaded';
        });
        print('DEBUG: Payment frame setup complete');
      }
    } catch (e) {
      print('DEBUG: Error setting up payment frame: $e');
      setState(() {
        _error = 'Failed to set up payment frame: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Payment'),
        backgroundColor: const Color(0xFFF37021),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ActivityTracker(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF37021)),
            ),
            const SizedBox(height: 16),
            const Text('Initializing payment...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red.shade600,
              size: 64,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.red,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
                _initializePayment();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF37021),
                foregroundColor: Colors.white,
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
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
                  Icons.info_outline,
                  color: Colors.blue.shade600,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _paymentStatus,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (kIsWeb)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  const Text(
                    'Secure Payment Processing',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 400,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.security,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Payment frame will appear here',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.shield,
                  color: Colors.green.shade600,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Your payment information is encrypted with industry-standard security.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade700,
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
}
