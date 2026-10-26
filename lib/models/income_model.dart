enum IncomeStatus {
  received,
  pending;

  static IncomeStatus fromString(String? value) {
    return value == 'pending'
        ? IncomeStatus.pending
        : IncomeStatus.received;
  }

  String toFirestore() => name;
}

class IncomeModel {
  final String id;
  final String ownerId;
  final String createdBy;
  final String clientName;
  final String? projectName;
  final String? description;
  final String incomeType; // 'client_payment', 'new_project', 'retainer', 'other'
  final double amount;
  final String paymentMethod;
  final IncomeStatus status;
  final DateTime date;
  final DateTime createdAt;

  IncomeModel({
    required this.id,
    required this.ownerId,
    required this.createdBy,
    required this.clientName,
    this.projectName,
    this.description,
    required this.incomeType,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    required this.date,
    required this.createdAt,
  });

  factory IncomeModel.fromMap(String id, Map<String, dynamic> map) {
    return IncomeModel(
      id: id,
      ownerId: map['ownerId'] ?? '',
      createdBy: map['createdBy'] ?? '',
      clientName: map['clientName'] ?? '',
      projectName: map['projectName'],
      description: map['description'],
      incomeType: map['incomeType'] ?? 'other',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: map['paymentMethod'] ?? 'Bank',
      status: IncomeStatus.fromString(map['status']),
      date: _parseDate(map['date']) ?? DateTime.now(),
      createdAt: _parseDate(map['createdAt']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'createdBy': createdBy,
      'clientName': clientName,
      'projectName': projectName,
      'description': description,
      'incomeType': incomeType,
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