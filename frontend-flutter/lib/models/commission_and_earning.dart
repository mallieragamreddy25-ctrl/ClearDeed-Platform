import 'package:json_annotation/json_annotation.dart';

part 'commission_and_earning.g.dart';

/// Commission earned by an agent
@JsonSerializable()
class Commission {
  final String id;
  final String agentId;
  final String dealId;
  final String propertyId;
  final String buyerId;
  final double amount;
  final String currency;
  final double percentage;
  final String status; // pending, approved, paid
  final DateTime earnedDate;
  final DateTime? paidDate;
  final String? paymentMethod;
  final String? transactionId;
  final String? notes;

  Commission({
    required this.id,
    required this.agentId,
    required this.dealId,
    required this.propertyId,
    required this.buyerId,
    required this.amount,
    required this.currency,
    required this.percentage,
    required this.status,
    required this.earnedDate,
    this.paidDate,
    this.paymentMethod,
    this.transactionId,
    this.notes,
  });

  factory Commission.fromJson(Map<String, dynamic> json) =>
      _$CommissionFromJson(json);

  Map<String, dynamic> toJson() => _$CommissionToJson(this);

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isPaid => status == 'paid';
}

/// Agent earnings dashboard
@JsonSerializable()
class AgentEarnings {
  final String agentId;
  final double totalEarnings;
  final double pendingEarnings;
  final double approvedEarnings;
  final double paidEarnings;
  final int totalDeals;
  final int dealsThisMonth;
  final List<Commission> commissions;
  final List<MonthlyEarning>? monthlyBreakdown;

  AgentEarnings({
    required this.agentId,
    required this.totalEarnings,
    required this.pendingEarnings,
    required this.approvedEarnings,
    required this.paidEarnings,
    required this.totalDeals,
    required this.dealsThisMonth,
    required this.commissions,
    this.monthlyBreakdown,
  });

  factory AgentEarnings.fromJson(Map<String, dynamic> json) =>
      _$AgentEarningsFromJson(json);

  Map<String, dynamic> toJson() => _$AgentEarningsToJson(this);
}

@JsonSerializable()
class MonthlyEarning {
  final String month; // YYYY-MM
  final double amount;
  final int dealCount;

  MonthlyEarning({
    required this.month,
    required this.amount,
    required this.dealCount,
  });

  factory MonthlyEarning.fromJson(Map<String, dynamic> json) =>
      _$MonthlyEarningFromJson(json);

  Map<String, dynamic> toJson() => _$MonthlyEarningToJson(this);
}

/// Deal model
@JsonSerializable()
class Deal {
  final String id;
  final String propertyId;
  final String sellerId;
  final String buyerId;
  final String agentId;
  final double dealAmount;
  final String currency;
  final String status; // negotiation, offer_sent, accepted, completed, cancelled
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? notes;
  final List<DealDocument> documents;
  final DealTimeline timeline;

  Deal({
    required this.id,
    required this.propertyId,
    required this.sellerId,
    required this.buyerId,
    required this.agentId,
    required this.dealAmount,
    required this.currency,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.notes,
    required this.documents,
    required this.timeline,
  });

  factory Deal.fromJson(Map<String, dynamic> json) =>
      _$DealFromJson(json);

  Map<String, dynamic> toJson() => _$DealToJson(this);

  bool get isActive =>
      status != 'completed' && status != 'cancelled';
  bool get isCompleted => status == 'completed';
}

@JsonSerializable()
class DealDocument {
  final String id;
  final String type; // agreement, id_proof, address_proof, etc.
  final String fileUrl;
  final String fileName;
  final DateTime uploadedAt;
  final String uploadedBy; // seller, buyer, agent
  final bool isVerified;

  DealDocument({
    required this.id,
    required this.type,
    required this.fileUrl,
    required this.fileName,
    required this.uploadedAt,
    required this.uploadedBy,
    required this.isVerified,
  });

  factory DealDocument.fromJson(Map<String, dynamic> json) =>
      _$DealDocumentFromJson(json);

  Map<String, dynamic> toJson() => _$DealDocumentToJson(this);
}

@JsonSerializable()
class DealTimeline {
  final DateTime createdAt;
  final DateTime? offerSentAt;
  final DateTime? acceptedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;

  DealTimeline({
    required this.createdAt,
    this.offerSentAt,
    this.acceptedAt,
    this.completedAt,
    this.cancelledAt,
  });

  factory DealTimeline.fromJson(Map<String, dynamic> json) =>
      _$DealTimelineFromJson(json);

  Map<String, dynamic> toJson() => _$DealTimelineToJson(this);
}

/// Referral and sharing model
@JsonSerializable()
class ReferralLink {
  final String id;
  final String agentId;
  final String code;
  final String fullUrl;
  final int clickCount;
  final int conversionCount;
  final double commissionRate;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final bool isActive;

  ReferralLink({
    required this.id,
    required this.agentId,
    required this.code,
    required this.fullUrl,
    required this.clickCount,
    required this.conversionCount,
    required this.commissionRate,
    required this.createdAt,
    this.expiresAt,
    required this.isActive,
  });

  factory ReferralLink.fromJson(Map<String, dynamic> json) =>
      _$ReferralLinkFromJson(json);

  Map<String, dynamic> toJson() => _$ReferralLinkToJson(this);

  double get conversionRate =>
      clickCount > 0 ? (conversionCount / clickCount) * 100 : 0;
}
