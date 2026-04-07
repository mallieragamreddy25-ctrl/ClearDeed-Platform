import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/investment_project.dart';
import '../../providers/project_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_logger.dart';
import 'project_detail_screen.dart';

/// Investment Projects List Screen
/// Displays projects with filters, pagination, and pull-to-refresh
class ProjectsListScreen extends ConsumerStatefulWidget {
  const ProjectsListScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProjectsListScreen> createState() => _ProjectsListScreenState();
}

class _ProjectsListScreenState extends ConsumerState<ProjectsListScreen> {
  late ScrollController _scrollController;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 500) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (!_isLoadingMore) {
      setState(() => _isLoadingMore = true);
      final notifier = ref.read(projectFilterProvider.notifier);
      await notifier.nextPage();
      setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _refreshProjects() async {
    final notifier = ref.read(projectFilterProvider.notifier);
    await notifier.resetFilter();
  }

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Investment Projects'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterSheet(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshProjects,
        child: projectsAsync.when(
          data: (projects) {
            if (projects.isEmpty) {
              return _buildEmptyState();
            }

            return ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: projects.length + (_isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == projects.length) {
                  return _buildLoadingMore();
                }
                return _buildProjectCard(context, projects[index]);
              },
            );
          },
          loading: () => _buildLoadingState(),
          error: (error, stack) => _buildErrorState(error, _refreshProjects),
        ),
      ),
    );
  }

  Widget _buildProjectCard(BuildContext context, InvestmentProject project) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    final roi = project.expectedReturn;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProjectDetailScreen(projectId: project.id),
          ),
        ),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Project Image/Header
            Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryBlue.withOpacity(0.8),
                    AppTheme.primaryBlue.withOpacity(0.6),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  if (project.projectImages.isNotEmpty)
                    Image.network(
                      project.projectImages.first,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholder(),
                    )
                  else
                    _buildPlaceholder(),

                  // Status badge
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(project.status),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        project.status.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // Progress indicator
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                      child: LinearProgressIndicator(
                        value: project.progressPercentage / 100,
                        minHeight: 4,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.successGreen,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Project Details
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.headlineSmall(),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 14,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          project.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMetricTile(
                        'Min Investment',
                        currencyFormat.format(project.minInvestment),
                      ),
                      _buildMetricTile(
                        'ROI',
                        '${roi.toStringAsFixed(1)}%',
                        color: AppTheme.successGreen,
                      ),
                      _buildMetricTile(
                        'Timeline',
                        '${project.expectedReturnMonths}M',
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${project.progressPercentage.toStringAsFixed(0)}% Funded',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      Text(
                        '${project.investorCount} Investors',
                        style: const TextStyle(
                          fontSize: 12,
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

  Widget _buildMetricTile(String label, String value, {Color? color}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color ?? AppTheme.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppTheme.lightGrey,
      child: const Center(
        child: Icon(
          Icons.business,
          size: 48,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox,
            size: 64,
            color: AppTheme.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No projects found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try adjusting your filters',
            style: TextStyle(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          const Text('Loading projects...'),
        ],
      ),
    );
  }

  Widget _buildLoadingMore() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: SizedBox(
          width: 30,
          height: 30,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              AppTheme.primaryBlue,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(Object error, Future<void> Function() onRetry) {
    AppLogger.error('ProjectsList Error: $error');

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: AppTheme.errorRed,
          ),
          const SizedBox(height: 16),
          const Text(
            'Failed to load projects',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    final filter = ref.read(projectFilterProvider);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) => _FilterSheet(
        currentFilter: filter,
        onApply: (newFilter) {
          ref.read(projectFilterProvider.notifier).setFilter(newFilter);
          Navigator.pop(context);
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AppTheme.successGreen;
      case 'planning':
        return AppTheme.infoBlue;
      case 'completed':
        return AppTheme.textSecondary;
      case 'on_hold':
        return AppTheme.warningOrange;
      default:
        return AppTheme.accentGrey;
    }
  }
}

class _FilterSheet extends StatefulWidget {
  final ProjectFilter currentFilter;
  final Function(ProjectFilter) onApply;

  const _FilterSheet({
    required this.currentFilter,
    required this.onApply,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late double _minInvestment;
  late double _maxROI;

  @override
  void initState() {
    super.initState();
    _minInvestment = widget.currentFilter.minInvestment ?? 100000;
    _maxROI = widget.currentFilter.maxROI ?? 50;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filters',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Min Investment
          Text(
            'Minimum Investment: ₹${_minInvestment.toStringAsFixed(0)}',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Slider(
            value: _minInvestment,
            min: 10000,
            max: 1000000,
            onChanged: (value) => setState(() => _minInvestment = value),
          ),

          const SizedBox(height: 20),

          // Max ROI
          Text(
            'Maximum ROI: ${_maxROI.toStringAsFixed(1)}%',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Slider(
            value: _maxROI,
            min: 5,
            max: 100,
            onChanged: (value) => setState(() => _maxROI = value),
          ),

          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final newFilter = widget.currentFilter.copyWith(
                  minInvestment: _minInvestment,
                  maxROI: _maxROI,
                  page: 1,
                );
                widget.onApply(newFilter);
              },
              child: const Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }
}
  ) {
    if (state.isLoading && state.projects.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryBlue),
      );
    }

    if (state.error != null && state.projects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppTheme.errorRed),
            const SizedBox(height: 16),
            Text(
              'Error loading projects',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.error ?? 'An unknown error occurred',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(projectsProvider);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.projects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox_outlined, size: 64, color: AppTheme.textHint),
            const SizedBox(height: 16),
            Text(
              'No projects found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters',
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.projects.length + (state.hasMore && state.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= state.projects.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: CircularProgressIndicator(color: AppTheme.primaryBlue),
            ),
          );
        }

        final project = state.projects[index];

        // Load more when reaching end
        if (index == state.projects.length - 3) {
          Future.microtask(() {
            ref.read(projectsProvider.notifier).loadMoreProjects();
          });
        }

        return _ProjectCard(project: project);
      },
    );
  }
}

