import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/auth_guard.dart';
import '../../providers/exchange_rate_provider.dart';
import 'amount_entry_screen.dart';

class TransferTypeScreen extends StatefulWidget {
  final String transferType;
  final String? selectedBank;

  const TransferTypeScreen({
    super.key, 
    required this.transferType,
    this.selectedBank,
  });

  @override
  State<TransferTypeScreen> createState() => _TransferTypeScreenState();
}

class _TransferTypeScreenState extends State<TransferTypeScreen> {
  String _selectedCurrency = 'USD';

  final List<Map<String, dynamic>> _currencies = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExchangeRates();
    });
  }

  Future<void> _loadExchangeRates() async {
    final exchangeProvider = Provider.of<ExchangeRateProvider>(
      context,
      listen: false,
    );
    
    // Load exchange rates if not already loaded
    if (exchangeProvider.exchangeRates.isEmpty && !exchangeProvider.isLoading) {
      await exchangeProvider.loadExchangeRates();
    }
    
    _loadCurrencies();
  }

  void _loadCurrencies() {
    final exchangeProvider = Provider.of<ExchangeRateProvider>(
      context,
      listen: false,
    );
    
    // Build currency list from exchange rates
    final currencies = <Map<String, dynamic>>[];
    exchangeProvider.exchangeRates.forEach((currency, exchangeRate) {
      currencies.add({
        'code': currency,
        'name': _getCurrencyName(currency),
        'flag': _getCurrencyFlag(currency),
        'rate': exchangeRate.rate, // This is the buying rate (used for calculations)
        'buyingRate': exchangeRate.buyingRate,
        'sellingRate': exchangeRate.sellingRate,
      });
    });
    
    setState(() {
      _currencies.clear();
      _currencies.addAll(currencies);
      if (_currencies.isNotEmpty && _selectedCurrency == 'USD') {
        _selectedCurrency = _currencies.first['code'];
      }
    });
  }

  String _getCurrencyName(String code) {
    switch (code) {
      case 'USD': return 'US Dollar';
      case 'EUR': return 'Euro';
      case 'GBP': return 'British Pound';
      case 'SAR': return 'Saudi Riyal';
      case 'AED': return 'UAE Dirham';
      case 'CAD': return 'Canadian Dollar';
      case 'AUD': return 'Australian Dollar';
      case 'JPY': return 'Japanese Yen';
      case 'CHF': return 'Swiss Franc';
      case 'SEK': return 'Swedish Krona';
      default: return code;
    }
  }

  String _getCurrencyFlag(String code) {
    switch (code) {
      case 'USD': return '🇺🇸';
      case 'EUR': return '🇪🇺';
      case 'GBP': return '🇬🇧';
      case 'SAR': return '🇸🇦';
      case 'AED': return '🇦🇪';
      case 'CAD': return '🇨🇦';
      case 'AUD': return '🇦🇺';
      case 'JPY': return '🇯🇵';
      case 'CHF': return '🇨🇭';
      case 'SEK': return '🇸🇪';
      default: return '💱';
    }
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

  String get _transferDescription {
    switch (widget.transferType) {
      case 'wegagen_bank':
        return 'Send money directly to Wegagen Bank accounts in Ethiopia';
      case 'wegagen_ebirr':
        return 'Send money to Wegagen E-birr mobile wallets';
      case 'cash_pickup':
        return 'Send money for cash pickup at authorized locations';
      case 'other_banks':
        return widget.selectedBank != null 
            ? 'Send money to ${widget.selectedBank} bank accounts'
            : 'Send money to Ethiopian bank accounts';
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
              child: Consumer<ExchangeRateProvider>(
                builder: (context, exchangeProvider, child) {
                  if (exchangeProvider.isLoading) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: Color(0xFFF37021),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Loading exchange rates...',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (exchangeProvider.error != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Failed to load exchange rates',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.red.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            exchangeProvider.error!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () => _loadExchangeRates(),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF37021),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (_currencies.isEmpty) {
                    return const Center(
                      child: Text(
                        'No currencies available',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Buy: ${currency['buyingRate']?.toStringAsFixed(2) ?? currency['rate'].toStringAsFixed(2)} ETB',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFF37021),
                                    ),
                                  ),
                                  if (currency['sellingRate'] != null)
                                    Text(
                                      'Sell: ${currency['sellingRate'].toStringAsFixed(2)} ETB',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                ],
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
                  onPressed: _currencies.isNotEmpty && _selectedCurrency.isNotEmpty
                      ? () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => AmountEntryScreen(
                                transferType: widget.transferType,
                                selectedCurrency: _selectedCurrency,
                                selectedBank: widget.selectedBank,
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
