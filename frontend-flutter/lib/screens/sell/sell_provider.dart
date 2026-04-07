import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'dart:io';

/// Model for property form data across all steps
class PropertyFormData {
  // Step 1: Property Details
  String? category; // Land, House, Commercial, Agriculture
  String? title;
  String? description;
  String? city;
  String? locality;
  String? area; // in sqft
  String? price;
  String? ownershipType; // Freehold, Leasehold
  String? availabilityStatus; // Available, Sold, Off-Market

  // Step 2: Images
  List<String> imageFilePaths = []; // File paths of selected images

  // Step 3: Documents
  Map<String, DocumentInfo> documents = {}; // document_type -> DocumentInfo

  // Step 4: Referral
  String? agentMobileNumber;
  String? agentName;
  bool? agentVerified;

  // Metadata
  DateTime? createdAt;
  DateTime? updatedAt;
  String? propertyId; // Set after successful submission
  String? listingId;

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
    this.agentVerified,
  }) {
    createdAt = DateTime.now();
    updatedAt = DateTime.now();
  }

  /// Convert to JSON for API submission
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
      'agentMobileNumber': agentMobileNumber,
      'documents': documents.entries.map((e) {
        return {
          'type': e.key,
          'filePath': e.value.filePath,
          'fileName': e.value.fileName,
        };
      }).toList(),
    };
  }

  /// Create a copy for immutability
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
    String? listingId,
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
      agentVerified: agentVerified ?? this.agentVerified,
    )
      ..imageFilePaths = imageFilePaths ?? this.imageFilePaths
      ..documents = documents ?? this.documents
      ..createdAt = this.createdAt
      ..updatedAt = DateTime.now()
      ..propertyId = propertyId ?? this.propertyId
      ..listingId = listingId ?? this.listingId;
  }
}

/// Model for document information
class DocumentInfo {
  final String filePath;
  final String fileName;
  final String mimeType;
  bool isRequired;
  DateTime? uploadedAt;

  DocumentInfo({
    required this.filePath,
    required this.fileName,
    required this.mimeType,
    this.isRequired = false,
    this.uploadedAt,
  }) {
    uploadedAt ??= DateTime.now();
  }
}

/// Model for property submission status
class PropertySubmissionStatus {
  final String status; // submitted, under_verification, verified, live, sold, rejected
  final DateTime createdAt;
  final DateTime? lastUpdatedAt;
  final String? adminNotes;
  final String? rejectionReason;
  final int progressPercentage;

  PropertySubmissionStatus({
    required this.status,
    required this.createdAt,
    this.lastUpdatedAt,
    this.adminNotes,
    this.rejectionReason,
    this.progressPercentage = 0,
  });
}

// ===================== RIVERPOD PROVIDERS =====================

/// Provider for current step tracking (1-5)
final currentStepProvider = StateProvider<int>((ref) => 1);

/// Provider for property form data
final propertyFormProvider = StateProvider<PropertyFormData>((ref) {
  return PropertyFormData();
});

/// Provider to track form submission status
final submissionStatusProvider =
    StateProvider<SubmissionStatus>((ref) => SubmissionStatus.idle);

enum SubmissionStatus { idle, loading, success, error }

/// Provider for submission error message
final submissionErrorProvider = StateProvider<String?>((ref) => null);

/// Provider for property ID after submission
final propertyIdProvider = StateProvider<String?>((ref) => null);

/// Provider for loading image picker state
final imagePickerLoadingProvider = StateProvider<bool>((ref) => false);

/// Provider for loading document picker state
final documentPickerLoadingProvider = StateProvider<bool>((ref) => false);

/// Provider to save draft to Hive
final saveDraftProvider = FutureProvider<void>((ref) async {
  final formData = ref.watch(propertyFormProvider);
  
  try {
    final box = await Hive.openBox('property_drafts');
    await box.put('current_draft', {
      'category': formData.category,
      'title': formData.title,
      'description': formData.description,
      'city': formData.city,
      'locality': formData.locality,
      'area': formData.area,
      'price': formData.price,
      'ownershipType': formData.ownershipType,
      'availabilityStatus': formData.availabilityStatus,
      'imageFilePaths': formData.imageFilePaths,
      'agentMobileNumber': formData.agentMobileNumber,
      'agentName': formData.agentName,
      'agentVerified': formData.agentVerified,
      'savedAt': DateTime.now().toIso8601String(),
    });
  } catch (e) {
    print('Error saving draft: $e');
    rethrow;
  }
});

