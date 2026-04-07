import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../../../theme/app_theme.dart';
import '../models/sell_form_model.dart';
import '../providers/sell_form_provider.dart';
import '../widgets/sell_form_widgets.dart';

class SellImageUploadScreen extends ConsumerStatefulWidget {
  const SellImageUploadScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SellImageUploadScreen> createState() =>
      _SellImageUploadScreenState();
}

class _SellImageUploadScreenState
    extends ConsumerState<SellImageUploadScreen> {
  late ImagePicker _imagePicker;
  int? _reorderingIndex;

  @override
  void initState() {
    super.initState();
    _imagePicker = ImagePicker();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final croppedFile = await _cropImage(File(pickedFile.path));
        if (croppedFile != null && mounted) {
          ref.read(sellFormProvider.notifier).addImage(croppedFile);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<File?> _cropImage(File imageFile) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 85,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: AppTheme.primaryBlue,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: false,
            showBottomControls: true,
          ),
          IOSUiSettings(
            title: 'Crop Image',
            minimumAspectRatio: 1.0,
            aspectRatioPickerButtonHidden: false,
            resetButtonHidden: false,
          ),
        ],
      );

      if (croppedFile != null) {
        return File(croppedFile.path);
      }
    } catch (e) {
      print('Error cropping image: $e');
    }
    return null;
  }

  void _handleNext() async {
    final notifier = ref.read(sellFormProvider.notifier);
    final images = ref.read(sellFormProvider).localImages;

    if (images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one image')),
      );
      return;
    }

    // In a real app, you would upload images here
    // For now, we'll use placeholder URLs
    final imageUrls = images
        .map((img) => 'file://${img.file.path}')
        .toList();

    notifier.commitImageUrls(imageUrls);
    notifier.nextStep();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(sellFormProvider);
    final images = formState.localImages;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Images'),
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
                'Add Property Images',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Upload high-quality photos of your property (minimum 3, maximum 10)',
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

              // Image count
              if (images.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.infoBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppTheme.infoBlue),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: AppTheme.infoBlue, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        '${images.length} image(s) added. You can add up to 10 images.',
                        style: const TextStyle(
                          color: AppTheme.infoBlue,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              if (images.isNotEmpty) const SizedBox(height: 24),

              // Add image buttons
              if (images.length < 10)
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                _pickImage(ImageSource.camera),
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('Take Photo'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                _pickImage(ImageSource.gallery),
                            icon: const Icon(Icons.image),
                            label: const Text('Choose Photo'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),

              // Image gallery - reorderable
              if (images.isNotEmpty)
                Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          'Your Images',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        Icon(Icons.drag_handle,
                            size: 16, color: AppTheme.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          'Drag to reorder',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ReorderableListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      onReorder: (oldIndex, newIndex) {
                        ref
                            .read(sellFormProvider.notifier)
                            .reorderImages(oldIndex, newIndex);
                      },
                      itemCount: images.length,
                      itemBuilder: (context, index) {
                        final image = images[index];
                        return _ImageCard(
                          key: ValueKey(image.file.path + index.toString()),
                          image: image,
                          index: index,
                          onRemove: () => ref
                              .read(sellFormProvider.notifier)
                              .removeImage(index),
                          onTitleChanged: (title) => ref
                              .read(sellFormProvider.notifier)
                              .updateImageTitle(index, title),
                        );
                      },
                    ),
                  ],
                ),

              const SizedBox(height: 32),

              // Action buttons
              StepActionButtons(
                showPrevious: true,
                nextEnabled: !formState.isLoading && images.isNotEmpty,
                isLoading: formState.isLoading,
                nextLabel: 'Next: Add Documents',
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

class _ImageCard extends ConsumerWidget {
  final LocalPropertyImage image;
  final int index;
  final VoidCallback onRemove;
  final Function(String) onTitleChanged;

  const _ImageCard({
    Key? key,
    required this.image,
    required this.index,
    required this.onRemove,
    required this.onTitleChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: ReorderableDragStartListener(
          index: index,
          child: MouseRegion(
            cursor: SystemMouseCursors.grab,
            child: Icon(Icons.drag_handle, color: AppTheme.textSecondary),
          ),
        ),
        title: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.file(
            image.file,
            height: 120,
            width: 80,
            fit: BoxFit.cover,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            TextFormField(
              initialValue:
                  image.title ?? 'Image ${index + 1}',
              decoration: InputDecoration(
                hintText: 'Add title (optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              ),
              onChanged: onTitleChanged,
            ),
            const SizedBox(height: 8),
            if (image.isUploading)
              LinearProgressIndicator(value: image.uploadProgress)
            else
              const SizedBox.shrink(),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.close, color: AppTheme.errorRed),
          onPressed: onRemove,
        ),
      ),
    );
  }
}
