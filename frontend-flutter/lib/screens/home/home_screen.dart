import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';
import '../../utils/app_logger.dart';
import '../../providers/user_provider.dart';
import '../../providers/property_provider.dart';
import '../../providers/navigation_provider.dart';

/// Home screen - main hub displaying property categories and quick actions
/// Part of the NavigationShell bottom tab system
class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ClearDeed'),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              AppLogger.logNavigation('Home', 'Notifications');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications coming soon')),
              );
            },
          ),
        ],
      ),
      body: const SingleChildScrollView(
        child: _HomeContent(),
      ),
    );
  }
}

// ==================== Home Content ====================

class _HomeContent extends ConsumerWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final featuredPropertiesAsync = ref.watch(featuredPropertiesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // User Greeting
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back, ${currentUser?.fullName.split(' ')[0] ?? 'User'}! 👋',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 4),
              Text(
                'Discover verified properties',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),

        // Property Category Cards Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Browse by Category',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1,
                children: [
                  _CategoryCard(
                    title: 'Land',
                    icon: Icons.terrain,
                    color: const Color(0xFF8B7355),
                    subtitle: 'Plot of land',
                    onTap: () {
                      AppLogger.logNavigation('Home', 'CategoryLand');
                      ref.read(navigationProvider.notifier).setSelectedIndex(1);
                    },
                  ),
                  _CategoryCard(
                    title: 'Houses',
                    icon: Icons.home,
                    color: const Color(0xFF1976D2),
                    subtitle: 'Residential homes',
                    onTap: () {
                      AppLogger.logNavigation('Home', 'CategoryHouses');
                      ref.read(navigationProvider.notifier).setSelectedIndex(1);
                    },
                  ),
                  _CategoryCard(
                    title: 'Commercial',
                    icon: Icons.business,
                    color: const Color(0xFF00796B),
                    subtitle: 'Business properties',
                    onTap: () {
                      AppLogger.logNavigation('Home', 'CategoryCommercial');
                      ref.read(navigationProvider.notifier).setSelectedIndex(1);
                    },
                  ),
                  _CategoryCard(
                    title: 'Agriculture',
                    icon: Icons.agriculture,
                    color: const Color(0xFF558B2F),
                    subtitle: 'Farmland & plots',
                    onTap: () {
                      AppLogger.logNavigation('Home', 'CategoryAgriculture');
                      ref.read(navigationProvider.notifier).setSelectedIndex(1);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Featured Properties Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Featured Properties',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              TextButton(
                onPressed: () {
                  AppLogger.logNavigation('Home', 'ViewAllProperties');
                },
                child: const Text('View all'),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Featured properties list
        featuredPropertiesAsync.when(
          data: (properties) {
            if (properties.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    'No featured properties available',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              );
            }

            return SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: properties.take(5).length,
                itemBuilder: (context, index) {
                  final property = properties[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _FeaturedPropertyCard(property: property),
                  );
                },
              ),
            );
          },
          loading: () => Padding(
            padding: const EdgeInsets.all(16),
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
          ),
          error: (error, stack) => Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text(
                'Failed to load featured properties',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
        ),

        const SizedBox(height: 32),

        // Quick Action Buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1,
                children: [
                  _QuickActionCard(
                    title: 'Buy',
                    subtitle: 'Find properties',
                    icon: Icons.shopping_cart,
                    color: AppTheme.primaryBlue,
                    onTap: () {
                      AppLogger.logNavigation('Home', 'Buy');
                      ref.read(navigationProvider.notifier).setSelectedIndex(1);
                    },
                  ),
                  _QuickActionCard(
                    title: 'Sell',
                    subtitle: 'List property',
                    icon: Icons.home_work,
                    color: const Color(0xFF26A69A),
                    onTap: () {
                      AppLogger.logNavigation('Home', 'Sell');
                      ref.read(navigationProvider.notifier).setSelectedIndex(2);
                    },
                  ),
                  _QuickActionCard(
                    title: 'Invest',
                    subtitle: 'Explore deals',
                    icon: Icons.trending_up,
                    color: const Color(0xFFEF5350),
                    onTap: () {
                      AppLogger.logNavigation('Home', 'Invest');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Investment section coming soon'),
                        ),
                      );
                    },
                  ),
                  _QuickActionCard(
                    title: 'History',
                    subtitle: 'Your activity',
                    icon: Icons.history,
                    color: const Color(0xFFFFB300),
                    onTap: () {
                      AppLogger.logNavigation('Home', 'History');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Activity history coming soon'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Info banner
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryBlue,
                  AppTheme.primaryBlue.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.security,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Verified & Secure',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '100% verified properties & sellers',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }
}

// ==================== Category Card ====================

class _CategoryCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Card(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            gradient: LinearGradient(
              colors: [widget.color, widget.color.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(widget.icon, color: Colors.white, size: 36),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.subtitle,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
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

// ==================== Quick Action Card ====================

class _QuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: Colors.white, size: 32),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== Featured Property Card ====================

class _FeaturedPropertyCard extends StatelessWidget {
  final dynamic property;

  const _FeaturedPropertyCard({required this.property});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          image: property.imageUrl != null
              ? DecorationImage(
                  image: NetworkImage(property.imageUrl!),
                  fit: BoxFit.cover,
                )
              : null,
          color: AppTheme.lightGrey,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            gradient: LinearGradient(
              colors: [Colors.black26, Colors.black12],
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Verified badge
                if (property.verifiedBadge)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.successGreen,
                      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified, color: Colors.white, size: 12),
                        SizedBox(width: 4),
                        Text(
                          'Verified',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                // Property info
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      property.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹${property.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
