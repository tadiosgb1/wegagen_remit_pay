import 'package:flutter/material.dart';
import '../../widgets/auth_guard.dart';
import 'amount_entry_screen.dart';

class TransferTypeScreen extends StatefulWidget {
  final String transferType;

  const TransferTypeScreen({super.key, required this.transferType});

  @override
  State<TransferTypeScreen> createState() => _TransferTypeScreenState();
}

class _TransferTypeScreenState extends State<TransferTypeScreen> {
  String _selectedCurrency = 'USD';

  final List<Map<String, dynamic>> _currencies = [
    {'code': 'USD', 'name': 'US Dollar', 'flag': '🇺🇸', 'rate': 154.60},
    {'code': 'EUR', 'name': 'Euro', 'flag': '🇪🇺', 'rate': 168.45},
    {'code': 'GBP', 'name': 'British Pound', 'flag': '🇬🇧', 'rate': 195.20},
    {'code': 'SAR', 'name': 'Saudi Riyal', 'flag': '🇸🇦', 'rate': 41.23},
    {'code': 'AED', 'name': 'UAE Dirham', 'flag': '🇦🇪', 'rate': 42.10},
  ];

  String get _transferTitle {
    switch (widget.transferType) {
      case 'wegagen_bank':
        return 'Bank Account Transfer';
      case 'wegagen_ebirr':
        return 'Wegagen E-birr Transfer';
      case 'cash_pickup':
        return 'Cash Pickup Transfer';
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
      case 'school_pay':
        return Icons.school;
      default:
        return Icons.send;
    }
  }

  String get _transferDescription {
    switch (widget.transferType) {
      case 'wegagen_bank':
        return 'Send money directly to Wegagen Bank accounts in Ethiopia';
      case 'wegagen_ebirr':
        return 'Send money to Wegagen E-birr mobile wallets';
      case 'cash_pickup':
        return 'Send money for cash pickup at authorized locations';
      case 'school_pay':
        return 'Pay school fees and educational expenses';
      default:
        return 'Send money securely and quickly';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      redirectMessage: 'Please login to send money transfers',
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
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
        body: Column(
          children: [
            // Header Info
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Currency',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _transferDescription,
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),

            // Currency List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: _currencies.length,
                itemBuilder: (context, index) {
                  final currency = _currencies[index];
                  final isSelected = currency['code'] == _selectedCurrency;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFF37021)
                            : Colors.grey.shade200,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(20),
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFF37021).withValues(alpha: 0.1)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            currency['flag'],
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                      title: Text(
                        currency['name'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? const Color(0xFFF37021)
                              : Colors.black87,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            currency['code'],
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '1 ${currency['code']} = ${currency['rate'].toStringAsFixed(2)} ETB',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                      trailing: Radio<String>(
                        value: currency['code'],
                        groupValue: _selectedCurrency,
                        onChanged: (value) {
                          setState(() {
                            _selectedCurrency = value!;
                          });
                        },
                        activeColor: const Color(0xFFF37021),
                      ),
                      onTap: () {
                        setState(() {
                          _selectedCurrency = currency['code'];
                        });
                      },
                    ),
                  );
                },
              ),
            ),

            // Continue Button
            Container(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AmountEntryScreen(
                          transferType: widget.transferType,
                          selectedCurrency: _selectedCurrency,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF37021),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
