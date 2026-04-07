import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../utils/app_logger.dart';
import 'auth_provider.dart';

// ==================== User State ====================

/// User state class
class UserState {
  final User? user;
  final bool isLoading;
  final String? error;

  const UserState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  UserState copyWith({
    User? user,
    bool? isLoading,
    String? error,
  }) {
    return UserState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  bool get isProfileComplete =>
      user != null &&
      user!.fullName.isNotEmpty &&
      user!.email.isNotEmpty &&
      user!.city.isNotEmpty;
}

// ==================== User Notifier ====================

class UserNotifier extends StateNotifier<UserState> {
  final AuthService _authService;
  final Ref _ref;

  UserNotifier(this._authService, this._ref)
      : super(UserState(user: StorageService.getUser()));

  /// Fetch user profile from server
  Future<void> fetchUserProfile() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _authService.getUserProfile();
      state = state.copyWith(
        isLoading: false,
        user: user,
      );
      AppLogger.info('User profile loaded: ${user.fullName}');
    } catch (e) {
      AppLogger.error('Failed to fetch user profile: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Update user profile
  Future<bool> updateProfile({
    required String fullName,
    required String email,
    required String city,
    required String profileType,
    String? budget,
    String? netWorth,
    String? referralNumber,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final updatedUser = await _authService.updateUserProfile(
        fullName: fullName,
        email: email,
        city: city,
        profileType: profileType,
        budget: budget,
        netWorth: netWorth,
        referralNumber: referralNumber,
      );

      state = state.copyWith(
        isLoading: false,
        user: updatedUser,
      );

      AppLogger.info('User profile updated successfully');
      return true;
    } catch (e) {
      AppLogger.error('Failed to update profile: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Set user (used after profile setup)
  void setUser(User user) {
    state = state.copyWith(user: user);
    StorageService.saveUser(user);
  }

  /// Clear user (on logout)
  void clearUser() {
    state = const UserState();
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// ==================== User Provider ====================

/// User service provider - used internally by user provider
final userServiceProvider = Provider<AuthService>((ref) {
  return ref.watch(authServiceProvider);
});

/// User provider - manages user profile state
final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  final authService = ref.watch(userServiceProvider);
  return UserNotifier(authService, ref);
});

/// Current user provider - access just the user object
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(userProvider).user;
});

/// Is profile complete provider
final isProfileCompleteProvider = Provider<bool>((ref) {
  return ref.watch(userProvider).isProfileComplete;
});

/// User loading provider
final userLoadingProvider = Provider<bool>((ref) {
  return ref.watch(userProvider).isLoading;
});

/// User error provider
final userErrorProvider = Provider<String?>((ref) {
  return ref.watch(userProvider).error;
});

// ==================== Effects ====================

/// Auto-fetch user profile when authenticated
final autoFetchUserProfileProvider = FutureProvider<void>((ref) async {
  final isAuthenticated = ref.watch(isAuthenticatedProvider);
  
  if (isAuthenticated) {
    AppLogger.debug('Auto-fetching user profile');
    await ref.read(userProvider.notifier).fetchUserProfile();
  }
});
