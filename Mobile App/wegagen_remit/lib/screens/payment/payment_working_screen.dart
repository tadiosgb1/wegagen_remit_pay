import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/payment_providers.dart';
import '../../widgets/activity_tracker.dart';
import 'payment_processing_screen.dart';

class PaymentWorkingScreen extends ConsumerStatefulWidget {
  const PaymentWorkingScreen({super.key});

  @override
  ConsumerState<PaymentWorkingScreen> createState() => _PaymentWorkingScreenState();
}

class _PaymentWorkingScreenState extends ConsumerState<PaymentWorkingScreen> {
  bool _isLoading = true;
  String? _error;
  String? _captureContext;
  final String _iframeId = 'payment-working-iframe';

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
          print('Got capture context: ${response.data.captureContext.substring(0, 50)}...');
          setState(() {
            _captureContext = response.data.captureContext;
          });
          _setupPaymentIframe();
        },
        loading: () {
          print('Loading capture context...');
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
    if (_captureContext == null) return;

    // Create HTML that will run from the correct origin
    final htmlContent = '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Secure Payment</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: #f5f5f5;
            padding: 20px;
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
            background: white;
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
            transition: background-color 0.3s;
        }
        
        .pay-button:hover:not(:disabled) {
            background: #e5631e;
        }
        
        .pay-button:disabled {
            background: #ccc;
            cursor: not-allowed;
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
        
        .status {
            background: #e8f5e8;
            color: #2d5a2d;
            padding: 8px 12px;
            border-radius: 4px;
            font-size: 12px;
            margin-bottom: 16px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h2>Secure Payment</h2>
            <p>🔒 Secured by CyberSource</p>
        </div>
        
        <div id="status" class="status">
            Initializing secure payment form...
        </div>
        
        <div id="error-message" class="error"></div>
        
        <form id="payment-form" style="display: none;">
            <div class="form-group">
                <label>Card Number</label>
                <div id="cardNumber-container" class="microform-field"></div>
            </div>
            
            <div class="card-row">
                <div class="form-group">
                    <label>Expiry Month</label>
                    <select id="expirationMonth" class="microform-field" required>
                        <option value="">MM</option>
                        <option value="01">01</option>
                        <option value="02">02</option>
                        <option value="03">03</option>
                        <option value="04">04</option>
                        <option value="05">05</option>
                        <option value="06">06</option>
                        <option value="07">07</option>
                        <option value="08">08</option>
                        <option value="09">09</option>
                        <option value="10">10</option>
                        <option value="11">11</option>
                        <option value="12">12</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <label>Expiry Year</label>
                    <select id="expirationYear" class="microform-field" required>
                        <option value="">YY</option>
                        <option value="24">24</option>
                        <option value="25">25</option>
                        <option value="26">26</option>
                        <option value="27">27</option>
                        <option value="28">28</option>
                        <option value="29">29</option>
                        <option value="30">30</option>
                        <option value="31">31</option>
                        <option value="32">32</option>
                        <option value="33">33</option>
                        <option value="34">34</option>
                    </select>
                </div>
                
                <div class="form-group">
                    <label>CVV</label>
                    <div id="securityCode-container" class="microform-field"></div>
                </div>
            </div>
            
            <button type="submit" id="pay-button" class="pay-button">
                Complete Payment
            </button>
        </form>
        
        <div id="loading" class="loading">
            <div style="display: inline-block; width: 20px; height: 20px; border: 3px solid #f3f3f3; border-top: 3px solid #F37021; border-radius: 50%; animation: spin 1s linear infinite;"></div>
            <p style="margin-top: 12px;">Processing your payment...</p>
            <p style="font-size: 14px; color: #666; margin-top: 4px;">Please do not close this window</p>
        </div>
    </div>

    <style>
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
    </style>

    <script src="https://testflex.cybersource.com/microform/bundle/v2.9.0/flex-microform.min.js"></script>
    <script>
        console.log('Payment form initializing...');
        console.log('Origin:', window.location.origin);
        console.log('Protocol:', window.location.protocol);
        
        const statusDiv = document.getElementById('status');
        const errorDiv = document.getElementById('error-message');
        const formDiv = document.getElementById('payment-form');
        const loadingDiv = document.getElementById('loading');
        
        function updateStatus(message) {
            console.log('Status:', message);
            statusDiv.textContent = message;
        }
        
        function showError(message) {
            console.error('Error:', message);
            errorDiv.textContent = message;
            errorDiv.classList.add('show');
            statusDiv.style.display = 'none';
        }
        
        function showForm() {
            statusDiv.style.display = 'none';
            formDiv.style.display = 'block';
        }
        
        function showLoading(show) {
            if (show) {
                loadingDiv.classList.add('show');
                formDiv.style.display = 'none';
            } else {
                loadingDiv.classList.remove('show');
                formDiv.style.display = 'block';
            }
        }
        
        // Wait for script to load
        function initializePayment() {
            updateStatus('Loading CyberSource library...');
            
            if (typeof Flex === 'undefined') {
                setTimeout(initializePayment, 500);
                return;
            }
            
            try {
                updateStatus('Creating secure payment form...');
                
                const captureContext = '$_captureContext';
                console.log('Capture context length:', captureContext.length);
                
                const flex = new Flex(captureContext);
                console.log('Flex instance created');
                console.log('Flex methods:', Object.getOwnPropertyNames(flex));
                
                // Try different microform initialization approaches
                let microform;
                
                // Method 1: Try with 'card' parameter (newer API)
                try {
                    microform = flex.microform('card', {
                        styles: {
                            'input': {
                                'font-size': '16px',
                                'font-family': '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif',
                                'color': '#333',
                                'padding': '12px',
                                'border': 'none',
                                'outline': 'none',
                                'width': '100%'
                            },
                            ':focus': {
                                'color': '#F37021'
                            },
                            '.valid': {
                                'color': '#28a745'
                            },
                            '.invalid': {
                                'color': '#dc3545'
                            }
                        }
                    });
                    console.log('Microform created with card parameter');
                } catch (e) {
                    console.log('Failed with card parameter, trying without:', e);
                    // Method 2: Try without 'card' parameter (older API)
                    microform = flex.microform({
                        styles: {
                            'input': {
                                'font-size': '16px',
                                'font-family': '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif',
                                'color': '#333',
                                'padding': '12px',
                                'border': 'none',
                                'outline': 'none',
                                'width': '100%'
                            },
                            ':focus': {
                                'color': '#F37021'
                            },
                            '.valid': {
                                'color': '#28a745'
                            },
                            '.invalid': {
                                'color': '#dc3545'
                            }
                        }
                    });
                    console.log('Microform created without card parameter');
                }
                
                console.log('Microform object:', microform);
                console.log('Microform methods:', Object.getOwnPropertyNames(microform));
                
                updateStatus('Loading payment fields...');
                
                // Only create microform fields for supported types: number and securityCode
                let numberField, cvvField;
                
                // Method 1: Try createField
                try {
                    numberField = microform.createField('number', { 
                        placeholder: '1234 5678 9012 3456' 
                    });
                    cvvField = microform.createField('securityCode', { 
                        placeholder: '123' 
                    });
                    console.log('Using createField method');
                } catch (e) {
                    console.log('createField failed, trying field method:', e);
                    // Method 2: Try field
                    try {
                        numberField = microform.field('number', { 
                            placeholder: '1234 5678 9012 3456' 
                        });
                        cvvField = microform.field('securityCode', { 
                            placeholder: '123' 
                        });
                        console.log('Using field method');
                    } catch (e2) {
                        console.log('field method also failed:', e2);
                        throw new Error('Unable to create microform fields with any method');
                    }
                }
                
                // Load microform fields
                numberField.load('#cardNumber-container');
                cvvField.load('#securityCode-container');
                
                console.log('All fields loaded');
                
                // Show form after a brief delay to ensure fields are ready
                setTimeout(() => {
                    showForm();
                }, 1000);
                
                // Handle form submission
                document.getElementById('payment-form').addEventListener('submit', function(e) {
                    e.preventDefault();
                    
                    console.log('Form submitted');
                    
                    // Get expiration date values
                    const expirationMonth = document.getElementById('expirationMonth').value;
                    const expirationYear = document.getElementById('expirationYear').value;
                    
                    // Validate expiration date
                    if (!expirationMonth || !expirationYear) {
                        showError('Please select both expiration month and year.');
                        return;
                    }
                    
                    console.log('Expiration date:', expirationMonth + '/' + expirationYear);
                    showLoading(true);
                    
                    // Create token with expiration date
                    const tokenData = {
                        expirationMonth: expirationMonth,
                        expirationYear: expirationYear
                    };
                    
                    microform.createToken(tokenData, function(err, token) {
                        if (err) {
                            console.error('Token creation error:', err);
                            showLoading(false);
                            showError('Payment validation failed: ' + (err.message || 'Please check your card details and try again.'));
                            return;
                        }
                        
                        if (token) {
                            console.log('Token created successfully:', token);
                            
                            // Send token to Flutter with expiration date
                            try {
                                window.parent.postMessage({
                                    type: 'PAYMENT_TOKEN',
                                    token: token,
                                    expirationMonth: expirationMonth,
                                    expirationYear: expirationYear
                                }, '*');
                                console.log('Token sent to Flutter');
                            } catch (e) {
                                console.error('Failed to send token to Flutter:', e);
                                showLoading(false);
                                showError('Payment processed but communication failed. Please try again.');
                            }
                        }
                    });
                });
                
            } catch (error) {
                console.error('Initialization error:', error);
                showError('Failed to initialize payment form: ' + error.message);
            }
        }
        
        // Start initialization
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', initializePayment);
        } else {
            initializePayment();
        }
    </script>
</body>
</html>
    ''';

    // Create iframe
    final iframe = html.IFrameElement()
      ..style.width = '100%'
      ..style.height = '700px'
      ..style.border = 'none'
      ..style.borderRadius = '8px'
      ..srcdoc = htmlContent;

    // Register view
    ui_web.platformViewRegistry.registerViewFactory(
      _iframeId,
      (int viewId) => iframe,
    );

    // Listen for messages
    html.window.addEventListener('message', (event) {
      final messageEvent = event as html.MessageEvent;
      print('Received message: ${messageEvent.data}');
      
      if (messageEvent.data is Map) {
        final data = messageEvent.data as Map;
        if (data['type'] == 'PAYMENT_TOKEN') {
          print('Payment token received: ${data['token']}');
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
        elevation: 0,
      ),
      body: ActivityTracker(
        interactionType: 'payment_working_screen',
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
            Text('Preparing secure payment...'),
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
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade600),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Your payment is processed securely through CyberSource. All card details are encrypted.',
                    style: TextStyle(color: Colors.blue.shade700),
                  ),
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
                  : const Center(child: Text('Payment form not available on this platform')),
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