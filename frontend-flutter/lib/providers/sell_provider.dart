import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../models/property_listing.dart';
import '../models/api_models.dart';
import '../services/api_service.dart';

// Sell Provider - Property Upload State
final sellProvider = StateNotifierProvider<SellNotifier, SellState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return SellNotifier(apiService);
});

class SellState {
  final bool isLoading;
  final String? error;
  final PropertyListing? currentProperty;
  final List<PropertyImage> uploadedImages;
  final List<PropertyDocument> uploadedDocuments;
  final int currentStep; // For wizard
  final bool isPhotoUploadInProgress;
  final int photoUploadProgress; // 0-100

  const SellState({
    this.isLoading = false,
    this.error,
    this.currentProperty,
    this.uploadedImages = const [],
    this.uploadedDocuments = const [],
    this.currentStep = 0,
    this.isPhotoUploadInProgress = false,
    this.photoUploadProgress = 0,
  });

  SellState copyWith({
    bool? isLoading,
    String? error,
    PropertyListing? currentProperty,
    List<PropertyImage>? uploadedImages,
    List<PropertyDocument>? uploadedDocuments,
    int? currentStep,
    bool? isPhotoUploadInProgress,
    int? photoUploadProgress,
  }) {
    return SellState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentProperty: currentProperty ?? this.currentProperty,
      uploadedImages: uploadedImages ?? this.uploadedImages,
      uploadedDocuments: uploadedDocuments ?? this.uploadedDocuments,
      currentStep: currentStep ?? this.currentStep,
      isPhotoUploadInProgress: isPhotoUploadInProgress ?? this.isPhotoUploadInProgress,
      photoUploadProgress: photoUploadProgress ?? this.photoUploadProgress,
    );
  }

  bool get canProceedToNextStep => error == null && currentProperty != null;
}

class SellNotifier extends StateNotifier<SellState> {
  final ApiService _apiService;

  SellNotifier(this._apiService) : super(const SellState());

  /// Update current property details
  void setPropertyDetails({
    required String title,
    required String description,
    required String propertyType,
    required double price,
    required double area,
    required String city,
    required double latitude,
    required double longitude,
    required List<String> amenities,
    required int bedrooms,
    required int bathrooms,
  }) {
    final property = state.currentProperty ??
        PropertyListing(
          id: '',
          title: title,
          description: description,
          propertyType: propertyType,
          price: price,
          currency: 'INR',
          area: area,
          areaUnit: 'sqft',
          bedrooms: bedrooms,
          bathrooms: bathrooms,
          city: city,
          state: '',
          postalCode: '',
          latitude: latitude,
          longitude: longitude,
          amenities: amenities,
          images: [],
          documents: [],
          status: 'submitted',
          sellerId: '',
          createdAt: DateTime.now(),
        );

    state = state.copyWith(currentProperty: property);
  }

  /// Move to next step
  void nextStep() {
    if (state.currentStep < 4) {
      state = state.copyWith(
        currentStep: state.currentStep + 1,
        error: null,
      );
    }
  }

  /// Move to previous step
  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  /// Upload property
  Future<void> uploadProperty() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final property = state.currentProperty;
      if (property == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'Property details not set',
        );
        return;
      }

      final requestData = PropertyUploadRequest(
        title: property.title,
        description: property.description,
        propertyType: property.propertyType,
        price: property.price,
        currency: property.currency,
        area: property.area,
        areaUnit: property.areaUnit,
        bedrooms: property.bedrooms,
        bathrooms: property.bathrooms,
        city: property.city,
        state: property.state,
        postalCode: property.postalCode,
        latitude: property.latitude,
        longitude: property.longitude,
        address: property.address,
        amenities: property.amenities,
      );

      final response = await _apiService.uploadProperty(requestData.toJson());

      if (response.statusCode == 200 || response.statusCode == 201) {
        state = state.copyWith(
          isLoading: false,
          currentProperty: PropertyListing.fromJson(response.data['data']),
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.data['message'] ?? 'Failed to upload property',
        );
      }
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message ?? 'Network error',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Unexpected error: $e',
      );
    }
  }

  /// Add image to upload queue
  void addImageToQueue(PropertyImage image) {
    state = state.copyWith(
      uploadedImages: [...state.uploadedImages, image],
    );
  }

  /// Upload gallery image
  Future<void> uploadGalleryImage(String propertyId, String imagePath) async {
    if (state.currentProperty?.id == null) return;

    state = state.copyWith(isPhotoUploadInProgress: true);

    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(imagePath),
      });

      final response =
          await _apiService.uploadGalleryImage(propertyId, formData);

      if (response.statusCode == 200) {
        final image = PropertyImage.fromJson(response.data['data']);
        state = state.copyWith(
          uploadedImages: [...state.uploadedImages, image],
          isPhotoUploadInProgress: false,
          photoUploadProgress: 0,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to upload image',
        isPhotoUploadInProgress: false,
      );
    }
  }

  /// Upload document
  Future<void> uploadDocument(
    String propertyId,
    String documentPath,
    String documentType,
  ) async {
    state = state.copyWith(isLoading: true);

    try {
      final formData = FormData.fromMap({
        'document': await MultipartFile.fromFile(documentPath),
        'type': documentType,
      });

      final response =
          await _apiService.uploadPropertyDocument(propertyId, formData);

      if (response.statusCode == 200) {
        final doc = PropertyDocument.fromJson(response.data['data']);
        state = state.copyWith(
          uploadedDocuments: [...state.uploadedDocuments, doc],
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to upload document',
        isLoading: false,
      );
    }
  }

  /// Reset form
  void resetForm() {
    state = const SellState();
  }
}

// Async providers for fetching my properties
final myPropertiesProvider = FutureProvider<List<PropertyListing>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  try {
    final response = await apiService.getProperties(pageSize: 100);
    if (response.statusCode == 200) {
      final data = response.data['data']['items'] as List;
      return data
          .map((p) => PropertyListing.fromJson(p as Map<String, dynamic>))
          .toList();
    }
    return [];
  } catch (e) {
    throw Exception('Failed to fetch properties');
  }
});

// Async provider for property details
final propertyDetailsProvider =
    FutureProvider.family<PropertyListing, String>((ref, propertyId) async {
  final apiService = ref.watch(apiServiceProvider);
  try {
    final response = await apiService.getPropertyById(propertyId);
    if (response.statusCode == 200) {
      return PropertyListing.fromJson(response.data['data']);
    }
    throw Exception('Failed to fetch property');
  } catch (e) {
    throw Exception('Failed to fetch property details');
  }
});