/// Provider to load draft from Hive
final loadDraftProvider = FutureProvider<PropertyFormData?>((ref) async {
  try {
    final box = await Hive.openBox('property_drafts');
    final draft = box.get('current_draft');
    
    if (draft != null && draft is Map) {
      return PropertyFormData(
        category: draft['category'],
        title: draft['title'],
        description: draft['description'],
        city: draft['city'],
        locality: draft['locality'],
        area: draft['area'],
        price: draft['price'],
        ownershipType: draft['ownershipType'],
        availabilityStatus: draft['availabilityStatus'],
        agentMobileNumber: draft['agentMobileNumber'],
        agentName: draft['agentName'],
        agentVerified: draft['agentVerified'],
      )..imageFilePaths = List<String>.from(draft['imageFilePaths'] ?? []);
    }
  } catch (e) {
    print('Error loading draft: $e');
  }
  return null;
});

/// Provider to clear draft
final clearDraftProvider = FutureProvider<void>((ref) async {
  try {
    final box = await Hive.openBox('property_drafts');
    await box.delete('current_draft');
  } catch (e) {
    print('Error clearing draft: $e');
    rethrow;
  }
});

/// Provider for agent verification (mock - replace with API call)
final verifyAgentProvider = FutureProvider.family<Map<String, dynamic>?, String>(
  (ref, mobileNumber) async {
    // TODO: Replace with actual API call to backend
    // Mock implementation
    await Future.delayed(const Duration(seconds: 2));
    
    if (mobileNumber.contains('9')) {
      return {
        'name': 'John Agent',
        'verified': true,
        'registrationNumber': 'AG123456',
      };
    }
    return null;
  },
);

/// Provider for property submission
final submitPropertyProvider =
    FutureProvider<PropertySubmissionStatus?>((ref) async {
  final formData = ref.watch(propertyFormProvider);
  
  ref.read(submissionStatusProvider.notifier).state = SubmissionStatus.loading;

  try {
    // TODO: Replace with actual API call to backend
    // Mock implementation
    await Future.delayed(const Duration(seconds: 3));
    
    // Simulate API response
    final status = PropertySubmissionStatus(
      status: 'submitted',
      createdAt: DateTime.now(),
      progressPercentage: 10,
    );

    ref.read(submissionStatusProvider.notifier).state = SubmissionStatus.success;
    ref.read(propertyIdProvider.notifier).state = 'PROP_${DateTime.now().millisecondsSinceEpoch}';
    
    // Clear draft after successful submission
    await ref.read(clearDraftProvider.future);
    
    return status;
  } catch (e) {
    ref.read(submissionStatusProvider.notifier).state = SubmissionStatus.error;
    ref.read(submissionErrorProvider.notifier).state = e.toString();
    rethrow;
  }
});

/// Provider to fetch property status by ID
final propertyStatusProvider =
    FutureProvider.family<PropertySubmissionStatus?, String>(
  (ref, propertyId) async {
    try {
      // TODO: Replace with actual API call to backend
      // Mock implementation
      await Future.delayed(const Duration(seconds: 1));
      
      return PropertySubmissionStatus(
        status: 'under_verification',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        lastUpdatedAt: DateTime.now(),
        progressPercentage: 40,
      );
    } catch (e) {
      print('Error fetching property status: $e');
      return null;
    }
  },
);

/// Provider to validate step 1 (Property Details)
final validateStep1Provider = StateProvider<bool>((ref) {
  final form = ref.watch(propertyFormProvider);
  return form.category != null &&
      form.title != null &&
      form.title!.isNotEmpty &&
      form.description != null &&
      form.description!.isNotEmpty &&
      form.city != null &&
      form.city!.isNotEmpty &&
      form.area != null &&
      form.area!.isNotEmpty &&
      form.price != null &&
      form.price!.isNotEmpty &&
      form.ownershipType != null;
});

/// Provider to validate step 2 (Images)
final validateStep2Provider = StateProvider<bool>((ref) {
  final form = ref.watch(propertyFormProvider);
  return form.imageFilePaths.isNotEmpty && form.imageFilePaths.length <= 20;
});

/// Provider to validate step 3 (Documents)
final validateStep3Provider = StateProvider<bool>((ref) {
  final form = ref.watch(propertyFormProvider);
  // At least title deed is required
  return form.documents.containsKey('title_deed');
});
