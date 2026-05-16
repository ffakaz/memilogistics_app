import 'package:flutter/material.dart';

import '../../domain/entities/carrier_company.dart';
import '../../domain/usecases/create_carrier_company.dart';
import '../../domain/usecases/get_carrier_company.dart';
import '../../domain/usecases/update_carrier_company.dart';
import '../states/carrier_company_state.dart';

class CarrierCompanyProvider extends ChangeNotifier {
  final CreateCarrierCompany createCarrierCompanyUseCase;
  final GetCarrierCompany getCarrierCompanyUseCase;
  final UpdateCarrierCompany updateCarrierCompanyUseCase;

  CarrierCompanyProvider({
    required this.createCarrierCompanyUseCase,
    required this.getCarrierCompanyUseCase,
    required this.updateCarrierCompanyUseCase,
  });

  CarrierCompanyState _state = const CarrierCompanyState();

  CarrierCompanyState get state => _state;

  Future<void> getCarrierCompany() async {
    _setState(_state.copyWith(isLoading: true, clearError: true));

    try {
      final company = await getCarrierCompanyUseCase();
      _setState(CarrierCompanyState(company: company));
    } catch (e) {
      _setState(CarrierCompanyState(error: e.toString()));
    }
  }

  Future<void> createCarrierCompany(CarrierCompany company) async {
    _setState(_state.copyWith(isLoading: true, clearError: true));

    try {
      final created = await createCarrierCompanyUseCase(company);
      _setState(CarrierCompanyState(company: created));
    } catch (e) {
      _setState(_state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> updateCarrierCompany(CarrierCompany company) async {
    _setState(_state.copyWith(isLoading: true, clearError: true));

    try {
      final updated = await updateCarrierCompanyUseCase(company);
      _setState(CarrierCompanyState(company: updated));
    } catch (e) {
      _setState(_state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void _setState(CarrierCompanyState state) {
    _state = state;
    notifyListeners();
  }
}
