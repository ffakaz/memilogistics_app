// lib/features/payment/presentation/states/payment_state.dart

import 'package:equatable/equatable.dart';
import '../../domain/entities/payment_record.dart';

/// Payment state for UI
abstract class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class PaymentInitial extends PaymentState {
  const PaymentInitial();
}

/// Loading state
class PaymentLoading extends PaymentState {
  const PaymentLoading();
}

/// Payment initiated successfully
class PaymentInitiated extends PaymentState {
  final PaymentRecord paymentRecord;

  const PaymentInitiated(this.paymentRecord);

  @override
  List<Object?> get props => [paymentRecord];
}

/// Payment confirmed successfully
class PaymentConfirmed extends PaymentState {
  final PaymentRecord paymentRecord;

  const PaymentConfirmed(this.paymentRecord);

  @override
  List<Object?> get props => [paymentRecord];
}

/// Payment record loaded
class PaymentRecordLoaded extends PaymentState {
  final PaymentRecord? paymentRecord;

  const PaymentRecordLoaded(this.paymentRecord);

  @override
  List<Object?> get props => [paymentRecord];
}

/// Payment history loaded
class PaymentHistoryLoaded extends PaymentState {
  final List<PaymentRecord> payments;

  const PaymentHistoryLoaded(this.payments);

  @override
  List<Object?> get props => [payments];
}

/// Error state
class PaymentError extends PaymentState {
  final String message;

  const PaymentError(this.message);

  @override
  List<Object?> get props => [message];
}
