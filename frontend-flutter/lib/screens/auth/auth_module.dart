import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user.dart';
import '../../utils/app_logger.dart';

// ==================== User Profile Setup State ====================

/// State for user profile setup
class ProfileSetupState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;
  final Map<String, String> fieldErrors;

  const ProfileSetupState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
    this.fieldErrors = const {},
  });

  ProfileSetupState copyWith({
    bool? isLoading,
    String? error,
    bool? isSuccess,
    Map<String, String>? fieldErrors,
  }) {
    return ProfileSetupState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isSuccess: isSuccess ?? this.isSuccess,
      fieldErrors: fieldErrors ?? this.fieldErrors,
    );
  }
}

// ==================== User Profile Notifier ====================

/// Notifier for managing user profile setup
class ProfileSetupNotifier extends StateNotifier<ProfileSetupState> {
  ProfileSetupNotifier()
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
    state = state.copyWith(isLoading: true, error: null, fieldErrors: {});

    try {
      // Validate fields
      final errors = _validateProfileFields(
        fullName: fullName,
        email: email,
        city: city,
        profileType: profileType,
        budgetRange: budgetRange,
        referralMobile: referralMobile,
      );

      if (errors.isNotEmpty) {
        state = state.copyWith(
          isLoading: false,
          fieldErrors: errors,
        );
        return false;
      }

      // TODO: Call API to save profile
      // For now, just simulate success
      await Future.delayed(const Duration(seconds: 1));

      AppLogger.logAuthEvent('Profile setup completed successfully');
      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
      );

      return true;
    } catch (e) {
      AppLogger.error('Profile setup failed: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Validate profile fields
  Map<String, String> _validateProfileFields({
    required String fullName,
    required String email,
    required String city,
    required String profileType,
    required String budgetRange,
    String? referralMobile,
  }) {
    final errors = <String, String>{};

    // Validate full name
    if (fullName.isEmpty) {
      errors['fullName'] = 'Full name is required';
    } else if (fullName.length < 2) {
      errors['fullName'] = 'Name must be at least 2 characters';
    } else if (!RegExp(r"^[a-zA-Z\s\-']+$").hasMatch(fullName)) {
      errors['fullName'] = 'Name can only contain letters, spaces, hyphens, and apostrophes';
    }

    // Validate email
    if (email.isEmpty) {
      errors['email'] = 'Email is required';
    } else if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email)) {
      errors['email'] = 'Enter a valid email address';
    }

    // Validate city
    if (city.isEmpty) {
      errors['city'] = 'City is required';
    } else if (city.length < 2) {
      errors['city'] = 'City must be at least 2 characters';
    }

    // Validate profile type
    if (profileType.isEmpty) {
      errors['profileType'] = 'Profile type is required';
    }

    // Validate budget range
    if (budgetRange.isEmpty) {
      errors['budgetRange'] = 'Budget range is required';
    }

    // Validate referral mobile (optional but must be valid if provided)
    if (referralMobile != null && referralMobile.isNotEmpty) {
      final cleanedPhone = referralMobile.replaceAll(RegExp(r'[^\d]'), '');
      if (cleanedPhone.length != 10) {
        errors['referralMobile'] = 'Referral mobile must be 10 digits';
      } else if (!RegExp(r'^[6-9]\d{9}$').hasMatch(cleanedPhone)) {
        errors['referralMobile'] = 'Enter a valid Indian mobile number';
      }
    }

    return errors;
  }

  /// Clear errors
  void clearErrors() {
    state = state.copyWith(error: null, fieldErrors: {});
  }

  /// Reset state
  void reset() {
    state = const ProfileSetupState();
  }
}

// ==================== User State ====================

/// State for user data
class UserDataState {
  final User? user;
  final bool isLoading;
  final String? error;

  const UserDataState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  UserDataState copyWith({
    User? user,
    bool? isLoading,
    String? error,
  }) {
    return UserDataState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// ==================== User Data Notifier ====================

/// Notifier for managing user data
class UserDataNotifier extends StateNotifier<UserDataState> {
  UserDataNotifier() : super(const UserDataState());

  /// Fetch user profile
  Future<void> fetchUserProfile(String userId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // TODO: Call API to fetch user profile
      AppLogger.logFunctionEntry('fetchUserProfile', {'userId': userId});

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // For now, just mark as loaded
      state = state.copyWith(isLoading: false);
    } catch (e) {
      AppLogger.error('Fetch user profile failed: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Update user profile
  Future<bool> updateUserProfile(User user) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // TODO: Call API to update user profile
      AppLogger.logFunctionEntry('updateUserProfile', {'userId': user.id});

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      state = state.copyWith(
        isLoading: false,
        user: user,
      );

      return true;
    } catch (e) {
      AppLogger.error('Update user profile failed: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Clear user data
  void clearUserData() {
    state = const UserDataState();
  }
}

// ==================== Providers ====================

/// Profile setup provider
final profileSetupProvider =
    StateNotifierProvider<ProfileSetupNotifier, ProfileSetupState>((ref) {
  return ProfileSetupNotifier();
});

/// Is profile setup loading provider
final isProfileSetupLoadingProvider = Provider<bool>((ref) {
  return ref.watch(profileSetupProvider).isLoading;
});

/// Profile setup error provider
final profileSetupErrorProvider = Provider<String?>((ref) {
  return ref.watch(profileSetupProvider).error;
});

/// Profile setup field errors provider
final profileSetupFieldErrorsProvider = Provider<Map<String, String>>((ref) {
  return ref.watch(profileSetupProvider).fieldErrors;
});

/// Is profile setup success provider
final isProfileSetupSuccessProvider = Provider<bool>((ref) {
  return ref.watch(profileSetupProvider).isSuccess;
});

/// User data provider
final userDataProvider =
    StateNotifierProvider<UserDataNotifier, UserDataState>((ref) {
  return UserDataNotifier();
});

/// Current user provider
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(userDataProvider).user;
});

/// Is user loading provider
final isUserLoadingProvider = Provider<bool>((ref) {
  return ref.watch(userDataProvider).isLoading;
});

/// User error provider
final userErrorProvider = Provider<String?>((ref) {
  return ref.watch(userDataProvider).error;
});
