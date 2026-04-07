import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'sell_provider.dart';

/// Step 3: Document Upload Screen
/// Supports uploading required and optional documents (title deed, survey, tax proof, approval letter)
class SellDocumentUploadScreen extends ConsumerStatefulWidget {
  final VoidCallback? onNext;
  final VoidCallback? onBack;

  const SellDocumentUploadScreen({
    Key? key,
    this.onNext,
    this.onBack,
  }) : super(key: key);

  @override
  ConsumerState<SellDocumentUploadScreen> createState() =>
      _SellDocumentUploadScreenState();
}

class _SellDocumentUploadScreenState
    extends ConsumerState<SellDocumentUploadScreen> {
  static const List<String> documentTypes = [
    'title_deed',
    'survey_report',
    'tax_proof',
    'approval_letter'
  ];

  static const Map<String, String> documentLabels = {
    'title_deed': 'Title Deed / Registration Certificate',
    'survey_report': 'Survey Report',
    'tax_proof': 'Tax Proof / Property Tax Receipt',
    'approval_letter': 'Building Approval Letter'
  };

  static const Map<String, bool> requiredDocuments = {
    'title_deed': true,
    'survey_report': false,
    'tax_proof': false,
    'approval_letter': false
  };

  void _pickDocument(String documentType) async {
    // TODO: Replace with actual file picker (file_picker package)
    // Example:
    // FilePicker.platform.pickFiles(
    //   type: FileType.custom,
    //   allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    // );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('File picker integration required')),
    );
  }

  void _removeDocument(String documentType) {
    final formData = ref.read(propertyFormProvider);
    final updatedDocs = Map<String, DocumentInfo>.from(formData.documents);
    updatedDocs.remove(documentType);
    ref.read(propertyFormProvider.notifier).state =
        formData.copyWith(documents: updatedDocs);
  }

  bool _validateDocuments() {
    final formData = ref.read(propertyFormProvider);
    if (!formData.documents.containsKey('title_deed')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Title Deed is mandatory. Please upload it.')),
      );
      return false;
    }
    return true;
  }

  void _proceedToNextStep() {
    if (_validateDocuments()) {
      ref.read(currentStepProvider.notifier).state = 4;
      widget.onNext?.call();
    }
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
            'Upload Documents',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Upload property documents for verification',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),

          // Documents list
          Column(
            children: documentTypes.map((docType) {
              final isRequired = requiredDocuments[docType] ?? false;
              final isUploaded = formData.documents.containsKey(docType);
              final docInfo = formData.documents[docType];

              return _buildDocumentCard(
                documentType: docType,
                label: documentLabels[docType] ?? docType,
                isRequired: isRequired,
                isUploaded: isUploaded,
                onUpload: () => _pickDocument(docType),
                onRemove: () => _removeDocument(docType),
                fileName: docInfo?.fileName,
              );
            }).toList(),
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
          'Step 3 of 5',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: 0.6,
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

  Widget _buildDocumentCard({
    required String documentType,
    required String label,
    required bool isRequired,
    required bool isUploaded,
    required VoidCallback onUpload,
    required VoidCallback onRemove,
    String? fileName,
  }) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (isRequired)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Required',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              if (!isRequired)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Optional',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.amber.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (isUploaded && fileName != null)
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green.shade600, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    fileName,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.green.shade600,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onRemove,
                  child: Icon(Icons.close, color: Colors.red.shade600, size: 20),
                ),
              ],
            )
          else
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onUpload,
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload Document'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              ref.read(currentStepProvider.notifier).state = 2;
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
            child: const Text('Next'),
          ),
        ),
      ],
    );
  }
}
