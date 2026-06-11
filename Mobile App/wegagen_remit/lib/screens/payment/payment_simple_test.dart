


import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;

// Use these imports if you are targeting Web specifically
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;


import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/payment_providers.dart';

class PaymentSimpleTest extends ConsumerWidget {
  const PaymentSimpleTest({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final captureContextAsync = ref.watch(captureContextProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Test'),
        backgroundColor: const Color(0xFFF37021),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: captureContextAsync.when(
          data: (response) {
            final captureContext = response.data.captureContext;
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '✅ Capture Context Received',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Length: ${captureContext.length} characters',
                        style: TextStyle(color: Colors.green.shade600),
                      ),
                      Text(
                        'Preview: ${captureContext.substring(0, 50)}...',
                        style: TextStyle(
                          color: Colors.green.shade600,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                ElevatedButton(
                  onPressed: () => _testDirectHTML(captureContext),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF37021),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Test Direct HTML'),
                ),
                
                const SizedBox(height: 20),
                
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: kIsWeb 
                        ? _buildTestIframe(captureContext)
                        : const Center(child: Text('Web only test')),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Color(0xFFF37021)),
                SizedBox(height: 16),
                Text('Loading capture context...'),
              ],
            ),
          ),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: $error'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTestIframe(String captureContext) {
    final iframeId = 'test-iframe-${DateTime.now().millisecondsSinceEpoch}';
    
    final htmlContent = '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>CyberSource Test</title>
    <style>
        body { 
            font-family: Arial, sans-serif; 
            padding: 20px; 
            background: #f9f9f9;
        }
        .status { 
            padding: 10px; 
            margin: 10px 0; 
            border-radius: 4px; 
            font-weight: bold;
        }
        .success { background: #d4edda; color: #155724; }
        .error { background: #f8d7da; color: #721c24; }
        .info { background: #d1ecf1; color: #0c5460; }
        .field { 
            margin: 10px 0; 
            padding: 10px; 
            border: 2px solid #ddd; 
            border-radius: 4px; 
            min-height: 40px;
            background: white;
        }
    </style>
</head>
<body>
    <h2>CyberSource Microform Test</h2>
    
    <div id="status" class="status info">Initializing...</div>
    
    <div>
        <strong>Capture Context Info:</strong><br>
        Length: ${captureContext.length}<br>
        First 100 chars: ${captureContext.substring(0, 100)}...
    </div>
    
    <hr>
    
    <div id="payment-fields">
        <h3>Payment Fields</h3>
        <div>Card Number:</div>
        <div id="cardNumber" class="field"></div>
        
        <div style="display: flex; gap: 10px;">
            <div style="flex: 1;">
                <div>Month:</div>
                <div id="expirationMonth" class="field"></div>
            </div>
            <div style="flex: 1;">
                <div>Year:</div>
                <div id="expirationYear" class="field"></div>
            </div>
            <div style="flex: 1;">
                <div>CVV:</div>
                <div id="securityCode" class="field"></div>
            </div>
        </div>
        
        <button onclick="testToken()" style="padding: 10px 20px; background: #F37021; color: white; border: none; border-radius: 4px; margin-top: 10px;">
            Test Token Creation
        </button>
    </div>

    <script>
        const status = document.getElementById('status');
        
        function updateStatus(message, type = 'info') {
            status.textContent = message;
            status.className = 'status ' + type;
            console.log(message);
        }
        
        updateStatus('Loading CyberSource script...');
        
        // Load CyberSource script
        const script = document.createElement('script');
        script.src = 'https://testflex.cybersource.com/microform/bundle/v2.9.0/flex-microform.min.js';
        
        script.onload = function() {
            updateStatus('Script loaded, initializing Flex...', 'info');
            setTimeout(initFlex, 500);
        };
        
        script.onerror = function() {
            updateStatus('Failed to load CyberSource script', 'error');
        };
        
        document.head.appendChild(script);
        
        const captureContext = ${jsonEncode(captureContext)};
        let flex, microform;
        
        function initFlex() {
            try {
                if (typeof Flex === 'undefined') {
                    throw new Error('Flex not available');
                }
                
                updateStatus('Creating Flex instance...', 'info');
                flex = new Flex(captureContext);
                
                updateStatus('Creating microform...', 'info');
                microform = flex.microform('card');
                
                updateStatus('Loading fields...', 'info');
                
                let numberField = null;
                let monthField = null;
                let yearField = null;
                let cvvField = null;

                try {
                    numberField = microform.createField('number');
                    monthField = microform.createField('expirationMonth');
                    yearField = microform.createField('expirationYear');
                    cvvField = microform.createField('securityCode');
                } catch (createFieldError) {
                    updateStatus('createField failed, trying field(): ' + createFieldError.message, 'info');
                    numberField = microform.field('number');
                    monthField = microform.field('expirationMonth');
                    yearField = microform.field('expirationYear');
                    cvvField = microform.field('securityCode');
                }

                numberField.load('#cardNumber');
                monthField.load('#expirationMonth');
                yearField.load('#expirationYear');
                cvvField.load('#securityCode');
                
                updateStatus('✅ SUCCESS: Microform ready!', 'success');
                document.getElementById('payment-fields').style.display = 'block';
                
            } catch (error) {
                updateStatus('❌ ERROR: ' + error.message, 'error');
            }
        }
        
        function testToken() {
            if (!microform) {
                updateStatus('Microform not ready', 'error');
                return;
            }
            
            updateStatus('Creating test token...', 'info');
            
            microform.createToken({}, function(err, token) {
                if (err) {
                    updateStatus('Token error: ' + err.message, 'error');
                } else {
                    updateStatus('✅ Token created: ' + token, 'success');
                    window.parent.postMessage({type: 'TOKEN', token: token}, '*');
                }
            });
        }
    </script>
</body>
</html>
    ''';

    final iframe = html.IFrameElement()
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.border = 'none'
      ..src = '/cybersource_payment_frame.html';

    iframe.onLoad.listen((_) {
      iframe.contentWindow?.postMessage(
        {
          'type': 'captureContext',
          'captureContext': captureContext,
        },
        html.window.location.origin ?? '*',
      );
    });

    ui_web.platformViewRegistry.registerViewFactory(
      iframeId,
      (int viewId) => iframe,
    );

    // Listen for messages
    html.window.addEventListener('message', (event) {
      final messageEvent = event as html.MessageEvent;
      if (messageEvent.data is Map) {
        final data = messageEvent.data as Map;
        if (data['type'] == 'TOKEN') {
          print('Test token received: ${data['token']}');
        }
      }
    });

    return HtmlElementView(viewType: iframeId);
  }

  void _testDirectHTML(String captureContext) {
    if (!kIsWeb) return;
    
    // Open a new window for testing
    final testWindow = html.window.open('', 'cybersource_test', 'width=800,height=600');
    
    testWindow?.document?.write('''
<!DOCTYPE html>
<html>
<head>
    <title>Direct CyberSource Test</title>
    <style>
        body { font-family: Arial, sans-serif; padding: 20px; }
        .field { margin: 10px 0; padding: 10px; border: 1px solid #ddd; min-height: 40px; }
    </style>
</head>
<body>
    <h1>Direct CyberSource Test</h1>
    <div id="status">Loading...</div>
    
    <div id="cardNumber" class="field"></div>
    <div id="expirationMonth" class="field"></div>
    <div id="expirationYear" class="field"></div>
    <div id="securityCode" class="field"></div>
    
    <script src="https://testflex.cybersource.com/microform/bundle/v2.9.0/flex-microform.min.js"></script>
    <script>
        const status = document.getElementById('status');
        
        setTimeout(function() {
            try {
                status.textContent = 'Initializing Flex...';
                
                const flex = new Flex(${jsonEncode(captureContext)});
                const microform = flex.microform('card');
                
                let numberField = null;
                let monthField = null;
                let yearField = null;
                let cvvField = null;

                try {
                    numberField = microform.createField('number');
                    monthField = microform.createField('expirationMonth');
                    yearField = microform.createField('expirationYear');
                    cvvField = microform.createField('securityCode');
                } catch (createFieldError) {
                    console.log('createField failed, trying field():', createFieldError);
                    numberField = microform.field('number');
                    monthField = microform.field('expirationMonth');
                    yearField = microform.field('expirationYear');
                    cvvField = microform.field('securityCode');
                }

                numberField.load('#cardNumber');
                monthField.load('#expirationMonth');
                yearField.load('#expirationYear');
                cvvField.load('#securityCode');
                
                status.textContent = 'SUCCESS: Fields loaded!';
                status.style.color = 'green';
                
            } catch (error) {
                status.textContent = 'ERROR: ' + error.message;
                status.style.color = 'red';
            }
        }, 1000);
    </script>
</body>
</html>
    ''');
  }
}