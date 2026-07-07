import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import '../../services/three_ds_service.dart';
import 'payment_processing_screen.dart';

class ThreeDSAuthScreen extends StatefulWidget {
  final EnrollmentCheckResult threeDSEnrollment;
  final String paymentToken;
  final double amount;
  final String currency;
  final Map<String, dynamic> billingInfo;
  final Map<String, dynamic> recipientInfo;
  final String? remark;

  const ThreeDSAuthScreen({
    super.key,
    required this.threeDSEnrollment,
    required this.paymentToken,
    required this.amount,
    required this.currency,
    required this.billingInfo,
    required this.recipientInfo,
    this.remark,
  });

  @override
  State<ThreeDSAuthScreen> createState() => _ThreeDSAuthScreenState();
}

class _ThreeDSAuthScreenState extends State<ThreeDSAuthScreen> {
  late WebViewController _webViewController;
  final ThreeDSService _threeDSService = ThreeDSService();
  
  bool _isLoading = true;
  bool _authCompleted = false;
  String? _error;
  Timer? _statusTimer;
  int _timeoutSeconds = 600; // 10 minutes timeout
  late Timer _timeoutTimer;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
    _startAuthTimeout();
    _startStatusPolling();
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    _timeoutTimer.cancel();
    super.dispose();
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

