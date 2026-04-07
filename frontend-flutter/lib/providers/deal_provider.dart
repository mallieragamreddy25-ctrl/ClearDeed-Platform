import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/deal.dart';
import '../services/api_client.dart';
import '../services/deal_service.dart';
import '../utils/app_logger.dart';

// ==================== Deal Filter State ====================

class DealFilter {
  final String? status; // proposed, negotiating, accepted, completed, cancelled
  final String? role; // buyer, seller, agent
  final int page;

  const DealFilter({
    this.status,
    this.role,
    this.page = 1,
  });

  DealFilter copyWith({
    String? status,
    String? role,
    int? page,
  }) {
    return DealFilter(
      status: status ?? this.status,
      role: role ?? this.role,
      page: page ?? this.page,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DealFilter &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          role == other.role &&
          page == other.page;

  @override
  int get hashCode => status.hashCode ^ role.hashCode ^ page.hashCode;
}

// ==================== Deal List State ====================

class DealListState {
  final List<Deal> deals;
  final bool isLoading;
  final bool hasMore;
  final String? error;
  final DealFilter filter;
  final String? selectedDealId;

  const DealListState({
    this.deals = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.error,
    this.filter = const DealFilter(),
    this.selectedDealId,
  });

  DealListState copyWith({
    List<Deal>? deals,
    bool? isLoading,
    bool? hasMore,
    String? error,
    DealFilter? filter,
    String? selectedDealId,
  }) {
    return DealListState(
      deals: deals ?? this.deals,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      error: error ?? this.error,
      filter: filter ?? this.filter,
      selectedDealId: selectedDealId ?? this.selectedDealId,
    );
  }
}

// ==================== Deal Stats ====================

class DealStats {
  final int totalDeals;
  final int activeDeal;
  final int completedDeals;
  final int cancelledDeals;
  final double totalValue;

  DealStats({
    required this.totalDeals,
    required this.activeDeal,
    required this.completedDeals,
    required this.cancelledDeals,
    required this.totalValue,
  });
}

// ==================== Providers ====================

/// Deal service provider
final dealServiceProvider = Provider<DealService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return DealService(apiClient: apiClient);
});

/// API client provider
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

/// Deal filter state provider
final dealFilterProvider = StateNotifierProvider<DealFilterNotifier, DealFilter>((ref) {
  return DealFilterNotifier();
});

/// Deal filter notifier
class DealFilterNotifier extends StateNotifier<DealFilter> {
  DealFilterNotifier() : super(const DealFilter());

  void setStatus(String? status) {
    state = state.copyWith(status: status, page: 1);
  }

  void setRole(String? role) {
    state = state.copyWith(role: role, page: 1);
  }

  void clearFilters() {
    state = const DealFilter();
  }

  void nextPage() {
    state = state.copyWith(page: state.page + 1);
  }

  void resetPage() {
    state = state.copyWith(page: 1);
  }
}

/// Deal list state notifier
class DealListNotifier extends StateNotifier<DealListState> {
  final DealService _dealService;

  DealListNotifier(this._dealService) : super(const DealListState());

  Future<void> loadDeals({String? status, String? role}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      AppLogger.logFunctionEntry('loadDeals', {
        'status': status,
        'role': role,
      });

      final deals = await _dealService.getDeals(
        page: 1,
        status: status,
        role: role,
      );

      state = state.copyWith(
        deals: deals,
        isLoading: false,
        hasMore: deals.length >= 20,
        filter: state.filter.copyWith(status: status, role: role, page: 1),
      );

      AppLogger.logFunctionExit('loadDeals', 'Loaded ${deals.length} deals');
    } catch (e) {
      AppLogger.error('Failed to load deals: $e', e);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    await loadDeals(
      status: state.filter.status,
      role: state.filter.role,
    );
  }

  Future<void> loadMoreDeals() async {
    if (!state.hasMore || state.isLoading) return;

    try {
      final nextPage = state.filter.page + 1;
      state = state.copyWith(isLoading: true);
      AppLogger.logFunctionEntry('loadMoreDeals', {'page': nextPage});

      final moreDeals = await _dealService.getDeals(
        page: nextPage,
        status: state.filter.status,
        role: state.filter.role,
      );

      final allDeals = [...state.deals, ...moreDeals];
      state = state.copyWith(
        deals: allDeals,
        isLoading: false,
        hasMore: moreDeals.length >= 20,
        filter: state.filter.copyWith(page: nextPage),
      );

      AppLogger.logFunctionExit('loadMoreDeals', 'Loaded ${moreDeals.length} more deals');
    } catch (e) {
      AppLogger.error('Failed to load more deals: $e', e);
      state = state.copyWith(isLoading: false);
    }
  }

