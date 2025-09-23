import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../core/utils/logger.dart';
import '../models/payment_error_model.dart';

/// 결제 오류 처리 서비스
///
/// 다양한 결제 오류 상황을 처리하고 사용자에게 적절한 메시지를 제공합니다.
class PaymentErrorHandler {
  static final PaymentErrorHandler _instance = PaymentErrorHandler._internal();
  factory PaymentErrorHandler() => _instance;
  PaymentErrorHandler._internal();

  /// PurchaseDetails 오류를 PaymentError로 변환
  PaymentError handlePurchaseError(PurchaseDetails purchaseDetails) {
    if (purchaseDetails.error == null) {
      return const PaymentError(
        type: PaymentErrorType.unknownError,
        message: '알 수 없는 오류가 발생했습니다.',
        isRetryable: false,
      );
    }

    final error = purchaseDetails.error!;
    final errorCode = error.code;
    final errorMessage = error.message;

    debugPrint('Purchase error: $errorCode - $errorMessage');

    switch (errorCode) {
      case 'user_cancelled':
        return const PaymentError(
          type: PaymentErrorType.userCancelled,
          message: '결제가 취소되었습니다.',
          isRetryable: true,
          retryAction: '다시 시도',
        );

      case 'item_unavailable':
        return const PaymentError(
          type: PaymentErrorType.invalidProduct,
          message: '해당 상품을 구매할 수 없습니다.',
          details: '상품이 Google Play Store에서 제거되었거나 비활성화되었습니다.',
          isRetryable: false,
        );

      case 'service_unavailable':
        return const PaymentError(
          type: PaymentErrorType.networkError,
          message: '결제 서비스를 사용할 수 없습니다.',
          details: '네트워크 연결을 확인하고 다시 시도해주세요.',
          isRetryable: true,
          retryAction: '다시 시도',
        );

      case 'billing_unavailable':
        return const PaymentError(
          type: PaymentErrorType.paymentDeclined,
          message: '결제 서비스를 사용할 수 없습니다.',
          details: 'Google Play Store가 설치되어 있지 않거나 업데이트가 필요합니다.',
          isRetryable: false,
        );

      case 'item_already_owned':
        return const PaymentError(
          type: PaymentErrorType.unknownError,
          message: '이미 구매한 상품입니다.',
          details: '구매 복원을 시도해보세요.',
          isRetryable: false,
        );

      case 'item_not_owned':
        return const PaymentError(
          type: PaymentErrorType.unknownError,
          message: '구매하지 않은 상품입니다.',
          isRetryable: false,
        );

      default:
        return PaymentError(
          type: PaymentErrorType.unknownError,
          message: '결제 중 오류가 발생했습니다.',
          details: errorMessage,
          isRetryable: true,
          retryAction: '다시 시도',
        );
    }
  }

  /// 구독 상태 오류 처리
  PaymentError handleSubscriptionError(String errorMessage) {
    if (errorMessage.contains('expired') || errorMessage.contains('만료')) {
      return const PaymentError(
        type: PaymentErrorType.subscriptionExpired,
        message: '구독이 만료되었습니다.',
        details: '프리미엄 기능을 계속 사용하려면 구독을 갱신해주세요.',
        isRetryable: true,
        retryAction: '구독 갱신',
      );
    }

    if (errorMessage.contains('network') || errorMessage.contains('네트워크')) {
      return const PaymentError(
        type: PaymentErrorType.networkError,
        message: '네트워크 연결을 확인해주세요.',
        details: '인터넷 연결 상태를 확인하고 다시 시도해주세요.',
        isRetryable: true,
        retryAction: '다시 시도',
      );
    }

    if (errorMessage.contains('verification') || errorMessage.contains('검증')) {
      return const PaymentError(
        type: PaymentErrorType.receiptVerificationFailed,
        message: '영수증 검증에 실패했습니다.',
        details: '잠시 후 다시 시도하거나 고객 지원에 문의해주세요.',
        isRetryable: true,
        retryAction: '다시 시도',
      );
    }

    return PaymentError(
      type: PaymentErrorType.unknownError,
      message: '구독 확인 중 오류가 발생했습니다.',
      details: errorMessage,
      isRetryable: true,
      retryAction: '다시 시도',
    );
  }

