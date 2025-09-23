import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../accessibility/accessibility_utils.dart';

/// 커스텀 텍스트 필드 위젯
/// 다양한 스타일과 상태를 지원하는 재사용 가능한 텍스트 필드입니다.
class CustomTextField extends StatefulWidget {
  const CustomTextField({
    super.key,
    this.controller,
    this.initialValue,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixText,
    this.suffixText,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.obscureText = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.validator,
    this.inputFormatters,
    this.focusNode,
    this.borderRadius,
    this.contentPadding,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.errorBorderColor,
    this.textStyle,
    this.labelStyle,
    this.hintStyle,
    this.helperStyle,
    this.errorStyle,
    this.counterStyle,
    this.isRequired = false,
    this.showCounter = false,
    this.obscuringCharacter = '•',
    this.enableInteractiveSelection = true,
    this.tooltip,
  });

  final TextEditingController? controller;
  final String? initialValue;
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? prefixText;
  final String? suffixText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final bool obscureText;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final bool autocorrect;
  final bool enableSuggestions;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final FormFieldValidator<String>? validator;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final double? borderRadius;
  final EdgeInsetsGeometry? contentPadding;
  final Color? fillColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? errorBorderColor;
  final TextStyle? textStyle;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;
  final TextStyle? helperStyle;
  final TextStyle? errorStyle;
  final TextStyle? counterStyle;
  final bool isRequired;
  final bool showCounter;
  final String obscuringCharacter;
  final bool enableInteractiveSelection;
  final String? tooltip;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late FocusNode _focusNode;
  bool _obscureText = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _obscureText = widget.obscureText;
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    // 포커스 상태 변경 시 필요한 로직이 있다면 여기에 추가
    setState(() {});
  }

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // 스타일 계산
    final decoration = _buildInputDecoration(context, theme, colorScheme);

    // 툴팁이 있는 경우 Tooltip으로 감싸기
    Widget textField = _buildTextField(decoration);

    if (widget.tooltip != null && widget.enabled) {
      textField = Tooltip(message: widget.tooltip!, child: textField);
    }

    return textField;
  }

  /// 입력 장식 생성
  InputDecoration _buildInputDecoration(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final borderRadius = widget.borderRadius ?? 16.0;
    final contentPadding =
        widget.contentPadding ??
        const EdgeInsets.symmetric(horizontal: 16, vertical: 16);

    return InputDecoration(
      labelText: widget.labelText != null
          ? (widget.isRequired ? '${widget.labelText} *' : widget.labelText)
          : null,
      hintText: widget.hintText,
      helperText: widget.helperText,
      errorText: widget.errorText,
      prefixIcon: widget.prefixIcon,
      suffixIcon: _buildSuffixIcon(),
      prefixText: widget.prefixText,
      suffixText: widget.suffixText,
      counterText: widget.showCounter ? null : '',

      filled: true,
      fillColor: widget.fillColor ?? colorScheme.surfaceContainerHighest,

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide.none,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(
          color: widget.borderColor ?? colorScheme.outline,
          width: 1,
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(
          color: widget.focusedBorderColor ?? colorScheme.primary,
          width: 2,
        ),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(
          color: widget.errorBorderColor ?? colorScheme.error,
          width: 2,
        ),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(
          color: widget.errorBorderColor ?? colorScheme.error,
          width: 2,
        ),
      ),

      contentPadding: contentPadding,

      labelStyle: widget.labelStyle,
      hintStyle: widget.hintStyle,
      helperStyle: widget.helperStyle,
      errorStyle: widget.errorStyle,
      counterStyle: widget.counterStyle,

      floatingLabelStyle: TextStyle(
        color: widget.focusedBorderColor ?? colorScheme.primary,
      ),
    );
  }

  /// 접미사 아이콘 생성
  Widget? _buildSuffixIcon() {
    if (widget.obscureText) {
      return IconButton(
        icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
        onPressed: _toggleObscureText,
        tooltip: _obscureText ? '비밀번호 보기' : '비밀번호 숨기기',
      );
    }

    return widget.suffixIcon;
  }

  /// 텍스트 필드 위젯 생성
  Widget _buildTextField(InputDecoration decoration) {
    final textField = TextFormField(
      controller: widget.controller,
      initialValue: widget.initialValue,
      focusNode: _focusNode,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      textCapitalization: widget.textCapitalization,
      obscureText: _obscureText,
      obscuringCharacter: widget.obscuringCharacter,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      autofocus: widget.autofocus,
      autocorrect: widget.autocorrect,
      enableSuggestions: widget.enableSuggestions,
      enableInteractiveSelection: widget.enableInteractiveSelection,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      onTap: widget.onTap,
      validator: widget.validator,
      inputFormatters: widget.inputFormatters,
      style: widget.textStyle,
      decoration: decoration,
    );

    // 접근성 적용
    return AccessibilityUtils.semanticTextField(
      label: widget.labelText ?? '',
      hint: widget.hintText,
      value: widget.controller?.text,
      enabled: widget.enabled,
      child: textField,
    );
  }
}

