import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import '../../providers/payment_providers.dart';
import '../../config/url_container.dart';

class PaymentMobileOptimizedScreen extends ConsumerStatefulWidget {
  final String? captureContext;

  const PaymentMobileOptimizedScreen({super.key, this.captureContext});

  @override
  ConsumerState<PaymentMobileOptimizedScreen> createState() =>
      _PaymentMobileOptimizedScreenState();
}

class _PaymentMobileOptimizedScreenState
    extends ConsumerState<PaymentMobileOptimizedScreen> {
  late WebViewController controller;
  bool isLoading = true;
  String? _error;

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
      ..setBackgroundColor(const Color(0x00000000));

    // Configure Android-specific settings for Cybersource
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
            setState(() {
              isLoading = true;
            });
          },
          onPageFinished: (String url) {
            debugPrint('✅ Page finished loading: $url');
            setState(() {
              isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('❌ WebView error: ${error.description}');
            debugPrint('❌ Error type: ${error.errorType}');
            debugPrint('❌ Error code: ${error.errorCode}');

            // Handle SSL certificate errors for development
            if (error.errorCode == -202 ||
                error.description.contains('SSL') ||
                error.description.contains('certificate')) {
              debugPrint(
                '🔒 SSL Certificate issue detected - this is expected with self-signed certificates',
              );
              setState(() {
                _error =
                    'SSL Certificate Error: Your backend is using self-signed certificates.\n\nFor development, this can be ignored, but you may need to:\n1. Use HTTP instead of HTTPS\n2. Add proper SSL certificates\n3. Configure certificate trust';
                isLoading = false;
              });
            } else {
              setState(() {
                _error =
                    'Failed to load payment page: ${error.description}\n\nPlease check:\n• Internet connection\n• Backend server status\n• SSL certificate configuration';
                isLoading = false;
              });
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            debugPrint('🔗 Navigation request: ${request.url}');

            // Allow all Cybersource domains
            if (request.url.contains('cybersource.com') ||
                request.url.contains('testflex.cybersource.com') ||
                request.url.contains('flex.cybersource.com')) {
              return NavigationDecision.navigate;
            }

            // Allow your backend domains
            if (request.url.contains('10.195.49.18') ||
                request.url.contains('localhost') ||
                request.url.startsWith('https://')) {
              return NavigationDecision.navigate;
            }

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

    // Load the local HTML file with proper Cybersource configuration
    _loadPaymentPage();
  }

  void _loadPaymentPage() {
    // Load the assets HTML file that has proper Cybersource configuration
    const htmlContent = '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <meta http-equiv="Content-Security-Policy" content="default-src * 'unsafe-inline' 'unsafe-eval' data: blob:; script-src * 'unsafe-inline' 'unsafe-eval'; frame-src *; child-src *; connect-src *;">
    <title>Secure Payment</title>
    <style>
        body { margin:0; padding:16px; background:#f8f9fa; font-family:system-ui; }
        .container { background:white; border-radius:16px; padding:24px; box-shadow:0 4px 20px rgba(0,0,0,0.1); }
        h2 { text-align:center; margin-bottom:8px; color:#1f2937; }
        label { display:block; margin:12px 0 6px; font-weight:600; color:#374151; }
        .microform-field { 
            width:100% !important; 
            height:58px !important; 
            border:2px solid #e5e7eb; 
            border-radius:10px; 
            margin-bottom:8px;
            box-sizing: border-box;
            background: white;
        }
        .pay-button { width:100%; background:#F37021; color:white; border:none; padding:16px; border-radius:12px; font-size:17px; margin-top:20px; cursor:pointer; }
        .pay-button:disabled { background:#ccc; cursor:not-allowed; }
        #status { text-align:center; margin:20px 0; color:#666; font-size:15px; }
        .error { color:red; text-align:center; margin:10px 0; display:none; }
        .row { display:flex; gap:12px; }
        .col { flex:1; }
        select { width:100%; padding:14px; border:2px solid #e5e7eb; border-radius:8px; background:white; }
    </style>
</head>
<body>
    <div class="container">
        <h2>🔒 Secure Payment</h2>
        <div id="status">Initializing secure payment form...</div>
        <div id="error" class="error"></div>

        <form id="payment-form" style="display:none;">
            <label for="number-container">Card Number *</label>
            <div id="number-container" class="microform-field"></div>

            <div class="row">
                <div class="col">
                    <label for="expMonth">Expiry Month *</label>
                    <select id="expMonth" required></select>
                </div>
                <div class="col">
                    <label for="expYear">Expiry Year *</label>
                    <select id="expYear" required></select>
                </div>
                <div class="col">
                    <label for="cvv-container">CVV *</label>
                    <div id="cvv-container" class="microform-field"></div>
                </div>
            </div>

            <button type="submit" id="payButton" class="pay-button">Pay Securely</button>
        </form>
    </div>

    <script src="https://testflex.cybersource.com/microform/bundle/v2.0/flex-microform.min.js"></script>
    <script>
        function log(msg) {
            console.log(msg);
            if (window.ConsoleChannel) {
                window.ConsoleChannel.postMessage(String(msg));
            }
        }

        let flexInstance = null;
        let microformInstance = null;

        // Initialize immediately with test capture context for now
        // In production, this should come from your backend
        initializePayment();

        async function initializePayment() {
            try {
                // Get capture context from your backend
                const response = await fetch('http://10.195.49.21:3001/payments/session');
                const data = await response.json();
                
                if (data.captureContext) {
                    initFlex(data.captureContext);
                } else {
                    throw new Error('No capture context received from backend');
                }
            } catch (error) {
                log('❌ Failed to get capture context: ' + error.message);
                document.getElementById('error').textContent = 'Failed to initialize payment. Please check your connection.';
                document.getElementById('error').style.display = 'block';
                document.getElementById('status').style.display = 'none';
            }
        }

        function initFlex(captureContext) {
            log('🔄 Starting Flex initialization...');
            
            try {
                // Create Flex instance
                flexInstance = new Flex(captureContext);
                
                // Create microform instance
                microformInstance = flexInstance.microform();

                // Create and load fields
                const numberField = microformInstance.createField('number', {
                    placeholder: '•••• •••• •••• ••••'
                });
                
                const cvvField = microformInstance.createField('securityCode', {
                    placeholder: '•••'
                });

                // Load fields into containers
                numberField.load('#number-container');
                cvvField.load('#cvv-container');

                // Populate expiration dropdowns
                populateExpiration();

                // Show form and hide status
                document.getElementById('status').style.display = 'none';
                document.getElementById('payment-form').style.display = 'block';
                
                log('✅ Cybersource Flex initialized successfully');

            } catch (error) {
                log('❌ Flex initialization error: ' + error.message);
                document.getElementById('error').textContent = 'Failed to load secure payment fields: ' + error.message;
                document.getElementById('error').style.display = 'block';
                document.getElementById('status').style.display = 'none';
            }
        }

        function populateExpiration() {
            const monthSelect = document.getElementById('expMonth');
            const yearSelect = document.getElementById('expYear');
            
            // Add placeholder options
            monthSelect.add(new Option('Month', '', true, true));
            yearSelect.add(new Option('Year', '', true, true));
            
            // Add months 01-12
            for (let i = 1; i <= 12; i++) {
                const monthStr = i.toString().padStart(2, '0');
                monthSelect.add(new Option(monthStr, monthStr));
            }
            
            // Add years (current year + 15 years)
            const currentYear = new Date().getFullYear();
            for (let i = 0; i < 15; i++) {
                const year = (currentYear + i).toString();
                yearSelect.add(new Option(year, year));
            }
        }

        document.getElementById('payment-form').addEventListener('submit', function(e) {
            e.preventDefault();
            
            if (!microformInstance) {
                log('❌ Microform not initialized');
                return;
            }
            
            const btn = document.getElementById('payButton');
            const month = document.getElementById('expMonth').value;
            const year = document.getElementById('expYear').value;

            if (!month || !year) {
                document.getElementById('error').textContent = 'Please select expiry month and year';
                document.getElementById('error').style.display = 'block';
                return;
            }

            btn.disabled = true;
            btn.textContent = 'Processing...';
            document.getElementById('error').style.display = 'none';

            log('🔄 Creating payment token...');

            microformInstance.createToken({
                expirationMonth: month,
                expirationYear: year
            }, function(err, token) {
                btn.disabled = false;
                btn.textContent = 'Pay Securely';
                
                if (err) {
                    log('❌ Token creation error: ' + JSON.stringify(err));
                    document.getElementById('error').textContent = 'Payment error: ' + (err.message || 'Invalid card details');
                    document.getElementById('error').style.display = 'block';
                } else if (token) {
                    log('✅ Payment token created successfully');
                    
                    // Send token back to Flutter
                    const paymentData = {
                        type: 'PAYMENT_SUCCESS',
                        token: token,
                        timestamp: new Date().toISOString()
                    };
                    
                    if (window.FlutterPayment) {
                        window.FlutterPayment.postMessage(JSON.stringify(paymentData));
                    }
                    
                    if (window.PaymentChannel) {
                        window.PaymentChannel.postMessage(JSON.stringify(paymentData));
                    }
                }
            });
        });

        // Handle errors
        window.addEventListener('error', function(e) {
            log('❌ JavaScript error: ' + e.message);
        });

        // Handle unhandled promise rejections
        window.addEventListener('unhandledrejection', function(e) {
            log('❌ Unhandled promise rejection: ' + e.reason);
        });
    </script>
</body>
</html>
    ''';

    controller.loadHtmlString(htmlContent);
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

      // Navigate back with the payment result
      Navigator.of(context).pop(message);
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
    _loadPaymentPage();
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
      body: _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Payment Error',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _error!,
                      style: const TextStyle(color: Colors.black87),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _retryPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF37021),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                      child: const Text('Retry Payment'),
                    ),
                  ],
                ),
              ),
            )
          : Stack(
              children: [
                // WebView displays the payment form
                WebViewWidget(controller: controller),

                // Loading overlay
                if (isLoading)
                  Container(
                    color: Colors.white,
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Color(0xFFF37021)),
                          SizedBox(height: 24),
                          Text(
                            'Loading secure payment page...',
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Initializing Cybersource security',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