  /// 네트워크 오류 처리
  PaymentError handleNetworkError(Exception exception) {
    return const PaymentError(
      type: PaymentErrorType.networkError,
      message: '네트워크 연결을 확인해주세요.',
      details: '인터넷 연결 상태를 확인하고 다시 시도해주세요.',
      isRetryable: true,
      retryAction: '다시 시도',
    );
  }

  /// 사용자 친화적 오류 메시지 생성
  String getUserFriendlyMessage(PaymentError error) {
    switch (error.type) {
      case PaymentErrorType.userCancelled:
        return '결제가 취소되었습니다. 언제든지 다시 시도할 수 있습니다.';

      case PaymentErrorType.networkError:
        return '네트워크 연결을 확인하고 다시 시도해주세요.';

      case PaymentErrorType.paymentDeclined:
        return '결제가 거부되었습니다. 결제 수단을 확인해주세요.';

      case PaymentErrorType.invalidProduct:
        return '해당 상품을 구매할 수 없습니다. 고객 지원에 문의해주세요.';

      case PaymentErrorType.receiptVerificationFailed:
        return '영수증 검증에 실패했습니다. 잠시 후 다시 시도해주세요.';

      case PaymentErrorType.subscriptionExpired:
        return '구독이 만료되었습니다. 프리미엄 기능을 계속 사용하려면 갱신해주세요.';

      case PaymentErrorType.unknownError:
        return error.message;
    }
  }

  /// 오류 복구 제안 메시지 생성
  String? getRecoverySuggestion(PaymentError error) {
    if (!error.isRetryable) {
      return null;
    }

    switch (error.type) {
      case PaymentErrorType.networkError:
        return 'Wi-Fi 또는 모바일 데이터 연결을 확인해주세요.';

      case PaymentErrorType.paymentDeclined:
        return '다른 결제 수단을 시도하거나 카드 정보를 확인해주세요.';

      case PaymentErrorType.receiptVerificationFailed:
        return '잠시 후 다시 시도하거나 앱을 재시작해보세요.';

      case PaymentErrorType.subscriptionExpired:
        return '구독 화면에서 갱신을 진행해주세요.';

      default:
        return '잠시 후 다시 시도해주세요.';
    }
  }

  /// 오류 로깅
  void logError(PaymentError error, {String? context}) {
    debugPrint(
      'Payment Error [${context ?? 'Unknown'}]: ${error.type} - ${error.message}',
    );
    if (error.details != null) {
      debugPrint('Error Details: ${error.details}');
    }

    // 실제 앱에서는 Firebase Crashlytics나 다른 로깅 서비스에 전송
    // 현재는 Logger를 사용하여 오류 로깅
    Logger.error(
      'Payment Error: ${error.message}',
      tag: 'PaymentErrorHandler',
      error: Exception('Payment Error: ${error.message}'),
    );

    // 향후 Firebase Crashlytics 구현 시 사용할 코드:
    // FirebaseCrashlytics.instance.recordError(
    //   Exception('Payment Error: ${error.message}'),
    //   StackTrace.current,
    //   context: context,
    // );
  }

  /// 오류 통계 수집
  void trackError(PaymentError error, {String? context}) {
    // 실제 앱에서는 분석 서비스에 오류 통계 전송
    // 현재는 Logger를 사용하여 통계 로깅
    Logger.info(
      'Payment Error Statistics: ${error.type.toString()} - ${error.message}',
      tag: 'PaymentErrorHandler',
    );

    // 향후 Firebase Analytics 구현 시 사용할 코드:
    // FirebaseAnalytics.instance.logEvent(
    //   name: 'payment_error',
    //   parameters: {
    //     'error_type': error.type.toString(),
    //     'error_message': error.message,
    //     'is_retryable': error.isRetryable,
    //     'context': context ?? 'unknown',
    //   },
    // );

    debugPrint(
      'Error tracked: ${error.type} in ${context ?? 'unknown context'}',
    );
  }
}
