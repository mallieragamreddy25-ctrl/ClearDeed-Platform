import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/investment_project.dart';
import '../../providers/project_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/app_logger.dart';

/// Project Detail Screen - Full project information with investment options
class ProjectDetailScreen extends ConsumerStatefulWidget {
  final String projectId;

  const ProjectDetailScreen({Key? key, required this.projectId})
      : super(key: key);

  @override
  ConsumerState<ProjectDetailScreen> createState() =>
      _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends ConsumerState<ProjectDetailScreen> {
  late TextEditingController _investmentController;
  bool _isExpressingInterest = false;

  @override
  void initState() {
    super.initState();
    _investmentController = TextEditingController();
  }

  @override
  void dispose() {
    _investmentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projectAsync = ref.watch(projectDetailProvider(widget.projectId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Details'),
        elevation: 0,
      ),
      body: projectAsync.when(
        data: (project) => _buildProjectContent(context, project),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => _buildErrorWidget(context, error),
      ),
    );
  }

  Widget _buildProjectContent(
    BuildContext context,
    InvestmentProject project,
  ) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    final dateFormat = DateFormat('MMM dd, yyyy');

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Image
          if (project.projectImages.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              child: Image.network(
                project.projectImages.first,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
              ),
            )
          else
            _buildImagePlaceholder(),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Status
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            project.name,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 16,
                                color: AppTheme.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${project.location}, ${project.city}',
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
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
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Investment Summary
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primaryBlue.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSummaryItem(
                            'Total Budget',
                            currencyFormat.format(project.totalBudget),
                          ),
                          _buildSummaryItem(
                            'Raised',
                            currencyFormat.format(project.raisedAmount),
                            valueColor: AppTheme.successGreen,
                          ),
                          _buildSummaryItem(
                            'Remaining',
                            currencyFormat.format(project.remainingAmount),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: project.progressPercentage / 100,
                                minHeight: 8,
                                backgroundColor: Colors.grey[300],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppTheme.successGreen,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${project.progressPercentage.toStringAsFixed(0)}%',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Key Metrics
                Text(
                  'Investment Details',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.lightGrey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow(
                        'Minimum Investment',
                        currencyFormat.format(project.minInvestment),
                      ),
                      Divider(color: AppTheme.white),
                      _buildDetailRow(
                        'Maximum Investment',
                        currencyFormat.format(project.maxInvestment),
                      ),
                      Divider(color: AppTheme.white),
                      _buildDetailRow(
                        'Expected ROI',
                        '${project.expectedReturn.toStringAsFixed(1)}%',
                        valueColor: AppTheme.successGreen,
                      ),
                      Divider(color: AppTheme.white),
                      _buildDetailRow(
                        'Return Timeline',
                        '${project.expectedReturnMonths} Months',
                      ),
                      Divider(color: AppTheme.white),
                      _buildDetailRow(
                        'Return Type',
                        project.returnType.replaceAll('_', ' ').toUpperCase(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Description
                Text(
                  'Overview',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                Text(
                  project.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    height: 1.6,
                  ),
                ),

                const SizedBox(height: 24),

                // Milestones
                if (project.milestones.isNotEmpty) ...[
                  Text(
                    'Project Milestones',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: project.milestones.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final milestone = project.milestones[index];
                      return _buildMilestoneItem(context, milestone);
                    },
                  ),
                  const SizedBox(height: 24),
                ],

                // Investor Info
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.infoBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.infoBlue.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.people,
                        color: AppTheme.infoBlue,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${project.investorCount} investors have backed this project',
                        style: const TextStyle(
                          color: AppTheme.infoBlue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Action Buttons
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton(
                      onPressed: () => _showInvestmentSheet(context, project),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: AppTheme.primaryBlue,
                      ),
                      child: const Text(
                        'Express Interest to Invest',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => _contactDeveloper(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                      child: const Text(
                        'Contact Developer',
                        style: TextStyle(
                          color: AppTheme.primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 250,
      width: double.infinity,
      color: AppTheme.lightGrey,
      child: const Center(
        child: Icon(
          Icons.building,
          size: 64,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: valueColor ?? AppTheme.primaryBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: valueColor ?? AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildMilestoneItem(
    BuildContext context,
    ProjectMilestone milestone,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: milestone.isCompleted
            ? AppTheme.successGreen.withOpacity(0.1)
            : AppTheme.lightGrey,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: milestone.isCompleted
              ? AppTheme.successGreen.withOpacity(0.3)
              : AppTheme.borderGrey,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  milestone.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (milestone.isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.successGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Completed',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(milestone.description),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Due: ${DateFormat('MMM dd, yyyy').format(milestone.dueDate)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
              Text(
                '${milestone.percentageOfBudget.toStringAsFixed(0)}% of budget',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showInvestmentSheet(BuildContext context, InvestmentProject project) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _InvestmentSheet(project: project),
      ),
    );
  }

  void _contactDeveloper(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening developer contact information...'),
        duration: Duration(seconds: 2),
      ),
    );
    AppLogger.info('Contact developer tapped');
  }

  Widget _buildErrorWidget(BuildContext context, Object error) {
    AppLogger.error('ProjectDetail Error: $error');

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
            'Failed to load project details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Go Back'),
          ),
        ],
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

class _InvestmentSheet extends StatefulWidget {
  final InvestmentProject project;

  const _InvestmentSheet({required this.project});

  @override
  State<_InvestmentSheet> createState() => _InvestmentSheetState();
}

class _InvestmentSheetState extends State<_InvestmentSheet> {
  late TextEditingController _amountController;
  late FocusNode _amountFocus;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _amountFocus = FocusNode();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _amountFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Express Interest',
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

            // Investment Amount
            const Text(
              'Investment Amount',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              focusNode: _amountFocus,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter amount in ₹',
                prefixText: '₹ ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Range info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.infoBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.infoBlue.withOpacity(0.3),
                ),
              ),
              child: Text(
                'Investment range: ₹${NumberFormat.currency(symbol: '₹', decimalDigits: 0).format(widget.project.minInvestment)} - ₹${NumberFormat.currency(symbol: '₹', decimalDigits: 0).format(widget.project.maxInvestment)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_amountController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter an amount'),
                      ),
                    );
                    return;
                  }

                  final amount = double.tryParse(_amountController.text) ?? 0;
                  if (amount < widget.project.minInvestment ||
                      amount > widget.project.maxInvestment) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Please enter amount within the allowed range',
                        ),
                      ),
                    );
                    return;
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Interest expressed for ₹${NumberFormat.currency(symbol: '', decimalDigits: 0).format(amount)}',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: AppTheme.primaryBlue,
                ),
                child: const Text(
                  'Submit Expression of Interest',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _ProjectDetailScreenState extends ConsumerState<ProjectDetailScreen> {
  late TextEditingController _investmentController;
  bool _isExpressingInterest = false;

  @override
  void initState() {
    super.initState();
    _investmentController = TextEditingController();
  }

  @override
  void dispose() {
    _investmentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projectAsync = ref.watch(projectDetailProvider(widget.projectId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Details'),
        elevation: 0,
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: AppTheme.white,
      ),
      body: projectAsync.when(
        data: (project) => _buildProjectContent(context, project),
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryBlue),
        ),
        error: (error, stack) => _buildErrorWidget(context, error),
      ),
    );
  }

