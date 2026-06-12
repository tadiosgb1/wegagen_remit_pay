import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main_navigation_screen.dart';
import '../../models/kyc_data.dart';
import '../../services/kyc_service.dart';
import 'liveness_detection_screen.dart';

class KycScreen extends StatefulWidget {
  const KycScreen({super.key});

  @override
  State<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends State<KycScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _kycService = KycService();

  final _dobController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();

  String _selectedIdType = 'passport';
  String _selectedCountry = 'Ethiopia';
  XFile? _idPhoto;
  XFile? _selfiePhoto;
  bool _livenessVerified = false;
  bool _isSubmitting = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<String> _idTypes = ['passport', 'national_id', 'driving_license'];
  final List<String> _countries = [
    'Ethiopia',
    'United States',
    'United Kingdom',
    'Canada',
    'Australia',
    'Germany',
    'France',
    'Italy'
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Header with progress
            _buildHeader(),

            // Form content
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Personal Information Section
                      _buildSectionHeader('Personal Information', Icons.person),
                      const SizedBox(height: 16),
                      _buildPersonalInfoSection(),

                      const SizedBox(height: 32),

                      // Document Upload Section
                      _buildSectionHeader(
                          'Document Verification', Icons.description),
                      const SizedBox(height: 16),
                      _buildDocumentSection(),

                      const SizedBox(height: 32),

                      // Biometric Verification Section
                      _buildSectionHeader('Biometric Verification', Icons.face),
                      const SizedBox(height: 16),
                      _buildBiometricSection(),

                      const SizedBox(height: 40),

                      // Submit Button - moved up from bottom
                      _buildSubmitButton(),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: const Color(0xFFF37021),
      foregroundColor: Colors.white,
      title: const Text(
        'KYC Verification',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF37021),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text(
            'Complete your verification process',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Progress',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${(_getFormProgress() * 100).toInt()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: _getFormProgress(),
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  borderRadius: BorderRadius.circular(8),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF37021).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: const Color(0xFFF37021),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Date of Birth
          _buildStyledTextField(
            controller: _dobController,
            label: 'Date of Birth',
            icon: Icons.calendar_today,
            readOnly: true,
            onTap: _selectDate,
            validator: (value) =>
                value?.isEmpty ?? true ? 'Date of birth is required' : null,
          ),

          const SizedBox(height: 20),

          // Address
          _buildStyledTextField(
            controller: _addressController,
            label: 'Address',
            icon: Icons.location_on_outlined,
            maxLines: 2,
            validator: (value) =>
                value?.isEmpty ?? true ? 'Address is required' : null,
          ),

          const SizedBox(height: 20),

          // City
          _buildStyledTextField(
            controller: _cityController,
            label: 'City',
            icon: Icons.location_city_outlined,
            validator: (value) =>
                value?.isEmpty ?? true ? 'City is required' : null,
          ),

          const SizedBox(height: 20),

          // Country Selection
          _buildStyledDropdown(
            value: _selectedCountry,
            label: 'Country',
            icon: Icons.public,
            items: _countries
                .map((country) => DropdownMenuItem(
                      value: country,
                      child: Text(country),
                    ))
                .toList(),
            onChanged: (value) => setState(() => _selectedCountry = value!),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // ID Type Selection
          _buildStyledDropdown(
            value: _selectedIdType,
            label: 'ID Document Type',
            icon: Icons.badge_outlined,
            items: _idTypes
                .map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(_formatIdType(type)),
                    ))
                .toList(),
            onChanged: (value) => setState(() => _selectedIdType = value!),
          ),

          const SizedBox(height: 24),

