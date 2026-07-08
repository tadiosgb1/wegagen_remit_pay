import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ThreeDSChallengeScreen extends StatefulWidget {
  final String stepUpUrl;
  final String accessToken;
  final String? merchantData;
  final VoidCallback onCompleted;

  const ThreeDSChallengeScreen({
    Key? key,
    required this.stepUpUrl,
    required this.accessToken,
    this.merchantData,
    required this.onCompleted,
  }) : super(key: key);

  @override
  State<ThreeDSChallengeScreen> createState() => _ThreeDSChallengeScreenState();
}

class _ThreeDSChallengeScreenState extends State<ThreeDSChallengeScreen> {
  late WebViewController controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            print('🔐 3DS Challenge page started loading: $url');
          },
          onPageFinished: (String url) {
            print('🔐 3DS Challenge page finished loading: $url');
            setState(() {
              isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            print('🔐 3DS Challenge WebView error: ${error.description}');
          },
        ),
      )
      ..addJavaScriptChannel(
        '3DSComplete',
        onMessageReceived: (JavaScriptMessage message) {
          print('🔐 3DS Challenge completion message: ${message.message}');
          if (message.message == '3DS_CHALLENGE_COMPLETE') {
            widget.onCompleted();
          }
        },
      );

    _loadChallengeForm();
  }

  void _loadChallengeForm() {
    // Create the HTML form that matches the Vue.js implementation
    final html = '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>3D Secure Authentication</title>
    <style>
        body {
            margin: 0;
            padding: 0;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
            background: #f5f5f5;
        }
        
        .challenge-header {
            background: #1a237e;
            color: #fff;
            padding: 20px 24px 16px;
            text-align: center;
        }
        
        .bank-logo {
            font-size: 14px;
            opacity: 0.8;
            margin-bottom: 8px;
        }
        
        .challenge-title {
            font-size: 20px;
            font-weight: 600;
            margin: 0 0 6px;
        }
        
        .challenge-subtitle {
            font-size: 13px;
            opacity: 0.85;
            margin: 0;
        }
        
        .challenge-iframe-wrapper {
            background: #fff;
            min-height: 400px;
            display: flex;
            justify-content: center;
            align-items: center;
        }
        
        .challenge-iframe {
            border: none;
            width: 100%;
            height: 400px;
            min-height: 400px;
        }
        
        .challenge-footer {
            padding: 16px 24px;
            text-align: center;
            background: #fff;
            border-top: 1px solid #e0e0e0;
        }
        
        .security-badge {
            font-size: 12px;
            color: #2e7d32;
            font-weight: 600;
            margin-bottom: 8px;
        }
        
        .challenge-hint {
            font-size: 12px;
            color: #757575;
            margin: 0;
        }
        
        .loading {
            text-align: center;
            padding: 40px;
            color: #666;
        }
    </style>
</head>
<body>
    <div class="challenge-header">
        <div class="bank-logo">🏦 Wegagen Bank</div>
        <h2 class="challenge-title">Verify Your Identity</h2>
        <p class="challenge-subtitle">
            Your bank requires additional verification to complete this payment.
        </p>
    </div>
    
    <div class="challenge-iframe-wrapper">
        <iframe
            id="step-up-iframe"
            name="stepUpIframe"
            class="challenge-iframe"
            title="Bank authentication"
            sandbox="allow-forms allow-scripts allow-same-origin allow-top-navigation allow-popups"
        ></iframe>
        
        <form
            id="step-up-form"
            method="POST"
            target="stepUpIframe"
            action="${widget.stepUpUrl}"
            style="display: none;"
        >
            <input type="hidden" name="JWT" value="${widget.accessToken}" />
            <input type="hidden" name="MD" value="${widget.merchantData ?? ''}" />
        </form>
    </div>
    
    <div class="challenge-footer">
        <div class="security-badge">
            🔒 Secured by 3D Secure 2.0 — Visa / Mastercard
        </div>
        <p class="challenge-hint">
            Please complete the verification in the window above.
            Do not close this page.
        </p>
    </div>
    
    <script>
        // Submit the form automatically when page loads
        window.addEventListener('load', function() {
            const form = document.getElementById('step-up-form');
            if (form) {
                console.log('🔐 Submitting 3DS challenge form to: ${widget.stepUpUrl}');
                form.submit();
            }
        });
        
        // Listen for completion messages from ACS iframe and backend /3ds/return endpoint
        window.addEventListener('message', function(event) {
            console.log('🔐 Received message from ACS or backend:', event.data);
            
            // Listen for completion from your backend /3ds/return endpoint
            if (event.data === '3DS_CHALLENGE_COMPLETE' || 
                event.data === 'authentication_complete' ||
                event.data === 'AUTHENTICATION_COMPLETE' ||
                (typeof event.data === 'string' && (
                    event.data.includes('COMPLETE') ||
                    event.data.includes('SUCCESS') ||
                    event.data.includes('AUTHENTICATED')
                ))) {
                
                console.log('🔐 3DS Challenge completion detected from backend!');
                console.log('🎯 Message received: ' + event.data);
                
                // Wait 1 second to ensure completion, then notify Flutter
                setTimeout(function() {
                    console.log('🔐 Notifying Flutter app of 3DS completion');
                    if (window['3DSComplete']) {
                        window['3DSComplete'].postMessage('3DS_CHALLENGE_COMPLETE');
                    }
                }, 1000); // 1 second delay
            } else {
                console.log('🔍 Non-completion message ignored: ' + event.data);
            }
        });
        
        // Log that we're relying on backend completion detection
        console.log('🔐 Relying on backend /3ds/return endpoint for completion detection');
        console.log('🔗 Backend endpoint will send 3DS_CHALLENGE_COMPLETE message');
        
        // Add manual completion button as backup - show after 10 seconds
        setTimeout(function() {
            console.log('🔐 Adding manual completion button as backup');
            const button = document.createElement('button');
            button.innerHTML = '';
            button.style.cssText = \`
                position: fixed !important;
                bottom: 20px !important;
                right: 20px !important;
                background: #4CAF50 !important;
                color: white !important;
                border: none !important;
                padding: 15px 25px !important;
                border-radius: 8px !important;
                font-size: 16px !important;
                font-weight: bold !important;
                cursor: pointer !important;
                z-index: 99999 !important;
                box-shadow: 0 4px 8px rgba(0,0,0,0.3) !important;
            \`;
            button.onclick = function() {
                console.log('🔐 Manual completion triggered by user');
                if (confirm('Did you complete the OTP verification successfully?')) {
                    console.log('🔐 User confirmed OTP completion - sending completion signal');
                    if (window['3DSComplete']) {
                        window['3DSComplete'].postMessage('3DS_CHALLENGE_COMPLETE');
                    }
                } else {
                    console.log('🔐 User cancelled manual completion');
                }
            };
            document.body.appendChild(button);
            console.log('🔐 Manual completion button added successfully');
        }, 10000); // Show button after 10 seconds
        
        // Handle iframe load events
        const iframe = document.getElementById('step-up-iframe');
        if (iframe) {
            iframe.addEventListener('load', function() {
                console.log('🔐 3DS Challenge iframe loaded');
            });
        }
    </script>
</body>
</html>
    ''';

    controller.loadHtmlString(html);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Prevent accidental back button presses during OTP entry
        debugPrint('🔐 Back button pressed during 3DS challenge - showing confirmation');
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Cancel 3D Secure Verification?'),
            content: const Text('Are you sure you want to cancel the payment verification? This will cancel your payment.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Stay'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Cancel Payment', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
        return shouldPop ?? false;
      },
      child: Scaffold(
        backgroundColor: Colors.black54,
        body: SafeArea(
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header with close button
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: const BoxDecoration(
                        color: Color(0xFF1A237E),
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              '3D Secure Authentication',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              // Show confirmation before closing
                              final shouldClose = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Cancel Verification?'),
                                  content: const Text('This will cancel your payment. Are you sure?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(false),
                                      child: const Text('Continue Verification'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(true),
                                      child: const Text('Cancel Payment', style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );
                              if (shouldClose == true) {
                                Navigator.of(context).pop();
                              }
                            },
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // WebView content
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: Stack(
                        children: [
                          WebViewWidget(controller: controller),
                          if (isLoading)
                            const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFF1A237E),
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Loading verification...',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Please wait while we prepare the OTP verification',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}