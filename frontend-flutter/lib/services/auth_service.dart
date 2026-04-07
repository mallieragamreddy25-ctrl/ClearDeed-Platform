import 'package:dio/dio.dart';
import 'http_exception.dart';
import 'api_client.dart';
import 'storage_service.dart';
import '../models/user.dart';
import '../utils/app_logger.dart';
import '../utils/constants.dart';

/// Authentication service for OTP, login, profile management
class AuthService {
  final ApiClient _apiClient;

  AuthService({required ApiClient apiClient}) : _apiClient = apiClient;

  // ==================== OTP Flow ====================

  /// Send OTP to phone number
  /// Returns: Future<bool> - true if OTP sent successfully
  Future<bool> sendOtp({required String phoneNumber}) async {
    try {
      AppLogger.logFunctionEntry('sendOtp', {'phoneNumber': phoneNumber});

      final response = await _apiClient.post(
        '/v1/auth/send-otp',
        data: {
          'mobile_number': phoneNumber,
          'country_code': '+91',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppLogger.logFunctionExit('sendOtp', true);
        return true;
      }

      throw ApiException(
        message: response.data['message'] ?? 'Failed to send OTP',
        statusCode: response.statusCode,
        responseBody: response.data,
      );
    } on DioException catch (e) {
      AppLogger.error('Send OTP failed: ${e.message}', e);
      throw _mapDioException(e);
    } catch (e) {
      AppLogger.error('Send OTP error: $e', e);
      rethrow;
    }
  }

  /// Verify OTP and get authentication token
  /// Returns: Future<String> - authentication token
  Future<String> verifyOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    try {
      AppLogger.logFunctionEntry('verifyOtp', {'phoneNumber': phoneNumber});

      final response = await _apiClient.post(
        '/v1/auth/verify-otp',
        data: {
          'mobile_number': phoneNumber,
          'otp': otp,
          'country_code': '+91',
        },
      );

      if (response.statusCode == 200) {
        final token = response.data['data']?['token'] ?? response.data['token'];

        if (token == null) {
          throw ApiException(
            message: 'No token in response',
            statusCode: 200,
            responseBody: response.data,
          );
        }

        // Save token
        _apiClient.setAuthToken(token);
        await StorageService.saveToken(token);

        // Save user if included in response
        if (response.data['data']?['user'] != null) {
          final user = User.fromJson(response.data['data']['user']);
          await StorageService.saveUser(user);
        }

        AppLogger.logFunctionExit('verifyOtp', 'Success');
        return token;
      }

      throw ApiException(
        message: response.data['message'] ?? 'OTP verification failed',
        statusCode: response.statusCode,
        responseBody: response.data,
      );
    } on DioException catch (e) {
      AppLogger.error('Verify OTP failed: ${e.message}', e);
      throw _mapDioException(e);
    } catch (e) {
      AppLogger.error('Verify OTP error: $e', e);
      rethrow;
    }
  }

