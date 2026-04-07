import 'package:json_annotation/json_annotation.dart';

part 'investment_project.g.dart';

/// Investment project model
@JsonSerializable()
class InvestmentProject {
  final String id;
  final String name;
  final String description;
  final String category;
  final String location;
  final String city;
  final double totalBudget;
  final double raisedAmount;
  final double minInvestment;
  final double maxInvestment;
  final double expectedReturn;
  final int expectedReturnMonths;
  final String returnType; // monthly, quarterly, annual, lumpsum
  final String status; // planning, active, completed, on_hold
  final DateTime startDate;
  final DateTime? endDate;
  final List<String> projectImages;
  final String? projectDocument;
  final List<ProjectMilestone> milestones;
  final int investorCount;
  final double commissionPercentage;
  final List<ProjectReturn> returnHistory;
  final bool isActive;
  final DateTime createdAt;

  InvestmentProject({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.location,
    required this.city,
    required this.totalBudget,
    required this.raisedAmount,
    required this.minInvestment,
    required this.maxInvestment,
    required this.expectedReturn,
    required this.expectedReturnMonths,
    required this.returnType,
    required this.status,
    required this.startDate,
    this.endDate,
    required this.projectImages,
    this.projectDocument,
    required this.milestones,
    required this.investorCount,
    required this.commissionPercentage,
    required this.returnHistory,
    required this.isActive,
    required this.createdAt,
  });

  factory InvestmentProject.fromJson(Map<String, dynamic> json) =>
      _$InvestmentProjectFromJson(json);

  Map<String, dynamic> toJson() => _$InvestmentProjectToJson(this);

  double get progressPercentage =>
      (raisedAmount / totalBudget * 100).clamp(0, 100).toDouble();
  double get remainingAmount => totalBudget - raisedAmount;
}

@JsonSerializable()
class ProjectMilestone {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final bool isCompleted;
  final DateTime? completedDate;
  final double percentageOfBudget;

  ProjectMilestone({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.isCompleted,
    this.completedDate,
    required this.percentageOfBudget,
  });

  factory ProjectMilestone.fromJson(Map<String, dynamic> json) =>
      _$ProjectMilestoneFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectMilestoneToJson(this);
}

@JsonSerializable()
class ProjectReturn {
  final String id;
  final double amount;
  final DateTime distributedDate;
  final String period; // Q1 2024, etc.
  final double returnPercentage;

  ProjectReturn({
    required this.id,
    required this.amount,
    required this.distributedDate,
    required this.period,
    required this.returnPercentage,
  });

  factory ProjectReturn.fromJson(Map<String, dynamic> json) =>
      _$ProjectReturnFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectReturnToJson(this);
}

/// Investment in a project by an investor
@JsonSerializable()
class ProjectInvestment {
  final String id;
  final String projectId;
  final String investorId;
  final double amount;
  final int units;
  final DateTime investedAt;
  final double currentValue;
  final double totalReturnsReceived;
  final List<ProjectReturn> returns;
  final bool isActive;

  ProjectInvestment({
    required this.id,
    required this.projectId,
    required this.investorId,
    required this.amount,
    required this.units,
    required this.investedAt,
    required this.currentValue,
    required this.totalReturnsReceived,
    required this.returns,
    required this.isActive,
  });

  factory ProjectInvestment.fromJson(Map<String, dynamic> json) =>
      _$ProjectInvestmentFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectInvestmentToJson(this);

  double get gain => currentValue - amount;
  double get gainPercentage =>
      (gain / amount * 100).clamp(-100, 10000).toDouble();
}
