import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../providers/payment_providers.dart';
import '../../utils/cybersource_webview_html.dart';
import '../../widgets/activity_tracker.dart';
import 'payment_processing_screen.dart';

class PaymentWebViewScreen extends ConsumerStatefulWidget {
  const PaymentWebViewScreen({super.key});

  @override
  ConsumerState<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends ConsumerState<PaymentWebViewScreen> {
  WebViewController? _controller;
  bool _isLoading = true;
  String? _error;
  bool _isWebViewInitialized = false;

  @override
  void initState() {
    super.initState();
    // Initialize WebView after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeWebView();
    });
  }

  void _initializeWebView() {
    try {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.white)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              if (mounted) {
                setState(() {
                  _isLoading = true;
                });
              }
            },
            onPageFinished: (String url) {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });
              }
            },
            onWebResourceError: (WebResourceError error) {
              if (mounted) {
                setState(() {
                  _error = 'Failed to load payment form: ${error.description}';
                  _isLoading = false;
                });
              }
            },
          ),
        )
        ..addJavaScriptChannel(
          'paymentToken',
          onMessageReceived: (JavaScriptMessage message) {
            _handlePaymentToken(message.message);
          },
        )
        ..addJavaScriptChannel(
          'FlutterLog',
          onMessageReceived: (JavaScriptMessage message) {
            print('WebView Log: ${message.message}');
          },
        );

      setState(() {
        _isWebViewInitialized = true;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to initialize WebView: $e';
        _isLoading = false;
      });
    }
  }

  void _handlePaymentToken(String tokenJson) {
    try {
      final tokenData = jsonDecode(tokenJson);
      final paymentToken = tokenData['token'] ?? tokenData;
      
      if (paymentToken != null && paymentToken.toString().isNotEmpty) {
        // Navigate to processing screen with the token
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => PaymentProcessingScreen(
              paymentToken: paymentToken.toString(),
            ),
          ),
        );
      } else {
        _showError('Invalid payment token received');
      }
    } catch (e) {
      _showError('Failed to process payment token: $e');
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final captureContextAsync = ref.watch(captureContextProvider);
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Secure Payment'),
        backgroundColor: const Color(0xFFF37021),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _showExitConfirmation(),
        ),
      ),
      body: ActivityTracker(
        interactionType: 'payment_webview_screen',
        child: captureContextAsync.when(
          data: (captureContext) => _buildWebView(captureContext.data.captureContext),
          loading: () => _buildLoadingState(),
          error: (error, stack) => _buildErrorState(error.toString()),
        ),
      ),
    );
  }

  Widget _buildWebView(String captureContext) {
    if (_error != null) {
      return _buildErrorState(_error!);
    }

    if (!_isWebViewInitialized || _controller == null) {
      return _buildLoadingState();
    }

    return Stack(
      children: [
        WebViewWidget(
          controller: _controller!
            ..loadHtmlString(
              CyberSourceWebViewHTML.generateHTML(captureContext),
            ),
        ),
        if (_isLoading)
          Container(
            color: Colors.white,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Color(0xFFF37021),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading secure payment form...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Color(0xFFF37021),
          ),
          SizedBox(height: 16),
          Text(
            'Preparing secure payment...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'This may take a few moments',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height - 200,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red.shade400,
            ),
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
            Text(
              error,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Go Back'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _error = null;
                        _isLoading = true;
                      });
                      ref.invalidate(captureContextProvider);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF37021),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
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

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancel Payment?'),
          content: const Text(
            'Are you sure you want to cancel this payment? Your progress will be lost.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Continue Payment'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to payment form
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Cancel Payment'),
            ),
          ],
        );
      },
    );
  }
}