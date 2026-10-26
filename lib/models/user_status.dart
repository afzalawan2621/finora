enum UserStatus {
  pending,
  approved,
  rejected,
  blocked;

  static UserStatus fromString(String? value) {
    switch (value) {
      case 'approved':
        return UserStatus.approved;
      case 'rejected':
        return UserStatus.rejected;
      case 'blocked':
        return UserStatus.blocked;
      case 'pending':
      default:
        return UserStatus.pending;
    }
  }

  String toFirestore() => name;

  bool get isApproved => this == UserStatus.approved;
  bool get isPending => this == UserStatus.pending;
  bool get isRejected => this == UserStatus.rejected;
  bool get isBlocked => this == UserStatus.blocked;
}

enum UserRole {
  admin,
  manager,
  user;

  static UserRole fromString(String? value) {
    switch (value) {
      case 'manager':
        return UserRole.manager;
      case 'user':
        return UserRole.user;
      case 'admin':
      default:
        return UserRole.admin;
    }
  }

  String toFirestore() => name;

  bool get isAdmin => this == UserRole.admin;
  bool get isManager => this == UserRole.manager;
  bool get isUser => this == UserRole.user;

  // ─── Permissions ───
  bool get canAdd => true;
  bool get canEdit => this == UserRole.admin;
  bool get canDelete => this == UserRole.admin;
}