import 'dart:io';
import 'package:json_serializable/json_serializable.dart';

part 'sell_form_model.g.dart';

/// Draft property data for selling
@JsonSerializable()
class SellPropertyDraft {
  // Step 1: Property Details
  final String? category;
  final String? title;
  final String? description;
  final String? location;
  final String? city;
  final String? state;
  final double? latitude;
  final double? longitude;
  final double? price;
  final double? area;
  final String? areaUnit;
  final String? ownershipStatus;

  // Step 2: Images
  final List<String> imageUrls;
  final List<int> imageOrders;

  // Step 3: Documents
  final Map<String, String?> documents; // documentType -> documentUrl

  // Step 4: Referral
  final String? referralAgentId;
  final String? referralAgentName;

  // Metadata
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? draftId;

  const SellPropertyDraft({
    this.category,
    this.title,
    this.description,
    this.location,
    this.city,
    this.state,
    this.latitude,
    this.longitude,
    this.price,
    this.area,
    this.areaUnit = 'sqft',
    this.ownershipStatus,
    this.imageUrls = const [],
    this.imageOrders = const [],
    this.documents = const {},
    this.referralAgentId,
    this.referralAgentName,
    this.createdAt,
    this.updatedAt,
    this.draftId,
  });

  factory SellPropertyDraft.fromJson(Map<String, dynamic> json) =>
      _$SellPropertyDraftFromJson(json);

  Map<String, dynamic> toJson() => _$SellPropertyDraftToJson(this);

  /// Create a copy with updated fields
  SellPropertyDraft copyWith({
    String? category,
    String? title,
    String? description,
    String? location,
    String? city,
    String? state,
    double? latitude,
    double? longitude,
    double? price,
    double? area,
    String? areaUnit,
    String? ownershipStatus,
    List<String>? imageUrls,
    List<int>? imageOrders,
    Map<String, String?>? documents,
    String? referralAgentId,
    String? referralAgentName,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? draftId,
  }) {
    return SellPropertyDraft(
      category: category ?? this.category,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      city: city ?? this.city,
      state: state ?? this.state,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      price: price ?? this.price,
      area: area ?? this.area,
      areaUnit: areaUnit ?? this.areaUnit,
      ownershipStatus: ownershipStatus ?? this.ownershipStatus,
      imageUrls: imageUrls ?? this.imageUrls,
      imageOrders: imageOrders ?? this.imageOrders,
      documents: documents ?? this.documents,
      referralAgentId: referralAgentId ?? this.referralAgentId,
      referralAgentName: referralAgentName ?? this.referralAgentName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      draftId: draftId ?? this.draftId,
    );
  }

  /// Check if minimum required fields are filled for step progression
  bool isStep1Valid() {
    return category != null &&
        category!.isNotEmpty &&
        title != null &&
        title!.isNotEmpty &&
        location != null &&
        location!.isNotEmpty &&
        price != null &&
        price! > 0 &&
        area != null &&
        area! > 0 &&
        ownershipStatus != null &&
        ownershipStatus!.isNotEmpty;
  }

  bool isStep2Valid() {
    return imageUrls.isNotEmpty;
  }

  bool isStep3Valid() {
    // At least title deed is required
    return documents.containsKey('title_deed') && documents['title_deed'] != null;
  }

  bool isStep4Valid() {
    return true; // Step 4 is optional
  }
}

/// Local image data before upload
class LocalPropertyImage {
  final File file;
  final int order;
  final String? title;
  bool isUploading;
  double uploadProgress;

  LocalPropertyImage({
    required this.file,
    required this.order,
    this.title,
    this.isUploading = false,
    this.uploadProgress = 0,
  });

  LocalPropertyImage copyWith({
    File? file,
    int? order,
    String? title,
    bool? isUploading,
    double? uploadProgress,
  }) {
    return LocalPropertyImage(
      file: file ?? this.file,
      order: order ?? this.order,
      title: title ?? this.title,
      isUploading: isUploading ?? this.isUploading,
      uploadProgress: uploadProgress ?? this.uploadProgress,
    );
  }
}

/// Local document data before upload
class LocalPropertyDocument {
  final File file;
  final String documentType;
  final String fileName;
  bool isUploading;
  double uploadProgress;

  LocalPropertyDocument({
    required this.file,
    required this.documentType,
    required this.fileName,
    this.isUploading = false,
    this.uploadProgress = 0,
  });

  LocalPropertyDocument copyWith({
    File? file,
    String? documentType,
    String? fileName,
    bool? isUploading,
    double? uploadProgress,
  }) {
    return LocalPropertyDocument(
      file: file ?? this.file,
      documentType: documentType ?? this.documentType,
      fileName: fileName ?? this.fileName,
      isUploading: isUploading ?? this.isUploading,
      uploadProgress: uploadProgress ?? this.uploadProgress,
    );
  }
}

/// Referral agent for step 4
@JsonSerializable()
class ReferralAgent {
  final String id;
  final String name;
  final String? phone;
  final String? email;
  final double? commissionPercentage;

  ReferralAgent({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.commissionPercentage,
  });

  factory ReferralAgent.fromJson(Map<String, dynamic> json) =>
      _$ReferralAgentFromJson(json);

  Map<String, dynamic> toJson() => _$ReferralAgentToJson(this);
}

/// Property status enum
enum PropertyStatus {
  draft('draft'),
  submitted('submitted'),
  underVerification('under_verification'),
  verified('verified'),
  live('live'),
  sold('sold'),
  rejected('rejected');

  final String value;
  const PropertyStatus(this.value);
}

/// Status tracking info
@JsonSerializable()
class PropertyStatusInfo {
  final String propertyId;
  final PropertyStatus status;
  final DateTime lastUpdated;
  final String? notes;
  final int? rejectionReason;

  PropertyStatusInfo({
    required this.propertyId,
    required this.status,
    required this.lastUpdated,
    this.notes,
    this.rejectionReason,
  });

  factory PropertyStatusInfo.fromJson(Map<String, dynamic> json) =>
      _$PropertyStatusInfoFromJson(json);

  Map<String, dynamic> toJson() => _$PropertyStatusInfoToJson(this);
}
