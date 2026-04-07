import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'sell_provider.dart';

/// Step 4: Referral Agent Screen
/// Optional: Add referral agent contact for commission sharing
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
  late TextEditingController _agentMobileController;
  bool _hasAgent = false;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    final formData = ref.read(propertyFormProvider);
    _agentMobileController = TextEditingController(
      text: formData.agentMobileNumber ?? '',
    );
    _hasAgent = formData.agentMobileNumber != null &&
        formData.agentMobileNumber!.isNotEmpty;
  }

  @override
  void dispose() {
    _agentMobileController.dispose();
    super.dispose();
  }

  void _verifyAgent() async {
    final mobile = _agentMobileController.text.trim();

    if (mobile.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter agent mobile number')),
      );
      return;
    }

    if (!_isValidMobileNumber(mobile)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter a valid 10-digit mobile number')),
      );
      return;
    }

    setState(() => _isVerifying = true);

    try {
      final agentData =
          await ref.read(verifyAgentProvider(mobile).future);

      if (agentData != null) {
        final formData = ref.read(propertyFormProvider);
        ref.read(propertyFormProvider.notifier).state = formData.copyWith(
          agentMobileNumber: mobile,
          agentName: agentData['name'],
          agentVerified: agentData['verified'] ?? false,
        );

        setState(() => _hasAgent = true);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Agent verified successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Agent not found')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isVerifying = false);
    }
  }

  void _removeAgent() {
    setState(() => _hasAgent = false);
    _agentMobileController.clear();
    final formData = ref.read(propertyFormProvider);
    ref.read(propertyFormProvider.notifier).state = formData.copyWith(
      agentMobileNumber: null,
      agentName: null,
      agentVerified: false,
    );
  }

  bool _isValidMobileNumber(String mobile) {
    final cleanMobile = mobile.replaceAll(RegExp(r'[^0-9]'), '');
    return cleanMobile.length == 10;
  }

  void _proceedToNextStep() {
    final formData = ref.read(propertyFormProvider);
    ref.read(currentStepProvider.notifier).state = 5;
    widget.onNext?.call();
  }

  @override
  Widget build(BuildContext context) {
    final formData = ref.watch(propertyFormProvider);
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepProgress(),
          const SizedBox(height: 24),

          Text(
            'Referral Agent (Optional)',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Share a referral agent who can help sell this property',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),

          // Agent info section
          if (_hasAgent && formData.agentName != null)
            _buildAgentInfoCard(formData, theme)
          else
            _buildAgentInputSection(theme),

          const SizedBox(height: 24),

          // Info box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info, color: Colors.blue.shade600, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Adding a referral agent helps in faster property sales. Both parties can benefit from commission sharing.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Action buttons
          _buildActionButtons(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildStepProgress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step 4 of 5',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: 0.8,
            minHeight: 6,
            backgroundColor: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAgentInputSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Agent Mobile Number',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _agentMobileController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            hintText: 'Enter agent 10-digit mobile number',
            prefixIcon: const Icon(Icons.phone),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: theme.colorScheme.surface,
            errorMaxLines: 2,
          ),
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              if (!_isValidMobileNumber(value)) {
                return 'Please enter a valid 10-digit mobile number';
              }
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _isVerifying ? null : _verifyAgent,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: _isVerifying
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Verify Agent'),
          ),
        ),
      ],
    );
  }

  Widget _buildAgentInfoCard(PropertyFormData formData, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.green.shade200),
        borderRadius: BorderRadius.circular(8),
        color: Colors.green.shade50,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green.shade600,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Agent Verified',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.green.shade600,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildAgentDetailRow('Name', formData.agentName ?? 'N/A', theme),
          const SizedBox(height: 8),
          _buildAgentDetailRow(
              'Mobile', formData.agentMobileNumber ?? 'N/A', theme),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _removeAgent,
                  child: const Text('Change Agent'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAgentDetailRow(
      String label, String value, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              ref.read(currentStepProvider.notifier).state = 3;
              widget.onBack?.call();
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('Back'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton(
            onPressed: _proceedToNextStep,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('Review'),
          ),
        ),
      ],
    );
  }
}
