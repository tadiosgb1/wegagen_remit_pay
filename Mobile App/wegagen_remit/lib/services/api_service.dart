import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';

import '../config/environment.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late Dio _dio;
  bool _initialized = false;
  late CookieJar _cookieJar;

  final String _baseUrl = Environment.baseUrl;

  // ================= GETTERS =================
  bool get isInitialized => _initialized;
  String get workingBaseUrl => _baseUrl;
  Dio get dio => _dio;

  // ================= INIT =================
  Future<void> initialize() async {
    // 🔥 FIX: prevents re-init crash (hot reload safe)
    if (_initialized && _dio.options.baseUrl == _baseUrl) return;

    // Initialize cookie jar for mobile
    if (!kIsWeb) {
      try {
        final appDocDir = await getApplicationDocumentsDirectory();
        final cookiePath = "${appDocDir.path}/.cookies/";
        _cookieJar = PersistCookieJar(
          ignoreExpires: true,
          storage: FileStorage(cookiePath),
        );
      } catch (e) {
        // Fallback to memory cookie jar if file storage fails
        _cookieJar = CookieJar();
      }
    } else {
      // Web uses browser's cookie storage
      _cookieJar = CookieJar();
    }

    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 60),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'X-API-Key': Environment.apiKey,
        },
      ),
    );

    // 🔥 prevent duplicate interceptors
    _dio.interceptors.clear();

    // Add cookie manager FIRST
    _dio.interceptors.add(CookieManager(_cookieJar));

    // Add logging interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (kDebugMode) {
            print("🔄 [${options.method}] ${options.uri}");
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            print("✅ RESPONSE: ${response.statusCode}");
          }
          handler.next(response);
        },
        onError: (error, handler) {
          if (kDebugMode) {
            print("❌ ERROR: ${error.message}");
          }
          handler.next(error);
        },
      ),
    );

    _initialized = true;
  }

  // ================= COOKIE METHODS =================
  Future<void> clearCookies() async {
    await _cookieJar.deleteAll();
    
    // Also clear any stored preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('refresh_token');
  }

  Future<List<Cookie>> getCookies(String url) async {
    final uri = Uri.parse(url);
    return await _cookieJar.loadForRequest(uri);
  }

  // ================= HEALTH CHECK =================
  Future<bool> healthCheck() async {
    try {
      await get('/health', includeAuth: false);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Health check failed: $e');
      }
      return false;
    }
  }

  // ================= CORE REQUEST ============
  Future<Map<String, dynamic>> _request(
    String method,
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParams,
    bool includeAuth = true,
  }) async {
    if (!_initialized) {
      await initialize();
    }

    final options = Options(
      method: method,
      headers: {
        'X-API-Key': Environment.apiKey,
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );

    // For web, we need to set withCredentials to true to send cookies
    if (kIsWeb) {
      options.extra = {'withCredentials': true};
    }

    try {
      final response = await _dio.request(
        url,
        data: data,
        queryParameters: queryParams,
        options: options,
      );

      if (response.data is Map<String, dynamic>) {
        return response.data;
      }

      return {
        "success": true,
        "data": response.data,
      };
    } on DioException catch (e) {
      throw ApiException(
        message: _extractError(e),
        statusCode: e.response?.statusCode ?? 0,
      );
    }
  }

  // ================= ERROR PARSER =================
  String _extractError(DioException e) {
    try {
      final data = e.response?.data;

      if (data is Map && data['message'] != null) {
        return data['message'];
      }

      return e.message ?? 'Request failed';
    } catch (_) {
      return 'Request failed';
    }
  }

  // ================= PUBLIC METHODS =================
  Future<Map<String, dynamic>> get(
    String url, {
    Map<String, dynamic>? queryParams,
    bool includeAuth = true,
  }) {
    return _request(
      'GET',
      url,
      queryParams: queryParams,
      includeAuth: includeAuth,
    );
  }

  Future<Map<String, dynamic>> post(
    String url,
    Map<String, dynamic> data, {
    bool includeAuth = true,
  }) {
    return _request(
      'POST',
      url,
      data: data,
      includeAuth: includeAuth,
    );
  }

  Future<Map<String, dynamic>> put(
    String url,
    Map<String, dynamic> data, {
    bool includeAuth = true,
  }) {
    return _request(
      'PUT',
      url,
      data: data,
      includeAuth: includeAuth,
    );
  }

  Future<Map<String, dynamic>> delete(
    String url, {
    bool includeAuth = true,
  }) {
    return _request(
      'DELETE',
      url,
      includeAuth: includeAuth,
    );
  }

  // ================= FORM DATA =================
  Future<Map<String, dynamic>> postFormData(
    String url,
    FormData formData, {
    bool includeAuth = true,
  }) {
    return _request(
      'POST',
      url,
      data: formData,
      includeAuth: includeAuth,
    );
  }



  

  // ================= FILE UPLOAD =================
  Future<Map<String, dynamic>> uploadFile(
  String url,
  File file, {
  String fieldName = 'file',
  Map<String, String>? additionalFields,
  bool includeAuth = true,
}) async {
  final formData = FormData();

  formData.files.add(
    MapEntry(fieldName, await MultipartFile.fromFile(file.path)),
  );

  additionalFields?.forEach((k, v) {
    formData.fields.add(MapEntry(k, v));
  });

  return postFormData(url, formData, includeAuth: includeAuth);
}


}

// ================= EXCEPTION =================
class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException({
    required this.message,
    required this.statusCode,
  });

  @override
  String toString() => "ApiException: $message ($statusCode)";
}