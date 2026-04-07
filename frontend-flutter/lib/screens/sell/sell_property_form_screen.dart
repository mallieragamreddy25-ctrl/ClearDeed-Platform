import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'sell_provider.dart';

/// Step 1: Property Details Form Screen
/// Collects basic property information including category, title, description, location, area, price, and ownership details
class SellPropertyFormScreen extends ConsumerStatefulWidget {
  final VoidCallback? onNext;

  const SellPropertyFormScreen({
    Key? key,
    this.onNext,
  }) : super(key: key);

  @override
  ConsumerState<SellPropertyFormScreen> createState() =>
      _SellPropertyFormScreenState();
}

class _SellPropertyFormScreenState
    extends ConsumerState<SellPropertyFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late TextEditingController _cityController;
  late TextEditingController _priceController;
  late TextEditingController _areaController;

  final List<String> categories = [
    'Land',
    'Residential House',
    'Commercial Property',
    'Agriculture Land',
    'Flat/Apartment'
  ];

  final List<String> ownershipStatuses = [
    'Absolute Owner',
    'Joint Owner',
    'Power of Attorney',
    'Leasehold',
    'Inheritance (Will)',
  ];

  @override
  void initState() {
    super.initState();
    final draft = ref.read(sellFormProvider).draft;
    _titleController = TextEditingController(text: draft.title ?? '');
    _descriptionController =
        TextEditingController(text: draft.description ?? '');
    _locationController = TextEditingController(text: draft.location ?? '');
    _cityController = TextEditingController(text: draft.city ?? '');
    _priceController =
        TextEditingController(text: draft.price?.toStringAsFixed(0) ?? '');
    _areaController =
        TextEditingController(text: draft.area?.toStringAsFixed(2) ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _cityController.dispose();
    _priceController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  void _handleNext() {
    if (_formKey.currentState!.validate()) {
      final notifier = ref.read(sellFormProvider.notifier);
      notifier.setPropertyDetails(
        category: ref.read(sellFormProvider).draft.category ?? '',
        title: _titleController.text,
        description: _descriptionController.text,
        location: _locationController.text,
        city: _cityController.text,
        price: double.parse(_priceController.text),
        area: double.parse(_areaController.text),
        ownershipStatus:
            ref.read(sellFormProvider).draft.ownershipStatus ?? '',
      );
      notifier.nextStep();
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(sellFormProvider);
    final draft = formState.draft;
    final isStep1Valid = ref.watch(isStep1ValidProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sell Property'),
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
                'Property Details',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Provide basic information about your property',
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

              // Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Category
                    FormDropdownField<String>(
                      label: 'Property Category',
                      value: draft.category,
                      items: categories,
                      itemLabel: (item) => item,
                      required: true,
                      onChanged: (value) {
                        ref
                            .read(sellFormProvider.notifier)
                            .setCategory(value ?? '');
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a category';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Title
                    CustomFormField(
                      label: 'Property Title',
                      hint: 'e.g., 2BHK flat in South Delhi',
                      initialValue: draft.title,
                      required: true,
                      onChanged: (value) {
                        ref
                            .read(sellFormProvider.notifier)
                            .setTitle(value);
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Title is required';
                        }
                        if (value.length < 5) {
                          return 'Title should be at least 5 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Description
                    CustomFormField(
                      label: 'Property Description',
                      hint: 'Describe your property, amenities, condition, etc.',
                      initialValue: draft.description,
                      maxLines: 4,
                      onChanged: (value) {
                        ref
                            .read(sellFormProvider.notifier)
                            .setDescription(value);
                      },
                    ),
                    const SizedBox(height: 20),

                    // Location
                    CustomFormField(
                      label: 'Property Location/Address',
                      hint: 'Street address',
                      initialValue: draft.location,
                      required: true,
                      onChanged: (value) {
                        ref
                            .read(sellFormProvider.notifier)
                            .setLocation(value);
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Location is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // City
                    CustomFormField(
                      label: 'City',
                      hint: 'Enter city name',
                      initialValue: draft.city,
                      onChanged: (value) {
                        ref.read(sellFormProvider.notifier).setLocation(value);
                      },
                    ),
                    const SizedBox(height: 20),

                    // Price
                    CustomFormField(
                      label: 'Price (₹)',
                      hint: 'e.g., 5000000',
                      initialValue: draft.price?.toStringAsFixed(0),
                      keyboardType: TextInputType.number,
                      required: true,
                      suffixIcon: const Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: Text('₹',
                            style: TextStyle(fontSize: 16, color: AppTheme.textSecondary)),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          ref
                              .read(sellFormProvider.notifier)
                              .setPrice(double.parse(value));
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Price is required';
                        }
                        final price = double.tryParse(value);
                        if (price == null || price <= 0) {
                          return 'Please enter a valid price';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Area
                    CustomFormField(
                      label: 'Area (sqft)',
                      hint: 'e.g., 1250',
                      initialValue: draft.area?.toStringAsFixed(2),
                      keyboardType: TextInputType.number,
                      required: true,
                      suffixIcon: const Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: Text('sqft',
                            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          ref
                              .read(sellFormProvider.notifier)
                              .setArea(double.parse(value));
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Area is required';
                        }
                        final area = double.tryParse(value);
                        if (area == null || area <= 0) {
                          return 'Please enter a valid area';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Ownership Status
                    FormDropdownField<String>(
                      label: 'Ownership Status',
                      value: draft.ownershipStatus,
                      items: ownershipStatuses,
                      itemLabel: (item) => item,
                      required: true,
                      onChanged: (value) {
                        ref
                            .read(sellFormProvider.notifier)
                            .setOwnershipStatus(value ?? '');
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select ownership status';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // Action buttons
                    StepActionButtons(
                      showPrevious: false,
                      nextEnabled: !formState.isLoading,
                      isLoading: formState.isLoading,
                      nextLabel: 'Next: Add Images',
                      onNext: _handleNext,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
