class Environment {
  static const String _baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://10.195.49.21:3000',
  );

  static const String _apiVersion = String.fromEnvironment(
    'API_VERSION',
    defaultValue: '',
  );

  static const bool _isDevelopment = bool.fromEnvironment(
    'DEVELOPMENT',
    defaultValue: true,
  );

  static const String _apiKey = String.fromEnvironment(
    'API_KEY',
    defaultValue: 'your-api-key-here',
  );

  // Getters
  static String get baseUrl => _baseUrl;
  static String get apiVersion => _apiVersion;
  static bool get isDevelopment => _isDevelopment;
  static String get apiKey => _apiKey;

  // Full API URL
  static String get apiUrl => '$_baseUrl$_apiVersion';

  // Environment info
  static String get environment =>
      _isDevelopment ? 'development' : 'production';
}
