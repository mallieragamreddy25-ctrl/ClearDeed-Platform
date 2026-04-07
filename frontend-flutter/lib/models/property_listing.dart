import 'package:json_annotation/json_annotation.dart';

part 'property_listing.g.dart';

/// Property listing model for both selling and viewing
@JsonSerializable()
class PropertyListing {
  final String id;
  final String title;
  final String description;
  final String propertyType; // apartment, villa, land, etc.
  final double price;
  final String currency;
  final double? area;
  final String? areaUnit; // sqft, sqm
  final int? bedrooms;
  final int? bathrooms;
  final String city;
  final String? state;
  final String postalCode;
  final double latitude;
  final double longitude;
  final String? address;
  final List<String> amenities;
  final List<PropertyImage> images;
  final List<PropertyDocument> documents;
  final String status; // submitted, verified, rejected, sold
  final String sellerId;
  final DateTime createdAt;
  final DateTime? verifiedAt;
  final String? rejectionReason;
  final bool isFeatured;
  final int viewCount;
  final List<String>? favoriteIds;

  PropertyListing({
    required this.id,
    required this.title,
    required this.description,
    required this.propertyType,
    required this.price,
    required this.currency,
    this.area,
    this.areaUnit,
    this.bedrooms,
    this.bathrooms,
    required this.city,
    this.state,
    required this.postalCode,
    required this.latitude,
    required this.longitude,
    this.address,
    required this.amenities,
    required this.images,
    required this.documents,
    required this.status,
    required this.sellerId,
    required this.createdAt,
    this.verifiedAt,
    this.rejectionReason,
    this.isFeatured = false,
    this.viewCount = 0,
    this.favoriteIds,
  });

  factory PropertyListing.fromJson(Map<String, dynamic> json) =>
      _$PropertyListingFromJson(json);

  Map<String, dynamic> toJson() => _$PropertyListingToJson(this);

  bool get isSold => status == 'sold';
  bool get isVerified => status == 'verified';
  bool get isPending => status == 'submitted';
  bool get isRejected => status == 'rejected';
}

@JsonSerializable()
class PropertyImage {
  final String id;
  final String url;
  final String thumbUrl;
  final int order;
  final bool isMainImage;
  final DateTime uploadedAt;

  PropertyImage({
    required this.id,
    required this.url,
    required this.thumbUrl,
    required this.order,
    required this.isMainImage,
    required this.uploadedAt,
  });

  factory PropertyImage.fromJson(Map<String, dynamic> json) =>
      _$PropertyImageFromJson(json);

  Map<String, dynamic> toJson() => _$PropertyImageToJson(this);
}

@JsonSerializable()
class PropertyDocument {
  final String id;
  final String type; // title, survey, tax_proof, etc.
  final String fileUrl;
  final String fileName;
  final String mimeType;
  final int fileSizeBytes;
  final DateTime uploadedAt;
  final String? verificationStatus; // pending, verified, rejected

  PropertyDocument({
    required this.id,
    required this.type,
    required this.fileUrl,
    required this.fileName,
    required this.mimeType,
    required this.fileSizeBytes,
    required this.uploadedAt,
    this.verificationStatus,
  });

  factory PropertyDocument.fromJson(Map<String, dynamic> json) =>
      _$PropertyDocumentFromJson(json);

  Map<String, dynamic> toJson() => _$PropertyDocumentToJson(this);
}
