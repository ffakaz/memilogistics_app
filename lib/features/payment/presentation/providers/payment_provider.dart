// lib/features/payment/presentation/providers/payment_provider.dart

import 'package:flutter/foundation.dart';
import '../../domain/entities/payment_request.dart';
import '../../domain/repositories/payment_repository.dart';
import '../states/payment_state.dart';

/// Payment provider for state management
class PaymentProvider with ChangeNotifier {
  final PaymentRepository _repository;

  PaymentState _state = const PaymentInitial();
  PaymentState get state => _state;

  bool get isLoading => _state is PaymentLoading;
  String? get error => _state is PaymentError ? (_state as PaymentError).message : null;

  PaymentProvider(this._repository);

  /// Update state and notify listeners
  void _updateState(PaymentState newState) {
    _state = newState;
    notifyListeners();
  }

  /// Initiate payment for a shipment
  Future<bool> initiatePayment({
    required int shipmentId,
    required PaymentRequest request,
  }) async {
    _updateState(const PaymentLoading());

    final result = await _repository.initiatePayment(
      shipmentId: shipmentId,
      request: request,
    );

    return result.fold(
      (failure) {
        _updateState(PaymentError(failure.message));
        return false;
      },
      (paymentRecord) {
        _updateState(PaymentInitiated(paymentRecord));
        return true;
      },
    );
  }

  /// Confirm payment completion
  Future<bool> confirmPayment({
    required int shipmentId,
    required String transactionId,
  }) async {
    _updateState(const PaymentLoading());

    final result = await _repository.confirmPayment(
      shipmentId: shipmentId,
      transactionId: transactionId,
    );

    return result.fold(
      (failure) {
        _updateState(PaymentError(failure.message));
        return false;
      },
      (paymentRecord) {
        _updateState(PaymentConfirmed(paymentRecord));
        return true;
      },
    );
  }

  /// Get payment record for a shipment
  Future<void> getPaymentRecord({required int shipmentId}) async {
    _updateState(const PaymentLoading());

    final result = await _repository.getPaymentRecord(
      shipmentId: shipmentId,
    );

    result.fold(
      (failure) {
        _updateState(PaymentError(failure.message));
      },
      (paymentRecord) {
        _updateState(PaymentRecordLoaded(paymentRecord));
      },
    );
  }

  /// Get payment history
  Future<void> getPaymentHistory() async {
    _updateState(const PaymentLoading());

    final result = await _repository.getPaymentHistory();

    result.fold(
      (failure) {
        _updateState(PaymentError(failure.message));
      },
      (payments) {
        _updateState(PaymentHistoryLoaded(payments));
      },
    );
  }

  /// Reset state to initial
  void reset() {
    _updateState(const PaymentInitial());
  }

  /// Clear error
  void clearError() {
    if (_state is PaymentError) {
      _updateState(const PaymentInitial());
    }
  }
}
