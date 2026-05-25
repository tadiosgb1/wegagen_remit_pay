import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../providers/payment_providers.dart';
import '../../widgets/activity_tracker.dart';
import 'payment_processing_screen.dart';

class PaymentMobileOptimizedScreen extends ConsumerStatefulWidget {
  const PaymentMobileOptimizedScreen({super.key});

  @override
  ConsumerState<PaymentMobileOptimizedScreen> createState() => _PaymentMobileOptimizedScreenState();
}

class _PaymentMobileOptimizedScreenState extends ConsumerState<PaymentMobileOptimizedScreen> {
  bool _isLoading = true;
  bool _isSetupDone = false;
  String? _error;
  String? _captureContext;
  WebViewController? _webViewController;

  @override
  void initState() {
    super.initState();
  }


@override
void dispose() {
  _webViewController = null;
  super.dispose();
}




 void _setupMobilePayment() {
  if (_captureContext == null) return;

  if (_isSetupDone) return;
  _isSetupDone = true;
  
      // Create WebView controller optimized for mobile
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent('Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36')
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            print('DEBUG: Page started loading: $url');
          },
          onPageFinished: (String url) {
            print('DEBUG: Page finished loading: $url');
            // Inject mobile-specific fixes
            _webViewController?.runJavaScript('''
              // Mobile touch event fixes
              document.addEventListener('DOMContentLoaded', function() {
                // Enable touch events for microform containers
                const containers = document.querySelectorAll('.microform-field');
                containers.forEach(container => {
                  container.style.pointerEvents = 'auto';
                  container.style.touchAction = 'manipulation';
                  
                  // Add touch event listeners
                  container.addEventListener('touchstart', function(e) {
                    console.log('Touch start on microform field');
                    e.stopPropagation();
                  }, { passive: false });
                  
                  container.addEventListener('touchend', function(e) {
                    console.log('Touch end on microform field');
                    e.stopPropagation();
                  }, { passive: false });
                });
                
                // Focus fix for mobile
                setTimeout(() => {
                  const firstField = document.querySelector('#cardNumber-container iframe');
                  if (firstField) {
                    firstField.focus();
                  }
                }, 2000);
              });
            ''');
          },
          onWebResourceError: (WebResourceError error) {
            print('DEBUG: WebView error: ${error.description}');
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
            print('DEBUG: Error parsing message: $e');
          }
        },
      );

    // Load the mobile-optimized HTML content
    final htmlContent = _createMobileOptimizedHTML();
    _webViewController!.loadHtmlString(htmlContent);
    
    setState(() {
      _isLoading = false;
    });
  }

  String _createMobileOptimizedHTML() {
    return '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title>Secure Payment</title>
    <style>
        * { 
            margin: 0; 
            padding: 0; 
            box-sizing: border-box; 
            -webkit-tap-highlight-color: transparent;
        }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: #f5f5f5;
            padding: 16px;
            -webkit-text-size-adjust: 100%;
            -webkit-touch-callout: none;
            -webkit-user-select: none;
            -khtml-user-select: none;
            -moz-user-select: none;
            -ms-user-select: none;
            user-select: none;
        }
        
        .container {
            max-width: 100%;
            margin: 0 auto;
            background: white;
            border-radius: 12px;
            padding: 20px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        
        .header {
            text-align: center;
            margin-bottom: 20px;
        }
        
        .header h2 {
            color: #333;
            margin-bottom: 8px;
            font-size: 20px;
        }
        
        .form-group {
            margin-bottom: 16px;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 8px;
            color: #333;
            font-weight: 500;
            font-size: 14px;
        }
        
        .form-control {
            width: 100%;
            padding: 14px;
            border: 2px solid #e1e1e1;
            border-radius: 8px;
            font-size: 16px;
            background: white;
            -webkit-appearance: none;
            -moz-appearance: none;
            appearance: none;
        }
        
        .form-control:focus {
            outline: none;
            border-color: #F37021;
        }
        
        .microform-field {
            width: 100% !important;
            height: 56px !important;
            min-height: 56px !important;
            position: relative !important;
            background: white !important;
            display: block !important;
            pointer-events: auto !important;
            touch-action: manipulation !important;
            border: 2px solid #e1e1e1;
            border-radius: 8px;
            box-sizing: border-box;
            -webkit-user-select: text;
            -moz-user-select: text;
            -ms-user-select: text;
            user-select: text;
        }
        
        .microform-field:focus-within {
            border-color: #F37021;
        }
        
        .microform-field iframe {
            width: 100% !important;
            height: 100% !important;
            min-height: 56px !important;
            border: none !important;
            display: block !important;
            pointer-events: auto !important;
            touch-action: manipulation !important;
        }
        
        .card-row {
            display: flex;
            gap: 12px;
            flex-wrap: wrap;
        }
        
        .card-row .form-group {
            flex: 1;
            min-width: 120px;
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
            margin-top: 20px;
            -webkit-appearance: none;
            -moz-appearance: none;
            appearance: none;
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
            font-size: 14px;
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
            text-align: center;
        }
        
        @media (max-width: 480px) {
            .card-row {
                flex-direction: column;
            }
            
            .card-row .form-group {
                min-width: 100%;
            }
            
            .container {
                padding: 16px;
            }
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
                    <select id="expirationMonth" class="form-control" required>
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
                    <select id="expirationYear" class="form-control" required>
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
                    window.PaymentChannel.postMessage(JSON.stringify(data));
                } else {
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
                
                const flex = new Flex(captureContext);
                console.log('Flex instance created successfully');
                
                const microform = flex.microform('card', {
                    styles: {
                        'input': {
                            'font-size': '16px',
                            'font-family': '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif',
                            'color': '#333',
                            'padding': '12px',
                            'border': 'none',
                            'outline': 'none',
                            'width': '100%',
                            'background': 'transparent',
                            '-webkit-appearance': 'none',
                            '-moz-appearance': 'none',
                            'appearance': 'none'
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
                
                updateStatus('Loading payment fields...');
                
                // Create only supported fields
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
                
                // Load fields
                try {
                    console.log('Loading card number field...');
                    numberField.load('#cardNumber-container');
                    
                    console.log('Loading CVV field...');
                    cvvField.load('#securityCode-container');
                    
                    console.log('All microform fields loaded successfully');
                } catch (loadError) {
                    console.error('Field loading failed:', loadError);
                    showError('Failed to load input fields: ' + loadError.message);
                    return;
                }
                
                // Mobile-specific event handlers
                numberField.on('focus', function() {
                    console.log('Card number field focused');
                    document.getElementById('cardNumber-container').style.borderColor = '#F37021';
                });
                
                numberField.on('blur', function() {
                    console.log('Card number field blurred');
                    document.getElementById('cardNumber-container').style.borderColor = '#e1e1e1';
                });
                
                cvvField.on('focus', function() {
                    console.log('CVV field focused');
                    document.getElementById('securityCode-container').style.borderColor = '#F37021';
                });
                
                cvvField.on('blur', function() {
                    console.log('CVV field blurred');
                    document.getElementById('securityCode-container').style.borderColor = '#e1e1e1';
                });
                
                // Show form after fields are loaded
                setTimeout(() => {
                    updateStatus('Payment form ready - tap fields to enter card details');
                    showForm();
                    
                    // Mobile interaction fixes
                    const cardContainer = document.getElementById('cardNumber-container');
                    const cvvContainer = document.getElementById('securityCode-container');
                    
                    // Add mobile touch handlers
                    [cardContainer, cvvContainer].forEach(container => {
                        if (container) {
                            container.addEventListener('touchstart', function(e) {
                                console.log('Touch start on container');
                                container.style.borderColor = '#F37021';
                            }, { passive: true });
                            
                            container.addEventListener('touchend', function(e) {
                                console.log('Touch end on container');
                                setTimeout(() => {
                                    const iframe = container.querySelector('iframe');
                                    if (iframe) {
                                        iframe.focus();
                                    }
                                }, 100);
                            }, { passive: true });
                        }
                    });
                    
                    // Check iframe loading
                    setTimeout(() => {
                        const cardIframe = cardContainer.querySelector('iframe');
                        const cvvIframe = cvvContainer.querySelector('iframe');
                        
                        if (!cardIframe || !cvvIframe) {
                            console.warn('Microform iframes not found');
                            showError('Payment fields failed to load. Please refresh and try again.');
                        } else {
                            console.log('Microform iframes loaded successfully');
                            updateStatus('Ready - tap on the card number field to start');
                        }
                    }, 2000);
                }, 3000);
                
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
                showError('Failed to initialize payment form: ' + error.message);
            }
        }
        
        // Start initialization
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', initializePayment);
        } else {
            initializePayment();
        }
        
        // Mobile-specific fixes
        document.addEventListener('DOMContentLoaded', function() {
            // Prevent zoom on input focus
            const viewport = document.querySelector('meta[name=viewport]');
            if (viewport) {
                viewport.setAttribute('content', 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no');
            }
            
            // Fix iOS Safari issues
            if (/iPad|iPhone|iPod/.test(navigator.userAgent)) {
                document.body.style.webkitTextSizeAdjust = '100%';
                document.body.style.webkitTouchCallout = 'none';
            }
        });
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
        interactionType: 'payment_mobile_optimized_screen',
        child: captureContextAsync.when(
          data: (response) {
          if (_captureContext != response.data.captureContext) {
            
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;

              setState(() {
                _captureContext = response.data.captureContext;
              });

              _setupMobilePayment();
            });


          }
            
            return _buildBody();
          },
          loading: () {
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

  return SafeArea(
    bottom: true,
    child: Padding(
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
                    'Mobile-optimized payment form. Tap on fields to enter card details.',
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
              child: _webViewController != null
                  ? WebViewWidget(controller: _webViewController!)
                  : const Center(child: Text('Loading payment form...')),
            ),
          ),
        ],
      ),
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
                        _isSetupDone = false;
                        _webViewController = null;
                      });

                      ref.invalidate(captureContextProvider);
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