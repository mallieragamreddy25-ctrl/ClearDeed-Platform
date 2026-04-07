import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/investment_project.dart';
import '../services/api_client.dart';
import '../services/project_service.dart';
import '../utils/app_logger.dart';

// ==================== Project Filter State ====================

class ProjectFilter {
  final String? category;
  final String? city;
  final double? minInvestment;
  final double? maxInvestment;
  final double? minROI;
  final double? maxROI;
  final String? searchQuery;
  final int page;

  const ProjectFilter({
    this.category,
    this.city,
    this.minInvestment,
    this.maxInvestment,
    this.minROI,
    this.maxROI,
    this.searchQuery,
    this.page = 1,
  });

  ProjectFilter copyWith({
    String? category,
    String? city,
    double? minInvestment,
    double? maxInvestment,
    double? minROI,
    double? maxROI,
    String? searchQuery,
    int? page,
  }) {
    return ProjectFilter(
      category: category ?? this.category,
      city: city ?? this.city,
      minInvestment: minInvestment ?? this.minInvestment,
      maxInvestment: maxInvestment ?? this.maxInvestment,
      minROI: minROI ?? this.minROI,
      maxROI: maxROI ?? this.maxROI,
      searchQuery: searchQuery ?? this.searchQuery,
      page: page ?? this.page,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectFilter &&
          runtimeType == other.runtimeType &&
          category == other.category &&
          city == other.city &&
          minInvestment == other.minInvestment &&
          maxInvestment == other.maxInvestment &&
          minROI == other.minROI &&
          maxROI == other.maxROI &&
          searchQuery == other.searchQuery &&
          page == other.page;

  @override
  int get hashCode =>
      category.hashCode ^
      city.hashCode ^
      minInvestment.hashCode ^
      maxInvestment.hashCode ^
      minROI.hashCode ^
      maxROI.hashCode ^
      searchQuery.hashCode ^
      page.hashCode;
}

// ==================== Project List State ====================

class ProjectListState {
  final List<InvestmentProject> projects;
  final bool isLoading;
  final bool hasMore;
  final String? error;
  final ProjectFilter filter;
  final String? selectedProjectId;

  const ProjectListState({
    this.projects = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.error,
    this.filter = const ProjectFilter(),
    this.selectedProjectId,
  });

  ProjectListState copyWith({
    List<InvestmentProject>? projects,
    bool? isLoading,
    bool? hasMore,
    String? error,
    ProjectFilter? filter,
    String? selectedProjectId,
  }) {
    return ProjectListState(
      projects: projects ?? this.projects,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      error: error ?? this.error,
      filter: filter ?? this.filter,
      selectedProjectId: selectedProjectId ?? this.selectedProjectId,
    );
  }
}

// ==================== Providers ====================

/// Project service provider
final projectServiceProvider = Provider<ProjectService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ProjectService(apiClient: apiClient);
});

/// API Client provider
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

/// Project filter state provider
final projectFilterProvider =
    StateNotifierProvider<ProjectFilterNotifier, ProjectFilter>((ref) {
  return ProjectFilterNotifier();
});

/// Projects list state notifier
class ProjectFilterNotifier extends StateNotifier<ProjectFilter> {
  ProjectFilterNotifier() : super(const ProjectFilter());

  void updateCategory(String? category) {
    state = state.copyWith(category: category, page: 1);
  }

  void updateCity(String? city) {
    state = state.copyWith(city: city, page: 1);
  }

  void updateInvestmentRange(double? min, double? max) {
    state = state.copyWith(
      minInvestment: min,
      maxInvestment: max,
      page: 1,
    );
  }

  void updateROIRange(double? min, double? max) {
    state = state.copyWith(
      minROI: min,
      maxROI: max,
      page: 1,
    );
  }

  void updateSearchQuery(String? query) {
    state = state.copyWith(searchQuery: query, page: 1);
  }

  void clearFilters() {
    state = const ProjectFilter();
  }

  void nextPage() {
    state = state.copyWith(page: state.page + 1);
  }

