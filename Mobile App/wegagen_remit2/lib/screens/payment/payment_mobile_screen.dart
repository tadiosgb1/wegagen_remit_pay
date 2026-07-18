import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import '../../providers/payment_providers.dart';
import '../../widgets/activity_tracker.dart';
import 'payment_processing_screen.dart';

class PaymentMobileScreen extends ConsumerStatefulWidget {
  const PaymentMobileScreen({super.key});

  @override
  ConsumerState<PaymentMobileScreen> createState() =>
      _PaymentMobileScreenState();
}

class _PaymentMobileScreenState extends ConsumerState<PaymentMobileScreen> {
  late WebViewController controller;
  bool isLoading = true;
  String? _error;
  String? _captureContext;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    late final PlatformWebViewControllerCreationParams params;

    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    controller = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..enableZoom(false);

    // Configure Android-specific settings for CyberSource
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    controller
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            debugPrint('📄 Page started loading: $url');
          },
          onPageFinished: (String url) {
            debugPrint('✅ Page finished loading: $url');
            setState(() {
              isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('❌ WebView error: ${error.description}');
            setState(() {
              _error = 'Failed to load payment form: ${error.description}';
              isLoading = false;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            debugPrint('🔗 Navigation request: ${request.url}');
            // Allow all CyberSource domains
            return NavigationDecision.navigate;
          },
        ),
      )
      ..addJavaScriptChannel(
        'FlutterPayment',
        onMessageReceived: (JavaScriptMessage message) {
          _handlePaymentMessage(message.message);
        },
      )
      ..addJavaScriptChannel(
        'ConsoleChannel',
        onMessageReceived: (JavaScriptMessage message) {
          debugPrint('WebView Console: ${message.message}');
        },
      )
      ..addJavaScriptChannel(
        'PaymentChannel',
        onMessageReceived: (JavaScriptMessage message) {
          _handlePaymentMessage(message.message);
        },
      );

    _loadPaymentData();
  }

  void _loadPaymentData() async {
    try {
      final captureContextAsync = ref.read(captureContextProvider);

      captureContextAsync.when(
        data: (response) {
          setState(() {
            _captureContext = response.data.captureContext;
          });
          _loadPaymentPage();
        },
        loading: () {
          // Keep loading state
        },
        error: (error, stack) {
          setState(() {
            _error = 'Failed to get payment configuration: $error';
            isLoading = false;
          });
        },
      );
    } catch (e) {
      setState(() {
        _error = 'Failed to initialize payment: $e';
        isLoading = false;
      });
    }
  }

  void _loadPaymentPage() {
    if (_captureContext == null) {
      setState(() {
        _error = 'No capture context available for payment initialization';
        isLoading = false;
      });
      return;
    }

    debugPrint('🔄 Loading microform with capture context');
    final htmlContent = _createMicroformHTML();
    controller.loadHtmlString(htmlContent);
  }

  String _createMicroformHTML() {
    return '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
    <title>Secure Payment</title>
    <meta http-equiv="Content-Security-Policy" content="
        default-src 'self' https:;
        script-src 'self' 'unsafe-inline' 'unsafe-eval' https://testflex.cybersource.com https://*.cybersource.com;
        frame-src https://testflex.cybersource.com https://*.cybersource.com;
        child-src https://testflex.cybersource.com https://*.cybersource.com;
        connect-src 'self' https://testflex.cybersource.com https://*.cybersource.com http://10.195.49.18;
        img-src 'self' data: https:;
        style-src 'self' 'unsafe-inline' https:;
        font-src 'self' https:;
    ">
    <style>
        * {
            box-sizing: border-box;
        }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segui UI', Roboto, sans-serif;
            background-color: #f5f5f5;
            padding: 16px;
            margin: 0;
            min-height: 100vh;
        }
        
        .container {
            max-width: 100%;
            margin: 0 auto;
            background: white;
            border-radius: 12px;
            padding: 20px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        
        .header {
            text-align: center;
            margin-bottom: 20px;
        }
        
        .header h2 {
            color: #333;
            margin-bottom: 8px;
            font-size: 20px;
        }
        
        .form-group {
            margin-bottom: 16px;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 6px;
            color: #333;
            font-weight: 500;
            font-size: 14px;
        }
        
        .microform-field {
            width: 100% !important;
            min-height: 50px !important;
            border: 2px solid #e1e1e1;
            border-radius: 8px;
            padding: 12px;
            font-size: 16px;
            background: white;
            display: block !important;
            visibility: visible !important;
        }
        
        .card-row {
            display: flex;
            gap: 12px;
        }
        
        .card-row .form-group {
            flex: 1;
        }
        
        .pay-button {
            width: 100%;
            background: #F37021;
            color: white;
            border: none;
            padding: 16px;
            border-radius: 8px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            margin-top: 20px;
        }
        
        .pay-button:hover {
            background: #e5631e;
        }
        
        .pay-button:disabled {
            background: #cccccc;
            cursor: not-allowed;
        }
        
        .status {
            padding: 10px;
            border-radius: 4px;
            margin: 10px 0;
            font-size: 14px;
        }
        
        .status.info {
            background: #e7f3ff;
            color: #0066cc;
        }
        
        .status.success {
            background: #e8f5e8;
            color: #2d5a2d;
        }
        
        .status.error {
            background: #fee;
            color: #c33;
        }
        
        .loading {
            display: none;
            text-align: center;
            padding: 20px;
        }
        
        .loading.show {
            display: block;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h2>Secure Payment</h2>
            <p>🔒 Secured by CyberSource</p>
        </div>
        
        <div id="status" class="status info">Initializing secure payment...</div>
        
        <form id="payment-form" style="display: none;">
            <div class="form-group">
                <label for="number-field">Card Number *</label>
                <div id="number-field" class="microform-field"></div>
            </div>
            
            <div class="card-row">
                <div class="form-group">
                    <label for="month-field">Month *</label>
                    <div id="month-field" class="microform-field"></div>
                </div>
                
                <div class="form-group">
                    <label for="year-field">Year *</label>
                    <div id="year-field" class="microform-field"></div>
                </div>
                
                <div class="form-group">
                    <label for="cvv-field">CVV *</label>
                    <div id="cvv-field" class="microform-field"></div>
                </div>
            </div>
            
            <button type="submit" id="pay-button" class="pay-button">
                Process Payment
            </button>
        </form>
        
        <div id="loading" class="loading">
            <p>Processing payment...</p>
        </div>
    </div>

    <script src="https://testflex.cybersource.com/microform/bundle/v2.9.0/flex-microform.min.js" 
            crossorigin="anonymous"></script>
    
    <script>
        const captureContext = ${jsonEncode(_captureContext)};
        let flex, microform;
        let numberField, monthField, yearField, cvvField;
        
        function updateStatus(message, type = 'info') {
            const statusDiv = document.getElementById('status');
            statusDiv.textContent = message;
            statusDiv.className = 'status ' + type;
            console.log('[Microform Status]', message);
            
            // Send status to Flutter
            if (window.ConsoleChannel) {
                ConsoleChannel.postMessage('Status: ' + message);
            }
        }
        
        function showError(message) {
            updateStatus(message, 'error');
            document.getElementById('loading').classList.remove('show');
            document.getElementById('payment-form').style.display = 'block';
        }
        
        function showLoading(show) {
            const loading = document.getElementById('loading');
            const form = document.getElementById('payment-form');
            const button = document.getElementById('pay-button');
            
            if (show) {
                loading.classList.add('show');
                form.style.display = 'none';
                button.disabled = true;
            } else {
                loading.classList.remove('show');
                form.style.display = 'block';
                button.disabled = false;
            }
        }
        
        function initializeMicroform() {
            try {
                updateStatus('Loading CyberSource SDK...', 'info');
                
                if (typeof Flex === 'undefined') {
                    throw new Error('CyberSource Flex library not loaded');
                }
                
                updateStatus('Creating Flex instance...', 'info');
                flex = new Flex(captureContext);
                
                updateStatus('Creating microform...', 'info');
                microform = flex.microform('card', {
                    styles: {
                        'input': {
                            'font-size': '16px',
                            'font-family': 'Arial, sans-serif',
                            'color': '#333',
                            'placeholder-color': '#999'
                        }
                    }
                });
                
                updateStatus('Creating secure form fields...', 'info');
                
                // Create fields with fallback error handling
                try {
                    numberField = microform.createField('number', { 
                        placeholder: '1234 5678 9012 3456' 
                    });
                    monthField = microform.createField('expirationMonth', { 
                        placeholder: 'MM' 
                    });
                    yearField = microform.createField('expirationYear', { 
                        placeholder: 'YY' 
                    });
                    cvvField = microform.createField('securityCode', { 
                        placeholder: '123' 
                    });
                } catch (createError) {
                    console.log('createField failed, trying field() method:', createError);
                    numberField = microform.field('number', { placeholder: '1234 5678 9012 3456' });
                    monthField = microform.field('expirationMonth', { placeholder: 'MM' });
                    yearField = microform.field('expirationYear', { placeholder: 'YY' });
                    cvvField = microform.field('securityCode', { placeholder: '123' });
                }
                
                // Load fields into DOM containers
                numberField.load('#number-field');
                monthField.load('#month-field');
                yearField.load('#year-field');
                cvvField.load('#cvv-field');
                
                updateStatus('✅ Payment form ready!', 'success');
                document.getElementById('payment-form').style.display = 'block';
                document.getElementById('status').style.display = 'none';
                
            } catch (error) {
                console.error('Microform initialization error:', error);
                showError('Failed to initialize payment form: ' + error.message);
            }
        }
        
        // Form submission handler
        document.addEventListener('DOMContentLoaded', function() {
            const form = document.getElementById('payment-form');
            form.addEventListener('submit', function(e) {
                e.preventDefault();
                
                if (!microform) {
                    showError('Payment form not ready');
                    return;
                }
                
                showLoading(true);
                updateStatus('Creating secure payment token...', 'info');
                
                microform.createToken({}, function(err, token) {
                    showLoading(false);
                    
                    if (err) {
                        console.error('Token creation error:', err);
                        showError('Payment failed: ' + (err.message || 'Please check your card details'));
                        return;
                    }
                    
                    if (token) {
                        console.log('Payment token created successfully:', token);
                        updateStatus('✅ Payment token created!', 'success');
                        
                        // Send token to Flutter app
                        if (window.FlutterPayment) {
                            FlutterPayment.postMessage(JSON.stringify({
                                type: 'PAYMENT_SUCCESS',
                                token: token,
                                timestamp: new Date().toISOString()
                            }));
                        }
                        
                        if (window.PaymentChannel) {
                            PaymentChannel.postMessage(token);
                        }
                    }
                });
            });
        });
        
        // Initialize microform when ready
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', initializeMicroform);
        } else {
            setTimeout(initializeMicroform, 100);
        }
        
        // Global error handling
        window.addEventListener('error', function(e) {
            console.error('Global error:', e);
            showError('Script loading error: ' + e.message);
        });
        
    </script>
</body>
</html>
    ''';
  }

  void _handlePaymentMessage(String message) {
    try {
      debugPrint('💳 Payment message received: $message');

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment completed successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to payment processing screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => PaymentProcessingScreen(paymentToken: message),
        ),
      );
    } catch (e) {
      debugPrint('❌ Error handling payment message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _retryPayment() {
    setState(() {
      _error = null;
      isLoading = true;
    });
    _loadPaymentData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF37021),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Secure Payment',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        actions: [
          if (!isLoading && _error == null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                controller.reload();
              },
            ),
        ],
      ),
      body: ActivityTracker(
        interactionType: 'payment_mobile_screen',
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return _buildErrorState();
    }

    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFFF37021)),
            SizedBox(height: 16),
            Text('Loading secure payment form...'),
            SizedBox(height: 8),
            Text(
              'Initializing CyberSource security',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return WebViewWidget(controller: controller);
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.red.shade400),
            const SizedBox(height: 24),
            Text(
              'Payment Setup Failed',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade600,
              ),
            ),
            const SizedBox(height: 16),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Go Back'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _retryPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF37021),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Retry'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
