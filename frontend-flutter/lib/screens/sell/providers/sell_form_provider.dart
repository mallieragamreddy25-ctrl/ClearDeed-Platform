import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sell_form_model.dart';

// ==================== Form State Notifier ====================

class SellFormState {
  final SellPropertyDraft draft;
  final List<LocalPropertyImage> localImages;
  final List<LocalPropertyDocument> localDocuments;
  final int currentStep; // 0-5
  final String? error;
  final bool isLoading;
  final bool isSubmitting;
  final List<ReferralAgent> availableAgents;
  final PropertyStatus? submittedStatus;

  const SellFormState({
    this.draft = const SellPropertyDraft(),
    this.localImages = const [],
    this.localDocuments = const [],
    this.currentStep = 0,
    this.error,
    this.isLoading = false,
    this.isSubmitting = false,
    this.availableAgents = const [],
    this.submittedStatus,
  });

  SellFormState copyWith({
    SellPropertyDraft? draft,
    List<LocalPropertyImage>? localImages,
    List<LocalPropertyDocument>? localDocuments,
    int? currentStep,
    String? error,
    bool? isLoading,
    bool? isSubmitting,
    List<ReferralAgent>? availableAgents,
    PropertyStatus? submittedStatus,
  }) {
    return SellFormState(
      draft: draft ?? this.draft,
      localImages: localImages ?? this.localImages,
      localDocuments: localDocuments ?? this.localDocuments,
      currentStep: currentStep ?? this.currentStep,
      error: error,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      availableAgents: availableAgents ?? this.availableAgents,
      submittedStatus: submittedStatus ?? this.submittedStatus,
    );
  }

  int get completedSteps {
    int completed = 0;
    if (draft.isStep1Valid()) completed++;
    if (draft.isStep2Valid()) completed++;
    if (draft.isStep3Valid()) completed++;
    if (draft.isStep4Valid()) completed++;
    return completed;
  }

  bool get canProceedToStep(int stepIndex) {
    switch (stepIndex) {
      case 0:
        return true;
      case 1:
        return draft.isStep1Valid();
      case 2:
        return draft.isStep1Valid();
      case 3:
        return draft.isStep1Valid() && draft.isStep2Valid();
      case 4:
        return draft.isStep1Valid() && draft.isStep2Valid() && draft.isStep3Valid();
      case 5:
        return draft.isStep1Valid() && draft.isStep2Valid() && draft.isStep3Valid();
      default:
        return false;
    }
  }
}

class SellFormNotifier extends StateNotifier<SellFormState> {
  SellFormNotifier() : super(const SellFormState());

  // ==================== Step 1: Property Details ====================

  void setPropertyDetails({
    required String category,
    required String title,
    required String location,
    required double price,
    required double area,
    required String ownershipStatus,
    String? description,
    String? city,
    String? state,
    double? latitude,
    double? longitude,
  }) {
    final updatedDraft = state.draft.copyWith(
      category: category,
      title: title,
      location: location,
      price: price,
      area: area,
      ownershipStatus: ownershipStatus,
      description: description,
      city: city,
      state: state,
      latitude: latitude,
      longitude: longitude,
      updatedAt: DateTime.now(),
    );

    state = state.copyWith(draft: updatedDraft, error: null);
  }

  void setCategory(String category) {
    state = state.copyWith(
      draft: state.draft.copyWith(category: category),
      error: null,
    );
  }

  void setTitle(String title) {
    state = state.copyWith(
      draft: state.draft.copyWith(title: title),
      error: null,
    );
  }

  void setDescription(String description) {
    state = state.copyWith(
      draft: state.draft.copyWith(description: description),
      error: null,
    );
  }

  void setLocation(String location) {
    state = state.copyWith(
      draft: state.draft.copyWith(location: location),
      error: null,
    );
  }

  void setPrice(double price) {
    state = state.copyWith(
      draft: state.draft.copyWith(price: price),
      error: null,
    );
  }

  void setArea(double area) {
    state = state.copyWith(
      draft: state.draft.copyWith(area: area),
      error: null,
    );
  }

  void setAreaUnit(String unit) {
    state = state.copyWith(
      draft: state.draft.copyWith(areaUnit: unit),
      error: null,
    );
  }

  void setOwnershipStatus(String status) {
    state = state.copyWith(
      draft: state.draft.copyWith(ownershipStatus: status),
      error: null,
    );
  }

  // ==================== Step 2: Image Management ====================

  void addImage(File imageFile) {
    final images = List<LocalPropertyImage>.from(state.localImages);
    final order = images.isEmpty ? 0 : images.map((e) => e.order).reduce((a, b) => a > b ? a : b) + 1;

    images.add(LocalPropertyImage(
      file: imageFile,
      order: order,
    ));

    state = state.copyWith(localImages: images, error: null);
  }

  void removeImage(int index) {
    final images = List<LocalPropertyImage>.from(state.localImages);
    images.removeAt(index);

    // Reorder remaining images
    for (int i = 0; i < images.length; i++) {
      images[i] = images[i].copyWith(order: i);
    }

    state = state.copyWith(localImages: images);
  }

  void reorderImages(int oldIndex, int newIndex) {
    final images = List<LocalPropertyImage>.from(state.localImages);

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final image = images.removeAt(oldIndex);
    images.insert(newIndex, image);

    // Update orders
    for (int i = 0; i < images.length; i++) {
      images[i] = images[i].copyWith(order: i);
    }

    state = state.copyWith(localImages: images);
  }

