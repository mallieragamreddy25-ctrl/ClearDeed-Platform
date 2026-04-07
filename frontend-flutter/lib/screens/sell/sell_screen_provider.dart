import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:hive/hive.dart';

// ===============================
// MODELS
// ===============================

/// Property form data across all steps
class PropertyFormData {
  // Step 1: Property Details
  String? category;
  String? title;
  String? description;
  String? city;
  String? locality;
  String? area;
  String? price;
  String? ownershipType;
  String? availabilityStatus;

  // Step 2: Images
  List<String> imageFilePaths = [];

  // Step 3: Documents
  Map<String, DocumentInfo> documents = {};

  // Step 4: Referral
  String? agentMobileNumber;
  String? agentName;
  bool agentVerified = false;

  // Metadata
  DateTime? createdAt;
  DateTime? updatedAt;
  String? propertyId;

  PropertyFormData({
    this.category,
    this.title,
    this.description,
    this.city,
    this.locality,
    this.area,
    this.price,
    this.ownershipType,
    this.availabilityStatus,
    this.agentMobileNumber,
    this.agentName,
  }) {
    createdAt = DateTime.now();
    updatedAt = DateTime.now();
  }

  /// Check if Step 1 is valid
  bool isStep1Valid() {
    return (category?.isNotEmpty ?? false) &&
        (title?.isNotEmpty ?? false) &&
        (title ?? '').length >= 5 &&
        (description?.isNotEmpty ?? false) &&
        (city?.isNotEmpty ?? false) &&
        (price?.isNotEmpty ?? false) &&
        (area?.isNotEmpty ?? false) &&
        (ownershipType?.isNotEmpty ?? false);
  }

  /// Check if Step 2 is valid
  bool isStep2Valid() {
    return imageFilePaths.isNotEmpty;
  }

  /// Check if Step 3 is valid
  bool isStep3Valid() {
    return documents.containsKey('title_deed') &&
        (documents['title_deed']?.filePath?.isNotEmpty ?? false);
  }

  // Step 4 is optional
  bool isStep4Valid() => true;

  PropertyFormData copyWith({
    String? category,
    String? title,
    String? description,
    String? city,
    String? locality,
    String? area,
    String? price,
    String? ownershipType,
    String? availabilityStatus,
    String? agentMobileNumber,
    String? agentName,
    bool? agentVerified,
    List<String>? imageFilePaths,
    Map<String, DocumentInfo>? documents,
    String? propertyId,
  }) {
    return PropertyFormData(
      category: category ?? this.category,
      title: title ?? this.title,
      description: description ?? this.description,
      city: city ?? this.city,
      locality: locality ?? this.locality,
      area: area ?? this.area,
      price: price ?? this.price,
      ownershipType: ownershipType ?? this.ownershipType,
      availabilityStatus: availabilityStatus ?? this.availabilityStatus,
      agentMobileNumber: agentMobileNumber ?? this.agentMobileNumber,
      agentName: agentName ?? this.agentName,
    )
      ..imageFilePaths = imageFilePaths ?? this.imageFilePaths
      ..documents = documents ?? this.documents
      ..agentVerified = agentVerified ?? this.agentVerified
      ..propertyId = propertyId ?? this.propertyId
      ..createdAt = this.createdAt
      ..updatedAt = DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'title': title,
      'description': description,
      'location': {
        'city': city,
        'locality': locality,
      },
      'area': double.tryParse(area ?? '0'),
      'price': double.tryParse(price ?? '0'),
      'ownershipType': ownershipType,
      'availabilityStatus': availabilityStatus,
      'imageCount': imageFilePaths.length,
      'documents': documents.keys.toList(),
      'agentMobileNumber': agentMobileNumber,
    };
  }
}

/// Document information model
class DocumentInfo {
  final String fileName;
  final String filePath;
  final String fileType;
  final bool isRequired;
  final DateTime uploadedAt;

  DocumentInfo({
    required this.fileName,
    required this.filePath,
    required this.fileType,
    this.isRequired = false,
  }) : uploadedAt = DateTime.now();
}

/// Property submission status model
class PropertySubmissionStatus {
  final String propertyId;
  final String status;
  final int progressPercentage;
  final DateTime submittedAt;
  final DateTime? lastUpdatedAt;
  final String? adminNotes;
  final String? rejectionReason;

  PropertySubmissionStatus({
    required this.propertyId,
    required this.status,
    this.progressPercentage = 10,
    required this.submittedAt,
    this.lastUpdatedAt,
    this.adminNotes,
    this.rejectionReason,
  });
}

// ===============================
// STATE
// ===============================

