import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/payment_providers.dart';
import '../../widgets/activity_tracker.dart';

class PaymentTestScreen extends ConsumerStatefulWidget {
  const PaymentTestScreen({super.key});

  @override
  ConsumerState<PaymentTestScreen> createState() => _PaymentTestScreenState();
}

class _PaymentTestScreenState extends ConsumerState<PaymentTestScreen> {
  String? _captureContext;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCaptureContext();
  }

  void _loadCaptureContext() async {
    try {
      final captureContextAsync = ref.read(captureContextProvider);
      
      captureContextAsync.when(
        data: (response) {
          setState(() {
            _captureContext = response.data.captureContext;
            _isLoading = false;
          });
        },
        loading: () {
          setState(() {
            _isLoading = true;
          });
        },
        error: (error, stack) {
          setState(() {
            _error = error.toString();
            _isLoading = false;
          });
        },
      );
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Payment Test'),
        backgroundColor: const Color(0xFFF37021),
        foregroundColor: Colors.white,
      ),
      body: ActivityTracker(
        interactionType: 'payment_test_screen',
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFFF37021)),
            SizedBox(height: 16),
            Text('Loading capture context...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 80, color: Colors.red.shade400),
              const SizedBox(height: 24),
              Text(
                'Error Loading Capture Context',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade600,
                ),
              ),
              const SizedBox(height: 16),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _error = null;
                    _isLoading = true;
                  });
                  _loadCaptureContext();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF37021),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade600),
                    const SizedBox(width: 8),
                    Text(
                      'Capture Context Loaded Successfully',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Length: ${_captureContext?.length ?? 0} characters',
                  style: TextStyle(color: Colors.green.shade600),
                ),
                Text(
                  'Platform: ${kIsWeb ? "Web" : "Mobile"}',
                  style: TextStyle(color: Colors.green.shade600),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          const Text(
            'Capture Context Details:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'First 100 characters:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                SelectableText(
                  _captureContext?.substring(0, 100) ?? 'No context',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                const Text(
                  'JWT Header (decoded):',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                SelectableText(
                  _decodeJWTHeader(_captureContext ?? ''),
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Next Steps:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '1. The capture context is loading successfully from your backend',
                  style: TextStyle(color: Colors.blue.shade600),
                ),
                Text(
                  '2. The issue is likely in the CyberSource Flex library loading',
                  style: TextStyle(color: Colors.blue.shade600),
                ),
                Text(
                  '3. Check backend targetOrigins configuration',
                  style: TextStyle(color: Colors.blue.shade600),
                ),
                Text(
                  '4. Verify CORS settings allow iframe access',
                  style: TextStyle(color: Colors.blue.shade600),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Open CyberSource test page in new tab
                if (kIsWeb) {
                  // This would open a test page
                  _showTestInstructions();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF37021),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Show Test Instructions'),
            ),
          ),
        ],
      ),
    );
  }

  String _decodeJWTHeader(String jwt) {
    try {
      if (jwt.isEmpty) return 'No JWT token';
      
      final parts = jwt.split('.');
      if (parts.length < 2) return 'Invalid JWT format';
      
      // Decode the header (first part)
      String header = parts[0];
      
      // Add padding if needed
      while (header.length % 4 != 0) {
        header += '=';
      }
      
      // This is a simplified decode - in a real app you'd use a proper JWT library
      return 'JWT Header: $header (Base64 encoded)';
    } catch (e) {
      return 'Error decoding JWT: $e';
    }
  }

  void _showTestInstructions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backend Configuration Required'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Your capture context is working, but the CyberSource Flex library needs backend configuration updates:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text('1. In your backend file:'),
              Text('   src/payments/payments.service.ts'),
              SizedBox(height: 8),
              Text('2. Change targetOrigins from:'),
              Text('   ["http://localhost:3000"]'),
              SizedBox(height: 8),
              Text('3. To:'),
              Text('   ["*"]  // Allow all origins for development'),
              SizedBox(height: 16),
              Text('4. Restart your backend server'),
              Text('5. Try the payment flow again'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}