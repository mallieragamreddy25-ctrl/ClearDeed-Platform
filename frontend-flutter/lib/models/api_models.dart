import 'package:json_annotation/json_annotation.dart';

part 'api_models.g.dart';

/// Generic API response
@JsonSerializable(genericArgumentFactories: true)
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.statusCode,
    this.errors,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) => _$ApiResponseFromJson<T>(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T) toJsonT) =>
      _$ApiResponseToJson<T>(this, toJsonT);
}

/// Paginated response
@JsonSerializable(genericArgumentFactories: true)
class PaginatedResponse<T> {
  final List<T> items;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  PaginatedResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) => _$PaginatedResponseFromJson<T>(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T) toJsonT) =>
      _$PaginatedResponseToJson<T>(this, toJsonT);
}

/// Request body for property upload
@JsonSerializable()
class PropertyUploadRequest {
  final String title;
  final String description;
  final String propertyType;
  final double price;
  final String currency;
  final double? area;
  final String? areaUnit;
  final int? bedrooms;
  final int? bathrooms;
  final String city;
  final String? state;
  final String postalCode;
  final double latitude;
  final double longitude;
  final String? address;
  final List<String> amenities;

  PropertyUploadRequest({
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
  });

  factory PropertyUploadRequest.fromJson(Map<String, dynamic> json) =>
      _$PropertyUploadRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PropertyUploadRequestToJson(this);
}

/// Investment expression request
@JsonSerializable()
class InvestmentExpressionRequest {
  final String projectId;
  final double amount;
  final String? communicationPreference; // email, phone, whatsapp

  InvestmentExpressionRequest({
    required this.projectId,
    required this.amount,
    this.communicationPreference,
  });

  factory InvestmentExpressionRequest.fromJson(Map<String, dynamic> json) =>
      _$InvestmentExpressionRequestFromJson(json);

  Map<String, dynamic> toJson() => _$InvestmentExpressionRequestToJson(this);
}

/// Property filter request
@JsonSerializable()
class PropertyFilterRequest {
  final String? city;
  final String? propertyType;
  final double? minPrice;
  final double? maxPrice;
  final int? minBedrooms;
  final int? maxBedrooms;
  final List<String>? amenities;
  final double? latitude;
  final double? longitude;
  final double? radiusKm;
  final int page;
  final int pageSize;
  final String? sortBy; // price, newest, popular

  PropertyFilterRequest({
    this.city,
    this.propertyType,
    this.minPrice,
    this.maxPrice,
    this.minBedrooms,
    this.maxBedrooms,
    this.amenities,
    this.latitude,
    this.longitude,
    this.radiusKm,
    required this.page,
    required this.pageSize,
    this.sortBy,
  });

  factory PropertyFilterRequest.fromJson(Map<String, dynamic> json) =>
      _$PropertyFilterRequestFromJson(json);

  Map<String, dynamic> toJson() => _$PropertyFilterRequestToJson(this);
}

/// Notification update request
@JsonSerializable()
class NotificationUpdateRequest {
  final String notificationId;
  final bool isRead;
  final bool? delete;

  NotificationUpdateRequest({
    required this.notificationId,
    required this.isRead,
    this.delete,
  });

  factory NotificationUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$NotificationUpdateRequestFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationUpdateRequestToJson(this);
}
