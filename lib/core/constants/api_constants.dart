class AppConstants {
  // API Configuration
  static const String baseUrl = 'https://easy-kaam-48281873f974.herokuapp.com';

  // Storage Keys
  static const String jwtTokenKey = 'jwt_token';
  static const String userIdKey = 'user_id';

  // Default Test Credentials
  static const String defaultPhoneNo = '12345';
  static const String defaultOtp = '12345';
  static const String defaultUserId = '9ac1fff9-ea5f-4faf-9764-fa5c42167c6f';

  // UI Constants
  static const double defaultPadding = 20.0;
  static const double smallPadding = 10.0;
  static const double largePadding = 30.0;

  // Colors
  static const int primaryBlue = 0xFF25B0F0;
  static const int lightBlue = 0xFF8DD4FD;
  static const int darkBlue = 0xFF547F97;
  static const int addBlue = 0xFFADD8E6;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 300);
  static const Duration mediumAnimation = Duration(milliseconds: 500);
  static const Duration longAnimation = Duration(milliseconds: 800);

  // Image Paths
  static const String logoPath = 'assets/logo/logo.png';
  static const String easyKaamLogoPath = 'assets/logo/easykaam.png';
  static const String defaultServiceImage = 'assets/services/subservices/Electrician.png';

  // API Endpoints
  static const String sendOtpEndpoint = '/api/users/send-otp';
  static const String verifyOtpEndpoint = '/api/users/verify-otp';
  static const String uploadProfileEndpoint = 'api/users/upload-profile-picture';
  static const String getProfileEndpoint = '/api/users/get-profile-picture';
  static const String categoriesEndpoint = '/api/Categories/get-all-categories';
  static const String subCategoriesEndpoint = '/api/sub-categories/get-all-sub-categories';
  static const String createSubCategoryEndpoint = '/api/create-sub-category';
  static const String registerWorkerEndpoint = '/api/worker-details/register-as-worker';

  // Error Messages
  static const String networkError = 'Network error. Please check your connection.';
  static const String serverError = 'Server error. Please try again later.';
  static const String unknownError = 'An unknown error occurred.';
  static const String noDataError = 'No data available.';

  // Success Messages
  static const String otpSentSuccess = 'OTP sent successfully';
  static const String otpVerifiedSuccess = 'OTP verified successfully';
  static const String profileUploadSuccess = 'Profile picture uploaded successfully';
}



