import '../models/payment/capture_context_response.dart';
import '../models/payment/payment_request.dart';
import '../models/payment/payment_response.dart';
import '../services/payment_service.dart';

abstract class PaymentRepository {
  Future<CaptureContextResponse> getCaptureContext();
  Future<PaymentResponse> processPayment(PaymentRequest request);
}

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentService _paymentService;

  PaymentRepositoryImpl(this._paymentService);

  @override
  Future<CaptureContextResponse> getCaptureContext() async {
    try {
      return await _paymentService.getCaptureContext();
    } catch (e) {
      // Log error for debugging
      print('PaymentRepository: getCaptureContext error: $e');
      rethrow;
    }
  }

  @override
  Future<PaymentResponse> processPayment(PaymentRequest request) async {
    try {
      return await _paymentService.processPayment(request);
    } catch (e) {
      // Log error for debugging
      print('PaymentRepository: processPayment error: $e');
      rethrow;
    }
  }
}