          // ID Photo Upload
          _buildAdvancedUploadCard(
            title: 'ID Document Photo',
            subtitle:
                'Upload clear photo of your ${_formatIdType(_selectedIdType)}',
            image: _idPhoto,
            onTap: () => _showImagePicker(true),
            icon: Icons.credit_card,
          ),
        ],
      ),
    );
  }

  Widget _buildBiometricSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _buildAdvancedLivenessCard(),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: _isFormComplete()
            ? const LinearGradient(
                colors: [Color(0xFFF37021), Color(0xFFFF8A4D)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        color: _isFormComplete() ? null : Colors.grey[300],
        boxShadow: _isFormComplete()
            ? [
                BoxShadow(
                  color: const Color(0xFFF37021).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: (_isSubmitting || !_isFormComplete()) ? null : _submitKyc,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isFormComplete()
                        ? Icons.verified_user
                        : Icons.info_outline,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isFormComplete()
                        ? 'Submit KYC Verification'
                        : 'Complete All Required Fields',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildStyledTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool readOnly = false,
    VoidCallback? onTap,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFFF37021)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFF37021), width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildStyledDropdown<T>({
    required T value,
    required String label,
    required IconData icon,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFFF37021)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFF37021), width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      items: items,
      onChanged: onChanged,
    );
  }

  Widget _buildAdvancedUploadCard({
    required String title,
    required String subtitle,
    required XFile? image,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: image != null ? Colors.green : Colors.grey[300]!,
            width: 2,
          ),
          color:
              image != null ? Colors.green.withOpacity(0.05) : Colors.grey[50],
        ),
        padding: const EdgeInsets.all(20),
        child: image != null
            ? Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: kIsWeb
                              ? Image.network(image.path, fit: BoxFit.cover)
                              : Image.file(File(image.path), fit: BoxFit.cover),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.check_circle,
                                    color: Colors.green, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Uploaded Successfully',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF2D3748),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tap to change photo',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              )
            : Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF37021).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Icon(
                      icon,
                      color: const Color(0xFFF37021),
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF37021),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Choose File',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildAdvancedLivenessCard() {
    return GestureDetector(
      onTap: _startLivenessDetection,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _livenessVerified ? Colors.green : Colors.grey[300]!,
            width: 2,
          ),
          color: _livenessVerified
              ? Colors.green.withOpacity(0.05)
              : Colors.grey[50],
        ),
        padding: const EdgeInsets.all(20),
        child: _livenessVerified
            ? Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: _selfiePhoto != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: kIsWeb
                                    ? Image.network(_selfiePhoto!.path,
                                        fit: BoxFit.cover)
                                    : Image.file(File(_selfiePhoto!.path),
                                        fit: BoxFit.cover),
                              )
                            : Container(
                                decoration: BoxDecoration(
                                  color: Colors.green[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.verified_user,
                                    color: Colors.green, size: 40),
                              ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.check_circle,
                                    color: Colors.green, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Verification Complete',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Liveness Verification',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF2D3748),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tap to retake verification',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              )
            : Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF37021).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Icon(
                      Icons.face_retouching_natural,
                      color: Color(0xFFF37021),
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Liveness Verification',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Verify your identity with face recognition technology',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF37021),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Start Verification',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildUploadCard(
      String title, String subtitle, XFile? image, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 120,
          padding: const EdgeInsets.all(16),
          child: image != null
              ? Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: kIsWeb
                          ? Image.network(image.path,
                              width: 80, height: 80, fit: BoxFit.cover)
                          : Image.file(File(image.path),
                              width: 80, height: 80, fit: BoxFit.cover),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(title,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          const Text('✅ Uploaded',
                              style: TextStyle(color: Colors.green)),
                          const Text('Tap to change',
                              style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.upload_file, size: 40, color: Colors.grey),
                    const SizedBox(height: 8),
                    Text(title,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(subtitle, style: const TextStyle(fontSize: 12)),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildLivenessCard() {
    return Card(
      child: InkWell(
        onTap: _startLivenessDetection,
        child: Container(
          height: 120,
          padding: const EdgeInsets.all(16),
          child: _livenessVerified
              ? Row(
                  children: [
                    if (_selfiePhoto != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: kIsWeb
                            ? Image.network(_selfiePhoto!.path,
                                width: 80, height: 80, fit: BoxFit.cover)
                            : Image.file(File(_selfiePhoto!.path),
                                width: 80, height: 80, fit: BoxFit.cover),
                      )
                    else
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.verified_user,
                            color: Colors.green, size: 40),
                      ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Liveness Verification',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('✅ Verified',
                              style: TextStyle(color: Colors.green)),
                          Text('Tap to retake', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                )
              : const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.face_retouching_natural,
                        size: 40, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('Liveness Verification',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Tap to start face verification',
                        style: TextStyle(fontSize: 12)),
                  ],
                ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 6570)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now().subtract(const Duration(days: 6570)),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = picked.toIso8601String().split('T')[0];
      });
    }
  }

  void _showImagePicker(bool isIdPhoto) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
      ),
    );
  }

  Future<void> _pickImage(ImageSource source, bool isIdPhoto) async {
    try {
      if (source == ImageSource.camera && !kIsWeb) {
        final status = await Permission.camera.request();
        if (!status.isGranted) return;
      }

      final picker = ImagePicker();
      final image = await picker.pickImage(source: source, imageQuality: 80);

      if (image != null) {
        setState(() {
          if (isIdPhoto) {
            _idPhoto = image;
          } else {
            _selfiePhoto = image;
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _startLivenessDetection() async {
    try {
      final result = await Navigator.push<XFile>(
        context,
        MaterialPageRoute(
            builder: (context) => const LivenessDetectionScreen()),
      );

      if (result != null) {
        setState(() {
          _selfiePhoto = result;
          _livenessVerified = true;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Liveness detection failed: $e')),
      );
    }
  }

  Future<void> _submitKyc() async {
    if (!_formKey.currentState!.validate() || !_isFormComplete()) return;

    setState(() => _isSubmitting = true);

    try {
      // First, check if user is authenticated
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');
      final isLoggedIn = prefs.getBool('is_logged_in') ?? false;

      if (!isLoggedIn && authToken == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please log in first to submit KYC verification'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final kycData = KycData(
        idType: _selectedIdType,
        dob: _dobController.text,
        address: _addressController.text,
        city: _cityController.text,
        country: _selectedCountry,
        idPhoto: _idPhoto,
        selfie: _selfiePhoto,
      );

      final response = await _kycService.submitKyc(kycData);

      if (!mounted) return;

      if (response.success) {
        _showSuccessDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message)),
        );
      }
    } catch (e) {
      if (!mounted) return;

      String errorMessage = 'Failed to submit KYC. Please try again.';

      // Handle specific error cases
      if (e.toString().contains('401') ||
          e.toString().contains('Unauthorized')) {
        errorMessage =
            'Authentication failed. Please log in again and try submitting your KYC.';
      } else if (e.toString().contains('DioException')) {
        errorMessage =
            'Network error. Please check your connection and try again.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          action: e.toString().contains('401')
              ? SnackBarAction(
                  label: 'Login',
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil('/login', (route) => false);
                  },
                )
              : null,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('KYC Submitted'),
        content: const Text(
            'Your KYC has been submitted successfully. We will review it within 24-48 hours.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                    builder: (context) => const MainNavigationScreen()),
              );
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  double _getFormProgress() {
    int completed = 0;
    if (_selectedIdType.isNotEmpty) completed++;
    if (_dobController.text.isNotEmpty) completed++;
    if (_addressController.text.isNotEmpty) completed++;
    if (_cityController.text.isNotEmpty) completed++;
    if (_selectedCountry.isNotEmpty) completed++;
    if (_idPhoto != null) completed++;
    if (_selfiePhoto != null && _livenessVerified) completed++;
    return completed / 7;
  }

  bool _isFormComplete() {
    return _dobController.text.isNotEmpty &&
        _addressController.text.isNotEmpty &&
        _cityController.text.isNotEmpty &&
        _idPhoto != null &&
        _selfiePhoto != null &&
        _livenessVerified;
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
