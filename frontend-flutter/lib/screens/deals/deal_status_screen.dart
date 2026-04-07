import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../models/deal.dart';
import '../../providers/deal_provider.dart';
import '../../utils/app_logger.dart';

/// Deal status screen - tracks deal progress with timeline and documents
class DealStatusScreen extends ConsumerWidget {
  final String dealId;

  const DealStatusScreen({
    Key? key,
    required this.dealId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mock deal data - replace with actual provider
    final deal = _getMockDeal();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Deal Progress'),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showMoreOptions(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Deal Header
            _DealHeaderCard(deal: deal),

            // Deal Status Section
            _DealStatusSection(deal: deal),

            // Timeline Section
            _DealTimelineSection(deal: deal),

            // Documents Section
            _DealDocumentsSection(deal: deal),

            // Commission Breakdown Section
            _CommissionBreakdownSection(deal: deal),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _contactParty(context, 'seller'),
                      icon: const Icon(Icons.phone),
                      label: const Text('Contact Seller'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _submitSupportTicket(context),
                      icon: const Icon(Icons.support_agent),
                      label: const Text('Create Support Ticket'),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.primaryBlue),
                        padding: const EdgeInsets.symmetric(vertical: 12),
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

  Deal _getMockDeal() => Deal(
    id: dealId,
    buyerId: 'buyer_001',
    sellerId: 'seller_001',
    agentId: 'agent_456',
    propertyId: 'prop_001',
    propertyTitle: 'Luxury 3BHK Apartment',
    propertyLocation: 'Bandra, Mumbai',
    propertyPrice: 5000000,
    dealStatus: 'negotiating',
    offeredPrice: 4800000,
    agentCommission: 120000,
    referralCommission: 60000,
    referralPartnerId: 'ref_001',
    commissionStatus: 'pending',
    createdAt: DateTime.now().subtract(const Duration(days: 15)),
    closedAt: null,
    notes: 'Property under negotiation. Inspection completed.',
    timeline: [
      DealTimeline(
        id: 'event_1',
        title: 'Deal Created',
        description: 'Initial offer made by buyer',
        timestamp: DateTime.now().subtract(const Duration(days: 15)),
        status: 'completed',
        actor: 'buyer_001',
      ),
      DealTimeline(
        id: 'event_2',
        title: 'Property Inspection',
        description: 'Buyer inspected the property',
        timestamp: DateTime.now().subtract(const Duration(days: 10)),
        status: 'completed',
        actor: 'buyer_001',
      ),
      DealTimeline(
        id: 'event_3',
        title: 'Negotiation',
        description: 'Price negotiation in progress',
        timestamp: DateTime.now().subtract(const Duration(days: 5)),
        status: 'in_progress',
        actor: 'agent_456',
      ),
      DealTimeline(
        id: 'event_4',
        title: 'Offer Accepted',
        description: 'Seller accepts buyer offer',
        timestamp: DateTime.now(),
        status: 'pending',
        actor: null,
      ),
      DealTimeline(
        id: 'event_5',
        title: 'Documentation & Payment',
        description: 'Final documentation and payment processing',
        timestamp: null,
        status: 'pending',
        actor: null,
      ),
    ],
  );

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: AppTheme.primaryBlue),
              title: const Text('Update Deal Status'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Update functionality coming soon')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.share, color: AppTheme.primaryBlue),
              title: const Text('Share Deal Details'),
              onTap: () {
                Navigator.pop(context);
                AppLogger.logNavigation('DealStatus', 'ShareDeal');
              },
            ),
            ListTile(
              leading: const Icon(Icons.print, color: AppTheme.primaryBlue),
              title: const Text('Print Deal Document'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _contactParty(BuildContext context, String party) {
    AppLogger.logNavigation('DealStatus', 'Contact_$party');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening contact for $party...'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _submitSupportTicket(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Support Ticket'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Describe your issue...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Support ticket created successfully!'),
                  backgroundColor: AppTheme.successGreen,
                ),
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}

// ==================== Deal Header Card ====================

class _DealHeaderCard extends StatelessWidget {
  final Deal deal;

  const _DealHeaderCard({required this.deal});

  Color _getDealStatusColor() {
    switch (deal.dealStatus) {
      case 'accepted':
        return AppTheme.successGreen;
      case 'completed':
        return AppTheme.successGreen;
      case 'cancelled':
        return AppTheme.errorRed;
      case 'negotiating':
        return AppTheme.warningOrange;
      default:
        return AppTheme.infoBlue;
    }
  }

  String _getDealStatusLabel() {
    return deal.statusLabel;
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      child: Padding(
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
                        deal.propertyTitle,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              deal.propertyLocation,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getDealStatusColor().withOpacity(0.2),
                    border: Border.all(color: _getDealStatusColor()),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _getDealStatusLabel(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: _getDealStatusColor(),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: AppTheme.lightGrey, height: 1),
            const SizedBox(height: 16),
            // Price details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Listed Price',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currencyFormat.format(deal.propertyPrice),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Offered Price',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currencyFormat.format(deal.offeredPrice),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== Deal Status Section ====================

class _DealStatusSection extends StatelessWidget {
  final Deal deal;

  const _DealStatusSection({required this.deal});

  Color _getPaymentStatusColor() {
    switch (deal.commissionStatus) {
      case 'paid':
        return AppTheme.successGreen;
      case 'approved':
        return AppTheme.infoBlue;
      case 'pending':
        return AppTheme.warningOrange;
      default:
        return AppTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Deal Status',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _StatusItem(
                    icon: Icons.check_circle,
                    label: 'Deal Status',
                    value: deal.statusLabel,
                  ),
                  _StatusItem(
                    icon: Icons.payment,
                    label: 'Payment Status',
                    value: deal.commissionStatus.toUpperCase(),
                    valueColor: _getPaymentStatusColor(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (deal.notes != null) ...[
                Divider(color: AppTheme.lightGrey, height: 1),
                const SizedBox(height: 12),
                Text(
                  'Notes',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  deal.notes!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== Status Item Widget ====================

class _StatusItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _StatusItem({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 24, color: AppTheme.primaryBlue),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppTheme.primaryBlue,
          ),
        ),
      ],
    );
  }
}

// ==================== Deal Timeline Section ====================

class _DealTimelineSection extends StatelessWidget {
  final Deal deal;

  const _DealTimelineSection({required this.deal});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Deal Timeline',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: deal.timeline.length,
                itemBuilder: (context, index) {
                  final event = deal.timeline[index];
                  final isLast = index == deal.timeline.length - 1;
                  final isCompleted = event.status == 'completed';

                  return _TimelineItem(
                    title: event.title,
                    description: event.description,
                    timestamp: event.timestamp,
                    isCompleted: isCompleted,
                    isInProgress: event.status == 'in_progress',
                    isPending: event.status == 'pending',
                    isLast: isLast,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== Timeline Item Widget ====================

class _TimelineItem extends StatelessWidget {
  final String title;
  final String description;
  final DateTime? timestamp;
  final bool isCompleted;
  final bool isInProgress;
  final bool isPending;
  final bool isLast;

  const _TimelineItem({
    required this.title,
    required this.description,
    required this.timestamp,
    required this.isCompleted,
    required this.isInProgress,
    required this.isPending,
    required this.isLast,
  });

  Color _getStatusColor() {
    if (isCompleted) return AppTheme.successGreen;
    if (isInProgress) return AppTheme.warningOrange;
    if (isPending) return AppTheme.textHint;
    return AppTheme.accentGrey;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline circle
              Column(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _getStatusColor().withOpacity(0.2),
                      border: Border.all(color: _getStatusColor(), width: 2),
                    ),
                    child: Icon(
                      isCompleted
                          ? Icons.check
                          : isInProgress
                              ? Icons.hourglass_top
                              : Icons.radio_button_unchecked,
                      size: 16,
                      color: _getStatusColor(),
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 40,
                      color: _getStatusColor().withOpacity(0.3),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isCompleted
                            ? AppTheme.textPrimary
                            : AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    if (timestamp != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('dd MMM yyyy, HH:mm').format(timestamp!),
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==================== Documents Section ====================

class _DealDocumentsSection extends StatelessWidget {
  final Deal deal;

  const _DealDocumentsSection({required this.deal});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Documents & Signatures',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _DocumentItem(
                    title: 'Agreement Letter',
                    status: 'signed',
                  ),
                  Divider(color: AppTheme.lightGrey, height: 1),
                  _DocumentItem(
                    title: 'Identity Verification',
                    status: 'completed',
                  ),
                  Divider(color: AppTheme.lightGrey, height: 1),
                  _DocumentItem(
                    title: 'Payment Proof',
                    status: 'pending',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== Document Item Widget ====================

class _DocumentItem extends StatelessWidget {
  final String title;
  final String status;

  const _DocumentItem({
    required this.title,
    required this.status,
  });

  Color _getStatusColor() {
    switch (status) {
      case 'signed':
      case 'completed':
        return AppTheme.successGreen;
      case 'pending':
        return AppTheme.warningOrange;
      default:
        return AppTheme.textSecondary;
    }
  }

  IconData _getStatusIcon() {
    switch (status) {
      case 'signed':
        return Icons.check_circle;
      case 'completed':
        return Icons.check_circle;
      case 'pending':
        return Icons.schedule;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Icon(_getStatusIcon(), size: 20, color: _getStatusColor()),
        ],
      ),
    );
  }
}

// ==================== Commission Breakdown Section ====================

class _CommissionBreakdownSection extends StatelessWidget {
  final Deal deal;

  const _CommissionBreakdownSection({required this.deal});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Commission Breakdown',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (deal.agentCommission != null) ...[
                    _CommissionRow(
                      label: 'Agent Commission',
                      amount: deal.agentCommission!,
                    ),
                    Divider(color: AppTheme.lightGrey, height: 1),
                  ],
                  if (deal.referralCommission != null) ...[
                    _CommissionRow(
                      label: 'Referral Commission',
                      amount: deal.referralCommission!,
                    ),
                    Divider(color: AppTheme.lightGrey, height: 1),
                  ],
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '₹${deal.totalCommission.toStringAsFixed(0)}',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== Commission Row Widget ====================

class _CommissionRow extends StatelessWidget {
  final String label;
  final double amount;

  const _CommissionRow({
    required this.label,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            '₹${amount.toStringAsFixed(0)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }
}
