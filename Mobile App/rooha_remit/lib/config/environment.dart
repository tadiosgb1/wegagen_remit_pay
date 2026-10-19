import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static String get baseUrl {
    final configuredUrl = dotenv.env['BASE_URL']?.trim();
    if (configuredUrl == null || configuredUrl.isEmpty) {
      throw StateError('BASE_URL is missing or empty in .env');
    }
    return configuredUrl;
  }

  static bool get useThreeDSFlow =>
      dotenv.env['USE_3DS_FLOW']?.trim().toLowerCase() == 'true';

  static const String _fallbackUrlOverride = String.fromEnvironment(
    'FALLBACK_URL',
  );

  static const String _apiVersion = String.fromEnvironment(
    'API_VERSION',
    defaultValue: '', // Remove API prefix - backend doesn't use it
  );

  static const bool _isDevelopment = bool.fromEnvironment(
    'DEVELOPMENT',
    defaultValue: true,
  );

  static const String _apiKey = String.fromEnvironment(
    'API_KEY',
    defaultValue: 'wegagen-remit-mobile-app-2024',
  );

  // Getters
  static String get fallbackUrl =>
      _fallbackUrlOverride.isEmpty ? baseUrl : _fallbackUrlOverride;
  static String get apiVersion => _apiVersion;
  static bool get isDevelopment => _isDevelopment;
  static String get apiKey => _apiKey;

  // All backend URLs for connectivity testing
  static List<String> get allBackendUrls => [baseUrl];

  // Full API URL with version
  static String get apiUrl => '$baseUrl$_apiVersion';
  static String get fallbackApiUrl => '$fallbackUrl$_apiVersion';

  // Backend URLs without API prefix for direct endpoints
  static String get backendUrl => baseUrl;
  static String get fallbackBackendUrl => fallbackUrl;

  // Environment info
  static String get environment =>
      _isDevelopment ? 'development' : 'production';

  // Cybersource environment
  static String get cybersourceEnvironment =>
      _isDevelopment ? 'sandbox' : 'production';
}
