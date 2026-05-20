// lib/features/payment/domain/repositories/payment_repository.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/payment_record.dart';
import '../entities/payment_request.dart';

/// Payment repository interface
/// Defines contract for payment data operations
abstract class PaymentRepository {
  /// Initiate payment for a shipment
  /// 
  /// [shipmentId] - ID of the shipment to pay for
  /// [request] - Payment request details
  /// 
  /// Returns [PaymentRecord] on success or [Failure] on error
  Future<Either<Failure, PaymentRecord>> initiatePayment({
    required int shipmentId,
    required PaymentRequest request,
  });

  /// Confirm payment completion
  /// 
  /// [shipmentId] - ID of the shipment
  /// [transactionId] - External payment gateway transaction ID
  /// 
  /// Returns updated [PaymentRecord] on success or [Failure] on error
  Future<Either<Failure, PaymentRecord>> confirmPayment({
    required int shipmentId,
    required String transactionId,
  });

  /// Get payment record for a shipment
  /// 
  /// [shipmentId] - ID of the shipment
  /// 
  /// Returns [PaymentRecord] if exists, null if not found, or [Failure] on error
  Future<Either<Failure, PaymentRecord?>> getPaymentRecord({
    required int shipmentId,
  });

  /// Get payment history for current user
  /// 
  /// Returns list of [PaymentRecord] on success or [Failure] on error
  Future<Either<Failure, List<PaymentRecord>>> getPaymentHistory();
}
