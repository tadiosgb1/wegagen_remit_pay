import 'package:flutter/material.dart';
import '../models/exchange_rate.dart';

class ExchangeRateProvider with ChangeNotifier {
  Map<String, ExchangeRate> _exchangeRates = {};
  bool _isLoading = false;
  String? _error;

  Map<String, ExchangeRate> get exchangeRates => _exchangeRates;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadExchangeRates() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Mock exchange rates data
      final mockRates = {
        'USD': ExchangeRate(
          fromCurrency: 'USD',
          toCurrency: 'ETB',
          rate: 154.60,
          lastUpdated: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        'EUR': ExchangeRate(
          fromCurrency: 'EUR',
          toCurrency: 'ETB',
          rate: 168.45,
          lastUpdated: DateTime.now().subtract(const Duration(minutes: 30)),
        ),
        'GBP': ExchangeRate(
          fromCurrency: 'GBP',
          toCurrency: 'ETB',
          rate: 195.20,
          lastUpdated: DateTime.now().subtract(const Duration(hours: 1)),
        ),
        'SAR': ExchangeRate(
          fromCurrency: 'SAR',
          toCurrency: 'ETB',
          rate: 41.23,
          lastUpdated: DateTime.now().subtract(const Duration(minutes: 15)),
        ),
        'AED': ExchangeRate(
          fromCurrency: 'AED',
          toCurrency: 'ETB',
          rate: 42.10,
          lastUpdated: DateTime.now(),
        ),
      };

      _exchangeRates = mockRates;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load exchange rates';
      _isLoading = false;
      notifyListeners();
    }
  }

  double? getRate(String fromCurrency, String toCurrency) {
    if (toCurrency == 'ETB' && _exchangeRates.containsKey(fromCurrency)) {
      return _exchangeRates[fromCurrency]?.rate;
    }
    return null;
  }

  ExchangeRate? getExchangeRate(String fromCurrency) {
    return _exchangeRates[fromCurrency];
  }
}