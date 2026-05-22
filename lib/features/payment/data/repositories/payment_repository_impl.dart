// lib/features/payment/data/repositories/payment_repository_impl.dart

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/payment_record.dart';
import '../../domain/entities/payment_request.dart';
import '../../domain/repositories/payment_repository.dart';
import '../models/payment_request_model.dart';
import '../services/payment_api_service.dart';

/// Payment repository implementation
/// Only implements confirmed backend endpoints
class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentApiService _apiService;

  PaymentRepositoryImpl(this._apiService);

  @override
  Future<Either<Failure, PaymentRecord>> initiatePayment({
    required int shipmentId,
    required PaymentRequest request,
  }) async {
    try {
      print(
        '🔷 PaymentRepository: Initiating payment for shipment $shipmentId',
      );
      print('🔷 PaymentRepository: Amount: ${request.formattedAmount}');
      print(
        '🔷 PaymentRepository: Method: ${request.paymentMethod.displayName}',
      );

      final requestModel = PaymentRequestModel.fromEntity(request);
      final resultModel = await _apiService.initiatePayment(
        shipmentId: shipmentId,
        request: requestModel,
      );

      final paymentRecord = resultModel.toEntity();

      print('🔷 PaymentRepository: Payment initiated successfully');
      print('🔷 PaymentRepository: Payment ID: ${paymentRecord.id}');
      print(
        '🔷 PaymentRepository: Status: ${paymentRecord.paymentStatus.displayName}',
      );

      return Right(paymentRecord);
    } on Exception catch (e) {
      print('🔷 PaymentRepository: Exception caught');
      print('🔷 PaymentRepository: Exception: $e');

      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      return Left(ServerFailure(errorMessage));
    } catch (e) {
      print('🔷 PaymentRepository: Unknown error caught');
      print('🔷 PaymentRepository: Error: $e');

      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaymentRecord>> confirmPayment({
    required int shipmentId,
    required String transactionId,
  }) async {
    try {
      print(
        '🔷 PaymentRepository: Confirming payment for shipment $shipmentId',
      );
      print('🔷 PaymentRepository: Transaction ID: $transactionId');
      print(
        '🔷 PaymentRepository: Note - Backend confirm-payment endpoint does not require request body',
      );

      final resultModel = await _apiService.confirmPayment(
        shipmentId: shipmentId,
      );

      final paymentRecord = resultModel.toEntity();

      print('🔷 PaymentRepository: Payment confirmed successfully');
      print('🔷 PaymentRepository: Payment ID: ${paymentRecord.id}');
      print(
        '🔷 PaymentRepository: Status: ${paymentRecord.paymentStatus.displayName}',
      );

      return Right(paymentRecord);
    } on Exception catch (e) {
      print('🔷 PaymentRepository: Exception caught');
      print('🔷 PaymentRepository: Exception: $e');

      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      return Left(ServerFailure(errorMessage));
    } catch (e) {
      print('🔷 PaymentRepository: Unknown error caught');
      print('🔷 PaymentRepository: Error: $e');

      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaymentRecord?>> getPaymentRecord({
    required int shipmentId,
  }) async {
    // This endpoint doesn't exist in the actual backend API
    // Payment record should be retrieved from shipment details
    print('🔷 PaymentRepository: getPaymentRecord not implemented');
    print('🔷 PaymentRepository: Use shipment.paymentRecord instead');
    return Left(
      ServerFailure(
        'Endpoint not available. Get payment record from shipment details.',
      ),
    );
  }

  @override
  Future<Either<Failure, List<PaymentRecord>>> getPaymentHistory() async {
    // This endpoint doesn't exist in the actual backend API
    // Payment history should be retrieved from user's shipments
    print('🔷 PaymentRepository: getPaymentHistory not implemented');
    print(
      '🔷 PaymentRepository: Use shipments list with payment records instead',
    );
    return Left(
      ServerFailure(
        'Endpoint not available. Get payment history from shipments list.',
      ),
    );
  }
}
