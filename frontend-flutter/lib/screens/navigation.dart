import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../utils/app_logger.dart';
import '../providers/navigation_provider.dart';
import 'home/home_screen.dart';
import 'properties/properties_list_screen.dart';
import 'sell/sell_screen.dart';
import 'profile/profile_screen.dart';

/// Main navigation shell - manages bottom navigation and page switching
/// This is the root widget after authentication
class NavigationShell extends ConsumerStatefulWidget {
  const NavigationShell({Key? key}) : super(key: key);

  @override
  ConsumerState<NavigationShell> createState() => _NavigationShellState();
}

class _NavigationShellState extends ConsumerState<NavigationShell> {
  late PageController _pageController;
  final Map<int, GlobalKey<NavigatorState>> _navigatorKeys = {
    0: GlobalKey<NavigatorState>(),
    1: GlobalKey<NavigatorState>(),
    2: GlobalKey<NavigatorState>(),
    3: GlobalKey<NavigatorState>(),
  };

  @override
  void initState() {
    super.initState();
    AppLogger.logFunctionEntry('NavigationShell.initState');
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop(int currentIndex) async {
    // Allow back navigation within the current tab's navigator
    final isFirstRouteInCurrentTab =
        !await _navigatorKeys[currentIndex]!.currentState!.maybePop();
    if (isFirstRouteInCurrentTab) {
      // If at home tab, exit app; otherwise switch to home
      if (currentIndex != 0) {
        _onNavigationTapped(0);
        return false;
      }
    }
    return isFirstRouteInCurrentTab;
  }

  void _onNavigationTapped(int index) {
    AppLogger.logNavigation('BottomNav', _getTabName(index));
    ref.read(navigationProvider.notifier).setSelectedIndex(index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  String _getTabName(int index) {
    const tabs = ['Home', 'Browse', 'Sell', 'Profile'];
    return tabs[index];
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(selectedIndexProvider);

    return WillPopScope(
      onWillPop: () => _onWillPop(selectedIndex),
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            ref.read(navigationProvider.notifier).setSelectedIndex(index);
          },
          physics: const NeverScrollableScrollPhysics(),
          children: [
            // Home Tab
            _buildTab(
              _navigatorKeys[0]!,
              const HomeScreen(),
            ),
            // Browse/Properties Tab
            _buildTab(
              _navigatorKeys[1]!,
              const PropertiesListScreen(),
            ),
            // Sell Tab
            _buildTab(
              _navigatorKeys[2]!,
              const SellScreen(),
            ),
            // Profile Tab
            _buildTab(
              _navigatorKeys[3]!,
              const ProfileScreen(),
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomNavigationBar(selectedIndex),
      ),
    );
  }

  /// Build a tab with its own navigator for deep linking support
  Widget _buildTab(GlobalKey<NavigatorState> key, Widget home) {
    return Navigator(
      key: key,
      onGenerateRoute: (setting) {
        return MaterialPageRoute(
          builder: (context) => home,
        );
      },
    );
  }

  /// Build the bottom navigation bar with role-aware icons
  Widget _buildBottomNavigationBar(int selectedIndex) {
    const navItems = [
      BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home),
        label: 'Home',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.search_outlined),
        activeIcon: Icon(Icons.search),
        label: 'Browse',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.add_box_outlined),
        activeIcon: Icon(Icons.add_box),
        label: 'Sell',
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.person_outlined),
        activeIcon: Icon(Icons.person),
        label: 'Profile',
      ),
    ];

    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: _onNavigationTapped,
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppTheme.white,
      selectedItemColor: AppTheme.primaryBlue,
      unselectedItemColor: AppTheme.textSecondary,
      selectedLabelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      elevation: 8,
      items: navItems,
    );
  }
}
