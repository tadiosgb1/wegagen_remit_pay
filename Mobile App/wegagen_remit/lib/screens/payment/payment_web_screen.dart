import 'dart:convert';
import 'dart:html' as html if (dart.library.html) 'dart:async' as html;
import 'dart:ui_web' as ui_web if (dart.library.ui_web) 'dart:async' as ui_web;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/payment_providers.dart';
import '../../widgets/activity_tracker.dart';
import 'payment_processing_screen.dart';

class PaymentWebScreen extends ConsumerStatefulWidget {
  const PaymentWebScreen({super.key});

  @override
  ConsumerState<PaymentWebScreen> createState() => _PaymentWebScreenState();
}

class _PaymentWebScreenState extends ConsumerState<PaymentWebScreen> {
  bool _isLoading = true;
  String? _error;
  String? _captureContext;
  final String _iframeId = 'payment-iframe';

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _initializeWebPayment();
    } else {
      setState(() {
        _error = 'This screen is only available on web platform';
        _isLoading = false;
      });
    }
  }

  void _initializeWebPayment() async {
    try {
      final captureContextAsync = ref.read(captureContextProvider);
      
      captureContextAsync.when(
        data: (response) {
          setState(() {
            _captureContext = response.data.captureContext;
          });
          _setupPaymentIframe();
        },
        loading: () {
          // Keep loading state
        },
        error: (error, stack) {
          setState(() {
            _error = 'Failed to get payment configuration: $error';
            _isLoading = false;
          });
        },
      );
    } catch (e) {
      setState(() {
        _error = 'Failed to initialize payment: $e';
        _isLoading = false;
      });
    }
  }

  void _setupPaymentIframe() {
    if (_captureContext == null) return;

    // Create the HTML content for the iframe
    final htmlContent = '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Secure Payment</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background-color: #f5f5f5;
            padding: 20px;
            margin: 0;
        }
        
        .container {
            max-width: 400px;
            margin: 0 auto;
            background: white;
            border-radius: 12px;
            padding: 24px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        
        .header {
            text-align: center;
            margin-bottom: 24px;
        }
        
        .header h2 {
            color: #333;
            margin-bottom: 8px;
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 8px;
            color: #333;
            font-weight: 500;
        }
        
        .microform-field {
            width: 100%;
            padding: 12px;
            border: 2px solid #e1e1e1;
            border-radius: 8px;
            font-size: 16px;
            min-height: 48px;
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
        }
        
        .pay-button:hover {
            background: #e5631e;
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
        
        <div id="error-message" class="error"></div>
        
        <form id="payment-form">
            <div class="form-group">
                <label>Card Number</label>
                <div id="cardNumber-container" class="microform-field"></div>
            </div>
            
            <div class="card-row">
                <div class="form-group">
                    <label>Month</label>
                    <div id="expirationMonth-container" class="microform-field"></div>
                </div>
                
                <div class="form-group">
                    <label>Year</label>
                    <div id="expirationYear-container" class="microform-field"></div>
                </div>
                
                <div class="form-group">
                    <label>CVV</label>
                    <div id="securityCode-container" class="microform-field"></div>
                </div>
            </div>
            
            <button type="submit" class="pay-button">
                Secure Payment
            </button>
        </form>
        
        <div id="loading" class="loading">
            <p>Processing payment...</p>
        </div>
    </div>

    <script src="https://testflex.cybersource.com/microform/bundle/v2.9.0/flex-microform.min.js"></script>
    <script>
        const captureContext = ${jsonEncode(_captureContext)};
        let flex, microform;
        
        function init() {
            try {
                console.log('Initializing Flex...');
                
                if (typeof Flex === 'undefined') {
                    throw new Error('Flex library not loaded');
                }
                
                flex = new Flex(captureContext);
                microform = flex.microform('card', {
                    styles: {
                        'input': {
                            'font-size': '16px',
                            'color': '#333',
                            'padding': '12px',
                            'border': 'none'
                        }
                    }
                });
                
                let numberField = null;
                let monthField = null;
                let yearField = null;
                let cvvField = null;

                try {
                    numberField = microform.createField('number', { placeholder: '1234 5678 9012 3456' });
                    monthField = microform.createField('expirationMonth', { placeholder: 'MM' });
                    yearField = microform.createField('expirationYear', { placeholder: 'YY' });
                    cvvField = microform.createField('securityCode', { placeholder: '123' });
                } catch (createFieldError) {
                    console.log('createField failed, fallback to field():', createFieldError);
                    numberField = microform.field('number', { placeholder: '1234 5678 9012 3456' });
                    monthField = microform.field('expirationMonth', { placeholder: 'MM' });
                    yearField = microform.field('expirationYear', { placeholder: 'YY' });
                    cvvField = microform.field('securityCode', { placeholder: '123' });
                }

                numberField.load('#cardNumber-container');
                monthField.load('#expirationMonth-container');
                yearField.load('#expirationYear-container');
                cvvField.load('#securityCode-container');
                
                console.log('Flex initialized successfully');
                
            } catch (error) {
                console.error('Flex init error:', error);
                showError('Failed to load payment form: ' + error.message);
            }
        }
        
        document.getElementById('payment-form').addEventListener('submit', function(e) {
            e.preventDefault();
            
            if (!microform) {
                showError('Payment form not ready');
                return;
            }
            
            showLoading(true);
            
            microform.createToken({}, function(err, token) {
                showLoading(false);
                
                if (err) {
                    showError('Payment failed: ' + (err.message || 'Please check your card details'));
                    return;
                }
                
                if (token) {
                    console.log('Token created:', token);
                    window.parent.postMessage({
                        type: 'PAYMENT_TOKEN',
                        token: token
                    }, '*');
                }
            });
        });
        
        function showError(message) {
            const errorDiv = document.getElementById('error-message');
            errorDiv.textContent = message;
            errorDiv.classList.add('show');
        }
        
        function showLoading(show) {
            const loading = document.getElementById('loading');
            const form = document.getElementById('payment-form');
            
            if (show) {
                loading.classList.add('show');
                form.style.display = 'none';
            } else {
                loading.classList.remove('show');
                form.style.display = 'block';
            }
        }
        
        // Initialize when ready
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', init);
        } else {
            setTimeout(init, 1000);
        }
    </script>
</body>
</html>
    ''';

    // Create iframe using a blob URL to preserve same-origin context
    final iframe = html.IFrameElement()
      ..style.width = '100%'
      ..style.height = '600px'
      ..style.border = 'none'
      ..src = '/cybersource_payment_frame.html';

    iframe.onLoad.listen((_) {
      iframe.contentWindow?.postMessage(
        {
          'type': 'captureContext',
          'captureContext': _captureContext,
        },
        html.window.location.origin ?? '*',
      );
    });

    // Register view
    ui_web.platformViewRegistry.registerViewFactory(
      _iframeId,
      (int viewId) => iframe,
    );

    // Listen for messages
    html.window.addEventListener('message', (event) {
      final messageEvent = event as html.MessageEvent;
      if (messageEvent.data is Map) {
        final data = messageEvent.data as Map;
        if (data['type'] == 'PAYMENT_TOKEN') {
          _handlePaymentToken(data['token'].toString());
        }
      }
    });

    setState(() {
      _isLoading = false;
    });
  }

  void _handlePaymentToken(String token) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => PaymentProcessingScreen(paymentToken: token),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Secure Payment'),
        backgroundColor: const Color(0xFFF37021),
        foregroundColor: Colors.white,
      ),
      body: ActivityTracker(
        interactionType: 'payment_web_screen',
        child: _buildBody(),
      ),
    );
  }

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
            Text('Loading secure payment form...'),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        height: 600,
        child: kIsWeb
            ? HtmlElementView(viewType: _iframeId)
            : const Center(child: Text('Web payment not available')),
      ),
    );
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
                    onPressed: () {
                      setState(() {
                        _error = null;
                        _isLoading = true;
                      });
                      _initializeWebPayment();
                    },
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