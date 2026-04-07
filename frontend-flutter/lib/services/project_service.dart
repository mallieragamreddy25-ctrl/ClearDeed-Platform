import 'package:dio/dio.dart';
import 'api_client.dart';
import '../models/investment_project.dart';
import '../utils/app_logger.dart';
import '../utils/constants.dart';

/// Exception for project related errors
class ProjectException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  ProjectException({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() => message;
}

/// Project service for handling investment project API calls
class ProjectService {
  final ApiClient _apiClient;

  ProjectService({required ApiClient apiClient}) : _apiClient = apiClient;

  // ==================== Project List ====================

  /// Get list of investment projects with optional filters
  /// Returns list of InvestmentProject objects
  Future<List<InvestmentProject>> getProjects({
    int page = 1,
    String? category,
    String? city,
    double? minInvestment,
    double? maxInvestment,
    String? searchQuery,
  }) async {
    try {
      AppLogger.logFunctionEntry('getProjects', {
        'page': page,
        'category': category,
        'city': city,
      });

      final queryParams = {
        'page': page,
        'limit': AppConstants.propertyPageSize,
        if (category != null) 'category': category,
        if (city != null) 'city': city,
        if (minInvestment != null) 'min_investment': minInvestment,
        if (maxInvestment != null) 'max_investment': maxInvestment,
        if (searchQuery != null) 'search': searchQuery,
      };

      final response = await _apiClient.get(
        '/v1/investment-projects',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        List<InvestmentProject> projects = [];
        final data = response.data['data'] ?? response.data;

        if (data is List) {
          projects = data
              .map((item) => InvestmentProject.fromJson(
                  item is Map<String, dynamic> ? item : {}))
              .toList();
        } else if (data is Map && data['projects'] != null) {
          projects = List<Map<String, dynamic>>.from(data['projects'])
              .map((item) => InvestmentProject.fromJson(item))
              .toList();
        }

        AppLogger.logFunctionExit('getProjects', 'Got ${projects.length} projects');
        return projects;
      } else {
        throw ProjectException(
          message: 'Failed to fetch projects',
          code: 'GET_PROJECTS_FAILED',
          originalError: response.data,
        );
      }
    } on DioException catch (e) {
      AppLogger.error('Get projects failed: ${e.message}', e);
      throw ProjectException(
        message: _handleDioError(e),
        code: 'GET_PROJECTS_ERROR',
        originalError: e,
      );
    } catch (e) {
      AppLogger.error('Get projects error: $e', e);
      if (e is ProjectException) rethrow;
      throw ProjectException(
        message: 'An unexpected error occurred',
        code: 'GET_PROJECTS_UNKNOWN',
        originalError: e,
      );
    }
  }

  /// Get project details by ID
  /// Returns InvestmentProject object
  Future<InvestmentProject> getProjectById(String projectId) async {
    try {
      AppLogger.logFunctionEntry('getProjectById', {'projectId': projectId});

      final response = await _apiClient.get(
        '/v1/investment-projects/$projectId',
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] ?? response.data;
        final project = InvestmentProject.fromJson(
            data is Map<String, dynamic> ? data : {});

        AppLogger.logFunctionExit('getProjectById', 'Got project: ${project.name}');
        return project;
      } else {
        throw ProjectException(
          message: 'Failed to fetch project details',
          code: 'GET_PROJECT_FAILED',
          originalError: response.data,
        );
      }
    } on DioException catch (e) {
      AppLogger.error('Get project failed: ${e.message}', e);
      throw ProjectException(
        message: _handleDioError(e),
        code: 'GET_PROJECT_ERROR',
        originalError: e,
      );
    } catch (e) {
      AppLogger.error('Get project error: $e', e);
      if (e is ProjectException) rethrow;
      throw ProjectException(
        message: 'An unexpected error occurred',
        code: 'GET_PROJECT_UNKNOWN',
        originalError: e,
      );
    }
  }

  /// Express interest in a project
  /// Returns success status
  Future<bool> expressInterest(String projectId, double investmentAmount) async {
    try {
      AppLogger.logFunctionEntry('expressInterest', {
        'projectId': projectId,
        'amount': investmentAmount,
      });

      final response = await _apiClient.post(
        '/v1/investment-projects/$projectId/express-interest',
        data: {
          'investment_amount': investmentAmount,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppLogger.logFunctionExit('expressInterest', 'Interest expressed successfully');
        return true;
      } else {
        throw ProjectException(
          message: 'Failed to express interest',
          code: 'EXPRESS_INTEREST_FAILED',
          originalError: response.data,
        );
      }
    } on DioException catch (e) {
      AppLogger.error('Express interest failed: ${e.message}', e);
      throw ProjectException(
        message: _handleDioError(e),
        code: 'EXPRESS_INTEREST_ERROR',
        originalError: e,
      );
    } catch (e) {
      AppLogger.error('Express interest error: $e', e);
      if (e is ProjectException) rethrow;
      throw ProjectException(
        message: 'An unexpected error occurred',
        code: 'EXPRESS_INTEREST_UNKNOWN',
        originalError: e,
      );
    }
  }

  /// Get featured/trending projects
  /// Returns list of featured InvestmentProject objects
  Future<List<InvestmentProject>> getFeaturedProjects() async {
    try {
      AppLogger.logFunctionEntry('getFeaturedProjects');

      final response = await _apiClient.get(
        '/v1/investment-projects/featured',
      );

      if (response.statusCode == 200) {
        List<InvestmentProject> projects = [];
        final data = response.data['data'] ?? response.data;

        if (data is List) {
          projects = data
              .map((item) => InvestmentProject.fromJson(
                  item is Map<String, dynamic> ? item : {}))
              .toList();
        }

        AppLogger.logFunctionExit('getFeaturedProjects', 'Got ${projects.length} projects');
        return projects;
      } else {
        throw ProjectException(
          message: 'Failed to fetch featured projects',
          code: 'GET_FEATURED_FAILED',
          originalError: response.data,
        );
      }
    } on DioException catch (e) {
      AppLogger.error('Get featured projects failed: ${e.message}', e);
      throw ProjectException(
        message: _handleDioError(e),
        code: 'GET_FEATURED_ERROR',
        originalError: e,
      );
    } catch (e) {
      AppLogger.error('Get featured projects error: $e', e);
      if (e is ProjectException) rethrow;
      throw ProjectException(
        message: 'An unexpected error occurred',
        code: 'GET_FEATURED_UNKNOWN',
        originalError: e,
      );
    }
  }

  /// Handle Dio error responses
  String _handleDioError(DioException e) {
    if (e.response != null) {
      final statusCode = e.response!.statusCode;
      final message = e.response!.data['message'] ?? 'API Error';

      if (statusCode == 400) {
        return 'Invalid request: $message';
      } else if (statusCode == 401) {
        return 'Unauthorized - Please login again';
      } else if (statusCode == 403) {
        return 'Forbidden - You do not have access';
      } else if (statusCode == 404) {
        return 'Project not found';
      } else if (statusCode == 429) {
        return 'Too many requests - Please try again later';
      } else if (statusCode == 500) {
        return 'Server error - Please try again later';
      }
    } else if (e.type == DioExceptionType.connectionTimeout) {
      return 'Connection timeout - Please check your network';
    } else if (e.type == DioExceptionType.receiveTimeout) {
      return 'Request timeout - Please try again';
    } else if (e.type == DioExceptionType.connectionError) {
      return 'Network error - Please check your internet connection';
    }

    return 'An error occurred - Please try again';
  }
}