  void selectDeal(String dealId) {
    state = state.copyWith(selectedDealId: dealId);
  }

  Future<void> updateDealStatus(String dealId, String newStatus) async {
    try {
      AppLogger.logFunctionEntry('updateDealStatus', {
        'dealId': dealId,
        'newStatus': newStatus,
      });

      await _dealService.updateDealStatus(dealId, newStatus);

      // Update local state
      final updatedDeals = state.deals.map((deal) {
        if (deal.id == dealId) {
          return Deal(
            id: deal.id,
            buyerId: deal.buyerId,
            sellerId: deal.sellerId,
            agentId: deal.agentId,
            propertyId: deal.propertyId,
            propertyTitle: deal.propertyTitle,
            propertyLocation: deal.propertyLocation,
            propertyPrice: deal.propertyPrice,
            dealStatus: newStatus,
            offeredPrice: deal.offeredPrice,
            agentCommission: deal.agentCommission,
            referralCommission: deal.referralCommission,
            referralPartnerId: deal.referralPartnerId,
            commissionStatus: deal.commissionStatus,
            createdAt: deal.createdAt,
            closedAt: newStatus == 'completed' ? DateTime.now() : deal.closedAt,
            notes: deal.notes,
            timeline: deal.timeline,
            documents: deal.documents,
          );
        }
        return deal;
      }).toList();

      state = state.copyWith(deals: updatedDeals);
      AppLogger.logFunctionExit('updateDealStatus', 'Status updated');
    } catch (e) {
      AppLogger.error('Failed to update deal status: $e', e);
    }
  }
}

/// Deal list provider with async value
final dealsProvider =
    StateNotifierProvider<DealListNotifier, AsyncValue<DealListState>>((ref) {
  final dealService = ref.watch(dealServiceProvider);
  return DealListNotifier(dealService);
});

/// Deals list notifier for async state management
class DealsAsyncNotifier extends StateNotifier<AsyncValue<DealListState>> {
  final DealService _dealService;
  final DealFilter _filter;

  DealsAsyncNotifier(this._dealService, this._filter)
      : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() async {
    await loadDeals();
  }

  Future<void> loadDeals() async {
    try {
      state = const AsyncValue.loading();
      AppLogger.logFunctionEntry('loadDeals_async', {
        'status': _filter.status,
        'role': _filter.role,
      });

      final deals = await _dealService.getDeals(
        page: _filter.page,
        status: _filter.status,
        role: _filter.role,
      );

      state = AsyncValue.data(
        DealListState(
          deals: deals,
          isLoading: false,
          hasMore: deals.length >= 20,
          filter: _filter,
        ),
      );

      AppLogger.logFunctionExit('loadDeals_async', 'Loaded ${deals.length} deals');
    } catch (e, st) {
      AppLogger.error('Load deals error: $e', e);
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    await loadDeals();
  }
}

/// Deal detail provider
final dealDetailProvider =
    FutureProvider.family<Deal, String>((ref, dealId) async {
  final dealService = ref.watch(dealServiceProvider);
  AppLogger.logFunctionEntry('dealDetailProvider', {'dealId': dealId});

  final deal = await dealService.getDealDetail(dealId);
  AppLogger.logFunctionExit('dealDetailProvider', 'Got deal: ${deal.propertyTitle}');

  return deal;
});

/// Deal stats provider
final dealStatsProvider = FutureProvider<DealStats>((ref) async {
  final dealService = ref.watch(dealServiceProvider);
  AppLogger.logFunctionEntry('dealStatsProvider');

  final stats = await dealService.getDealStats();
  AppLogger.logFunctionExit('dealStatsProvider', 'Got deal stats');

  return stats;
});

/// User's deals (buyer/seller view)
final userDealsProvider = FutureProvider<List<Deal>>((ref) async {
  final dealService = ref.watch(dealServiceProvider);
  AppLogger.logFunctionEntry('userDealsProvider');

  final deals = await dealService.getUserDeals();
  AppLogger.logFunctionExit('userDealsProvider', 'Got ${deals.length} user deals');

  return deals;
});

/// Deal commission provider
final dealCommissionProvider = FutureProvider.family<double, String>((ref, dealId) async {
  final dealService = ref.watch(dealServiceProvider);
  AppLogger.logFunctionEntry('dealCommissionProvider', {'dealId': dealId});

  final commission = await dealService.getDealCommission(dealId);
  AppLogger.logFunctionExit('dealCommissionProvider', 'Commission: $commission');

  return commission;
});
  }

  void clearFilters() {
    state = const DealFilter();
  }
}
