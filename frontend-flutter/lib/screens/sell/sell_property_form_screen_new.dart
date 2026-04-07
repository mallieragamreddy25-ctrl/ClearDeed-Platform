import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'sell_screen_provider.dart';

/// Step 1: Property Details Form Screen
/// Collects property category, title, description, location, area, price, and ownership information
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
  late TextEditingController _cityController;
  late TextEditingController _localityController;
  late TextEditingController _areaController;
  late TextEditingController _priceController;

  final List<String> categories = [
    'Land',
    'Residential House',
    'Commercial Property',
    'Agriculture Land',
    'Flat/Apartment',
  ];

  final List<String> ownershipTypes = [
    'Freehold',
    'Leasehold',
    'Joint Ownership',
    'Power of Attorney',
  ];

  final List<String> availabilityOptions = [
    'Available',
    'Sold',
    'Off-Market',
  ];

  @override
  void initState() {
    super.initState();
    final formData = ref.read(formDataProvider);
    _titleController = TextEditingController(text: formData.title ?? '');
    _descriptionController =
        TextEditingController(text: formData.description ?? '');
    _cityController = TextEditingController(text: formData.city ?? '');
    _localityController = TextEditingController(text: formData.locality ?? '');
    _areaController = TextEditingController(text: formData.area ?? '');
    _priceController = TextEditingController(text: formData.price ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _cityController.dispose();
    _localityController.dispose();
    _areaController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _handleNext() {
    if (_formKey.currentState!.validate()) {
      ref.read(sellScreenProvider.notifier).updatePropertyDetails(
            category: ref.read(formDataProvider).category,
            title: _titleController.text,
            description: _descriptionController.text,
            city: _cityController.text,
            locality: _localityController.text,
            area: _areaController.text,
            price: _priceController.text,
            ownershipType: ref.read(formDataProvider).ownershipType,
            availabilityStatus: ref.read(formDataProvider).availabilityStatus,
          );
      ref.read(sellScreenProvider.notifier).nextStep();
      widget.onNext?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final formData = ref.watch(formDataProvider);
    final error = ref.watch(sellScreenProvider).error;
    final theme = Theme.of(context);

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
              _buildStepIndicator(1, theme),
              const SizedBox(height: 32),

              // Title
              Text(
                'Property Details',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Provide basic information about your property',
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

              // Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Category dropdown
                    _buildDropdownField(
                      label: 'Property Category *',
                      value: formData.category,
                      items: categories,
                      onChanged: (value) {
                        ref.read(sellScreenProvider.notifier).updatePropertyDetails(
                              category: value,
                            );
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
                    _buildTextField(
                      label: 'Property Title *',
                      hint: 'e.g., 2BHK House in South Delhi',
                      controller: _titleController,
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Title is required';
                        }
                        if (value.length < 5) {
                          return 'Title must be at least 5 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Description
                    _buildTextField(
                      label: 'Description',
                      hint: 'Describe the property, amenities, condition, etc.',
                      controller: _descriptionController,
                      maxLines: 4,
                    ),
                    const SizedBox(height: 20),

                    // City
                    _buildTextField(
                      label: 'City *',
                      hint: 'Enter city name',
                      controller: _cityController,
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'City is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Locality
                    _buildTextField(
                      label: 'Locality/Area',
                      hint: 'e.g., Sector 15, DLF',
                      controller: _localityController,
                    ),
                    const SizedBox(height: 20),

                    // Area (sqft)
                    _buildTextField(
                      label: 'Area (sqft) *',
                      hint: 'e.g., 1500',
                      controller: _areaController,
                      keyboardType: TextInputType.number,
                      suffix: 'sqft',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Area is required';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Price
                    _buildTextField(
                      label: 'Price (₹) *',
                      hint: 'e.g., 5000000',
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      prefix: '₹',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Price is required';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid price';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Ownership Type
                    _buildDropdownField(
                      label: 'Ownership Type *',
                      value: formData.ownershipType,
                      items: ownershipTypes,
                      onChanged: (value) {
                        ref.read(sellScreenProvider.notifier).updatePropertyDetails(
                              ownershipType: value,
                            );
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select ownership type';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Availability Status
                    _buildDropdownField(
                      label: 'Availability Status',
                      value: formData.availabilityStatus ?? 'Available',
                      items: availabilityOptions,
                      onChanged: (value) {
                        ref.read(sellScreenProvider.notifier).updatePropertyDetails(
                              availabilityStatus: value,
                            );
                      },
                    ),
                    const SizedBox(height: 32),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              ref.read(sellScreenProvider.notifier).clearError();
                            },
                            child: const Text('Save Draft'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: _handleNext,
                            child: const Text('Next'),
                          ),
                        ),
                      ],
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

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    String? prefix,
    String? suffix,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          minLines: maxLines == 1 ? 1 : maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixText: prefix,
            suffixText: suffix,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: onChanged,
          validator: validator,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }
}
