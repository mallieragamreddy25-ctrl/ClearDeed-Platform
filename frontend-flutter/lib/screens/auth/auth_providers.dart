import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../services/api_client.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';
import '../../utils/app_logger.dart';
import '../../models/user.dart';

// ==================== Service Providers ====================

/// API Client provider - single instance used across app
final apiClientProvider = Provider<ApiClient>((ref) {
  final token = StorageService.getToken();
  final client = ApiClient(authToken: token);
  AppLogger.debug('API Client initialized');
  return client;
});

/// Auth Service provider - depends on API Client
final authServiceProvider = Provider<AuthService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthService(apiClient: apiClient);
});

// ==================== OTP State ====================

/// OTP state class for managing OTP flow
class OtpState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;
  final int attemptsRemaining;
  final DateTime? nextRetryTime;
  final String phoneNumber;

  const OtpState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
    this.attemptsRemaining = 3,
    this.nextRetryTime,
    this.phoneNumber = '',
  });

  OtpState copyWith({
    bool? isLoading,
    String? error,
    bool? isSuccess,
    int? attemptsRemaining,
    DateTime? nextRetryTime,
    String? phoneNumber,
  }) {
    return OtpState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isSuccess: isSuccess ?? this.isSuccess,
      attemptsRemaining: attemptsRemaining ?? this.attemptsRemaining,
      nextRetryTime: nextRetryTime ?? this.nextRetryTime,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }
}

/// OTP notifier - manages OTP verification flow
class OtpNotifier extends StateNotifier<OtpState> {
  final AuthService _authService;
  static const int _maxAttempts = 3;
  static const int _lockoutDurationMinutes = 30;

  OtpNotifier(this._authService) : super(const OtpState());

  /// Send OTP to phone number
  Future<bool> sendOtp(String phoneNumber) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      phoneNumber: phoneNumber,
    );

    try {
      AppLogger.logFunctionEntry('sendOtp', {
        'phoneNumber': phoneNumber,
      });

      final success = await _authService.sendOtp(phoneNumber: phoneNumber);

      if (success) {
        state = state.copyWith(
          isLoading: false,
          isSuccess: true,
          attemptsRemaining: _maxAttempts,
        );
        AppLogger.logAuthEvent('OTP sent successfully to $phoneNumber');
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to send OTP. Please try again.',
        );
        return false;
      }
    } on DioException catch (e) {
      final errorMessage = _extractDioErrorMessage(e);
      AppLogger.error('Send OTP failed: $errorMessage', e);
      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
      );
      return false;
    } catch (e) {
      final errorMessage = _extractErrorMessage(e);
      AppLogger.error('Send OTP error: $errorMessage', e);
      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
      );
      return false;
    }
  }

  /// Verify OTP and authenticate user
  Future<bool> verifyOtp(String phoneNumber, String otp) async {
    // Check if user is locked out
    if (state.nextRetryTime != null &&
        DateTime.now().isBefore(state.nextRetryTime!)) {
      final minutesRemaining = state.nextRetryTime!
          .difference(DateTime.now())
          .inMinutes;
      state = state.copyWith(
        error:
            'Too many failed attempts. Try again in $minutesRemaining minutes.',
      );
      return false;
    }

    state = state.copyWith(
      isLoading: true,
      error: null,
    );

    try {
      AppLogger.logFunctionEntry('verifyOtp', {
        'phoneNumber': phoneNumber,
        'otpLength': otp.length,
      });

      final token = await _authService.verifyOtp(
        phoneNumber: phoneNumber,
        otp: otp,
      );

      // Store token
      await StorageService.setToken(token);

      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        attemptsRemaining: _maxAttempts,
        nextRetryTime: null,
      );

      AppLogger.logAuthEvent('OTP verified successfully');
      return true;
    } on DioException catch (e) {
      // Handle OTP verification failure
      int newAttemptsRemaining = state.attemptsRemaining - 1;
      DateTime? lockoutTime;

      if (newAttemptsRemaining <= 0) {
        lockoutTime = DateTime.now()
            .add(Duration(minutes: _lockoutDurationMinutes));
        newAttemptsRemaining = 0;
      }

      final errorMessage = _extractDioErrorMessage(e);
      AppLogger.error('OTP verification failed: $errorMessage', e);

      state = state.copyWith(
        isLoading: false,
        error: newAttemptsRemaining > 0
            ? 'Invalid OTP. $newAttemptsRemaining attempts remaining.'
            : 'Too many failed attempts. Try again in 30 minutes.',
        attemptsRemaining: newAttemptsRemaining,
        nextRetryTime: lockoutTime,
      );

      return false;
    } catch (e) {
      int newAttemptsRemaining = state.attemptsRemaining - 1;
      DateTime? lockoutTime;

      if (newAttemptsRemaining <= 0) {
        lockoutTime = DateTime.now()
            .add(Duration(minutes: _lockoutDurationMinutes));
        newAttemptsRemaining = 0;
      }

      final errorMessage = _extractErrorMessage(e);
      AppLogger.error('OTP verification error: $errorMessage', e);

      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
        attemptsRemaining: newAttemptsRemaining,
        nextRetryTime: lockoutTime,
      );

      return false;
    }
  }

  /// Resend OTP
  Future<bool> resendOtp() async {
    if (state.phoneNumber.isEmpty) {
      state = state.copyWith(error: 'Phone number not found.');
      return false;
    }

    return sendOtp(state.phoneNumber);
  }

  /// Reset OTP state
  void reset() {
    state = const OtpState();
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  String _extractErrorMessage(dynamic error) {
    return error.toString().replaceAll('Exception: ', '');
  }

  String _extractDioErrorMessage(DioException error) {
    if (error.response?.statusCode == 429) {
      return 'Too many requests. Please try again later.';
    } else if (error.response?.statusCode == 400) {
      return 'Invalid OTP. Please try again.';
    } else if (error.response?.statusCode == 401) {
      return 'Session expired. Request a new OTP.';
    } else if (error.type == DioExceptionType.connectionTimeout) {
      return 'Connection timeout. Please check your internet.';
    } else if (error.type == DioExceptionType.receiveTimeout) {
      return 'Request timeout. Please try again.';
    } else {
      return error.message ?? 'An error occurred. Please try again.';
    }
  }
}

