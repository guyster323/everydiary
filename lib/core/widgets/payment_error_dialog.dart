import 'package:flutter/material.dart';

import '../../shared/models/payment_error_model.dart';

/// 결제 오류 다이얼로그
class PaymentErrorDialog extends StatelessWidget {
  final PaymentError error;
  final VoidCallback? onRetry;
  final VoidCallback? onCancel;

  const PaymentErrorDialog({
    super.key,
    required this.error,
    this.onRetry,
    this.onCancel,
  });

  /// 결제 오류 다이얼로그 표시
  static Future<void> show(
    BuildContext context,
    PaymentError error, {
    VoidCallback? onRetry,
    VoidCallback? onCancel,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => PaymentErrorDialog(
        error: error,
        onRetry: onRetry,
        onCancel: onCancel,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            _getErrorIcon(error.type),
            color: _getErrorColor(error.type),
            size: 24,
          ),
          const SizedBox(width: 8),
          const Text('결제 오류'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(error.message, style: const TextStyle(fontSize: 16)),
          if (error.details != null) ...[
            const SizedBox(height: 8),
            Text(
              error.details!,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ],
      ),
      actions: [
        if (onCancel != null)
          TextButton(onPressed: onCancel, child: const Text('취소')),
        if (error.isRetryable && onRetry != null)
          ElevatedButton(
            onPressed: onRetry,
            child: Text(error.retryAction ?? '다시 시도'),
          ),
        if (!error.isRetryable || onRetry == null)
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
      ],
    );
  }

  /// 오류 타입에 따른 아이콘 반환
  IconData _getErrorIcon(PaymentErrorType type) {
    switch (type) {
      case PaymentErrorType.userCancelled:
        return Icons.cancel;
      case PaymentErrorType.networkError:
        return Icons.wifi_off;
      case PaymentErrorType.paymentDeclined:
        return Icons.remove_shopping_cart;
      case PaymentErrorType.invalidProduct:
        return Icons.error;
      case PaymentErrorType.receiptVerificationFailed:
        return Icons.verified_user;
      case PaymentErrorType.subscriptionExpired:
        return Icons.access_time;
      case PaymentErrorType.unknownError:
        return Icons.help;
    }
  }

  /// 오류 타입에 따른 색상 반환
  Color _getErrorColor(PaymentErrorType type) {
    switch (type) {
      case PaymentErrorType.userCancelled:
        return Colors.orange;
      case PaymentErrorType.networkError:
        return Colors.red;
      case PaymentErrorType.paymentDeclined:
        return Colors.red;
      case PaymentErrorType.invalidProduct:
        return Colors.red;
      case PaymentErrorType.receiptVerificationFailed:
        return Colors.orange;
      case PaymentErrorType.subscriptionExpired:
        return Colors.orange;
      case PaymentErrorType.unknownError:
        return Colors.grey;
    }
  }
}

/// 결제 오류 스낵바
class PaymentErrorSnackBar extends StatelessWidget {
  final PaymentError error;
  final VoidCallback? onRetry;

  const PaymentErrorSnackBar({super.key, required this.error, this.onRetry});

  /// 결제 오류 스낵바 표시
  static void show(
    BuildContext context,
    PaymentError error, {
    VoidCallback? onRetry,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _getErrorIconStatic(error.type),
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(error.message)),
          ],
        ),
        backgroundColor: _getErrorColorStatic(error.type),
        duration: const Duration(seconds: 4),
        action: error.isRetryable && onRetry != null
            ? SnackBarAction(
                label: error.retryAction ?? '다시 시도',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  /// 오류 타입에 따른 아이콘 반환 (정적 메서드)
  static IconData _getErrorIconStatic(PaymentErrorType type) {
    switch (type) {
      case PaymentErrorType.userCancelled:
        return Icons.cancel;
      case PaymentErrorType.networkError:
        return Icons.wifi_off;
      case PaymentErrorType.paymentDeclined:
        return Icons.remove_shopping_cart;
      case PaymentErrorType.invalidProduct:
        return Icons.error;
      case PaymentErrorType.receiptVerificationFailed:
        return Icons.verified_user;
      case PaymentErrorType.subscriptionExpired:
        return Icons.access_time;
      case PaymentErrorType.unknownError:
        return Icons.help;
    }
  }

  /// 오류 타입에 따른 색상 반환 (정적 메서드)
  static Color _getErrorColorStatic(PaymentErrorType type) {
    switch (type) {
      case PaymentErrorType.userCancelled:
        return Colors.orange;
      case PaymentErrorType.networkError:
        return Colors.red;
      case PaymentErrorType.paymentDeclined:
        return Colors.red;
      case PaymentErrorType.invalidProduct:
        return Colors.red;
      case PaymentErrorType.receiptVerificationFailed:
        return Colors.orange;
      case PaymentErrorType.subscriptionExpired:
        return Colors.orange;
      case PaymentErrorType.unknownError:
        return Colors.grey;
    }
  }
}
