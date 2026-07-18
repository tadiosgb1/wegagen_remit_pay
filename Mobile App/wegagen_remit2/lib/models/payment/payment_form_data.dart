import '../../services/bonus_service.dart';

class PaymentFormData {
  final String toAccountHolder;
  final String toAccount;
  final double amount;
  final String currency;
  final String remark;
  final double exchangeRate;
  final BonusCalculation? bonusCalculation; // ETB bonus calculation

  // Billing information
  final String firstName;
  final String lastName;
  final String address1;
  final String locality;
  final String administrativeArea;
  final String postalCode;
  final String country;
  final String email;

  const PaymentFormData({
    required this.toAccountHolder,
    required this.toAccount,
    required this.amount,
    required this.currency,
    required this.remark,
    required this.exchangeRate,
    required this.firstName,
    required this.lastName,
    required this.address1,
    required this.locality,
    required this.administrativeArea,
    required this.postalCode,
    required this.country,
    required this.email,
    this.bonusCalculation,
  });

  PaymentFormData copyWith({
    String? toAccountHolder,
    String? toAccount,
    double? amount,
    String? currency,
    String? remark,
    double? exchangeRate,
    String? firstName,
    String? lastName,
    String? address1,
    String? locality,
    String? administrativeArea,
    String? postalCode,
    String? country,
    String? email,
    BonusCalculation? bonusCalculation,
  }) {
    return PaymentFormData(
      toAccountHolder: toAccountHolder ?? this.toAccountHolder,
      toAccount: toAccount ?? this.toAccount,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      remark: remark ?? this.remark,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      address1: address1 ?? this.address1,
      locality: locality ?? this.locality,
      administrativeArea: administrativeArea ?? this.administrativeArea,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      email: email ?? this.email,
      bonusCalculation: bonusCalculation ?? this.bonusCalculation,
    );
  }

  bool get isValid {
    return toAccountHolder.isNotEmpty &&
        toAccount.isNotEmpty &&
        amount > 0 &&
        currency.isNotEmpty &&
        remark.isNotEmpty &&
        exchangeRate > 0 &&
        firstName.isNotEmpty &&
        lastName.isNotEmpty &&
        address1.isNotEmpty &&
        locality.isNotEmpty &&
        administrativeArea.isNotEmpty &&
        postalCode.isNotEmpty &&
        country.isNotEmpty &&
        email.isNotEmpty;
  }
}