  void updateImageTitle(int index, String title) {
    final images = List<LocalPropertyImage>.from(state.localImages);
    images[index] = images[index].copyWith(title: title);
    state = state.copyWith(localImages: images);
  }

  void setImageUploadProgress(int index, double progress) {
    final images = List<LocalPropertyImage>.from(state.localImages);
    if (index >= 0 && index < images.length) {
      images[index] = images[index].copyWith(uploadProgress: progress);
      state = state.copyWith(localImages: images);
    }
  }

  void markImageAsUploading(int index, bool uploading) {
    final images = List<LocalPropertyImage>.from(state.localImages);
    if (index >= 0 && index < images.length) {
      images[index] = images[index].copyWith(isUploading: uploading);
      state = state.copyWith(localImages: images);
    }
  }

  void commitImageUrls(List<String> imageUrls) {
    final orders = List.generate(imageUrls.length, (index) => index);
    final updatedDraft = state.draft.copyWith(
      imageUrls: imageUrls,
      imageOrders: orders,
      updatedAt: DateTime.now(),
    );
    state = state.copyWith(
      draft: updatedDraft,
      localImages: [],
      error: null,
    );
  }

  // ==================== Step 3: Document Management ====================

  void addDocument(File documentFile, String documentType, String fileName) {
    final documents = List<LocalPropertyDocument>.from(state.localDocuments);
    documents.add(LocalPropertyDocument(
      file: documentFile,
      documentType: documentType,
      fileName: fileName,
    ));

    state = state.copyWith(localDocuments: documents, error: null);
  }

  void removeDocument(int index) {
    final documents = List<LocalPropertyDocument>.from(state.localDocuments);
    documents.removeAt(index);
    state = state.copyWith(localDocuments: documents);
  }

  void setDocumentUploadProgress(int index, double progress) {
    final documents = List<LocalPropertyDocument>.from(state.localDocuments);
    if (index >= 0 && index < documents.length) {
      documents[index] = documents[index].copyWith(uploadProgress: progress);
      state = state.copyWith(localDocuments: documents);
    }
  }

  void markDocumentAsUploading(int index, bool uploading) {
    final documents = List<LocalPropertyDocument>.from(state.localDocuments);
    if (index >= 0 && index < documents.length) {
      documents[index] = documents[index].copyWith(isUploading: uploading);
      state = state.copyWith(localDocuments: documents);
    }
  }

  void commitDocumentUrls(Map<String, String> documentUrls) {
    final updatedDraft = state.draft.copyWith(
      documents: documentUrls,
      updatedAt: DateTime.now(),
    );
    state = state.copyWith(
      draft: updatedDraft,
      localDocuments: [],
      error: null,
    );
  }

  // ==================== Step 4: Referral ====================

  void setAvailableAgents(List<ReferralAgent> agents) {
    state = state.copyWith(availableAgents: agents);
  }

  void selectAgent(String agentId, String agentName) {
    final updatedDraft = state.draft.copyWith(
      referralAgentId: agentId,
      referralAgentName: agentName,
      updatedAt: DateTime.now(),
    );
    state = state.copyWith(draft: updatedDraft, error: null);
  }

  void unselectAgent() {
    final updatedDraft = state.draft.copyWith(
      referralAgentId: null,
      referralAgentName: null,
      updatedAt: DateTime.now(),
    );
    state = state.copyWith(draft: updatedDraft);
  }

  // ==================== Navigation ====================

  void goToStep(int stepIndex) {
    if (state.canProceedToStep(stepIndex)) {
      state = state.copyWith(currentStep: stepIndex, error: null);
    } else {
      state = state.copyWith(error: 'Please complete previous steps first');
    }
  }

  void nextStep() {
    if (state.currentStep < 5) {
      goToStep(state.currentStep + 1);
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1, error: null);
    }
  }

  // ==================== Draft Management ====================

  void setError(String? error) {
    state = state.copyWith(error: error);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void setIsLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setIsSubmitting(bool submitting) {
    state = state.copyWith(isSubmitting: submitting);
  }

  void loadDraft(SellPropertyDraft draft) {
    state = state.copyWith(
      draft: draft,
      currentStep: 0,
      error: null,
      localImages: [],
      localDocuments: [],
    );
  }

  void resetForm() {
    state = const SellFormState();
  }

  void setSubmittedStatus(PropertyStatus status) {
    state = state.copyWith(submittedStatus: status);
  }
}

// ==================== Providers ====================

final sellFormProvider =
    StateNotifierProvider<SellFormNotifier, SellFormState>((ref) {
  return SellFormNotifier();
});

// Step validators
final isStep1ValidProvider = Provider<bool>((ref) {
  final state = ref.watch(sellFormProvider);
  return state.draft.isStep1Valid();
});

final isStep2ValidProvider = Provider<bool>((ref) {
  final state = ref.watch(sellFormProvider);
  return state.draft.isStep2Valid();
});

final isStep3ValidProvider = Provider<bool>((ref) {
  final state = ref.watch(sellFormProvider);
  return state.draft.isStep3Valid();
});

final isStep4ValidProvider = Provider<bool>((ref) {
  final state = ref.watch(sellFormProvider);
  return state.draft.isStep4Valid();
});

final completedStepsProvider = Provider<int>((ref) {
  final state = ref.watch(sellFormProvider);
  return state.completedSteps;
});
