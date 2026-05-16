import '../../domain/entities/carrier_company.dart';

class CarrierCompanyState {
  final CarrierCompany? company;
  final bool isLoading;
  final String? error;

  const CarrierCompanyState({this.company, this.isLoading = false, this.error});

  CarrierCompanyState copyWith({
    CarrierCompany? company,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return CarrierCompanyState(
      company: company ?? this.company,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }
}
