import 'package:flutter/material.dart';

/// 접근성을 고려한 커스텀 위젯들
class AccessibilityWidgets {
  /// 접근성을 고려한 버튼
  static Widget accessibleButton({
    required String label,
    required VoidCallback onPressed,
    required Widget child,
    String? hint,
    bool enabled = true,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      enabled: enabled,
      button: true,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        child: child,
      ),
    );
  }

  /// 접근성을 고려한 텍스트 필드
  static Widget accessibleTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    String? errorText,
    bool obscureText = false,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    ValueChanged<String>? onChanged,
    VoidCallback? onTap,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      textField: true,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        onChanged: onChanged,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          errorText: errorText,
        ),
      ),
    );
  }

  /// 접근성을 고려한 카드
  static Widget accessibleCard({
    required String label,
    required Widget child,
    String? hint,
    VoidCallback? onTap,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      button: onTap != null,
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: child,
        ),
      ),
    );
  }

  /// 접근성을 고려한 리스트 타일
  static Widget accessibleListTile({
    required String title,
    String? subtitle,
    Widget? leading,
    Widget? trailing,
    VoidCallback? onTap,
    String? hint,
  }) {
    return Semantics(
      label: title,
      hint: subtitle ?? hint,
      button: onTap != null,
      child: ListTile(
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle) : null,
        leading: leading,
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }

  /// 접근성을 고려한 이미지
  static Widget accessibleImage({
    required String imageUrl,
    required String altText,
    double? width,
    double? height,
    BoxFit? fit,
  }) {
    return Semantics(
      label: altText,
      image: true,
      child: Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return Semantics(
            label: '이미지를 불러올 수 없습니다: $altText',
            child: Container(
              width: width,
              height: height,
              color: Colors.grey.shade300,
              child: const Icon(Icons.broken_image),
            ),
          );
        },
      ),
    );
  }

  /// 접근성을 고려한 로딩 인디케이터
  static Widget accessibleLoadingIndicator({required String message}) {
    return Semantics(
      label: message,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(message),
          ],
        ),
      ),
    );
  }

  /// 접근성을 고려한 에러 메시지
  static Widget accessibleErrorMessage({
    required String message,
    VoidCallback? onRetry,
  }) {
    return Semantics(
      label: '오류: $message',
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(onPressed: onRetry, child: const Text('다시 시도')),
            ],
          ],
        ),
      ),
    );
  }

  /// 접근성을 고려한 빈 상태 메시지
  static Widget accessibleEmptyState({
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Semantics(
      label: message,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(onPressed: onAction, child: Text(actionLabel)),
            ],
          ],
        ),
      ),
    );
  }

  /// 접근성을 고려한 스위치
  static Widget accessibleSwitch({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
    String? hint,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      toggled: value,
      child: SwitchListTile(
        title: Text(label),
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  /// 접근성을 고려한 체크박스
  static Widget accessibleCheckbox({
    required String label,
    required bool value,
    required ValueChanged<bool?> onChanged,
    String? hint,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      checked: value,
      child: CheckboxListTile(
        title: Text(label),
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  /// 접근성을 고려한 라디오 버튼
  static Widget accessibleRadio<T>({
    required String label,
    required T value,
    required T? groupValue,
    required ValueChanged<T?> onChanged,
    String? hint,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      checked: value == groupValue,
      child: RadioListTile<T>(
        title: Text(label),
        value: value,
        // ignore: deprecated_member_use
        groupValue: groupValue,
        // ignore: deprecated_member_use
        onChanged: onChanged,
      ),
    );
  }

  /// 접근성을 고려한 탭바
  static Widget accessibleTabBar({
    required List<String> labels,
    required int selectedIndex,
    required ValueChanged<int> onTap,
  }) {
    return Semantics(
      child: TabBar(
        tabs: labels.map((label) => Tab(text: label)).toList(),
        onTap: onTap,
      ),
    );
  }

  /// 접근성을 고려한 슬라이더
  static Widget accessibleSlider({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
    double min = 0.0,
    double max = 1.0,
    int? divisions,
    String? hint,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      slider: true,
      child: Slider(
        value: value,
        onChanged: onChanged,
        min: min,
        max: max,
        divisions: divisions,
      ),
    );
  }

  /// 접근성을 고려한 프로그레스 바
  static Widget accessibleProgressBar({
    required String label,
    required double value,
    String? hint,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      child: LinearProgressIndicator(value: value),
    );
  }

  /// 접근성을 고려한 툴팁
  static Widget accessibleTooltip({
    required String message,
    required Widget child,
    Duration? waitDuration,
  }) {
    return Tooltip(
      message: message,
      waitDuration: waitDuration ?? const Duration(milliseconds: 500),
      child: child,
    );
  }

  /// 접근성을 고려한 플로팅 액션 버튼
  static Widget accessibleFloatingActionButton({
    required String label,
    required VoidCallback onPressed,
    required Widget child,
    String? hint,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      button: true,
      child: FloatingActionButton(onPressed: onPressed, child: child),
    );
  }

  /// 접근성을 고려한 드롭다운
  static Widget accessibleDropdown<T>({
    required String label,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    String? hint,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      child: DropdownButtonFormField<T>(
        initialValue: value,
        items: items,
        onChanged: onChanged,
        decoration: InputDecoration(labelText: label, hintText: hint),
      ),
    );
  }
}
