import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'sell_screen_provider.dart';

/// Step 4: Referral Agent Screen
/// Optional referral agent information - allows adding agent details for commission/network
class SellReferralScreen extends ConsumerStatefulWidget {
  final VoidCallback? onNext;
  final VoidCallback? onBack;

  const SellReferralScreen({
    Key? key,
    this.onNext,
    this.onBack,
  }) : super(key: key);

  @override
  ConsumerState<SellReferralScreen> createState() =>
      _SellReferralScreenState();
}

class _SellReferralScreenState extends ConsumerState<SellReferralScreen> {
  late TextEditingController _mobileController;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    final formData = ref.read(formDataProvider);
    _mobileController =
        TextEditingController(text: formData.agentMobileNumber ?? '');
  }

  @override
  void dispose() {
    _mobileController.dispose();
    super.dispose();
  }

  Future<void> _verifyAgent() async {
    final mobile = _mobileController.text.trim();

    if (mobile.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter mobile number')),
      );
      return;
    }

    if (mobile.length != 10 || !RegExp(r'^[6-9]').hasMatch(mobile)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid 10-digit mobile number'),
        ),
      );
      return;
    }

    setState(() => _isVerifying = true);
    final success = await ref
        .read(sellScreenProvider.notifier)
        .verifyAgent(mobile);
    setState(() => _isVerifying = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Agent verified successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to verify agent'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final formData = ref.watch(formDataProvider);
    final error = ref.watch(sellScreenProvider).error;
    final isLoading = ref.watch(sellScreenProvider).isLoading;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Referral Agent'),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step indicator
            _buildStepIndicator(4, theme),
            const SizedBox(height: 32),

            // Title
            Text(
              'Referral Agent (Optional)',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add a referral agent to earn commission on this listing',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),

            // Benefits banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.card_giftcard, color: Colors.amber[600], size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Get Commission',
                          style: TextStyle(
                            color: Colors.amber[900],
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Add an agent to share your listing network and earn commission',
                          style: TextStyle(
                            color: Colors.amber[700],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Error banner
            if (error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red[600], size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        error,
                        style: TextStyle(color: Colors.red[700]),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, size: 20, color: Colors.red[600]),
                      onPressed: () =>
                          ref.read(sellScreenProvider.notifier).clearError(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Agent verification card
            if (formData.agentVerified && formData.agentMobileNumber != null)
              _buildAgentVerifiedCard(formData, theme)
            else
              _buildAgentInputCard(theme),

            const SizedBox(height: 32),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      ref.read(sellScreenProvider.notifier).previousStep();
                      widget.onBack?.call();
                    },
                    child: const Text('Back'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      ref.read(sellScreenProvider.notifier).nextStep();
                      widget.onNext?.call();
                    },
                    child: const Text('Review'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgentInputCard(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Agent Mobile Number',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _mobileController,
              enabled: !_isVerifying,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: 'Enter 10-digit mobile number',
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                counter: Text('${_mobileController.text.length}/10'),
              ),
              maxLength: 10,
              onChanged: (value) {
                setState(() {});
              },
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isVerifying ? null : _verifyAgent,
                icon: _isVerifying
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(theme.primaryColor),
                        ),
                      )
                    : const Icon(Icons.check_circle),
                label: Text(_isVerifying ? 'Verifying...' : 'Verify Agent'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.info, color: Colors.green[600], size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'You can skip this step and add agent later',
                  style: TextStyle(
                    color: Colors.green[700],
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAgentVerifiedCard(PropertyFormData formData, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[300]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: Colors.green[600],
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Agent Verified',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.green[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formData.agentName ?? 'Agent',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.green[700],
                      ),
                    ),
                    Text(
                      formData.agentMobileNumber ?? '',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.green[700],
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    _mobileController.clear();
                    ref.read(sellScreenProvider.notifier).removeAgent();
                  },
                  icon: const Icon(Icons.close),
                  label: const Text('Remove'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int currentStep, ThemeData theme) {
    return Row(
      children: [
        for (int i = 1; i <= 5; i++)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i < 5 ? 8 : 0),
              child: Column(
                children: [
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: i <= currentStep
                          ? theme.colorScheme.primary
                          : Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$i',
                        style: TextStyle(
                          color: i <= currentStep ? Colors.white : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Step $i',
                    style: TextStyle(
                      fontSize: 12,
                      color: i <= currentStep ? Colors.grey[800] : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
