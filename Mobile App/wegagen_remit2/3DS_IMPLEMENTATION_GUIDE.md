# 3D Secure (3DS) Implementation Guide for Wegagen Remit

## Overview
This guide explains how 3D Secure authentication has been implemented in the Wegagen Remit Flutter app. 3D Secure adds an extra layer of security for card payments by requiring additional authentication from the cardholder's bank.

## What's Been Implemented

### 1. 3DS Service Layer (`lib/services/three_ds_service.dart`)
- **ThreeDSService**: Main service class that handles all 3DS operations
- **API Methods**:
  - `initiate3DSAuth()`: Starts the 3DS authentication process
  - `check3DSStatus()`: Polls authentication status during challenge
  - `complete3DSAuth()`: Completes authentication after challenge
  - `processPaymentWith3DS()`: Main payment processing method

### 2. 3DS Authentication Screen (`lib/screens/payment/three_ds_auth_screen.dart`)
- **WebView-based 3DS Challenge**: Handles bank authentication pages
- **Status Polling**: Monitors authentication progress
- **Timeout Management**: 10-minute timeout for user authentication
- **Error Handling**: Comprehensive error handling and retry logic

### 3. Enhanced Payment Processing (`lib/screens/payment/payment_processing_screen.dart`)
- **Integrated 3DS Flow**: Seamlessly handles 3DS requirements
- **Progress Tracking**: Visual progress indicators for users
- **Fallback Support**: Handles both 3DS and non-3DS transactions

### 4. UI Components
- **ThreeDSInfoWidget**: Shows 3DS security information to users
- **Enhanced Payment Forms**: Updated to indicate 3DS protection

## Backend Requirements

### Required API Endpoints
Add these endpoints to your backend (`lib/config/url_container.dart`):

```dart
// 3DS Authentication endpoints
static String get initiate3DS => '$baseUrl/payments/3ds/initiate';
static String get check3DSStatus => '$baseUrl/payments/3ds/status';
static String get complete3DS => '$baseUrl/payments/3ds/complete';
static String get processPaymentWith3DS => '$baseUrl/payments/process-with-3ds';
```

### Backend Implementation Examples

#### 1. Generate Capture Context with 3DS
```javascript
// POST /payments/generate-capture-context
app.post('/payments/generate-capture-context', (req, res) => {
  const captureContext = {
    // Your Cybersource configuration
    enable_3ds: true,
    challenge_window_size: '02', // 390x400
    return_url: 'https://your-domain.com/payments/3ds/return'
  };
  
  res.json({ captureContext });
});
```

#### 2. Initiate 3DS Authentication
```javascript
// POST /payments/3ds/initiate
app.post('/payments/3ds/initiate', async (req, res) => {
  const { payment_token, amount, currency, billing_info } = req.body;
  
  try {
    // Call Cybersource 3DS authentication API
    const authResponse = await cybersourceAPI.initiate3DS({
      paymentToken: payment_token,
      amount,
      currency,
      billingInfo: billing_info,
      returnUrl: 'https://your-domain.com/payments/3ds/return',
      notificationUrl: 'https://your-domain.com/payments/3ds/webhook'
    });
    
    res.json({
      success: true,
      transaction_id: authResponse.transactionId,
      requires_3ds: authResponse.requires3DS,
      acs_url: authResponse.acsUrl,
      pa_req: authResponse.paReq,
      md: authResponse.md,
      term_url: authResponse.termUrl
    });
  } catch (error) {
    res.status(400).json({
      success: false,
      error: error.message
    });
  }
});
```

#### 3. Check 3DS Status
```javascript
// GET /payments/3ds/status/:transactionId
app.get('/payments/3ds/status/:transactionId', async (req, res) => {
  const { transactionId } = req.params;
  
  try {
    const status = await cybersourceAPI.check3DSStatus(transactionId);
    
    res.json({
      status: status.authenticationStatus, // pending, authenticated, failed
      is_complete: status.isComplete,
      auth_result: status.authResult,
      last_update: new Date().toISOString()
    });
  } catch (error) {
    res.status(400).json({
      success: false,
      error: error.message
    });
  }
});
```

## How It Works

