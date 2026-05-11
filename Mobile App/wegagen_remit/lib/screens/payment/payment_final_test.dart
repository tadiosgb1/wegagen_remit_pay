import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/payment_providers.dart';
import '../../widgets/activity_tracker.dart';
import 'payment_working_screen.dart';

class PaymentFinalTest extends ConsumerStatefulWidget {
  const PaymentFinalTest({super.key});

  @override
  ConsumerState<PaymentFinalTest> createState() => _PaymentFinalTestState();
}

class _PaymentFinalTestState extends ConsumerState<PaymentFinalTest> {
  @override
  Widget build(BuildContext context) {
    final captureContextAsync = ref.watch(captureContextProvider);
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Payment Final Test'),
        backgroundColor: const Color(0xFFF37021),
        foregroundColor: Colors.white,
      ),
      body: ActivityTracker(
        interactionType: 'payment_final_test',
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: captureContextAsync.when(
            data: (response) => _buildSuccessView(response.data.captureContext),
            loading: () => _buildLoadingView(),
            error: (error, stack) => _buildErrorView(error.toString()),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
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

  Widget _buildErrorView(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red.shade400),
          const SizedBox(height: 16),
          Text(
            'Error Loading Capture Context',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(error, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              ref.invalidate(captureContextProvider);
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView(String captureContext) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Success indicator
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green.shade600),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '✅ Backend Connection: SUCCESS',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                      Text(
                        '✅ Capture Context: RECEIVED',
                        style: TextStyle(color: Colors.green.shade600),
                      ),
                      Text(
                        '✅ Token Length: ${captureContext.length} chars',
                        style: TextStyle(color: Colors.green.shade600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Capture context details
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
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'First 200 characters:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                SelectableText(
                  captureContext.length > 200 
                      ? '${captureContext.substring(0, 200)}...'
                      : captureContext,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                const Text(
                  'JWT Structure Check:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Text(
                  _analyzeJWT(captureContext),
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Next steps
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
                  '🎯 Ready for Payment!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your backend is working correctly. The capture context is being generated and received successfully.',
                  style: TextStyle(color: Colors.blue.shade600),
                ),
                const SizedBox(height: 12),
                Text(
                  'Next Steps:',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.blue.shade700,
                  ),
                ),
                Text(
                  '1. ✅ Backend generating capture context',
                  style: TextStyle(color: Colors.blue.shade600),
                ),
                Text(
                  '2. ✅ Flutter receiving capture context',
                  style: TextStyle(color: Colors.blue.shade600),
                ),
                Text(
                  '3. 🔄 Test the microform loading',
                  style: TextStyle(color: Colors.blue.shade600),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Test microform button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _testMicroform(captureContext);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF37021),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Test Microform Loading',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _analyzeJWT(String jwt) {
    try {
      final parts = jwt.split('.');
      if (parts.length == 3) {
        return '✅ Valid JWT structure (3 parts)\n'
               '   Header: ${parts[0].length} chars\n'
               '   Payload: ${parts[1].length} chars\n'
               '   Signature: ${parts[2].length} chars';
      } else {
        return '❌ Invalid JWT structure (${parts.length} parts, expected 3)';
      }
    } catch (e) {
      return '❌ Error analyzing JWT: $e';
    }
  }

  void _testMicroform(String captureContext) {
    if (kIsWeb) {
      // Navigate to the working payment screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const PaymentWorkingScreen(),
        ),
      );
    } else {
      // Show message for non-web platforms
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Microform testing is only available on web platform'),
        ),
      );
    }
  }
}