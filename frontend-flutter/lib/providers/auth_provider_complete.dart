import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../utils/app_logger.dart';

// ==================== Singleton Services ====================

/// API Client provider - single instance
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

// ==================== Auth State ====================

/// Authentication state
class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? token;
  final String? error;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.token,
    this.error,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? token,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      token: token ?? this.token,
      error: error ?? this.error,
    );
  }
}

/// Auth notifier - manages authentication state
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService)
      : super(
          AuthState(
            isAuthenticated: _authService.isAuthenticated(),
            token: StorageService.getToken(),
          ),
        );

  /// Send OTP to phone number
  Future<void> sendOtp(String phoneNumber) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final success = await _authService.sendOtp(phoneNumber: phoneNumber);
      if (success) {
        AppLogger.logAuthEvent('OTP sent to $phoneNumber');
      }
      state = state.copyWith(isLoading: false);
    } catch (e) {
      AppLogger.error('Send OTP failed: $e');
      state = state.copyWith(
        isLoading: false,
        error: _extractErrorMessage(e),
      );
    }
  }

  /// Verify OTP and authenticate user
  Future<bool> verifyOtp(String phoneNumber, String otp) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final token = await _authService.verifyOtp(
        phoneNumber: phoneNumber,
        otp: otp,
      );

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        token: token,
      );

      AppLogger.logAuthEvent('User authenticated via OTP');
      return true;
    } catch (e) {
      AppLogger.error('Verify OTP failed: $e');
      state = state.copyWith(
        isLoading: false,
        error: _extractErrorMessage(e),
      );
      return false;
    }
  }

  /// Resend OTP
  Future<void> resendOtp(String phoneNumber) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final success = await _authService.resendOtp(phoneNumber: phoneNumber);
      if (success) {
        AppLogger.logAuthEvent('OTP resent to $phoneNumber');
      }
      state = state.copyWith(isLoading: false);
    } catch (e) {
      AppLogger.error('Resend OTP failed: $e');
      state = state.copyWith(
        isLoading: false,
        error: _extractErrorMessage(e),
      );
    }
  }

  /// Logout user
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    try {
      await _authService.logout();
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

  /// Check if token is valid
  Future<void> validateToken() async {
    try {
      final isValid = await _authService.isTokenValid();
      state = state.copyWith(isAuthenticated: isValid);
    } catch (e) {
      AppLogger.warning('Token validation failed: $e');
      state = state.copyWith(isAuthenticated: false);
    }
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Extract user-friendly error message
  String _extractErrorMessage(dynamic error) {
    return error.toString().replaceAll('Exception: ', '');
  }
}

/// Auth provider - manages auth state
final authProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});

/// Auth token provider
final authTokenProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).token;
});

/// Is authenticated provider
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

/// Is loading provider
final isAuthLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoading;
});

/// Auth error provider
final authErrorProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).error;
});

// ==================== Profile Setup State ====================

/// Profile setup state
class ProfileSetupState {
  final bool isLoading;
  final String? error;
  final Map<String, String> fieldErrors;
  final bool isSuccess;

  const ProfileSetupState({
    this.isLoading = false,
    this.error,
    this.fieldErrors = const {},
    this.isSuccess = false,
  });

  ProfileSetupState copyWith({
    bool? isLoading,
    String? error,
    Map<String, String>? fieldErrors,
    bool? isSuccess,
  }) {
    return ProfileSetupState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      fieldErrors: fieldErrors ?? this.fieldErrors,
      isSuccess: isSuccess ?? this.isSuccess,
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

      // Use updateUserProfile to complete profile setup
      final success = await _authService.updateUserProfile(
        fullName: fullName,
        email: email,
        city: city,
        profileMode: profileType,
        netWorth: budgetRange,
        referralNumber: referralMobile,
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
    } catch (e) {
      AppLogger.error('Profile setup failed: $e');
      state = state.copyWith(
        isLoading: false,
        error: _extractErrorMessage(e),
      );
      return false;
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Extract user-friendly error message
  String _extractErrorMessage(dynamic error) {
    return error.toString().replaceAll('Exception: ', '');
  }
}

/// Profile setup provider
final profileSetupProvider =
    StateNotifierProvider<ProfileSetupNotifier, ProfileSetupState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return ProfileSetupNotifier(authService);
});

/// Profile setup error provider
final profileSetupErrorProvider = Provider<String?>((ref) {
  return ref.watch(profileSetupProvider).error;
});

/// Is profile setup loading provider
final isProfileSetupLoadingProvider = Provider<bool>((ref) {
  return ref.watch(profileSetupProvider).isLoading;
});

/// Profile setup field errors provider
final profileSetupFieldErrorsProvider = Provider<Map<String, String>>((ref) {
  return ref.watch(profileSetupProvider).fieldErrors;
});
