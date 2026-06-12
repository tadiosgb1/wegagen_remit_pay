# KYC Implementation Guide

## Overview
Your KYC (Know Your Customer) functionality has been fixed and enhanced to properly handle file uploads with HTTP-only cookie authentication.

## ✅ Fixed Issues

1. **File Upload Problem**: Files were not being uploaded because FormData was incorrectly converted to a regular map
2. **Missing Import**: `IOHttpClientAdapter` import was missing for SSL configuration
3. **Validation**: Added proper validation for required fields
4. **Error Handling**: Improved error messages and debugging

## 🚀 How to Use KYC

### 1. Basic KYC Submission

```dart
import 'package:image_picker/image_picker.dart';
import 'lib/services/kyc_service.dart';
import 'lib/models/kyc_data.dart';

// Create KYC data
final kycData = KycData(
  idType: 'passport',           // Required
  dob: '1990-01-01',           // Required
  address: '123 Main Street',   // Required
  city: 'New York',            // Required
  country: 'USA',              // Required
  idPhoto: idPhotoXFile,       // Required - XFile from ImagePicker
  selfie: selfieXFile,         // Required - XFile from ImagePicker
);

// Submit KYC
final kycService = KycService();
final result = await kycService.submitKyc(kycData);

if (result.success) {
  print('✅ KYC submitted successfully: ${result.message}');
  print('📋 Status: ${result.status}');
} else {
  print('❌ KYC failed: ${result.message}');
}
```

### 2. Image Selection with ImagePicker

```dart
final ImagePicker picker = ImagePicker();

// Pick ID photo
final XFile? idPhoto = await picker.pickImage(
  source: ImageSource.camera,  // or ImageSource.gallery
  maxWidth: 1920,
  maxHeight: 1080,
  imageQuality: 85,
);

// Pick selfie
final XFile? selfie = await picker.pickImage(
  source: ImageSource.camera,
  maxWidth: 1920,
  maxHeight: 1080,
  imageQuality: 85,
);
```

### 3. KYC Status Check

```dart
final kycService = KycService();
final status = await kycService.getKycStatus();

switch (status) {
  case KycStatus.notStarted:
    print('📝 KYC not started');
    break;
  case KycStatus.inProgress:
    print('🔄 KYC in progress');
    break;
  case KycStatus.underReview:
    print('📋 KYC under review');
    break;
  case KycStatus.approved:
    print('✅ KYC approved');
    break;
  case KycStatus.rejected:
    print('❌ KYC rejected');
    break;
}
```

### 4. Validation Before Submission

```dart
// Check if KYC data is complete
if (kycData.isComplete) {
  // Submit KYC
  final result = await kycService.submitKyc(kycData);
} else {
  // Show missing fields
  final missing = kycData.missingFields;
  print('Missing fields: ${missing.join(', ')}');
}
```

## 🔧 Backend Requirements

Your backend endpoint `/kyc` should accept:

### Form Fields:
- `id_type`: String (passport, driver_license, etc.)
- `dob`: String (YYYY-MM-DD format)
- `address`: String
- `city`: String  
- `country`: String

### File Fields:
- `id_photo`: Image file (JPEG/PNG)
- `selfie`: Image file (JPEG/PNG)

### Example Backend Response:
```json
{
  "success": true,
  "message": "KYC submitted successfully",
  "status": "under_review",
  "data": {
    "kyc_id": "12345",
    "submitted_at": "2024-01-01T00:00:00Z"
  }
}
```

## 🐛 Troubleshooting

### Common Issues:

1. **File Upload Fails**
   - Check that backend accepts multipart/form-data
   - Verify file size limits on backend
   - Check network connectivity

2. **Authentication Errors**
   - Ensure user is logged in
   - Check that HTTP-only cookies are working
   - Verify backend authentication

3. **Validation Errors**
   - Use `kycData.isComplete` to check completeness
   - Check `kycData.missingFields` for what's missing
   - Ensure all required fields are filled

### Debug Mode:
Enable debug mode to see detailed logs:
```dart
import 'package:flutter/foundation.dart';

// Debug logs will show:
// - Form fields being submitted
// - File sizes and names
// - Backend response details
// - Error messages and stack traces
```

## 📱 UI Integration Example

```dart
class KycScreen extends StatefulWidget {
  @override
  _KycScreenState createState() => _KycScreenState();
}

class _KycScreenState extends State<KycScreen> {
  final _formKey = GlobalKey<FormState>();
  final kycService = KycService();
  
  String idType = '';
  String dob = '';
  String address = '';
  String city = '';
  String country = '';
  XFile? idPhoto;
  XFile? selfie;
  
  bool isSubmitting = false;

  Future<void> _submitKyc() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => isSubmitting = true);
    
    try {
      final kycData = KycData(
        idType: idType,
        dob: dob,
        address: address,
        city: city,
        country: country,
        idPhoto: idPhoto,
        selfie: selfie,
      );
      
      final result = await kycService.submitKyc(kycData);
      
      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('KYC Verification')),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Add your form fields here
            // ID Type dropdown
            // DOB date picker  
            // Address text field
            // City text field
            // Country text field
            // ID Photo picker button
            // Selfie picker button
            
            ElevatedButton(
              onPressed: isSubmitting ? null : _submitKyc,
              child: isSubmitting 
                ? CircularProgressIndicator() 
                : Text('Submit KYC'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## 🔄 Next Steps

1. **Test KYC submission** in your app
2. **Check backend logs** to verify file uploads are working
3. **Test with different file types** (JPEG, PNG)
4. **Verify authentication** is working with HTTP-only cookies
5. **Test error handling** with invalid data

Your KYC functionality should now work correctly with file uploads and proper validation! 🎉