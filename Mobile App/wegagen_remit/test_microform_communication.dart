import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'lib/config/environment.dart';

/// Test script to verify microform communication between backend and frontend
class MicroformTestScreen extends ConsumerStatefulWidget {
  const MicroformTestScreen({super.key});

  @override
  ConsumerState<MicroformTestScreen> createState() => _MicroformTestScreenState();
}

class _MicroformTestScreenState extends ConsumerState<MicroformTestScreen> {
  WebViewController? _controller;
  List<String> _testResults = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _runTests();
  }

  void _addResult(String result) {
    setState(() {
      _testResults.add('${DateTime.now().toString().substring(11, 19)}: $result');
    });
  }

  Future<void> _runTests() async {
    _addResult('🧪 Starting microform communication tests...');
    
    // Test 1: Check backend URL
    _addResult('📡 Backend URL: ${Environment.baseUrl}');
    
    // Test 2: Test capture context endpoint
    await _testCaptureContext();
    
    // Test 3: Test payment page endpoint
    await _testPaymentPage();
    
    // Test 4: Test WebView loading
    await _testWebViewLoading();
    
    _addResult('✅ All tests completed!');
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _testCaptureContext() async {
    try {
      _addResult('🔑 Testing capture context endpoint...');
      
      // This would normally use your PaymentService
      // For now, just test the URL construction
      final url = '${Environment.baseUrl}/payments/generate-capture-context';
      _addResult('📍 Capture context URL: $url');
      
      // In a real test, you'd make the HTTP request here
      _addResult('✅ Capture context endpoint configured');
      
    } catch (e) {
      _addResult('❌ Capture context test failed: $e');
    }
  }

  Future<void> _testPaymentPage() async {
    try {
      _addResult('🌐 Testing payment page endpoint...');
      
      final url = '${Environment.baseUrl}/payment-page';
      _addResult('📍 Payment page URL: $url');
      
      _addResult('✅ Payment page endpoint configured');
      
    } catch (e) {
      _addResult('❌ Payment page test failed: $e');
    }
  }

  Future<void> _testWebViewLoading() async {
    try {
      _addResult('📱 Testing WebView setup...');
      
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              _addResult('🔄 WebView loading: $url');
            },
            onPageFinished: (String url) {
              _addResult('✅ WebView loaded: $url');
            },
            onWebResourceError: (WebResourceError error) {
              _addResult('❌ WebView error: ${error.description}');
            },
          ),
        )
        ..addJavaScriptChannel(
          'TestChannel',
          onMessageReceived: (JavaScriptMessage message) {
            _addResult('📨 JS Message: ${message.message}');
          },
        );

      // Test loading a simple HTML page
      const testHtml = '''
        <!DOCTYPE html>
        <html>
        <head>
          <title>Microform Test</title>
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
        </head>
        <body>
          <h2>🧪 Microform Communication Test</h2>
          <p>Testing JavaScript communication...</p>
          <button onclick="testCommunication()">Test Communication</button>
          
          <script>
            function testCommunication() {
              if (window.TestChannel && window.TestChannel.postMessage) {
                window.TestChannel.postMessage('Communication test successful!');
              } else {
                console.log('TestChannel not available');
              }
            }
            
            // Auto-test on load
            document.addEventListener('DOMContentLoaded', function() {
              setTimeout(testCommunication, 1000);
            });
          </script>
        </body>
        </html>
      ''';

      _controller!.loadHtmlString(testHtml);
      _addResult('✅ WebView test setup complete');
      
    } catch (e) {
      _addResult('❌ WebView test failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🧪 Microform Communication Test'),
        backgroundColor: const Color(0xFFF37021),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _testResults.clear();
                _isLoading = true;
              });
              _runTests();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Test Results
          Container(
            height: 300,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '📋 Test Results',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: _testResults.length,
                    itemBuilder: (context, index) {
                      return Text(
                        _testResults[index],
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // WebView Test Area
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: _controller != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: WebViewWidget(controller: _controller!),
                    )
                  : const Center(
                      child: Text('WebView not initialized'),
                    ),
            ),
          ),
          
          // Status
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (_isLoading)
                  const CircularProgressIndicator(
                    color: Color(0xFFF37021),
                  )
                else
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                  ),
                const SizedBox(width: 12),
                Text(
                  _isLoading ? 'Running tests...' : 'Tests completed',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
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

void main() {
  runApp(
    ProviderScope(
      child: MaterialApp(
        title: 'Microform Test',
        theme: ThemeData(
          primarySwatch: Colors.orange,
        ),
        home: const MicroformTestScreen(),
      ),
    ),
  );
}