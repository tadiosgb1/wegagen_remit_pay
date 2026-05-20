import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/payment_providers.dart';
import '../../widgets/activity_tracker.dart';
import 'payment_processing_screen.dart';

// Conditional imports for web and mobile
import 'dart:html' as html show window, MessageEvent, Element, Blob, Url, ScriptElement, document;
import 'dart:ui_web' as ui_web show platformViewRegistry;
import 'package:webview_flutter/webview_flutter.dart';

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
  WebViewController? _webViewController;

  @override
  void initState() {
    super.initState();
    _initializePayment();
  }

  void _initializePayment() async {
    try {
      print('DEBUG: Starting payment initialization...');
      print('DEBUG: Platform - kIsWeb: $kIsWeb');
      
      final captureContextAsync = ref.read(captureContextProvider);
      
      captureContextAsync.when(
        data: (response) {
          print('DEBUG: Capture context received successfully');
          print('DEBUG: Status: ${response.status}');
          print('DEBUG: Token length: ${response.data?.captureContext?.length ?? 0}');
          print('DEBUG: Token preview: ${response.data?.captureContext?.substring(0, 50) ?? 'null'}...');
          setState(() {
            _captureContext = response.data.captureContext;
          });
          if (kIsWeb) {
            print('DEBUG: Setting up web payment...');
            _setupWebPayment();
          } else {
            print('DEBUG: Setting up mobile payment...');
            _setupMobilePayment();
          }
        },
        loading: () {
          print('DEBUG: Capture context is loading from backend...');
          // Keep loading state
        },
        error: (error, stack) {
          print('DEBUG: Capture context error: $error');
          print('DEBUG: Stack trace: $stack');
          setState(() {
            _error = 'Failed to get payment configuration: $error';
            _isLoading = false;
          });
        },
      );
    } catch (e) {
      print('DEBUG: Exception in _initializePayment: $e');
      setState(() {
        _error = 'Failed to initialize payment: $e';
        _isLoading = false;
      });
    }
  }

  void _setupWebPayment() {
    print('DEBUG: _setupWebPayment called');
    if (_captureContext == null) {
      print('DEBUG: ERROR - _captureContext is null');
      return;
    }
    
    print('DEBUG: Capture context available, creating HTML content...');
    
    // Create HTML content for the payment form
    final htmlContent = _createPaymentHTML();
    print('DEBUG: HTML content created, length: ${htmlContent.length}');
    
    // Create blob URL for better Chrome compatibility
    final blob = html.Blob([htmlContent], 'text/html');
    final blobUrl = html.Url.createObjectUrlFromBlob(blob);
    print('DEBUG: Blob URL created: $blobUrl');
    
    final iframe = html.Element.tag('iframe')
      ..style.width = '100%'
      ..style.height = '700px'
      ..style.border = 'none'
      ..style.borderRadius = '8px'
      ..setAttribute('src', blobUrl)
      ..setAttribute('sandbox', 'allow-scripts allow-same-origin allow-forms allow-popups');

    print('DEBUG: Iframe created, registering view factory...');

    // Register view
    ui_web.platformViewRegistry.registerViewFactory(
      _iframeId,
      (int viewId) {
        print('DEBUG: View factory called with viewId: $viewId');
        return iframe;
      },
    );

    print('DEBUG: View factory registered, setting up message listener...');

    // Listen for messages
    html.window.addEventListener('message', (event) {
      final messageEvent = event as html.MessageEvent;
      final rawData = messageEvent.data;

      dynamic parsed;
      if (rawData is String) {
        try {
          parsed = jsonDecode(rawData);
        } catch (e) {
          return;
        }
      } else {
        parsed = rawData;
      }

      if (parsed is Map) {
        final data = parsed as Map<String, dynamic>;
        final type = data['type']?.toString();
        if (type == 'PAYMENT_TOKEN' || type == 'paymentToken') {
          _handlePaymentToken(data['token'].toString());
        }
      }
    });

    print('DEBUG: Message listener set up, updating state to show microform...');
    setState(() {
      _isLoading = false;
    });
    print('DEBUG: State updated, _isLoading = false');
  }

  void _setupMobilePayment() {
    if (_captureContext == null) return;
    
    // Create WebView controller for mobile
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            // Page started loading
          },
          onPageFinished: (String url) {
            // Page finished loading
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _error = 'Failed to load payment form: ${error.description}';
              _isLoading = false;
            });
          },
        ),
      )
      ..addJavaScriptChannel(
        'PaymentChannel',
        onMessageReceived: (JavaScriptMessage message) {
          try {
            final data = jsonDecode(message.message);
            if (data['type'] == 'PAYMENT_TOKEN') {
              _handlePaymentToken(data['token'].toString());
            }
          } catch (e) {
            // Handle parsing error
          }
        },
      );

    // Load the HTML content
    final htmlContent = _createPaymentHTML();
    _webViewController!.loadHtmlString(htmlContent);
    
    setState(() {
      _isLoading = false;
    });
  }

  String _createPaymentHTML() {
    return '''
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
            position: relative;
        }
        
        .microform-field iframe {
            width: 100% !important;
            height: 100% !important;
            min-height: 48px !important;
            border: none !important;
            display: block !important;
            padding: 0 !important;
            margin: 0 !important;
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
        
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
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

    <script src="https://testflex.cybersource.com/microform/bundle/v2.9.0/flex-microform.min.js"></script>
    <script>
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
        
        function sendMessage(data) {
            try {
                if (window.PaymentChannel && window.PaymentChannel.postMessage) {
                    // Mobile WebView
                    window.PaymentChannel.postMessage(JSON.stringify(data));
                } else {
                    // Web iframe
                    window.parent.postMessage(data, '*');
                }
            } catch (e) {
                console.error('Failed to send message:', e);
            }
        }
        
        function initializePayment() {
            updateStatus('Loading CyberSource library...');
            
            if (typeof Flex === 'undefined') {
                setTimeout(initializePayment, 500);
                return;
            }
            
            try {
                updateStatus('Creating secure payment form...');
                
                const captureContext = ${jsonEncode(_captureContext)};
                console.log('Capture context received:', captureContext.substring(0, 100) + '...');
                
                // Check if we're on localhost and add special handling
                const isLocalhost = window.location.hostname === 'localhost' || 
                                  window.location.hostname === '127.0.0.1' ||
                                  window.location.hostname.includes('localhost');
                
                if (isLocalhost) {
                    console.log('Running on localhost - using development configuration');
                }
                
                const flex = new Flex(captureContext);
                console.log('Flex instance created successfully');
                
                // Create microform with enhanced error handling
                let microform;
                try {
                    microform = flex.microform('card', {
                        styles: {
                            'input': {
                                'font-size': '16px',
                                'font-family': '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif',
                                'color': '#333',
                                'padding': '8px',
                                'border': 'none',
                                'outline': 'none',
                                'width': '100%',
                                'background': 'transparent'
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
                    console.log('Microform created successfully');
                } catch (microformError) {
                    console.error('Microform creation failed:', microformError);
                    showError('Failed to create secure form: ' + microformError.message);
                    return;
                }
                
                updateStatus('Loading payment fields...');
                
                // Create microform fields with enhanced error handling
                let numberField, cvvField;
                try {
                    numberField = microform.createField('number', { 
                        placeholder: '1234 5678 9012 3456' 
                    });
                    console.log('Card number field created');
                    
                    cvvField = microform.createField('securityCode', { 
                        placeholder: '123' 
                    });
                    console.log('CVV field created');
                } catch (fieldError) {
                    console.error('Field creation failed:', fieldError);
                    showError('Failed to create input fields: ' + fieldError.message);
                    return;
                }
                
                // Load microform fields with error handling
                try {
                    console.log('Loading card number field...');
                    numberField.load('#cardNumber-container');
                    
                    console.log('Loading CVV field...');
                    cvvField.load('#securityCode-container');
                    
                    console.log('All fields loaded successfully');
                } catch (loadError) {
                    console.error('Field loading failed:', loadError);
                    showError('Failed to load input fields: ' + loadError.message);
                    return;
                }
                
                // Add field event listeners for debugging
                numberField.on('focus', function() {
                    console.log('Card number field focused');
                });
                
                numberField.on('blur', function() {
                    console.log('Card number field blurred');
                });
                
                cvvField.on('focus', function() {
                    console.log('CVV field focused');
                });
                
                cvvField.on('blur', function() {
                    console.log('CVV field blurred');
                });
                
                // Show form after fields are loaded
                setTimeout(() => {
                    updateStatus('Payment form ready');
                    showForm();
                    
                    // Add click handlers to containers for debugging
                    const cardContainer = document.getElementById('cardNumber-container');
                    const cvvContainer = document.getElementById('securityCode-container');
                    
                    if (cardContainer) {
                        cardContainer.addEventListener('click', function() {
                            console.log('Card number container clicked');
                        });
                    }
                    
                    if (cvvContainer) {
                        cvvContainer.addEventListener('click', function() {
                            console.log('CVV container clicked');
                        });
                    }
                    
                    // Check if fields are actually interactive after a delay
                    setTimeout(() => {
                        const cardIframe = cardContainer.querySelector('iframe');
                        const cvvIframe = cvvContainer.querySelector('iframe');
                        
                        if (!cardIframe || !cvvIframe) {
                            console.warn('Microform iframes not found - this may indicate localhost security restrictions');
                            
                            // For localhost development, show a helpful message
                            if (isLocalhost) {
                                showError('Localhost detected: Microform fields may not work due to security restrictions. For testing, try using test card data or deploy to a proper domain with HTTPS.');
                            }
                        } else {
                            console.log('Microform iframes loaded successfully');
                        }
                    }, 1000);
                }, 2000);
                
                // Handle form submission
                document.getElementById('payment-form').addEventListener('submit', function(e) {
                    e.preventDefault();
                    
                    const expirationMonth = document.getElementById('expirationMonth').value;
                    const expirationYear = document.getElementById('expirationYear').value;
                    
                    if (!expirationMonth || !expirationYear) {
                        showError('Please select both expiration month and year.');
                        return;
                    }
                    
                    console.log('Form submitted with expiry:', expirationMonth + '/' + expirationYear);
                    showLoading(true);
                    
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
                            sendMessage({
                                type: 'PAYMENT_TOKEN',
                                token: token,
                                expirationMonth: expirationMonth,
                                expirationYear: expirationYear
                            });
                        }
                    });
                });
                
            } catch (error) {
                console.error('Initialization error:', error);
                showError('Failed to initialize payment form: ' + error.message + '. Please check browser console for details.');
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
    final captureContextAsync = ref.watch(captureContextProvider);
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Secure Payment'),
        backgroundColor: const Color(0xFFF37021),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ActivityTracker(
        interactionType: 'payment_working_screen',
        child: captureContextAsync.when(
          data: (response) {
            print('DEBUG: Capture context received successfully');
            print('DEBUG: Status: ${response.status}');
            print('DEBUG: Token length: ${response.data?.captureContext?.length ?? 0}');
            
            // Set capture context and setup payment
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_captureContext != response.data.captureContext) {
                setState(() {
                  _captureContext = response.data.captureContext;
                });
                if (kIsWeb) {
                  print('DEBUG: Setting up web payment...');
                  _setupWebPayment();
                } else {
                  print('DEBUG: Setting up mobile payment...');
                  _setupMobilePayment();
                }
              }
            });
            
            return _buildBody();
          },
          loading: () {
            print('DEBUG: Capture context is loading from backend...');
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
          },
          error: (error, stack) {
            print('DEBUG: Capture context error: $error');
            return _buildErrorState('Failed to get payment configuration: $error');
          },
        ),
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
                  : _webViewController != null
                      ? WebViewWidget(controller: _webViewController!)
                      : const Center(child: Text('Loading payment form...')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState([String? errorMessage]) {
    final displayError = errorMessage ?? _error ?? 'Unknown error occurred';
    
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
            Text(displayError, textAlign: TextAlign.center),
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
                      _initializePayment();
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