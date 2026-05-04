import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/payment/capture_context_response.dart';
import '../models/payment/payment_form_data.dart';
import '../models/payment/payment_request.dart';
import '../models/payment/payment_response.dart';
import '../repositories/payment_repository.dart';
import '../services/payment_service.dart';

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
  ));

  void updateAccountHolder(String value) {
    state = state.copyWith(toAccountHolder: value);
  }

  void updateAccount(String value) {
    state = state.copyWith(toAccount: value);
  }

  void updateAmount(double value) {
    state = state.copyWith(amount: value);
  }

  void updateCurrency(String value) {
    state = state.copyWith(currency: value);
  }

  void updateRemark(String value) {
    state = state.copyWith(remark: value);
  }

  void updateExchangeRate(double value) {
    state = state.copyWith(exchangeRate: value);
  }

  void reset() {
    state = const PaymentFormData(
      toAccountHolder: '',
      toAccount: '',
      amount: 0.0,
      currency: 'ETB',
      remark: '',
      exchangeRate: 0.0,
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
        toAccountHolder: formData.toAccountHolder,
        toAccount: formData.toAccount,
        amount: formData.amount,
        currency: formData.currency,
        remark: formData.remark,
        exchangeRate: formData.exchangeRate,
        paymentToken: paymentToken,
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