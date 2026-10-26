class BudgetModel {
  final String id;
  final String ownerId;
  final String createdBy;

  /// Month key — format: "2026-10" (year-month)
  final String monthKey;

  /// Total monthly budget
  final double totalBudget;

  /// Category-wise limits
  /// Example: { 'salaries': 1800000, 'rent': 100000 }
  final Map<String, double> categoryLimits;

  final DateTime createdAt;
  final DateTime updatedAt;

  BudgetModel({
    required this.id,
    required this.ownerId,
    required this.createdBy,
    required this.monthKey,
    required this.totalBudget,
    required this.categoryLimits,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BudgetModel.fromMap(String id, Map<String, dynamic> map) {
    return BudgetModel(
      id: id,
      ownerId: map['ownerId'] ?? '',
      createdBy: map['createdBy'] ?? '',
      monthKey: map['monthKey'] ?? '',
      totalBudget: (map['totalBudget'] as num?)?.toDouble() ?? 0.0,
      categoryLimits: (map['categoryLimits'] as Map<String, dynamic>?)
          ?.map((k, v) => MapEntry(k, (v as num).toDouble())) ??
          {},
      createdAt: _parseDate(map['createdAt']) ?? DateTime.now(),
      updatedAt: _parseDate(map['updatedAt']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'createdBy': createdBy,
      'monthKey': monthKey,
      'totalBudget': totalBudget,
      'categoryLimits': categoryLimits,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    try {
      return (value as dynamic).toDate() as DateTime?;
    } catch (_) {
      return null;
    }
  }
}