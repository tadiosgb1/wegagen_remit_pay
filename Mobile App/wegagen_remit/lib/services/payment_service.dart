import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/environment.dart';
import '../config/url_container.dart';
import '../models/payment/capture_context_response.dart';
import '../models/payment/payment_request.dart';
import '../models/payment/payment_response.dart';
import 'auth_service.dart';

class PaymentService {
  late final Dio _dio;
  final AuthService _authService = AuthService();

  PaymentService() {
    _dio = Dio(BaseOptions(
      baseUrl: Environment.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add auth interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // Token expired, try to refresh
          try {
            final refreshedResponse = await _authService.refreshToken();
            // Retry the request with new token
            error.requestOptions.headers['Authorization'] = 'Bearer ${refreshedResponse.accessToken}';
            final response = await _dio.fetch(error.requestOptions);
            handler.resolve(response);
            return;
          } catch (e) {
            // Refresh failed, let the error pass through
          }
        }
        handler.next(error);
      },
    ));

    // Add logging interceptor for debugging
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (object) {
        // Only log in debug mode
        if (Environment.isDevelopment) {
          print(object);
        }
      },
    ));
  }

  /// Generate capture context for CyberSource payment
  Future<CaptureContextResponse> getCaptureContext() async {
    try {
      final response = await _dio.post(UrlContainer.generateCaptureContext);
      
      if (response.statusCode == 200) {
        // Handle case where response is a string (JWT token) instead of JSON
        if (response.data is String) {
          // The response is directly the capture context JWT token
          return CaptureContextResponse(
            status: 'success',
            data: CaptureContextData(
              captureContext: response.data as String,
              sessionId: null,
            ),
          );
        } else {
          // Normal JSON response
          return CaptureContextResponse.fromJson(response.data);
        }
      } else {
        throw PaymentException(
          'Failed to generate capture context: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw PaymentException('Unexpected error: $e');
    }
  }

  /// Process payment with CyberSource token
  Future<PaymentResponse> processPayment(PaymentRequest request) async {
    try {
      final response = await _dio.post(
        UrlContainer.processPayment,
        data: request.toJson(),
      );
      
      if (response.statusCode == 200) {
        return PaymentResponse.fromJson(response.data);
      } else {
        throw PaymentException(
          'Payment processing failed: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw PaymentException('Unexpected error: $e');
    }
  }

  PaymentException _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return PaymentException(
          'Connection timeout. Please check your internet connection.',
          statusCode: e.response?.statusCode,
        );
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.response?.data?['message'] ?? 
                       e.response?.data?['error'] ?? 
                       'Server error occurred';
        return PaymentException(
          message,
          statusCode: statusCode,
        );
      case DioExceptionType.cancel:
        return PaymentException('Request was cancelled');
      case DioExceptionType.connectionError:
        return PaymentException(
          'No internet connection. Please check your network.',
        );
      default:
        return PaymentException(
          'Network error: ${e.message}',
          statusCode: e.response?.statusCode,
        );
    }
  }
}

class PaymentException implements Exception {
  final String message;
  final int? statusCode;

  const PaymentException(this.message, {this.statusCode});

  @override
  String toString() => 'PaymentException: $message';
}