  Widget _buildProjectContent(
    BuildContext context,
    InvestmentProject project,
  ) {
    final currencyFormat = NumberFormat.currency(symbol: '₹');
    final dateFormat = DateFormat('MMM dd, yyyy');

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Image
          if (project.projectImages.isNotEmpty)
            Image.network(
              project.projectImages.first,
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 250,
                  color: AppTheme.lightGrey,
                  child: const Icon(Icons.image_not_supported,
                      size: 64, color: AppTheme.textHint),
                );
              },
            )
          else
            Container(
              height: 250,
              color: AppTheme.lightGrey,
              child: const Icon(Icons.image_not_supported,
                  size: 64, color: AppTheme.textHint),
            ),
          // Project Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Status
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            project.name,
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.location_on,
                                  size: 18, color: AppTheme.textSecondary),
                              const SizedBox(width: 6),
                              Text(
                                '${project.location}, ${project.city}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: AppTheme.textSecondary),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
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
                const SizedBox(height: 24),
                // Financial Summary Card
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.lightGrey,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.accentGrey.withOpacity(0.2)),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildFinancialRow(
                        context,
                        'Total Budget',
                        currencyFormat.format(project.totalBudget),
                      ),
                      const SizedBox(height: 12),
                      _buildFinancialRow(
                        context,
                        'Raised Amount',
                        currencyFormat.format(project.raisedAmount),
                        color: AppTheme.successGreen,
                      ),
                      const SizedBox(height: 12),
                      _buildFinancialRow(
                        context,
                        'Remaining',
                        currencyFormat.format(project.remainingAmount),
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: project.progressPercentage / 100,
                          minHeight: 8,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation(
                            _getProgressColor(project.progressPercentage),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${project.progressPercentage.toStringAsFixed(1)}% Funded',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Investment Details
                _buildSectionTitle(context, 'Investment Details'),
                const SizedBox(height: 12),
                _buildDetailGrid(context, [
                  ('Min Investment', currencyFormat.format(project.minInvestment)),
                  ('Max Investment', currencyFormat.format(project.maxInvestment)),
                  ('Expected ROI', '${project.expectedReturn.toStringAsFixed(1)}%'),
                  ('Return Type', _formatReturnType(project.returnType)),
                  ('Timeline', '${project.expectedReturnMonths} Months'),
                  ('Commission', '${project.commissionPercentage}%'),
                ]),
                const SizedBox(height: 24),
                // Description
                _buildSectionTitle(context, 'About Project'),
                const SizedBox(height: 12),
                Text(
                  project.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                // Milestones
                _buildSectionTitle(context, 'Project Milestones'),
                const SizedBox(height: 12),
                _buildMilestonesList(context, project.milestones),
                const SizedBox(height: 24),
                // Stats
                _buildSectionTitle(context, 'Project Statistics'),
                const SizedBox(height: 12),
                _buildDetailGrid(context, [
                  ('Total Investors', '${project.investorCount}'),
                  ('Category', project.category),
                  ('Start Date', dateFormat.format(project.startDate)),
                  ('Active', project.isActive ? 'Yes' : 'No'),
                ]),
                const SizedBox(height: 32),
                // Express Interest Section
                if (project.isActive) _buildExpressInterestSection(context, project),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpressInterestSection(
    BuildContext context,
    InvestmentProject project,
  ) {
    final currencyFormat = NumberFormat.currency(symbol: '₹');

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryBlue),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Express Your Interest',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          // Investment Amount Input
          TextField(
            controller: _investmentController,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: 'Enter investment amount',
              prefixText: '₹ ',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              suffixText: _investmentController.text.isEmpty
                  ? null
                  : '(Min: ${currencyFormat.format(project.minInvestment)})',
            ),
            onChanged: (value) {
              setState(() {});
            },
          ),
          const SizedBox(height: 12),
          // Validation message
          if (_investmentController.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildValidationMessage(
                context,
                project,
                _investmentController.text,
              ),
            ),
          // Express Interest Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isExpressingInterest
                  ? null
                  : () => _handleExpressInterest(context, project),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 14),
                disabledBackgroundColor: AppTheme.textHint,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isExpressingInterest
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppTheme.white),
                      ),
                    )
                  : const Text(
                      'Express Interest',
                      style: TextStyle(
                        color: AppTheme.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValidationMessage(
    BuildContext context,
    InvestmentProject project,
    String amount,
  ) {
    try {
      final investmentAmount = double.parse(amount);
      final isValid = investmentAmount >= project.minInvestment &&
          investmentAmount <= project.maxInvestment;

      return Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.info,
            size: 18,
            color: isValid ? AppTheme.successGreen : AppTheme.warningOrange,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isValid
                  ? 'Investment amount is valid'
                  : 'Investment must be between ₹${project.minInvestment} and ₹${project.maxInvestment}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isValid
                        ? AppTheme.successGreen
                        : AppTheme.warningOrange,
                  ),
            ),
          ),
        ],
      );
    } catch (e) {
      return const SizedBox();
    }
  }

  Future<void> _handleExpressInterest(
    BuildContext context,
    InvestmentProject project,
  ) async {
    if (_investmentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an investment amount')),
      );
      return;
    }

    try {
      final amount = double.parse(_investmentController.text);

      if (amount < project.minInvestment || amount > project.maxInvestment) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Investment must be between ₹${project.minInvestment} and ₹${project.maxInvestment}',
            ),
          ),
        );
        return;
      }

      setState(() {
        _isExpressingInterest = true;
      });

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      setState(() {
        _isExpressingInterest = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Interest expressed successfully!'),
          backgroundColor: AppTheme.successGreen,
        ),
      );

      _investmentController.clear();
    } catch (e) {
      setState(() {
        _isExpressingInterest = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildFinancialRow(
    BuildContext context,
    String label,
    String value, {
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailGrid(
    BuildContext context,
    List<(String, String)> details,
  ) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: details.map((detail) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.white,
            border: Border.all(color: AppTheme.lightGrey),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                detail.$1,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                detail.$2,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMilestonesList(
    BuildContext context,
    List<ProjectMilestone> milestones,
  ) {
    if (milestones.isEmpty) {
      return Text(
        'No milestones defined',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: milestones.length,
      itemBuilder: (context, index) {
        final milestone = milestones[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: milestone.isCompleted
                ? AppTheme.successGreen.withOpacity(0.1)
                : AppTheme.lightGrey,
            border: Border.all(
              color: milestone.isCompleted
                  ? AppTheme.successGreen
                  : AppTheme.textHint,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    milestone.isCompleted
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    size: 20,
                    color: milestone.isCompleted
                        ? AppTheme.successGreen
                        : AppTheme.textHint,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      milestone.title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                milestone.description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Due: ${DateFormat('MMM dd, yyyy').format(milestone.dueDate)} • ${milestone.percentageOfBudget.toStringAsFixed(0)}% of Budget',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorWidget(BuildContext context, dynamic error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppTheme.errorRed),
          const SizedBox(height: 16),
          Text(
            'Error loading project',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
            ),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  String _formatReturnType(String type) {
    switch (type.toLowerCase()) {
      case 'monthly':
        return 'Monthly';
      case 'quarterly':
        return 'Quarterly';
      case 'annual':
        return 'Annual';
      case 'lumpsum':
        return 'Lump Sum';
      default:
        return type;
    }
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
}
