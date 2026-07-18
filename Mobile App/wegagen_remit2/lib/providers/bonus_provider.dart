import 'package:flutter/material.dart';
import '../models/bonus.dart';
import '../services/api_service.dart';
import '../config/url_container.dart';

class BonusProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Bonus> _bonuses = [];
  bool _isLoading = false;
  String? _error;
  DateTime? _lastUpdated;

  List<Bonus> get bonuses => _bonuses;
  List<Bonus> get activeBonuses => _bonuses.where((bonus) => bonus.status).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastUpdated => _lastUpdated;

  // Get the primary active bonus (first active bonus)
  Bonus? get primaryBonus {
    final active = activeBonuses;
    return active.isNotEmpty ? active.first : null;
  }

  // Calculate bonus amount in ETB - FIXED ETB PER UNIT FOR ALL CURRENCIES
  double calculateBonusAmount(double foreignAmount, String currency) {
    final bonus = primaryBonus;
    if (bonus == null || !bonus.status) {
      debugPrint('❌ No active bonus found!');
      return 0.0;
    }
    
    debugPrint('🎁 BONUS CALCULATION DEBUG:');
    debugPrint('   💰 Bonus from API: ${bonus.amount} ETB per unit');
    debugPrint('   🌍 Foreign Amount: $foreignAmount $currency');
    debugPrint('   🧮 Calculation: $foreignAmount × ${bonus.amount} = ${foreignAmount * bonus.amount} ETB');
    
    // Fixed ETB per unit, same for all currencies
    // Example from /bones API: amount = 5.00 ETB per unit
    // 1 USD = 5 ETB bonus, 1 EUR = 5 ETB bonus
    // 10 USD = 10 * 5 = 50 ETB bonus, 10 EUR = 10 * 5 = 50 ETB bonus
    final calculatedBonus = foreignAmount * bonus.amount;
    
    debugPrint('   ✅ Final Bonus: $calculatedBonus ETB');
    return calculatedBonus;
  }

  // Calculate total amount after exchange rate and bonus
  double calculateTotalWithBonus(
    double foreignAmount, 
    String fromCurrency, 
    double exchangeRate,
  ) {
    // Convert foreign currency to ETB using exchange rate
    final amountInETB = foreignAmount * exchangeRate;
    
    // Add bonus: foreignAmount * bonus per unit
    final bonusAmountETB = calculateBonusAmount(foreignAmount, fromCurrency);
    
    debugPrint('💰 Per-Unit Bonus Calculation:');
    debugPrint('   Foreign Amount: $foreignAmount $fromCurrency');
    debugPrint('   Exchange Rate: $exchangeRate ETB per $fromCurrency');
    debugPrint('   Amount in ETB: $amountInETB ETB');
    debugPrint('   Bonus per unit: ${primaryBonus?.amount ?? 0} ETB per unit (from /bones API)');
    debugPrint('   Total Bonus: $foreignAmount * ${primaryBonus?.amount ?? 0} = $bonusAmountETB ETB');
    debugPrint('   Final Total: ${amountInETB + bonusAmountETB} ETB');
    
    return amountInETB + bonusAmountETB;
  }

  Future<void> loadBonuses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('🎁 Loading bonuses from /bones API...');
      
      final response = await _apiService.get(UrlContainer.getBonuses);
      debugPrint('🎁 Bonuses API Response: $response');
      
      if (response['status'] == 'success') {
        final bonusResponse = BonusResponse.fromJson(response);
        _bonuses = bonusResponse.data;
        _lastUpdated = DateTime.now();
        
        debugPrint('✅ Loaded ${_bonuses.length} bonuses');
        debugPrint('🎁 Active bonuses: ${activeBonuses.length}');
        if (primaryBonus != null) {
          debugPrint('💰 Primary bonus: ${primaryBonus!.description} - ${primaryBonus!.amount} ETB per unit');
        }
      } else {
        throw Exception(response['message'] ?? 'Failed to load bonuses');
      }
      
      _isLoading = false;
      _error = null;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Bonus API error: $e');
      
      _error = e.toString();
      _isLoading = false;
      
      // Load fallback bonus for testing
      _loadFallbackBonus();
      
      notifyListeners();
    }
  }

  void _loadFallbackBonus() {
    // Fallback bonus for development/testing
    _bonuses = [
      Bonus(
        id: 1,
        description: 'Daily Bonus - Development Fallback',
        amount: 5.00, // 5 ETB per USD/EUR etc
        status: true,
      ),
    ];
    _lastUpdated = DateTime.now();
    _error = null;
    
    debugPrint('🎁 Using fallback bonus: 5.00 ETB per foreign currency unit');
  }

  // Force refresh bonuses
  Future<void> refreshBonuses() async {
    await loadBonuses();
  }

  // Get bonus description for UI
  String getBonusDescription() {
    final bonus = primaryBonus;
    if (bonus == null) {
      return 'No bonus available';
    }
    
    return '${bonus.description}: +${bonus.amount.toStringAsFixed(2)} ETB per unit';
  }

  // Check if any bonuses are active
  bool get hasBonusActive => activeBonuses.isNotEmpty;
}