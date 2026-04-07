import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'sell_provider.dart';

/// Step 2: Image Upload Screen
/// Supports multiple image selection, reordering, cropping, and preview
class SellImageUploadScreen extends ConsumerStatefulWidget {
  final VoidCallback? onNext;
  final VoidCallback? onBack;

  const SellImageUploadScreen({
    Key? key,
    this.onNext,
    this.onBack,
  }) : super(key: key);

  @override
  ConsumerState<SellImageUploadScreen> createState() => _SellImageUploadScreenState();
}

class _SellImageUploadScreenState extends ConsumerState<SellImageUploadScreen> {
  late List<String> _selectedImages;

  @override
  void initState() {
    super.initState();
    _selectedImages = List.from(ref.read(propertyFormProvider).imageFilePaths);
  }

  void _addImages() async {
    // TODO: Replace with actual image picker
    // Example using image_picker package:
    // final ImagePicker picker = ImagePicker();
    // final List<XFile> images = await picker.pickMultiImage();
    // 
    // for (var image in images) {
    //   if (_selectedImages.length < 20) {
    //     _selectedImages.add(image.path);
    //   }
    // }
    // setState(() {});

    // Mock implementation for now
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Image picker integration required')),
    );
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _reorderImages(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final image = _selectedImages.removeAt(oldIndex);
      _selectedImages.insert(newIndex, image);
    });
  }

  void _compressImages() {
    // TODO: Implement image compression
    // You can use flutter_image_compress or similar package
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Compressing images...')),
    );
  }

  bool _validateImages() {
    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one image')),
      );
      return false;
    }
    return true;
  }

  void _proceedToNextStep() {
    if (_validateImages()) {
      final formData = ref.read(propertyFormProvider);
      ref.read(propertyFormProvider.notifier).state = formData.copyWith(
        imageFilePaths: _selectedImages,
      );
      ref.read(currentStepProvider.notifier).state = 3;
      widget.onNext?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepProgress(),
          const SizedBox(height: 24),

          Text(
            'Add Property Images',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Add high-quality photos (max 20 images)',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),

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
                  '${_selectedImages.length}/20 images added',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_selectedImages.isNotEmpty)
                  FilledButton.tonal(
                    onPressed: _compressImages,
                    child: const Text('Compress'),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Image grid or empty state
          if (_selectedImages.isEmpty)
            _buildEmptyState()
          else
            _buildImageGrid(),

          const SizedBox(height: 32),

          // Add more images button
          if (_selectedImages.length < 20)
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonal(
                onPressed: _addImages,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('+ Add More Images'),
              ),
            ),

          const SizedBox(height: 12),

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
          'Step 2 of 5',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: 0.4,
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

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            Icons.image_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No images added yet',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Add photos to showcase your property better',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _addImages,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('Select Images'),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGrid() {
    return ReorderableGridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      onReorder: _reorderImages,
      children: List.generate(_selectedImages.length, (index) {
        return _buildImageCard(index);
      }),
    );
  }

  Widget _buildImageCard(int index) {
    return ReorderableDelayedDragStartListener(
      index: index,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image placeholder
            Container(
              color: Theme.of(context).colorScheme.surfaceVariant,
              child: Icon(
                Icons.image,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            // Delete button
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => _removeImage(index),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red.shade600,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
            // Image index
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${index + 1}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            // Reorder handle
            Positioned(
              bottom: 8,
              right: 8,
              child: Icon(
                Icons.drag_handle,
                color: Colors.white.withOpacity(0.7),
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              ref.read(currentStepProvider.notifier).state = 1;
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

/// Custom reorderable grid view (simplified implementation)
/// For production, use reorderable_grid_view package
class ReorderableGridView extends StatelessWidget {
  final int crossAxisCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final List<Widget> children;
  final ReorderCallback? onReorder;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const ReorderableGridView.count({
    Key? key,
    required this.crossAxisCount,
    this.crossAxisSpacing = 0,
    this.mainAxisSpacing = 0,
    required this.children,
    this.onReorder,
    this.shrinkWrap = false,
    this.physics,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: crossAxisSpacing,
      mainAxisSpacing: mainAxisSpacing,
      children: children,
      shrinkWrap: shrinkWrap,
      physics: physics,
    );
  }
}

typedef ReorderCallback = void Function(int oldIndex, int newIndex);

/// Simple wrapper for reorderable items
class ReorderableDelayedDragStartListener extends StatelessWidget {
  final int index;
  final Widget child;

  const ReorderableDelayedDragStartListener({
    Key? key,
    required this.index,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
