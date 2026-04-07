import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/property.dart';
import '../services/api_client.dart';
import '../services/property_service.dart';
import '../services/storage_service.dart';
import '../utils/app_logger.dart';

// ==================== Property Filter State ====================

class PropertyFilter {
  final String? category;
  final String? city;
  final double? minPrice;
  final double? maxPrice;
  final String? searchQuery;
  final int page;

  const PropertyFilter({
    this.category,
    this.city,
    this.minPrice,
    this.maxPrice,
    this.searchQuery,
    this.page = 1,
  });

  PropertyFilter copyWith({
    String? category,
    String? city,
    double? minPrice,
    double? maxPrice,
    String? searchQuery,
    int? page,
  }) {
    return PropertyFilter(
      category: category ?? this.category,
      city: city ?? this.city,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      searchQuery: searchQuery ?? this.searchQuery,
      page: page ?? this.page,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (category != null) 'category': category,
      if (city != null) 'city': city,
      if (minPrice != null) 'minPrice': minPrice,
      if (maxPrice != null) 'maxPrice': maxPrice,
      if (searchQuery != null) 'searchQuery': searchQuery,
      'page': page,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PropertyFilter &&
          runtimeType == other.runtimeType &&
          category == other.category &&
          city == other.city &&
          minPrice == other.minPrice &&
          maxPrice == other.maxPrice &&
          searchQuery == other.searchQuery &&
          page == other.page;

  @override
  int get hashCode =>
      category.hashCode ^
      city.hashCode ^
      minPrice.hashCode ^
      maxPrice.hashCode ^
      searchQuery.hashCode ^
      page.hashCode;
}

// ==================== Property State ====================

class PropertyListState {
  final List<Property> properties;
  final bool isLoading;
  final bool hasMore;
  final String? error;
  final PropertyFilter filter;

  const PropertyListState({
    this.properties = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.error,
    this.filter = const PropertyFilter(),
  });

  PropertyListState copyWith({
    List<Property>? properties,
    bool? isLoading,
    bool? hasMore,
    String? error,
    PropertyFilter? filter,
  }) {
    return PropertyListState(
      properties: properties ?? this.properties,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      error: error ?? this.error,
      filter: filter ?? this.filter,
    );
  }
}

// Individual property detail state
class PropertyDetailState {
  final PropertyDetail? property;
  final bool isLoading;
  final String? error;
  final bool isFavorite;
  final bool hasExpressedInterest;

  const PropertyDetailState({
    this.property,
    this.isLoading = false,
    this.error,
    this.isFavorite = false,
    this.hasExpressedInterest = false,
  });

  PropertyDetailState copyWith({
    PropertyDetail? property,
    bool? isLoading,
    String? error,
    bool? isFavorite,
    bool? hasExpressedInterest,
  }) {
    return PropertyDetailState(
      property: property ?? this.property,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isFavorite: isFavorite ?? this.isFavorite,
      hasExpressedInterest: hasExpressedInterest ?? this.hasExpressedInterest,
    );
  }
}

// ==================== Property Service Provider ====================

final propertyServiceProvider = Provider<PropertyService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PropertyService(apiClient: apiClient);
});

// ==================== Property List Notifier ====================

class PropertyListNotifier extends StateNotifier<PropertyListState> {
  final PropertyService _propertyService;

  PropertyListNotifier(this._propertyService)
      : super(const PropertyListState());

  /// Load properties with current filter
  Future<void> loadProperties() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final properties = await _propertyService.getProperties(
        page: state.filter.page,
        category: state.filter.category,
        city: state.filter.city,
        minPrice: state.filter.minPrice,
        maxPrice: state.filter.maxPrice,
        searchQuery: state.filter.searchQuery,
      );

      state = state.copyWith(
        isLoading: false,
        properties: properties,
        hasMore: properties.length >= 20, // Assuming page size is 20
      );

