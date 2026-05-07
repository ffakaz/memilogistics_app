// lib/features/user/domain/enums/app_role.dart

enum AppRole {
  admin,
  shipper,
  carrier;

  String get displayName {
    switch (this) {
      case AppRole.admin:
        return 'Administrator';
      case AppRole.shipper:
        return 'Shipper';
      case AppRole.carrier:
        return 'Carrier';
    }
  }

  String get description {
    switch (this) {
      case AppRole.admin:
        return 'Full system access';
      case AppRole.shipper:
        return 'Create and manage shipments';
      case AppRole.carrier:
        return 'Receive and deliver shipments';
    }
  }
}
