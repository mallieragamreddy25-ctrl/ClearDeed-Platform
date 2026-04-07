import 'package:json_serializable/json_serializable.dart';

part 'property.g.dart';

@JsonSerializable()
class Property {
  final int id;
  final String title;
  final String location;
  final String category;
  final double price;
  final double area;
  final String areaUnit;
  final String status;
  final bool isVerified;
  final bool verifiedBadge;
  final String? imageUrl;
  final DateTime createdAt;

  Property({
    required this.id,
    required this.title,
    required this.location,
    required this.category,
    required this.price,
    required this.area,
    required this.areaUnit,
    required this.status,
    required this.isVerified,
    required this.verifiedBadge,
    this.imageUrl,
    required this.createdAt,
  });

  factory Property.fromJson(Map<String, dynamic> json) =>
      _$PropertyFromJson(json);
  Map<String, dynamic> toJson() => _$PropertyToJson(this);
}

@JsonSerializable()
class PropertyDetail extends Property {
  final String description;
  final String ownershipStatus;
  final List<PropertyImage> gallery;
  final List<PropertyDocument> documents;
  final String? verificationSummary;

  PropertyDetail({
    required super.id,
    required super.title,
    required super.location,
    required super.category,
    required super.price,
    required super.area,
    required super.areaUnit,
    required super.status,
    required super.isVerified,
    required super.verifiedBadge,
    super.imageUrl,
    required super.createdAt,
    required this.description,
    required this.ownershipStatus,
    required this.gallery,
    required this.documents,
    this.verificationSummary,
  });

  factory PropertyDetail.fromJson(Map<String, dynamic> json) =>
      _$PropertyDetailFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PropertyDetailToJson(this);
}

@JsonSerializable()
class PropertyImage {
  final String imageUrl;
  final String? imageTitle;
  final int? displayOrder;

  PropertyImage({
    required this.imageUrl,
    this.imageTitle,
    this.displayOrder,
  });

  factory PropertyImage.fromJson(Map<String, dynamic> json) =>
      _$PropertyImageFromJson(json);
  Map<String, dynamic> toJson() => _$PropertyImageToJson(this);
}

@JsonSerializable()
class PropertyDocument {
  final String documentType;
  final String documentName;
  final String? documentUrl;

  PropertyDocument({
    required this.documentType,
    required this.documentName,
    this.documentUrl,
  });

  factory PropertyDocument.fromJson(Map<String, dynamic> json) =>
      _$PropertyDocumentFromJson(json);
  Map<String, dynamic> toJson() => _$PropertyDocumentToJson(this);
}