    _webViewController = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000));

    if (_webViewController.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (_webViewController.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    _webViewController.setNavigationDelegate(
      NavigationDelegate(
        onPageStarted: (String url) {
          debugPrint('🔐 3DS Page started loading: $url');
          setState(() => _isLoading = true);
        },
        onPageFinished: (String url) {
          debugPrint('🔐 3DS Page finished loading: $url');
          setState(() => _isLoading = false);
          
          // Check if this is a completion URL
          if (url.contains('3ds/return') || url.contains('payments/return') || 
              url.contains('success') || url.contains('complete')) {
            _handleAuthReturn(url);
          }
        },
        onNavigationRequest: (NavigationRequest request) {
          debugPrint('🔐 3DS Navigation request: ${request.url}');
          
          // Allow all authentication-related URLs
          return NavigationDecision.navigate;
        },
        onWebResourceError: (WebResourceError error) {
          debugPrint('🔐 3DS WebView error: ${error.description}');
          setState(() {
            _error = 'Authentication failed: ${error.description}';
            _isLoading = false;
          });
        },
      ),
    );

    // Load the 3DS challenge URL - use stepUpUrl from your backend
    if (widget.threeDSEnrollment.stepUpUrl != null) {
      debugPrint('🔐 Loading stepUpUrl: ${widget.threeDSEnrollment.stepUpUrl}');
      _webViewController.loadRequest(Uri.parse(widget.threeDSEnrollment.stepUpUrl!));
    } else if (widget.threeDSEnrollment.acsUrl != null) {
      // Fallback to traditional ACS flow if stepUpUrl not available
      _load3DSForm();
    } else {
      setState(() {
        _error = 'Invalid 3DS authentication data - no stepUpUrl or acsUrl';
        _isLoading = false;
      });
    }
  }

  void _load3DSForm() {
    final html = _build3DSForm();
    final dataUri = Uri.dataFromString(
      html,
      mimeType: 'text/html',
      encoding: Encoding.getByName('utf-8'),
    );
    _webViewController.loadRequest(dataUri);
  }

  String _build3DSForm() {
    return '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>3D Secure Authentication</title>
    <style>
        body {
            font-family: system-ui, -apple-system, sans-serif;
            margin: 0;
            padding: 20px;
            background: #f5f5f5;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
        }
        .container {
            background: white;
            padding: 30px;
            border-radius: 12px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.1);
            text-align: center;
            max-width: 400px;
            width: 100%;
        }
        .spinner {
            border: 3px solid #f3f3f3;
            border-top: 3px solid #F37021;
            border-radius: 50%;
            width: 30px;
            height: 30px;
            animation: spin 1s linear infinite;
            margin: 20px auto;
        }
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
        h2 { color: #333; margin-bottom: 20px; }
        p { color: #666; line-height: 1.5; }
        .security-icon { font-size: 48px; margin-bottom: 20px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="security-icon">🔐</div>
        <h2>3D Secure Authentication</h2>
        <p>Redirecting to your bank for secure authentication...</p>
        <div class="spinner"></div>
        <p><small>This may take a few seconds</small></p>
    </div>
    
    <form id="threeDSForm" action="${widget.threeDSEnrollment.acsUrl}" method="POST" style="display: none;">
        <input type="hidden" name="PaReq" value="${widget.threeDSEnrollment.paReq ?? ''}">
        <input type="hidden" name="TermUrl" value="https://cybersource.wegagenbanksc.com.et:3001/payments/3ds/return">
    </form>
    
    <script>
        console.log('3DS Form loaded, submitting...');
        setTimeout(function() {
            document.getElementById('threeDSForm').submit();
        }, 1000);
    </script>
</body>
</html>
    ''';
  }

  void _startAuthTimeout() {
    _timeoutTimer = Timer(Duration(seconds: _timeoutSeconds), () {
      if (!_authCompleted && mounted) {
        setState(() {
          _error = 'Authentication timeout. Please try again.';
          _isLoading = false;
        });
        _statusTimer?.cancel();
      }
    });
  }

  void _startStatusPolling() {
    if (widget.threeDSEnrollment.authenticationTransactionId == null) return;
    
    _statusTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (_authCompleted || !mounted) {
        timer.cancel();
        return;
      }

      try {
        final authResult = await _threeDSService.getAuthenticationResults(
          customerId: 'CUSTOMER_ID', // You'll need to pass this from payment processing
          authenticationTransactionId: widget.threeDSEnrollment.authenticationTransactionId!,
          amount: widget.amount,
          currency: widget.currency,
        );
        
        if (authResult.success && (authResult.isAuthenticated || authResult.isAttempted)) {
          timer.cancel();
          _handleAuthComplete(authResult);
        }
      } catch (e) {
        debugPrint('🔐 Status polling error: $e');
        // Continue polling unless it's a critical error
      }
    });
  }

  void _handleAuthReturn(String url) {
    debugPrint('🔐 3DS Auth return URL: $url');
    
    // Parse return parameters
    final uri = Uri.parse(url);
    final paRes = uri.queryParameters['PaRes'];
    final md = uri.queryParameters['MD'];
    
    if (paRes != null && md != null) {
      // Authentication completed, proceed to payment
      _proceedToPayment(null);
    } else {
      // Check status via polling if no direct parameters
      _statusTimer?.cancel();
      _startStatusPolling();
    }
  }

  void _handleAuthComplete(ThreeDSAuthResult authResult) {
    setState(() => _authCompleted = true);
    
    if (authResult.isAuthenticated || authResult.isAttempted) {
      _proceedToPayment(authResult);
    } else {
      setState(() {
        _error = authResult.message ?? 'Authentication failed. Please try again.';
        _isLoading = false;
      });
    }
  }

  void _proceedToPayment(ThreeDSAuthResult? threeDSResult) {
    if (!mounted) return;
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => PaymentProcessingScreen(
          paymentToken: widget.paymentToken,
          amount: widget.amount,
          currency: widget.currency,
          billingInfo: widget.billingInfo,
          recipientInfo: widget.recipientInfo,
          remark: widget.remark,
          threeDSResult: threeDSResult,
          transactionId: widget.threeDSEnrollment.transactionId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF37021),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('3D Secure Authentication'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            _showCancelDialog();
          },
        ),
      ),
      body: _error != null
          ? _buildErrorView()
          : Stack(
              children: [
                WebViewWidget(controller: _webViewController),
                if (_isLoading) _buildLoadingOverlay(),
              ],
            ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.security,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              '3D Secure Authentication Failed',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              _error!,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade600,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _error = null;
                      _isLoading = true;
                    });
                    _initializeWebView();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF37021),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.white.withValues(alpha: 0.9),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Color(0xFFF37021),
              strokeWidth: 3,
            ),
            SizedBox(height: 16),
            Text(
              '3D Secure Authentication',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Please complete the authentication\nwith your bank',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Authentication'),
        content: const Text(
          'Are you sure you want to cancel the 3D Secure authentication? This will abort your payment.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Continue'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Close 3DS screen
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cancel Payment'),
          ),
        ],
      ),
    );
  }
}