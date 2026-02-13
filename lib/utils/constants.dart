class AppConstants {
  // WordPress API Base URL
  static const String wordpressBaseUrl = 'https://server168.liquidityprint.com';
  static const String apiBasePath = '/wp-json';
  
  // API Endpoints
  static const String loginEndpoint = '/liquidity/v1/login';
  static const String checkSubscriptionEndpoint = '/liquidity/v1/check-subscription';
  static const String registerDeviceEndpoint = '/liquidity/v1/register-device';
  static const String getCandlesEndpoint = '/liquidity/v1/get-candles';
  
  // Indicator Endpoints
  static const String deltaEndpoint = '/indicators/v1/delta';
  static const String scaleEndpoint = '/indicators/v1/liquidity-scale';
  static const String algoLocEndpoint = '/indicators/v1/algo-loc';
  static const String icebergEndpoint = '/indicators/v1/iceberg';
  
  // Subscription Plans
  static const String planFree = 'free';
  static const String planBasic = 'basic';
  static const String planPro = 'pro';
  static const String planPremium = 'premium';
  
  // Storage Keys
  static const String keyUserEmail = 'user_email';
  static const String keyUserId = 'user_id';
  static const String keyAuthToken = 'auth_token';
  static const String keyDeviceId = 'device_id';
  static const String keyRememberMe = 'remember_me';
}