### 1. Payment Flow with 3DS
```
User fills payment form
        ↓
Cybersource generates token
        ↓
App calls processPaymentWith3DS()
        ↓
Backend checks if 3DS required
        ↓
If 3DS required:
  → Navigate to ThreeDSAuthScreen
  → User completes bank authentication
  → Return to payment processing
        ↓
Payment completed
```

### 2. 3DS Challenge Flow
```
3DS Challenge Required
        ↓
Load bank's authentication page in WebView
        ↓
User enters additional authentication (SMS, app, etc.)
        ↓
Bank returns authentication result
        ↓
App processes result and completes payment
```

## Configuration

### 1. Update pubspec.yaml
Ensure you have the required dependencies:
```yaml
dependencies:
  webview_flutter: ^4.4.2
  webview_flutter_android: ^3.12.1
  webview_flutter_wkwebview: ^3.9.4
```

### 2. Android Configuration
Update `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

### 3. iOS Configuration
Update `ios/Runner/Info.plist`:
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

## Usage Examples

### 1. Basic 3DS Payment
```dart
// In your payment processing
final threeDSService = ThreeDSService();

final paymentResult = await threeDSService.processPaymentWith3DS(
  paymentToken: token,
  amount: 100.00,
  currency: 'USD',
  billingInfo: billingData,
  recipientInfo: recipientData,
  remark: 'Payment for services',
);

if (paymentResult.needsAuthentication) {
  // Navigate to 3DS authentication screen
  Navigator.push(context, MaterialPageRoute(
    builder: (context) => ThreeDSAuthScreen(
      threeDSAuth: paymentResult.threeDSAuth!,
      paymentToken: token,
      // ... other parameters
    ),
  ));
}
```

### 2. Show 3DS Information
```dart
// Display 3DS security info to users
ThreeDSInfoWidget(
  is3DSEnabled: true,
  status: 'authenticated',
  onLearnMore: () {
    // Show 3DS explanation dialog
  },
)
```

## Testing 3DS

### Test Cards for 3DS
Use these test card numbers to simulate different 3DS scenarios:

- **3DS Authentication Required**: 4000000000001091
- **3DS Not Enrolled**: 4000000000001109  
- **3DS Authentication Failed**: 4000000000001125

### Test Flow
1. Use test card numbers in the payment form
2. Complete the simulated 3DS challenge
3. Verify the payment processes correctly

## Security Best Practices

### 1. Backend Security
- Validate all 3DS responses on the backend
- Use HTTPS for all 3DS communication
- Implement proper session management
- Log all 3DS transactions for audit

### 2. App Security
- Never store sensitive authentication data
- Use secure WebView configurations
- Implement proper timeout handling
- Validate 3DS results before proceeding

## Troubleshooting

### Common Issues

1. **WebView not loading 3DS page**
   - Check internet connectivity
   - Verify 3DS URL is accessible
   - Check CSP headers in HTML

2. **3DS timeout**
   - Default timeout is 10 minutes
   - Check if user is completing authentication
   - Verify backend 3DS status polling

3. **Authentication loop**
   - Check return URL configuration
   - Verify 3DS completion logic
   - Check for proper status polling

### Debug Mode
Enable debug logging by setting:
```dart
if (kDebugMode) {
  print('3DS Debug: $debugMessage');
}
```

## Production Deployment

### Checklist
- [ ] Configure production Cybersource credentials
- [ ] Update return URLs to production domains
- [ ] Test with real bank 3DS challenges
- [ ] Verify SSL certificate configuration
- [ ] Test timeout and error scenarios
- [ ] Enable production logging

### Monitoring
Monitor these metrics in production:
- 3DS authentication success rate
- Average authentication time
- Timeout occurrences
- Error rates by bank/card type

## Additional Resources

- [Cybersource 3DS Documentation](https://developer.cybersource.com)
- [EMVCo 3DS Specification](https://www.emvco.com/emv-technologies/3d-secure/)
- [Flutter WebView Documentation](https://pub.dev/packages/webview_flutter)

## Support
For implementation questions or issues, check:
1. This documentation
2. Cybersource developer resources  
3. Flutter WebView package documentation
4. Your backend API logs for 3DS transactions