import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../providers/payment_providers.dart';
import '../../widgets/activity_tracker.dart';
import '../../models/user.dart';
import '../../services/api_service.dart';
import '../../config/url_container.dart';
import 'payment_mobile_optimized_screen.dart';

class StreamlinedBillingScreen extends ConsumerStatefulWidget {
  final String toAccountHolder;
  final String toAccount;
  final double amount;
  final String currency;
  final double exchangeRate; // Hidden from UI but used internally
  final double originalAmount; // Original sender input amount
  final String originalCurrency; // Original sender currency

  const StreamlinedBillingScreen({
    super.key,
    required this.toAccountHolder,
    required this.toAccount,
    required this.amount,
    required this.currency,
    required this.exchangeRate,
    required this.originalAmount,
    required this.originalCurrency,
  });

  @override
  ConsumerState<StreamlinedBillingScreen> createState() =>
      _StreamlinedBillingScreenState();
}

class _StreamlinedBillingScreenState
    extends ConsumerState<StreamlinedBillingScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _address1Controller = TextEditingController();
  final _localityController = TextEditingController();
  final _administrativeAreaController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _remarkController = TextEditingController();

  String _selectedCountry = 'ET';
  bool _useLoginInfo = true; // Toggle for using login info
  bool _isLoadingUserData = false; // Loading state for user data
  User? _currentUser; // Store current user data

  final List<Map<String, String>> _countries = [
    {'code': 'ET', 'name': 'Ethiopia'},
    {'code': 'US', 'name': 'United States'},
    {'code': 'CA', 'name': 'Canada'},
    {'code': 'GB', 'name': 'United Kingdom'},
    {'code': 'AU', 'name': 'Australia'},
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (!_useLoginInfo) return;

    setState(() {
      _isLoadingUserData = true;
    });

    try {
      // First try to get user data from SharedPreferences (cached)
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user_data');

      if (userJson != null) {
        _currentUser = User.fromJson(userJson);
        _populateFieldsFromUser(_currentUser!);
      }

      // Then fetch fresh user data from API
      await _fetchUserFromAPI();
    } catch (e) {
      print('Error loading user data: $e');
      // If loading fails, use default values
      _loadDefaultUserInfo();
    } finally {
      setState(() {
        _isLoadingUserData = false;
      });
    }
  }

  Future<void> _fetchUserFromAPI() async {
    try {
      final apiService = ApiService();
      final response = await apiService.get(UrlContainer.profile);

      if (response['success'] == true && response['data'] != null) {
        _currentUser = User.fromMap(response['data']);

        // Cache the user data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', _currentUser!.toJson());

        // Populate fields with fresh data
        _populateFieldsFromUser(_currentUser!);
      }
    } catch (e) {
      print('Error fetching user from API: $e');
      // If API fails but we have cached data, keep using it
      if (_currentUser == null) {
        _loadDefaultUserInfo();
      }
    }
  }

  void _populateFieldsFromUser(User user) {
    if (!_useLoginInfo) return;

    setState(() {
      // Basic user info
      _firstNameController.text = user.firstName;
      _lastNameController.text = user.lastName;
      _emailController.text = user.email;

      // KYC data if available
      if (user.kyc != null) {
        _address1Controller.text = user.kyc!.address;
        _localityController.text = user.kyc!.city;
        _administrativeAreaController.text =
            user.kyc!.city; // Use city as state for simplicity
        _postalCodeController.text = '1000'; // Default postal code
        _selectedCountry = _getCountryCode(user.kyc!.country);
      } else {
        // Use default Ethiopian address if no KYC data
        _address1Controller.text = 'Addis Ababa, Ethiopia';
        _localityController.text = 'Addis Ababa';
        _administrativeAreaController.text = 'Addis Ababa';
        _postalCodeController.text = '1000';
        _selectedCountry = 'ET';
      }
    });
  }

  String _getCountryCode(String countryName) {
    // Map country names to codes
    final countryMap = {
      'ethiopia': 'ET',
      'united states': 'US',
      'canada': 'CA',
      'united kingdom': 'GB',
      'australia': 'AU',
    };

    return countryMap[countryName.toLowerCase()] ?? 'ET';
  }

  void _loadDefaultUserInfo() {
    // Fallback default data
    if (_useLoginInfo) {
      setState(() {
        _firstNameController.text = 'John'; // Default
        _lastNameController.text = 'Doe'; // Default
        _emailController.text = 'user@example.com'; // Default
        _address1Controller.text = 'Bole Road, Addis Ababa';
        _localityController.text = 'Addis Ababa';
        _administrativeAreaController.text = 'Addis Ababa';
        _postalCodeController.text = '1000';
        _selectedCountry = 'ET';
      });
    }
  }

  void _clearFields() {
    setState(() {
      _firstNameController.clear();
      _lastNameController.clear();
      _emailController.clear();
      _address1Controller.clear();
      _localityController.clear();
      _administrativeAreaController.clear();
      _postalCodeController.clear();
    });
  }

  void _toggleUserInfo(bool value) {
    setState(() {
      _useLoginInfo = value;
      if (value) {
        _loadUserData();
      } else {
        _clearFields();
      }
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _address1Controller.dispose();
    _localityController.dispose();
    _administrativeAreaController.dispose();
    _postalCodeController.dispose();
    _remarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Complete Payment'),
        backgroundColor: const Color(0xFFF37021),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ActivityTracker(
        interactionType: 'streamlined_billing_screen',
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTransferSummary(),
                const SizedBox(height: 24),
                _buildRemarkSection(),
                const SizedBox(height: 24),
                _buildBillingToggle(),
                const SizedBox(height: 16),
                _buildBillingInfoSection(),
                const SizedBox(height: 32),
                _buildPayNowButton(),
                const SizedBox(height: 16),
                _buildSecurityInfo(),
              ],
            ),
          ),
        ),
      ),
    );
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
          Row(
            children: [
              Icon(Icons.account_balance, color: Colors.blue.shade600),
              const SizedBox(width: 12),
              const Text(
                'Transfer Summary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildSummaryRow('To Account', widget.toAccount),
          _buildSummaryRow('Account Holder', widget.toAccountHolder),
          // Show original sender amount and currency for clarity
          _buildSummaryRow(
            'Amount',
            '${widget.originalAmount.toStringAsFixed(2)} ${widget.originalCurrency}',
          ),

          const Divider(height: 24),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF37021).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'You Pay:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  '${widget.originalAmount.toStringAsFixed(2)} ${widget.originalCurrency}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFFF37021),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildRemarkSection() {
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
          Row(
            children: [
              Icon(Icons.note_outlined, color: Colors.orange.shade600),
              const SizedBox(width: 12),
              const Text(
                'Transfer Purpose',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _remarkController,
            decoration: const InputDecoration(
              labelText: 'Purpose of Transfer *',
              hintText: 'e.g., Family support, Business payment, etc.',
              prefixIcon: Icon(Icons.edit_note),
              border: OutlineInputBorder(),
              helperText: 'Required for compliance purposes',
            ),
            maxLines: 2,
            maxLength: 100,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter the purpose of transfer';
              }
              if (value.trim().length < 3) {
                return 'Purpose must be at least 3 characters';
              }
              return null;
            },
            onChanged: (value) {
              ref.read(paymentFormProvider.notifier).updateRemark(value.trim());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBillingToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.person, color: Colors.blue.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Billing Information',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
                Text(
                  _useLoginInfo
                      ? (_currentUser?.kyc != null
                            ? 'Using your KYC verified information'
                            : 'Using your account information')
                      : 'Enter custom billing details',
                  style: TextStyle(fontSize: 12, color: Colors.blue.shade600),
                ),
                if (_isLoadingUserData)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.blue.shade600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Loading your information...',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.blue.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Switch(
            value: _useLoginInfo,
            onChanged: _isLoadingUserData ? null : _toggleUserInfo,
            activeColor: const Color(0xFFF37021),
          ),
        ],
      ),
    );
  }

  Widget _buildBillingInfoSection() {
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
          Row(
            children: [
              Icon(Icons.credit_card, color: Colors.green.shade600, size: 26),
              const SizedBox(width: 12),

              // This prevents overflow
              Expanded(
                child: Text(
                  _useLoginInfo
                      ? 'Confirm Billing Details'
                      : 'Enter Billing Details',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),

              if (_currentUser?.kyc != null && _useLoginInfo) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified,
                        size: 12,
                        color: Colors.green.shade700,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'KYC Verified',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),

          // Personal Information
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _firstNameController,
                  enabled: !_useLoginInfo && !_isLoadingUserData,
                  decoration: InputDecoration(
                    labelText: 'First Name *',
                    hintText: 'Enter your first name',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: const OutlineInputBorder(),
                    filled: _useLoginInfo || _isLoadingUserData,
                    fillColor: (_useLoginInfo || _isLoadingUserData)
                        ? Colors.grey.shade100
                        : null,
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'First name is required';
                    }
                    if (value.trim().length < 2) {
                      return 'Must be at least 2 characters';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    ref
                        .read(paymentFormProvider.notifier)
                        .updateFirstName(value.trim());
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _lastNameController,
                  enabled: !_useLoginInfo && !_isLoadingUserData,
                  decoration: InputDecoration(
                    labelText: 'Last Name *',
                    hintText: 'Enter your last name',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: const OutlineInputBorder(),
                    filled: _useLoginInfo || _isLoadingUserData,
                    fillColor: (_useLoginInfo || _isLoadingUserData)
                        ? Colors.grey.shade100
                        : null,
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Last name is required';
                    }
                    if (value.trim().length < 2) {
                      return 'Must be at least 2 characters';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    ref
                        .read(paymentFormProvider.notifier)
                        .updateLastName(value.trim());
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: _emailController,
            enabled: !_useLoginInfo && !_isLoadingUserData,
            decoration: InputDecoration(
              labelText: 'Email Address *',
              hintText: 'Enter your email address',
              prefixIcon: const Icon(Icons.email_outlined),
              border: const OutlineInputBorder(),
              filled: _useLoginInfo || _isLoadingUserData,
              fillColor: (_useLoginInfo || _isLoadingUserData)
                  ? Colors.grey.shade100
                  : null,
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Email is required';
              }
              const emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
              if (!RegExp(emailPattern).hasMatch(value.trim())) {
                return 'Please enter a valid email address';
              }
              return null;
            },
            onChanged: (value) {
              ref.read(paymentFormProvider.notifier).updateEmail(value.trim());
            },
          ),

          const SizedBox(height: 20),

          // Address Section
          Text(
            'Address Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 12),

          TextFormField(
            controller: _address1Controller,
            enabled: !_useLoginInfo && !_isLoadingUserData,
            decoration: InputDecoration(
              labelText: 'Street Address *',
              hintText: 'Enter your street address',
              prefixIcon: const Icon(Icons.home_outlined),
              border: const OutlineInputBorder(),
              filled: _useLoginInfo || _isLoadingUserData,
              fillColor: (_useLoginInfo || _isLoadingUserData)
                  ? Colors.grey.shade100
                  : null,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Street address is required';
              }
              if (value.trim().length < 5) {
                return 'Address must be at least 5 characters';
              }
              return null;
            },
            onChanged: (value) {
              ref
                  .read(paymentFormProvider.notifier)
                  .updateAddress1(value.trim());
            },
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _localityController,
                  enabled: !_useLoginInfo && !_isLoadingUserData,
                  decoration: InputDecoration(
                    labelText: 'City *',
                    hintText: 'Enter city',
                    prefixIcon: const Icon(Icons.location_city_outlined),
                    border: const OutlineInputBorder(),
                    filled: _useLoginInfo || _isLoadingUserData,
                    fillColor: (_useLoginInfo || _isLoadingUserData)
                        ? Colors.grey.shade100
                        : null,
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'City is required';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    ref
                        .read(paymentFormProvider.notifier)
                        .updateLocality(value.trim());
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _postalCodeController,
                  enabled: !_useLoginInfo && !_isLoadingUserData,
                  decoration: InputDecoration(
                    labelText: 'Postal Code *',
                    hintText: 'Enter postal code',
                    prefixIcon: const Icon(Icons.markunread_mailbox_outlined),
                    border: const OutlineInputBorder(),
                    filled: _useLoginInfo || _isLoadingUserData,
                    fillColor: (_useLoginInfo || _isLoadingUserData)
                        ? Colors.grey.shade100
                        : null,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Postal code is required';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    ref
                        .read(paymentFormProvider.notifier)
                        .updatePostalCode(value.trim());
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            value: _selectedCountry,
            decoration: InputDecoration(
              labelText: 'Country *',
              prefixIcon: const Icon(Icons.flag_outlined),
              border: const OutlineInputBorder(),
              filled: _useLoginInfo || _isLoadingUserData,
              fillColor: (_useLoginInfo || _isLoadingUserData)
                  ? Colors.grey.shade100
                  : null,
            ),
            items: _countries.map((country) {
              return DropdownMenuItem<String>(
                value: country['code'],
                child: Text(country['name']!),
              );
            }).toList(),
            onChanged: (_useLoginInfo || _isLoadingUserData)
                ? null
                : (value) {
                    if (value != null) {
                      setState(() {
                        _selectedCountry = value;
                      });
                      ref
                          .read(paymentFormProvider.notifier)
                          .updateCountry(value);
                    }
                  },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Country is required';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPayNowButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoadingUserData ? null : _proceedToPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF37021),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
        ),
        child: _isLoadingUserData
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Loading...',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.payment, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    'Pay ${widget.originalAmount.toStringAsFixed(2)} ${widget.originalCurrency} Now',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSecurityInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.security, color: Colors.green.shade600, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '🔒 Secure payment powered by CyberSource. Your card details are encrypted and never stored.',
              style: TextStyle(fontSize: 12, color: Colors.green.shade700),
            ),
          ),
        ],
      ),
    );
  }

  void _proceedToPayment() {
    if (_formKey.currentState?.validate() ?? false) {
      // Update all form data in provider
      ref
          .read(paymentFormProvider.notifier)
          .updateAccountHolder(widget.toAccountHolder);
      ref.read(paymentFormProvider.notifier).updateAccount(widget.toAccount);
      // Ensure provider stores the original sender amount and currency
      ref.read(paymentFormProvider.notifier).updateAmount(widget.originalAmount);
      ref.read(paymentFormProvider.notifier).updateCurrency(widget.originalCurrency);
      ref
          .read(paymentFormProvider.notifier)
          .updateExchangeRate(widget.exchangeRate);

      // Update billing info
      ref
          .read(paymentFormProvider.notifier)
          .updateFirstName(_firstNameController.text.trim());
      ref
          .read(paymentFormProvider.notifier)
          .updateLastName(_lastNameController.text.trim());
      ref
          .read(paymentFormProvider.notifier)
          .updateEmail(_emailController.text.trim());
      ref
          .read(paymentFormProvider.notifier)
          .updateAddress1(_address1Controller.text.trim());
      ref
          .read(paymentFormProvider.notifier)
          .updateLocality(_localityController.text.trim());
      ref
          .read(paymentFormProvider.notifier)
          .updateAdministrativeArea(_administrativeAreaController.text.trim());
      ref
          .read(paymentFormProvider.notifier)
          .updatePostalCode(_postalCodeController.text.trim());
      ref.read(paymentFormProvider.notifier).updateCountry(_selectedCountry);
      ref
          .read(paymentFormProvider.notifier)
          .updateRemark(_remarkController.text.trim());

      // Navigate to payment screen
      if (kIsWeb) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PaymentMobileOptimizedScreen()),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PaymentMobileOptimizedScreen(),
          ),
        );
      }
    }
  }
}
