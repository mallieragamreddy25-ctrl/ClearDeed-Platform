import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/app_logger.dart';

// ==================== Navigation State ====================

/// Navigation state class for managing bottom nav and role
class NavigationState {
  final int selectedIndex;
  final String userRole; // 'buyer', 'seller', 'investor'

  const NavigationState({
    this.selectedIndex = 0,
    this.userRole = 'buyer',
  });

  NavigationState copyWith({
    int? selectedIndex,
    String? userRole,
  }) {
    return NavigationState(
      selectedIndex: selectedIndex ?? this.selectedIndex,
      userRole: userRole ?? this.userRole,
    );
  }
}

// ==================== Navigation Notifier ====================

/// Navigation notifier - manages bottom navigation and role state
class NavigationNotifier extends StateNotifier<NavigationState> {
  NavigationNotifier() : super(const NavigationState());

  /// Update the selected navigation index
  void setSelectedIndex(int index) {
    AppLogger.debug('Navigation index changed to: $index');
    state = state.copyWith(selectedIndex: index);
  }

  /// Update user role/mode
  void setUserRole(String role) {
    if (!['buyer', 'seller', 'investor'].contains(role.toLowerCase())) {
      AppLogger.warning('Invalid role: $role');
      return;
    }
    AppLogger.debug('User role changed to: $role');
    state = state.copyWith(userRole: role.toLowerCase());
    // Reset to home tab when role changes
    state = state.copyWith(selectedIndex: 0);
  }

  /// Reset navigation to home
  void resetNavigation() {
    AppLogger.debug('Navigation reset to home');
    state = const NavigationState();
  }
}

// ==================== Riverpod Providers ====================

/// Navigation state provider
final navigationProvider =
    StateNotifierProvider<NavigationNotifier, NavigationState>((ref) {
  return NavigationNotifier();
});

/// Selected index provider for convenience
final selectedIndexProvider = Provider<int>((ref) {
  return ref.watch(navigationProvider).selectedIndex;
});

/// User role provider for convenience
final userRoleProvider = Provider<String>((ref) {
  return ref.watch(navigationProvider).userRole;
});