class SellScreenState {
  final int currentStep;
  final PropertyFormData formData;
  final bool isLoading;
  final String? error;
  final PropertySubmissionStatus? submissionStatus;

  const SellScreenState({
    this.currentStep = 0,
    PropertyFormData? formData,
    this.isLoading = false,
    this.error,
    this.submissionStatus,
  }) : formData = formData ?? const PropertyFormData._empty();

  SellScreenState copyWith({
    int? currentStep,
    PropertyFormData? formData,
    bool? isLoading,
    String? error,
    PropertySubmissionStatus? submissionStatus,
  }) {
    return SellScreenState(
      currentStep: currentStep ?? this.currentStep,
      formData: formData ?? this.formData,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      submissionStatus: submissionStatus ?? this.submissionStatus,
    );
  }
}

extension on PropertyFormData {
  const factory PropertyFormData._empty() => PropertyFormData();
}

// ===============================
// NOTIFIER
// ===============================

class SellScreenNotifier extends StateNotifier<SellScreenState> {
  SellScreenNotifier() : super(const SellScreenState()) {
    _loadDraft();
  }

  Future<void> _loadDraft() async {
    try {
      final box = await Hive.openBox<Map>('sell_drafts');
      final draftData = box.get('current_draft');
      if (draftData != null) {
        final formData = _parseFormDataFromMap(draftData);
        state = state.copyWith(formData: formData);
      }
    } catch (e) {
      print('Error loading draft: $e');
    }
  }

  PropertyFormData _parseFormDataFromMap(Map data) {
    final form = PropertyFormData(
      category: data['category'],
      title: data['title'],
      description: data['description'],
      city: data['city'],
      locality: data['locality'],
      area: data['area'],
      price: data['price'],
      ownershipType: data['ownershipType'],
      availabilityStatus: data['availabilityStatus'],
      agentMobileNumber: data['agentMobileNumber'],
      agentName: data['agentName'],
    );
    form.imageFilePaths =
        List<String>.from(data['imageFilePaths'] ?? <String>[]);
    form.agentVerified = data['agentVerified'] ?? false;
    return form;
  }

  // ===== STEP 1 =====
  void updatePropertyDetails({
    String? category,
    String? title,
    String? description,
    String? city,
    String? locality,
    String? area,
    String? price,
    String? ownershipType,
    String? availabilityStatus,
  }) {
    state = state.copyWith(
      formData: state.formData.copyWith(
        category: category,
        title: title,
        description: description,
        city: city,
        locality: locality,
        area: area,
        price: price,
        ownershipType: ownershipType,
        availabilityStatus: availabilityStatus,
      ),
    );
    _saveDraft();
  }

  // ===== STEP 2 =====
  void addImage(String filePath) {
    final images = List<String>.from(state.formData.imageFilePaths);
    if (images.length < 20 && !images.contains(filePath)) {
      images.add(filePath);
      state = state.copyWith(
        formData: state.formData.copyWith(imageFilePaths: images),
      );
      _saveDraft();
    }
  }

  void removeImage(String filePath) {
    final images = List<String>.from(state.formData.imageFilePaths);
    images.removeWhere((img) => img == filePath);
    state = state.copyWith(
      formData: state.formData.copyWith(imageFilePaths: images),
    );
    _saveDraft();
  }

  void reorderImages(int oldIndex, int newIndex) {
    final images = List<String>.from(state.formData.imageFilePaths);
    if (newIndex > oldIndex) newIndex -= 1;
    final image = images.removeAt(oldIndex);
    images.insert(newIndex, image);
    state = state.copyWith(
      formData: state.formData.copyWith(imageFilePaths: images),
    );
    _saveDraft();
  }

  // ===== STEP 3 =====
  void addDocument(String documentType, DocumentInfo docInfo) {
    final docs = Map<String, DocumentInfo>.from(state.formData.documents);
    docs[documentType] = docInfo;
    state = state.copyWith(
      formData: state.formData.copyWith(documents: docs),
    );
    _saveDraft();
  }

  void removeDocument(String documentType) {
    final docs = Map<String, DocumentInfo>.from(state.formData.documents);
    docs.remove(documentType);
    state = state.copyWith(
      formData: state.formData.copyWith(documents: docs),
    );
    _saveDraft();
  }