/// Project card widget
class _ProjectCard extends ConsumerWidget {
  final InvestmentProject project;

  const _ProjectCard({required this.project});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyFormat = NumberFormat.currency(symbol: '₹');

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProjectDetailScreen(projectId: project.id),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Project Image
            if (project.projectImages.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: Image.network(
                  project.projectImages.first,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: AppTheme.lightGrey,
                      child: const Icon(Icons.image_not_supported,
                          size: 48, color: AppTheme.textHint),
                    );
                  },
                ),
              )
            else
              Container(
                height: 200,
                color: AppTheme.lightGrey,
                child: const Icon(Icons.image_not_supported,
                    size: 48, color: AppTheme.textHint),
              ),
            // Project Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Category
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              project.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.location_on,
                                    size: 16, color: AppTheme.textSecondary),
                                const SizedBox(width: 4),
                                Text(
                                  '${project.location}, ${project.city}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: AppTheme.textSecondary),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getStatusColor(project.status),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          project.status.toUpperCase(),
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppTheme.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Progress Bar
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Raised: ${project.progressPercentage.toStringAsFixed(0)}%',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            currencyFormat.format(project.raisedAmount),
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppTheme.successGreen),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: project.progressPercentage / 100,
                          minHeight: 8,
                          backgroundColor: AppTheme.lightGrey,
                          valueColor: AlwaysStoppedAnimation(
                            _getProgressColor(project.progressPercentage),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Key Info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoChip(
                        context,
                        'Min Investment',
                        currencyFormat.format(project.minInvestment),
                      ),
                      _buildInfoChip(
                        context,
                        'ROI',
                        '${project.expectedReturn.toStringAsFixed(1)}%',
                      ),
                      _buildInfoChip(
                        context,
                        'Timeline',
                        '${project.expectedReturnMonths}M',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProjectDetailScreen(projectId: project.id),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'View Details',
                        style: TextStyle(
                          color: AppTheme.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AppTheme.successGreen;
      case 'planning':
        return AppTheme.infoBlue;
      case 'completed':
        return AppTheme.accentGrey;
      case 'on_hold':
        return AppTheme.warningOrange;
      default:
        return AppTheme.textSecondary;
    }
  }

  Color _getProgressColor(double percentage) {
    if (percentage >= 75) return AppTheme.successGreen;
    if (percentage >= 50) return AppTheme.infoBlue;
    if (percentage >= 25) return AppTheme.warningOrange;
    return AppTheme.errorRed;
  }

  Widget _buildInfoChip(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall
              ?.copyWith(color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.labelLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

/// Filter bottom sheet
class _FilterBottomSheet extends ConsumerWidget {
  final ProjectFilter filter;
  final WidgetRef ref;

  const _FilterBottomSheet({required this.filter, required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: AppTheme.white,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16) +
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter Projects',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                TextButton(
                  onPressed: () {
                    ref.read(projectFilterProvider.notifier).clearFilters();
                    Navigator.pop(context);
                  },
                  child: const Text('Clear All'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Category
            Text(
              'Category',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            _buildCategoryDropdown(context, ref, filter),
            const SizedBox(height: 20),
            // City
            Text(
              'City',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            _buildCityDropdown(context, ref, filter),
            const SizedBox(height: 20),
            // Investment Range
            Text(
              'Investment Range',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            _buildInvestmentRangeSlider(context, ref, filter),
            const SizedBox(height: 24),
            // Apply Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(color: AppTheme.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown(
    BuildContext context,
    WidgetRef ref,
    ProjectFilter filter,
  ) {
    return DropdownButtonFormField<String?>(
      value: filter.category,
      items: [
        const DropdownMenuItem(value: null, child: Text('All Categories')),
        const DropdownMenuItem(value: 'real_estate', child: Text('Real Estate')),
        const DropdownMenuItem(value: 'startup', child: Text('Startup')),
        const DropdownMenuItem(value: 'technology', child: Text('Technology')),
        const DropdownMenuItem(value: 'infrastructure', child: Text('Infrastructure')),
      ],
      onChanged: (value) {
        ref.read(projectFilterProvider.notifier).updateCategory(value);
      },
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      ),
    );
  }

  Widget _buildCityDropdown(
    BuildContext context,
    WidgetRef ref,
    ProjectFilter filter,
  ) {
    return DropdownButtonFormField<String?>(
      value: filter.city,
      items: [
        const DropdownMenuItem(value: null, child: Text('All Cities')),
        const DropdownMenuItem(value: 'mumbai', child: Text('Mumbai')),
        const DropdownMenuItem(value: 'bangalore', child: Text('Bangalore')),
        const DropdownMenuItem(value: 'delhi', child: Text('Delhi')),
        const DropdownMenuItem(value: 'pune', child: Text('Pune')),
      ],
      onChanged: (value) {
        ref.read(projectFilterProvider.notifier).updateCity(value);
      },
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      ),
    );
  }

  Widget _buildInvestmentRangeSlider(
    BuildContext context,
    WidgetRef ref,
    ProjectFilter filter,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Min: ₹${filter.minInvestment?.toStringAsFixed(0) ?? "0"} - Max: ₹${filter.maxInvestment?.toStringAsFixed(0) ?? "100L"}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        RangeSlider(
          values: RangeValues(
            filter.minInvestment?.toDouble() ?? 0,
            filter.maxInvestment?.toDouble() ?? 100000000,
          ),
          min: 0,
          max: 100000000,
          divisions: 100,
          onChanged: (RangeValues values) {
            ref.read(projectFilterProvider.notifier).updateInvestmentRange(
              values.start,
              values.end,
            );
          },
          activeColor: AppTheme.primaryBlue,
        ),
      ],
    );
  }
}
