import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';
import '../../providers/user_provider.dart';
import '../../providers/auth_provider.dart';

/// Account screen - user profile and settings
class AccountScreen extends ConsumerWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Profile Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Avatar
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          currentUser?.fullName[0].toUpperCase() ?? 'U',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // User name
                    Text(
                      currentUser?.fullName ?? 'User',
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 4),

                    // User type badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.infoBlue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        currentUser?.profileType ?? 'User',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.infoBlue,
                        ),
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Email and city
                    Text(
                      currentUser?.email ?? 'email@example.com',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),

                    const SizedBox(height: 2),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_on,
                            size: 14, color: AppTheme.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          currentUser?.city ?? 'City',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Edit profile button
                    OutlinedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Edit profile coming soon!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      child: const Text('Edit Profile'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Menu items
            _MenuItem(
              icon: Icons.favorite_outline,
              title: 'Saved Properties',
              subtitle: 'Your favorite listings',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Saved properties coming soon!'),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            _MenuItem(
              icon: Icons.handshake_outlined,
              title: 'My Interests',
              subtitle: 'Properties you\'re interested in',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('My interests coming soon!'),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            _MenuItem(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              subtitle: 'Manage alerts and updates',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Notifications coming soon!'),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            _MenuItem(
              icon: Icons.settings_outlined,
              title: 'Settings',
              subtitle: 'App preferences and privacy',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Settings coming soon!'),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            _MenuItem(
              icon: Icons.help_outline,
              title: 'Help & Support',
              subtitle: 'FAQs and customer service',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Help coming soon!'),
                  ),
                );
              },
            ),

            const SizedBox(height: 32),

            // Logout button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showLogoutDialog(context, ref),
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.errorRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // App version
            Text(
              'ClearDeed v1.0.0',
              style: Theme.of(context).textTheme.labelSmall,
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
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
              Navigator.pop(context);
              ref.read(authProvider.notifier).logout();
              // Navigation to login will be handled by main.dart logic
            },
            child: const Text('Logout',
                style: TextStyle(color: AppTheme.errorRed)),
          ),
        ],
      ),
    );
  }
}

// ==================== Menu Item ====================

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryBlue),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
