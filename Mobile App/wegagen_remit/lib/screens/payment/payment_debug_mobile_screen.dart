import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../providers/payment_providers.dart';
import '../../widgets/activity_tracker.dart';

class PaymentDebugMobileScreen extends ConsumerStatefulWidget {
  const PaymentDebugMobileScreen({super.key});

  @override
  ConsumerState<PaymentDebugMobileScreen> createState() => _PaymentDebugMobileScreenState();
}

class _PaymentDebugMobileScreenState extends ConsumerState<PaymentDebugMobileScreen> with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  bool _isLoading = true;
  String? _error;
  String? _captureContext;
  WebViewController? _webViewController;
  String? _loadedCaptureContext;
  List<String> _debugLogs = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializePayment();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Keep the controller alive where possible; only null it when truly disposing.
    // Do not aggressively recreate the WebView on transient lifecycle events.
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Log lifecycle changes for debugging; avoid disposing controller on pause/resume.
    _addDebugLog('AppLifecycleState changed: $state');
    if (state == AppLifecycleState.resumed) {
      // Optionally reload if webview lost context on some devices
      // _webViewController?.reload();
    }
  }

  void _addDebugLog(String message) {
    setState(() {
      _debugLogs.add('${DateTime.now().toString().substring(11, 19)}: $message');
    });
    print('DEBUG: $message');
  }

  void _initializePayment() async {
    try {
      _addDebugLog('Starting mobile payment initialization...');
      
      final captureContextAsync = ref.read(captureContextProvider);
      
      captureContextAsync.when(
        data: (response) {
          _addDebugLog('Capture context received successfully');
          setState(() {
            _captureContext = response.data.captureContext;
          });
          _setupMobilePayment();
        },
        loading: () {
          _addDebugLog('Capture context is loading from backend...');
        },
        error: (error, stack) {
          _addDebugLog('Capture context error: $error');
          setState(() {
            _error = 'Failed to get payment configuration: $error';
            _isLoading = false;
          });
        },
      );
    } catch (e) {
      _addDebugLog('Exception in _initializePayment: $e');
      setState(() {
        _error = 'Failed to initialize payment: $e';
        _isLoading = false;
      });
    }
  }

  void _setupMobilePayment() {
    if (_captureContext == null) return;
    if (_loadedCaptureContext == _captureContext) {
      _addDebugLog('Capture context already loaded, skipping setup');
      return;
    }

    _addDebugLog('Setting up mobile WebView...');
    
    // Create WebView controller with debug logging
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent('Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36')
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            _addDebugLog('Page started loading: $url');
          },
          onPageFinished: (String url) {
            _addDebugLog('Page finished loading: $url');
            
            // Inject debug script to detect origin
            _webViewController?.runJavaScript('''
              console.log('=== MOBILE ORIGIN DEBUG ===');
              console.log('window.location.origin:', window.location.origin);
              console.log('window.location.href:', window.location.href);
              console.log('window.location.protocol:', window.location.protocol);
              console.log('window.location.host:', window.location.host);
              console.log('document.domain:', document.domain);
              console.log('User Agent:', navigator.userAgent);
              
              // Send origin info to Flutter
              if (window.DebugChannel && window.DebugChannel.postMessage) {
                window.DebugChannel.postMessage(JSON.stringify({
                  type: 'ORIGIN_INFO',
                  origin: window.location.origin,
                  href: window.location.href,
                  protocol: window.location.protocol,
                  host: window.location.host,
                  userAgent: navigator.userAgent
                }));
              }
            ''');
          },
          onWebResourceError: (WebResourceError error) {
            _addDebugLog('WebView error: ${error.description}');
            setState(() {
              _error = 'Failed to load payment form: ${error.description}';
              _isLoading = false;
            });
          },
        ),
      )
      ..addJavaScriptChannel(
        'DebugChannel',
        onMessageReceived: (JavaScriptMessage message) {
          try {
            final data = jsonDecode(message.message);
            if (data['type'] == 'ORIGIN_INFO') {
              _addDebugLog('=== ORIGIN DETECTED ===');
              _addDebugLog('Origin: ${data['origin']}');
              _addDebugLog('Full URL: ${data['href']}');
              _addDebugLog('Protocol: ${data['protocol']}');
              _addDebugLog('Host: ${data['host']}');
              _addDebugLog('User Agent: ${data['userAgent']}');
              _addDebugLog('=== ADD THIS TO BACKEND ===');
              _addDebugLog('request.targetOrigins = [');
              _addDebugLog('  \'${data['origin']}\',');
              _addDebugLog('  \'http://localhost:3000\',');
              _addDebugLog('  \'http://10.195.49.18:3001\'');
              _addDebugLog('];');
            }
          } catch (e) {
            _addDebugLog('Error parsing debug message: $e');
          }
        },
      )
      ..addJavaScriptChannel(
        'PaymentChannel',
        onMessageReceived: (JavaScriptMessage message) {
          try {
            final data = jsonDecode(message.message);
            if (data['type'] == 'PAYMENT_TOKEN') {
              _addDebugLog('Payment token received successfully!');
            }
          } catch (e) {
            _addDebugLog('Error parsing payment message: $e');
          }
        },
      );

    // Load the debug HTML content with a base origin that matches the captureContext
    final htmlContent = _createDebugHTML();
    final origin = _extractCaptureOrigin(_captureContext) ?? 'https://appassets.androidplatform.net';
    _addDebugLog('Loading debug HTML with origin: $origin');
    try {
      _webViewController!.loadHtmlString(htmlContent, baseUrl: origin);
    } catch (e) {
      // Older webview versions may not support baseUrl parameter
      _addDebugLog('loadHtmlString with baseUrl failed: $e. Falling back to default load.');
      _webViewController!.loadHtmlString(htmlContent);
    }
    _loadedCaptureContext = _captureContext;
    
    setState(() {
      _isLoading = false;
    });
  }

  String _createDebugHTML() {
    return '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mobile Origin Debug</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: #f5f5f5;
            padding: 16px;
        }
        
        .container {
            max-width: 100%;
            margin: 0 auto;
            background: white;
            border-radius: 12px;
            padding: 20px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        
        .debug-info {
            background: #f8f9fa;
            border: 1px solid #dee2e6;
            border-radius: 8px;
            padding: 16px;
            margin-bottom: 20px;
            font-family: monospace;
            font-size: 12px;
            white-space: pre-wrap;
        }
        
        .status {
            background: #e8f5e8;
            color: #2d5a2d;
            padding: 12px;
            border-radius: 8px;
            margin-bottom: 16px;
            text-align: center;
        }
        
        .error {
            background: #fee;
            color: #c33;
            padding: 12px;
            border-radius: 8px;
            margin-bottom: 16px;
            display: none;
        }
        
        .error.show {
            display: block;
        }
        
        .test-button {
            width: 100%;
            background: #F37021;
            color: white;
            border: none;
            padding: 16px;
            border-radius: 8px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            margin-top: 16px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h2>🔍 Mobile Origin Debug</h2>
        <p style="margin-bottom: 20px; color: #666;">This screen will detect your mobile app's origin for CyberSource configuration.</p>
        
        <div class="status" id="status">
            Detecting mobile origin...
        </div>
        
        <div class="error" id="error-message"></div>
        
        <div class="debug-info" id="debug-info">
            Initializing debug detection...
        </div>
        
        <button class="test-button" onclick="detectOrigin()">
            🔄 Re-detect Origin
        </button>
        
        <button class="test-button" onclick="testCyberSource()" style="background: #28a745;">
            🧪 Test CyberSource Connection
        </button>
    </div>

    <script>
        function updateDebugInfo(info) {
            document.getElementById('debug-info').textContent = info;
        }
        
        function updateStatus(message) {
            document.getElementById('status').textContent = message;
        }
        
        function showError(message) {
            const errorDiv = document.getElementById('error-message');
            errorDiv.textContent = message;
            errorDiv.classList.add('show');
        }
        
        function detectOrigin() {
            updateStatus('Detecting origin...');
            
            const originInfo = {
                origin: window.location.origin,
                href: window.location.href,
                protocol: window.location.protocol,
                host: window.location.host,
                hostname: window.location.hostname,
                port: window.location.port,
                pathname: window.location.pathname,
                userAgent: navigator.userAgent,
                platform: navigator.platform,
                cookieEnabled: navigator.cookieEnabled,
                onLine: navigator.onLine
            };
            
            const debugText = 
                '=== MOBILE ORIGIN DETECTION ===\\n' +
                'Origin: ' + originInfo.origin + '\\n' +
                'Full URL: ' + originInfo.href + '\\n' +
                'Protocol: ' + originInfo.protocol + '\\n' +
                'Host: ' + originInfo.host + '\\n' +
                'Hostname: ' + originInfo.hostname + '\\n' +
                'Port: ' + originInfo.port + '\\n' +
                'Path: ' + originInfo.pathname + '\\n' +
                'User Agent: ' + originInfo.userAgent + '\\n' +
                'Platform: ' + originInfo.platform + '\\n' +
                'Online: ' + originInfo.onLine + '\\n\\n' +
                '=== BACKEND CONFIGURATION ===\\n' +
                'Add this to your backend payments.service.ts:\\n\\n' +
                'request.targetOrigins = [\\n' +
                '  \\'' + originInfo.origin + '\\',\\n' +
                '  \\'http://localhost:3000\\',\\n' +
                '  \\'http://10.195.49.18:3001\\',\\n' +
                '  \\'https://10.195.49.18:3001\\'\\n' +
                '];\\n\\n' +
                '=== FLUTTER DEBUG INFO ===\\n' +
                'This origin should be added to targetOrigins\\n' +
                'in your backend CyberSource configuration.';
            
            updateDebugInfo(debugText);
            updateStatus('✅ Origin detected! Check debug info below.');
            
            // Send to Flutter
            if (window.DebugChannel && window.DebugChannel.postMessage) {
                window.DebugChannel.postMessage(JSON.stringify({
                    type: 'ORIGIN_INFO',
                    ...originInfo
                }));
            }
        }
        
        function testCyberSource() {
            updateStatus('Testing CyberSource connection...');
            
            try {
                // Test if CyberSource script loads
                const script = document.createElement('script');
                script.src = 'https://testflex.cybersource.com/microform/bundle/v2.9.0/flex-microform.min.js';
                script.onload = function() {
                    updateStatus('✅ CyberSource script loaded successfully!');
                    
                    // Test Flex initialization
                    setTimeout(() => {
                        if (typeof Flex !== 'undefined') {
                            updateStatus('✅ CyberSource Flex library available!');
                            
                            // Test with dummy capture context
                            try {
                                const captureContext = ${jsonEncode(_captureContext)};
                                if (captureContext && captureContext.length > 100) {
                                    updateStatus('✅ Valid capture context available!');
                                    
                                    // Test Flex instance creation
                                    try {
                                        const flex = new Flex(captureContext);
                                        updateStatus('✅ Flex instance created successfully!');
                                        
                                        // Test microform creation
                                        try {
                                            const microform = flex.microform('card');
                                            updateStatus('✅ Microform created successfully! Ready for payment.');
                                        } catch (microformError) {
                                            showError('❌ Microform creation failed: ' + microformError.message);
                                        }
                                    } catch (flexError) {
                                        showError('❌ Flex instance creation failed: ' + flexError.message);
                                    }
                                } else {
                                    showError('❌ Invalid capture context from backend');
                                }
                            } catch (contextError) {
                                showError('❌ Capture context error: ' + contextError.message);
                            }
                        } else {
                            showError('❌ CyberSource Flex library not available');
                        }
                    }, 1000);
                };
                script.onerror = function() {
                    showError('❌ Failed to load CyberSource script');
                };
                document.head.appendChild(script);
            } catch (error) {
                showError('❌ Test failed: ' + error.message);
            }
        }
        
        // Auto-detect on load
        document.addEventListener('DOMContentLoaded', function() {
            setTimeout(detectOrigin, 1000);
        });
        
        // Also detect immediately if DOM is already ready
        if (document.readyState === 'complete' || document.readyState === 'interactive') {
            setTimeout(detectOrigin, 1000);
        }
    </script>
</body>
</html>
    ''';
  }

  String? _extractCaptureOrigin(String? captureContext) {
    if (captureContext == null) return null;
    try {
      final parts = captureContext.split('.');
      if (parts.length < 2) return null;
      var payload = parts[1];
      final mod = payload.length % 4;
      if (mod > 0) payload = payload + List.filled(4 - mod, '=').join();
      final decoded = utf8.decode(base64Url.decode(payload));
      final Map<String, dynamic> json = jsonDecode(decoded);
      if (json.containsKey('flx') && json['flx'] is Map && json['flx']['origin'] != null) {
        return json['flx']['origin'].toString();
      }
    } catch (e) {
      _addDebugLog('Failed to extract capture origin: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // required when using AutomaticKeepAliveClientMixin
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Mobile Origin Debug'),
        backgroundColor: const Color(0xFFF37021),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _initializePayment,
          ),
        ],
      ),
      body: Column(
        children: [
          // Debug logs section
          Container(
            height: 200,
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
                  '📱 Mobile Debug Logs',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: _debugLogs.length,
                    itemBuilder: (context, index) {
                      return Text(
                        _debugLogs[index],
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
          
          // WebView section
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildBody(),
            ),
          ),
          
          // Instructions
          Container(
            margin: const EdgeInsets.all(16),
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
                  '📋 Instructions:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '1. Wait for origin detection to complete\n'
                  '2. Copy the detected origin from debug info\n'
                  '3. Add it to your backend targetOrigins\n'
                  '4. Test CyberSource connection',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  Widget _buildBody() {
    if (_error != null) {
      return _buildErrorState();
    }

    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFFF37021)),
            SizedBox(height: 16),
            Text('Initializing debug mode...'),
          ],
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: _webViewController != null
          ? WebViewWidget(controller: _webViewController!)
          : const Center(child: Text('Loading debug screen...')),
    );
  }

  Widget _buildErrorState([String? errorMessage]) {
    final displayError = errorMessage ?? _error ?? 'Unknown error occurred';
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.red.shade400),
            const SizedBox(height: 24),
            Text(
              'Debug Setup Failed',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade600,
              ),
            ),
            const SizedBox(height: 16),
            Text(displayError, textAlign: TextAlign.center),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _initializePayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF37021),
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry Debug'),
            ),
          ],
        ),
      ),
    );
  }
}