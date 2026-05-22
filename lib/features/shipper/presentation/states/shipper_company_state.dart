// lib/features/shipper/presentation/states/shipper_company_state.dart

import '../../domain/entities/shipper_company.dart';

enum ShipperProfileStatus { initial, loading, missing, available, error }

/// Shipper Company State
///
/// Represents the UI state for shipper company operations.
/// Used by ShipperCompanyProvider to manage state.
class ShipperCompanyState {
  final bool isLoading;
  final ShipperCompany? company;
  final String? error;
  final ShipperProfileStatus status;

  const ShipperCompanyState({
    this.isLoading = false,
    this.company,
    this.error,
    this.status = ShipperProfileStatus.initial,
  });

  bool get hasProfile =>
      company != null && status == ShipperProfileStatus.available;
  bool get isMissing => status == ShipperProfileStatus.missing;
  bool get hasCheckedProfile => status != ShipperProfileStatus.initial;

  /// Creates a copy of this state with the given fields replaced
  ShipperCompanyState copyWith({
    bool? isLoading,
    ShipperCompany? company,
    String? error,
    ShipperProfileStatus? status,
    bool clearError = false,
    bool clearCompany = false,
  }) {
    return ShipperCompanyState(
      isLoading: isLoading ?? this.isLoading,
      company: clearCompany ? null : company ?? this.company,
      error: clearError ? null : error ?? this.error,
      status: status ?? this.status,
    );
  }

  @override
  String toString() {
    return 'ShipperCompanyState(isLoading: $isLoading, company: $company, error: $error, status: $status)';
  }
}
