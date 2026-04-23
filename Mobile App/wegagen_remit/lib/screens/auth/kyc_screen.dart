import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../main_navigation_screen.dart';
import '../../models/kyc_data.dart';
import '../../services/kyc_service.dart';
import 'liveness_detection_screen.dart';

class KycScreen extends StatefulWidget {
  const KycScreen({super.key});

  @override
  State<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends State<KycScreen> {
  final PageController _pageController = PageController();
  final _formKey = GlobalKey<FormState>();
  final KycService _kycService = KycService();

  int _currentStep = 0;
  bool _isLoading = false;

  // Form controllers
  final _dobController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();

  // Form data
  String _selectedIdType = 'passport';
  String _selectedCountry = 'Ethiopia';
  XFile? _idPhoto;
  XFile? _selfiePhoto;
  bool _livenessVerified = false;

  final List<String> _idTypes = ['passport', 'national_id', 'driving_license'];

  final List<String> _countries = [
    'Ethiopia',
    'United States',
    'United Kingdom',
    'Canada',
    'Australia',
    'Germany',
    'France',
    'Italy',
    'Spain',
    'Netherlands',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  // Helper method to display images that works on both web and mobile
  Widget _buildImageWidget(XFile? imageFile, {BoxFit fit = BoxFit.cover}) {
    if (imageFile == null) return const SizedBox.shrink();

    if (kIsWeb) {
      // For web, show success indicator since we can't easily display XFile images
      return Container(
        color: Colors.green.shade100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            const SizedBox(height: 8),
            const Text(
              'Image uploaded successfully',
              style: TextStyle(color: Colors.green, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    } else {
      // For mobile/desktop, use Image.file with File conversion
      return Image.file(File(imageFile.path), fit: fit);
    }
  }

  Future<void> _pickImage(ImageSource source, bool isIdPhoto) async {
    try {
      // Request camera permission
      if (source == ImageSource.camera && !kIsWeb) {
        final status = await Permission.camera.request();
        if (!status.isGranted) {
          _showErrorDialog('Camera permission is required to take photos');
          return;
        }
      }

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          if (isIdPhoto) {
            _idPhoto = image;
          } else {
            _selfiePhoto = image;
            // On web, mark liveness as verified when selfie is uploaded
            if (kIsWeb) {
              _livenessVerified = true;
            }
          }
        });
      }
    } catch (e) {
      _showErrorDialog('Failed to pick image: $e');
    }
  }

  void _showImageSourceDialog(bool isIdPhoto) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera, isIdPhoto);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery, isIdPhoto);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitKyc() async {
    try {
      // Only validate form if we're on a step that has form fields (step 1 - personal info)
      // The liveness step (step 3) doesn't have form fields, so skip validation
      if (_currentStep == 1) {
        // Check if form key and form state are valid
        if (_formKey.currentState == null) {
          _showErrorDialog('Form validation error. Please try again.');
          return;
        }

        if (!_formKey.currentState!.validate()) {
          _showErrorDialog('Please fill in all required fields correctly.');
          return;
        }
      }

      if (_idPhoto == null) {
        _showErrorDialog('Please upload your ID document photo');
        return;
      }

      if (_selfiePhoto == null || !_livenessVerified) {
        _showErrorDialog('Please complete the liveness verification');
        return;
      }

      setState(() {
        _isLoading = true;
      });

      // Validate text controllers
      final dob = _dobController.text.trim();
      final address = _addressController.text.trim();
      final city = _cityController.text.trim();

      if (dob.isEmpty || address.isEmpty || city.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog('Please fill in all personal information fields.');
        return;
      }

      final kycData = KycData(
        idType: _selectedIdType,
        dob: dob,
        address: address,
        city: city,
        country: _selectedCountry,
        idPhoto: _idPhoto,
        selfie: _selfiePhoto,
      );

      print('Submitting KYC data...');
      final response = await _kycService.submitKyc(kycData);
      print('KYC response: ${response.success}, ${response.message}');

      if (response.success) {
        _showSuccessDialog();
      } else {
        _showErrorDialog(response.message);
      }
    } catch (e) {
      print('KYC submission error in screen: $e');
      _showErrorDialog('Failed to submit KYC: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('KYC Submitted Successfully'),
        content: const Text(
          'Your KYC documents have been submitted successfully. '
          'We will review your documents within 24-48 hours and notify you of the status.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const MainNavigationScreen(),
                ),
              );
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    // Validate current step before proceeding
    if (_currentStep == 1) {
      // Validate personal information step
      if (_formKey.currentState == null || !_formKey.currentState!.validate()) {
        return;
      }
    } else if (_currentStep == 2) {
      // Validate document upload step
      if (_idPhoto == null) {
        _showErrorDialog('Please upload your ID document photo');
        return;
      }
    }

    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Identity Verification',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Indicator
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(24),
              child: Row(
                children: List.generate(4, (index) {
                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
                      height: 4,
                      decoration: BoxDecoration(
                        color: index <= _currentStep
                            ? const Color(0xFFF37021)
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Page Content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildWelcomeStep(),
                  _buildPersonalInfoStep(),
                  _buildDocumentUploadStep(),
                  _buildLivenessStep(),
                ],
              ),
            ),

            // Navigation Buttons
            Container(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousStep,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Back'),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : _currentStep == 3
                          ? _submitKyc
                          : _nextStep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF37021),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(_currentStep == 3 ? 'Submit KYC' : 'Continue'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeStep() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFF37021).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.verified_user,
              size: 60,
              color: Color(0xFFF37021),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Identity Verification Required',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'To comply with financial regulations and ensure secure transactions, we need to verify your identity.',
            style: TextStyle(fontSize: 16, color: Colors.grey, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.security, color: Colors.blue.shade700, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'What you\'ll need:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• Government-issued ID (Passport, National ID, etc.)',
                    ),
                    Text('• Clear selfie photo with liveness verification'),
                    Text('• Personal information (address, date of birth)'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Personal Information',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please provide your personal details',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),

            const SizedBox(height: 20),

            // Date of Birth
            const Text(
              'Date of Birth',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _dobController,
              decoration: InputDecoration(
                hintText: 'YYYY-MM-DD',
                prefixIcon: const Icon(Icons.calendar_today),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFF37021)),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your date of birth';
                }
                return null;
              },
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime(1990),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now().subtract(
                    const Duration(days: 6570),
                  ), // 18 years ago
                );
                if (date != null) {
                  _dobController.text = date.toString().split(' ')[0];
                }
              },
              readOnly: true,
            ),
            const SizedBox(height: 20),

            // Address
            const Text(
              'Address',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(
                hintText: 'Enter your full address',
                prefixIcon: const Icon(Icons.location_on),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFF37021)),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your address';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // City
            const Text(
              'City',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _cityController,
              decoration: InputDecoration(
                hintText: 'Enter your city',
                prefixIcon: const Icon(Icons.location_city),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFF37021)),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your city';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Country
            const Text(
              'Country',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedCountry,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFF37021)),
                ),
              ),
              items: _countries.map((country) {
                return DropdownMenuItem(value: country, child: Text(country));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCountry = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentUploadStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upload Documents',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please upload clear photos of your documents',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 32),

          // ID Type
          const Text(
            'ID Document Type',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedIdType,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFF37021)),
              ),
            ),
            items: _idTypes.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(_formatIdType(type)),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedIdType = value!;
              });
            },
          ),
          const SizedBox(height: 20),

          // ID Document Upload
          const Text(
            'ID Document Photo',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _showImageSourceDialog(true),
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: _idPhoto != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _buildImageWidget(_idPhoto, fit: BoxFit.cover),
                    )
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text(
                          'Tap to upload ID document',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 24),

          // Tips
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb,
                      color: Colors.amber.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Tips for better photos:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• Ensure good lighting'),
                    Text('• Keep the document flat and straight'),
                    Text('• Make sure all text is clearly visible'),
                    Text('• Avoid shadows and glare'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLivenessStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Liveness Verification',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Complete the liveness check to verify your identity',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 32),

          // Liveness Status
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _livenessVerified
                  ? Colors.green.shade50
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _livenessVerified
                    ? Colors.green.shade300
                    : Colors.grey.shade300,
              ),
            ),
            child: Column(
              children: [
                // Show captured selfie if available
                if (_livenessVerified && _selfiePhoto != null)
                  Container(
                    width: 120,
                    height: 120,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.green, width: 3),
                    ),
                    child: ClipOval(
                      child: _buildImageWidget(_selfiePhoto, fit: BoxFit.cover),
                    ),
                  )
                else
                  Icon(
                    _livenessVerified ? Icons.check_circle : Icons.face,
                    size: 64,
                    color: _livenessVerified ? Colors.green : Colors.grey,
                  ),
                const SizedBox(height: 16),
                Text(
                  _livenessVerified
                      ? 'Liveness Verification Completed'
                      : 'Liveness Verification Required',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: _livenessVerified
                        ? Colors.green.shade700
                        : Colors.grey.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _livenessVerified
                      ? 'Your identity has been successfully verified and selfie captured'
                      : 'Please complete the liveness check to continue',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Start Liveness Check Button
          if (!_livenessVerified)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  if (kIsWeb) {
                    // On web, just show image picker instead of liveness detection
                    _showImageSourceDialog(false); // false = selfie photo
                  } else {
                    // On mobile, run actual liveness detection
                    final result = await Navigator.push<XFile>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LivenessDetectionScreen(),
                      ),
                    );

                    if (result != null) {
                      setState(() {
                        _livenessVerified = true;
                        _selfiePhoto =
                            result; // Store the captured selfie XFile
                      });
                    }
                  }
                },
                icon: Icon(kIsWeb ? Icons.photo_camera : Icons.camera_front),
                label: Text(
                  kIsWeb ? 'Upload Selfie Photo' : 'Start Liveness Check',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF37021),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

          const SizedBox(height: 24),

          // Instructions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue.shade700, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      kIsWeb
                          ? 'Selfie Upload Instructions:'
                          : 'Liveness Check Instructions:',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: kIsWeb
                      ? [
                          const Text('• Upload a clear selfie photo'),
                          const Text('• Ensure good lighting on your face'),
                          const Text('• Look directly at the camera'),
                          const Text('• Remove glasses or hats if possible'),
                        ]
                      : [
                          const Text(
                            '• Position your face in the center of the screen',
                          ),
                          const Text('• Follow the on-screen instructions'),
                          const Text('• Ensure good lighting on your face'),
                          const Text('• Complete all requested actions'),
                        ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatIdType(String type) {
    switch (type) {
      case 'passport':
        return 'Passport';
      case 'national_id':
        return 'National ID';
      case 'driving_license':
        return 'Driving License';
      default:
        return type;
    }
  }
}
