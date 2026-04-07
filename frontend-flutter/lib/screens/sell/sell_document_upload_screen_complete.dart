import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'sell_screen_provider.dart';

/// Step 3: Document Upload Screen
/// Allows uploading property documents (title deed, survey, tax proof, approval letter)
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
  final List<Map<String, dynamic>> documentTypes = [
    {'id': 'title_deed', 'name': 'Title Deed', 'required': true},
    {'id': 'survey_report', 'name': 'Survey Report', 'required': false},
    {'id': 'tax_proof', 'name': 'Tax/Municipal Proof', 'required': false},
    {
      'id': 'approval_letter',
      'name': 'Approval Letter',
      'required': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final formData = ref.watch(formDataProvider);
    final error = ref.watch(sellScreenProvider).error;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Documents'),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step indicator
            _buildStepIndicator(3, theme),
            const SizedBox(height: 32),

            // Title
            Text(
              'Upload Documents',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Upload required property documents (PDF format)',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),

            // Important banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue[600], size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Title Deed is mandatory. Others are optional.',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontSize: 13,
                      ),
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
              const SizedBox(height: 16),
            ],

            // Document list
            Column(
              children: documentTypes.map((docType) {
                final docId = docType['id'] as String;
                final docName = docType['name'] as String;
                final isRequired = docType['required'] as bool;
                final uploadedDoc = formData.documents[docId];

                return Column(
                  children: [
                    _buildDocumentCard(
                      docId: docId,
                      docName: docName,
                      isRequired: isRequired,
                      isUploaded: uploadedDoc != null,
                      uploadedFileName: uploadedDoc?.fileName,
                      onUpload: () => _handleDocumentUpload(context, docId),
                      onDelete: uploadedDoc != null
                          ? () {
                              ref
                                  .read(sellScreenProvider.notifier)
                                  .removeDocument(docId);
                            }
                          : null,
                    ),
                    const SizedBox(height: 12),
                  ],
                );
              }).toList(),
            ),

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
                    onPressed: formData.isStep3Valid()
                        ? () {
                            ref.read(sellScreenProvider.notifier).nextStep();
                            widget.onNext?.call();
                          }
                        : null,
                    child: const Text('Next'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentCard({
    required String docId,
    required String docName,
    required bool isRequired,
    required bool isUploaded,
    required String? uploadedFileName,
    required VoidCallback onUpload,
    required VoidCallback? onDelete,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: isUploaded ? Colors.green[300]! : Colors.grey[300]!,
        ),
        borderRadius: BorderRadius.circular(8),
        color: isUploaded ? Colors.green[50] : Colors.transparent,
      ),
      child: Row(
        children: [
          // Document icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isUploaded ? Colors.green[100] : Colors.grey[200],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              isUploaded ? Icons.check_circle : Icons.description,
              color: isUploaded ? Colors.green[600] : Colors.grey[600],
              size: 24,
            ),
          ),
          const SizedBox(width: 12),

          // Document info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      docName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    if (isRequired)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red[200],
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          'Required',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.red[800],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          'Optional',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                if (isUploaded)
                  Text(
                    uploadedFileName ?? 'Document uploaded',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green[700],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                else
                  Text(
                    'No file uploaded',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),

          // Action buttons
          if (!isUploaded)
            SizedBox(
              width: 100,
              child: FilledButton.tonal(
                onPressed: onUpload,
                child: const Text('Upload'),
              ),
            )
          else
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Colors.green[600], size: 20),
                const SizedBox(width: 8),
                if (onDelete != null)
                  GestureDetector(
                    onTap: onDelete,
                    child: Icon(
                      Icons.close,
                      color: Colors.red[600],
                      size: 20,
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  void _handleDocumentUpload(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Upload Document'),
          content: const Text(
            'Choose file source for document upload.\n\nNote: Document picker integration required - use file_picker package.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('File picker integration required'),
                  ),
                );
              },
              child: const Text('Choose File'),
            ),
          ],
        );
      },
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
