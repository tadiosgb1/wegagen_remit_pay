import 'dart:convert';
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/environment.dart';
import '../config/url_container.dart';

// Platform-specific imports
import 'dart:io' if (dart.library.io) 'dart:io';
import 'package:dio/io.dart' if (dart.library.io) 'package:dio/io.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart' if (dart.library.io) 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart' if (dart.library.io) 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart' if (dart.library.io) 'package:path_provider/path_provider.dart';

// Web-specific imports
import 'dart:html' as html if (dart.library.html) 'dart:html';

// Conditional File import for cross-platform compatibility
import 'dart:io' show File if (dart.library.io) 'dart:io' show File;

// Custom adapter for web platform with credentials support
class WebHttpClientAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future? cancelFuture) async {
    final completer = Completer<ResponseBody>();
    
    if (!kIsWeb) {
      throw UnsupportedError('WebHttpClientAdapter is only supported on web platform');
    }
    
    final request = html.HttpRequest();
    
    // CRITICAL: Set withCredentials BEFORE opening the request
    request.withCredentials = true;
    
    request.open(options.method, options.uri.toString());
    
    // Set headers
    options.headers.forEach((key, value) {
      try {
        request.setRequestHeader(key, value.toString());
      } catch (e) {
        if (kDebugMode) print('⚠️ Could not set header $key: $e');
      }
    });
    
    // Set response type
    request.responseType = 'text';
    
    // Handle load event (success)
    request.onLoad.listen((_) {
      final headers = <String, List<String>>{};
      final responseText = request.responseText ?? '';
      
      if (kDebugMode) print('🌐 Web request completed: ${request.status} - ${responseText.length} bytes');
      
      completer.complete(ResponseBody(
        Stream.value(Uint8List.fromList(responseText.codeUnits)),
        request.status ?? 200,
        headers: headers,
      ));
    });
    
    // Handle error event
    request.onError.listen((_) {
      if (kDebugMode) print('🌐 Web request error: ${request.status} - ${request.statusText}');
      completer.completeError(DioException(
        requestOptions: options,
        error: 'Network error: ${request.statusText}',
        type: DioExceptionType.connectionError,
        response: Response(
          requestOptions: options,
          statusCode: request.status,
          statusMessage: request.statusText,
        ),
      ));
    });
    
    // Handle timeout if specified
    if (options.receiveTimeout != null) {
      request.timeout = options.receiveTimeout!.inMilliseconds;
    }
    
    // Send request with data
    try {
      if (requestStream != null) {
        final data = await requestStream.fold<List<int>>([], (previous, element) => previous..addAll(element));
        if (data.isNotEmpty) {
          final body = String.fromCharCodes(data);
          request.send(body);
        } else {
          request.send();
        }
      } else {
        request.send();
      }
    } catch (e) {
      completer.completeError(DioException(
        requestOptions: options,
        error: 'Failed to send request: $e',
        type: DioExceptionType.connectionError,
      ));
    }
    
