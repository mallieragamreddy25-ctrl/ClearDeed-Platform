import 'package:json_annotation/json_annotation.dart';

part 'deal.g.dart';

/// Deal model - represents a real estate transaction
@JsonSerializable()
class Deal {
  final String id;
  final String buyerId;
  final String sellerId;
  final String? agentId;
  final String propertyId;
  final String propertyTitle;
  final String propertyLocation;
  final double propertyPrice;
  final String dealStatus; // proposed, negotiating, accepted, completed, cancelled
  final double offeredPrice;
  final double? agentCommission;
  final double? referralCommission;
  final String? referralPartnerId;
  final String commissionStatus; // pending, approved, paid
  final DateTime createdAt;
  final DateTime? closedAt;
  final String? notes;
  final List<DealTimeline> timeline;
  final Map<String, dynamic>? documents;

  Deal({
    required this.id,
    required this.buyerId,
    required this.sellerId,
    this.agentId,
    required this.propertyId,
    required this.propertyTitle,
    required this.propertyLocation,
    required this.propertyPrice,
    required this.dealStatus,
    required this.offeredPrice,
    this.agentCommission,
    this.referralCommission,
    this.referralPartnerId,
    required this.commissionStatus,
    required this.createdAt,
    this.closedAt,
    this.notes,
    required this.timeline,
    this.documents,
  });

  factory Deal.fromJson(Map<String, dynamic> json) => _$DealFromJson(json);

  Map<String, dynamic> toJson() => _$DealToJson(this);

  bool get isCompleted => dealStatus == 'completed';
  bool get isCancelled => dealStatus == 'cancelled';
  bool get isPending => dealStatus == 'proposed' || dealStatus == 'negotiating';
  bool get isActive => !isCompleted && !isCancelled;
  
  double get totalCommission => (agentCommission ?? 0) + (referralCommission ?? 0);
  String get statusLabel {
    switch (dealStatus) {
      case 'proposed':
        return 'Proposed';
      case 'negotiating':
        return 'Negotiating';
      case 'accepted':
        return 'Accepted';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return dealStatus;
    }
  }
}

@JsonSerializable()
class DealTimeline {
  final String id;
  final String event; // proposed, counter_offered, accepted, completed, cancelled
  final String description;
  final DateTime timestamp;
  final String? updatedBy;

  DealTimeline({
    required this.id,
    required this.event,
    required this.description,
    required this.timestamp,
    this.updatedBy,
  });

  factory DealTimeline.fromJson(Map<String, dynamic> json) =>
      _$DealTimelineFromJson(json);

  Map<String, dynamic> toJson() => _$DealTimelineToJson(this);
}

/// Deal statistics
@JsonSerializable()
class DealStats {
  final int totalDeals;
  final int completedDeals;
  final int activeDealCount;
  final double totalCommissionEarned;
  final double pendingCommission;
  final double successRate; // percentage

  DealStats({
    required this.totalDeals,
    required this.completedDeals,
    required this.activeDealCount,
    required this.totalCommissionEarned,
    required this.pendingCommission,
    required this.successRate,
  });

  factory DealStats.fromJson(Map<String, dynamic> json) =>
      _$DealStatsFromJson(json);

  Map<String, dynamic> toJson() => _$DealStatsToJson(this);
}
