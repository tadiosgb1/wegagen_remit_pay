import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/environment.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final http.Client _client = http.Client();
  String? _authToken;

  // Initialize with stored token
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');
  }

  // Set auth token
  void setAuthToken(String token) {
    _authToken = token;
  }

  // Clear auth token
  void clearAuthToken() {
    _authToken = null;
  }

  // Get headers
  Map<String, String> _getHeaders({bool includeAuth = true}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-API-Key': Environment.apiKey,
    };

    if (includeAuth && _authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    return headers;
  }

  // Handle response
  Map<String, dynamic> _handleResponse(http.Response response) {
    final data = json.decode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw ApiException(
        message: data['message'] ?? 'An error occurred',
        statusCode: response.statusCode,
        errors: data['errors'],
      );
    }
  }

  // GET request
  Future<Map<String, dynamic>> get(
    String url, {
    Map<String, String>? queryParams,
    bool includeAuth = true,
  }) async {
    try {
      Uri uri = Uri.parse(url);
      if (queryParams != null) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final response = await _client.get(
        uri,
        headers: _getHeaders(includeAuth: includeAuth),
      );

      return _handleResponse(response);
    } on SocketException {
      throw ApiException(
        message: 'No internet connection',
        statusCode: 0,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Network error occurred',
        statusCode: 0,
      );
    }
  }

  // POST request
  Future<Map<String, dynamic>> post(
    String url,
    Map<String, dynamic> data, {
    bool includeAuth = true,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse(url),
        headers: _getHeaders(includeAuth: includeAuth),
        body: json.encode(data),
      );

      return _handleResponse(response);
    } on SocketException {
      throw ApiException(
        message: 'No internet connection',
        statusCode: 0,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Network error occurred',
        statusCode: 0,
      );
    }
  }

  // PUT request
  Future<Map<String, dynamic>> put(
    String url,
    Map<String, dynamic> data, {
    bool includeAuth = true,
  }) async {
    try {
      final response = await _client.put(
        Uri.parse(url),
        headers: _getHeaders(includeAuth: includeAuth),
        body: json.encode(data),
      );

      return _handleResponse(response);
    } on SocketException {
      throw ApiException(
        message: 'No internet connection',
        statusCode: 0,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Network error occurred',
        statusCode: 0,
      );
    }
  }

  // DELETE request
  Future<Map<String, dynamic>> delete(
    String url, {
    bool includeAuth = true,
  }) async {
    try {
      final response = await _client.delete(
        Uri.parse(url),
        headers: _getHeaders(includeAuth: includeAuth),
      );

      return _handleResponse(response);
    } on SocketException {
      throw ApiException(
        message: 'No internet connection',
        statusCode: 0,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Network error occurred',
        statusCode: 0,
      );
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

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } on SocketException {
      throw ApiException(
        message: 'No internet connection',
        statusCode: 0,
      );
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'File upload failed',
        statusCode: 0,
      );
    }
  }

  // Dispose
  void dispose() {
    _client.close();
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  final Map<String, dynamic>? errors;

  ApiException({
    required this.message,
    required this.statusCode,
    this.errors,
  });

  @override
  String toString() {
    return 'ApiException: $message (Status: $statusCode)';
  }
}