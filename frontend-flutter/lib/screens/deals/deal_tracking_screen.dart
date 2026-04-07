import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../models/deal.dart';
import '../../providers/deal_provider.dart';
import '../../utils/app_logger.dart';

/// Deal Tracking Screen - Monitor deal progression for buyers/sellers
class DealTrackingScreen extends ConsumerStatefulWidget {
  final String? dealId; // Optional: if provided, show only this deal

  const DealTrackingScreen({Key? key, this.dealId}) : super(key: key);

  @override
  ConsumerState<DealTrackingScreen> createState() =>
      _DealTrackingScreenState();
}

class _DealTrackingScreenState extends ConsumerState<DealTrackingScreen> {
  late ScrollController _scrollController;
  String _filterStatus = 'all'; // all, active, completed, cancelled

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dealsAsync = ref.watch(dealsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Deal Tracking'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Status Filter
          _buildStatusFilter(),

          // Deals List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(dealsProvider);
                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: dealsAsync.when(
                data: (deals) {
                  final filtered = _filterDeals(deals);

                  if (filtered.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(12),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      return _buildDealCard(context, filtered[index]);
                    },
                  );
                },
                loading: () => _buildLoadingState(),
                error: (error, stack) => _buildErrorState(error),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilter() {
    final statuses = [
      ('all', 'All Deals'),
      ('active', 'Active'),
      ('completed', 'Completed'),
      ('cancelled', 'Cancelled'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: statuses.map((status) {
          final isSelected = _filterStatus == status.$1;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _filterStatus = status.$1),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryBlue : AppTheme.lightGrey,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.borderGrey,
                  ),
                ),
                child: Text(
                  status.$2,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDealCard(BuildContext context, Deal deal) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showDealDetail(context, deal),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          deal.propertyTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
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
                                deal.propertyLocation,
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
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getDealStatusColor(deal.dealStatus).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _getDealStatusColor(deal.dealStatus).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      deal.dealStatus.replaceAll('_', ' ').toUpperCase(),
                      style: TextStyle(
                        color: _getDealStatusColor(deal.dealStatus),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Price Info
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.lightGrey,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Property Price',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        Text(
                          currencyFormat.format(deal.propertyPrice),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 1,
                      height: 30,
                      color: AppTheme.borderGrey,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Offered Price',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        Text(
                          currencyFormat.format(deal.offeredPrice),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: AppTheme.successGreen,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 1,
                      height: 30,
                      color: AppTheme.borderGrey,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Difference',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        Text(
                          currencyFormat
                              .format(deal.propertyPrice - deal.offeredPrice),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: deal.propertyPrice > deal.offeredPrice
                                ? AppTheme.warningOrange
                                : AppTheme.successGreen,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Commission Info
              if (deal.agentCommission != null || deal.referralCommission != null)
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.primaryBlue.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (deal.agentCommission != null) ...[
                        _buildCommissionItem(
                          'Agent Commission',
                          currencyFormat.format(deal.agentCommission!),
                        ),
                        Container(
                          width: 1,
                          height: 30,
                          color: AppTheme.borderGrey,
                        ),
                      ],
                      if (deal.referralCommission != null)
                        _buildCommissionItem(
                          'Referral Commission',
                          currencyFormat.format(deal.referralCommission!),
                        ),
                    ],
                  ),
                ),

              const SizedBox(height: 12),

              // Timeline
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.lightGrey,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTimelineStatus(
                      'Created',
                      DateFormat('MMM dd').format(deal.createdAt),
                    ),
                    const Icon(Icons.arrow_forward,
                        size: 16, color: AppTheme.textSecondary),
                    _buildTimelineStatus(
                      'Status',
                      deal.dealStatus.replaceAll('_', ' '),
                    ),
                    if (deal.closedAt != null) ...[
                      const Icon(Icons.arrow_forward,
                          size: 16, color: AppTheme.textSecondary),
                      _buildTimelineStatus(
                        'Closed',
                        DateFormat('MMM dd').format(deal.closedAt!),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Commission Status
              if (deal.agentCommission != null || deal.referralCommission != null)
                Align(
                  alignment: Alignment.bottomRight,
                  child: _buildCommissionStatus(deal.commissionStatus),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommissionItem(String label, String amount) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textSecondary,
            ),
          ),
          Text(
            amount,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStatus(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppTheme.textSecondary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildCommissionStatus(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getCommissionStatusColor(status).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Commission: ${status.replaceAll('_', ' ').toUpperCase()}',
        style: TextStyle(
          color: _getCommissionStatusColor(status),
          fontSize: 10,
          fontWeight: FontWeight.bold,
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
            Icons.assignment_turned_in,
            size: 64,
            color: AppTheme.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No deals',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your deals will appear here',
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
          const Text('Loading deals...'),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    AppLogger.error('DealTracking Error: $error');

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
            'Failed to load deals',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => ref.invalidate(dealsProvider),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  List<Deal> _filterDeals(List<Deal> deals) {
    if (_filterStatus == 'all') {
      return deals;
    }

    return deals.where((deal) => deal.dealStatus == _filterStatus).toList();
  }

  void _showDealDetail(BuildContext context, Deal deal) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) => _DealDetailSheet(deal: deal),
    );
  }

  Color _getDealStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
      case 'completed':
        return AppTheme.successGreen;
      case 'proposed':
      case 'negotiating':
        return AppTheme.infoBlue;
      case 'cancelled':
        return AppTheme.errorRed;
      default:
        return AppTheme.accentGrey;
    }
  }

  Color _getCommissionStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return AppTheme.successGreen;
      case 'approved':
        return AppTheme.infoBlue;
      case 'pending':
        return AppTheme.warningOrange;
      default:
        return AppTheme.accentGrey;
    }
  }
}

