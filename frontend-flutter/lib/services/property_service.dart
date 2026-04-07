import 'dart:io';
import 'package:dio/dio.dart';
import 'http_exception.dart';
import 'api_client.dart';
import '../models/property.dart';
import '../utils/app_logger.dart';

/// Property service for handling property-related API calls
class PropertyService {
  final ApiClient _apiClient;

  PropertyService({required ApiClient apiClient}) : _apiClient = apiClient;

  // ==================== Property List ====================

  /// Get list of properties with optional filters
  /// Returns: Future<List<Property>> - list of properties
  Future<List<Property>> getProperties({
    int page = 1,
    int limit = 20,
    String? category,
    String? city,
    double? minPrice,
    double? maxPrice,
    String? searchQuery,
  }) async {
    try {
      AppLogger.logFunctionEntry('getProperties', {
        'page': page,
        'category': category,
        'city': city,
      });

      final queryParams = {
        'page': page,
        'limit': limit,
        if (category != null) 'category': category,
        if (city != null) 'city': city,
        if (minPrice != null) 'min_price': minPrice,
        if (maxPrice != null) 'max_price': maxPrice,
        if (searchQuery != null) 'search': searchQuery,
      };

      final response = await _apiClient.get(
        '/v1/properties',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        List<Property> properties = [];
        final data = response.data['data'] ?? response.data;

        if (data is List) {
          properties = data
              .map((item) => Property.fromJson(item is Map<String, dynamic> ? item : {}))
              .toList();
        } else if (data is Map && data['properties'] != null) {
          properties = (data['properties'] as List)
              .map((item) => Property.fromJson(item))
              .toList();
        }

        AppLogger.logFunctionExit('getProperties', 'Got ${properties.length} properties');
        return properties;
      }

      throw ApiException(
        message: response.data['message'] ?? 'Failed to fetch properties',
        statusCode: response.statusCode,
        responseBody: response.data,
      );
    } on DioException catch (e) {
      AppLogger.error('Get properties failed: ${e.message}', e);
      throw _mapDioException(e);
    } catch (e) {
      AppLogger.error('Get properties error: $e', e);
      rethrow;
    }
  }

  /// Get featured properties
  /// Returns: Future<List<Property>> - list of featured properties
  Future<List<Property>> getFeaturedProperties() async {
    try {
      AppLogger.logFunctionEntry('getFeaturedProperties');

      final response = await _apiClient.get('/v1/properties/featured');

      if (response.statusCode == 200) {
        List<Property> properties = [];
        final data = response.data['data'] ?? response.data;

        if (data is List) {
          properties = data
              .map((item) => Property.fromJson(item is Map<String, dynamic> ? item : {}))
              .toList();
        }

        AppLogger.logFunctionExit('getFeaturedProperties', 'Got ${properties.length} properties');
        return properties;
      }

      throw ApiException(
        message: response.data['message'] ?? 'Failed to fetch featured properties',
        statusCode: response.statusCode,
        responseBody: response.data,
      );
    } on DioException catch (e) {
      AppLogger.error('Get featured properties failed: ${e.message}', e);
      throw _mapDioException(e);
    } catch (e) {
      AppLogger.error('Get featured properties error: $e', e);
      rethrow;
    }
  }

  // ==================== Property Detail ====================

