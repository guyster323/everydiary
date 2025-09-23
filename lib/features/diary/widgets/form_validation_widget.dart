import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/custom_card.dart';
import '../services/form_validation_service.dart';

/// 폼 유효성 검증 상태를 표시하는 위젯
class FormValidationWidget extends ConsumerWidget {
  final FormValidationService validationService;
  final String fieldName;
  final Widget child;

  const FormValidationWidget({
    super.key,
    required this.validationService,
    required this.fieldName,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnimatedBuilder(
      animation: validationService,
      builder: (context, child) {
        final hasError = validationService.hasError(fieldName);
        final errorMessage = validationService.getError(fieldName);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 원본 위젯
            child!,

            // 에러 메시지
            if (hasError && errorMessage != null) ...[
              const SizedBox(height: 4),
              _buildErrorMessage(errorMessage),
            ],
          ],
        );
      },
      child: child,
    );
  }

  Widget _buildErrorMessage(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            size: 16,
            color: Colors.red.shade600,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12,
                color: Colors.red.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 전체 폼 에러 요약 위젯
class FormErrorSummaryWidget extends ConsumerWidget {
  final FormValidationService validationService;
  final VoidCallback? onRetry;

  const FormErrorSummaryWidget({
    super.key,
    required this.validationService,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnimatedBuilder(
      animation: validationService,
      builder: (context, child) {
        if (!validationService.hasErrors) {
          return const SizedBox.shrink();
        }

        return CustomCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더
              Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '입력 오류',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.red.shade700,
                    ),
                  ),
                  const Spacer(),
                  if (onRetry != null)
                    TextButton(
                      onPressed: onRetry,
                      child: const Text('다시 시도'),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // 에러 목록
              ...validationService.errors.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.only(top: 6, right: 8),
                        decoration: BoxDecoration(
                          color: Colors.red.shade600,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

/// 폼 검증 상태 표시 위젯
class FormValidationStatusWidget extends ConsumerWidget {
  final FormValidationService validationService;

  const FormValidationStatusWidget({
    super.key,
    required this.validationService,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnimatedBuilder(
      animation: validationService,
      builder: (context, child) {
        if (validationService.isValidating) {
          return _buildValidatingStatus();
        }

        if (validationService.hasErrors) {
          return _buildErrorStatus();
        }

        if (validationService.isValid) {
          return _buildValidStatus();
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildValidatingStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '검증 중...',
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: 16,
            color: Colors.red.shade600,
          ),
          const SizedBox(width: 8),
          Text(
            '${validationService.errors.length}개 오류',
            style: TextStyle(
              fontSize: 12,
              color: Colors.red.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValidStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 16,
            color: Colors.green.shade600,
          ),
          const SizedBox(width: 8),
          Text(
            '유효함',
            style: TextStyle(
              fontSize: 12,
              color: Colors.green.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// 필드별 유효성 검증을 위한 래퍼 위젯
class ValidatedFormField extends ConsumerWidget {
  final FormValidationService validationService;
  final String fieldName;
  final Widget child;
  final bool showErrorImmediately;

  const ValidatedFormField({
    super.key,
    required this.validationService,
    required this.fieldName,
    required this.child,
    this.showErrorImmediately = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FormValidationWidget(
      validationService: validationService,
      fieldName: fieldName,
      child: child,
    );
  }
}

/// 폼 제출 버튼 (유효성 검증 포함)
class ValidatedSubmitButton extends ConsumerWidget {
  final FormValidationService validationService;
  final VoidCallback onPressed;
  final String text;
  final bool isLoading;
  final ButtonStyle? style;

  const ValidatedSubmitButton({
    super.key,
    required this.validationService,
    required this.onPressed,
    required this.text,
    this.isLoading = false,
    this.style,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnimatedBuilder(
      animation: validationService,
      builder: (context, child) {
        final isEnabled = !isLoading && validationService.isValid;

        return ElevatedButton(
          onPressed: isEnabled ? onPressed : null,
          style: style,
          child: isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(text),
        );
      },
    );
  }
}


