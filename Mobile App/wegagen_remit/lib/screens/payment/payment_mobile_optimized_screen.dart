import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

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

            // Allow your backend domains including nginx
            if (request.url.contains('10.195.49.18') ||
                request.url.contains('10.195.49.21') ||
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
    // Load the backend payment session page directly from nginx
    const paymentSessionUrl = 'http://10.195.49.21/payments/session';

    debugPrint('🔄 Loading payment session from: $paymentSessionUrl');

    // Set additional headers for better compatibility
    controller.setUserAgent(
        'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36 FlutterWebView');

    // Load the payment session URL directly
    controller.loadRequest(
      Uri.parse(paymentSessionUrl),
      headers: {
        'Accept':
            'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        'Accept-Language': 'en-US,en;q=0.5',
        'Accept-Encoding': 'gzip, deflate',
        'Cache-Control': 'no-cache',
        'Pragma': 'no-cache',
      },
    );
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
