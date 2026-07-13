import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:country_picker/country_picker.dart';
import 'modern_confirmation_screen.dart';
import '../../services/account_service.dart';
import '../../models/account_info_response.dart';
import '../../config/url_container.dart';

class RecipientDetailsScreen extends StatefulWidget {
  final String transferType;
  final double amount;
  final String currency;
  final double etbAmount;
  final double fee;
  final double exchangeRate;
  final String? selectedBank;

  const RecipientDetailsScreen({
    super.key,
    required this.transferType,
    required this.amount,
    required this.currency,
    required this.etbAmount,
    required this.fee,
    required this.exchangeRate,
    this.selectedBank,
  });

  @override
  State<RecipientDetailsScreen> createState() => _RecipientDetailsScreenState();
}

class _RecipientDetailsScreenState extends State<RecipientDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  // Bank transfer fields
  final _accountNumberController = TextEditingController();
  bool _isAccountVerified = false;
  String _accountHolderName = '';
  String _accountType = '';

  // E-birr fields
  final _phoneNumberController = TextEditingController();
  bool _isPhoneVerified = false;
  String _ebirrHolderName = '';

  final AccountService _accountService = AccountService();
  bool _isVerifying = false;
  Timer? _accountVerificationTimer;
  String _lastVerifiedAccountNumber = '';
  
  // Cash pickup fields - all required API fields
  final _recipientPhoneController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _countryController = TextEditingController();
  final _stateController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();
  final _relationshipController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill cash pickup fields
    if (widget.transferType == 'cash_pickup') {
      _countryController.text = 'ET';
    }
  }

  @override
  void dispose() {
    _accountNumberController.dispose();
    _phoneNumberController.dispose();
    _recipientPhoneController.dispose();
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _countryController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _relationshipController.dispose();
    _accountVerificationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(_getTitle()),
        backgroundColor: const Color(0xFFF37021),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTransferSummary(),
              const SizedBox(height: 32),
              ..._buildTransferTypeFields(),
              const SizedBox(height: 24),
              _buildContinueButton(),
              const SizedBox(height: 16), // Extra padding at bottom
            ],
          ),
        ),
      ),
    );
  }

  String _getTitle() {
    switch (widget.transferType) {
      case 'wegagen_bank':
        return 'Wegagen Bank Transfer';
      case 'wegagen_ebirr':
        return 'Wegagen E-birr Transfer';
      case 'cash_pickup':
        return 'Cash Pickup Details';
      case 'other_banks':
        return '${widget.selectedBank} Transfer';
      default:
        return 'Transfer Details';
    }
  }

  Widget _buildTransferSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Transfer Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFF37021),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Amount Sending:'),
              Text(
                '${widget.amount.toStringAsFixed(2)} ${widget.currency}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recipient Gets:'),
              Text(
                '${widget.etbAmount.toStringAsFixed(2)} ETB',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Exchange Rate:'),
              Text('1 ${widget.currency} = ${widget.exchangeRate.toStringAsFixed(4)} ETB'),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTransferTypeFields() {
    switch (widget.transferType) {
      case 'wegagen_bank':
        return _buildBankTransferFields();
      case 'wegagen_ebirr':
        return _buildEbirrTransferFields();
      case 'cash_pickup':
        return _buildCashPickupFields();
      case 'other_banks':
        return _buildOtherBankTransferFields();
      default:
        return [];
    }
  }

  List<Widget> _buildCashPickupFields() {
    return [
      // Header with icon
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFF37021).withValues(alpha: 0.1),
              const Color(0xFFF37021).withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFF37021).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF37021),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.money_outlined,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cash Pickup Recipient Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF37021),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Enter recipient information for cash pickup',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 32),

      // Phone Number - Professional styling
      _buildModernSectionTitle('Recipient Contact', Icons.phone),
      const SizedBox(height: 16),
      _buildModernPhoneField(),
      const SizedBox(height: 32),

      // Personal Information Section
      _buildModernSectionTitle('Personal Information', Icons.person),
      const SizedBox(height: 16),
      
      // First Name
      _buildModernTextField(
        controller: _firstNameController,
        label: 'First Name',
        hintText: 'Enter first name',
        prefixIcon: Icons.person_outline,
        isRequired: true,
      ),
      const SizedBox(height: 20),

      // Middle Name - Full width as requested
      _buildModernTextField(
        controller: _middleNameController,
        label: 'Middle Name',
        hintText: 'Enter middle name (optional)',
        prefixIcon: Icons.person_outline,
        isRequired: false,
      ),
      const SizedBox(height: 20),

      // Last Name
      _buildModernTextField(
        controller: _lastNameController,
        label: 'Last Name',
        hintText: 'Enter last name',
        prefixIcon: Icons.person_outline,
        isRequired: true,
      ),
      const SizedBox(height: 32),

      // Location Information Section
      _buildModernSectionTitle('Location Information', Icons.location_on),
      const SizedBox(height: 16),
      
      // Country Dropdown - Professional
      _buildModernCountryDropdown(),
      const SizedBox(height: 20),

      // State/Region
      _buildModernTextField(
        controller: _stateController,
        label: 'State/Region',
        hintText: 'Enter state or region',
        prefixIcon: Icons.location_city_outlined,
        isRequired: true,
      ),
      const SizedBox(height: 20),

      // City
      _buildModernTextField(
        controller: _cityController,
        label: 'City',
        hintText: 'Enter city',
        prefixIcon: Icons.location_city,
        isRequired: true,
      ),
      const SizedBox(height: 20),

      // Address
      _buildModernTextField(
        controller: _addressController,
        label: 'Address',
        hintText: 'Street address or area',
        prefixIcon: Icons.location_on,
        isRequired: true,
        maxLines: 2,
      ),
      const SizedBox(height: 32),

      // Transfer Purpose Section
      _buildModernSectionTitle('Transfer Information', Icons.description),
      const SizedBox(height: 16),
      
      _buildModernTextField(
        controller: _relationshipController,
        label: 'Purpose of Transfer',
        hintText: 'Family support, Business payment, Emergency, etc.',
        prefixIcon: Icons.description_outlined,
        isRequired: true,
      ),
      const SizedBox(height: 32),

      // Summary Card - Enhanced Design
      if (_recipientPhoneController.text.isNotEmpty && 
          _firstNameController.text.isNotEmpty && 
          _lastNameController.text.isNotEmpty) ...[
        _buildModernSummaryCard(),
        const SizedBox(height: 24),
      ],
    ];
  }

  Widget _buildModernSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF37021).withValues(alpha: 0.1),
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
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData prefixIcon,
    bool isRequired = true,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            children: [
              if (isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            readOnly: readOnly,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 15,
              ),
              prefixIcon: Icon(
                prefixIcon,
                color: const Color(0xFFF37021),
                size: 22,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFF37021),
                  width: 1.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: const Color(0xFFF37021).withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFF37021),
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: readOnly ? Colors.grey.shade50 : Colors.white,
              contentPadding: const EdgeInsets.all(16),
            ),
            validator: (value) {
              if (isRequired && (value == null || value.trim().isEmpty)) {
                return '$label is required';
              }
              return null;
            },
            textCapitalization: TextCapitalization.words,
          ),
        ),
      ],
    );
  }

  Widget _buildModernPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            text: 'Phone Number',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            children: [
              TextSpan(
                text: ' *',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: _recipientPhoneController,
            keyboardType: TextInputType.phone,
            maxLength: 9, // 9 characters as requested
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: '912345678',
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 15,
              ),
              prefixIcon: const Icon(
                Icons.phone,
                color: Color(0xFFF37021),
                size: 22,
              ),
              prefixText: '+251 ',
              prefixStyle: const TextStyle(
                color: Color(0xFFF37021),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              counterText: '', // Hide character counter
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFF37021),
                  width: 1.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: const Color(0xFFF37021).withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFF37021),
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.all(16),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Phone number is required';
              }
              if (value.trim().length != 9) {
                return 'Phone number must be exactly 9 digits';
              }
              if (!RegExp(r'^[0-9]+$').hasMatch(value.trim())) {
                return 'Phone number must contain only digits';
              }
              return null;
            },
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Ethiopian phone number (9 digits without country code)',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildModernCountryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            text: 'Country',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            children: [
              TextSpan(
                text: ' *',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: InkWell(
            onTap: () {
              showCountryPicker(
                context: context,
                showPhoneCode: false,
                onSelect: (Country country) {
                  setState(() {
                    _countryController.text = country.countryCode;
                  });
                },
                favorite: <String>['ET'],
                showWorldWide: false,
              );
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFF37021).withValues(alpha: 0.3),
                  width: 1.5,
                ),
                color: Colors.white,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.flag,
                    color: Color(0xFFF37021),
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _countryController.text.isEmpty 
                          ? 'Select Country'
                          : _getCountryName(_countryController.text),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: _countryController.text.isEmpty 
                            ? Colors.grey.shade400 
                            : Colors.black87,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_drop_down,
                    color: Color(0xFFF37021),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade50,
            Colors.blue.shade100,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.blue.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade600,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.receipt_long,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Cash Pickup Summary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSummaryRow('Recipient', '${_firstNameController.text} ${_middleNameController.text} ${_lastNameController.text}'.trim()),
          _buildSummaryRow('Phone', '+251 ${_recipientPhoneController.text}'),
          if (_cityController.text.isNotEmpty) 
            _buildSummaryRow('Location', '${_cityController.text}, ${_stateController.text}'),
          if (_relationshipController.text.isNotEmpty) 
            _buildSummaryRow('Purpose', _relationshipController.text),
          _buildSummaryRow('Amount', '${widget.etbAmount.toStringAsFixed(2)} ETB'),
          _buildSummaryRow('Exchange Rate', '1 ${widget.currency} = ${widget.exchangeRate.toStringAsFixed(4)} ETB'),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    if (value.isEmpty || value.trim() == '') return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getCountryName(String countryCode) {
    switch (countryCode) {
      case 'ET':
        return 'Ethiopia';
      case 'US':
        return 'United States';
      case 'CA':
        return 'Canada';
      case 'GB':
        return 'United Kingdom';
      case 'AU':
        return 'Australia';
      default:
        return countryCode;
    }
  }

  // Placeholder methods for other transfer types (simplified)
  List<Widget> _buildBankTransferFields() {
    return [
      // Header
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFF37021).withValues(alpha: 0.1),
              const Color(0xFFF37021).withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFF37021).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF37021),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.account_balance,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Wegagen Bank Transfer',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF37021),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Enter recipient Wegagen Bank account details',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 32),

      // Account Number Section
      _buildModernSectionTitle('Account Information', Icons.account_balance),
      const SizedBox(height: 16),
      
      // Account Number Field with Real-time Verification
      _buildAccountNumberField(),
      const SizedBox(height: 24),

      // Account Verification Status
      if (_isVerifying) ...[
        _buildVerificationProgress(),
        const SizedBox(height: 24),
      ] else if (_isAccountVerified) ...[
        _buildAccountVerifiedCard(),
        const SizedBox(height: 24),
      ],
    ];
  }

  Widget _buildAccountNumberField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            text: 'Wegagen Bank Account Number',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            children: [
              TextSpan(
                text: ' *',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextFormField(
            controller: _accountNumberController,
            keyboardType: TextInputType.number,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: '1000123456789',
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 15,
              ),
              prefixIcon: const Icon(
                Icons.account_balance,
                color: Color(0xFFF37021),
                size: 22,
              ),
              suffixIcon: _isVerifying
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFFF37021),
                        ),
                      ),
                    )
                  : _isAccountVerified
                      ? const Icon(Icons.check_circle, color: Colors.green, size: 24)
                      : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFF37021),
                  width: 1.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _isAccountVerified 
                      ? Colors.green 
                      : const Color(0xFFF37021).withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _isAccountVerified ? Colors.green : const Color(0xFFF37021),
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.all(16),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Account number is required';
              }
              if (value.trim().length < 10) {
                return 'Account number must be at least 10 digits';
              }
              if (!_isAccountVerified) {
                return 'Please wait for account verification';
              }
              return null;
            },
            onChanged: (value) {
              // Cancel previous verification timer
              _accountVerificationTimer?.cancel();
              
              setState(() {
                _isAccountVerified = false;
                _accountHolderName = '';
                _accountType = '';
              });
              
              // Start new verification after user stops typing
              if (value.trim().length >= 10) {
                _accountVerificationTimer = Timer(const Duration(milliseconds: 800), () {
                  if (mounted && value.trim() != _lastVerifiedAccountNumber) {
                    _verifyAccount(value.trim());
                  }
                });
              }
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Account will be verified automatically',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildVerificationProgress() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFFF37021),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Verifying Account...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Please wait while we verify the account details',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountVerifiedCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade600,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Account Verified',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildVerificationRow('Account Number', _accountNumberController.text),
          _buildVerificationRow('Account Holder', _accountHolderName),
          _buildVerificationRow('Account Type', _accountType),
          _buildVerificationRow('Bank', 'Wegagen Bank S.C.'),
        ],
      ),
    );
  }

  Widget _buildVerificationRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _verifyAccount(String accountNumber) async {
    if (accountNumber.isEmpty || accountNumber.length < 10) {
      return;
    }

    setState(() {
      _isVerifying = true;
      _isAccountVerified = false;
      _accountHolderName = '';
      _accountType = '';
    });

    try {
      print('🔍 Verifying Wegagen account: $accountNumber');
      print('🌐 Using API endpoint: ${UrlContainer.accountInfo}');
      
      final response = await _accountService.getAccountInfo(accountNumber);
      
      print('📱 Account verification response: success=${response.success}');
      print('📱 Response message: ${response.message}');
      print('📱 Response error: ${response.error}');
      
      if (response.success && response.account != null) {
        final account = response.account!;
        
        print('📱 Account data received: ${account.accountHolderName}');
        
        // Validate that we have valid account data
        if (_isValidAccountData(account)) {
          setState(() {
            _isAccountVerified = true;
            _accountHolderName = account.accountHolderName;
            _accountType = account.accountTypeDescription;
            _lastVerifiedAccountNumber = accountNumber;
            _isVerifying = false;
          });
          
          print('✅ Account verified: ${account.accountHolderName}');
        } else {
          _showAccountError('Invalid account data received');
        }
      } else {
        // Handle specific error cases
        String errorMessage = 'Account not found or invalid';
        
        if (response.error?.contains('Request failed') == true) {
          errorMessage = 'Connection failed. Please check your internet connection and try again.';
        } else if (response.message?.isNotEmpty == true) {
          errorMessage = response.message!;
        } else if (response.error?.isNotEmpty == true) {
          errorMessage = response.error!;
        }
        
        print('❌ Account verification failed: $errorMessage');
        _showAccountError(errorMessage);
      }
    } catch (e) {
      print('❌ Account verification error: $e');
      
      String errorMessage = 'Unable to verify account. Please check the number and try again.';
      
      // Handle specific error types
      if (e.toString().contains('Request failed')) {
        errorMessage = 'Connection failed. Please check your internet connection and try again.';
      } else if (e.toString().contains('SocketException')) {
        errorMessage = 'Network connection failed. Please try again.';
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage = 'Request timed out. Please try again.';
      }
      
      _showAccountError(errorMessage);
    }
  }

  bool _isValidAccountData(AccountInfo accountData) {
    // Check if account holder name is empty or null
    if (accountData.accountHolderName.trim().isEmpty) {
      print('❌ Account holder name is empty');
      return false;
    }
    
    // Check for placeholder or invalid names
    final name = accountData.accountHolderName.trim().toLowerCase();
    if (name == 'null' || name == 'n/a' || name == 'unknown' || name.length < 2) {
      print('❌ Account holder name is invalid: $name');
      return false;
    }
    
    return true;
  }

  void _showAccountError(String message) {
    setState(() {
      _isVerifying = false;
      _isAccountVerified = false;
      _accountHolderName = '';
      _accountType = '';
    });

    print('📱 Showing account error: $message');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (message.contains('Connection failed') || message.contains('Request failed'))
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  'Please check your internet connection or try again later.',
                  style: TextStyle(fontSize: 12),
                ),
              ),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: message.contains('Connection failed') || message.contains('Request failed')
            ? SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: () {
                  if (_accountNumberController.text.length >= 10) {
                    _verifyAccount(_accountNumberController.text);
                  }
                },
              )
            : null,
      ),
    );
  }

  List<Widget> _buildEbirrTransferFields() {
    return [
      const Text('E-birr transfer fields will go here'),
    ];
  }

  List<Widget> _buildOtherBankTransferFields() {
    return [
      const Text('Other bank transfer fields will go here'),
    ];
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _proceedToConfirmation,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF37021),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
        ),
        child: const Text(
          'Continue to Payment',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _proceedToConfirmation() {
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> recipientData = {};
      
      switch (widget.transferType) {
        case 'cash_pickup':
          recipientData = {
            'phone_number': _recipientPhoneController.text,
            'first_name': _firstNameController.text,
            'middle_name': _middleNameController.text,
            'last_name': _lastNameController.text,
            'city': _cityController.text,
            'country': _countryController.text,
            'state': _stateController.text,
            'address': _addressController.text,
            'relationship': _relationshipController.text,
          };
          break;
        // Add other cases as needed
      }

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ModernConfirmationScreen(
            transferType: widget.transferType,
            amount: widget.amount,
            currency: widget.currency,
            etbAmount: widget.etbAmount,
            fee: widget.fee,
            exchangeRate: widget.exchangeRate,
            recipientData: recipientData,
          ),
        ),
      );
    }
  }
}