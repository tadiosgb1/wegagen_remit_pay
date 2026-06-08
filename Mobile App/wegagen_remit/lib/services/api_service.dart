import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:http/browser_client.dart' if (dart.library.html) 'package:http/browser_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/environment.dart';
import '../config/url_container.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  http.Client? _client;
  String? _authToken;
  bool _isInitialized = false;
  String _currentBaseUrl = Environment.baseUrl;

  // Getter to check if initialized
  bool get isInitialized => _isInitialized;

  // Initialize client with SSL handling and credentials
  void _initializeClient() {
    if (_client != null) return; // Already initialized
    
    if (kIsWeb) {
      // For web, use BrowserClient with credentials enabled for HTTP-only cookies
      try {
        _client = BrowserClient()..withCredentials = true;
      } catch (e) {
        debugPrint('Failed to create BrowserClient with credentials, falling back to regular client: $e');
        _client = http.Client();
      }
    } else if (Environment.isDevelopment) {
      // For mobile development, create HTTP client that accepts self-signed certificates
      final httpClient = HttpClient()
        ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      httpClient.connectionTimeout = const Duration(seconds: 15);
      httpClient.idleTimeout = const Duration(seconds: 30);
      _client = IOClient(httpClient);
    } else {
      _client = http.Client();
    }
  }

  // Initialize with stored token
  Future<void> initialize() async {
    if (_isInitialized) return; // Already initialized
    
    _initializeClient(); // Initialize the HTTP client
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');
    _isInitialized = true;
    
    // Test backend connectivity
    await _testBackendConnectivity();
  }

  // Test backend connectivity and set working URL
  Future<void> _testBackendConnectivity() async {
    for (final url in Environment.allBackendUrls) {
      try {
        final response = await _client!.get(
          Uri.parse('$url/'),
          headers: {'Content-Type': 'application/json'},
        ).timeout(const Duration(seconds: 5));
        
        if (response.statusCode == 200) {
          _currentBaseUrl = url;
          debugPrint('✅ Connected to backend: $url');
          return;
        }
      } catch (e) {
        debugPrint('❌ Failed to connect to: $url - $e');
        continue;
      }
    }
    
    debugPrint('⚠️ No backend servers responded, using default: $_currentBaseUrl');
  }

  // Set auth token
  void setAuthToken(String token) {
    _authToken = token;
  }

  // Clear auth token
  void clearAuthToken() {
    _authToken = null;
  }

  // Get current working base URL
  String get workingBaseUrl => _currentBaseUrl;

  // Get headers
  Map<String, String> _getHeaders({bool includeAuth = true}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-API-Key': Environment.apiKey,
      'User-Agent': 'WegagenRemit-Mobile/1.0.0',
    };

    // For web, rely on HTTP-only cookies for authentication
    // For mobile, use Bearer token if available
    if (includeAuth && !kIsWeb && _authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    return headers;
  }

  // Handle response with better error handling
  Map<String, dynamic> _handleResponse(http.Response response) {
    debugPrint('API Response: ${response.statusCode} - ${response.body.length} bytes');
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // Try to parse as JSON first
      try {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return data;
      } catch (e) {
        // If JSON parsing fails, check if it's a raw string (like JWT token)
        final body = response.body.trim();
        if (body.isNotEmpty) {
          // Return the raw string wrapped in a map for consistency
          return {'data': body, 'success': true};
        } else {
          return {'success': true};
        }
      }
    } else {
      // Try to parse error response as JSON
      try {
        final data = json.decode(response.body) as Map<String, dynamic>;
        throw ApiException(
          message: data['message'] ?? data['error'] ?? 'An error occurred',
          statusCode: response.statusCode,
          errors: data['errors'],
        );
      } catch (e) {
        // If error response is not JSON, use raw body
        throw ApiException(
          message: response.body.isNotEmpty ? response.body : 'An error occurred',
          statusCode: response.statusCode,
        );
      }
    }
  }

  // Generic request method with retry logic
  Future<Map<String, dynamic>> _makeRequest(
    String method,
    String url, {
    Map<String, dynamic>? data,
    Map<String, String>? queryParams,
    bool includeAuth = true,
    int maxRetries = 2,
  }) async {
    if (_client == null) {
      throw ApiException(message: 'ApiService not initialized', statusCode: 0);
    }

    Uri uri = Uri.parse(url);
    if (queryParams != null) {
      uri = uri.replace(queryParameters: queryParams);
    }

    for (int attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        http.Response response;
        
        switch (method.toUpperCase()) {
          case 'GET':
            response = await _client!.get(
              uri,
              headers: _getHeaders(includeAuth: includeAuth),
            ).timeout(const Duration(seconds: 30));
            break;
          case 'POST':
            response = await _client!.post(
              uri,
              headers: _getHeaders(includeAuth: includeAuth),
              body: data != null ? json.encode(data) : null,
            ).timeout(const Duration(seconds: 30));
            break;
          case 'PUT':
            response = await _client!.put(
              uri,
              headers: _getHeaders(includeAuth: includeAuth),
              body: data != null ? json.encode(data) : null,
            ).timeout(const Duration(seconds: 30));
            break;
          case 'DELETE':
            response = await _client!.delete(
              uri,
              headers: _getHeaders(includeAuth: includeAuth),
            ).timeout(const Duration(seconds: 30));
            break;
          default:
            throw ApiException(message: 'Unsupported HTTP method: $method', statusCode: 0);
        }

        return _handleResponse(response);
      } on SocketException catch (e) {
        if (attempt < maxRetries) {
          debugPrint('🔄 Retrying request (attempt ${attempt + 2}): $e');
          await Future.delayed(Duration(seconds: attempt + 1));
          continue;
        }
        throw ApiException(message: 'No internet connection', statusCode: 0);
      } on HttpException catch (e) {
        if (attempt < maxRetries) {
          debugPrint('🔄 Retrying request (attempt ${attempt + 2}): $e');
          await Future.delayed(Duration(seconds: attempt + 1));
          continue;
        }
        throw ApiException(message: 'Network error: ${e.message}', statusCode: 0);
      } catch (e) {
        if (e is ApiException) rethrow;
        if (attempt < maxRetries) {
          debugPrint('🔄 Retrying request (attempt ${attempt + 2}): $e');
          await Future.delayed(Duration(seconds: attempt + 1));
          continue;
        }
        throw ApiException(message: 'Network error occurred: $e', statusCode: 0);
      }
    }
    
    throw ApiException(message: 'Request failed after $maxRetries retries', statusCode: 0);
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
      debugPrint('🔄 Fetching capture context from: ${UrlContainer.generateCaptureContext}');
      return await get(UrlContainer.generateCaptureContext);
    } catch (e) {
      debugPrint('❌ Primary capture context failed, trying fallback...');
      try {
        return await get(UrlContainer.generateCaptureContextAlt);
      } catch (fallbackError) {
        debugPrint('❌ Fallback capture context also failed: $fallbackError');
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
      debugPrint('🔄 Processing payment via: ${UrlContainer.processPayment}');
      return await post(UrlContainer.processPayment, paymentData);
    } catch (e) {
      debugPrint('❌ Primary payment processing failed, trying fallback...');
      try {
        return await post(UrlContainer.processPaymentAlt, paymentData);
      } catch (fallbackError) {
        debugPrint('❌ Fallback payment processing also failed: $fallbackError');
        throw ApiException(
          message: 'Failed to process payment on all endpoints',
          statusCode: 503,
        );
      }
    }
  }

  // Upload file
  Future<Map<String, dynamic>> uploadFile(
    String url,
    File file, {
    String fieldName = 'file',
    Map<String, String>? additionalFields,
    bool includeAuth = true,
  }) async {
    if (_client == null) {
      throw ApiException(message: 'ApiService not initialized', statusCode: 0);
    }
    
    try {
      final request = http.MultipartRequest('POST', Uri.parse(url));

      // Add headers
      request.headers.addAll(_getHeaders(includeAuth: includeAuth));

      // Add file
      request.files.add(
        await http.MultipartFile.fromPath(fieldName, file.path),
      );

      // Add additional fields
      if (additionalFields != null) {
        request.fields.addAll(additionalFields);
      }

      final streamedResponse = await _client!.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } on SocketException {
      throw ApiException(message: 'No internet connection', statusCode: 0);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'File upload failed', statusCode: 0);
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
    _client?.close();
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
