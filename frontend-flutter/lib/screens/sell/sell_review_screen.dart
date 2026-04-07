import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'sell_provider.dart';

/// Step 5: Review & Submit Screen
/// Shows summary of all entered data with ability to edit each section
class SellReviewScreen extends ConsumerStatefulWidget {
  final VoidCallback? onBack;

  const SellReviewScreen({
    Key? key,
    this.onBack,
  }) : super(key: key);

  @override\n  ConsumerState<SellReviewScreen> createState() => _SellReviewScreenState();
}

class _SellReviewScreenState extends ConsumerState<SellReviewScreen> {
  @override
  Widget build(BuildContext context) {
    final formData = ref.watch(propertyFormProvider);
    final submissionStatus = ref.watch(submissionStatusProvider);
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepProgress(),
          const SizedBox(height: 24),

          Text(
            'Review Your Property',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Please review all details before submission',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),

          // Property Details Section
          _buildSectionCard(
            title: 'Property Details',
            onEdit: () => ref.read(currentStepProvider.notifier).state = 1,
            children: [
              _buildReviewRow('Category', formData.category),
              _buildReviewRow('Title', formData.title),
              _buildReviewRow('Description', formData.description),
              _buildReviewRow('City', formData.city),
              _buildReviewRow('Locality', formData.locality),
              _buildReviewRow('Area', '${formData.area} sqft'),
              _buildReviewRow('Price', '₹${_formatPrice(formData.price ?? '')}'),
              _buildReviewRow('Ownership', formData.ownershipType),
              _buildReviewRow('Status', formData.availabilityStatus),
            ],
          ),
          const SizedBox(height: 16),

          // Images Section
          _buildSectionCard(
            title: 'Images',
            subtitle: '${formData.imageFilePaths.length} images',
            onEdit: () => ref.read(currentStepProvider.notifier).state = 2,
            children: [
              if (formData.imageFilePaths.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(
                    formData.imageFilePaths.length,
                    (index) => Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color:
                              theme.colorScheme.outline.withOpacity(0.3),
                        ),
                        borderRadius: BorderRadius.circular(4),
                        color: theme.colorScheme.surfaceVariant,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: theme.textTheme.labelSmall,
                        ),
                      ),
                    ),
                  ),
                )
              else
                Text(
                  'No images added',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Documents Section
          _buildSectionCard(
            title: 'Documents',
            subtitle: '${formData.documents.length} documents',
            onEdit: () => ref.read(currentStepProvider.notifier).state = 3,
            children: [
              if (formData.documents.isNotEmpty)
                Column(
                  children: formData.documents.entries.map((e) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(Icons.description,
                              size: 20,
                              color: theme.colorScheme.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              e.value.fileName,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                          Icon(Icons.check_circle,
                              size: 18,
                              color: Colors.green.shade600),
                        ],
                      ),
                    );
                  }).toList(),
                )
              else
                Text(
                  'No documents added',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Referral Agent Section
          _buildSectionCard(
            title: 'Referral Agent',
            onEdit: () => ref.read(currentStepProvider.notifier).state = 4,
            children: [
              if (formData.agentMobileNumber != null &&
                  formData.agentMobileNumber!.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildReviewRow('Agent Name', formData.agentName),
                    _buildReviewRow(
                        'Mobile Number', formData.agentMobileNumber),
                    _buildReviewRow(
                      'Verification',
                      formData.agentVerified ?? false
                          ? 'Verified'
                          : 'Not Verified',
                    ),
                  ],
                )
              else
                Text(
                  'No agent added',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),

          // Submit button
          if (submissionStatus == SubmissionStatus.idle)
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _submitProperty,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Submit Property'),
              ),
            )
          else if (submissionStatus == SubmissionStatus.loading)
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: null,
                icon: const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                label: const Text('Submitting...'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _submitProperty() async {
    try {
      await ref.read(submitPropertyProvider.future);
      // Success - will be handled by provider
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Property submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildStepProgress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Step 5 of 5',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: 1.0,
            minHeight: 6,
            backgroundColor:
                Theme.of(context).colorScheme.outline.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    String? subtitle,
    required VoidCallback onEdit,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(7)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                  ],
                ),
                TextButton(
                  onPressed: onEdit,
                  child: const Text('Edit'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewRow(String label, String? value) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'N/A',
              textAlign: TextAlign.end,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(String price) {
    if (price.isEmpty) return 'N/A';
    try {
      final numPrice = int.parse(price.replaceAll(',', ''));
      return numPrice.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      );
    } catch (e) {
      return price;
    }
  }
}
