import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:country_picker/country_picker.dart';
import 'modern_confirmation_screen.dart';
import '../../services/account_service.dart';
import '../../models/account_info_response.dart';

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
  final _currencyController = TextEditingController();
  final _expectedAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill cash pickup fields
    if (widget.transferType == 'cash_pickup') {
      _countryController.text = 'ET';
      _currencyController.text = widget.currency;
      _expectedAmountController.text = widget.etbAmount.toString();
    }
  }

  @override
  void dispose() {
    _accountVerificationTimer?.cancel();
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
    _currencyController.dispose();
    _expectedAmountController.dispose();
    super.dispose();
  }

  String get _transferTitle {
    switch (widget.transferType) {
      case 'wegagen_bank':
        return 'Bank Account Transfer';
      case 'wegagen_ebirr':
        return 'Wegagen E-birr Transfer';
      case 'cash_pickup':
        return 'Cash Pickup Transfer';
      case 'other_banks':
        return 'Other Banks Transfer';
      default:
        return 'Money Transfer';
    }
  }

  IconData get _transferIcon {
    switch (widget.transferType) {
      case 'wegagen_bank':
        return Icons.account_balance;
      case 'wegagen_ebirr':
        return Icons.phone_android;
      case 'cash_pickup':
        return Icons.local_atm;
      case 'other_banks':
        return Icons.account_balance_outlined;
      default:
        return Icons.send;
    }
  }

  Widget _buildProgressIndicator() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFF37021),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFF37021),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFF37021),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _verifyPhone() {
    if (_phoneNumberController.text.isNotEmpty) {
      setState(() {
        _isPhoneVerified = true;
        _ebirrHolderName = 'KIDUS ATSBIH';
      });
    }
  }

  Future<void> _verifyAccount([String? accountNumberArg]) async {
    final accountNumber = accountNumberArg?.trim() ?? _accountNumberController.text.trim();
    if (accountNumber.isEmpty) return;
    if (_isVerifying && accountNumber == _lastVerifiedAccountNumber) return;

    setState(() {
      _isVerifying = true;
      _isAccountVerified = false;
    });

    try {
      final response = await _accountService.getAccountInfo(accountNumber);

      if (mounted) {
        if (response.success && response.account != null) {
          final accountData = response.account!;
          
          if (_isValidAccountData(accountData)) {
            setState(() {
              _isAccountVerified = true;
              _accountHolderName = accountData.accountHolderName;
              _accountType = accountData.accountTypeDescription;
              _isVerifying = false;
            });
            _lastVerifiedAccountNumber = accountNumber;
          } else {
            setState(() {
              _isAccountVerified = false;
              _isVerifying = false;
            });
            _lastVerifiedAccountNumber = '';
            _showErrorMessage('Account not found. Please verify the account number and try again.');
          }
        } else {
          setState(() {
            _isAccountVerified = false;
            _isVerifying = false;
          });
          _lastVerifiedAccountNumber = '';
          _showErrorMessage(response.message?.isNotEmpty == true
              ? response.message! 
              : 'Account not found. Please verify the account number.');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAccountVerified = false;
          _isVerifying = false;
        });
        _lastVerifiedAccountNumber = '';
        _showErrorMessage('Failed to verify account. Please check your connection and try again.');
      }
    }
  }

  bool _isValidAccountData(AccountInfo accountData) {
    if (accountData.accountHolderName.trim().isEmpty) return false;
    
    final name = accountData.accountHolderName.trim().toLowerCase();
    if (name == 'null' || name == 'n/a' || name == 'unknown' || name.length < 2) return false;
    
    if (!accountData.isActive || !accountData.canReceiveMoney) return false;
    
    return true;
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _proceedToConfirmation() {
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> recipientData = {};

      switch (widget.transferType) {
        case 'wegagen_bank':
          if (!_isAccountVerified) return;
          recipientData = {
            'accountNumber': _accountNumberController.text,
            'accountHolderName': _accountHolderName,
            'accountType': _accountType,
          };
          break;
        case 'wegagen_ebirr':
          if (!_isPhoneVerified) return;
          recipientData = {
            'phoneNumber': _phoneNumberController.text,
            'holderName': _ebirrHolderName,
          };
          break;
        case 'cash_pickup':
          recipientData = {
            'phone_number': _recipientPhoneController.text,
            'first_name': _firstNameController.text,
            'middle_name': _middleNameController.text,
            'last_name': _lastNameController.text,
            'country': _countryController.text,
            'state': _stateController.text,
            'city': _cityController.text,
            'address': _addressController.text,
            'relationship_to_sender': _relationshipController.text,
            'currency': _currencyController.text,
            'expected_amount': _expectedAmountController.text,
          };
          break;
        case 'other_banks':
          if (!_isAccountVerified) return;
          recipientData = {
            'accountNumber': _accountNumberController.text,
            'accountHolderName': _accountHolderName,
            'accountType': _accountType,
            'bankName': widget.selectedBank,
          };
          break;
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

  bool get _canProceed {
    switch (widget.transferType) {
      case 'wegagen_bank':
        return _isAccountVerified;
      case 'wegagen_ebirr':
        return _isPhoneVerified;
      case 'cash_pickup':
        return _recipientPhoneController.text.isNotEmpty &&
            _firstNameController.text.isNotEmpty &&
            _lastNameController.text.isNotEmpty &&
            _cityController.text.isNotEmpty &&
            _addressController.text.isNotEmpty &&
            _relationshipController.text.isNotEmpty;
      case 'other_banks':
        return _isAccountVerified;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    const double extraBottomPadding = 12.0;
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_transferIcon, size: 20, color: Colors.black87),
            const SizedBox(width: 8),
            Text(
              _transferTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            _buildProgressIndicator(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  24,
                  24,
                  24,
                  24 + MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Recipient Details',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Enter the recipient\'s information',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 32),
                      ..._buildTransferSpecificFields(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: EdgeInsets.fromLTRB(24, 8, 24, bottomInset + extraBottomPadding),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 0),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _canProceed ? _proceedToConfirmation : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF37021),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
              child: const Text(
                'Continue',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildTransferSpecificFields() {
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
  }  List
<Widget> _buildBankTransferFields() {
    return [
      const Text(
        'Bank Account Number',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      const SizedBox(height: 12),
      Container(
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
        child: TextFormField(
          controller: _accountNumberController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: '1000123456789',
            hintStyle: TextStyle(color: Colors.grey.shade400),
            prefixIcon: Icon(Icons.account_balance, color: Colors.grey.shade400),
            suffixIcon: _isVerifying
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : _isAccountVerified
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(16),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter account number';
            }
            return null;
          },
          onChanged: (value) {
            _accountVerificationTimer?.cancel();
            setState(() {
              _isAccountVerified = false;
            });
            if (value.length >= 10) {
              _accountVerificationTimer = Timer(const Duration(milliseconds: 600), () {
                if (mounted) {
                  _verifyAccount(value.trim());
                }
              });
            }
          },
        ),
      ),
      const SizedBox(height: 24),
      if (_isAccountVerified) ...[
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Account Verified',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Name: $_accountHolderName',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Type: $_accountType',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ],
    ];
  }

  List<Widget> _buildEbirrTransferFields() {
    return [
      const Text(
        'Wegagen E-birr Phone Number',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      const SizedBox(height: 12),
      Container(
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
        child: TextFormField(
          controller: _phoneNumberController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            hintText: '09XXXXXXXX',
            hintStyle: TextStyle(color: Colors.grey.shade400),
            prefixIcon: Icon(Icons.phone, color: Colors.grey.shade400),
            suffixIcon: _isPhoneVerified
                ? const Icon(Icons.check_circle, color: Colors.green)
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(16),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter phone number';
            }
            return null;
          },
          onChanged: (value) {
            setState(() {
              _isPhoneVerified = false;
            });
            if (value.length >= 10) {
              _verifyPhone();
            }
          },
        ),
      ),
      const SizedBox(height: 24),
      if (_isPhoneVerified) ...[
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Phone Verified',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Name: $_ebirrHolderName',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    ];
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cash Pickup Recipient Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF37021),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Enter recipient information for cash pickup',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
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
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 1.5,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Colors.red,
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
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 1.5,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Colors.red,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'State/Region',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                _buildInputField(
                  controller: _stateController,
                  hintText: 'State/Region',
                  prefixIcon: Icons.location_city_outlined,
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 24),

      // City
      const Text(
        'City',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      const SizedBox(height: 12),
      _buildInputField(
        controller: _cityController,
        hintText: 'Addis Ababa',
        prefixIcon: Icons.location_city,
      ),
      const SizedBox(height: 24),

      // Address
      const Text(
        'Address',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      const SizedBox(height: 12),
      _buildInputField(
        controller: _addressController,
        hintText: 'Street address or area',
        prefixIcon: Icons.location_on,
      ),
      const SizedBox(height: 24),

      // Reason for Transfer
      const Text(
        'Reason for Transfer',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      const SizedBox(height: 12),
      _buildInputField(
        controller: _relationshipController,
        hintText: 'Family support, Business payment, Emergency, etc.',
        prefixIcon: Icons.description,
      ),
      const SizedBox(height: 24),

      // Summary Card - Display full info
      if (_recipientPhoneController.text.isNotEmpty && 
          _firstNameController.text.isNotEmpty && 
          _lastNameController.text.isNotEmpty) ...[
        Container(
          padding: const EdgeInsets.all(20),
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
                  Icon(
                    Icons.receipt_long,
                    color: Colors.blue.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Cash Pickup Summary',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildSummaryRow('Recipient', '${_firstNameController.text} ${_middleNameController.text} ${_lastNameController.text}'.trim()),
              _buildSummaryRow('Phone', _recipientPhoneController.text),
              if (_cityController.text.isNotEmpty) _buildSummaryRow('Location', '${_cityController.text}, ${_stateController.text}'),
              if (_relationshipController.text.isNotEmpty) _buildSummaryRow('Reason', _relationshipController.text),
              _buildSummaryRow('Amount', '${widget.etbAmount.toStringAsFixed(2)} ${widget.currency}'),
              _buildSummaryRow('Exchange Rate', widget.exchangeRate.toStringAsFixed(4)),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    ];
  }

  Widget _buildSummaryRow(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
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

  List<Widget> _buildOtherBankTransferFields() {
    return [
      // Selected Bank Info
      if (widget.selectedBank != null) ...[
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            children: [
              Icon(
                Icons.account_balance_outlined,
                color: Colors.blue.shade600,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Sending to: ${widget.selectedBank}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
      
      // Account Number Field
      Text(
        '${widget.selectedBank ?? "Bank"} Account Number',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      const SizedBox(height: 12),
      Container(
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
        child: TextFormField(
          controller: _accountNumberController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: '1000123456789',
            hintStyle: TextStyle(color: Colors.grey.shade400),
            prefixIcon: Icon(Icons.account_balance, color: Colors.grey.shade400),
            suffixIcon: _isVerifying
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : _isAccountVerified
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(16),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter account number';
            }
            return null;
          },
          onChanged: (value) {
            _accountVerificationTimer?.cancel();
            setState(() {
              _isAccountVerified = false;
            });
            if (value.length >= 10) {
              _accountVerificationTimer = Timer(const Duration(milliseconds: 600), () {
                if (mounted) {
                  _verifyAccount(value.trim());
                }
              });
            }
          },
        ),
      ),
      const SizedBox(height: 24),
      if (_isAccountVerified) ...[
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Account Verified',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Name: $_accountHolderName',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Type: $_accountType',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 4),
              Text(
                'Bank: ${widget.selectedBank}',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ],
    ];
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    IconData? prefixIcon,
    TextInputType? keyboardType,
    bool readOnly = false,
  }) {
    return Container(
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
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        readOnly: readOnly,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.shade400),
          prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Colors.grey.shade400) : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: readOnly ? Colors.grey.shade100 : Colors.white,
          contentPadding: const EdgeInsets.all(16),
        ),
        validator: (value) {
          if (!readOnly && (value == null || value.isEmpty)) {
            return 'This field is required';
          }
          return null;
        },
      ),
    );
  }
}         
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
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 1.5,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Colors.red,
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
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 1.5,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Colors.red,
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
                countryListTheme: CountryListThemeData(
                  flagSize: 25,
                  backgroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 16, color: Colors.blueGrey),
                  bottomSheetHeight: 500,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0),
                  ),
                  inputDecoration: InputDecoration(
                    labelText: 'Search',
                    hintText: 'Start typing to search',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: const Color(0xFFF37021).withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                ),
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

  Widget _buildModernSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade50,
            Colors.blue.shade25,
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

  List<Widget> _buildOtherBankTransferFields() {
    return [
      // Selected Bank Info
      if (widget.selectedBank != null) ...[
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            children: [
              Icon(
                Icons.account_balance_outlined,
                color: Colors.blue.shade600,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Sending to: ${widget.selectedBank}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
      
      // Account Number Field
      Text(
        '${widget.selectedBank ?? "Bank"} Account Number',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      const SizedBox(height: 12),
      Container(
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
        child: TextFormField(
          controller: _accountNumberController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: '1000123456789',
            hintStyle: TextStyle(color: Colors.grey.shade400),
            prefixIcon: Icon(Icons.account_balance, color: Colors.grey.shade400),
            suffixIcon: _isVerifying
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : _isAccountVerified
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(16),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter account number';
            }
            return null;
          },
          onChanged: (value) {
            _accountVerificationTimer?.cancel();
            setState(() {
              _isAccountVerified = false;
            });
            if (value.length >= 10) {
              _accountVerificationTimer = Timer(const Duration(milliseconds: 600), () {
                if (mounted) {
                  _verifyAccount(value.trim());
                }
              });
            }
          },
        ),
      ),
      const SizedBox(height: 24),
      if (_isAccountVerified) ...[
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Account Verified',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Name: $_accountHolderName',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Type: $_accountType',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 4),
              Text(
                'Bank: ${widget.selectedBank}',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ],
    ];
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    IconData? prefixIcon,
    TextInputType? keyboardType,
    bool readOnly = false,
  }) {
    return Container(
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
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        readOnly: readOnly,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.shade400),
          prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Colors.grey.shade400) : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: readOnly ? Colors.grey.shade100 : Colors.white,
          contentPadding: const EdgeInsets.all(16),
        ),
        validator: (value) {
          if (!readOnly && (value == null || value.isEmpty)) {
            return 'This field is required';
          }
          return null;
        },
      ),
    );
  }
}