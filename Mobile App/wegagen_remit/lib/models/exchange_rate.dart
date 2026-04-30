class ExchangeRate {
  final String fromCurrency;
  final String toCurrency;
  final double buyingRate;
  final double sellingRate;
  final DateTime lastUpdated;

  ExchangeRate({
    required this.fromCurrency,
    required this.toCurrency,
    required this.buyingRate,
    required this.sellingRate,
    required this.lastUpdated,
  });

  // Use buying rate for calculations (what bank pays for foreign currency)
  double get rate => buyingRate;

  factory ExchangeRate.fromJson(Map<String, dynamic> json) {
    return ExchangeRate(
      fromCurrency: json['fromCurrency'],
      toCurrency: json['toCurrency'],
      buyingRate: json['buyingRate'].toDouble(),
      sellingRate: json['sellingRate'].toDouble(),
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fromCurrency': fromCurrency,
      'toCurrency': toCurrency,
      'buyingRate': buyingRate,
      'sellingRate': sellingRate,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}