import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/payment/capture_context_response.dart';
import '../models/payment/payment_form_data.dart';
import '../models/payment/payment_request.dart';
import '../models/payment/payment_response.dart';
import '../repositories/payment_repository.dart';
import '../services/payment_service.dart';
import '../services/bonus_service.dart';

// Service providers
final paymentServiceProvider = Provider<PaymentService>((ref) {
  return PaymentService();
});

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  final paymentService = ref.watch(paymentServiceProvider);
  return PaymentRepositoryImpl(paymentService);
});

// State providers
final paymentFormProvider = StateNotifierProvider<PaymentFormNotifier, PaymentFormData>((ref) {
  return PaymentFormNotifier();
});

final captureContextProvider = FutureProvider<CaptureContextResponse>((ref) async {
  final repository = ref.watch(paymentRepositoryProvider);
  return repository.getCaptureContext();
});

final paymentProcessingProvider = StateNotifierProvider<PaymentProcessingNotifier, AsyncValue<PaymentResponse?>>((ref) {
  final repository = ref.watch(paymentRepositoryProvider);
  return PaymentProcessingNotifier(repository);
});

// Payment form state notifier
class PaymentFormNotifier extends StateNotifier<PaymentFormData> {
  PaymentFormNotifier() : super(const PaymentFormData(
    toAccountHolder: '',
    toAccount: '',
    amount: 0.0,
    currency: 'ETB',
    remark: '',
    exchangeRate: 0.0,
    firstName: '',
    lastName: '',
    address1: '',
    locality: '',
    administrativeArea: '',
    postalCode: '',
    country: '',
    email: '',
  ));

  void updateAccountHolder(String value) {
    state = state.copyWith(toAccountHolder: value);
  }

  void updateAccount(String value) {
    state = state.copyWith(toAccount: value);
  }

  void updateAmount(double value) {
    state = state.copyWith(amount: value);
    _calculateBonus();
  }

  void updateCurrency(String value) {
    state = state.copyWith(currency: value);
    _calculateBonus();
  }

  void updateRemark(String value) {
    state = state.copyWith(remark: value);
  }

  void updateExchangeRate(double value) {
    state = state.copyWith(exchangeRate: value);
    _calculateBonus();
  }
  
  /// Calculate bonus in ETB only (regardless of sender currency)
  void _calculateBonus() {
    if (state.amount <= 0 || state.exchangeRate <= 0) {
      // Clear bonus if invalid data
      state = state.copyWith(bonusCalculation: null);
      return;
    }
    
    // Only calculate bonus if sender is NOT using ETB
    if (!BonusCalculator.bonusApplies(state.currency)) {
      state = state.copyWith(bonusCalculation: null);
      return;
    }
    
    try {
      final bonusCalculation = BonusCalculator.calculateBonus(
        senderAmount: state.amount,
        senderCurrency: state.currency,
        exchangeRate: state.exchangeRate,
      );
      
      state = state.copyWith(bonusCalculation: bonusCalculation);
    } catch (e) {
      // In case of error, clear bonus
      state = state.copyWith(bonusCalculation: null);
    }
  }

  void updateFirstName(String value) {
    state = state.copyWith(firstName: value);
  }

  void updateLastName(String value) {
    state = state.copyWith(lastName: value);
  }

  void updateAddress1(String value) {
    state = state.copyWith(address1: value);
  }

  void updateLocality(String value) {
    state = state.copyWith(locality: value);
  }

  void updateAdministrativeArea(String value) {
    state = state.copyWith(administrativeArea: value);
  }

  void updatePostalCode(String value) {
    state = state.copyWith(postalCode: value);
  }

  void updateCountry(String value) {
    state = state.copyWith(country: value);
  }

  void updateEmail(String value) {
    state = state.copyWith(email: value);
  }

  void reset() {
    state = const PaymentFormData(
      toAccountHolder: '',
      toAccount: '',
      amount: 0.0,
      currency: 'ETB',
      remark: '',
      exchangeRate: 0.0,
      firstName: '',
      lastName: '',
      address1: '',
      locality: '',
      administrativeArea: '',
      postalCode: '',
      country: '',
      email: '',
    );
  }
}

// Payment processing state notifier
class PaymentProcessingNotifier extends StateNotifier<AsyncValue<PaymentResponse?>> {
  final PaymentRepository _repository;

  PaymentProcessingNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> processPayment(PaymentFormData formData, String paymentToken) async {
    state = const AsyncValue.loading();

    try {
      final request = PaymentRequest(
        transientToken: paymentToken,
        firstName: formData.firstName,
        lastName: formData.lastName,
        address1: formData.address1,
        locality: formData.locality,
        administrativeArea: formData.administrativeArea,
        postalCode: formData.postalCode,
        country: formData.country,
        email: formData.email,
        exchangeRate: formData.exchangeRate,
      );

      final response = await _repository.processPayment(request);
      state = AsyncValue.data(response);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}