/// OTP provider
final otpProvider = StateNotifierProvider<OtpNotifier, OtpState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return OtpNotifier(authService);
});

/// OTP loading provider
final otpLoadingProvider = Provider<bool>((ref) {
  return ref.watch(otpProvider).isLoading;
});

/// OTP error provider
final otpErrorProvider = Provider<String?>((ref) {
  return ref.watch(otpProvider).error;
});

/// OTP attempts remaining provider
final otpAttemptsRemainingProvider = Provider<int>((ref) {
  return ref.watch(otpProvider).attemptsRemaining;
});

/// OTP is locked out provider
final otpIsLockedOutProvider = Provider<bool>((ref) {
  final otpState = ref.watch(otpProvider);
  return otpState.nextRetryTime != null &&
      DateTime.now().isBefore(otpState.nextRetryTime!);
});

/// Send OTP provider - async provider for sending OTP
final sendOtpProvider = FutureProvider.family<bool, String>((ref, phoneNumber) async {
  final otpNotifier = ref.read(otpProvider.notifier);
  return otpNotifier.sendOtp(phoneNumber);
});

// ==================== Profile Setup State ====================

/// Profile setup state class
class ProfileSetupState {
  final bool isLoading;
  final String? error;
  final Map<String, String> fieldErrors;
  final bool isSuccess;
  final User? setupUser;

  const ProfileSetupState({
    this.isLoading = false,
    this.error,
    this.fieldErrors = const {},
    this.isSuccess = false,
    this.setupUser,
  });

  ProfileSetupState copyWith({
    bool? isLoading,
    String? error,
    Map<String, String>? fieldErrors,
    bool? isSuccess,
    User? setupUser,
  }) {
    return ProfileSetupState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      fieldErrors: fieldErrors ?? this.fieldErrors,
      isSuccess: isSuccess ?? this.isSuccess,
      setupUser: setupUser ?? this.setupUser,
    );
  }
}

/// Profile setup notifier
class ProfileSetupNotifier extends StateNotifier<ProfileSetupState> {
  final AuthService _authService;

  ProfileSetupNotifier(this._authService)
      : super(const ProfileSetupState());

