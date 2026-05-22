# 📱 Mobile Origin Detection Guide for CyberSource

## 🎯 **The Problem**

Your backend currently has:
```typescript
request.targetOrigins = ['http://localhost:3000'];
```

But mobile APKs don't run on `localhost:3000` - they use different origins that need to be detected and configured.

## 🔍 **How to Find Your Mobile APK's Origin**

### **Step 1: Use the Debug Screen**

I've created a special debug screen (`PaymentDebugMobileScreen`) that will automatically detect your mobile app's origin.

1. **Build and install your APK**:
   ```bash
   flutter build apk --debug
   flutter install
   ```

2. **Navigate to payment flow** in your mobile app
3. **Fill billing information** and tap "Continue to Payment"
4. **The debug screen will automatically detect** your mobile origin

### **Step 2: Read the Debug Information**

The debug screen will show you something like:

```
=== MOBILE ORIGIN DETECTION ===
Origin: file://
Full URL: file:///android_asset/flutter_assets/...
Protocol: file:
Host: 
Hostname: 
Port: 
Path: /android_asset/flutter_assets/...
User Agent: Mozilla/5.0 (Linux; Android 10; ...)

=== BACKEND CONFIGURATION ===
Add this to your backend payments.service.ts:

request.targetOrigins = [
  'file://',
  'http://localhost:3000',
  'http://10.195.49.18:3001',
  'https://10.195.49.18:3001'
];
```

## 🔧 **Common Mobile Origins**

### **Flutter Mobile Apps typically use:**

1. **`file://`** - Most common for Flutter mobile apps
2. **`https://appassets.androidplatform.net`** - Android WebView assets
3. **`capacitor://localhost`** - If using Capacitor
4. **`ionic://localhost`** - If using Ionic
5. **`app://localhost`** - Some hybrid frameworks

### **Your Backend Configuration Should Include:**

```typescript
// In backend/src/payments/payments.service.ts
request.targetOrigins = [
  'file://',                           // Mobile APK (most likely)
  'https://appassets.androidplatform.net', // Android WebView
  'http://localhost:3000',             // Web development
  'http://10.195.49.18:3001',         // Your backend IP
  'https://10.195.49.18:3001'         // Your backend IP (HTTPS)
];
```

## 🧪 **Testing Process**

### **Step 1: Build APK with Debug Screen**
```bash
# Clean and build
flutter clean
flutter pub get
flutter build apk --debug

# Install on device
flutter install
```

### **Step 2: Run Debug Detection**
1. Open your app
2. Navigate to payment flow
3. Fill billing information
4. Tap "Continue to Payment"
5. **Debug screen will show your mobile origin**

### **Step 3: Update Backend**
Copy the detected origin and add it to your backend:

```typescript
// In backend/src/payments/payments.service.ts
async generateCaptureContext() {
  // ... existing code ...
  
  request.targetOrigins = [
    'YOUR_DETECTED_ORIGIN_HERE',  // Add the detected origin
    'http://localhost:3000',
    'http://10.195.49.18:3001',
    'https://10.195.49.18:3001'
  ];
  
  // ... rest of method
}
```

### **Step 4: Test CyberSource Connection**
The debug screen has a "Test CyberSource Connection" button that will:
- ✅ Load CyberSource script
- ✅ Test Flex library availability  
- ✅ Test capture context validity
- ✅ Test microform creation

## 🔍 **Manual Detection Methods**

### **Method 1: WebView Console Logs**
```bash
# Connect device and check logs
adb logcat | grep -i "origin\|cybersource\|microform"
```

### **Method 2: Add Debug JavaScript**
Add this to your WebView HTML:
```javascript
console.log('Mobile Origin:', window.location.origin);
console.log('Mobile URL:', window.location.href);
console.log('Mobile Protocol:', window.location.protocol);
```

### **Method 3: Flutter Debug Prints**
Add debug prints in your WebView setup:
```dart
..setNavigationDelegate(
  NavigationDelegate(
    onPageFinished: (String url) {
      print('DEBUG: WebView URL: $url');
      _webViewController?.runJavaScript('''
        console.log('Origin:', window.location.origin);
      ''');
    },
  ),
)
```

## 🚨 **Common Issues & Solutions**

### **Issue 1: Origin shows as `file://`**
**Solution**: This is normal for Flutter mobile apps. Add `'file://'` to targetOrigins.

### **Issue 2: Origin shows as empty or null**
**Solution**: The WebView might not be fully loaded. Add multiple common origins:
```typescript
request.targetOrigins = [
  'file://',
  'https://appassets.androidplatform.net',
  'capacitor://localhost',
  'http://localhost:3000'
];
```

### **Issue 3: CyberSource still fails after adding origin**
**Solution**: 
1. Restart your backend server
2. Clear app cache/data
3. Rebuild and reinstall APK
4. Check backend logs for CORS errors

## 🔄 **Switch Back to Production Screen**

Once you've detected the origin and updated your backend:

1. **Update billing_info_screen.dart**:
```dart
// Change from debug screen back to production
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => kIsWeb 
        ? const PaymentWorkingScreen()
        : const PaymentMobileOptimizedScreen(), // Back to production
  ),
);
```

2. **Rebuild APK**:
```bash
flutter build apk --debug
flutter install
```

## 📊 **Expected Results**

### **After Correct Configuration:**
- ✅ Debug screen detects origin successfully
- ✅ CyberSource connection test passes
- ✅ Microform fields load and are interactive
- ✅ Payment token creation works
- ✅ Backend receives and processes payments

### **Success Indicators:**
1. **Origin Detection**: Shows valid origin (usually `file://`)
2. **CyberSource Test**: All green checkmarks
3. **Field Interaction**: Card number and CVV fields respond to touch
4. **Token Creation**: Payment tokens generated successfully

## 🎉 **Final Configuration Example**

Your final backend configuration should look like:

```typescript
// backend/src/payments/payments.service.ts
async generateCaptureContext() {
  console.log("Generating capture context...");
  return new Promise((resolve, reject) => {
    const apiClient = new cybersourceRestApi.ApiClient();
    const instance = new cybersourceRestApi.MicroformIntegrationApi(
      this.configObj,
      apiClient,
    );

    const request = new cybersourceRestApi.GenerateCaptureContextRequest();

    request.clientVersion = 'v2';
    request.allowedPaymentTypes = ['CARD'];
    request.allowedCardNetworks = ['VISA', 'MASTERCARD', 'AMEX'];

    // ✅ UPDATED: Include mobile origins
    request.targetOrigins = [
      'file://',                           // Mobile APK
      'https://appassets.androidplatform.net', // Android WebView
      'http://localhost:3000',             // Web development
      'http://10.195.49.18:3001',         // Your backend IP
      'https://10.195.49.18:3001'         // Your backend IP (HTTPS)
    ];

    console.log("Target origins:", request.targetOrigins);

    instance.generateCaptureContext(request, (error, data) => {
      if (error) {
        console.log("CyberSource error:", error);
        reject(error.response ? error.response.text : error.message);
      } else {
        console.log("Capture context generated successfully");
        resolve(data);
      }
    });
  });
}
```

The debug screen will help you identify the exact origin your mobile APK is using! 🚀