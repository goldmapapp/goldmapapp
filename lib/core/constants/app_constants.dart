class AppConstants {
  AppConstants._();
  // Shared Preferences Keys
  static const String keyThemeMode = 'theme_mode';
  static const String keyLanguage = 'language';
  static const String keyFirstLaunch = 'first_launch';
  static const String keyAuthToken = 'auth_token';
  static const String keyUserId = 'user_id';

  // Hive Box Names
  static const String boxCache = 'cache_box';
  static const String boxUser = 'user_box';
  static const String boxSettings = 'settings_box';

  // Route Names
  static const String routeHome = '/';
  static const String routeLogin = '/login';
  static const String routeProfile = '/profile';
  static const String routeSettings = '/settings';

  // API Endpoints
  static const String endpointLogin = '/auth/login';
  static const String endpointRegister = '/auth/register';
  static const String endpointProfile = '/user/profile';

  // Asset Paths
  static const String assetsImages = 'assets/images';
  static const String assetsIcons = 'assets/icons';
  static const String assetsFonts = 'assets/fonts';

  // Validation
  static const int minPasswordLength = 8;
  static const int maxNameLength = 50;

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
}
