// lib/features/user/domain/enums/account_status.dart

enum AccountStatus {
  active,
  inactive,
  suspended,
  pending;

  String get displayName {
    switch (this) {
      case AccountStatus.active:
        return 'Active';
      case AccountStatus.inactive:
        return 'Inactive';
      case AccountStatus.suspended:
        return 'Suspended';
      case AccountStatus.pending:
        return 'Pending Verification';
    }
  }

  bool get canLogin {
    return this == AccountStatus.active;
  }
}
