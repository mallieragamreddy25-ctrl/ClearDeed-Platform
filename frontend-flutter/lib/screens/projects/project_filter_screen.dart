import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../providers/project_provider.dart';

/// Bottom sheet filter modal for investment projects
/// Allows filtering by investment range, ROI range, timeline, and status
class ProjectFilterScreen extends ConsumerStatefulWidget {
  const ProjectFilterScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProjectFilterScreen> createState() => _ProjectFilterScreenState();
}

class _ProjectFilterScreenState extends ConsumerState<ProjectFilterScreen> {
  late double _minInvestment;
  late double _maxInvestment;
  late double _minROI;
  late double _maxROI;
  late int _minTimeline;
  late int _maxTimeline;
  late String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    final filter = ref.read(projectFilterProvider);
    _minInvestment = filter.minInvestment ?? 0;
    _maxInvestment = filter.maxInvestment ?? 10000000;
    _minROI = 0;
    _maxROI = 50;
    _minTimeline = 0;
    _maxTimeline = 60;
    _selectedStatus = null;
  }

  void _applyFilters() {
    ref.read(projectFilterProvider.notifier).updateInvestmentRange(
      _minInvestment,
      _maxInvestment,
    );
    Navigator.pop(context);
  }

  void _clearFilters() {
    setState(() {
      _minInvestment = 0;
      _maxInvestment = 10000000;
      _minROI = 0;
      _maxROI = 50;
      _minTimeline = 0;
      _maxTimeline = 60;
      _selectedStatus = null;
    });
    ref.read(projectFilterProvider.notifier).clearFilters();
  }

  String _formatCurrency(double amount) {
    if (amount >= 10000000) {
      return '₹${(amount / 10000000).toStringAsFixed(1)}Cr';
    } else if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return '₹${amount.toStringAsFixed(0)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: ListView(
              controller: scrollController,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filter Projects',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Investment Range Section
                _FilterSection(
                  title: 'Minimum Investment',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Slider(
                        value: _minInvestment,
                        min: 0,
                        max: 10000000,
                        divisions: 100,
                        activeColor: AppTheme.primaryBlue,
                        inactiveColor: AppTheme.lightGrey,
                        onChanged: (value) {
                          setState(() {
                            if (value <= _maxInvestment) {
                              _minInvestment = value;
                            }
                          });
                        },
                      ),
                      Text(
                        _formatCurrency(_minInvestment),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                _FilterSection(
                  title: 'Maximum Investment',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Slider(
                        value: _maxInvestment,
                        min: 0,
                        max: 10000000,
                        divisions: 100,
                        activeColor: AppTheme.primaryBlue,
                        inactiveColor: AppTheme.lightGrey,
                        onChanged: (value) {
                          setState(() {
                            if (value >= _minInvestment) {
                              _maxInvestment = value;
                            }
                          });
                        },
                      ),
                      Text(
                        _formatCurrency(_maxInvestment),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ROI Range Section
                _FilterSection(
                  title: 'Expected ROI Range',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Slider(
                              value: _minROI,
                              min: 0,
                              max: 50,
                              divisions: 50,
                              activeColor: AppTheme.primaryBlue,
                              onChanged: (value) {
                                setState(() {
                                  if (value <= _maxROI) {
                                    _minROI = value;
                                  }
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_minROI.toStringAsFixed(1)}%',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                          Text(
                            'to ${_maxROI.toStringAsFixed(1)}%',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Timeline Filter
                _FilterSection(
                  title: 'Return Timeline (months)',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Slider(
                              value: _minTimeline.toDouble(),
                              min: 0,
                              max: 60,
                              divisions: 12,
                              activeColor: AppTheme.primaryBlue,
                              onChanged: (value) {
                                setState(() {
                                  if (value <= _maxTimeline) {
                                    _minTimeline = value.toInt();
                                  }
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$_minTimeline months',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                          Text(
                            'to $_maxTimeline months',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Project Status Filter
                _FilterSection(
                  title: 'Project Status',
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['Active', 'Planning', 'Completed', 'On Hold'].map((status) {
                      final isSelected = _selectedStatus == status.toLowerCase();
                      return FilterChip(
                        label: Text(status),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedStatus = selected ? status.toLowerCase() : null;
                          });
                        },
                        backgroundColor: AppTheme.white,
                        selectedColor: AppTheme.primaryBlue.withOpacity(0.2),
                        side: BorderSide(
                          color: isSelected ? AppTheme.primaryBlue : AppTheme.textHint,
                        ),
                        labelStyle: TextStyle(
                          color: isSelected ? AppTheme.primaryBlue : AppTheme.textSecondary,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 32),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _clearFilters,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppTheme.primaryBlue),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Clear Filters'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _applyFilters,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryBlue,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Apply Filters'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ==================== Filter Section Widget ====================

class _FilterSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _FilterSection({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}
