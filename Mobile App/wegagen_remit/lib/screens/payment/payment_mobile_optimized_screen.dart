import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'payment_processing_screen.dart';

class PaymentMobileOptimizedScreen extends StatefulWidget {
  const PaymentMobileOptimizedScreen({super.key});

  @override
  State<PaymentMobileOptimizedScreen> createState() =>
      _PaymentMobileOptimizedScreenState();
}

class _PaymentMobileOptimizedScreenState
    extends State<PaymentMobileOptimizedScreen> {
  static const String _paymentUrl = 'https://cybersource.wegagenbanksc.com.et:3001/payments/card-form';

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
      ..setBackgroundColor(const Color(0x00000000))
      ..enableZoom(false);

    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    controller
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              isLoading = true;
              _error = null;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _error = 'Failed to load payment page: ${error.description}';
              isLoading = false;
            });
          },
        ),
      )
      // Token channels
      ..addJavaScriptChannel(
        'TokenChannel',
        onMessageReceived: (JavaScriptMessage message) {
          final token = _extractTransientToken(message.message);
          if (token != null) {
            _handleTokenReceived(token);
          }
        },
      )
      ..addJavaScriptChannel(
        'FlutterPayment',
        onMessageReceived: (JavaScriptMessage message) {
          final token = _extractTransientToken(message.message);
          if (token != null) {
            _handleTokenReceived(token);
          }
        },
      )
      ..addJavaScriptChannel(
        'PaymentChannel',
        onMessageReceived: (JavaScriptMessage message) {
          final token = _extractTransientToken(message.message);
          if (token != null) {
            _handleTokenReceived(token);
          }
        },
      )
      ..loadRequest(Uri.parse(_paymentUrl));
  }

  String? _extractTransientToken(String message) {
    // Some pages may post a raw token, others may post JSON containing the token.
    try {
      final trimmed = message.trim();
      if (trimmed.isEmpty) return null;

      if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
        final jsonData = jsonDecode(trimmed) as Map<String, dynamic>;
        if (jsonData.containsKey('token')) {
          return jsonData['token'] as String?;
        }
        if (jsonData.containsKey('paymentToken')) {
          return jsonData['paymentToken'] as String?;
        }
      }

      return trimmed;
    } catch (_) {
      return message;
    }
  }

  Future<void> _handleTokenReceived(String token) async {
    debugPrint('💳 Received transient token from WebView: $token');

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment token received. Processing payment...'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => PaymentProcessingScreen(paymentToken: token),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF37021),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Secure Payment'),
      ),
      body: _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(_error!, textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        setState(() => _error = null);
                        controller.reload();
                      },
                      child: const Text('Retry Payment'),
                    ),
                  ],
                ),
              ),
            )
          : Stack(
              children: [
                WebViewWidget(controller: controller),
                if (isLoading)
                  Container(
                    color: Colors.white,
                    child: const Center(
                      child: CircularProgressIndicator(color: Color(0xFFF37021)),
                    ),
                  ),
              ],
            ),
    );
  }
}