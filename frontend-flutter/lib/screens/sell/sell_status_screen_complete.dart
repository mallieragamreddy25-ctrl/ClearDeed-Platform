import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'sell_screen_provider.dart';

/// Property Status Tracking Screen
/// Displays property verification status, timeline, and admin feedback
class SellStatusScreen extends ConsumerStatefulWidget {
  final String? propertyId;
  final Function()? onEditProperty;

  const SellStatusScreen({
    Key? key,
    this.propertyId,
    this.onEditProperty,
  }) : super(key: key);

  @override
  ConsumerState<SellStatusScreen> createState() => _SellStatusScreenState();
}

class _SellStatusScreenState extends ConsumerState<SellStatusScreen> {
  late String _propertyId;

  @override
  void initState() {
    super.initState();
    _propertyId = widget.propertyId ?? ref.read(propertyIdProvider) ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final statusAsync = ref.watch(propertyStatusProvider(_propertyId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Property Status'),
        elevation: 0,
        centerTitle: true,
      ),
      body: statusAsync.when(
        data: (status) {
          if (status == null) {
            return _buildErrorState(theme);
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Property ID Card
                _buildPropertyIdCard(status, theme),
                const SizedBox(height: 24),

                // Status Badge
                _buildStatusBadge(status, theme),
                const SizedBox(height: 24),

                // Progress Bar
                _buildProgressBar(status, theme),
                const SizedBox(height: 24),

                // Timeline
                _buildTimeline(status, theme),
                const SizedBox(height: 24),

                // Admin Notes
                if (status.adminNotes != null)
                  Column(
                    children: [
                      _buildAdminNotesCard(status, theme),
                      const SizedBox(height: 24),
                    ],
                  ),

                // Rejection Reason
                if (status.status == 'rejected' &&
                    status.rejectionReason != null)
                  Column(
                    children: [
                      _buildRejectionReasonCard(status, theme),
                      const SizedBox(height: 24),
                    ],
                  ),

                // Action Buttons
                _buildActionButtons(status, theme),
              ],
            ),
          );
        },
        loading: () => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Loading property status...',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        error: (error, stack) => _buildErrorState(theme),
      ),
    );
  }

  Widget _buildPropertyIdCard(PropertySubmissionStatus status, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Property ID',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                status.propertyId,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: status.propertyId));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Property ID copied to clipboard'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(PropertySubmissionStatus status, ThemeData theme) {
    final statusConfig = _getStatusConfig(status.status);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: statusConfig['color'].withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusConfig['color'].withOpacity(0.5),
        ),
      ),
      child: Column(
        children: [
          Icon(
            statusConfig['icon'],
            size: 48,
            color: statusConfig['color'],
          ),
          const SizedBox(height: 12),
          Text(
            statusConfig['label'],
            style: theme.textTheme.headlineSmall?.copyWith(
              color: statusConfig['color'],
              fontWeight: FontWeight.w700,
            ),
          ),
          if (status.lastUpdatedAt != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Updated: ${_formatDate(status.lastUpdatedAt!)}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(PropertySubmissionStatus status, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${status.progressPercentage}%',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: status.progressPercentage / 100,
            minHeight: 12,
            backgroundColor: theme.colorScheme.outline.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeline(PropertySubmissionStatus status, ThemeData theme) {
    final steps = [
      {'step': 1, 'title': 'Submitted', 'description': 'Property listing submitted'},
      {
        'step': 2,
        'title': 'Documents Verified',
        'description': 'Admin verifies documents'
      },
      {
        'step': 3,
        'title': 'Images Approved',
        'description': 'Property images reviewed'
      },
      {
        'step': 4,
        'title': 'Final Review',
        'description': 'Final verification check'
      },
      {
        'step': 5,
        'title': 'Published',
        'description': 'Property goes live'
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Verification Timeline',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Column(
          children: steps.map((step) {
            final progress = step['step'] as int;
            final isCompleted = progress <= (status.progressPercentage ~/ 20);
            final isActive = progress == ((status.progressPercentage ~/ 20) + 1);

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  // Indicator
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted
                          ? Colors.green
                          : isActive
                              ? theme.colorScheme.primary
                              : Colors.grey[300],
                    ),
                    child: Center(
                      child: isCompleted
                          ? Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 20,
                            )
                          : Text(
                              '${step['step']}',
                              style: TextStyle(
                                color: isActive ? Colors.white : Colors.grey[600],
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step['title'],
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isCompleted || isActive
                                ? theme.colorScheme.onSurface
                                : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          step['description'],
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAdminNotesCard(PropertySubmissionStatus status, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info, color: Colors.blue[600], size: 20),
              const SizedBox(width: 8),
              Text(
                'Admin Notes',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            status.adminNotes ?? '',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.blue[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRejectionReasonCard(PropertySubmissionStatus status, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning, color: Colors.red[600], size: 20),
              const SizedBox(width: 8),
              Text(
                'Rejection Reason',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.red[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            status.rejectionReason ?? '',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.red[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(PropertySubmissionStatus status, ThemeData theme) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sharing listing...')),
              );
            },
            icon: const Icon(Icons.share),
            label: const Text('Share Listing'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening listing...')),
              );
            },
            icon: const Icon(Icons.open_in_new),
            label: const Text('View Listing'),
          ),
        ),
        const SizedBox(height: 12),
        if (status.status == 'submitted')
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: widget.onEditProperty,
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Property'),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening support chat...')),
              );
            },
            icon: const Icon(Icons.contact_support),
            label: const Text('Contact Support'),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[600],
          ),
          const SizedBox(height: 16),
          Text(
            'Unable to Load Property Status',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please check the property ID and try again',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton.tonal(
            onPressed: () => setState(() {}),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getStatusConfig(String status) {
    const configurations = {
      'submitted': {
        'label': 'Submitted',
        'color': Colors.blue,
        'icon': Icons.send,
      },
      'under_verification': {
        'label': 'Under Verification',
        'color': Colors.orange,
        'icon': Icons.schedule,
      },
      'verified': {
        'label': 'Verified',
        'color': Colors.green,
        'icon': Icons.check_circle,
      },
      'live': {
        'label': 'Live',
        'color': Colors.green,
        'icon': Icons.visibility,
      },
      'sold': {
        'label': 'Sold',
        'color': Colors.purple,
        'icon': Icons.done_all,
      },
      'rejected': {
        'label': 'Rejected',
        'color': Colors.red,
        'icon': Icons.close_circle,
      },
    };

    return configurations[status] ??
        {
          'label': 'Unknown',
          'color': Colors.grey,
          'icon': Icons.help_outline,
        };
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
