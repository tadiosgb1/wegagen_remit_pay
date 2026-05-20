import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/payment_providers.dart';
import 'payment_working_screen.dart';
import 'payment_webview_screen.dart';

class PaymentDebugScreen extends ConsumerStatefulWidget {
  const PaymentDebugScreen({super.key});

  @override
  ConsumerState<PaymentDebugScreen> createState() => _PaymentDebugScreenState();
}

class _PaymentDebugScreenState extends ConsumerState<PaymentDebugScreen> {
  @override
  Widget build(BuildContext context) {
    final captureContextAsync = ref.watch(captureContextProvider);
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Payment Debug'),
        backgroundColor: const Color(0xFFF37021),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Platform Info
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
                  const Text(
                    'Platform Information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Platform: ${defaultTargetPlatform.name}'),
                  Text('Is Web: ${kIsWeb ? "Yes" : "No"}'),
                  Text('Debug Mode: ${kDebugMode ? "Yes" : "No"}'),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Capture Context Status
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
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
                  const Text(
                    'Capture Context Status',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  captureContextAsync.when(
                    data: (response) => _buildSuccessInfo(response),
                    loading: () => _buildLoadingInfo(),
                    error: (error, stack) => _buildErrorInfo(error, stack),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Test Microform Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to actual microform screen using MaterialPageRoute
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => kIsWeb 
                          ? const PaymentWorkingScreen()
                          : const PaymentWebViewScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF37021),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Test Microform'),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Refresh Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  ref.invalidate(captureContextProvider);
                },
                child: const Text('Refresh Capture Context'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessInfo(dynamic response) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade600),
            const SizedBox(width: 8),
            const Text(
              'Success',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text('Status: ${response.status}'),
        if (response.data?.captureContext != null) ...[
          const SizedBox(height: 8),
          Text('Token Length: ${response.data.captureContext.length} chars'),
          const SizedBox(height: 8),
          Text(
            'Token Preview: ${response.data.captureContext.substring(0, 50)}...',
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ],
        if (response.data?.sessionId != null) ...[
          const SizedBox(height: 8),
          Text('Session ID: ${response.data.sessionId}'),
        ],
      ],
    );
  }

  Widget _buildLoadingInfo() {
    return const Row(
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        SizedBox(width: 12),
        Text('Loading capture context...'),
      ],
    );
  }

  Widget _buildErrorInfo(Object error, StackTrace? stack) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.error, color: Colors.red.shade600),
            const SizedBox(width: 8),
            const Text(
              'Error',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Error: $error',
          style: const TextStyle(color: Colors.red),
        ),
        if (kDebugMode && stack != null) ...[
          const SizedBox(height: 8),
          const Text(
            'Stack Trace:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              stack.toString(),
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 10,
              ),
            ),
          ),
        ],
      ],
    );
  }
}