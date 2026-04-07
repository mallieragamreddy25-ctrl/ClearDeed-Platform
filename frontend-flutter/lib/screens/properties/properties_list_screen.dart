import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'property_detail_screen.dart';
import 'property_filter_screen.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';
import '../../utils/app_logger.dart';
import '../../providers/property_provider.dart';
import '../../models/property.dart';

/// Properties list screen - Browse properties with filters, pagination, and pull-to-refresh
class PropertiesListScreen extends ConsumerStatefulWidget {
  const PropertiesListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PropertiesListScreen> createState() =>
      _PropertiesListScreenState();
}

class _PropertiesListScreenState extends ConsumerState<PropertiesListScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _searchController;
  bool _isGridView = true;
  late ScrollController _scrollController;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _scrollController = ScrollController();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    AppLogger.logFunctionEntry('PropertiesListScreen.initState');

    // Load properties on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(propertyListProvider.notifier).loadProperties();
      _fadeController.forward();
    });

    // Load more when scrolling near bottom (infinite scroll)
    _scrollController.addListener(_onScrollListener);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_onScrollListener);
    _scrollController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  /// Infinite scroll listener
  void _onScrollListener() {
    if (_scrollController.position.pixels >
        _scrollController.position.maxScrollExtent - 500) {
      ref.read(propertyListProvider.notifier).loadNextPage();
    }
  }

  /// Handle pull-to-refresh
  Future<void> _onRefresh() async {
    _searchController.clear();
    await ref.read(propertyListProvider.notifier).loadProperties();
  }

  /// Show filter modal
  void _showFilterDialog() {
    AppLogger.logNavigation('PropertiesListScreen', 'PropertyFilterScreen');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PropertyFilterScreen(
        currentFilter: ref.read(propertyListProvider).filter,
        onApply: (filters) {
          ref.read(propertyListProvider.notifier).updateFilter(filters);
          Navigator.pop(context);
        },
      ),
    );
  }

  /// Build property card
  Widget _buildPropertyCard(Property property, {bool isGridView = false}) {
    return GestureDetector(
      onTap: () {
        AppLogger.logNavigation(
          'PropertiesListScreen',
          'PropertyDetailScreen',
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                PropertyDetailScreen(propertyId: property.id),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderGrey, width: 1),
          color: AppTheme.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image with badges
              Stack(
                children: [
                  // Image
                  AspectRatio(
                    aspectRatio: isGridView ? 1 : 2,
                    child: Container(
                      color: AppTheme.lightGrey,
                      child: property.imageUrl != null
                          ? Image.network(
                              property.imageUrl!,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                );
                              },
                              errorBuilder: (ctx, error, stackTrace) {
                                return Center(
                                  child: Icon(
                                    Icons.image,
                                    color: AppTheme.textHint,
                                    size: 40,
                                  ),
                                );
                              },
                            )
                          : Center(
                              child: Icon(
                                Icons.home,
                                color: AppTheme.textHint,
                                size: 40,
                              ),
                            ),
                    ),
                  ),
                  // Verified badge
                  if (property.isVerified)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.successGreen,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_circle,
                              size: 14,
                              color: AppTheme.white,
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'Verified',
                              style: TextStyle(
                                color: AppTheme.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        property.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Location
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 13,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              property.location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Category & Area
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.lightGrey,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              property.category,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${property.area.toStringAsFixed(0)} ${property.areaUnit}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Price
                      Text(
                        '₹${_formatPrice(property.price)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build loading skeleton card
  Widget _buildSkeletonCard({bool isGridView = false}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderGrey, width: 1),
        color: AppTheme.white,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: isGridView ? 1 : 2,
              child: Container(
                color: AppTheme.lightGrey,
                child: Shimmer.fromColors(
                  baseColor: AppTheme.lightGrey,
                  highlightColor: Colors.white.withOpacity(0.5),
                  child: Container(color: AppTheme.lightGrey),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 12,
                      color: AppTheme.lightGrey,
                      margin: const EdgeInsets.only(bottom: 8),
                    ),
                    Container(
                      height: 10,
                      color: AppTheme.lightGrey,
                      margin: const EdgeInsets.only(bottom: 12),
                    ),
                    Container(
                      height: 10,
                      color: AppTheme.lightGrey,
                      margin: const EdgeInsets.only(bottom: 12),
                    ),
                    const Spacer(),
                    Container(
                      height: 14,
                      color: AppTheme.lightGrey,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Format price display
  String _formatPrice(double price) {
    if (price >= 10000000) {
      return '${(price / 10000000).toStringAsFixed(1)}Cr';
    } else if (price >= 100000) {
      return '${(price / 100000).toStringAsFixed(0)}L';
    }
    return price.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final propertyListState = ref.watch(propertyListProvider);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Properties'),
        elevation: 2,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: CustomScrollView(
          slivers: [
            // Search Bar
            SliverAppBar(
              floating: true,
              pinned: false,
              backgroundColor: AppTheme.lightGrey,
              elevation: 0,
              flexibleSpace: Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search properties...',
                    filled: true,
                    fillColor: AppTheme.white,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _onSearch('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppConstants.borderRadius),
                      borderSide: const BorderSide(color: AppTheme.textHint),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                  onChanged: _onSearch,
                ),
              ),
            ),

            // Filters and View Toggle
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            // Category filter
                            _buildFilterChip(
                              label: _selectedCategory ?? 'Category',
                              isActive: _selectedCategory != null,
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return SimpleDialog(
                                      title: const Text('Select Category'),
                                      children: [
                                        ...AppConstants.propertyCategories
                                            .map((cat) => SimpleDialogOption(
                                                  onPressed: () {
                                                    _onCategoryChanged(cat);
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text(cat),
                                                ))
                                            .toList(),
                                        SimpleDialogOption(
                                          onPressed: () {
                                            _onCategoryChanged(null);
                                            Navigator.pop(context);
                                          },
                                          child: const Text('Clear'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                            const SizedBox(width: 8),
                            // Filter button
                            ElevatedButton.icon(
                              onPressed: _showFilterDialog,
                              icon: const Icon(Icons.tune, size: 18),
                              label: const Text('More Filters'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.lightGrey,
                                foregroundColor: AppTheme.primaryBlue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppConstants.borderRadius,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // View toggle
                    Material(
                      color: Colors.transparent,
                      child: Tooltip(
                        message: _isGridView ? 'List View' : 'Grid View',
                        child: IconButton(
                          icon: Icon(
                            _isGridView ? Icons.list : Icons.grid_3x3,
                            color: AppTheme.primaryBlue,
                          ),
                          onPressed: () =>
                              setState(() => _isGridView = !_isGridView),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Error message
            if (propertyListState.error != null)
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.errorRed.withOpacity(0.1),
                    border: Border.all(color: AppTheme.errorRed),
                    borderRadius:
                        BorderRadius.circular(AppConstants.borderRadius),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: AppTheme.errorRed, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          propertyListState.error ?? 'An error occurred',
                          style: const TextStyle(color: AppTheme.errorRed),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close,
                            color: AppTheme.errorRed, size: 20),
                        onPressed: () {
                          ref
                              .read(propertyListProvider.notifier)
                              .clearError();
                        },
                      ),
                    ],
                  ),
                ),
              ),

            // Properties list/grid
            if (propertyListState.isLoading &&
                propertyListState.properties.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(strokeWidth: 2),
                      const SizedBox(height: 16),
                      Text(
                        'Loading properties...',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              )
            else if (propertyListState.properties.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.home_outlined,
                        size: 64,
                        color: AppTheme.textHint,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No properties found',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Try adjusting your filters or search criteria',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              )
            else if (_isGridView)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                sliver: SliverGrid(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.75,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final property = propertyListState.properties[index];
                      return _PropertyGridCard(property: property);
                    },
                    childCount: propertyListState.properties.length,
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final property = propertyListState.properties[index];
                    return _PropertyListCard(property: property);
                  },
                  childCount: propertyListState.properties.length,
                ),
              ),

            // Load more button
            if (propertyListState.hasMore && propertyListState.properties.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: propertyListState.isLoading
                          ? null
                          : () {
                              ref
                                  .read(propertyListProvider.notifier)
                                  .loadNextPage();
                            },
                      child: propertyListState.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text('Load More Properties'),
                    ),
                  ),
                ),
              ),

            // Bottom padding
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primaryBlue : AppTheme.lightGrey,
          border: Border.all(
            color: isActive ? AppTheme.primaryBlue : AppTheme.textHint,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? AppTheme.white : AppTheme.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ==================== Property Grid Card ====================

class _PropertyGridCard extends StatelessWidget {
  final dynamic property;

  const _PropertyGridCard({required this.property});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PropertyDetailScreen(propertyId: property.id),
          ),
        );
      },
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(8),
                  ),
                  image: property.imageUrl != null
                      ? DecorationImage(
                          image: NetworkImage(property.imageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                  color: AppTheme.lightGrey,
                ),
                child: property.verifiedBadge
                    ? Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.successGreen,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.verified,
                                    color: Colors.white, size: 12),
                                SizedBox(width: 2),
                                Text(
                                  'Verified',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : null,
              ),
            ),

            // Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    property.location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${(property.price / 10000000).toStringAsFixed(1)}Cr',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                      Text(
                        '${property.area.toStringAsFixed(0)} ${property.areaUnit}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== Property List Card ====================

class _PropertyListCard extends StatelessWidget {
  final dynamic property;

  const _PropertyListCard({required this.property});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PropertyDetailScreen(propertyId: property.id),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Image
              Container(
                width: 100,
                height: 100,
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
              ),

              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            property.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        if (property.verifiedBadge)
                          const Icon(
                            Icons.verified,
                            color: AppTheme.successGreen,
                            size: 16,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      property.location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '₹${(property.price / 10000000).toStringAsFixed(1)}Cr',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                        Text(
                          '${property.area.toStringAsFixed(0)} ${property.areaUnit}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
