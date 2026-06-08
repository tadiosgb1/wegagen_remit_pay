# 🔄 Microform Communication Flow Summary

## Overview
This document outlines the complete communication flow between the Flutter frontend and backend for CyberSource microform integration.

## 📱 Frontend Flow (Flutter)

### 1. Payment Screen Navigation
```
PaymentScreen → BillingInfoScreen → PaymentMobileOptimizedScreen
```

### 2. Mobile Payment Screen (`PaymentMobileOptimizedScreen`)
- **Purpose**: Loads the backend payment page in a WebView
- **Authentication**: Automatically includes Bearer token from SharedPreferences
- **URL**: `${Environment.baseUrl}/payment-page`
- **Communication**: Uses JavaScript channels for payment result handling

### 3. Key Components:
- **WebViewController**: Handles page loading and JavaScript communication
- **JavaScript Channel**: `PaymentResult` - receives payment tokens from the HTML page
- **Error Handling**: Comprehensive error states and retry mechanisms
- **Security**: SSL certificate handling for development environments

## 🖥️ Backend Flow (Node.js/NestJS)

### 1. Payment Page Controller (`/payment-page`)
- **Authentication**: Protected by `AuthGuard`
- **Response**: Returns complete HTML page with embedded CyberSource microform
- **Headers**: Proper mobile WebView compatibility headers

### 2. Capture Context Generation (`/payments/generate-capture-context`)
- **Purpose**: Generates CyberSource capture context JWT token
- **Security**: Includes proper target origins for mobile apps
- **Response**: JWT token for microform initialization

### 3. Payment Processing (`/payments/process-payment`)
- **Input**: Transient token from CyberSource + billing information
- **Processing**: Handles actual payment through CyberSource API
- **Response**: Payment result and transaction details

## 🔗 Communication Protocol

### 1. Initial Load
```
Mobile App → Backend /payment-page → HTML with Microform
```

### 2. Microform Initialization
```
HTML Page → CyberSource API → Secure Payment Fields
```

### 3. Payment Token Creation
```
User Input → CyberSource Microform → Payment Token → Mobile App
```

### 4. Payment Processing
```
Mobile App → Backend /payments/process-payment → CyberSource API → Result
```

## 🛡️ Security Features

### Frontend Security:
- Bearer token authentication
- SSL certificate validation (configurable for dev)
- Secure WebView configuration
- Input validation and sanitization

### Backend Security:
- JWT-based authentication
- CORS configuration for mobile origins
- Secure headers for WebView compatibility
- CyberSource secure tokenization

## 🔧 Configuration

### Environment Variables:
```dart
// Flutter (lib/config/environment.dart)
static const String _baseUrl = 'https://10.195.49.18:3001';
```

### Backend Headers:
```typescript
// Proper mobile WebView headers
res.setHeader('X-Frame-Options', 'ALLOWALL');
res.setHeader('Content-Security-Policy', "frame-ancestors *");
```

### Mobile Origins (Backend):
```typescript
// Add mobile app origins to CyberSource configuration
request.targetOrigins = [
  'https://appassets.androidplatform.net',
  'file://',
  'http://localhost:3000',
  'https://10.195.49.18:3001'
];
```

## 📋 Testing Checklist

### ✅ Frontend Tests:
- [ ] WebView loads payment page successfully
- [ ] JavaScript communication works
- [ ] Authentication token is sent correctly
- [ ] Error handling displays properly
- [ ] Payment token is received and processed

### ✅ Backend Tests:
- [ ] `/payment-page` returns valid HTML
- [ ] `/payments/generate-capture-context` returns valid JWT
- [ ] CyberSource microform initializes correctly
- [ ] Payment processing works end-to-end
- [ ] Mobile origins are properly configured

## 🐛 Common Issues & Solutions

### Issue 1: White Page in Mobile WebView
**Cause**: Missing authentication or CORS issues
**Solution**: Ensure Bearer token is included and mobile origins are configured

### Issue 2: Microform Not Loading
**Cause**: Invalid capture context or missing CyberSource script
**Solution**: Verify capture context generation and script loading

### Issue 3: JavaScript Communication Fails
**Cause**: Missing JavaScript channels or incorrect message format
**Solution**: Verify `PaymentResult` channel setup and message structure

### Issue 4: SSL Certificate Errors
**Cause**: Self-signed certificates in development
**Solution**: Configure `badCertificateCallback` for development builds

## 🚀 Deployment Notes

### Development:
- Use self-signed SSL certificates
- Enable debug logging
- Configure mobile origins for local testing

### Production:
- Use valid SSL certificates
- Disable debug logging
- Configure production mobile origins
- Enable proper CORS policies

## 📞 API Endpoints Summary

| Endpoint | Method | Purpose | Authentication |
|----------|--------|---------|----------------|
| `/payment-page` | GET | Returns microform HTML | Required |
| `/payments/generate-capture-context` | POST | Creates CyberSource context | Required |
| `/payments/process-payment` | POST | Processes payment | Required |

## 🔄 Data Flow Diagram

```
[Mobile App] 
    ↓ (Bearer Token)
[Backend /payment-page] 
    ↓ (HTML + Capture Context)
[WebView with Microform] 
    ↓ (User Input)
[CyberSource API] 
    ↓ (Payment Token)
[Mobile App via JS Channel] 
    ↓ (Token + Billing Info)
[Backend /payments/process-payment] 
    ↓ (Payment Result)
[Success/Error Screen]
```

This flow ensures secure, seamless payment processing with proper error handling and user feedback at each step.