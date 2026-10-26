import 'user_status.dart';

class UserModel {
  final String uid;
  final String fullName;
  final String companyName;
  final String email;
  final String phone;
  final UserRole role;
  final UserStatus status;

  /// Admin uid — jis admin ke under ye user hai
  /// (Admin ke liye khud ka uid, manager/user ke liye admin ka uid)
  final String ownerId;

  /// Jis admin ne create kiya (manager/user ke liye)
  final String? createdBy;

  /// Plain password — **sirf admin ke liye** (create ke baad display)
  final String? passwordPlain;

  final DateTime createdAt;
  final DateTime? approvedAt;
  final String? approvedBy;
  final DateTime? rejectedAt;
  final String? rejectionReason;

  UserModel({
    required this.uid,
    required this.fullName,
    required this.companyName,
    required this.email,
    required this.phone,
    required this.role,
    required this.status,
    required this.ownerId,
    this.createdBy,
    this.passwordPlain,
    required this.createdAt,
    this.approvedAt,
    this.approvedBy,
    this.rejectedAt,
    this.rejectionReason,
  });

  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    return UserModel(
      uid: uid,
      fullName: map['fullName'] ?? '',
      companyName: map['companyName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      role: UserRole.fromString(map['role']),
      status: UserStatus.fromString(map['status']),
      ownerId: map['ownerId'] ?? uid,
      createdBy: map['createdBy'],
      passwordPlain: map['passwordPlain'],
      createdAt: _parseDate(map['createdAt']) ?? DateTime.now(),
      approvedAt: _parseDate(map['approvedAt']),
      approvedBy: map['approvedBy'],
      rejectedAt: _parseDate(map['rejectedAt']),
      rejectionReason: map['rejectionReason'],
    );
  }

  Map<String, dynamic> toSignupMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'companyName': companyName,
      'email': email,
      'phone': phone,
      'role': role.toFirestore(),
      'status': status.toFirestore(),
      'ownerId': ownerId,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  Map<String, dynamic> toCreateUserMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'companyName': companyName,
      'email': email,
      'phone': phone,
      'role': role.toFirestore(),
      'status': status.toFirestore(),
      'ownerId': ownerId,
      'createdBy': createdBy,
      'passwordPlain': passwordPlain,
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

  UserModel copyWith({
    String? uid,
    String? fullName,
    String? companyName,
    String? email,
    String? phone,
    UserRole? role,
    UserStatus? status,
    String? ownerId,
    String? createdBy,
    String? passwordPlain,
    DateTime? createdAt,
    DateTime? approvedAt,
    String? approvedBy,
    DateTime? rejectedAt,
    String? rejectionReason,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      companyName: companyName ?? this.companyName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      status: status ?? this.status,
      ownerId: ownerId ?? this.ownerId,
      createdBy: createdBy ?? this.createdBy,
      passwordPlain: passwordPlain ?? this.passwordPlain,
      createdAt: createdAt ?? this.createdAt,
      approvedAt: approvedAt ?? this.approvedAt,
      approvedBy: approvedBy ?? this.approvedBy,
      rejectedAt: rejectedAt ?? this.rejectedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }
}