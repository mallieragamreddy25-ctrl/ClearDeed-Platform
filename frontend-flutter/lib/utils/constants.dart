/// Constants used throughout the application
class AppConstants {
  // API Configuration
  static const String baseUrl = 'https://api.cleardeed.com/v1';
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration connectTimeout = Duration(seconds: 15);
  static const String apiKeyHeader = 'X-API-Key';

  // Auth Configuration
  static const int otpResendDelaySeconds = 60;
  static const int otpExpirySeconds = 600; // 10 minutes
  static const String phoneNumberRegex = r'^[6-9]\d{9}$'; // Indian phone
  static const int minPhoneLength = 10;
  static const int maxPhoneLength = 10;

  // Form Validation
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
  static const int minCityLength = 2;
  static const int maxCityLength = 50;
  static const String emailRegex =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';

  // Property Constants
  static const int propertyPageSize = 20;
  static const List<String> propertyCategories = [
    'Land',
    'Houses',
    'Commercial',
    'Agriculture'
  ];
  static const List<String> profileTypes = ['Buyer', 'Seller', 'Investor'];

  // Database Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String filtersKey = 'property_filters';
  static const String favoritePropertiesKey = 'favorite_properties';

  // Error Messages
  static const String networkErrorMessage =
      'Network error. Please check your connection.';
  static const String serverErrorMessage =
      'Server error. Please try again later.';
  static const String unauthorizedErrorMessage =
      'Unauthorized. Please login again.';
  static const String invalidOtpMessage = 'Invalid OTP. Please try again.';
  static const String otpExpiredMessage =
      'OTP expired. Please request a new one.';
  static const String fieldRequiredMessage = 'This field is required';
  static const String invalidPhoneMessage = 'Please enter a valid phone number';
  static const String invalidEmailMessage = 'Please enter a valid email';

  // Endpoints
  static const String sendOtpEndpoint = '/auth/send-otp';
  static const String verifyOtpEndpoint = '/auth/verify-otp';
  static const String userProfileEndpoint = '/users/profile';
  static const String updateProfileEndpoint = '/users/profile';
  static const String logoutEndpoint = '/auth/logout';
  static const String propertiesEndpoint = '/properties';
  static const String propertyDetailEndpoint = '/properties';
  static const String expressInterestEndpoint = '/properties/express-interest';

  // UI Configuration
  static const double borderRadius = 8.0;
  static const double cardElevation = 1.0;
  static const EdgeInsets defaultScreenPadding =
      EdgeInsets.symmetric(horizontal: 16, vertical: 24);
  static const EdgeInsets cardPadding =
      EdgeInsets.symmetric(horizontal: 16, vertical: 12);
}
