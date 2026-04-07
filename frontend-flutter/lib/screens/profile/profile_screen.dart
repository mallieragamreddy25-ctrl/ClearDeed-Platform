import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';
import '../../utils/app_logger.dart';
import '../../providers/user_provider.dart';
import '../../providers/navigation_provider.dart';
import '../mode_selector_screen.dart';

/// Profile screen - displays user information and commission tracking for agents
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _showCommissionDetails = false;

  @override
  void initState() {
    super.initState();
    AppLogger.logFunctionEntry('ProfileScreen.initState');
  }

  void _navigateToModeSelector() {
    AppLogger.logNavigation('Profile', 'ModeSelector');
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ModeSelectorScreen(),
      ),
    );
  }

  Future<void> _logout() async {
    AppLogger.logAuthEvent('User initiated logout');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(currentUserProvider.notifier).logout();
              Navigator.pop(context);
            },
            child: const Text('Logout', style: TextStyle(color: AppTheme.errorRed)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserAsync = ref.watch(currentUserProvider);
    final userRole = ref.watch(userRoleProvider);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        elevation: 0,
        centerTitle: true,
      ),
      body: currentUserAsync.when(
        data: (user) {
          if (user == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.person_outline,
                    size: 64,
                    color: AppTheme.textHint,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No profile data',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => ref.refresh(currentUserProvider),
                    child: const Text('Refresh'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header
                _ProfileHeader(user: user),
                const SizedBox(height: 24),

                // User Information Section
                _UserInfoCard(user: user),
                const SizedBox(height: 24),

                // Commission Section (for agents)
                if (userRole == 'seller' || userRole == 'agent')
                  ...[
                    _CommissionCard(
                      isExpanded: _showCommissionDetails,
                      onTap: () => setState(
                        () => _showCommissionDetails = !_showCommissionDetails,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                // Referral Link Section
                _ReferralLinkCard(referralCode: '${user.fullName}${user.id}'),
                const SizedBox(height: 24),

                // Role Switching
                _RoleSwitchCard(
                  currentRole: userRole,
                  onTap: _navigateToModeSelector,
                ),
                const SizedBox(height: 24),

                // Settings Section
                _SettingsSection(),
                const SizedBox(height: 24),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.errorRed,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: _logout,
                  ),
                ),
                const SizedBox(height: 24),

                // Version info
                Center(
                  child: Text(
                    'ClearDeed v1.0.0',
                    style: Theme.of(context).textTheme.labelSmall,
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
                'Failed to load profile',
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
    );
  }
}

// ==================== Profile Header ====================

class _ProfileHeader extends StatelessWidget {
  final dynamic user;

  const _ProfileHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryBlue.withOpacity(0.1),
              ),
              child: Center(
                child: Text(
                  user.fullName.isNotEmpty
                      ? user.fullName[0].toUpperCase()
                      : 'U',
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Name
            Text(
              user.fullName,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),

            // Verification badge
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (user.isVerified)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.successGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.verified,
                          size: 14,
                          color: AppTheme.successGreen,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Verified',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppTheme.successGreen,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.warningOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.pending,
                          size: 14,
                          color: AppTheme.warningOrange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Pending',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppTheme.warningOrange,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Mobile number
            Text(
              user.mobileNumber,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== User Info Card ====================

class _UserInfoCard extends StatelessWidget {
  final dynamic user;

  const _UserInfoCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          _InfoTile(
            icon: Icons.email_outlined,
            title: 'Email',
            value: user.email,
          ),
          const Divider(indent: 16, endIndent: 16),
          _InfoTile(
            icon: Icons.location_on_outlined,
            title: 'City',
            value: user.city,
          ),
          const Divider(indent: 16, endIndent: 16),
          _InfoTile(
            icon: Icons.badge_outlined,
            title: 'Profile Type',
            value: user.profileType == 'buyer'
                ? 'Buyer'
                : user.profileType == 'seller'
                    ? 'Seller'
                    : 'Investor',
          ),
          const Divider(indent: 16, endIndent: 16),
          _InfoTile(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Member Since',
            value: 'March 2024',
          ),
        ],
      ),
    );
  }
}

// ==================== Info Tile ====================

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryBlue, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== Commission Card ====================

class _CommissionCard extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onTap;

  const _CommissionCard({
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(
              Icons.trending_up,
              color: AppTheme.successGreen,
            ),
            title: const Text('Commission Tracking'),
            trailing: Icon(
              isExpanded ? Icons.expand_less : Icons.expand_more,
            ),
            onTap: onTap,
          ),
          if (isExpanded) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Commissions Earned',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        '₹2,50,000',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.successGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'This Month',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        '₹45,000',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pending Payouts',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        '₹15,000',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.warningOrange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        AppLogger.logNavigation('Profile', 'CommissionLedger');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Commission ledger coming soon'),
                          ),
                        );
                      },
                      child: const Text('View Commission Ledger'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ==================== Referral Link Card ====================

class _ReferralLinkCard extends StatelessWidget {
  final String referralCode;

  const _ReferralLinkCard({required this.referralCode});

  void _copyToClipboard(BuildContext context) {
    AppLogger.logNavigation('Profile', 'CopyReferralLink');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Referral link copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final referralLink = 'https://cleardeed.app/?ref=$referralCode';

    return Card(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.share_outlined,
                      color: AppTheme.primaryBlue,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Referral Link',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Share your referral link and earn rewards when your friends sign up',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.lightGrey,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: SelectableText(
                          referralLink,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () => _copyToClipboard(context),
                        splashRadius: 24,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.share),
                label: const Text('Share'),
                onPressed: () {
                  AppLogger.logNavigation('Profile', 'ShareReferral');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Share functionality coming soon'),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ==================== Role Switch Card ====================

class _RoleSwitchCard extends StatelessWidget {
  final String currentRole;
  final VoidCallback onTap;

  const _RoleSwitchCard({
    required this.currentRole,
    required this.onTap,
  });

  String _getRoleDisplay(String role) {
    switch (role) {
      case 'buyer':
        return 'Buyer';
      case 'seller':
        return 'Seller';
      case 'investor':
        return 'Investor';
      case 'agent':
        return 'Agent';
      default:
        return 'User';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(
          Icons.switch_account,
          color: AppTheme.primaryBlue,
        ),
        title: const Text('Switch Role'),
        subtitle:
            Text('Current: ${_getRoleDisplay(currentRole)}'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

// ==================== Settings Section ====================

class _SettingsSection extends StatelessWidget {
  const _SettingsSection();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Notifications'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              AppLogger.logNavigation('Profile', 'Notifications');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notifications settings coming soon'),
                ),
              );
            },
          ),
          const Divider(indent: 16, endIndent: 16),
          ListTile(
            leading: const Icon(Icons.security_outlined),
            title: const Text('Privacy & Security'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              AppLogger.logNavigation('Profile', 'Privacy');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Privacy settings coming soon'),
                ),
              );
            },
          ),
          const Divider(indent: 16, endIndent: 16),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help & Support'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              AppLogger.logNavigation('Profile', 'Support');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Help & support coming soon'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