    return completer.future;
  }
  
  @override
  void close({bool force = false}) {
    // Nothing to close for web
  }
}

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late final Dio _dio;
  CookieJar? _cookieJar; // Make nullable for web compatibility
  String? _authToken;
  bool _isInitialized = false;
  String _currentBaseUrl = Environment.baseUrl;

  // Getter to check if initialized
  bool get isInitialized => _isInitialized;

  // Initialize Dio with SSL handling and cookie management
  Future<void> _initializeDio() async {
    _dio = Dio(BaseOptions(
      baseUrl: _currentBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-API-Key': Environment.apiKey
      },
    ));

    // Configure for web vs mobile platforms
    if (kIsWeb) {
      // For web, use our custom adapter that properly sets withCredentials
      if (kDebugMode) print('🌐 Web platform: Using custom adapter with credentials');
      _dio.httpClientAdapter = WebHttpClientAdapter();
    } else {
      // Initialize cookie jar for persistent cookies on mobile
      try {
        final appDocDir = await getApplicationDocumentsDirectory();
        final cookiePath = "${appDocDir.path}/.cookies/";
        _cookieJar = PersistCookieJar(
          ignoreExpires: true,
          storage: FileStorage(cookiePath),
        );
        if (kDebugMode) print('📁 Cookie storage path: $cookiePath');
        
        // Add cookie manager interceptor ONLY for mobile
        _dio.interceptors.add(CookieManager(_cookieJar!));
      } catch (e) {
        if (kDebugMode) print('⚠️ Cookie jar initialization failed: $e');
        // Fallback to memory-only cookies for mobile
        _cookieJar = CookieJar();
        _dio.interceptors.add(CookieManager(_cookieJar!));
      }
    }

    // Configure SSL for development
    if (!kIsWeb && Environment.isDevelopment) {
      (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();
        client.badCertificateCallback = (cert, host, port) => true;
        return client;
      };
    }

    // Add interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (kDebugMode) {
            print('🔄 Making request to: ${options.uri}');
            if (kIsWeb) {
              print('🌐 Web: Cookies handled by browser');
            } else {
              print('📱 Mobile: Cookies handled by cookie manager');
            }
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            print('✅ Response received: ${response.statusCode}');
          }
          handler.next(response);
        },
        onError: (error, handler) {
          if (kDebugMode) {
            print('❌ API Error: ${error.message}');
          }
          handler.next(error);
        },
      ),
    );

    _isInitialized = true;
  }

  // Initialize with stored token
  Future<void> initialize() async {
    if (_isInitialized) return; // Already initialized
    
    await _initializeDio(); // Initialize Dio (now async)
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');
    
    // Test backend connectivity
    await _testBackendConnectivity();
  }

  // Test backend connectivity and set working URL
  Future<void> _testBackendConnectivity() async {
    for (final url in Environment.allBackendUrls) {
      try {
        final response = await _dio.get(
          '/',
          options: Options(
            sendTimeout: const Duration(seconds: 5),
            receiveTimeout: const Duration(seconds: 5),
          ),
        );
        
        if (response.statusCode == 200) {
          _currentBaseUrl = url;
          _dio.options.baseUrl = url;
          if (kDebugMode) print('✅ Connected to backend: $url');
          return;
        }
      } catch (e) {
        if (kDebugMode) print('❌ Failed to connect to: $url - $e');
        continue;
      }
    }
    
    if (kDebugMode) print('⚠️ No backend servers responded, using default: $_currentBaseUrl');
  }

  // Set auth token
  void setAuthToken(String token) {
    _authToken = token;
  }

  // Clear auth token and cookies
  Future<void> clearAuthToken() async {
    _authToken = null;
    // Clear all cookies to log out completely
    await clearCookies();
  }

  // Clear all cookies
  Future<void> clearCookies() async {
    if (_isInitialized && !kIsWeb && _cookieJar != null) {
      await _cookieJar!.deleteAll();
      if (kDebugMode) print('🍪 All cookies cleared');
    } else if (kIsWeb) {
      if (kDebugMode) print('🌐 Web: Cookies will be cleared by server logout response');
    }
  }

  // Get cookies for debugging
  Future<List<Cookie>> getCookies(String url) async {
    if (_isInitialized && !kIsWeb && _cookieJar != null) {
      final uri = Uri.parse(url);
      return await _cookieJar!.loadForRequest(uri);
    }
    return [];
  }

  // Get current working base URL
  String get workingBaseUrl => _currentBaseUrl;

  // Handle Dio response
  Map<String, dynamic> _handleResponse(Response response) {
    if (kDebugMode) print('API Response: ${response.statusCode} - ${response.data.toString().length} bytes');
    
    if (response.statusCode! >= 200 && response.statusCode! < 300) {
      // Dio automatically handles JSON parsing
      if (response.data is Map<String, dynamic>) {
        return response.data;
      } else if (response.data is String) {
        // Return raw string wrapped in a map for consistency
        return {'data': response.data, 'success': true};
      } else {
        return {'data': response.data, 'success': true};
      }
    } else {
      throw ApiException(
        message: response.data?['message'] ?? response.data?['error'] ?? 'An error occurred',
        statusCode: response.statusCode ?? 0,
        errors: response.data?['errors'],
      );
    }
  }
