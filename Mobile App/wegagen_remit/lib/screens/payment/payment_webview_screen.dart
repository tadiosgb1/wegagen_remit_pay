import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/url_container.dart';
import '../../widgets/activity_tracker.dart';
import 'payment_processing_screen.dart';

class PaymentWebViewScreen extends StatefulWidget {
  const PaymentWebViewScreen({super.key});

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
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
                _error = 'Failed to load payment page: ${error.description}';
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
          debugPrint('WebView Log: ${message.message}');
        },
      );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPaymentPage();
    });
  }

Future<void> _loadPaymentPage() async {
  final prefs = await SharedPreferences.getInstance();
  final authToken = prefs.getString('auth_token');

  if (authToken == null || authToken.isEmpty) {
    if (mounted) {
      setState(() {
        _error = 'Authentication required. Please log in first.';
        _isLoading = false;
      });
    }
    return;
  }

  try {
    final paymentUrl =
        '${UrlContainer.paymentSession}?token=$authToken'; // Updated to use new payment session endpoint

    await _controller.loadRequest(
      Uri.parse(paymentUrl),
    );
  } catch (e) {
    if (mounted) {
      setState(() {
        _error = 'Failed to load payment page: $e';
        _isLoading = false;
      });
    }
  }
}

  void _handlePaymentToken(String tokenJson) {
    try {
      final token = tokenJson.trim();
      if (token.isNotEmpty) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => PaymentProcessingScreen(paymentToken: token),
          ),
        );
      } else {
        _showError('Invalid payment token received.');
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
        child: _error != null
            ? _buildErrorState(_error!)
            : _buildWebView(),
      ),
    );
  }

  Widget _buildWebView() {
    return Stack(
      children: [
        WebViewWidget(controller: _controller),
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
                    'Loading secure payment page...',
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

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
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
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF37021),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Go Back'),
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
                Navigator.of(context).pop();
                Navigator.of(context).pop();
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