class _DealDetailSheet extends StatefulWidget {
  final Deal deal;

  const _DealDetailSheet({required this.deal});

  @override
  State<_DealDetailSheet> createState() => _DealDetailSheetState();
}

class _DealDetailSheetState extends State<_DealDetailSheet> {
  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    final dateFormat = DateFormat('MMM dd, yyyy');

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
                  'Deal Details',
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

            const SizedBox(height: 16),

            // Property Info
            _buildDetailSection(
              'Property Information',
              [
                _buildDetailRow('Title', widget.deal.propertyTitle),
                _buildDetailRow('Location', widget.deal.propertyLocation),
                _buildDetailRow(
                  'Property Price',
                  currencyFormat.format(widget.deal.propertyPrice),
                ),
                _buildDetailRow(
                  'Offered Price',
                  currencyFormat.format(widget.deal.offeredPrice),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Deal Status
            _buildDetailSection(
              'Deal Status',
              [
                _buildDetailRow(
                  'Status',
                  widget.deal.dealStatus.replaceAll('_', ' ').toUpperCase(),
                ),
                _buildDetailRow(
                  'Commission Status',
                  widget.deal.commissionStatus.replaceAll('_', ' ').toUpperCase(),
                ),
                _buildDetailRow(
                  'Created',
                  dateFormat.format(widget.deal.createdAt),
                ),
                if (widget.deal.closedAt != null)
                  _buildDetailRow(
                    'Closed',
                    dateFormat.format(widget.deal.closedAt!),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Commission Details
            if (widget.deal.agentCommission != null ||
                widget.deal.referralCommission != null)
              _buildDetailSection(
                'Commission Breakdown',
                [
                  if (widget.deal.agentCommission != null)
                    _buildDetailRow(
                      'Agent Commission',
                      currencyFormat.format(widget.deal.agentCommission!),
                    ),
                  if (widget.deal.referralCommission != null)
                    _buildDetailRow(
                      'Referral Commission',
                      currencyFormat.format(widget.deal.referralCommission!),
                    ),
                  _buildDetailRow(
                    'Total Commission',
                    currencyFormat.format(widget.deal.totalCommission),
                  ),
                ],
              ),

            const SizedBox(height: 24),

            // Action Buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Document upload opened'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: AppTheme.primaryBlue,
                ),
                child: const Text(
                  'Upload Transaction Proof',
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

  Widget _buildDetailSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.lightGrey,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: List.generate(
              items.length,
              (index) => Column(
                children: [
                  items[index],
                  if (index < items.length - 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Divider(
                        color: AppTheme.white,
                        height: 1,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