Future<Map<String, dynamic>> _makeRequest(
  String method,
  String url, {
  Map<String, dynamic>? data,
  Map<String, String>? queryParams,
  bool includeAuth = true,
  int maxRetries = 2,
}) async {
  if (!_isInitialized) {
    throw ApiException(message: 'ApiService not initialized', statusCode: 0);
  }

  for (int attempt = 0; attempt <= maxRetries; attempt++) {
    try {
      Response response;

      // 1. Prepare options with Credentials and Auth Headers
      final options = Options(
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-API-Key': Environment.apiKey,
          if (includeAuth && _authToken != null)
            'Authorization': 'Bearer $_authToken',
        },
        // 2. This flag is critical for HttpOnly cookie propagation
        extra: {'withCredentials': true},
      );

      // 3. Execute Request
      response = await _dio.request(
        url,
        data: data,
        queryParameters: queryParams,
        options: options.copyWith(method: method.toUpperCase()),
      );

      return _handleResponse(response);
    } on DioException catch (e) {
      if (attempt < maxRetries && _shouldRetry(e)) {
        if (kDebugMode) print('🔄 Retrying request (attempt ${attempt + 2}): ${e.message}');
        await Future.delayed(Duration(seconds: attempt + 1));
        continue;
      }
      throw _handleDioError(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Network error: $e', statusCode: 0);
    }
  }

  throw ApiException(message: 'Request failed after $maxRetries retries', statusCode: 0);
}

  // Check if we should retry the request
  bool _shouldRetry(DioException e) {
    return e.type == DioExceptionType.connectionTimeout ||
           e.type == DioExceptionType.receiveTimeout ||
           e.type == DioExceptionType.connectionError;
  }

  // Handle Dio errors
  ApiException _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: 'Connection timeout. Please check your internet connection.',
          statusCode: 0,
        );
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode ?? 0;
        final errorData = e.response?.data;
        String message = 'An error occurred';
        
        if (errorData is Map<String, dynamic>) {
          message = errorData['message'] ?? errorData['error'] ?? message;
        } else if (errorData is String) {
          message = errorData;
        }
        
        return ApiException(
          message: message,
          statusCode: statusCode,
          errors: errorData is Map ? errorData['errors'] : null,
        );
      case DioExceptionType.cancel:
        return ApiException(message: 'Request was cancelled', statusCode: 0);
      case DioExceptionType.connectionError:
        return ApiException(message: 'Connection error. Please check your internet connection.', statusCode: 0);
      default:
        return ApiException(message: e.message ?? 'Unknown error occurred', statusCode: 0);
    }
  }

  // GET request
  Future<Map<String, dynamic>> get(
    String url, {
    Map<String, String>? queryParams,
    bool includeAuth = true,
  }) async {
    return _makeRequest('GET', url, queryParams: queryParams, includeAuth: includeAuth);
  }

  // POST request
  Future<Map<String, dynamic>> post(
    String url,
    Map<String, dynamic> data, {
    bool includeAuth = true,
  }) async {
    return _makeRequest('POST', url, data: data, includeAuth: includeAuth);
  }

  // PUT request
  Future<Map<String, dynamic>> put(
    String url,
    Map<String, dynamic> data, {
    bool includeAuth = true,
  }) async {
    return _makeRequest('PUT', url, data: data, includeAuth: includeAuth);
  }

  // DELETE request
  Future<Map<String, dynamic>> delete(
    String url, {
    bool includeAuth = true,
  }) async {
    return _makeRequest('DELETE', url, includeAuth: includeAuth);
  }

  // Cybersource-specific methods
  Future<Map<String, dynamic>> getCaptureContext() async {
    // Try primary endpoint first, then fallback
    try {
      if (kDebugMode) print('🔄 Fetching capture context from: ${UrlContainer.generateCaptureContext}');
      return await get(UrlContainer.generateCaptureContext);
    } catch (e) {
      if (kDebugMode) print('❌ Primary capture context failed, trying fallback...');
      try {
        return await get(UrlContainer.generateCaptureContextAlt);
      } catch (fallbackError) {
        if (kDebugMode) print('❌ Fallback capture context also failed: $fallbackError');
        throw ApiException(
          message: 'Failed to get capture context from all endpoints',
          statusCode: 503,
        );
      }
    }
  }

  Future<Map<String, dynamic>> processPayment(Map<String, dynamic> paymentData) async {
    // Try primary endpoint first, then fallback
    try {
      if (kDebugMode) print('🔄 Processing payment via: ${UrlContainer.processPayment}');
      return await post(UrlContainer.processPayment, paymentData);
    } catch (e) {
      if (kDebugMode) print('❌ Primary payment processing failed, trying fallback...');
      try {
        return await post(UrlContainer.processPaymentAlt, paymentData);
      } catch (fallbackError) {
        if (kDebugMode) print('❌ Fallback payment processing also failed: $fallbackError');
        throw ApiException(
          message: 'Failed to process payment on all endpoints',
          statusCode: 503,
        );
      }
    }
  }

  // Upload file using Dio
  Future<Map<String, dynamic>> uploadFile(
    String url,
    File file, {
    String fieldName = 'file',
    Map<String, String>? additionalFields,
    bool includeAuth = true,
  }) async {
    try {
      final formData = FormData();

      // Add file
      formData.files.add(MapEntry(
        fieldName,
        await MultipartFile.fromFile(file.path),
      ));

      // Add additional fields
      if (additionalFields != null) {
        for (final entry in additionalFields.entries) {
          formData.fields.add(MapEntry(entry.key, entry.value));
        }
      }

      final response = await _dio.post(
        url,
        data: formData,
        options: Options(
          headers: {
            if (includeAuth && _authToken != null && !kIsWeb)
              'Authorization': 'Bearer $_authToken',
          },
        ),
      );

      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException(message: 'File upload failed: $e', statusCode: 0);
    }
  }

  // Account search with fallback
  Future<Map<String, dynamic>> searchAccount(String accountNumber) async {
    try {
      final response = await get(
        UrlContainer.accountInfo,
        queryParams: {
          'accountNumber': accountNumber.trim(),
        },
      );
      
      return response;
    } catch (e) {
      throw ApiException(
        message: 'Invalid account or account not found',
        statusCode: 404,
      );
    }
  }

  // Health check
  Future<bool> healthCheck() async {
    try {
      await get(UrlContainer.healthCheck, includeAuth: false);
      return true;
    } catch (e) {
      try {
        await get(UrlContainer.healthCheckAlt, includeAuth: false);
        return true;
      } catch (e2) {
        return false;
      }
    }
  }

  // Dispose
  void dispose() {
    _dio.close();
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  final Map<String, dynamic>? errors;

  ApiException({required this.message, required this.statusCode, this.errors});

  @override
  String toString() {
    return 'ApiException: $message (Status: $statusCode)';
  }
}