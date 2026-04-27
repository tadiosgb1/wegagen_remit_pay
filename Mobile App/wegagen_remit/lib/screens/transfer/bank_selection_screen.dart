import 'package:flutter/material.dart';
import '../../widgets/auth_guard.dart';
import 'transfer_type_screen.dart';

class BankSelectionScreen extends StatefulWidget {
  const BankSelectionScreen({super.key});

  @override
  State<BankSelectionScreen> createState() => _BankSelectionScreenState();
}

class _BankSelectionScreenState extends State<BankSelectionScreen> {
  String? _selectedBank;

  final List<Map<String, dynamic>> _ethiopianBanks = [
    {
      'name': 'Commercial Bank of Ethiopia',
      'code': 'CBE',
      'logo': '🏦',
      'color': Color(0xFF1976D2)
    },
    {
      'name': 'Dashen Bank',
      'code': 'DASH',
      'logo': '🏛️',
      'color': Color(0xFF2E7D32)
    },
    {
      'name': 'Bank of Abyssinia',
      'code': 'BOA',
      'logo': '🏦',
      'color': Color(0xFF7B1FA2)
    },
    {
      'name': 'Awash International Bank',
      'code': 'AIB',
      'logo': '🏛️',
      'color': Color(0xFFD32F2F)
    },
    {
      'name': 'Nib International Bank',
      'code': 'NIB',
      'logo': '🏦',
      'color': Color(0xFF388E3C)
    },
    {
      'name': 'United Bank',
      'code': 'UB',
      'logo': '🏛️',
      'color': Color(0xFF1565C0)
    },
    {
      'name': 'Cooperative Bank of Oromia',
      'code': 'CBO',
      'logo': '🏦',
      'color': Color(0xFF5D4037)
    },
    {
      'name': 'Lion International Bank',
      'code': 'LIB',
      'logo': '🏛️',
      'color': Color(0xFFE65100)
    },
    {
      'name': 'Zemen Bank',
      'code': 'ZB',
      'logo': '🏦',
      'color': Color(0xFF6A1B9A)
    },
    {
      'name': 'Bunna International Bank',
      'code': 'BIB',
      'logo': '🏛️',
      'color': Color(0xFF00695C)
    },
    {
      'name': 'Berhan International Bank',
      'code': 'BERHAN',
      'logo': '🏦',
      'color': Color(0xFF4527A0)
    },
    {
      'name': 'Abay Bank',
      'code': 'ABAY',
      'logo': '🏛️',
      'color': Color(0xFF2E7D32)
    },
  ];

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
          title: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.account_balance_outlined, size: 20, color: Colors.black87),
              SizedBox(width: 8),
              Text(
                'Select Bank',
                style: TextStyle(
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
                  const Text(
                    'Choose Ethiopian Bank',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select the bank where you want to send money',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),

            // Bank List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(24),
                itemCount: _ethiopianBanks.length,
                itemBuilder: (context, index) {
                  final bank = _ethiopianBanks[index];
                  final isSelected = bank['code'] == _selectedBank;

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
                              : bank['color'].withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            bank['logo'],
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                      title: Text(
                        bank['name'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? const Color(0xFFF37021)
                              : Colors.black87,
                        ),
                      ),
                      subtitle: Text(
                        bank['code'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      trailing: Radio<String>(
                        value: bank['code'],
                        groupValue: _selectedBank,
                        onChanged: (value) {
                          setState(() {
                            _selectedBank = value;
                          });
                        },
                        activeColor: const Color(0xFFF37021),
                      ),
                      onTap: () {
                        setState(() {
                          _selectedBank = bank['code'];
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
                  onPressed: _selectedBank != null
                      ? () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => TransferTypeScreen(
                                transferType: 'other_banks',
                                selectedBank: _selectedBank,
                              ),
                            ),
                          );
                        }
                      : null,
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