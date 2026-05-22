import 'dart:convert';

class CyberSourceWebViewHTML {
  static String generateHTML(String captureContext) {
    return '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Secure Payment</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background-color: #f5f5f5;
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
        
        .header p {
            color: #666;
            font-size: 14px;
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
        
        .form-control {
            width: 100%;
            padding: 12px;
            border: 2px solid #e1e1e1;
            border-radius: 8px;
            font-size: 16px;
            transition: border-color 0.3s;
            min-height: 48px;
        }
        
        .form-control:focus {
            outline: none;
            border-color: #F37021;
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
        
        .pay-button:hover {
            background: #e5631e;
        }
        
        .pay-button:disabled {
            background: #ccc;
            cursor: not-allowed;
        }
        
        .loading {
            display: none;
            text-align: center;
            padding: 20px;
        }
        
        .loading.show {
            display: block;
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
        
        .security-info {
            background: #f0f9ff;
            border: 1px solid #bae6fd;
            border-radius: 8px;
            padding: 12px;
            margin-bottom: 20px;
            font-size: 14px;
            color: #0369a1;
        }
        
        .security-info .icon {
            display: inline-block;
            margin-right: 8px;
        }

        /* Microform field styling */
     /* Find this class inside your CSS block and replace it */
        .microform-field {
            width: 100% !important;
            height: 52px !important; /* Forces physical height on screen */
            min-height: 52px !important;
            position: relative !important;
            background: white !important;
            display: block !important;
            pointer-events: auto !important; /* Tells the browser to accept clicks */
            border: 2px solid #e1e1e1;
            border-radius: 8px;
            box-sizing: border-box;
        }
        .microform-field iframe {
            width: 100% !important;
            height: 100% !important;
            min-height: 52px !important;
            border: none !important;
            display: block !important;
        }
        
        .microform-field.loading {
            background: #f8f9fa;
            border-color: #F37021;
        }
        
        .microform-field.loading::after {
            content: 'Loading secure field...';
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            color: #666;
            font-size: 14px;
            pointer-events: none;
        }
        
        .field-status {
            background: #e8f5e8;
            color: #2d5a2d;
            padding: 8px 12px;
            border-radius: 4px;
            font-size: 12px;
            margin-bottom: 16px;
            text-align: center;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h2>Secure Payment</h2>
            <p>Your payment information is encrypted and secure</p>
        </div>
        
        <div class="security-info">
            <span class="icon">🔒</span>
            This form is secured by CyberSource encryption
        </div>
        
        <!-- Debug info -->
        <div id="debug-info" style="background: #f0f0f0; padding: 12px; border-radius: 8px; margin-bottom: 16px; font-size: 12px; font-family: monospace;">
            <div>Status: <span id="debug-status">Initializing...</span></div>
            <div>Capture Context: <span id="debug-context">Loading...</span></div>
            <div>Fields Ready: <span id="debug-fields">No</span></div>
        </div>
        
        <div id="error-message" class="error"></div>
        
        <form id="payment-form">
            <div class="form-group">
                <label for="cardNumber">Card Number</label>
                <div id="cardNumber-container" class="microform-field"></div>
            </div>
            
            <div class="card-row">
                <div class="form-group">
                    <label for="expirationMonth">Expiry Month</label>
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
                    <label for="expirationYear">Expiry Year</label>
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
                    <label for="securityCode">CVV</label>
                    <div id="securityCode-container" class="microform-field"></div>
                </div>
            </div>
            
            <button type="submit" id="pay-button" class="pay-button">
                Secure Payment
            </button>
        </form>
        
        <div id="loading" class="loading">
            <p>Processing your payment...</p>
            <p style="margin-top: 8px; font-size: 14px; color: #666;">Please do not close this window</p>
        </div>
    </div>

    <script src="https://testflex.cybersource.com/microform/bundle/v2.9.0/flex-microform.min.js"></script>
    <script>
        console.log('🚀 Payment form starting...');
        
        // Simple logging
        function log(message) {
            console.log('静态 ' + message);
            try {
                if (window.FlutterLog && typeof window.FlutterLog.postMessage === 'function') {
                    window.FlutterLog.postMessage(message);
                }
            } catch (e) {
                // Ignore Flutter logging errors
            }
        }
        
        const captureContext = ${jsonEncode(captureContext)};
        log('Capture context length: ' + captureContext.length);
        
        // Update debug info
        document.getElementById('debug-context').textContent = captureContext.length > 0 ? 
            captureContext.substring(0, 50) + '... (' + captureContext.length + ' chars)' : 'Not loaded';
        
        // FIXED: Escaped the dollar sign using \\\$ so Dart treats it as a raw JS string
        if (!captureContext || captureContext.length < 100) {
            document.getElementById('debug-status').textContent = 'ERROR: Invalid capture context';
            document.getElementById('error-message').textContent = 'Invalid payment configuration';
            document.getElementById('error-message').classList.add('show');
        } else {
            let flex, microform;
            let fieldsReady = false;
            
            // Initialize payment form
            function initPaymentForm() {
                log('Initializing payment form...');
                document.getElementById('debug-status').textContent = 'Initializing...';
                
                // Check if CyberSource library is loaded
                if (typeof Flex === 'undefined') {
                    log('CyberSource library not loaded yet, waiting...');
                    document.getElementById('debug-status').textContent = 'Waiting for CyberSource library...';
                    setTimeout(initPaymentForm, 500);
                    return;
                }
                
                try {
                    log('Creating Flex instance...');
                    document.getElementById('debug-status').textContent = 'Creating Flex instance...';
                    flex = new Flex(captureContext);
                    
                    log('Creating microform...');
                    document.getElementById('debug-status').textContent = 'Creating microform...';
                    microform = flex.microform('card', {
                        styles: {
                            'input': {
                                'font-size': '16px',
                                'color': '#333',
                                'padding': '0',
                                'border': 'none',
                                'outline': 'none',
                                'width': '100%',
                                'height': '100%'
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
                    
                    document.getElementById('debug-status').textContent = 'Loading payment fields...';
                    
                    log('Loading card number field...');
                    let cardNumberField, cvvField;
                    try {
                        cardNumberField = microform.createField('number', { placeholder: '1234 5678 9012 3456' });
                        cvvField = microform.createField('securityCode', { placeholder: '123' });
                        log('Using createField API - only number and securityCode fields');
                    } catch (fieldError) {
                        log('createField failed, fallback to field(): ' + fieldError.message);
                        cardNumberField = microform.field('number');
                        cvvField = microform.field('securityCode');
                    }

                    cardNumberField.load('#cardNumber-container');
                    
                    log('Loading CVV field...');
                    cvvField.load('#securityCode-container');
                    
                    // Mark fields as ready after a short delay
                    setTimeout(() => {
                        fieldsReady = true;
                        log('✅ All fields loaded successfully!');
                        document.getElementById('debug-status').textContent = '✅ Ready for payment';
                        document.getElementById('debug-fields').textContent = 'Yes';
                        document.getElementById('debug-fields').style.color = '#28a745';
                        
                        // Visual feedback - flash green borders
                        const containers = document.querySelectorAll('.microform-field');
                        containers.forEach(container => {
                            container.style.borderColor = '#28a745';
                            container.style.boxShadow = '0 0 5px rgba(40, 167, 69, 0.3)';
                        });
                        
                        setTimeout(() => {
                            containers.forEach(container => {
                                container.style.borderColor = '#e1e1e1';
                                container.style.boxShadow = 'none';
                            });
                        }, 2000);
                        
                        // Hide any error messages
                        document.getElementById('error-message').classList.remove('show');
                    }, 1000);
                    
                } catch (error) {
                    log('❌ Error initializing payment form: ' + error.message);
                    document.getElementById('debug-status').textContent = '❌ Error: ' + error.message;
                    document.getElementById('error-message').textContent = 'Failed to load payment form: ' + error.message;
                    document.getElementById('error-message').classList.add('show');
                }
            }
            
            // Handle form submission
            document.getElementById('payment-form').addEventListener('submit', function(e) {
                e.preventDefault();
                log('Form submitted');
                
                if (!fieldsReady || !microform) {
                    document.getElementById('error-message').textContent = 'Payment form not ready. Please wait and try again.';
                    document.getElementById('error-message').classList.add('show');
                    return;
                }
                
                // Get expiry values from HTML select elements
                const expirationMonth = document.getElementById('expirationMonth').value;
                const expirationYear = document.getElementById('expirationYear').value;
                
                if (!expirationMonth || !expirationYear) {
                    document.getElementById('error-message').textContent = 'Please select both expiration month and year.';
                    document.getElementById('error-message').classList.add('show');
                    return;
                }
                
                // Show loading
                document.getElementById('loading').classList.add('show');
                document.getElementById('payment-form').style.display = 'none';
                document.getElementById('error-message').classList.remove('show');
                
                log('Creating payment token with expiry: ' + expirationMonth + '/' + expirationYear);
                
                // Create token with expiry data
                const tokenData = {
                    expirationMonth: expirationMonth,
                    expirationYear: expirationYear
                };
                
                microform.createToken(tokenData, function(err, token) {
                    // Hide loading
                    document.getElementById('loading').classList.remove('show');
                    document.getElementById('payment-form').style.display = 'block';
                    
                    if (err) {
                        log('❌ Token creation failed: ' + err.message);
                        document.getElementById('error-message').textContent = 'Payment validation failed: ' + err.message;
                        document.getElementById('error-message').classList.add('show');
                        return;
                    }
                    
                    if (token) {
                        log('✅ Token created successfully');
                        
                        // Send token to Flutter
                        try {
                            if (window.paymentToken && typeof window.paymentToken.postMessage === 'function') {
                                window.paymentToken.postMessage(JSON.stringify(token));
                            } else {
                                window.parent.postMessage({
                                    type: 'PAYMENT_TOKEN',
                                    token: token,
                                    expirationMonth: expirationMonth,
                                    expirationYear: expirationYear
                                }, '*');
                            }
                            log('Token sent to Flutter');
                        } catch (e) {
                            log('Failed to send token: ' + e.message);
                            document.getElementById('error-message').textContent = 'Payment processed but communication failed.';
                            document.getElementById('error-message').classList.add('show');
                        }
                    } else {
                        log('❌ No token received');
                        document.getElementById('error-message').textContent = 'Failed to process payment. Please try again.';
                        document.getElementById('error-message').classList.add('show');
                    }
                });
            });
            
            // Start initialization when DOM is ready
            if (document.readyState === 'loading') {
                document.addEventListener('DOMContentLoaded', initPaymentForm);
            } else {
                initPaymentForm();
            }
            
            // Also try when window loads (backup)
            window.addEventListener('load', function() {
                if (!fieldsReady) {
                    log('Backup initialization attempt...');
                    setTimeout(initPaymentForm, 1000);
                }
            });
        }
    </script>
</body>
</html>
''';
  }
}