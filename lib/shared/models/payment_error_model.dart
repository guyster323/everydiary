/// 결제 오류 타입
enum PaymentErrorType {
  networkError,
  userCancelled,
  paymentDeclined,
  invalidProduct,
  receiptVerificationFailed,
  subscriptionExpired,
  unknownError,
}

/// 결제 오류 정보
class PaymentError {
  final PaymentErrorType type;
  final String message;
  final String? details;
  final bool isRetryable;
  final String? retryAction;

  const PaymentError({
    required this.type,
    required this.message,
    this.details,
    required this.isRetryable,
    this.retryAction,
  });

  @override
  String toString() {
    return 'PaymentError(type: $type, message: $message, details: $details, isRetryable: $isRetryable, retryAction: $retryAction)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaymentError &&
        other.type == type &&
        other.message == message &&
        other.details == details &&
        other.isRetryable == isRetryable &&
        other.retryAction == retryAction;
  }

  @override
  int get hashCode {
    return Object.hash(type, message, details, isRetryable, retryAction);
  }
}
