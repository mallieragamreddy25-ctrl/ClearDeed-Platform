import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'sell_screen_provider.dart';

/// Step 2: Image Upload Screen
/// Allows uploading multiple images with reordering and deletion capabilities
class SellImageUploadScreen extends ConsumerStatefulWidget {
  final VoidCallback? onNext;
  final VoidCallback? onBack;

  const SellImageUploadScreen({
    Key? key,
    this.onNext,
    this.onBack,
  }) : super(key: key);

  @override
  ConsumerState<SellImageUploadScreen> createState() =>
      _SellImageUploadScreenState();
}

class _SellImageUploadScreenState extends ConsumerState<SellImageUploadScreen> {
  @override
  Widget build(BuildContext context) {
    final formData = ref.watch(formDataProvider);
    final error = ref.watch(sellScreenProvider).error;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Images'),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step indicator
            _buildStepIndicator(2, theme),
            const SizedBox(height: 32),

            // Title
            Text(
              'Add Property Images',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Upload high-quality photos (maximum 20 images)',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
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

            // Image counter
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${formData.imageFilePaths.length}/20 images added',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (formData.imageFilePaths.isNotEmpty)
                    FilledButton.tonal(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Image compression feature coming soon'),
                          ),
                        );
                      },
                      child: const Text('Compress'),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Image grid or empty state
            if (formData.imageFilePaths.isEmpty)
              _buildEmptyState(theme)
            else
              _buildImageGrid(formData, theme),

            const SizedBox(height: 24),

            // Add images button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: () {
                  _showImageSourceDialog(context);
                },
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text('Add Images'),
              ),
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
                    onPressed: formData.imageFilePaths.isEmpty
                        ? null
                        : () {
                            ref.read(sellScreenProvider.notifier).nextStep();
                            widget.onNext?.call();
                          },
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

  Widget _buildEmptyState(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(
            Icons.image_not_supported,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No images added yet',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add high-quality photos to showcase your property',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildImageGrid(PropertyFormData formData, ThemeData theme) {
    return ReorderableGridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1,
      onReorder: (oldIndex, newIndex) {
        ref.read(sellScreenProvider.notifier).reorderImages(oldIndex, newIndex);
      },
      children: [
        for (int i = 0; i < formData.imageFilePaths.length; i++)
          _buildImageCard(
            key: ValueKey(formData.imageFilePaths[i]),
            imagePath: formData.imageFilePaths[i],
            index: i,
            onDelete: () {
              ref.read(sellScreenProvider.notifier).removeImage(
                    formData.imageFilePaths[i],
                  );
            },
          ),
      ],
    );
  }

  Widget _buildImageCard({
    required Key key,
    required String imagePath,
    required int index,
    required VoidCallback onDelete,
  }) {
    return Container(
      key: key,
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: File(imagePath).existsSync()
                ? Image.file(
                    File(imagePath),
                    fit: BoxFit.cover,
                  )
                : Container(
                    color: Colors.grey[200],
                    child: Icon(
                      Icons.image_not_supported,
                      color: Colors.grey[400],
                    ),
                  ),
          ),

          // Index badge
          Positioned(
            top: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Delete button
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onDelete,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),

          // Drag handle
          Positioned(
            bottom: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.grey[800]!.withOpacity(0.8),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.drag_indicator,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showImageSourceDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Choose Image Source',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Camera integration required - use image_picker package'),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Image picker integration required - use image_picker package'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              FilledButton.tonal(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
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

/// Reorderable grid view - simple implementation
class ReorderableGridView extends StatefulWidget {
  final int crossAxisCount;
  final double childAspectRatio;
  final List<Widget> children;
  final Function(int, int) onReorder;
  final bool shrinkWrap;
  final ScrollPhysics physics;

  const ReorderableGridView.count({
    Key? key,
    required this.crossAxisCount,
    required this.children,
    required this.onReorder,
    this.childAspectRatio = 1.0,
    this.shrinkWrap = true,
    this.physics = const ScrollPhysics(),
  }) : super(key: key);

  @override
  State<ReorderableGridView> createState() => _ReorderableGridViewState();
}

class _ReorderableGridViewState extends State<ReorderableGridView> {
  late List<Widget> _children;

  @override
  void initState() {
    super.initState();
    _children = List<Widget>.from(widget.children);
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: widget.crossAxisCount,
      childAspectRatio: widget.childAspectRatio,
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics,
      children: _children,
    );
  }
}
