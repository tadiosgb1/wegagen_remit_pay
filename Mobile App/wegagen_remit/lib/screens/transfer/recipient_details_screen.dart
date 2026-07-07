import 'dart:async';
import 'package:flutter/material.dart';
import 'modern_confirmation_screen.dart';
import '../../services/account_service.dart'; // Updated import
import '../../models/account_info_response.dart'; // Updated import

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

  final AccountService _accountService = AccountService(); // Updated service
  bool _isVerifying = false;
  Timer? _accountVerificationTimer;
  String _lastVerifiedAccountNumber = '';
  final _recipientPhoneController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _regionController = TextEditingController();

  @override
  void dispose() {
    _accountVerificationTimer?.cancel();
    _accountNumberController.dispose();
    _phoneNumberController.dispose();
    _recipientPhoneController.dispose();
    _fullNameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _regionController.dispose();
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
      case 'school_pay':
        return 'School Payment';
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
        return Icons.send;
      case 'other_banks':
        return Icons.account_balance_outlined;
      case 'school_pay':
        return Icons.school;
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
          // Step 1 - Active
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFF37021),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Step 2 - Active
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFF37021),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Step 3 - Active
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFF37021),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Step 4 - Inactive
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

  Future<void> _verifyAccount([String? accountNumberArg]) async {
    final accountNumber = accountNumberArg?.trim() ?? _accountNumberController.text.trim();
    if (accountNumber.isEmpty) return;
    if (_isVerifying && accountNumber == _lastVerifiedAccountNumber) return;

    setState(() {
      _isVerifying = true;
      _isAccountVerified = false;
    });

    try {
      print('🔍 Starting account verification for: $accountNumber');
      
      // Use the new AccountService instead of TransferService
      final response = await _accountService.getAccountInfo(
        accountNumber,
      );

      print('📱 Received response: ${response.success}');
      if (response.account != null) {
        print('👤 Account holder: ${response.account!.accountHolderName}');
        print('🏦 Account type: ${response.account!.accountTypeDescription}');
        print('✅ Can receive: ${response.account!.canReceiveMoney}');
        print('🔴 Is active: ${response.account!.isActive}');
      }

      if (mounted) {
        // Check if response is successful AND has valid account data
        if (response.success && response.account != null) {
          final accountData = response.account!;
          
          // Validate that the account data is actually valid (not empty)
          final isValidAccount = _isValidAccountData(accountData);
          
          print('🎯 Account validation result: $isValidAccount');
          
          if (isValidAccount) {
            setState(() {
              _isAccountVerified = true;
              _accountHolderName = accountData.accountHolderName;
              _accountType = accountData.accountTypeDescription;
              _isVerifying = false;
            });
            _lastVerifiedAccountNumber = accountNumber;

            print('✅ Account verified successfully!');
            print('👤 Display name: $_accountHolderName');
            print('🏦 Display type: $_accountType');
            
          } else {
            // Backend returned empty/invalid account data
            setState(() {
              _isAccountVerified = false;
              _isVerifying = false;
            });
            _lastVerifiedAccountNumber = '';
            print('❌ Account data validation failed');
            _showErrorMessage('Account not found. Please verify the account number and try again.');
          }
        } else {
          setState(() {
            _isAccountVerified = false;
            _isVerifying = false;
          });
          _lastVerifiedAccountNumber = '';
          print('❌ Response unsuccessful or no account data');
          _showErrorMessage(response.message?.isNotEmpty == true
              ? response.message! 
              : 'Account not found. Please verify the account number.');
        }
      }
    } catch (e) {
      print('❌ Account verification error: $e');
      
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

  /// Validate that account data contains actual valid information
  /// Updated to work with the new AccountInfo model
  bool _isValidAccountData(AccountInfo accountData) {
    print('🔍 VALIDATING ACCOUNT DATA:');
    print('   Account Holder Name: "${accountData.accountHolderName}"');
    print('   Account Holder Name Length: ${accountData.accountHolderName.length}');
    print('   Account Holder Name Trimmed: "${accountData.accountHolderName.trim()}"');
    print('   Is Active: ${accountData.isActive}');
    print('   Can Receive Money: ${accountData.canReceiveMoney}');
    print('   Account Status: ${accountData.accountStatus}');
    print('   Is Frozen: ${accountData.frozen}');
    
    // Check if account holder name is empty or null
    if (accountData.accountHolderName.trim().isEmpty) {
      print('❌ VALIDATION FAILED: Account holder name is empty');
      return false;
    }
    
    // Check if account holder name is just whitespace or placeholder text
    final name = accountData.accountHolderName.trim().toLowerCase();
    if (name == 'null' || name == 'n/a' || name == 'unknown' || name.length < 2) {
      print('❌ VALIDATION FAILED: Account holder name is invalid: "$name"');
      return false;
    }
    
    // Check if account is active and can receive money
    if (!accountData.isActive || !accountData.canReceiveMoney) {
      print('❌ VALIDATION FAILED: Account not active or cannot receive money');
      print('   Is Active: ${accountData.isActive} (status: ${accountData.accountStatus}, frozen: ${accountData.frozen})');
      print('   Can Receive: ${accountData.canReceiveMoney}');
      return false;
    }
    
    print('✅ VALIDATION PASSED: Account data is valid');
    // Account data looks valid
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

  void _verifyPhone() {
    if (_phoneNumberController.text.isNotEmpty) {
      setState(() {
        _isPhoneVerified = true;
        _ebirrHolderName = 'KIDUS ATSBIH';
      });
    }
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
            'phoneNumber': _recipientPhoneController.text,
            'fullName': _fullNameController.text,
            'address': _addressController.text,
            'city': _cityController.text,
            'region': _regionController.text,
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
            _fullNameController.text.isNotEmpty &&
            _addressController.text.isNotEmpty &&
            _cityController.text.isNotEmpty &&
            _regionController.text.isNotEmpty;
      case 'other_banks':
        return _isAccountVerified;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    const double _extraBottomPadding = 12.0; // raise button a little above inset
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
            // Progress Indicator
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
                      // Dynamic content based on transfer type
                      ..._buildTransferSpecificFields(),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox.shrink(),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: EdgeInsets.fromLTRB(24, 8, 24, bottomInset + _extraBottomPadding),
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
  }

  List<Widget> _buildBankTransferFields() {
    return [
      const Text(
        'Wegagen Bank Account Number',
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
            hintText: '1000000099839',
            hintStyle: TextStyle(color: Colors.grey.shade400),
            prefixIcon: Icon(Icons.credit_card, color: Colors.grey.shade400),
            suffixIcon: _isVerifying
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFFF37021),
                      ),
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
            if (value.trim().length >= 10) {
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
        'Wegagen Birr Phone Number',
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
      // Recipient Phone Number
      const Text(
        'Recipient Phone Number',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      const SizedBox(height: 12),
      _buildInputField(
        controller: _recipientPhoneController,
        hintText: '09XXXXXXXX',
        prefixIcon: Icons.phone,
        keyboardType: TextInputType.phone,
      ),
      const SizedBox(height: 24),
      // Full Name
      const Text(
        'Full Name',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      const SizedBox(height: 12),
      _buildInputField(
        controller: _fullNameController,
        hintText: 'Enter recipient\'s full name',
        prefixIcon: Icons.person,
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
        hintText: 'Ethiopia',
        prefixIcon: Icons.location_on,
      ),
      const SizedBox(height: 24),
      // City and Region
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                  hintText: 'City',
                  prefixIcon: null,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Region',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                _buildInputField(
                  controller: _regionController,
                  hintText: 'Region',
                  prefixIcon: null,
                ),
              ],
            ),
          ),
        ],
      ),
    ];
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
            hintText: 'Enter account number',
            hintStyle: TextStyle(color: Colors.grey.shade400),
            prefixIcon: Icon(Icons.credit_card, color: Colors.grey.shade400),
            suffixIcon: _isVerifying
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFFF37021),
                      ),
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
            if (value.trim().length >= 10) {
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
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.shade400),
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, color: Colors.grey.shade400)
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
            return 'This field is required';
          }
          return null;
        },
        onChanged: (value) {
          setState(() {
            // Trigger rebuild to update button state
          });
        },
      ),
    );
  }
}
