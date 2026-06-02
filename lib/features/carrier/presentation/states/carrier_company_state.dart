import '../../domain/entities/carrier_company.dart';

enum CarrierProfileStatus {
  initial,
  loading,
  loaded,
  error,
  loggedOut,
}

class CarrierCompanyState {
  final bool isLoading;
  final CarrierCompany? company;
  final String? error;
  final bool hasAttemptedLoad;

  const CarrierCompanyState({
    this.isLoading = false,
    this.company,
    this.error,
    this.hasAttemptedLoad = false,
  });

  CarrierCompanyState copyWith({
    bool? isLoading,
    CarrierCompany? company,
    String? error,
    bool? hasAttemptedLoad,
    bool clearError = false,
    bool clearCompany = false,
  }) {
    return CarrierCompanyState(
      isLoading: isLoading ?? this.isLoading,
      company: clearCompany ? null : company ?? this.company,
      error: clearError ? null : error ?? this.error,
      hasAttemptedLoad: hasAttemptedLoad ?? this.hasAttemptedLoad,
    );
  }

  CarrierProfileStatus get status {
    if (isLoading) return CarrierProfileStatus.loading;
    if (error != null) return CarrierProfileStatus.error;
    if (!hasAttemptedLoad) return CarrierProfileStatus.initial;
    if (company == null) return CarrierProfileStatus.loggedOut;
    return CarrierProfileStatus.loaded;
  }

  bool get isMissing => company == null;
}