      AppLogger.debug('Loaded ${properties.length} properties');
    } catch (e) {
      AppLogger.error('Failed to load properties: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Load next page of properties
  Future<void> loadNextPage() async {
    if (!state.hasMore || state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final properties = await _propertyService.getProperties(
        page: state.filter.page + 1,
        category: state.filter.category,
        city: state.filter.city,
        minPrice: state.filter.minPrice,
        maxPrice: state.filter.maxPrice,
        searchQuery: state.filter.searchQuery,
      );

      final updatedProperties = [...state.properties, ...properties];

      state = state.copyWith(
        isLoading: false,
        properties: updatedProperties,
        filter: state.filter.copyWith(page: state.filter.page + 1),
        hasMore: properties.length >= 20,
      );

      AppLogger.debug('Loaded next page with ${properties.length} properties');
    } catch (e) {
      AppLogger.error('Failed to load next page: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Update filter and reload
  Future<void> updateFilter(PropertyFilter filter) async {
    state = state.copyWith(filter: filter.copyWith(page: 1));
    await loadProperties();
  }

  /// Set category filter
  Future<void> setCategory(String? category) async {
    final newFilter = state.filter.copyWith(category: category, page: 1);
    await updateFilter(newFilter);
  }

  /// Set city filter
  Future<void> setCity(String? city) async {
    final newFilter = state.filter.copyWith(city: city, page: 1);
    await updateFilter(newFilter);
  }

  /// Set price range filter
  Future<void> setPriceRange(double? minPrice, double? maxPrice) async {
    final newFilter = state.filter.copyWith(
      minPrice: minPrice,
      maxPrice: maxPrice,
      page: 1,
    );
    await updateFilter(newFilter);
  }

  /// Search properties
  Future<void> search(String query) async {
    if (query.isEmpty) {
      // Clear search
      final newFilter = state.filter.copyWith(searchQuery: null, page: 1);
      await updateFilter(newFilter);
    } else {
      final newFilter = state.filter.copyWith(searchQuery: query, page: 1);
      await updateFilter(newFilter);
    }
  }

  /// Clear all filters
  Future<void> clearFilters() async {
    await updateFilter(const PropertyFilter());
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// ==================== Property Detail Notifier ====================

class PropertyDetailNotifier extends StateNotifier<PropertyDetailState> {
  final PropertyService _propertyService;

  PropertyDetailNotifier(this._propertyService)
      : super(const PropertyDetailState());

  /// Load property details
  Future<void> loadPropertyDetail(int propertyId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final property = await _propertyService.getPropertyDetail(propertyId);
      final isFavorite = StorageService.isFavorited(propertyId);
      final hasInterest =
          await _propertyService.hasExpressedInterest(propertyId);

      state = state.copyWith(
        isLoading: false,
        property: property,
        isFavorite: isFavorite,
        hasExpressedInterest: hasInterest,
      );

      AppLogger.debug('Loaded property detail: ${property.title}');
    } catch (e) {
      AppLogger.error('Failed to load property detail: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Toggle favorite status
  Future<void> toggleFavorite() async {
    if (state.property == null) return;

    try {
      if (state.isFavorite) {
        await StorageService.removeFavoriteProperty(state.property!.id);
      } else {
        await StorageService.addFavoriteProperty(state.property!.id);
      }

      state = state.copyWith(isFavorite: !state.isFavorite);
      AppLogger.debug(
        'Property ${state.isFavorite ? 'added to' : 'removed from'} favorites',
      );
    } catch (e) {
      AppLogger.error('Failed to toggle favorite: $e');
    }
  }

  /// Express interest in property
  Future<bool> expressInterest() async {
    if (state.property == null) return false;

    state = state.copyWith(isLoading: true);
    try {
      final success =
          await _propertyService.expressInterest(state.property!.id);
      state = state.copyWith(
        isLoading: false,
        hasExpressedInterest: true,
      );
      AppLogger.debug('Interest expressed for property ${state.property!.id}');
      return true;
    } catch (e) {
      AppLogger.error('Failed to express interest: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// ==================== Providers ====================

/// Property list provider
final propertyListProvider =
    StateNotifierProvider<PropertyListNotifier, PropertyListState>((ref) {
  final propertyService = ref.watch(propertyServiceProvider);
  return PropertyListNotifier(propertyService);
});

/// Featured properties provider
final featuredPropertiesProvider = FutureProvider<List<Property>>((ref) async {
  final propertyService = ref.watch(propertyServiceProvider);
  try {
    return await propertyService.getFeaturedProperties();
  } catch (e) {
    AppLogger.error('Failed to load featured properties: $e');
    return [];
  }
});

/// Property detail provider with ID parameter
final propertyDetailProvider =
    StateNotifierProvider.family<PropertyDetailNotifier, PropertyDetailState, int>(
  (ref, propertyId) {
    final propertyService = ref.watch(propertyServiceProvider);
    return PropertyDetailNotifier(propertyService);
  },
);

/// Favorite property IDs provider
final favoritePropertyIdsProvider = Provider<List<int>>((ref) {
  return StorageService.getFavoritePropertyIds();
});

/// Search properties provider
final searchPropertiesProvider =
    FutureProvider.family<List<Property>, String>((ref, query) async {
  final propertyService = ref.watch(propertyServiceProvider);
  if (query.isEmpty) return [];
  try {
    return await propertyService.searchProperties(query);
  } catch (e) {
    AppLogger.error('Search failed: $e');
    return [];
  }
});
