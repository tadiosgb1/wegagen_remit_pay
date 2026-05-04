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
        .microform-field {
            width: 100%;
            padding: 12px;
            border: 2px solid #e1e1e1;
            border-radius: 8px;
            font-size: 16px;
            min-height: 48px;
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
        
        <div id="error-message" class="error"></div>
        
        <form id="payment-form">
            <div class="form-group">
                <label for="cardNumber">Card Number</label>
                <div id="cardNumber-container" class="microform-field"></div>
            </div>
            
            <div class="card-row">
                <div class="form-group">
                    <label for="expirationMonth">Expiry Month</label>
                    <div id="expirationMonth-container" class="microform-field"></div>
                </div>
                
                <div class="form-group">
                    <label for="expirationYear">Expiry Year</label>
                    <div id="expirationYear-container" class="microform-field"></div>
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
        // Enhanced logging function
        function logToFlutter(message) {
            console.log(message);
            try {
                if (window.FlutterLog && typeof window.FlutterLog.postMessage === 'function') {
                    window.FlutterLog.postMessage(message);
                }
            } catch (e) {
                console.log('Failed to log to Flutter:', e);
            }
        }
        
        logToFlutter('Starting CyberSource Flex initialization...');
        logToFlutter('Capture Context received: ' + ('$captureContext'.length > 0 ? 'Yes (' + '$captureContext'.length + ' chars)' : 'No'));
        
        // Validate capture context format
        if (captureContext && captureContext.length > 0) {
            try {
                // Basic JWT validation (should have 3 parts separated by dots)
                const parts = captureContext.split('.');
                if (parts.length === 3) {
                    logToFlutter('Capture context appears to be valid JWT format');
                } else {
                    logToFlutter('WARNING: Capture context does not appear to be valid JWT format');
                }
            } catch (e) {
                logToFlutter('Error validating capture context: ' + e.message);
            }
        } else {
            logToFlutter('ERROR: No capture context provided');
            showError('No capture context provided. Please try again.');
            return;
        }
        
        // CyberSource Flex configuration
        const captureContext = '$captureContext';
        let flex;
        let microform;
        
        // Initialize CyberSource Flex
        function initializeFlex() {
            try {
                logToFlutter('Creating Flex instance...');
                flex = new Flex(captureContext);
                
                logToFlutter('Creating microform...');
                // Create microform
                microform = flex.microform({
                    styles: {
                        'input': {
                            'font-size': '16px',
                            'font-family': '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif',
                            'color': '#333',
                            'padding': '12px',
                            'border': 'none',
                            'outline': 'none'
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
                
                logToFlutter('Creating fields...');
                
                // Create number field
                const numberField = microform.field('number', {
                    placeholder: '1234 5678 9012 3456'
                });
                numberField.load('#cardNumber-container');
                logToFlutter('Card number field loaded');
                
                // Create expiry month field
                const expiryMonthField = microform.field('expirationMonth', {
                    placeholder: 'MM'
                });
                expiryMonthField.load('#expirationMonth-container');
                logToFlutter('Expiry month field loaded');
                
                // Create expiry year field
                const expiryYearField = microform.field('expirationYear', {
                    placeholder: 'YY'
                });
                expiryYearField.load('#expirationYear-container');
                logToFlutter('Expiry year field loaded');
                
                // Create security code field
                const securityCodeField = microform.field('securityCode', {
                    placeholder: '123'
                });
                securityCodeField.load('#securityCode-container');
                logToFlutter('Security code field loaded');
                
                logToFlutter('CyberSource Flex initialized successfully');
                hideError();
                
            } catch (error) {
                logToFlutter('Failed to initialize CyberSource Flex: ' + error.message);
                showError('Failed to initialize secure payment form: ' + error.message);
            }
        }
        
        // Handle form submission
        document.getElementById('payment-form').addEventListener('submit', function(e) {
            e.preventDefault();
            
            logToFlutter('Form submitted');
            
            if (!microform) {
                showError('Payment form not ready. Please try again.');
                return;
            }
            
            showLoading(true);
            hideError();
            
            // Create token
            microform.createToken({}, function(err, token) {
                logToFlutter('Token creation callback - Error: ' + (err ? err.message : 'None') + ', Token: ' + (token ? 'Received' : 'None'));
                showLoading(false);
                
                if (err) {
                    logToFlutter('Token creation failed: ' + err.message);
                    showError('Payment validation failed: ' + (err.message || 'Please check your card details and try again.'));
                    return;
                }
                
                if (token) {
                    logToFlutter('Token created successfully: ' + token);
                    
                    // Send token back to Flutter - try multiple methods
                    try {
                        // Method 1: Flutter WebView JavaScript channel
                        if (window.paymentToken && typeof window.paymentToken.postMessage === 'function') {
                            logToFlutter('Sending token via Flutter channel');
                            window.paymentToken.postMessage(JSON.stringify(token));
                            return;
                        }
                        
                        // Method 2: Post message to parent (for Flutter web)
                        logToFlutter('Sending token via postMessage');
                        window.parent.postMessage({
                            type: 'PAYMENT_TOKEN',
                            token: token
                        }, '*');
                        
                        // Method 3: Console log for debugging
                        logToFlutter('TOKEN_READY: ' + JSON.stringify(token));
                        
                        // Show success message if no communication method worked
                        showError('Payment token generated successfully. Check console for token details.');
                        
                    } catch (commError) {
                        logToFlutter('Communication error: ' + commError.message);
                        showError('Payment processed but communication failed. Check console for token details.');
                    }
                } else {
                    showError('Failed to process payment. Please try again.');
                }
            });
        });
        
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
        
        function showError(message) {
            const errorDiv = document.getElementById('error-message');
            errorDiv.textContent = message;
            errorDiv.classList.add('show');
        }
        
        function hideError() {
            const errorDiv = document.getElementById('error-message');
            errorDiv.classList.remove('show');
        }
        
        // Initialize when page loads
        document.addEventListener('DOMContentLoaded', function() {
            logToFlutter('DOM loaded, initializing Flex...');
            setTimeout(initializeFlex, 500);
        });
        
        // Handle page visibility changes
        document.addEventListener('visibilitychange', function() {
            if (document.hidden) {
                console.log('Page hidden');
            } else {
                console.log('Page visible');
            }
        });

        // Listen for messages from parent (Flutter web)
        window.addEventListener('message', function(event) {
            console.log('Received message:', event.data);
        });
    </script>
</body>
</html>
    ''';
  }
}