  /// Submit profile setup form
  Future<bool> submitProfile({
    required String fullName,
    required String email,
    required String city,
    required String profileType,
    required String budgetRange,
    String? referralMobile,
  }) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      fieldErrors: {},
      isSuccess: false,
    );

    try {
      AppLogger.logFunctionEntry('submitProfile', {
        'fullName': fullName,
        'email': email,
        'city': city,
        'profileType': profileType,
      });

      final success = await _authService.setupProfile(
        fullName: fullName,
        email: email,
        city: city,
        profileType: profileType,
        budgetRange: budgetRange,
        referralMobile: referralMobile,
      );

      if (success) {
        state = state.copyWith(
          isLoading: false,
          isSuccess: true,
        );
        AppLogger.logAuthEvent('Profile setup completed successfully');
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to complete profile setup',
        );
        return false;
      }
    } on DioException catch (e) {
      final errorMessage = _extractDioErrorMessage(e);
      AppLogger.error('Profile setup failed: $errorMessage', e);

      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
      );
      return false;
    } catch (e) {
      final errorMessage = _extractErrorMessage(e);
      AppLogger.error('Profile setup error: $errorMessage', e);

      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
      );
      return false;
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Reset state
  void reset() {
    state = const ProfileSetupState();
  }

  String _extractErrorMessage(dynamic error) {
    return error.toString().replaceAll('Exception: ', '');
  }

  String _extractDioErrorMessage(DioException error) {
    if (error.response?.statusCode == 400) {
      return 'Invalid input. Please check your details.';
    } else if (error.response?.statusCode == 409) {
      return 'Email already in use. Please use a different email.';
    } else if (error.type == DioExceptionType.connectionTimeout) {
      return 'Connection timeout. Please check your internet.';
    } else if (error.type == DioExceptionType.receiveTimeout) {
      return 'Request timeout. Please try again.';
    } else {
      return error.message ?? 'An error occurred. Please try again.';
    }
  }
}

/// Profile setup provider
final profileSetupProvider =
    StateNotifierProvider<ProfileSetupNotifier, ProfileSetupState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return ProfileSetupNotifier(authService);
});

/// Profile setup loading provider
final profileSetupLoadingProvider = Provider<bool>((ref) {
  return ref.watch(profileSetupProvider).isLoading;
});

/// Profile setup error provider
final profileSetupErrorProvider = Provider<String?>((ref) {
  return ref.watch(profileSetupProvider).error;
});

/// Profile setup field errors provider
final profileSetupFieldErrorsProvider =
    Provider<Map<String, String>>((ref) {
  return ref.watch(profileSetupProvider).fieldErrors;
});

// ==================== Auth State ====================

/// Auth state class
class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? token;
  final String? error;
  final User? currentUser;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.token,
    this.error,
    this.currentUser,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? token,
    String? error,
    User? currentUser,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      token: token ?? this.token,
      error: error ?? this.error,
      currentUser: currentUser ?? this.currentUser,
    );
  }
}

/// Auth notifier - manages overall authentication state
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService)
      : super(
          AuthState(
            isAuthenticated: _authService.isAuthenticated(),
            token: StorageService.getToken(),
          ),
        );

  /// Logout user
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    try {
      await _authService.logout();
      await StorageService.clearToken();

      state = const AuthState(
        isAuthenticated: false,
        isLoading: false,
        token: null,
      );
      AppLogger.logAuthEvent('User logged out');
    } catch (e) {
      AppLogger.error('Logout failed: $e');
      state = const AuthState(
        isAuthenticated: false,
        isLoading: false,
      );
    }
  }

  /// Set authentication successful
  void setAuthenticated(String token, User? user) {
    state = state.copyWith(
      isAuthenticated: true,
      token: token,
      currentUser: user,
      isLoading: false,
    );
  }

  /// Clear any error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Auth provider
final authProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});

/// Is authenticated provider
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

/// Auth token provider
final authTokenProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).token;
});

/// Current user provider
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authProvider).currentUser;
});

/// Auth loading provider
final authLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoading;
});

// ==================== Profile Type and Budget Constants ====================

/// Profile types
const List<String> profileTypes = ['Buyer', 'Seller', 'Investor'];

/// Budget ranges
const Map<String, String> budgetRanges = {
  '0-50L': '0-50 Lakhs',
  '50L-1Cr': '50 Lakhs - 1 Crore',
  '1Cr+': '1 Crore+',
};