  void resetPagination() {
    state = state.copyWith(page: 1);
  }
}

/// Projects list provider with full async management
final projectListProvider =
    StateNotifierProvider<ProjectListNotifier, AsyncValue<ProjectListState>>((ref) {
  final projectService = ref.watch(projectServiceProvider);
  final filter = ref.watch(projectFilterProvider);
  return ProjectListNotifier(projectService, filter);
});

/// Complete projects list state notifier with error handling
class ProjectListNotifier extends StateNotifier<AsyncValue<ProjectListState>> {
  final ProjectService _projectService;
  final ProjectFilter _filter;

  ProjectListNotifier(this._projectService, this._filter)
      : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() async {
    await refresh();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await _loadProjects(resetPage: true);
  }

  Future<void> _loadProjects({bool resetPage = false}) async {
    try {
      final currentState = state.maybeWhen(
        data: (data) => data,
        orElse: () => const ProjectListState(),
      );

      final filter = resetPage ? _filter.copyWith(page: 1) : _filter;

      state = AsyncValue.data(currentState.copyWith(isLoading: true, error: null));

      AppLogger.logFunctionEntry('_loadProjects', {
        'category': filter.category,
        'city': filter.city,
        'page': filter.page,
      });

      final projects = await _projectService.getProjects(
        page: filter.page,
        category: filter.category,
        city: filter.city,
        minInvestment: filter.minInvestment,
        maxInvestment: filter.maxInvestment,
        searchQuery: filter.searchQuery,
      );

      final isFirstPage = filter.page == 1;
      final newProjects =
          isFirstPage ? projects : [...currentState.projects, ...projects];

      state = AsyncValue.data(
        currentState.copyWith(
          projects: newProjects,
          isLoading: false,
          hasMore: projects.length >= 10,
          filter: filter,
        ),
      );

      AppLogger.logFunctionExit('_loadProjects', 'Loaded ${projects.length} projects');
    } catch (e, st) {
      AppLogger.error('Load projects error: $e', e);
      state = AsyncValue.error(e, st);
    }
  }

  void search(String query) {
    final newFilter = _filter.copyWith(searchQuery: query.isEmpty ? null : query, page: 1);
    _loadProjects();
  }

  Future<void> loadMoreProjects() async {
    final data = state.maybeWhen(
      data: (data) => data,
      orElse: () => null,
    );
    
    if (data == null || !data.hasMore || data.isLoading) return;
    
    await _loadProjects();
  }

  void selectProject(String projectId) {
    state = state.maybeWhen(
      data: (data) => AsyncValue.data(data.copyWith(selectedProjectId: projectId)),
      orElse: () => state,
    );
  }
}

/// Featured projects provider
final featuredProjectsProvider = FutureProvider<List<InvestmentProject>>((ref) async {
  final projectService = ref.watch(projectServiceProvider);
  AppLogger.logFunctionEntry('featuredProjectsProvider');
  
  final projects = await projectService.getFeaturedProjects();
  AppLogger.logFunctionExit('featuredProjectsProvider', 'Got ${projects.length} featured projects');
  
  return projects;
});

/// Single project detail provider
final projectDetailProvider =
    FutureProvider.family<InvestmentProject, String>((ref, projectId) async {
  final projectService = ref.watch(projectServiceProvider);
  AppLogger.logFunctionEntry('projectDetailProvider', {'projectId': projectId});
  
  final project = await projectService.getProjectById(projectId);
  AppLogger.logFunctionExit('projectDetailProvider', 'Got project: ${project.name}');
  
  return project;
});

/// Express interest provider
final expressInterestProvider =
    FutureProvider.family<bool, (String, double)>((ref, params) async {
  final projectService = ref.watch(projectServiceProvider);
  final (projectId, amount) = params;
  
  AppLogger.logFunctionEntry('expressInterestProvider', {
    'projectId': projectId,
    'amount': amount,
  });
  
  final success = await projectService.expressInterest(projectId, amount);
  AppLogger.logFunctionExit('expressInterestProvider', 'Interest expressed: $success');
  
  return success;
});
