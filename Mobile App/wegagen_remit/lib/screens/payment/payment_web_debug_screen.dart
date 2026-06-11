import 'dart:convert';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/foundation.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/payment_providers.dart';
import '../../widgets/activity_tracker.dart';
import 'payment_processing_screen.dart';

class PaymentWebDebugScreen extends ConsumerStatefulWidget {
  const PaymentWebDebugScreen({super.key});

  @override
  ConsumerState<PaymentWebDebugScreen> createState() => _PaymentWebDebugScreenState();
}

class _PaymentWebDebugScreenState extends ConsumerState<PaymentWebDebugScreen> {
  bool _isLoading = true;
  String? _error;
  String? _captureContext;
  final String _iframeId = 'payment-debug-iframe';

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
          print('Got capture context response: ${response.data.captureContext.substring(0, 50)}...');
          setState(() {
            _captureContext = response.data.captureContext;
          });
          _setupPaymentIframe();
        },
        loading: () {
          print('Still loading capture context...');
        },
        error: (error, stack) {
          print('Capture context error: $error');
          setState(() {
            _error = 'Failed to get payment configuration: $error';
            _isLoading = false;
          });
        },
      );
    } catch (e) {
      print('Exception in _initializeWebPayment: $e');
      setState(() {
        _error = 'Failed to initialize payment: $e';
        _isLoading = false;
      });
    }
  }

  void _setupPaymentIframe() {
    if (_captureContext == null) {
      print('ERROR: No capture context available');
      return;
    }

    print('Setting up iframe with capture context length: ${_captureContext!.length}');

    // Create simple HTML for debugging - ensure it runs from localhost:3000 origin
    final htmlContent = '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Payment Debug</title>
    <base href="http://localhost:3000/">
    <style>
        body { 
            font-family: Arial, sans-serif; 
            padding: 20px; 
            background: #f5f5f5;
        }
        .container { 
            max-width: 500px; 
            margin: 0 auto; 
            background: white; 
            padding: 20px; 
            border-radius: 8px;
        }
        .debug { 
            background: #f0f0f0; 
            padding: 10px; 
            margin: 10px 0; 
            border-radius: 4px; 
            font-size: 12px; 
            font-family: monospace;
            white-space: pre-wrap;
            max-height: 200px;
            overflow-y: auto;
        }
        .field { 
            margin: 15px 0; 
            padding: 10px; 
            border: 2px solid #ddd; 
            border-radius: 4px; 
            min-height: 40px;
        }
        .button { 
            background: #F37021; 
            color: white; 
            border: none; 
            padding: 15px 30px; 
            border-radius: 4px; 
            cursor: pointer; 
            width: 100%;
        }
        .error { 
            background: #fee; 
            color: #c33; 
            padding: 10px; 
            border-radius: 4px; 
            margin: 10px 0;
        }
        .success {
            background: #efe;
            color: #363;
            padding: 10px;
            border-radius: 4px;
            margin: 10px 0;
        }
    </style>
</head>
<body>
    <div class="container">
        <h2>Payment Debug Screen</h2>
        
        <div class="debug" id="debug-log">
Starting payment initialization...
Origin: \${window.location.origin}
Capture context length: ${_captureContext!.length}
        </div>
        
        <div id="error-container"></div>
        <div id="success-container"></div>
        
        <div id="payment-form">
            <h3>Card Details</h3>
            <div>Card Number:</div>
            <div id="cardNumber-container" class="field"></div>
            
            <div style="display: flex; gap: 10px;">
                <div style="flex: 1;">
                    <div>Month:</div>
                    <div id="expirationMonth-container" class="field"></div>
                </div>
                <div style="flex: 1;">
                    <div>Year:</div>
                    <div id="expirationYear-container" class="field"></div>
                </div>
                <div style="flex: 1;">
                    <div>CVV:</div>
                    <div id="securityCode-container" class="field"></div>
                </div>
            </div>
            
            <button id="pay-button" class="button">Pay Now</button>
        </div>
    </div>

    <script>
        const debugLog = document.getElementById('debug-log');
        const errorContainer = document.getElementById('error-container');
        const successContainer = document.getElementById('success-container');
        
        function log(message) {
            console.log(message);
            debugLog.textContent += '\\n' + new Date().toLocaleTimeString() + ': ' + message;
            debugLog.scrollTop = debugLog.scrollHeight;
        }
        
        function showError(message) {
            errorContainer.innerHTML = '<div class="error">' + message + '</div>';
            log('ERROR: ' + message);
        }
        
        function showSuccess(message) {
            successContainer.innerHTML = '<div class="success">' + message + '</div>';
            log('SUCCESS: ' + message);
        }
        
        // Log initial information
        log('Window origin: ' + window.location.origin);
        log('Document domain: ' + document.domain);
        log('Protocol: ' + window.location.protocol);
        
        log('Loading CyberSource script...');
        
        // Load script
        const script = document.createElement('script');
        script.src = 'https://testflex.cybersource.com/microform/bundle/v2.9.0/flex-microform.min.js';
        script.crossOrigin = 'anonymous';
        
        script.onload = function() {
            log('CyberSource script loaded successfully');
            log('Flex available: ' + (typeof Flex !== 'undefined'));
            setTimeout(initFlex, 1000);
        };
        
        script.onerror = function(e) {
            showError('Failed to load CyberSource script: ' + e.message);
        };
        
        document.head.appendChild(script);
        
        const captureContext = ${jsonEncode(_captureContext)};
        let flex, microform;
        
        function initFlex() {
            try {
                log('Initializing Flex with origin: ' + window.location.origin);
                
                if (typeof Flex === 'undefined') {
                    throw new Error('Flex library not loaded');
                }
                
                log('Creating Flex instance...');
                flex = new Flex(captureContext);
                log('Flex instance created successfully');
                
                log('Creating microform...');
                microform = flex.microform('card', {
                    styles: {
                        'input': {
                            'font-size': '14px',
                            'color': '#333',
                            'padding': '8px'
                        },
                        ':focus': {
                            'border-color': '#F37021'
                        }
                    }
                });
                log('Microform created successfully');
                
                log('Loading card number field...');
                let numberField, monthField, yearField, cvvField;

                try {
                    numberField = microform.createField('number', { placeholder: '1234 5678 9012 3456' });
                    monthField = microform.createField('expirationMonth', { placeholder: 'MM' });
                    yearField = microform.createField('expirationYear', { placeholder: 'YY' });
                    cvvField = microform.createField('securityCode', { placeholder: '123' });
                    log('Using createField API');
                } catch (createFieldError) {
                    log('createField failed, trying field API: ' + createFieldError.message);
                    numberField = microform.field('number', { placeholder: '1234 5678 9012 3456' });
                    monthField = microform.field('expirationMonth', { placeholder: 'MM' });
                    yearField = microform.field('expirationYear', { placeholder: 'YY' });
                    cvvField = microform.field('securityCode', { placeholder: '123' });
                }

                numberField.load('#cardNumber-container');
                log('Card number field loaded');
                monthField.load('#expirationMonth-container');
                log('Expiry month field loaded');
                yearField.load('#expirationYear-container');
                log('Expiry year field loaded');
                cvvField.load('#securityCode-container');
                log('Security code field loaded');
                
                showSuccess('All fields initialized successfully!');
                document.getElementById('payment-form').style.display = 'block';
                
                // Add form submit handler
                document.getElementById('pay-button').addEventListener('click', function() {
                    log('Pay button clicked');
                    
                    if (!microform) {
                        showError('Microform not ready');
                        return;
                    }
                    
                    log('Creating payment token...');
                    this.disabled = true;
                    this.textContent = 'Processing...';
                    
                    microform.createToken({}, function(err, token) {
                        document.getElementById('pay-button').disabled = false;
                        document.getElementById('pay-button').textContent = 'Pay Now';
                        
                        if (err) {
                            showError('Token creation failed: ' + err.message);
                            return;
                        }
                        
                        if (token) {
                            log('Token created successfully: ' + token);
                            showSuccess('Payment token generated! Sending to Flutter...');
                            
                            // Send to Flutter
                            window.parent.postMessage({
                                type: 'PAYMENT_TOKEN',
                                token: token
                            }, '*');
                        }
                    });
                });
                
            } catch (error) {
                showError('Flex initialization failed: ' + error.message);
                log('Error details: ' + (error.stack || 'No stack trace'));
            }
        }
    </script>
</body>
</html>
    ''';

    print('Creating iframe element...');
    
    // Create iframe using a blob URL to preserve same-origin context
    final iframe = html.IFrameElement()
      ..style.width = '100%'
      ..style.height = '800px'
      ..style.border = '1px solid #ccc'
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

    print('Registering iframe view...');
    
    // Register view
    ui_web.platformViewRegistry.registerViewFactory(
      _iframeId,
      (int viewId) => iframe,
    );

    print('Setting up message listener...');
    
    // Listen for messages
    html.window.addEventListener('message', (event) {
      final messageEvent = event as html.MessageEvent;
      print('Received message from iframe: ${messageEvent.data}');
      
      if (messageEvent.data is Map) {
        final data = messageEvent.data as Map;
        if (data['type'] == 'PAYMENT_TOKEN') {
          print('Processing payment token: ${data['token']}');
          _handlePaymentToken(data['token'].toString());
        }
      }
    });

    setState(() {
      _isLoading = false;
    });
    
    print('Iframe setup complete');
  }

  void _handlePaymentToken(String token) {
    print('Navigating to processing screen with token: $token');
    
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
        title: const Text('Payment Debug'),
        backgroundColor: const Color(0xFFF37021),
        foregroundColor: Colors.white,
      ),
      body: ActivityTracker(
        interactionType: 'payment_web_debug_screen',
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
            Text('Loading payment debug screen...'),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
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
                  'Debug Information',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Capture Context Length: ${_captureContext?.length ?? 0}',
                  style: TextStyle(color: Colors.blue.shade600),
                ),
                Text(
                  'Platform: ${kIsWeb ? "Web" : "Mobile"}',
                  style: TextStyle(color: Colors.blue.shade600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SizedBox(
              width: double.infinity,
              child: kIsWeb
                  ? HtmlElementView(viewType: _iframeId)
                  : const Center(child: Text('Debug screen only available on web')),
            ),
          ),
        ],
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
              'Payment Debug Failed',
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