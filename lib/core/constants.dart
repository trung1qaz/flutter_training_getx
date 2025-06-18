class AppConstants {
  static const String baseUrl = 'https://training-api-unrp.onrender.com';
  static const String loginEndpoint = '/login2';
  static const String logoutEndpoint = '/logout';
  static const String refreshTokenEndpoint = '/refresh';
  static const String productsEndpoint = '/products';

  static const int taxCodeLength = 10;
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 20;

  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const double defaultBorderRadius = 8.0;
  static const double defaultPadding = 16.0;
}
