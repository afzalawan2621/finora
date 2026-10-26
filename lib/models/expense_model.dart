enum ExpenseStatus {
  paid,
  pending;

  static ExpenseStatus fromString(String? value) {
    return value == 'pending'
        ? ExpenseStatus.pending
        : ExpenseStatus.paid;
  }

  String toFirestore() => name;
}

class ExpenseModel {
  final String id;
  final String ownerId; // Admin uid (jis admin ka data)
  final String createdBy; // Jis user ne create kiya (admin ya manager)
  final String title;
  final String? description;
  final String category; // 'salaries', 'rent', 'bills', etc.
  final double amount;
  final String paymentMethod;
  final ExpenseStatus status;
  final DateTime date;
  final DateTime createdAt;

  ExpenseModel({
    required this.id,
    required this.ownerId,
    required this.createdBy,
    required this.title,
    this.description,
    required this.category,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    required this.date,
    required this.createdAt,
  });

  factory ExpenseModel.fromMap(String id, Map<String, dynamic> map) {
    return ExpenseModel(
      id: id,
      ownerId: map['ownerId'] ?? '',
      createdBy: map['createdBy'] ?? '',
      title: map['title'] ?? '',
      description: map['description'],
      category: map['category'] ?? 'other',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: map['paymentMethod'] ?? 'Cash',
      status: ExpenseStatus.fromString(map['status']),
      date: _parseDate(map['date']) ?? DateTime.now(),
      createdAt: _parseDate(map['createdAt']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'createdBy': createdBy,
      'title': title,
      'description': description,
      'category': category,
      'amount': amount,
      'paymentMethod': paymentMethod,
      'status': status.toFirestore(),
      'date': date.toIso8601String(),
      'createdAt': DateTime.now().toIso8601String(),
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