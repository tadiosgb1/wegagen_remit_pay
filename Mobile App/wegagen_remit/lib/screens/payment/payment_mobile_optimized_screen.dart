import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import '../../providers/payment_providers.dart';
import 'payment_processing_screen.dart';

class PaymentMobileOptimizedScreen extends ConsumerStatefulWidget {
  final String? transferType; // Add transferType parameter
  final Map<String, dynamic>? recipientData; // Add recipient data parameter

  const PaymentMobileOptimizedScreen({
    super.key,
    this.transferType,
    this.recipientData,
  });

  @override
  ConsumerState<PaymentMobileOptimizedScreen> createState() =>
      _PaymentMobileOptimizedScreenState();
}

class _PaymentMobileOptimizedScreenState
    extends ConsumerState<PaymentMobileOptimizedScreen> {
  static const String _paymentUrl =
      'https://cybersource.wegagenbanksc.com.et:3001/payments/card-form';

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

  Map<String, dynamic> _formatRecipientInfo(
      Map<String, dynamic> recipientData) {
    // For cash pickup, format the recipient information properly
    if (widget.transferType == 'cash_pickup') {
      final firstName = recipientData['first_name'] ?? '';
      final middleName = recipientData['middle_name'] ?? '';
      final lastName = recipientData['last_name'] ?? '';
      final fullName = '$firstName $middleName $lastName'.trim();
      final phoneNumber = recipientData['phone_number'] ?? '';

      return {
        'account_holder':
            fullName.isNotEmpty ? fullName : 'Cash Pickup Recipient',
        'account_number': phoneNumber.isNotEmpty ? phoneNumber : 'Cash Pickup',
        'full_name': fullName,
        'phone_number': phoneNumber,
        'first_name': firstName,
        'middle_name': middleName,
        'last_name': lastName,
        'city': recipientData['city'] ?? '',
        'country': recipientData['country'] ?? 'ET',
        'address': recipientData['address'] ?? '',
      };
    }

    // For other transfer types, return as-is
    return recipientData;
  }

  Future<void> _handleTokenReceived(String token) async {
    debugPrint('💳 Received transient token from WebView: $token');

    if (!mounted) return;

    if (kDebugMode) {
      print('🚀 === TOKEN RECEIVED - STARTING NAVIGATION ===');
      print('💳 Token: ${token.substring(0, 30)}...');
      print('📱 About to navigate to PaymentProcessingScreen...');
      print(
          '🔥 DEBUG: PaymentMobileOptimizedScreen received transferType: ${widget.transferType}');
      print(
          '🔥 DEBUG: PaymentMobileOptimizedScreen received recipientData: ${widget.recipientData}');
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment token received. Processing with 3D Secure...'),
        backgroundColor: Colors.green,
      ),
    );

    // Get payment data from provider - this should now include your $20 amount
    final formData = ref.read(paymentFormProvider);

    if (kDebugMode) {
      print('💰 Form Data Retrieved:');
      print('   💵 Amount: ${formData.amount} ${formData.currency}');
      print('   👤 Billing: ${formData.firstName} ${formData.lastName}');
      print('   📧 Email: ${formData.email}');
      print('   📱 Recipient: ${formData.toAccountHolder}');
    }

    debugPrint(
        '💰 Amount from form provider: ${formData.amount} ${formData.currency}');
    debugPrint('👤 Billing info: ${formData.firstName} ${formData.lastName}');

    if (kDebugMode) {
      print('🎯 Creating PaymentProcessingScreen...');
    }

    // Navigate to payment processing screen which handles 3DS
    if (kDebugMode) {
      print('🚀 === NAVIGATING TO PAYMENT PROCESSING SCREEN ===');
      print('📱 Passing transferType: ${widget.transferType}');
      print('💳 Passing paymentToken: ${token.substring(0, 20)}...');
      print('💰 Passing amount: ${formData.amount}');
      print('💱 Passing currency: ${formData.currency}');
      print('👤 Passing recipientInfo: ${widget.recipientData ?? {
            'account_holder': formData.toAccountHolder,
            'account_number': formData.toAccount
          }}');
      print('🚀 === NAVIGATION START ===');
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => PaymentProcessingScreen(
          paymentToken: token,
          amount: formData.amount,
          currency: formData.currency,
          billingInfo: {
            'first_name': formData.firstName,
            'last_name': formData.lastName,
            'email': formData.email,
            'address1': formData.address1,
            'locality': formData.locality,
            'administrative_area': formData.administrativeArea,
            'postal_code': formData.postalCode,
            'country': formData.country,
            'phone_number': '', // Add if you have phone in form
          },
          recipientInfo: widget.recipientData != null
              ? _formatRecipientInfo(widget.recipientData!)
              : {
                  'account_holder': formData.toAccountHolder,
                  'account_number': formData.toAccount,
                },
          remark: formData.remark,
          transferType: widget.transferType, // ✅ Pass transfer type here!
        ),
      ),
    );

    if (kDebugMode) {
      print('✅ Navigation to PaymentProcessingScreen initiated!');
      print('🚀 === TOKEN NAVIGATION COMPLETE ===\n');
    }
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
                    const Icon(Icons.error_outline,
                        size: 64, color: Colors.red),
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
                      child:
                          CircularProgressIndicator(color: Color(0xFFF37021)),
                    ),
                  ),
              ],
            ),
    );
  }
}