  /// Resend OTP to phone number
  /// Returns: Future<bool> - true if OTP resent successfully
  Future<bool> resendOtp({required String phoneNumber}) async {
    try {
      AppLogger.logFunctionEntry('resendOtp', {'phoneNumber': phoneNumber});

      final response = await _apiClient.post(
        '/v1/auth/send-otp',
        data: {
          'mobile_number': phoneNumber,
          'country_code': '+91',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppLogger.logFunctionExit('resendOtp', true);
        return true;
      }

      throw ApiException(
        message: response.data['message'] ?? 'Failed to resend OTP',
        statusCode: response.statusCode,
        responseBody: response.data,
      );
    } on DioException catch (e) {
      AppLogger.error('Resend OTP failed: ${e.message}', e);
      throw _mapDioException(e);
    } catch (e) {
      AppLogger.error('Resend OTP error: $e', e);
      rethrow;
    }
  }

  // ==================== User Profile ====================

  /// Get current user profile
  /// Returns: Future<User> - current user profile
  Future<User> getUserProfile() async {
    try {
      AppLogger.logFunctionEntry('getUserProfile');

      final response = await _apiClient.get('/v1/users/profile');

      if (response.statusCode == 200) {
        final userData = response.data['data'] ?? response.data;
        final user = User.fromJson(userData);

        // Cache user locally
        await StorageService.saveUser(user);

        AppLogger.logFunctionExit('getUserProfile', user.fullName);
        return user;
      }

      throw ApiException(
        message: response.data['message'] ?? 'Failed to fetch profile',
        statusCode: response.statusCode,
        responseBody: response.data,
      );
    } on DioException catch (e) {
      AppLogger.error('Get profile failed: ${e.message}', e);
      throw _mapDioException(e);
    } catch (e) {
      AppLogger.error('Get profile error: $e', e);
      rethrow;
    }
  }

  /// Update user profile
  /// Returns: Future<User> - updated user profile
  Future<User> updateUserProfile({
    required String fullName,
    required String email,
    required String city,
    required String profileType,
    String? budget,
    String? netWorth,
  }) async {
    try {
      AppLogger.logFunctionEntry('updateUserProfile', {
        'fullName': fullName,
        'email': email,
        'city': city,
        'profileType': profileType,
      });

      final data = {
        'full_name': fullName,
        'email': email,
        'city': city,
        'profile_type': profileType.toLowerCase(),
        if (budget != null && budget.isNotEmpty) 'budget': budget,
        if (netWorth != null && netWorth.isNotEmpty) 'net_worth': netWorth,
      };

      final response = await _apiClient.put(
        '/v1/users/profile',
        data: data,
      );

      if (response.statusCode == 200) {
        final userData = response.data['data'] ?? response.data;
        final user = User.fromJson(userData);

        // Update cached user
        await StorageService.saveUser(user);

        AppLogger.logFunctionExit('updateUserProfile', user.fullName);
        return user;
      }

      throw ApiException(
        message: response.data['message'] ?? 'Failed to update profile',
        statusCode: response.statusCode,
        responseBody: response.data,
      );
    } on DioException catch (e) {
      AppLogger.error('Update profile failed: ${e.message}', e);
      throw _mapDioException(e);
    } catch (e) {
      AppLogger.error('Update profile error: $e', e);
      rethrow;
    }
  }

  /// Create user profile (after OTP verification)
  /// Returns: Future<User> - created user profile
  Future<User> createUserProfile({
    required String fullName,
    required String email,
    required String city,
    required String profileType,
  }) async {
    try {
      AppLogger.logFunctionEntry('createUserProfile', {
        'fullName': fullName,
        'email': email,
        'city': city,
        'profileType': profileType,
      });

      final response = await _apiClient.post(
        '/v1/users/profile',
        data: {
          'full_name': fullName,
          'email': email,
          'city': city,
          'profile_type': profileType.toLowerCase(),
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final userData = response.data['data'] ?? response.data;
        final user = User.fromJson(userData);

        // Cache user locally
        await StorageService.saveUser(user);

        AppLogger.logFunctionExit('createUserProfile', user.fullName);
        return user;
      }

      throw ApiException(
        message: response.data['message'] ?? 'Failed to create profile',
        statusCode: response.statusCode,
        responseBody: response.data,
      );
    } on DioException catch (e) {
      AppLogger.error('Create profile failed: ${e.message}', e);
      throw _mapDioException(e);
    } catch (e) {
      AppLogger.error('Create profile error: $e', e);
      rethrow;
    }
  }

  // ==================== Logout ====================

  /// Logout user
  /// Returns: Future<void>
  Future<void> logout() async {
    try {
      AppLogger.logFunctionEntry('logout');

      // Try to notify server (don't fail if it fails)
      try {
        await _apiClient.post('/v1/auth/logout');
      } catch (e) {
        AppLogger.warning('Server logout failed, clearing local session anyway');
      }

      // Clear local session
      await _apiClient.clearAuthToken();
      await StorageService.logout();

      AppLogger.logFunctionExit('logout', 'Success');
    } catch (e) {
      AppLogger.error('Logout error: $e', e);
      // Still clear local storage even if error occurs
      await _apiClient.clearAuthToken();
      await StorageService.logout();
    }
  }

  // ==================== Session Management ====================

  /// Check if user is authenticated
  /// Returns: bool - true if valid session exists
  bool isAuthenticated() {
    return _apiClient.isAuthenticated && StorageService.isSessionValid();
  }

  /// Get cached user (without API call)
  /// Returns: User? - cached user or null
  User? getCachedUser() {
    return StorageService.getUser();
  }

  /// Validate current token
  /// Returns: Future<bool> - true if token is still valid
  Future<bool> isTokenValid() async {
    try {
      if (!_apiClient.isAuthenticated) {
        return false;
      }

      // Try to fetch profile to validate token
      await getUserProfile();
      return true;
    } catch (e) {
      AppLogger.warning('Token validation failed: $e');
      return false;
    }
  }

  // ==================== Error Handling ====================

  /// Map DioException to AppException
  AppException _mapDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException(
          message: 'Request timeout. Please check your connection.',
          originalError: error,
        );

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 401) {
          return UnauthorizedException(
            responseBody: error.response?.data,
            originalError: error,
          );
        }
        if (statusCode == 422) {
          return ValidationException(
            message: error.response?.data['message'] ?? 'Validation error',
            fieldErrors: error.response?.data['errors'],
            responseBody: error.response?.data,
          );
        }
        return ApiException(
          message: error.response?.data['message'] ?? 'API error',
          statusCode: statusCode,
          responseBody: error.response?.data,
          originalError: error,
        );

      case DioExceptionType.connectionError:
      case DioExceptionType.connectionErrorSocket:
        return NetworkException(
          message: 'Network connection failed',
          originalError: error,
        );

      case DioExceptionType.unknown:
        return NetworkException(
          message: 'An unexpected error occurred',
          originalError: error,
        );

      case DioExceptionType.badCertificate:
        return NetworkException(
          message: 'SSL certificate error',
          originalError: error,
        );

      case DioExceptionType.cancel:
        return AppException(
          message: 'Request cancelled',
          originalError: error,
        );

      case DioExceptionType.badRequest:
        return ApiException(
          message: 'Bad request',
          statusCode: error.response?.statusCode,
          responseBody: error.response?.data,
          originalError: error,
        );
    }
  }
}
