import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../../theme/app_theme.dart';
import '../models/sell_form_model.dart';
import '../providers/sell_form_provider.dart';
import '../widgets/sell_form_widgets.dart';

class SellDocumentUploadScreen extends ConsumerStatefulWidget {
  const SellDocumentUploadScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SellDocumentUploadScreen> createState() =>
      _SellDocumentUploadScreenState();
}

class _SellDocumentUploadScreenState
    extends ConsumerState<SellDocumentUploadScreen> {
  final List<Map<String, String>> documentTypes = [
    {'type': 'title_deed', 'name': 'Title Deed / Registry Copy', 'required': 'true'},
    {'type': 'survey', 'name': 'Survey Report', 'required': 'false'},
    {'type': 'tax_proof', 'name': 'Property Tax Proof', 'required': 'false'},
    {'type': 'approval_letter', 'name': 'Municipal Approval Letter', 'required': 'false'},
    {'type': 'ownership_proof', 'name': 'Ownership Proof Document', 'required': 'false'},
    {'type': 'other', 'name': 'Other Documents', 'required': 'false'},
  ];

  Future<void> _pickDocument(String documentType) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
      );

      if (result != null && result.files.single.path != null && mounted) {
        final file = File(result.files.single.path!);
        final fileName = result.files.single.name;

        ref
            .read(sellFormProvider.notifier)
            .addDocument(file, documentType, fileName);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking file: $e')),
        );
      }
    }
  }

  void _handleNext() {
    final notifier = ref.read(sellFormProvider.notifier);
    final documents = ref.read(sellFormProvider).localDocuments;

    // Check if at least title deed is provided
    final hasTitleDeed =
        documents.any((doc) => doc.documentType == 'title_deed');

    if (!hasTitleDeed) {
      notifier.setError('Title Deed is required');
      return;
    }

    // In a real app, you would upload documents here
    // For now, we'll use placeholder URLs
    final documentUrls = <String, String>{};
    for (var doc in documents) {
      documentUrls[doc.documentType] = 'file://${doc.file.path}';
    }

    notifier.commitDocumentUrls(documentUrls);
    notifier.nextStep();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(sellFormProvider);
    final documents = formState.localDocuments;
    final draft = formState.draft;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Documents'),
        elevation: 0,
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Step indicator
              SellStepIndicator(
                currentStep: formState.currentStep,
                completedSteps: formState.completedSteps,
              ),
              const SizedBox(height: 32),

              // Title
              Text(
                'Upload Documents',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Upload property documents for verification. Title Deed is mandatory.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),

              // Error banner
              ErrorBanner(
                error: formState.error,
                onDismiss: () =>
                    ref.read(sellFormProvider.notifier).clearError(),
              ),
              if (formState.error != null) const SizedBox(height: 16),

              // Uploaded documents
              if (documents.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Uploaded Documents (${documents.length})',
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: documents.length,
                      itemBuilder: (context, index) {
                        final doc = documents[index];
                        return _DocumentCard(
                          document: doc,
                          index: index,
                          onRemove: () => ref
                              .read(sellFormProvider.notifier)
                              .removeDocument(index),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),

              // Document type selection
              Text(
                'Add More Documents',
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Column(
                children: documentTypes
                    .map((docType) {
                      final isRequired = docType['required'] == 'true';
                      final isUploaded = documents.any(
                          (doc) => doc.documentType == docType['type']);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _DocumentTypeButton(
                          documentName: docType['name'] ?? '',
                          isRequired: isRequired,
                          isUploaded: isUploaded,
                          onPressed: isUploaded
                              ? null
                              : () => _pickDocument(docType['type'] ?? ''),
                        ),
                      );
                    })
                    .toList(),
              ),

              const SizedBox(height: 32),

              // Info banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.warningOrange.withOpacity(0.1),
                  border: Border.all(color: AppTheme.warningOrange),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning_amber,
                            color: AppTheme.warningOrange, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Document Upload Tips',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Ensure documents are clear and legible\n'
                      '• File size should not exceed 10 MB\n'
                      '• Supported formats: PDF, JPG, PNG, DOC, DOCX',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Action buttons
              StepActionButtons(
                showPrevious: true,
                nextEnabled: !formState.isLoading && documents.isNotEmpty,
                isLoading: formState.isLoading,
                nextLabel: 'Next: Referral Agent',
                onPrevious: () =>
                    ref.read(sellFormProvider.notifier).previousStep(),
                onNext: _handleNext,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DocumentTypeButton extends StatelessWidget {
  final String documentName;
  final bool isRequired;
  final bool isUploaded;
  final VoidCallback? onPressed;

  const _DocumentTypeButton({
    Key? key,
    required this.documentName,
    required this.isRequired,
    required this.isUploaded,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        side: BorderSide(
          color: isUploaded ? AppTheme.successGreen : AppTheme.primaryBlue,
        ),
        backgroundColor:
            isUploaded ? AppTheme.successGreen.withOpacity(0.05) : null,
      ),
      child: Row(
        children: [
          Icon(
            isUploaded ? Icons.check_circle : Icons.upload_file,
            color: isUploaded ? AppTheme.successGreen : AppTheme.primaryBlue,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      documentName,
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (isRequired)
                      const Text(
                        ' *',
                        style: TextStyle(
                          color: AppTheme.errorRed,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
                if (isUploaded)
                  Text(
                    'Uploaded',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppTheme.successGreen,
                        ),
                  ),
              ],
            ),
          ),
          Icon(
            isUploaded ? Icons.done : Icons.arrow_forward,
            color: isUploaded ? AppTheme.successGreen : AppTheme.primaryBlue,
            size: 18,
          ),
        ],
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  final LocalPropertyDocument document;
  final int index;
  final VoidCallback onRemove;

  const _DocumentCard({
    Key? key,
    required this.document,
    required this.index,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          _getDocumentIcon(document.documentType),
          color: AppTheme.primaryBlue,
        ),
        title: Text(document.fileName),
        subtitle: Text(
          document.documentType,
          style: Theme.of(context).textTheme.labelSmall,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.close, color: AppTheme.errorRed),
          onPressed: onRemove,
        ),
      ),
    );
  }

  IconData _getDocumentIcon(String documentType) {
    switch (documentType) {
      case 'title_deed':
        return Icons.description;
      case 'survey':
        return Icons.map;
      case 'tax_proof':
        return Icons.receipt;
      case 'approval_letter':
        return Icons.verified_user;
      default:
        return Icons.attach_file;
    }
  }
}
