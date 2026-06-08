# Cybersource Microform Fixes Applied

This document outlines the fixes applied to resolve Cybersource Flex Microform issues where card number and CVV fields were not loading properly in the mobile app WebView.

## Root Causes Identified

1. **Network Security Configuration**: Cybersource domains were not allowlisted in Android network security config
2. **WebView Configuration**: Missing proper JavaScript, DOM storage, and third-party content settings
3. **Content Security Policy**: Overly restrictive or misconfigured CSP headers
4. **Cybersource Script Version**: Using inconsistent or outdated script versions
5. **WebView Platform-Specific Settings**: Missing Android/iOS specific WebView configurations

## Fixes Applied

### 1. Android Network Security Configuration
**File**: `android/app/src/main/res/xml/network_security_config.xml`

```xml
<!-- Added Cybersource domains allowlist -->
<domain-config cleartextTrafficPermitted="false">
    <domain includeSubdomains="true">testflex.cybersource.com</domain>
    <domain includeSubdomains="true">flex.cybersource.com</domain>
    <domain includeSubdomains="true">cybersource.com</domain>
    <trust-anchors>
        <certificates src="system"/>
    </trust-anchors>
</domain-config>
```

**Purpose**: Ensures Android WebView can access Cybersource domains over HTTPS without blocking.

### 2. Enhanced WebView Configuration 
**File**: `lib/screens/payment/payment_mobile_optimized_screen.dart`

Key improvements:
- Added platform-specific WebView controller creation
- Enabled JavaScript debugging for Android
- Configured proper media playback settings
- Added multiple JavaScript channels for communication
- Improved error handling and navigation delegate
- Updated to use proper WebView platform packages

```dart
// Platform-specific WebView settings
if (WebViewPlatform.instance is WebKitWebViewPlatform) {
    params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
    );
}

// Android-specific configurations
if (controller.platform is AndroidWebViewController) {
    AndroidWebViewController.enableDebugging(true);
    (controller.platform as AndroidWebViewController).setMediaPlaybackRequiresUserGesture(false);
}
```

### 3. Updated Dependencies
**File**: `pubspec.yaml`

Added platform-specific WebView packages:
```yaml
webview_flutter: ^4.4.4
webview_flutter_android: ^3.12.1
webview_flutter_wkwebview: ^3.9.4
webview_flutter_web: ^0.2.2+4
```

### 4. Improved HTML Payment Form
**File**: `assets/payment/index.html`

Major improvements:
- Updated to Cybersource Flex Microform v2.0 (latest stable)
- Optimized Content Security Policy for mobile WebViews
- Enhanced field styling and container visibility
- Improved error handling and user feedback
- Added proper field loading validation
- Multiple communication channels with Flutter
- Better responsive design for mobile screens

Key features:
```javascript
// Updated Cybersource script URL
<script src="https://testflex.cybersource.com/microform/bundle/v2.0/flex-microform.min.js"></script>

// Proper field configuration with styling
const numberField = microformInstance.createField('number', {
    placeholder: '•••• •••• •••• ••••',
    styles: {
        'input': {
            'font-size': '16px',
            'font-family': 'system-ui, -apple-system, sans-serif',
            'color': '#1f2937',
            'border': 'none',
            'outline': 'none',
            'padding': '16px 12px',
            'width': '100%',
            'box-sizing': 'border-box'
        }
    }
});
```

### 5. Android Build Configuration
**File**: `android/app/build.gradle`

```gradle
defaultConfig {
    // Enable cleartext traffic for development
    manifestPlaceholders = [usesCleartextTraffic: "true"]
}
```

## Verification Checklist

To verify the fixes work correctly:

### ✅ Pre-flight Checks
- [ ] Internet connection is active
- [ ] Backend API is running and accessible
- [ ] Capture context endpoint returns valid JWT
- [ ] No firewall/proxy blocking Cybersource domains

### ✅ WebView Checks  
- [ ] JavaScript is enabled (`JavaScriptMode.unrestricted`)
- [ ] DOM storage is enabled (default in Flutter WebView)
- [ ] Third-party iframes/scripts are allowed
- [ ] Network security config allows Cybersource domains
- [ ] CSP headers allow necessary script-src and frame-src

### ✅ Cybersource Configuration
- [ ] Using correct Cybersource environment (testflex vs flex)
- [ ] Capture context JWT is valid and not expired
- [ ] Capture context matches the domain/origin
- [ ] Microform script loads successfully
- [ ] Card number and CVV containers have visible dimensions

### ✅ Visual Verification
- [ ] Card number field appears and accepts input
- [ ] CVV field appears and accepts input  
- [ ] Expiration dropdowns are populated
- [ ] Form styling renders correctly
- [ ] Error messages display when appropriate
- [ ] Success flow communicates back to Flutter

## Testing Commands

```bash
# Install dependencies
flutter pub get

# Run on Android device/emulator
flutter run

# Build APK for testing
flutter build apk --debug

# Check WebView logs
adb logcat | grep -i "WebView\|Cybersource"
```

## Common Issues & Solutions

### Issue: "Fields appear blank or blocked"
**Solution**: Check network security config and CSP headers

### Issue: "JavaScript errors in console"
**Solution**: Verify Cybersource script URL and capture context validity

### Issue: "Token creation fails"
**Solution**: Ensure expiration month/year are provided and fields contain valid data

### Issue: "WebView communication fails"
**Solution**: Verify JavaScript channels are properly configured and message passing works

## Security Notes

1. **Production Environment**: Update script URLs to production Cybersource domains
2. **Capture Context**: Ensure capture context is generated server-side with proper security
3. **Token Handling**: Never store payment tokens in app storage
4. **Network Security**: Use proper SSL certificates in production
5. **CSP Policy**: Tighten CSP in production to only allow necessary domains

## Next Steps

1. Test on physical Android devices
2. Test on iOS devices (may need similar WKWebView configurations)
3. Update backend to generate valid capture context
4. Implement proper token handling and payment processing
5. Add proper error handling for network failures
6. Consider implementing payment flow timeout handling

---
*Last Updated: December 2024*
*Cybersource Flex Microform Version: v2.0*