import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'sell_screen_provider.dart';

/// Step 5: Review & Submit Screen
/// Shows complete summary of all property details with option to edit any section
class SellReviewScreen extends ConsumerStatefulWidget {
  final VoidCallback? onBack;
  final Function(String)? onSuccess;

  const SellReviewScreen({
    Key? key,
    this.onBack,
    this.onSuccess,
  }) : super(key: key);

  @override
  ConsumerState<SellReviewScreen> createState() => _SellReviewScreenState();
}

class _SellReviewScreenState extends ConsumerState<SellReviewScreen> {
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final formData = ref.watch(formDataProvider);
    final submissionStatus = ref.watch(sellScreenProvider).submissionStatus;
    final isLoading = ref.watch(sellScreenProvider).isLoading;
    final theme = Theme.of(context);

    if (submissionStatus != null && submissionStatus.status == 'submitted') {
      return _buildSuccessScreen(submissionStatus, theme);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review & Submit'),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step indicator
            _buildStepIndicator(5, theme),
            const SizedBox(height: 32),

            // Title
            Text(
              'Review Your Property',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please review all details before submitting',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),

            // Step 1: Property Details
            _buildSectionCard(
              title: 'Property Details',
              stepNumber: 1,
              onEdit: () {
                ref.read(sellScreenProvider.notifier).goToStep(0);
              },
              children: [
                _buildReviewRow('Category', formData.category, theme),
                _buildReviewRow('Title', formData.title, theme),
                _buildReviewRow('Description', formData.description, theme),
                _buildReviewRow('City', formData.city, theme),
                _buildReviewRow('Locality', formData.locality, theme),
                _buildReviewRow('Area', '${formData.area} sqft', theme),
                _buildReviewRow(
                    'Price',
                    (formData.price ?? '0').toString().replaceAllMapped(
                          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
                          (Match m) => '${m[1]},',
                        ),
                    theme),
                _buildReviewRow('Ownership Type', formData.ownershipType, theme),
                _buildReviewRow(
                    'Availability', formData.availabilityStatus, theme),
              ],
              theme: theme,
            ),
            const SizedBox(height: 16),

            // Step 2: Images
            _buildSectionCard(
              title: 'Property Images',
              stepNumber: 2,
              onEdit: () {
                ref.read(sellScreenProvider.notifier).goToStep(1);
              },
              children: [
                if (formData.imageFilePaths.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      children: formData.imageFilePaths
                          .take(6)
                          .map((path) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: File(path).existsSync()
                                  ? Image.file(
                                      File(path),
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      color: Colors.grey[200],
                                      child: Icon(
                                        Icons.image_not_supported,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                            );
                          })
                          .toList(),
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  '${formData.imageFilePaths.length} images added',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
              theme: theme,
            ),
            const SizedBox(height: 16),

            // Step 3: Documents
            _buildSectionCard(
              title: 'Documents',
              stepNumber: 3,
              onEdit: () {
                ref.read(sellScreenProvider.notifier).goToStep(2);
              },
              children: [
                if (formData.documents.isEmpty)
                  Text(
                    'No documents uploaded',
                    style: TextStyle(color: Colors.grey[600]),
                  )
                else
                  Column(
                    children: formData.documents.entries
                        .map((entry) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.green[600],
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      entry.value.fileName,
                                      style: theme.textTheme.bodySmall,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
              ],
              theme: theme,
            ),
            const SizedBox(height: 16),

            // Step 4: Referral (if applicable)
            if (formData.agentVerified)
              Column(
                children: [
                  _buildSectionCard(
                    title: 'Referral Agent',
                    stepNumber: 4,
                    onEdit: () {
                      ref.read(sellScreenProvider.notifier).goToStep(3);
                    },
                    children: [
                      _buildReviewRow('Agent Name', formData.agentName, theme),
                      _buildReviewRow(
                          'Mobile Number', formData.agentMobileNumber, theme),
                    ],
                    theme: theme,
                  ),
                  const SizedBox(height: 16),
                ],
              ),

            // Submit button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: isLoading
                    ? null
                    : () {
                        _handleSubmit();
                      },
                icon: isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              theme.colorScheme.onPrimary),
                        ),
                      )
                    : const Icon(Icons.check),
                label: Text(isLoading ? 'Submitting...' : 'Submit Property'),
              ),
            ),
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () {
                  ref.read(sellScreenProvider.notifier).previousStep();
                  widget.onBack?.call();
                },
                child: const Text('Back'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSubmit() async {
    await ref.read(sellScreenProvider.notifier).submitProperty();
    final status = ref.read(submissionStatusProvider);
    if (status != null) {
      widget.onSuccess?.call(status.propertyId);
    }
  }

  Widget _buildSuccessScreen(
      PropertySubmissionStatus status, ThemeData theme) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  size: 80,
                  color: Colors.green[600],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Property Submitted!',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your property is now under review',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Property ID',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          status.propertyId,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Status',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Submitted',
                            style: TextStyle(
                              color: Colors.blue[800],
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    // Navigate to status screen
                  },
                  child: const Text('View Status'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    // Navigate back to home
                  },
                  child: const Text('Go to Home'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required int stepNumber,
    required VoidCallback onEdit,
    required List<Widget> children,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              FilledButton.tonal(
                onPressed: onEdit,
                child: const Text('Edit'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ],
      ),
    );
  }

  Widget _buildReviewRow(String label, String? value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          Text(
            value ?? 'N/A',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.end,
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
