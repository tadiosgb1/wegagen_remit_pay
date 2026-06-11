import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import '../config/environment.dart';
import '../config/url_container.dart';
import '../models/payment/capture_context_response.dart';
import '../models/payment/payment_request.dart';
import '../models/payment/payment_response.dart';

class PaymentService {
  late final Dio _dio;

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

    // Initialize HTTP client with SSL handling for development
    if (!kIsWeb && Environment.isDevelopment) {
      (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final httpClient = HttpClient();
        httpClient.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
        return httpClient;
      };
    }

    // Add interceptors for debugging and error handling
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token if available
          final headers = await _getHeaders();
          options.headers.addAll(headers);
          handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            print('Payment API Response: ${response.statusCode}');
          }
          handler.next(response);
        },
        onError: (error, handler) {
          if (kDebugMode) {
            print('Payment API Error: ${error.message}');
          }
          handler.next(error);
        },
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: false, // Don't log sensitive payment data
        responseBody: false, // Don't log sensitive response data
        requestHeader: false,
        responseHeader: false,
      ));
    }
  }

  /// Generate capture context for CyberSource payment
  Future<CaptureContextResponse> getCaptureContext() async {
    try {
      final response = await _dio.post(
        UrlContainer.generateCaptureContext,
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        String captureContextToken;
        
        // Handle different response formats
        try {
          final data = response.data;
          if (data is String) {
            captureContextToken = data;
          } else if (data is Map<String, dynamic>) {
            if (data.containsKey('captureContext')) {
              captureContextToken = data['captureContext'] as String;
            } else if (data.containsKey('data') && data['data'] is Map) {
              captureContextToken = data['data']['captureContext'] as String;
            } else {
              // Try to find any JWT-like string in the response
              final jsonStr = data.toString();
              const jwtPattern = r'eyJ[A-Za-z0-9_-]+\.eyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+';
              final jwtMatch = RegExp(jwtPattern).firstMatch(jsonStr);
              if (jwtMatch != null) {
                captureContextToken = jwtMatch.group(0)!;
              } else {
                throw const PaymentException('No valid capture context found in response');
              }
            }
          } else {
            throw const PaymentException('Invalid response format from server');
          }
        } catch (e) {
          // If parsing fails, treat response as raw string
          captureContextToken = response.data.toString().trim();
        }
        
        // Validate the token format
        if (captureContextToken.isEmpty || !captureContextToken.contains('.')) {
          throw const PaymentException('Invalid capture context token format');
        }
        
        if (kDebugMode) {
          print('Capture context token received: ${captureContextToken.substring(0, 50)}...');
        }
        
        return CaptureContextResponse(
          status: 'success',
          data: CaptureContextData(
            captureContext: captureContextToken,
            sessionId: null,
          ),
        );
      } else {
        throw PaymentException(
          'Failed to generate capture context: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw const PaymentException('No internet connection. Please check your network.');
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is PaymentException) rethrow;
      if (kDebugMode) {
        print('Exception in getCaptureContext: $e');
      }
      throw PaymentException('Unexpected error: $e');
    }
  }

  /// Process payment with CyberSource token
  Future<PaymentResponse> processPayment(PaymentRequest request) async {
    try {
      final response = await _dio.post(
        UrlContainer.processPayment,
        data: request.toJson(),
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        return PaymentResponse.fromJson(response.data);
      } else {
        throw PaymentException(
          'Payment processing failed: ${response.statusMessage}',
          statusCode: response.statusCode,
        );
      }
    } on SocketException {
      throw const PaymentException('No internet connection. Please check your network.');
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is PaymentException) rethrow;
      throw PaymentException('Unexpected error: $e');
    }
  }

  /// Get headers with auth token
  Future<Map<String, String>> _getHeaders() async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting auth token: $e');
      }
    }

    return headers;
  }

  PaymentException _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const PaymentException('Connection timeout. Please check your network.');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode ?? 0;
        final errorData = e.response?.data;
        String message = 'Payment processing failed';
        
        if (errorData is Map<String, dynamic>) {
          message = errorData['message'] ?? errorData['error'] ?? message;
        } else if (errorData is String) {
          message = errorData;
        }
        
        return PaymentException(message, statusCode: statusCode);
      case DioExceptionType.cancel:
        return const PaymentException('Request was cancelled');
      case DioExceptionType.connectionError:
        return const PaymentException('Connection error. Please check your network.');
      default:
        return PaymentException(e.message ?? 'Unknown error occurred');
    }
  }

  void dispose() {
    _dio.close();
  }
}

class PaymentException implements Exception {
  final String message;
  final int? statusCode;

  const PaymentException(this.message, {this.statusCode});

  @override
  String toString() => 'PaymentException: $message';
}