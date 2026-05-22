// lib/features/shipper/presentation/providers/shipper_company_provider.dart

import 'package:flutter/material.dart';

import '../../domain/entities/shipper_company.dart';
import '../../domain/usecases/create_shipper_company.dart';
import '../../domain/usecases/get_shipper_company.dart';
import '../../domain/usecases/update_shipper_company.dart';
import '../states/shipper_company_state.dart';

/// Shipper Company Provider
///
/// Manages the state and business logic for shipper company operations.
/// Uses ChangeNotifier to notify UI of state changes.
class ShipperCompanyProvider extends ChangeNotifier {
  final CreateShipperCompany createShipperCompanyUseCase;
  final GetShipperCompany getShipperCompanyUseCase;
  final UpdateShipperCompany updateShipperCompanyUseCase;

  ShipperCompanyProvider({
    required this.createShipperCompanyUseCase,
    required this.getShipperCompanyUseCase,
    required this.updateShipperCompanyUseCase,
  });

  ShipperCompanyState _state = const ShipperCompanyState();

  ShipperCompanyState get state => _state;
  ShipperCompany? get company => _state.company;
  bool get hasProfile => _state.hasProfile;
  bool get isProfileMissing => _state.isMissing;

  /// Gets the current shipper's company profile
  Future<void> getShipperCompany() async {
    try {
      _state = _state.copyWith(
        isLoading: true,
        status: ShipperProfileStatus.loading,
        clearError: true,
      );
      notifyListeners();

      final company = await getShipperCompanyUseCase();

      _state = _state.copyWith(
        isLoading: false,
        company: company,
        status: ShipperProfileStatus.available,
      );
      notifyListeners();
    } catch (e) {
      final msg = e.toString();

      if (_isNotFound(msg)) {
        _state = _state.copyWith(
          isLoading: false,
          clearCompany: true,
          clearError: true,
          status: ShipperProfileStatus.missing,
        );
        notifyListeners();
        return;
      }

      _state = _state.copyWith(
        isLoading: false,
        error: e.toString(),
        status: ShipperProfileStatus.error,
      );
      notifyListeners();
    }
  }

  Future<void> ensureProfileLoaded({bool forceRefresh = false}) async {
    if (!forceRefresh && _state.hasCheckedProfile) return;
    await getShipperCompany();
  }

  /// Creates a new shipper company profile
  Future<void> createShipperCompany(ShipperCompany company) async {
    try {
      _state = _state.copyWith(
        isLoading: true,
        status: ShipperProfileStatus.loading,
        clearError: true,
      );
      notifyListeners();

      final result = await createShipperCompanyUseCase(company);

      _state = _state.copyWith(
        isLoading: false,
        company: result,
        status: ShipperProfileStatus.available,
      );
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        error: e.toString(),
        status: ShipperProfileStatus.error,
      );
      notifyListeners();
    }
  }

  /// Updates the shipper company profile
  Future<void> updateShipperCompany(ShipperCompany company) async {
    try {
      _state = _state.copyWith(
        isLoading: true,
        status: ShipperProfileStatus.loading,
        clearError: true,
      );
      notifyListeners();

      final result = await updateShipperCompanyUseCase(company);

      _state = _state.copyWith(
        isLoading: false,
        company: result,
        status: ShipperProfileStatus.available,
      );
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        error: e.toString(),
        status: ShipperProfileStatus.error,
      );
      notifyListeners();
    }
  }

  void clearProfile() {
    _state = const ShipperCompanyState();
    notifyListeners();
  }

  bool _isNotFound(String message) {
    final normalized = message.toLowerCase();
    return normalized.contains('not_found') ||
        normalized.contains('not found') ||
        normalized.contains('404');
  }
}
