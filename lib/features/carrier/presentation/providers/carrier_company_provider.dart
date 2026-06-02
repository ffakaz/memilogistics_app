import 'package:flutter/material.dart';
import 'package:memilogistics_app/core/error/exceptions.dart';

import '../../domain/entities/carrier_company.dart';

import '../../domain/usecases/create_carrier_company.dart';
import '../../domain/usecases/get_carrier_company.dart';
import '../../domain/usecases/get_carrier_companybyid.dart';
import '../../domain/usecases/update_carrier_company.dart';
import '../states/carrier_company_state.dart';

class CarrierCompanyProvider extends ChangeNotifier {
  final CreateCarrierCompany createCarrierCompanyUseCase;

  final GetCarrierCompany getCarrierCompanyUseCase;

  final UpdateCarrierCompany updateCarrierCompanyUseCase;
  final GetCarrierCompanyById getCarrierCompanyByIdUseCase;
  CarrierCompanyProvider({
    required this.createCarrierCompanyUseCase,
    required this.getCarrierCompanyUseCase,
    required this.updateCarrierCompanyUseCase,
    required this.getCarrierCompanyByIdUseCase,
  });

  CarrierCompanyState _state = const CarrierCompanyState();

  CarrierCompanyState get state => _state;

  Future<void> getCarrierCompany() async {
    try {
      _state = _state.copyWith(
        isLoading: true,
        clearError: true,
        hasAttemptedLoad: true,
      );

      notifyListeners();

      final company = await getCarrierCompanyUseCase();

      _state = _state.copyWith(
        isLoading: false,
        company: company,
        clearError: true,
        hasAttemptedLoad: true,
      );

      notifyListeners();
    } catch (e) {
      // Treat 404 / not-found consistently:
      // - HttpException with statusCode 404
      // - NotFoundException mapped by HttpErrorMapper
      // - Fallback: message contains '404' or 'not found'
      if ((e is HttpException && e.statusCode == 404) ||
          (e is NotFoundException) ||
          _isNotFound(e.toString())) {
        _state = _state.copyWith(
          isLoading: false,
          clearCompany: true,
          clearError: true,
          hasAttemptedLoad: true,
        );
        notifyListeners();
        return;
      }

      _state = _state.copyWith(
        isLoading: false,
        error: e.toString(),
        hasAttemptedLoad: true,
      );

      notifyListeners();
    }
  }

  /// Retrieves a shipper company profile by ID
  Future<CarrierCompany> getCarrierCompanyById(int carrierId) async {
    return await getCarrierCompanyByIdUseCase(carrierId);
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

  bool _isNotFound(String message) {
    final normalized = message.toLowerCase();
    return normalized.contains('not_found') ||
        normalized.contains('not found') ||
        normalized.contains('404');
  }

  void clearError() {
    _state = _state.copyWith(clearError: true);
    notifyListeners();
  }

  void clearProfile() {
    _state = const CarrierCompanyState();
    notifyListeners();
  }

  Future<void> createCarrierCompany(CarrierCompany company) async {
    try {
      _state = _state.copyWith(isLoading: true, clearError: true);

      notifyListeners();

      final result = await createCarrierCompanyUseCase(company);

      _state = _state.copyWith(
        isLoading: false,
        company: result,
        clearError: true,
        hasAttemptedLoad: true,
      );

      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(isLoading: false, error: e.toString());

      notifyListeners();
    }
  }

  Future<void> updateCarrierCompany(CarrierCompany company) async {
    try {
      _state = _state.copyWith(isLoading: true, clearError: true);

      notifyListeners();

      final result = await updateCarrierCompanyUseCase(company);

      _state = _state.copyWith(
        isLoading: false,
        company: result,
        clearError: true,
        hasAttemptedLoad: true,
      );

      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(isLoading: false, error: e.toString());

      notifyListeners();
    }
  }
}
