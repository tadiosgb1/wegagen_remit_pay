class Environment {
  static const String _baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://donation.wegagenbanksc.com.et/remit', // Change to localhost for web development
  );

  static const String _fallbackUrl = String.fromEnvironment(
    'FALLBACK_URL',
    defaultValue: 'https://donation.wegagenbanksc.com.et/remit', // Fallback to previous URL
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
    // 'http://localhost:3001',      // Primary - Localhost for web development
    // 'http://127.0.0.1:3001',      // Alternative localhost
    'https://donation.wegagenbanksc.com.et/remit',   // Internal IP - Primary backend
    // 'http://10.195.49.18:3001',   // Internal IP - Secondary backend
  ];
  
  // All backend URLs for connectivity testing
  static List<String> get allBackendUrls => _backendUrls;

  // ---------------------------------------------------------------------------
  // Hosts-file override map for local/intranet domains.
  // When the domain is only resolvable inside the office network (no public DNS),
  // add it here so the HttpClient resolves it directly to the server IP.
  // The domain name is still sent in the TLS SNI / Host header, so Cybersource
  // Microform domain checks continue to work correctly.
  // ---------------------------------------------------------------------------
  static const Map<String, String> hostsOverrides = {
    'cybersource.wegagenbanksc.com.et': '10.195.49.21',
  };

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
