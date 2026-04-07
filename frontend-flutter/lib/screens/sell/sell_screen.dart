import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';

/// Sell screen - property listing flow (stub for phase 1)
class SellScreen extends StatelessWidget {
  const SellScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sell Property'),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              // Illustration
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: AppTheme.lightGrey,
                  borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                ),
                child: Icon(
                  Icons.home_work,
                  size: 80,
                  color: AppTheme.primaryBlue.withOpacity(0.3),
                ),
              ),

              const SizedBox(height: 32),

              Text(
                'List Your Property',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: AppTheme.primaryBlue,
                    ),
              ),

              const SizedBox(height: 12),

              Text(
                'Get verified buyer inquiries in minutes',
                style: Theme.of(context).textTheme.bodyMedium,
              ),

              const SizedBox(height: 32),

              // Benefits list
              Column(
                children: [
                  _BenefitItem(
                    icon: Icons.verified,
                    title: '100% Verified Buyers',
                    description: 'Only genuine buyers will contact you',
                  ),
                  const SizedBox(height: 12),
                  _BenefitItem(
                    icon: Icons.trending_up,
                    title: 'Maximize Value',
                    description: 'Get best market price for your property',
                  ),
                  const SizedBox(height: 12),
                  _BenefitItem(
                    icon: Icons.schedule,
                    title: 'Quick Process',
                    description: 'List and get inquiries within minutes',
                  ),
                  const SizedBox(height: 12),
                  _BenefitItem(
                    icon: Icons.security,
                    title: 'Complete Safety',
                    description: 'All transactions are verified & secure',
                  ),
                ],
              ),

              const SizedBox(height: 48),

              // CTA Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Sell flow coming soon!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_home),
                  label: const Text('Start Listing'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== Benefit Item ====================

class _BenefitItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _BenefitItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.lightGrey,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryBlue,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
