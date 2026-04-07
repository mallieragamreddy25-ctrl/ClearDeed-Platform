import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

/// API Service Provider - Single instance Dio client
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

/// Token provider for API requests
final tokenProvider = StateProvider<String?>((ref) => null);

/// Base API Service with Dio
class ApiService {
  static const String baseUrl = 'http://localhost:3000/v1';
  static const Duration timeout = Duration(seconds: 30);

  late final Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: timeout,
        receiveTimeout: timeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add token to request if available
          final token = _getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          // Handle 401 Unauthorized
          if (error.response?.statusCode == 401) {
            // Clear token and redirect to login
            _clearToken();
          }
          return handler.next(error);
        },
      ),
    );
  }

  // Auth Endpoints
  Future<Response<dynamic>> sendOtp(String phoneNumber) async {
    try {
      final response = await _dio.post(
        '/auth/send-otp',
        data: {'phoneNumber': phoneNumber},
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response<dynamic>> verifyOtp(String phoneNumber, String otp) async {
    try {
      final response = await _dio.post(
        '/auth/verify-otp',
        data: {'phoneNumber': phoneNumber, 'otp': otp},
      );
      if (response.statusCode == 200) {
        final token = response.data['data']['token'];
        _setToken(token);
      }
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response<dynamic>> logout() async {
    try {
      final response = await _dio.post('/auth/logout');
      _clearToken();
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // User Profile Endpoints
  Future<Response<dynamic>> getProfile() => _dio.get('/users/profile');

  Future<Response<dynamic>> updateProfile(Map<String, dynamic> data) =>
      _dio.put('/users/profile', data: data);

  Future<Response<dynamic>> selectRole(String role) =>
      _dio.post('/users/mode-select', data: {'role': role});

  Future<Response<dynamic>> deactivateAccount() =>
      _dio.post('/users/deactivate');

  // Property Endpoints
  Future<Response<dynamic>> uploadProperty(Map<String, dynamic> data) =>
      _dio.post('/properties', data: data);

  Future<Response<dynamic>> getProperties({
    int page = 1,
    int pageSize = 10,
    Map<String, dynamic>? filters,
  }) {
    final queryParams = {
      'page': page,
      'pageSize': pageSize,
      ...?filters,
    };
    return _dio.get('/properties', queryParameters: queryParams);
  }

  Future<Response<dynamic>> getPropertyById(String propertyId) =>
      _dio.get('/properties/$propertyId');

  Future<Response<dynamic>> updateProperty(
    String propertyId,
    Map<String, dynamic> data,
  ) =>
      _dio.put('/properties/$propertyId', data: data);

  Future<Response<dynamic>> deleteProperty(String propertyId) =>
      _dio.delete('/properties/$propertyId');

  // Document Upload
  Future<Response<dynamic>> uploadPropertyDocument(
    String propertyId,
    FormData formData,
  ) =>
      _dio.post(
        '/properties/$propertyId/documents',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

  Future<Response<dynamic>> deleteDocument(
    String propertyId,
    String documentId,
  ) =>
      _dio.delete('/properties/$propertyId/documents/$documentId');

  // Gallery Endpoints
  Future<Response<dynamic>> uploadGalleryImage(
    String propertyId,
    FormData formData,
  ) =>
      _dio.post(
        '/properties/$propertyId/gallery',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

  Future<Response<dynamic>> deleteGalleryImage(
    String propertyId,
    String imageId,
  ) =>
      _dio.delete('/properties/$propertyId/gallery/$imageId');

  Future<Response<dynamic>> reorderGallery(
    String propertyId,
    List<Map<String, dynamic>> order,
  ) =>
      _dio.put(
        '/properties/$propertyId/gallery/reorder',
        data: {'order': order},
      );

  // Investment Endpoints
  Future<Response<dynamic>> getProjects({
    int page = 1,
    int pageSize = 10,
    Map<String, dynamic>? filters,
  }) {
    final queryParams = {
      'page': page,
      'pageSize': pageSize,
      ...?filters,
    };
    return _dio.get('/projects', queryParameters: queryParams);
  }

  Future<Response<dynamic>> getProjectById(String projectId) =>
      _dio.get('/projects/$projectId');

  Future<Response<dynamic>> expressInterest(
    String projectId,
    Map<String, dynamic> data,
  ) =>
      _dio.post('/projects/$projectId/express-interest', data: data);

  Future<Response<dynamic>> getMyInvestments({
    int page = 1,
    int pageSize = 10,
  }) =>
      _dio.get(
        '/users/investments',
        queryParameters: {'page': page, 'pageSize': pageSize},
      );

  // Notification Endpoints
  Future<Response<dynamic>> getNotifications({
    int page = 1,
    int pageSize = 20,
    bool? unreadOnly,
  }) {
    final queryParams = {
      'page': page,
      'pageSize': pageSize,
      if (unreadOnly != null) 'unreadOnly': unreadOnly,
    };
    return _dio.get('/notifications', queryParameters: queryParams);
  }

  Future<Response<dynamic>> markNotificationAsRead(String notificationId) =>
      _dio.put('/notifications/$notificationId', data: {'isRead': true});

  Future<Response<dynamic>> deleteNotification(String notificationId) =>
      _dio.delete('/notifications/$notificationId');

  Future<Response<dynamic>> getNotificationPreferences() =>
      _dio.get('/notifications/preferences');

  Future<Response<dynamic>> updateNotificationPreferences(
    Map<String, dynamic> data,
  ) =>
      _dio.put('/notifications/preferences', data: data);

  // Commission & Earnings Endpoints
  Future<Response<dynamic>> getAgentEarnings() =>
      _dio.get('/commissions/earnings');

  Future<Response<dynamic>> getCommissions({
    int page = 1,
    int pageSize = 10,
    String? status,
  }) {
    final queryParams = {
      'page': page,
      'pageSize': pageSize,
      if (status != null) 'status': status,
    };
    return _dio.get('/commissions', queryParameters: queryParams);
  }

  // Deal Endpoints
  Future<Response<dynamic>> getDeals({
    int page = 1,
    int pageSize = 10,
    String? status,
  }) {
    final queryParams = {
      'page': page,
      'pageSize': pageSize,
      if (status != null) 'status': status,
    };
    return _dio.get('/deals', queryParameters: queryParams);
  }

  Future<Response<dynamic>> getDealById(String dealId) =>
      _dio.get('/deals/$dealId');

  Future<Response<dynamic>> updateDealStatus(
    String dealId,
    String status,
  ) =>
      _dio.put('/deals/$dealId', data: {'status': status});

  // Referral Endpoints
  Future<Response<dynamic>> getReferralLink() =>
      _dio.get('/referrals/my-link');

  Future<Response<dynamic>> generateReferralLink() =>
      _dio.post('/referrals/generate');

  // Health Check
  Future<Response<dynamic>> healthCheck() => _dio.get('/health');

  // Token management
  void _setToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  String? _getToken() {
    final auth = _dio.options.headers['Authorization'] as String?;
    if (auth != null && auth.startsWith('Bearer ')) {
      return auth.substring(7);
    }
    return null;
  }

  void _clearToken() {
    _dio.options.headers.remove('Authorization');
  }

  bool isTokenExpired(String token) {
    try {
      return JwtDecoder.isExpired(token);
    } catch (e) {
      return true;
    }
  }

  Map<String, dynamic>? decodeToken(String token) {
    try {
      return JwtDecoder.decode(token);
    } catch (e) {
      return null;
    }
  }

  /// For testing - disable in production
  void setMockMode(bool enabled) {
    if (enabled) {
      _dio.httpClientAdapter = _MockHttpAdapter();
    }
  }
}

/// Mock adapter for testing
class _MockHttpAdapter extends HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    // Mock responses for testing
    return ResponseBody.fromString(
      '{"success": true, "message": "Mock response"}',
      200,
      headers: {'content-type': ['application/json']},
    );
  }

  @override
  void close({bool force = false}) {}
}

import 'package:dio/io.dart';
