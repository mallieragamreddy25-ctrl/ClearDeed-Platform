import 'package:dio/dio.dart';
import 'api_client.dart';
import '../models/deal.dart';
import '../utils/app_logger.dart';
import '../utils/constants.dart';

/// Exception for deal related errors
class DealException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  DealException({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() => message;
}

/// Deal service for handling deal API calls
class DealService {
  final ApiClient _apiClient;

  DealService({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Get list of deals for current user (buyer/seller/agent)
  /// Returns list of Deal objects with pagination
  Future<List<Deal>> getDeals({
    int page = 1,
    String? status,
    String? type, // buyer, seller, agent, referral
  }) async {
    try {
      AppLogger.logFunctionEntry('getDeals', {
        'page': page,
        'status': status,
        'type': type,
      });

      final queryParams = {
        'page': page,
        'limit': 20,
        if (status != null) 'status': status,
        if (type != null) 'type': type,
      };

      final response = await _apiClient.get(
        '/v1/deals',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        List<Deal> deals = [];
        final data = response.data['data'] ?? response.data;

        if (data is List) {
          deals = data
              .map((item) =>
                  Deal.fromJson(item is Map<String, dynamic> ? item : {}))
              .toList();
        } else if (data is Map && data['deals'] != null) {
          deals = List<Map<String, dynamic>>.from(data['deals'])
              .map((item) => Deal.fromJson(item))
              .toList();
        }

        AppLogger.logFunctionExit('getDeals', 'Got ${deals.length} deals');
        return deals;
      } else {
        throw DealException(
          message: 'Failed to fetch deals',
          code: 'GET_DEALS_FAILED',
          originalError: response.data,
        );
      }
    } on DioException catch (e) {
      AppLogger.error('Get deals failed: ${e.message}', e);
      throw DealException(
        message: _handleDioError(e),
        code: 'GET_DEALS_ERROR',
        originalError: e,
      );
    } catch (e) {
      AppLogger.error('Get deals error: $e', e);
      if (e is DealException) rethrow;
      throw DealException(
        message: 'An unexpected error occurred',
        code: 'GET_DEALS_UNKNOWN',
        originalError: e,
      );
    }
  }

  /// Get deal detail
  Future<Deal> getDealDetail(String dealId) async {
    try {
      AppLogger.logFunctionEntry('getDealDetail', {'dealId': dealId});

      final response = await _apiClient.get('/v1/deals/$dealId');

      if (response.statusCode == 200) {
        final deal = Deal.fromJson(response.data['data'] ?? response.data);
        AppLogger.logFunctionExit('getDealDetail', 'Got deal: ${deal.id}');
        return deal;
      } else {
        throw DealException(
          message: 'Failed to fetch deal details',
          code: 'GET_DEAL_FAILED',
          originalError: response.data,
        );
      }
    } on DioException catch (e) {
      AppLogger.error('Get deal detail failed: ${e.message}', e);
      throw DealException(
        message: _handleDioError(e),
        code: 'GET_DEAL_ERROR',
        originalError: e,
      );
    } catch (e) {
      AppLogger.error('Get deal detail error: $e', e);
      if (e is DealException) rethrow;
      throw DealException(
        message: 'An unexpected error occurred',
        code: 'GET_DEAL_UNKNOWN',
        originalError: e,
      );
    }
  }

  /// Get deal statistics for current user
  Future<DealStats> getDealStats() async {
    try {
      AppLogger.logFunctionEntry('getDealStats', {});

      final response = await _apiClient.get('/v1/deals/stats');

      if (response.statusCode == 200) {
        final stats = DealStats.fromJson(response.data['data'] ?? response.data);
        AppLogger.logFunctionExit('getDealStats', 'Got stats');
        return stats;
      } else {
        throw DealException(
          message: 'Failed to fetch deal statistics',
          code: 'GET_STATS_FAILED',
          originalError: response.data,
        );
      }
    } on DioException catch (e) {
      AppLogger.error('Get deal stats failed: ${e.message}', e);
      throw DealException(
        message: _handleDioError(e),
        code: 'GET_STATS_ERROR',
        originalError: e,
      );
    } catch (e) {
      AppLogger.error('Get deal stats error: $e', e);
      if (e is DealException) rethrow;
      throw DealException(
        message: 'An unexpected error occurred',
        code: 'GET_STATS_UNKNOWN',
        originalError: e,
      );
    }
  }

  /// Handle Dio errors
  String _handleDioError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout) {
      return 'Connection timeout. Please check your internet.';
    } else if (error.type == DioExceptionType.receiveTimeout) {
      return 'Request timeout. Please try again.';
    } else if (error.response?.statusCode == 401) {
      return 'Unauthorized. Please login again.';
    } else if (error.response?.statusCode == 403) {
      return 'Access forbidden.';
    } else if (error.response?.statusCode == 404) {
      return 'Deal not found.';
    } else if (error.response?.statusCode == 500) {
      return 'Server error. Please try again later.';
    } else {
      return error.message ?? 'Network error occurred.';
    }
  }
}
