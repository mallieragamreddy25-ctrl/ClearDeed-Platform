import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';
import '../../providers/property_provider.dart';

/// Property filter modal for advanced filtering
class PropertyFilterScreen extends StatefulWidget {
  final PropertyFilter currentFilter;
  final Function(PropertyFilter) onApply;

  const PropertyFilterScreen({
    Key? key,
    required this.currentFilter,
    required this.onApply,
  }) : super(key: key);

  @override
  State<PropertyFilterScreen> createState() => _PropertyFilterScreenState();
}

class _PropertyFilterScreenState extends State<PropertyFilterScreen> {
  late TextEditingController _minPriceController;
  late TextEditingController _maxPriceController;
  
  String? _selectedCategory;
  String? _selectedCity;
  List<String> _selectedCities = [];
  double? _minPrice;
  double? _maxPrice;
  String? _selectedSort;

  // Sample cities - in production, this would come from API
  static const List<String> cities = [
    'New Delhi',
    'Mumbai',
    'Bangalore',
    'Hyderabad',
    'Pune',
    'Kolkata',
    'Chennai',
    'Ahmedabad',
    'Jaipur',
    'Gurugram',
    'Noida',
    'Ghaziabad',
  ];

  static const List<String> sortOptions = [
    'Newest',
    'Price: Low to High',
    'Price: High to Low',
    'Area: Small to Large',
    'Area: Large to Small',
  ];

  @override
  void initState() {
    super.initState();
    _minPriceController = TextEditingController(
      text: widget.currentFilter.minPrice?.toStringAsFixed(0) ?? '',
    );
    _maxPriceController = TextEditingController(
      text: widget.currentFilter.maxPrice?.toStringAsFixed(0) ?? '',
    );
    _selectedCategory = widget.currentFilter.category;
    _selectedCity = widget.currentFilter.city;
    if (widget.currentFilter.city != null) {
      _selectedCities = [widget.currentFilter.city!];
    }
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    _minPrice = _minPriceController.text.isEmpty
        ? null
        : double.tryParse(_minPriceController.text);
    _maxPrice = _maxPriceController.text.isEmpty
        ? null
        : double.tryParse(_maxPriceController.text);

    final filter = PropertyFilter(
      category: _selectedCategory,
      city: _selectedCity,
      minPrice: _minPrice,
      maxPrice: _maxPrice,
      page: 1,
    );

    widget.onApply(filter);
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = null;
      _selectedCity = null;
      _selectedCities.clear();
      _minPriceController.clear();
      _maxPriceController.clear();
      _minPrice = null;
      _maxPrice = null;
      _selectedSort = null;
    });

    widget.onApply(const PropertyFilter(page: 1));
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppTheme.textHint,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Filter Properties',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Category Section
                    Text(
                      'Category',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: AppConstants.propertyCategories.map((category) {
                        final isSelected = _selectedCategory == category;
                        return FilterChip(
                          selected: isSelected,
                          label: Text(category),
                          onSelected: (value) {
                            setState(() {
                              _selectedCategory =
                                  isSelected ? null : category;
                            });
                          },
                          backgroundColor: AppTheme.white,
                          selectedColor: AppTheme.primaryBlue,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? AppTheme.white
                                : AppTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                          side: BorderSide(
                            color: isSelected
                                ? AppTheme.primaryBlue
                                : AppTheme.borderGrey,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // City Section
                    Text(
                      'City',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: cities.map((city) {
                        final isSelected = _selectedCity == city;
                        return FilterChip(
                          selected: isSelected,
                          label: Text(city),
                          onSelected: (value) {
                            setState(() {
                              _selectedCity = isSelected ? null : city;
                            });
                          },
                          backgroundColor: AppTheme.white,
                          selectedColor: AppTheme.primaryBlue,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? AppTheme.white
                                : AppTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                          side: BorderSide(
                            color: isSelected
                                ? AppTheme.primaryBlue
                                : AppTheme.borderGrey,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Price Range Section
                    Text(
                      'Price Range (₹)',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _minPriceController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'Min Price',
                              hintStyle:
                                  const TextStyle(color: AppTheme.textHint),
                              prefixIcon: const Icon(Icons.currency_rupee,
                                  size: 16, color: AppTheme.textSecondary),
                              filled: true,
                              fillColor: AppTheme.lightGrey,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {});
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _maxPriceController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'Max Price',
                              hintStyle:
                                  const TextStyle(color: AppTheme.textHint),
                              prefixIcon: const Icon(Icons.currency_rupee,
                                  size: 16, color: AppTheme.textSecondary),
                              filled: true,
                              fillColor: AppTheme.lightGrey,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {});
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Sort Section
                    Text(
                      'Sort By',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.borderGrey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton<String>(
                        value: _selectedSort,
                        underline: const SizedBox.shrink(),
                        isExpanded: true,
                        hint: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text('Select sort option'),
                        ),
                        items: sortOptions.map((option) {
                          return DropdownMenuItem(
                            value: option,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(option),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedSort = value);
                        },
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _clearFilters,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: const BorderSide(color: AppTheme.textHint),
                            ),
                            child: const Text('Clear All'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _applyFilters,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Apply Filters'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

