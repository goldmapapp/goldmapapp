class AppConfig {
  static const String appName = 'GoldMapApp';
  static const String version = '1.0.0';

  // Environment
  static const String environment =
      String.fromEnvironment('ENVIRONMENT', defaultValue: 'dev');

  static bool get isDev => environment == 'dev';
  static bool get isStaging => environment == 'staging';
  static bool get isProduction => environment == 'production';

  // API Configuration
  static String get apiBaseUrl {
    switch (environment) {
      case 'production':
        return 'https://api.goldmap.com';
      case 'staging':
        return 'https://staging-api.goldmap.com';
      case 'dev':
      default:
        return 'https://dev-api.goldmap.com';
    }
  }

  // Features flags
  static const bool enableLogging = true;
  static const bool enableAnalytics = false;

  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration connectTimeout = Duration(seconds: 10);
}
