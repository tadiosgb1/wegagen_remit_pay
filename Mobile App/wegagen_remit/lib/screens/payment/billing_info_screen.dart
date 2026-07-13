import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/payment_providers.dart';
import '../../widgets/activity_tracker.dart';
import '../../widgets/bonus_display_widget.dart';
import '../../widgets/three_ds_info_widget.dart';
import 'payment_mobile_optimized_screen.dart';

class BillingInfoScreen extends ConsumerStatefulWidget {
  final String? transferType; // Add transferType parameter
  final Map<String, dynamic>? recipientData; // Add recipient data parameter
  
  const BillingInfoScreen({
    super.key,
    this.transferType,
    this.recipientData,
  });

  @override
  ConsumerState<BillingInfoScreen> createState() => _BillingInfoScreenState();
}

class _BillingInfoScreenState extends ConsumerState<BillingInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _address1Controller = TextEditingController();
  final _localityController = TextEditingController();
  final _administrativeAreaController = TextEditingController();
  final _postalCodeController = TextEditingController();

  String _selectedCountry = 'ET';
  bool _useRecipientInfo = true; // Default to true for convenience

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
    // Pre-populate fields if toggle is on
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _populateFieldsFromRecipient();
    });
  }

  void _populateFieldsFromRecipient() {
    if (!_useRecipientInfo) return;
    
    final formData = ref.read(paymentFormProvider);
    
    // For cash pickup transfers, use different field mapping
    if (formData.toAccount.contains('cash_pickup') || formData.toAccount.isEmpty) {
      // Cash pickup: Use recipient details (stored in payment provider)
      _firstNameController.text = formData.toAccountHolder.split(' ').first;
      if (formData.toAccountHolder.split(' ').length > 1) {
        _lastNameController.text = formData.toAccountHolder.split(' ').last;
      }
      _emailController.text = 'sender@example.com'; // Default email
      _address1Controller.text = 'Main Street 123';
      _localityController.text = 'Addis Ababa';
      _administrativeAreaController.text = 'AA';
      _postalCodeController.text = '1000';
    } else {
      // Regular bank transfer: Use account holder info
      final nameParts = formData.toAccountHolder.split(' ');
      _firstNameController.text = nameParts.isNotEmpty ? nameParts.first : '';
      _lastNameController.text = nameParts.length > 1 ? nameParts.skip(1).join(' ') : '';
      _emailController.text = 'sender@example.com';
      _address1Controller.text = 'Main Street 123';
      _localityController.text = 'Addis Ababa';
      _administrativeAreaController.text = 'AA';
      _postalCodeController.text = '1000';
    }
    
    // Update payment form provider
    ref.read(paymentFormProvider.notifier).updateFirstName(_firstNameController.text);
    ref.read(paymentFormProvider.notifier).updateLastName(_lastNameController.text);
    ref.read(paymentFormProvider.notifier).updateEmail(_emailController.text);
    ref.read(paymentFormProvider.notifier).updateAddress1(_address1Controller.text);
    ref.read(paymentFormProvider.notifier).updateLocality(_localityController.text);
    ref.read(paymentFormProvider.notifier).updateAdministrativeArea(_administrativeAreaController.text);
    ref.read(paymentFormProvider.notifier).updatePostalCode(_postalCodeController.text);
    ref.read(paymentFormProvider.notifier).updateCountry(_selectedCountry);
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Billing Information'),
        backgroundColor: const Color(0xFFF37021),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ActivityTracker(
        interactionType: 'billing_info_screen',
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoCard(),
                const SizedBox(height: 24),
                _buildBillingToggle(),
                const SizedBox(height: 24),
                _buildPersonalInfoSection(),
                const SizedBox(height: 24),
                _buildAddressSection(),
                const SizedBox(height: 24),
                _buildPaymentSummarySection(),
                const SizedBox(height: 24),
                // 3DS Security Information
                const ThreeDSInfoWidget(
                  is3DSEnabled: true,
                ),
                const SizedBox(height: 32),
                _buildContinueButton(),
                const SizedBox(height: 16),
                _buildSecurityInfo(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue.shade600, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Please provide your billing information for secure payment processing.',
              style: TextStyle(fontSize: 14, color: Colors.blue.shade700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillingToggle() {
    final formData = ref.watch(paymentFormProvider);
    
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
            'Billing Options',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          
          // Toggle switch
          Row(
            children: [
              Switch(
                value: _useRecipientInfo,
                onChanged: (value) {
                  setState(() {
                    _useRecipientInfo = value;
                  });
                  
                  if (value) {
                    _populateFieldsFromRecipient();
                  } else {
                    // Clear fields when toggle is off
                    _clearBillingFields();
                  }
                },
                activeColor: const Color(0xFFF37021),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Use recipient info for billing',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _useRecipientInfo 
                          ? 'Billing fields will be populated from recipient details'
                          : 'Enter billing information manually',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Show recipient info preview when toggle is on
          if (_useRecipientInfo && formData.toAccountHolder.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange.shade600, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Using recipient: ${formData.toAccountHolder}',
                      style: TextStyle(
                        fontSize: 12, 
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _clearBillingFields() {
    _firstNameController.clear();
    _lastNameController.clear();
    _emailController.clear();
    _address1Controller.clear();
    _localityController.clear();
    _administrativeAreaController.clear();
    _postalCodeController.clear();
    
    // Clear from provider too
    ref.read(paymentFormProvider.notifier).updateFirstName('');
    ref.read(paymentFormProvider.notifier).updateLastName('');
    ref.read(paymentFormProvider.notifier).updateEmail('');
    ref.read(paymentFormProvider.notifier).updateAddress1('');
    ref.read(paymentFormProvider.notifier).updateLocality('');
    ref.read(paymentFormProvider.notifier).updateAdministrativeArea('');
    ref.read(paymentFormProvider.notifier).updatePostalCode('');
  }

  Widget _buildPersonalInfoSection() {
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
            'Personal Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'First Name *',
                    hintText: 'Enter your first name',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
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
                  decoration: const InputDecoration(
                    labelText: 'Last Name *',
                    hintText: 'Enter your last name',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
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
            decoration: const InputDecoration(
              labelText: 'Email Address *',
              hintText: 'Enter your email address',
              prefixIcon: Icon(Icons.email_outlined),
              border: OutlineInputBorder(),
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
        ],
      ),
    );
  }

  Widget _buildAddressSection() {
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
            'Billing Address',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _address1Controller,
            decoration: const InputDecoration(
              labelText: 'Street Address *',
              hintText: 'Enter your street address',
              prefixIcon: Icon(Icons.home_outlined),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Street address is required';
              }
              if (value.trim().length <2) {
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
                  decoration: const InputDecoration(
                    labelText: 'City *',
                    hintText: 'Enter city',
                    prefixIcon: Icon(Icons.location_city_outlined),
                    border: OutlineInputBorder(),
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
                  controller: _administrativeAreaController,
                  decoration: const InputDecoration(
                    labelText: 'State/Region *',
                    hintText: 'Enter state/region',
                    prefixIcon: Icon(Icons.map_outlined),
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'State/Region is required';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    ref
                        .read(paymentFormProvider.notifier)
                        .updateAdministrativeArea(value.trim());
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _postalCodeController,
                  decoration: const InputDecoration(
                    labelText: 'Postal Code *',
                    hintText: 'Enter postal code',
                    prefixIcon: Icon(Icons.markunread_mailbox_outlined),
                    border: OutlineInputBorder(),
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
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedCountry,
                  decoration: const InputDecoration(
                    labelText: 'Country *',
                    prefixIcon: Icon(Icons.flag_outlined),
                    border: OutlineInputBorder(),
                  ),
                  items: _countries.map((country) {
                    return DropdownMenuItem<String>(
                      value: country['code'],
                      child: Text(country['name']!),
                    );
                  }).toList(),
                  onChanged: (value) {
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
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummarySection() {
    final formData = ref.watch(paymentFormProvider);
    
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
            'Payment Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFF37021),
            ),
          ),
          const SizedBox(height: 16),
          
          // Basic payment information
          _buildSummaryRow('Recipient', formData.toAccountHolder),
          const SizedBox(height: 8),
          _buildSummaryRow('Account', formData.toAccount),
          const SizedBox(height: 8),
          _buildSummaryRow('Amount Sending', '${formData.amount.toStringAsFixed(2)} ${formData.currency}'),
          
          if (formData.exchangeRate > 0) ...[
            const SizedBox(height: 8),
            _buildSummaryRow('Exchange Rate', '1 ${formData.currency} = ${formData.exchangeRate.toStringAsFixed(2)} ETB'),
          ],
          
          if (formData.remark.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildSummaryRow('Remark', formData.remark),
          ],
          
          const SizedBox(height: 16),
          const Divider(),
          
          // Bonus calculation display (ETB only)
          if (formData.bonusCalculation != null) ...[
            const SizedBox(height: 16),
            BonusDisplayWidget(
              bonusCalculation: formData.bonusCalculation,
              showDetailed: true,
            ),
          ] else if (formData.amount > 0 && formData.exchangeRate > 0) ...[
            const SizedBox(height: 16),
            _buildSummaryRow(
              'Total Recipient Gets', 
              '${(formData.amount * formData.exchangeRate).toStringAsFixed(2)} ETB',
              isTotal: true,
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? const Color(0xFFF37021) : Colors.grey.shade600,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: isTotal ? const Color(0xFFF37021) : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _proceedToPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF37021),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: const Text(
          'Continue to Payment',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
              'Your information is encrypted and secure. We use industry-standard security measures.',
              style: TextStyle(fontSize: 12, color: Colors.green.shade700),
            ),
          ),
        ],
      ),
    );
  }

  void _proceedToPayment() {
    if (_formKey.currentState?.validate() ?? false) {
      // Set default country if not set
      if (_selectedCountry.isNotEmpty) {
        ref.read(paymentFormProvider.notifier).updateCountry(_selectedCountry);
      }

      // Store transfer type and recipient data in payment form provider
      if (widget.transferType != null) {
        // We need to find a way to pass transferType through the provider or navigation
        // For now, let's update the remark to include transfer type info
        final currentRemark = ref.read(paymentFormProvider).remark;
        final remarkWithType = currentRemark.isEmpty 
            ? 'Transfer type: ${widget.transferType}' 
            : '$currentRemark (${widget.transferType})';
        ref.read(paymentFormProvider.notifier).updateRemark(remarkWithType);
      }

      // Navigate to the payment screen with transfer type
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PaymentMobileOptimizedScreen(
            transferType: widget.transferType, // Pass transfer type
            recipientData: widget.recipientData, // Pass recipient data
          ),
        ),
      );
    }
  }
}
