import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';
import '../utils/app_logger.dart';
import '../providers/user_provider.dart';
import '../providers/navigation_provider.dart';

/// Mode selector screen - allows users to choose Buyer/Seller/Investor role
class ModeSelectorScreen extends ConsumerStatefulWidget {
  final VoidCallback? onModeSelected;

  const ModeSelectorScreen({
    Key? key,
    this.onModeSelected,
  }) : super(key: key);

  @override
  ConsumerState<ModeSelectorScreen> createState() => _ModeSelectorScreenState();
}

class _ModeSelectorScreenState extends ConsumerState<ModeSelectorScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  String? _selectedMode;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    AppLogger.logFunctionEntry('ModeSelectorScreen.initState');
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _selectMode(String mode) async {
    AppLogger.logNavigation('ModeSelector', 'Selected: $mode');
    setState(() => _selectedMode = mode);
    _animationController.forward();

    setState(() => _isLoading = true);

    try {
      // Update navigation state
      ref.read(navigationProvider.notifier).setUserRole(mode.toLowerCase());

      // Update user role in backend
      final userNotifier = ref.read(currentUserProvider.notifier);
      await userNotifier.updateUserProfile(profileType: mode.toLowerCase());

      if (widget.onModeSelected != null) {
        widget.onModeSelected!();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Switched to $mode mode'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      AppLogger.error('Failed to select mode: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to switch mode: $e'),
            backgroundColor: AppTheme.errorRed,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserAsync = ref.watch(currentUserProvider);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Your Role'),
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: currentUserAsync.when(
          data: (user) {
            final currentRole = user?.profileType ?? 'buyer';

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    'What would you like to do?',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Switch between roles to access different features',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 32),

                  // Mode cards grid
                  GridView.count(
                    crossAxisCount: isMobile ? 1 : 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    childAspectRatio: isMobile ? 1.2 : 1,
                    children: [
                      _ModeCard(
                        icon: Icons.shopping_cart_outlined,
                        title: 'Buyer',
                        subtitle: 'Search & buy properties',
                        description: 'Browse verified properties and connect with sellers',
                        isSelected: currentRole == 'buyer',
                        isLoading: _isLoading && _selectedMode == 'Buyer',
                        onTap: _isLoading ? null : () => _selectMode('Buyer'),
                        color: const Color(0xFF1976D2),
                      ),
                      _ModeCard(
                        icon: Icons.home_work_outlined,
                        title: 'Seller',
                        subtitle: 'List & sell properties',
                        description: 'Upload your properties and reach potential buyers',
                        isSelected: currentRole == 'seller',
                        isLoading: _isLoading && _selectedMode == 'Seller',
                        onTap: _isLoading ? null : () => _selectMode('Seller'),
                        color: const Color(0xFF388E3C),
                      ),
                      _ModeCard(
                        icon: Icons.trending_up_outlined,
                        title: 'Investor',
                        subtitle: 'Explore investment deals',
                        description: 'Analyze and invest in promising real estate projects',
                        isSelected: currentRole == 'investor',
                        isLoading: _isLoading && _selectedMode == 'Investor',
                        onTap: _isLoading ? null : () => _selectMode('Investor'),
                        color: const Color(0xFFD32F2F),
                      ),
                      if (!isMobile)
                        _ModeCard(
                          icon: Icons.business_center_outlined,
                          title: 'Agent',
                          subtitle: 'Manage deals & commission',
                          description: 'Track deals, earn commissions, and manage referrals',
                          isSelected: currentRole == 'agent',
                          isLoading: _isLoading && _selectedMode == 'Agent',
                          onTap: _isLoading ? null : () => _selectMode('Agent'),
                          color: const Color(0xFF7B1FA2),
                        ),
                    ],
                  ),

                  if (isMobile) ...[
                    const SizedBox(height: 20),
                    _ModeCard(
                      icon: Icons.business_center_outlined,
                      title: 'Agent',
                      subtitle: 'Manage deals & commission',
                      description: 'Track deals, earn commissions, and manage referrals',
                      isSelected: currentRole == 'agent',
                      isLoading: _isLoading && _selectedMode == 'Agent',
                      onTap: _isLoading ? null : () => _selectMode('Agent'),
                      color: const Color(0xFF7B1FA2),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Info banner
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.lightGrey,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.primaryBlue.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outlined,
                          color: AppTheme.primaryBlue,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'You can switch between roles anytime from your profile',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppTheme.errorRed,
                ),
                const SizedBox(height: 16),
                Text(
                  'Failed to load user data',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => ref.refresh(currentUserProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== Mode Card Widget ====================

class _ModeCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String description;
  final bool isSelected;
  final bool isLoading;
  final VoidCallback? onTap;
  final Color color;

  const _ModeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.isSelected,
    required this.isLoading,
    required this.color,
    this.onTap,
  });

  @override
  State<_ModeCard> createState() => _ModeCardState();
}

class _ModeCardState extends State<_ModeCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap() {
    if (widget.onTap != null) {
      _controller.forward().then((_) {
        _controller.reverse();
      });
      widget.onTap!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween(begin: 1.0, end: 0.95).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: GestureDetector(
        onTap: widget.isLoading ? null : _onTap,
        child: Card(
          elevation: widget.isSelected ? 4 : 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: widget.isSelected ? widget.color : Colors.transparent,
              width: 2,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: widget.isSelected ? widget.color.withOpacity(0.05) : Colors.white,
            ),
            padding: const EdgeInsets.all(20),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Icon and title
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: widget.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        widget.icon,
                        color: widget.color,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textHint,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
                // Selected badge and loading
                if (widget.isSelected || widget.isLoading)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: widget.isLoading
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                widget.color,
                              ),
                            ),
                          )
                        : Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: widget.color,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