  // ===== STEP 4 =====
  Future<bool> verifyAgent(String mobileNumber) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 2));

      if (mobileNumber.length == 10 && mobileNumber.startsWith(RegExp(r'[6-9]'))) {
        state = state.copyWith(
          formData: state.formData.copyWith(
            agentMobileNumber: mobileNumber,
            agentName: 'Agent Name',
            agentVerified: true,
          ),
          isLoading: false,
        );
        _saveDraft();
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Invalid mobile number format',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to verify agent: $e',
      );
      return false;
    }
  }

  void removeAgent() {
    state = state.copyWith(
      formData: state.formData.copyWith(
        agentMobileNumber: null,
        agentName: null,
        agentVerified: false,
      ),
    );
    _saveDraft();
  }

  // ===== NAVIGATION =====
  void nextStep() {
    if (state.currentStep < 5) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void goToStep(int step) {
    if (step >= 0 && step <= 5) {
      state = state.copyWith(currentStep: step);
    }
  }

  // ===== SUBMISSION =====
  Future<void> submitProperty() async {
    if (!state.formData.isStep1Valid() ||
        !state.formData.isStep2Valid() ||
        !state.formData.isStep3Valid()) {
      state = state.copyWith(error: 'Please complete all required steps');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(seconds: 3));

      final propertyId = 'PROP_${DateTime.now().millisecondsSinceEpoch}';
      final status = PropertySubmissionStatus(
        propertyId: propertyId,
        status: 'submitted',
        progressPercentage: 10,
        submittedAt: DateTime.now(),
      );

      state = state.copyWith(
        isLoading: false,
        submissionStatus: status,
        formData: state.formData.copyWith(propertyId: propertyId),
      );
      
      await _clearDraft();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to submit property: $e',
      );
    }
  }

  // ===== DRAFT MANAGEMENT =====
  Future<void> _saveDraft() async {
    try {
      final box = await Hive.openBox<Map>('sell_drafts');
      await box.put('current_draft', {
        'category': state.formData.category,
        'title': state.formData.title,
        'description': state.formData.description,
        'city': state.formData.city,
        'locality': state.formData.locality,
        'area': state.formData.area,
        'price': state.formData.price,
        'ownershipType': state.formData.ownershipType,
        'availabilityStatus': state.formData.availabilityStatus,
        'imageFilePaths': state.formData.imageFilePaths,
        'agentMobileNumber': state.formData.agentMobileNumber,
        'agentName': state.formData.agentName,
        'agentVerified': state.formData.agentVerified,
        'savedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error saving draft: $e');
    }
  }

  Future<void> _clearDraft() async {
    try {
      final box = await Hive.openBox<Map>('sell_drafts');
      await box.delete('current_draft');
    } catch (e) {
      print('Error clearing draft: $e');
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// ===============================
// PROVIDERS
// ===============================

final sellScreenProvider =
    StateNotifierProvider<SellScreenNotifier, SellScreenState>((ref) {
  return SellScreenNotifier();
});

/// Provider for current step (derived)
final currentStepProvider = Provider<int>((ref) {
  return ref.watch(sellScreenProvider).currentStep;
});

/// Provider for form data (derived)
final formDataProvider = Provider<PropertyFormData>((ref) {
  return ref.watch(sellScreenProvider).formData;
});

/// Provider for submission status (derived)
final submissionStatusProvider = Provider<PropertySubmissionStatus?>((ref) {
  return ref.watch(sellScreenProvider).submissionStatus;
});

/// Provider for property ID (derived)
final propertyIdProvider = Provider<String?>((ref) {
  return ref.watch(sellScreenProvider).submissionStatus?.propertyId;
});

/// Async provider for fetching property status
final propertyStatusProvider =
    FutureProvider.family<PropertySubmissionStatus?, String>((ref, propertyId) async {
  if (propertyId.isEmpty) return null;

  try {
    // TODO: Replace with actual API call
    await Future.delayed(const Duration(seconds: 1));

    return PropertySubmissionStatus(
      propertyId: propertyId,
      status: 'submitted',
      progressPercentage: 10,
      submittedAt: DateTime.now(),
    );
  } catch (e) {
    throw Exception('Failed to load property status: $e');
  }
});

/// Provider for form validity
final isFormValidProvider = Provider<bool>((ref) {
  final formData = ref.watch(formDataProvider);
  return formData.isStep1Valid() &&
      formData.isStep2Valid() &&
      formData.isStep3Valid();
});

/// Provider for step validation
final isCurrentStepValidProvider = Provider<bool>((ref) {
  final step = ref.watch(currentStepProvider);
  final formData = ref.watch(formDataProvider);

  switch (step) {
    case 0:
      return formData.isStep1Valid();
    case 1:
      return formData.isStep2Valid();
    case 2:
      return formData.isStep3Valid();
    case 3:
      return formData.isStep4Valid();
    default:
      return true;
  }
});
