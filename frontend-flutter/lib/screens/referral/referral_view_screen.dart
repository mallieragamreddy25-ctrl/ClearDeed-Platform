import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../models/commission_and_earning.dart';
import '../../utils/app_logger.dart';

/// Referral & Commission Tracking Screen
/// Displays referral link, earnings summary, and commission history
class ReferralViewScreen extends ConsumerWidget {
  const ReferralViewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mock data - replace with actual provider
    const referralLink = 'https://cleardeed.com/ref/agent_12345';
    final agentEarnings = AgentEarnings(
      agentId: 'agent_123',
      totalEarnings: 250000,
      pendingEarnings: 45000,
      approvedEarnings: 85000,
      paidEarnings: 120000,
      totalDeals: 8,
      dealsThisMonth: 2,
      commissions: _getMockCommissions(),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Referrals & Earnings'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Referral Link Card
            _ReferralLinkCard(referralLink: referralLink, context: context),

            // Earnings Summary Section
            _CommissionSummarySection(earnings: agentEarnings),

            // Commission History Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Commission History',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  if (agentEarnings.commissions.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Column(
                          children: [
                            Icon(
                              Icons.history,
                              size: 48,
                              color: AppTheme.textSecondary.withOpacity(0.5),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'No commissions yet',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    _CommissionHistoryTable(
                      commissions: agentEarnings.commissions,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<AgentCommission> _getMockCommissions() {
    return [
      AgentCommission(
        id: 'comm_1',
        dealId: 'deal_123',
        amount: 50000,
        commissionRate: 2.5,
        dealTitle: 'Property A - Mumbai',
        dealPrice: 2000000,
        approvalDate: DateTime.now().subtract(const Duration(days: 5)),
        paymentDate: DateTime.now().subtract(const Duration(days: 2)),
        status: 'paid',
      ),
      AgentCommission(
        id: 'comm_2',
        dealId: 'deal_124',
        amount: 35000,
        commissionRate: 2.5,
        dealTitle: 'Property B - Pune',
        dealPrice: 1400000,
        approvalDate: DateTime.now().subtract(const Duration(days: 10)),
        paymentDate: null,
        status: 'approved',
      ),
      AgentCommission(
        id: 'comm_3',
        dealId: 'deal_125',
        amount: 45000,
        commissionRate: 2.5,
        dealTitle: 'Property C - Bangalore',
        dealPrice: 1800000,
        approvalDate: null,
        paymentDate: null,
        status: 'pending',
      ),
    ];
  }
}

class _ReferralLinkCard extends StatelessWidget {
  final String referralLink;
  final BuildContext context;

  const _ReferralLinkCard({
    required this.referralLink,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryBlue.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Referral Link',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.borderGrey,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _getMaskedLink(referralLink),
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _copyToClipboard(context, referralLink),
                  child: Icon(
                    Icons.copy,
                    size: 18,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _shareLink(context, referralLink),
                  icon: const Icon(Icons.share),
                  label: const Text('Share'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _copyToClipboard(context, referralLink),
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentGrey,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getMaskedLink(String link) {
    if (link.length > 30) {
      return '${link.substring(0, 20)}...${link.substring(link.length - 10)}';
    }
    return link;
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Referral link copied!'),
        duration: Duration(seconds: 2),
      ),
    );
    AppLogger.info('Referral link copied to clipboard');
  }

  void _shareLink(BuildContext context, String link) {
    // Note: Requires share_plus package
    // Share.share(
    //   'Join me on ClearDeed! Use my referral link: $link',
    //   subject: 'Join ClearDeed Real Estate Platform',
    // );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share functionality ready (requires share_plus)'),
        duration: Duration(seconds: 2),
      ),
    );
    AppLogger.info('Share link triggered: $link');
  }
}

class _CommissionSummarySection extends StatelessWidget {
  final AgentEarnings earnings;

  const _CommissionSummarySection({required this.earnings});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Earnings Summary',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),

          // Total Earnings Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.successGreen.withOpacity(0.9),
                  AppTheme.successGreen.withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Earnings',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  currencyFormat.format(earnings.totalEarnings),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Status Cards Grid
          Row(
            children: [
              Expanded(
                child: _buildStatusCard(
                  'Paid',
                  currencyFormat.format(earnings.paidEarnings),
                  AppTheme.successGreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatusCard(
                  'Approved',
                  currencyFormat.format(earnings.approvedEarnings),
                  AppTheme.infoBlue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatusCard(
                  'Pending',
                  currencyFormat.format(earnings.pendingEarnings),
                  AppTheme.warningOrange,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Stats
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.lightGrey,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem(
                  'Total Deals',
                  '${earnings.totalDeals}',
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: AppTheme.borderGrey,
                ),
                _buildStatItem(
                  'This Month',
                  '${earnings.dealsThisMonth}',
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Withdraw Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showWithdrawSheet(context, earnings),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: AppTheme.primaryBlue,
              ),
              child: const Text(
                'Request Withdrawal',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(String label, String amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            amount,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryBlue,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  void _showWithdrawSheet(BuildContext context, AgentEarnings earnings) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Withdrawal request submitted'),
        duration: Duration(seconds: 2),
      ),
    );
    AppLogger.info('Withdrawal requested for amount: ${earnings.approvedEarnings}');
  }
}

class _CommissionHistoryTable extends StatelessWidget {
  final List<AgentCommission> commissions;

  const _CommissionHistoryTable({required this.commissions});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: commissions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final commission = commissions[index];
        return _buildCommissionTile(context, commission);
      },
    );
  }

  Widget _buildCommissionTile(
    BuildContext context,
    AgentCommission commission,
  ) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.lightGrey,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  commission.dealTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                currencyFormat.format(commission.amount),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.successGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${commission.commissionRate}% of ${currencyFormat.format(commission.dealPrice)}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textSecondary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(commission.status),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  commission.status.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (commission.paymentDate != null)
            Text(
              'Paid on ${DateFormat('MMM dd, yyyy').format(commission.paymentDate!)}',
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondary,
              ),
            )
          else if (commission.approvalDate != null)
            Text(
              'Approved on ${DateFormat('MMM dd, yyyy').format(commission.approvalDate!)}',
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondary,
              ),
            )
          else
            Text(
              'Pending approval',
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.warningOrange,
              ),
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
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


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mock data - replace with actual provider
    final referralLink = 'https://cleardeed.com/ref/agent_12345';
    final agentEarnings = AgentEarnings(
      agentId: 'agent_123',
      totalEarnings: 250000,
      pendingEarnings: 45000,
      approvedEarnings: 85000,
      paidEarnings: 120000,
      totalDeals: 8,
      dealsThisMonth: 2,
      commissions: _getMockCommissions(),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Referrals & Earnings'),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Referral Link Card
            _ReferralLinkCard(referralLink: referralLink),

            // Commission Summary Cards
            _CommissionSummarySection(earnings: agentEarnings),

            // Commission History Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Commission History',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  _CommissionHistoryTable(commissions: agentEarnings.commissions),
                  const SizedBox(height: 24),
                  // Withdraw button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: agentEarnings.approvedEarnings > 0
                          ? () => _showWithdrawDialog(context)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: agentEarnings.approvedEarnings > 0
                            ? AppTheme.primaryBlue
                            : AppTheme.textHint,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Request Withdrawal'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Referral terms
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        AppLogger.logNavigation('ReferralView', 'ReferralTerms');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Opening referral terms...'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      child: Text(
                        'View Referral Terms & Conditions',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.primaryBlue,
                          decoration: TextDecoration.underline,
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

  void _showWithdrawDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Withdrawal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Available balance: ₹85,000'),
            const SizedBox(height: 16),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Withdrawal Amount',
                hintText: 'Enter amount',
                prefixText: '₹ ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Withdrawal will be processed within 3-5 business days to your registered bank account.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
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
                  content: Text('Withdrawal request submitted successfully!'),
                  backgroundColor: AppTheme.successGreen,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  List<Commission> _getMockCommissions() => [
    Commission(
      id: '1',
      agentId: 'agent_123',
      dealId: 'deal_001',
      propertyId: 'prop_001',
      buyerId: 'buyer_001',
      amount: 15000,
      currency: 'INR',
      percentage: 1.5,
      status: 'paid',
      earnedDate: DateTime.now().subtract(const Duration(days: 30)),
      paidDate: DateTime.now().subtract(const Duration(days: 25)),
      paymentMethod: 'bank_transfer',
      transactionId: 'TXN123456',
    ),
    Commission(
      id: '2',
      agentId: 'agent_123',
      dealId: 'deal_002',
      propertyId: 'prop_002',
      buyerId: 'buyer_002',
      amount: 22000,
      currency: 'INR',
      percentage: 2.0,
      status: 'paid',
      earnedDate: DateTime.now().subtract(const Duration(days: 20)),
      paidDate: DateTime.now().subtract(const Duration(days: 15)),
      paymentMethod: 'bank_transfer',
      transactionId: 'TXN123457',
    ),
    Commission(
      id: '3',
      agentId: 'agent_123',
      dealId: 'deal_003',
      propertyId: 'prop_003',
      buyerId: 'buyer_003',
      amount: 18500,
      currency: 'INR',
      percentage: 1.85,
      status: 'approved',
      earnedDate: DateTime.now().subtract(const Duration(days: 10)),
    ),
    Commission(
      id: '4',
      agentId: 'agent_123',
      dealId: 'deal_004',
      propertyId: 'prop_004',
      buyerId: 'buyer_004',
      amount: 26500,
      currency: 'INR',
      percentage: 2.5,
      status: 'pending',
      earnedDate: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];
}

// ==================== Referral Link Card ====================

class _ReferralLinkCard extends StatefulWidget {
  final String referralLink;

  const _ReferralLinkCard({required this.referralLink});

  @override
  State<_ReferralLinkCard> createState() => _ReferralLinkCardState();
}

class _ReferralLinkCardState extends State<_ReferralLinkCard> {
  bool _copied = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Referral Link',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            // Link display with copy button
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.lightGrey,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppTheme.textHint.withOpacity(0.3)),
                    ),
                    child: Text(
                      widget.referralLink,
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    _copyToClipboard(widget.referralLink);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _copied ? AppTheme.successGreen : AppTheme.primaryBlue,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      _copied ? Icons.done : Icons.content_copy,
                      color: AppTheme.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Share buttons
            SizedBox(
              width: double.infinity,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _shareViaWhatsApp(widget.referralLink, context),
                      icon: const Icon(Icons.share),
                      label: const Text('WhatsApp'),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.primaryBlue),
                      ),
                    ),
                  ),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _shareViaEmail(widget.referralLink, context),
                      icon: const Icon(Icons.email),
                      label: const Text('Email'),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.primaryBlue),
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

  void _copyToClipboard(String text) {
    // In production, use flutter/services.dart Clipboard.setData
    AppLogger.logNavigation('ReferralView', 'CopyLink');
    setState(() {
      _copied = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Link copied to clipboard!'),
        duration: Duration(seconds: 1),
        backgroundColor: AppTheme.successGreen,
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  void _shareViaWhatsApp(String link, BuildContext context) {
    AppLogger.logNavigation('ReferralView', 'ShareWhatsApp');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening WhatsApp...'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _shareViaEmail(String link, BuildContext context) {
    AppLogger.logNavigation('ReferralView', 'ShareEmail');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening email client...'),
        duration: Duration(seconds: 1),
      ),
    );
  }
}

// ==================== Commission Summary Section ====================

class _CommissionSummarySection extends StatelessWidget {
  final AgentEarnings earnings;

  const _CommissionSummarySection({required this.earnings});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      symbol: '₹',
      decimalDigits: 0,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Commission Summary',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.1,
            children: [
              _SummaryCard(
                title: 'Total Earned',
                amount: earnings.totalEarnings,
                color: AppTheme.primaryBlue,
              ),
              _SummaryCard(
                title: 'Pending',
                amount: earnings.pendingEarnings,
                color: AppTheme.warningOrange,
              ),
              _SummaryCard(
                title: 'Approved',
                amount: earnings.approvedEarnings,
                color: AppTheme.infoBlue,
              ),
              _SummaryCard(
                title: 'Paid',
                amount: earnings.paidEarnings,
                color: AppTheme.successGreen,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==================== Summary Card ====================

class _SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.color,
  });

  String _formatAmount(double amount) {
    if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return '₹${amount.toStringAsFixed(0)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(Icons.trending_up, color: color, size: 18),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatAmount(amount),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== Commission History Table ====================

class _CommissionHistoryTable extends StatelessWidget {
  final List<Commission> commissions;

  const _CommissionHistoryTable({required this.commissions});

  String _getStatusBadge(String status) {
    switch (status) {
      case 'paid':
        return 'PAID';
      case 'approved':
        return 'APPROVED';
      case 'pending':
        return 'PENDING';
      default:
        return status.toUpperCase();
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
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
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: commissions.length,
      itemBuilder: (context, index) {
        final commission = commissions[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Deal: ${commission.dealId}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('dd MMM yyyy').format(commission.earnedDate),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₹${commission.amount.toStringAsFixed(0)}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getStatusColor(commission.status).withOpacity(0.2),
                            border: Border.all(color: _getStatusColor(commission.status)),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _getStatusBadge(commission.status),
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: _getStatusColor(commission.status),
                              fontWeight: FontWeight.w600,
                            ),
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
      },
    );
  }
}