  /// Get property details
  /// Returns: Future<PropertyDetail> - detailed property information
  Future<PropertyDetail> getPropertyDetail(int propertyId) async {
    try {
      AppLogger.logFunctionEntry('getPropertyDetail', {'propertyId': propertyId});

      final response = await _apiClient.get('/v1/properties/$propertyId');

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final property = PropertyDetail.fromJson(data);

        AppLogger.logFunctionExit('getPropertyDetail', property.title);
        return property;
      }

      throw ApiException(
        message: response.data['message'] ?? 'Failed to fetch property details',
        statusCode: response.statusCode,
        responseBody: response.data,
      );
    } on DioException catch (e) {
      AppLogger.error('Get property detail failed: ${e.message}', e);
      throw _mapDioException(e);
    } catch (e) {
      AppLogger.error('Get property detail error: $e', e);
      rethrow;
    }
  }

  // ==================== Property Images ====================

  /// Upload property image
  /// Returns: Future<Map> - uploaded image details
  Future<Map<String, dynamic>> uploadImage(
    int propertyId,
    String imagePath, {
    void Function(int, int)? onProgress,
  }) async {
    try {
      AppLogger.logFunctionEntry('uploadImage', {'propertyId': propertyId});

      final response = await _apiClient.uploadFile(
        '/v1/properties/$propertyId/images',
        filePath: imagePath,
        fileKey: 'image',
        onProgress: onProgress,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final imageData = response.data['data'] ?? response.data;
        AppLogger.logFunctionExit('uploadImage', 'Success');
        return imageData is Map<String, dynamic> ? imageData : {};
      }

      throw ApiException(
        message: response.data['message'] ?? 'Failed to upload image',
        statusCode: response.statusCode,
        responseBody: response.data,
      );
    } on DioException catch (e) {
      AppLogger.error('Upload image failed: ${e.message}', e);
      throw _mapDioException(e);
    } catch (e) {
      AppLogger.error('Upload image error: $e', e);
      rethrow;
    }
  }

  /// Upload multiple property images
  /// Returns: Future<List<Map>> - list of uploaded image details
  Future<List<Map<String, dynamic>>> uploadImages(
    int propertyId,
    List<String> imagePaths, {
    void Function(int, int)? onProgress,
  }) async {
    try {
      AppLogger.logFunctionEntry('uploadImages', {
        'propertyId': propertyId,
        'imageCount': imagePaths.length
      });

      final response = await _apiClient.uploadFiles(
        '/v1/properties/$propertyId/images',
        filePaths: imagePaths,
        fileKey: 'images',
        onProgress: onProgress,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] ?? response.data;
        List<Map<String, dynamic>> images = [];

        if (data is List) {
          images = data.map((item) => item is Map<String, dynamic> ? item : {}).toList();
        }

        AppLogger.logFunctionExit('uploadImages', 'Uploaded ${images.length} images');
        return images;
      }

      throw ApiException(
        message: response.data['message'] ?? 'Failed to upload images',
        statusCode: response.statusCode,
        responseBody: response.data,
      );
    } on DioException catch (e) {
      AppLogger.error('Upload images failed: ${e.message}', e);
      throw _mapDioException(e);
    } catch (e) {
      AppLogger.error('Upload images error: $e', e);
      rethrow;
    }
  }

  // ==================== Property Documents ====================

  /// Upload property document
  /// Returns: Future<Map> - uploaded document details
  Future<Map<String, dynamic>> uploadDocument(
    int propertyId,
    String documentPath,
    String documentType, {
    void Function(int, int)? onProgress,
  }) async {
    try {
      AppLogger.logFunctionEntry('uploadDocument', {
        'propertyId': propertyId,
        'documentType': documentType
      });

      final response = await _apiClient.uploadFile(
        '/v1/properties/$propertyId/documents',
        filePath: documentPath,
        fileKey: 'document',
        additionalFields: {'document_type': documentType},
        onProgress: onProgress,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final docData = response.data['data'] ?? response.data;
        AppLogger.logFunctionExit('uploadDocument', 'Success');
        return docData is Map<String, dynamic> ? docData : {};
      }

      throw ApiException(
        message: response.data['message'] ?? 'Failed to upload document',
        statusCode: response.statusCode,
        responseBody: response.data,
      );
    } on DioException catch (e) {
      AppLogger.error('Upload document failed: ${e.message}', e);
      throw _mapDioException(e);
    } catch (e) {
      AppLogger.error('Upload document error: $e', e);
      rethrow;
    }
  }

  // ==================== Property Interaction ====================

  /// Express interest in property
  /// Returns: Future<Map> - response data
  Future<Map<String, dynamic>> expressInterest(int propertyId) async {
    try {
      AppLogger.logFunctionEntry('expressInterest', {'propertyId': propertyId});

      final response = await _apiClient.post(
        '/v1/properties/$propertyId/interest',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'] ?? response.data;
        AppLogger.logFunctionExit('expressInterest', 'Success');
        return data is Map<String, dynamic> ? data : {};
      }

      throw ApiException(
        message: response.data['message'] ?? 'Failed to express interest',
        statusCode: response.statusCode,
        responseBody: response.data,
      );
    } on DioException catch (e) {
      AppLogger.error('Express interest failed: ${e.message}', e);
      throw _mapDioException(e);
    } catch (e) {
      AppLogger.error('Express interest error: $e', e);
      rethrow;
    }
  }

  /// Get property status
  /// Returns: Future<Map> - property status information
  Future<Map<String, dynamic>> getPropertyStatus(int propertyId) async {
    try {
      AppLogger.logFunctionEntry('getPropertyStatus', {'propertyId': propertyId});

      final response = await _apiClient.get('/v1/properties/$propertyId/status');

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        AppLogger.logFunctionExit('getPropertyStatus', 'Success');
        return data is Map<String, dynamic> ? data : {};
      }

      throw ApiException(
        message: response.data['message'] ?? 'Failed to fetch property status',
        statusCode: response.statusCode,
        responseBody: response.data,
      );
    } on DioException catch (e) {
      AppLogger.error('Get property status failed: ${e.message}', e);
      throw _mapDioException(e);
    } catch (e) {
      AppLogger.error('Get property status error: $e', e);
      rethrow;
    }
  }

  /// Search properties
  /// Returns: Future<List<Property>> - search results
  Future<List<Property>> searchProperties({
    required String query,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      AppLogger.logFunctionEntry('searchProperties', {'query': query});

      final response = await _apiClient.get(
        '/v1/properties/search',
        queryParameters: {
          'q': query,
          'page': page,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        List<Property> properties = [];
        final data = response.data['data'] ?? response.data;

        if (data is List) {
          properties = data
              .map((item) => Property.fromJson(item is Map<String, dynamic> ? item : {}))
              .toList();
        }

        AppLogger.logFunctionExit('searchProperties', 'Found ${properties.length} properties');
        return properties;
      }

      throw ApiException(
        message: response.data['message'] ?? 'Failed to search properties',
        statusCode: response.statusCode,
        responseBody: response.data,
      );
    } on DioException catch (e) {
      AppLogger.error('Search properties failed: ${e.message}', e);
      throw _mapDioException(e);
    } catch (e) {
      AppLogger.error('Search properties error: $e', e);
      rethrow;
    }
  }

  // ==================== Error Handling ====================

  /// Map DioException to AppException
  AppException _mapDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException(
          message: 'Request timeout. Please check your connection.',
          originalError: error,
        );

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 401) {
          return UnauthorizedException(
            responseBody: error.response?.data,
            originalError: error,
          );
        }
        return ApiException(
          message: error.response?.data['message'] ?? 'API error',
          statusCode: statusCode,
          responseBody: error.response?.data,
          originalError: error,
        );

      case DioExceptionType.connectionError:
      case DioExceptionType.connectionErrorSocket:
        return NetworkException(
          message: 'Network connection failed',
          originalError: error,
        );

      case DioExceptionType.unknown:
        return NetworkException(
          message: 'An unexpected error occurred',
          originalError: error,
        );

      case DioExceptionType.badCertificate:
        return NetworkException(
          message: 'SSL certificate error',
          originalError: error,
        );

      case DioExceptionType.cancel:
        return AppException(
          message: 'Request cancelled',
          originalError: error,
        );

      default:
        return AppException(
          message: 'An error occurred',
          originalError: error,
        );
    }
  }
}
