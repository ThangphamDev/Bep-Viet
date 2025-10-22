class AppConfig {
  // API Configuration
  static const String baseUrl = 'http://localhost:8080';
  static const String ngrokBaseUrl =
      'https://shortly-discordant-yoshiko.ngrok-free.dev';

  // App Information
  static const String appName = 'Bếp Việt';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Smart Vietnamese Cooking App';

  // API Endpoints
  static const String authEndpoint = '/auth';
  static const String usersEndpoint = '/users';
  static const String recipesEndpoint = '/recipes';
  static const String suggestionsEndpoint = '/suggestions';
  static const String mealPlansEndpoint = '/meal-plans';
  static const String shoppingListsEndpoint = '/shopping-lists';
  static const String pantryEndpoint = '/pantry';
  static const String communityEndpoint = '/community';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';
  static const String userIdKey = 'user_id';
  static const String preferencesKey = 'user_preferences';
  static const String rememberMeKey = 'remember_me';
  static const String tokenExpiryKey = 'token_expiry';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Timeouts
  static const int connectTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  static const int sendTimeout = 30000; // 30 seconds

  // Cache
  static const int cacheExpirationMinutes = 5;
  static const int imageCacheExpirationDays = 7;

  // Validation
  static const int minPasswordLength = 8;
  static const int maxNameLength = 255;
  static const int maxDescriptionLength = 1000;

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double cardElevation = 2.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Feature Flags
  static const bool enableOfflineMode = true;
  static const bool enablePushNotifications = true;
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;
}