/// 편의 생성자들
extension CustomTextFieldConvenience on CustomTextField {
  /// 이메일 입력 필드
  static CustomTextField email({
    TextEditingController? controller,
    String? labelText,
    String? hintText,
    String? helperText,
    String? errorText,
    bool enabled = true,
    bool isRequired = false,
    ValueChanged<String>? onChanged,
    FormFieldValidator<String>? validator,
    FocusNode? focusNode,
  }) {
    return CustomTextField(
      controller: controller,
      labelText: labelText ?? '이메일',
      hintText: hintText ?? 'example@email.com',
      helperText: helperText,
      errorText: errorText,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      enabled: enabled,
      isRequired: isRequired,
      onChanged: onChanged,
      validator: validator,
      focusNode: focusNode,
    );
  }

  /// 비밀번호 입력 필드
  static CustomTextField password({
    TextEditingController? controller,
    String? labelText,
    String? hintText,
    String? helperText,
    String? errorText,
    bool enabled = true,
    bool isRequired = false,
    ValueChanged<String>? onChanged,
    FormFieldValidator<String>? validator,
    FocusNode? focusNode,
  }) {
    return CustomTextField(
      controller: controller,
      labelText: labelText ?? '비밀번호',
      hintText: hintText ?? '비밀번호를 입력하세요',
      helperText: helperText,
      errorText: errorText,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: TextInputAction.done,
      obscureText: true,
      enabled: enabled,
      isRequired: isRequired,
      onChanged: onChanged,
      validator: validator,
      focusNode: focusNode,
    );
  }

  /// 검색 입력 필드
  static CustomTextField search({
    TextEditingController? controller,
    String? hintText,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    VoidCallback? onTap,
    FocusNode? focusNode,
  }) {
    return CustomTextField(
      controller: controller,
      hintText: hintText ?? '검색어를 입력하세요',
      prefixIcon: const Icon(Icons.search),
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.search,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      onTap: onTap,
      focusNode: focusNode,
    );
  }

  /// 다중 라인 텍스트 필드
  static CustomTextField multiline({
    TextEditingController? controller,
    String? labelText,
    String? hintText,
    String? helperText,
    String? errorText,
    int? maxLines,
    int? minLines,
    int? maxLength,
    bool enabled = true,
    bool isRequired = false,
    ValueChanged<String>? onChanged,
    FormFieldValidator<String>? validator,
    FocusNode? focusNode,
  }) {
    return CustomTextField(
      controller: controller,
      labelText: labelText,
      hintText: hintText,
      helperText: helperText,
      errorText: errorText,
      maxLines: maxLines ?? 5,
      minLines: minLines ?? 3,
      maxLength: maxLength,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      enabled: enabled,
      isRequired: isRequired,
      onChanged: onChanged,
      validator: validator,
      focusNode: focusNode,
      showCounter: maxLength != null,
    );
  }
}
