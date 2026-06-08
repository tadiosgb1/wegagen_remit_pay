class Environment {
  static const String _baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://10.195.49.21:3001', // Updated to new backend URL
  );

  static const String _fallbackUrl = String.fromEnvironment(
    'FALLBACK_URL',
    defaultValue: 'http://10.195.49.18:3001', // Fallback to previous URL
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
  static String get baseUrl => _baseUrl;
  static String get fallbackUrl => _fallbackUrl;
  static String get apiVersion => _apiVersion;
  static bool get isDevelopment => _isDevelopment;
  static String get apiKey => _apiKey;

  // Multiple backend URLs for failover
  static const List<String> _backendUrls = [
    'http://10.195.49.21:3001',   // Primary - Updated to new backend
    'http://10.195.49.18:3001',   // Secondary - Previous backend
    'https://10.195.49.21:3001',  // HTTPS fallback
    'https://10.195.49.18:3001',  // HTTPS fallback
  ];
  
  // All backend URLs for connectivity testing
  static List<String> get allBackendUrls => _backendUrls;

  // Full API URL with version
  static String get apiUrl => '$_baseUrl$_apiVersion';
  static String get fallbackApiUrl => '$_fallbackUrl$_apiVersion';

  // Backend URLs without API prefix for direct endpoints
  static String get backendUrl => _baseUrl;
  static String get fallbackBackendUrl => _fallbackUrl;

  // Environment info
  static String get environment =>
      _isDevelopment ? 'development' : 'production';

  // Cybersource environment
  static String get cybersourceEnvironment =>
      _isDevelopment ? 'sandbox' : 'production';
}
