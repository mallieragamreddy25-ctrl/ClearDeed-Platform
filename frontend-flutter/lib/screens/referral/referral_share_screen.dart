import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../theme/app_theme.dart';
import '../utils/app_logger.dart';
import '../providers/user_provider.dart';

/// Referral share screen - displays secure referral link and sharing options
/// Users can copy link and share via social media or messaging apps
class ReferralShareScreen extends ConsumerWidget {
  const ReferralShareScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final referralLink = _generateReferralLink(currentUser?.id ?? '');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Referral Program'),
        elevation: 0,
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: AppTheme.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              _buildHeaderSection(context),
              const SizedBox(height: 32),

              // Referral Code Section
              _buildReferralCodeSection(context, referralLink),
              const SizedBox(height: 32),

              // Share Options Section
              _buildShareOptionsSection(context, referralLink),
              const SizedBox(height: 32),

              // Benefits Section
              _buildBenefitsSection(context),
              const SizedBox(height: 32),

              // Terms Section
              _buildTermsSection(context),
            ],
          ),
        ),
      ),
    );
  }

  /// Header with illustrations and welcome text
  Widget _buildHeaderSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryBlue,
                AppTheme.primaryBlue.withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.card_giftcard, color: AppTheme.white, size: 40),
              const SizedBox(height: 12),
              Text(
                'Earn with Referrals',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppTheme.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Share your unique referral link and earn commissions when friends join',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.white.withOpacity(0.9),
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Referral code display and copy section
  Widget _buildReferralCodeSection(BuildContext context, String referralLink) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Referral Link',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.lightGrey),
            borderRadius: BorderRadius.circular(12),
            color: AppTheme.lightGrey.withOpacity(0.3),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    referralLink,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontFamily: 'monospace',
                          color: AppTheme.primaryBlue,
                        ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.copy, color: AppTheme.primaryBlue),
                onPressed: () {
                  _copyToClipboard(referralLink, context);
                  AppLogger.logUIEvent('Referral link copied', {});
                },
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Share your link to earn commissions',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
      ],
    );
  }

  /// Share options (via different channels)
  Widget _buildShareOptionsSection(BuildContext context, String referralLink) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Share Via',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: [
            _buildShareOption(
              context,
              Icons.message,
              'WhatsApp',
              'Share on WhatsApp',
              () => _shareViaWhatsApp(referralLink, context),
            ),
            _buildShareOption(
              context,
              Icons.mail,
              'Email',
              'Share via Email',
              () => _shareViaEmail(referralLink, context),
            ),
            _buildShareOption(
              context,
              Icons.share,
              'More',
              'Other options',
              () => _shareViaOther(referralLink, context),
            ),
            _buildShareOption(
              context,
              Icons.content_copy,
              'Copy Link',
              'Copy to clipboard',
              () {
                _copyToClipboard(referralLink, context);
                AppLogger.logUIEvent('Copied from share section', {});
              },
            ),
          ],
        ),
      ],
    );
  }

  /// Single share option card
  Widget _buildShareOption(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.lightGrey),
            borderRadius: BorderRadius.circular(12),
            color: AppTheme.white,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, color: AppTheme.primaryBlue, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Benefits section
  Widget _buildBenefitsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How It Works',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        _buildBenefitItem(
          context,
          '1',
          'Share Your Link',
          'Send your unique referral link to friends and contacts',
        ),
        const SizedBox(height: 12),
        _buildBenefitItem(
          context,
          '2',
          'Friend Joins',
          'When they sign up using your link, you get credited',
        ),
        const SizedBox(height: 12),
        _buildBenefitItem(
          context,
          '3',
          'Earn Commission',
          'Earn ₹500 per successful property transaction',
        ),
        const SizedBox(height: 12),
        _buildBenefitItem(
          context,
          '4',
          'Get Rewards',
          'Bonus rewards for 10+ successful referrals',
        ),
      ],
    );
  }

  /// Single benefit item
  Widget _buildBenefitItem(
    BuildContext context,
    String number,
    String title,
    String description,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              number,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppTheme.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Terms and conditions section
  Widget _buildTermsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.infoBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.infoBlue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.info_outline,
                color: AppTheme.infoBlue,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Terms & Conditions',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.infoBlue,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Commission earned after successful property transaction\n• Friend must complete account verification\n• Only valid for new registered users\n• One referral per user limit per month',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                            height: 1.5,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Generate referral link
  String _generateReferralLink(String userId) {
    return 'https://cleardeed.com/ref/$userId';
  }

  /// Copy to clipboard
  void _copyToClipboard(String text, BuildContext context) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Link copied to clipboard'),
        backgroundColor: AppTheme.successGreen,
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Share via WhatsApp
  void _shareViaWhatsApp(String referralLink, BuildContext context) {
    final message = '''
🔗 Join ClearDeed - India's #1 Real Estate Platform!

I'm earning with ClearDeed! Join me and get exclusive benefits.

👉 $referralLink

✨ What you get:
• Verified Property Listings
• Transparent Deals
• Zero Hidden Charges
• Expert Support

Download now and start earning! 💰
''';

    Share.share(
      message,
      subject: 'Join ClearDeed with my referral link',
    );
    AppLogger.logUIEvent('Shared via WhatsApp', {});
  }

  /// Share via Email
  void _shareViaEmail(String referralLink, BuildContext context) {
    final message = '''
Hi there!

I'm using ClearDeed, India's leading real estate platform, and I'd love for you to join me!

Use my referral link to get special benefits: $referralLink

ClearDeed offers:
• Verified property listings
• Transparent transactions
• Expert guidance
• Earn with referrals

Looking forward to seeing you there!

Best regards
''';

    Share.share(
      message,
      subject: 'Join ClearDeed with my referral link',
    );
    AppLogger.logUIEvent('Shared via Email', {});
  }

  /// Share via other methods
  void _shareViaOther(String referralLink, BuildContext context) {
    final message =
        'Join ClearDeed! Use my referral link to get benefits: $referralLink';

    Share.share(
      message,
      subject: 'ClearDeed Referral Link',
    );
    AppLogger.logUIEvent('Shared via other methods', {});
  }
}
