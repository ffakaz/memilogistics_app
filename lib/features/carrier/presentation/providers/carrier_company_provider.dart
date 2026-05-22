import 'package:flutter/material.dart';

import '../../domain/entities/carrier_company.dart';

import '../../domain/usecases/create_carrier_company.dart';
import '../../domain/usecases/get_carrier_company.dart';
import '../../domain/usecases/update_carrier_company.dart';

import '../states/carrier_company_state.dart';

class CarrierCompanyProvider
    extends ChangeNotifier {

  final CreateCarrierCompany
      createCarrierCompanyUseCase;

  final GetCarrierCompany
      getCarrierCompanyUseCase;

  final UpdateCarrierCompany
      updateCarrierCompanyUseCase;

  CarrierCompanyProvider({
    required this.createCarrierCompanyUseCase,
    required this.getCarrierCompanyUseCase,
    required this.updateCarrierCompanyUseCase,
  });

  CarrierCompanyState _state =
      const CarrierCompanyState();

  CarrierCompanyState get state => _state;

  Future<void> getCarrierCompany() async {
    try {
      _state = _state.copyWith(
        isLoading: true,
        error: null,
        hasAttemptedLoad: true,
      );

      notifyListeners();

      final company =
          await getCarrierCompanyUseCase();

      _state = _state.copyWith(
        isLoading: false,
        company: company,
        hasAttemptedLoad: true,
      );

      notifyListeners();

    } catch (e) {

      _state = _state.copyWith(
        isLoading: false,
        error: e.toString(),
        hasAttemptedLoad: true,
      );

      notifyListeners();
    }
  }

  /// Backwards-compatible wrapper used by UI code.
  Future<void> ensureProfileLoaded({bool forceRefresh = false}) async {
    if (forceRefresh) {
      await getCarrierCompany();
      return;
    }

    if (_state.company == null && !_state.isLoading) {
      await getCarrierCompany();
    }
  }

  void clearError() {
    _state = _state.copyWith(error: null);
    notifyListeners();
  }

  void clearProfile() {
    _state = _state.copyWith(company: null, hasAttemptedLoad: true);
    notifyListeners();
  }

  Future<void> createCarrierCompany(
    CarrierCompany company,
  ) async {

    try {

      _state = _state.copyWith(
        isLoading: true,
        error: null,
      );

      notifyListeners();

      final result =
          await createCarrierCompanyUseCase(
        company,
      );

      _state = _state.copyWith(
        isLoading: false,
        company: result,
      );

      notifyListeners();

    } catch (e) {

      _state = _state.copyWith(
        isLoading: false,
        error: e.toString(),
      );

      notifyListeners();
    }
  }

  Future<void> updateCarrierCompany(
    CarrierCompany company,
  ) async {

    try {

      _state = _state.copyWith(
        isLoading: true,
        error: null,
      );

      notifyListeners();

      final result =
          await updateCarrierCompanyUseCase(
        company,
      );

      _state = _state.copyWith(
        isLoading: false,
        company: result,
      );

      notifyListeners();

    } catch (e) {

      _state = _state.copyWith(
        isLoading: false,
        error: e.toString(),
      );

      notifyListeners();
    }
  }
}