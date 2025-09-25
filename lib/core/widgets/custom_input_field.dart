import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 입력 필드 크기 옵션
enum InputFieldSize { small, medium, large }

/// 입력 필드 스타일 옵션
enum InputFieldStyle { outlined, filled, underlined }

/// 커스텀 입력 필드 컴포넌트
/// Material Design 3 기반으로 다양한 스타일과 기능을 지원합니다.
class CustomInputField extends StatefulWidget {
  /// 컨트롤러
  final TextEditingController? controller;

  /// 라벨 텍스트
  final String? labelText;

  /// 힌트 텍스트
  final String? hintText;

  /// 도움말 텍스트
  final String? helperText;

  /// 에러 텍스트
  final String? errorText;

  /// 입력 필드 크기
  final InputFieldSize size;

  /// 입력 필드 스타일
  final InputFieldStyle style;

  /// 입력 타입
  final TextInputType keyboardType;

  /// 입력 액션
  final TextInputAction textInputAction;

  /// 비밀번호 필드 여부
  final bool obscureText;

  /// 읽기 전용 여부
  final bool readOnly;

  /// 비활성화 여부
  final bool enabled;

  /// 최대 라인 수
  final int? maxLines;

  /// 최소 라인 수
  final int? minLines;

  /// 최대 길이
  final int? maxLength;

  /// 최대 길이 표시 여부
  final bool showMaxLength;

  /// 접두사 아이콘
  final IconData? prefixIcon;

  /// 접미사 아이콘
  final IconData? suffixIcon;

  /// 접미사 위젯
  final Widget? suffix;

  /// 접두사 위젯
  final Widget? prefix;

  /// 포커스 노드
  final FocusNode? focusNode;

  /// 값 변경 콜백
  final ValueChanged<String>? onChanged;

  /// 제출 콜백
  final ValueChanged<String>? onSubmitted;

  /// 탭 콜백
  final VoidCallback? onTap;

  /// 유효성 검증 함수
  final String? Function(String?)? validator;

  /// 자동 포커스 여부
  final bool autofocus;

  /// 텍스트 정렬
  final TextAlign textAlign;

  /// 텍스트 대문자화
  final TextCapitalization textCapitalization;

  /// 입력 포맷터
  final List<TextInputFormatter>? inputFormatters;

  /// 접근성 라벨
  final String? semanticLabel;

  /// 접근성 힌트
  final String? semanticHint;

  /// 커스텀 데코레이션
  final InputDecoration? decoration;

  const CustomInputField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.size = InputFieldSize.medium,
    this.style = InputFieldStyle.outlined,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
    this.obscureText = false,
    this.readOnly = false,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.showMaxLength = true,
    this.prefixIcon,
    this.suffixIcon,
    this.suffix,
    this.prefix,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.validator,
    this.autofocus = false,
    this.textAlign = TextAlign.start,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.semanticLabel,
    this.semanticHint,
    this.decoration,
  });

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _obscureText = false;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
    _obscureText = widget.obscureText;

    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
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

    // 기본 데코레이션 구성
    final decoration =
        widget.decoration ?? _buildDefaultDecoration(theme, colorScheme);

    // 접근성 지원
    final Widget textField = Semantics(
      label: widget.semanticLabel ?? widget.labelText,
      hint: widget.semanticHint ?? widget.hintText,
      textField: true,
      enabled: widget.enabled,
      child: _buildTextField(theme, colorScheme, decoration),
    );

    return textField;
  }

  /// 기본 데코레이션 구성
  InputDecoration _buildDefaultDecoration(
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return InputDecoration(
      labelText: widget.labelText,
      hintText: widget.hintText,
      helperText: widget.helperText,
      errorText: widget.errorText,
      prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
      suffixIcon: _buildSuffixIcon(),
      prefix: widget.prefix,
      suffix: widget.suffix,
      counterText: widget.maxLength != null && widget.showMaxLength ? null : '',
      filled: widget.style == InputFieldStyle.filled,
      border: _getBorderStyle(context),
      enabledBorder: _getBorderStyle(context),
      focusedBorder: _getBorderStyle(context, isFocused: true),
      errorBorder: _getBorderStyle(context, isError: true),
      focusedErrorBorder: _getBorderStyle(
        context,
        isFocused: true,
        isError: true,
      ),
      contentPadding: _getContentPadding(),
      labelStyle: _getLabelStyle(theme, colorScheme),
      hintStyle: _getHintStyle(theme, colorScheme),
      helperStyle: _getHelperStyle(theme, colorScheme),
      errorStyle: _getErrorStyle(theme, colorScheme),
    );
  }

  /// 접미사 아이콘 구성
  Widget? _buildSuffixIcon() {
    if (widget.suffix != null) return null;

    if (widget.obscureText) {
      return IconButton(
        icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
        onPressed: _toggleObscureText,
        tooltip: _obscureText ? '비밀번호 보기' : '비밀번호 숨기기',
      );
    }

    if (widget.suffixIcon != null) {
      return Icon(widget.suffixIcon);
    }

    return null;
  }

  /// 테두리 스타일 반환
  InputBorder _getBorderStyle(
    BuildContext context, {
    bool isFocused = false,
    bool isError = false,
  }) {
    final color = isError
        ? Theme.of(context).colorScheme.error
        : isFocused
        ? Theme.of(context).colorScheme.primary
        : Colors.grey.shade300;

    final width = isFocused ? 2.0 : 1.0;

    switch (widget.style) {
      case InputFieldStyle.outlined:
        return OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color, width: width),
        );
      case InputFieldStyle.filled:
        return OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        );
      case InputFieldStyle.underlined:
        return UnderlineInputBorder(
          borderSide: BorderSide(color: color, width: width),
        );
    }
  }

  /// 콘텐츠 패딩 반환
  EdgeInsets _getContentPadding() {
    switch (widget.size) {
      case InputFieldSize.small:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      case InputFieldSize.medium:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
      case InputFieldSize.large:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 16);
    }
  }

  /// 라벨 스타일 반환
  TextStyle _getLabelStyle(ThemeData theme, ColorScheme colorScheme) {
    return TextStyle(
      fontSize: _getFontSize(),
      fontFamily: 'NotoSansKR',
      color: _isFocused
          ? colorScheme.primary
          : Colors.black87, // 라벨 텍스트를 검정색으로 변경
    );
  }

  /// 힌트 스타일 반환
  TextStyle _getHintStyle(ThemeData theme, ColorScheme colorScheme) {
    return TextStyle(
      fontSize: _getFontSize(),
      fontFamily: 'NotoSansKR',
      color: Colors.black54, // 힌트 텍스트를 검정색 계열로 변경
    );
  }

  /// 도움말 스타일 반환
  TextStyle _getHelperStyle(ThemeData theme, ColorScheme colorScheme) {
    return TextStyle(
      fontSize: _getFontSize() - 2,
      fontFamily: 'NotoSansKR',
      color: colorScheme.onSurface.withValues(alpha: 0.7),
    );
  }

  /// 에러 스타일 반환
  TextStyle _getErrorStyle(ThemeData theme, ColorScheme colorScheme) {
    return TextStyle(
      fontSize: _getFontSize() - 2,
      fontFamily: 'NotoSansKR',
      color: colorScheme.error,
    );
  }

  /// 폰트 크기 반환
  double _getFontSize() {
    switch (widget.size) {
      case InputFieldSize.small:
        return 14;
      case InputFieldSize.medium:
        return 16;
      case InputFieldSize.large:
        return 18;
    }
  }

  /// 텍스트 필드 구성
  Widget _buildTextField(
    ThemeData theme,
    ColorScheme colorScheme,
    InputDecoration decoration,
  ) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      obscureText: _obscureText,
      readOnly: widget.readOnly,
      enabled: widget.enabled,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      onTap: widget.onTap,
      autofocus: widget.autofocus,
      textAlign: widget.textAlign,
      textCapitalization: widget.textCapitalization,
      inputFormatters: widget.inputFormatters,
      // 한글 입력을 위한 설정
      enableSuggestions: true,
      autocorrect: true,
      smartDashesType: SmartDashesType.enabled,
      smartQuotesType: SmartQuotesType.enabled,
      // IME 조합 중 안정성을 위한 설정
      enableIMEPersonalizedLearning: true,
      enableInteractiveSelection: true,
      style: TextStyle(
        fontSize: _getFontSize(),
        fontFamily: 'NotoSansKR',
        color: widget.enabled
            ? Colors
                  .black // 입력 텍스트를 검정색으로 변경
            : Colors.black54, // 비활성화된 텍스트도 검정색 계열로 변경
      ),
      decoration: decoration,
    );
  }
}

/// 폼 필드 래퍼 - 유효성 검증 기능 포함
class CustomFormField extends StatelessWidget {
  /// 컨트롤러
  final TextEditingController? controller;

  /// 라벨 텍스트
  final String? labelText;

  /// 힌트 텍스트
  final String? hintText;

  /// 도움말 텍스트
  final String? helperText;

  /// 입력 필드 크기
  final InputFieldSize size;

  /// 입력 필드 스타일
  final InputFieldStyle style;

  /// 입력 타입
  final TextInputType keyboardType;

  /// 입력 액션
  final TextInputAction textInputAction;

  /// 비밀번호 필드 여부
  final bool obscureText;

  /// 읽기 전용 여부
  final bool readOnly;

  /// 비활성화 여부
  final bool enabled;

  /// 최대 라인 수
  final int? maxLines;

  /// 최소 라인 수
  final int? minLines;

  /// 최대 길이
  final int? maxLength;

  /// 최대 길이 표시 여부
  final bool showMaxLength;

  /// 접두사 아이콘
  final IconData? prefixIcon;

  /// 접미사 아이콘
  final IconData? suffixIcon;

  /// 접미사 위젯
  final Widget? suffix;

  /// 접두사 위젯
  final Widget? prefix;

  /// 포커스 노드
  final FocusNode? focusNode;

  /// 값 변경 콜백
  final ValueChanged<String>? onChanged;

  /// 제출 콜백
  final ValueChanged<String>? onSubmitted;

  /// 탭 콜백
  final VoidCallback? onTap;

  /// 유효성 검증 함수
  final String? Function(String?)? validator;

  /// 자동 포커스 여부
  final bool autofocus;

  /// 텍스트 정렬
  final TextAlign textAlign;

  /// 텍스트 대문자화
  final TextCapitalization textCapitalization;

  /// 입력 포맷터
  final List<TextInputFormatter>? inputFormatters;

  /// 접근성 라벨
  final String? semanticLabel;

  /// 접근성 힌트
  final String? semanticHint;

  const CustomFormField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.helperText,
    this.size = InputFieldSize.medium,
    this.style = InputFieldStyle.outlined,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
    this.obscureText = false,
    this.readOnly = false,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.showMaxLength = true,
    this.prefixIcon,
    this.suffixIcon,
    this.suffix,
    this.prefix,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.validator,
    this.autofocus = false,
    this.textAlign = TextAlign.start,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.semanticLabel,
    this.semanticHint,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      readOnly: readOnly,
      enabled: enabled,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      onTap: onTap,
      validator: validator,
      autofocus: autofocus,
      textAlign: textAlign,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      // 한글 입력을 위한 설정
      enableSuggestions: true,
      autocorrect: true,
      smartDashesType: SmartDashesType.enabled,
      smartQuotesType: SmartQuotesType.enabled,
      enableIMEPersonalizedLearning: true,
      enableInteractiveSelection: true,
      style: TextStyle(
        fontSize: _getFontSize(),
        fontFamily: 'NotoSansKR',
        color: Colors.black, // 입력 텍스트를 검정색으로 변경
      ),
      decoration: _buildDecoration(context),
    );
  }

  /// 데코레이션 구성
  InputDecoration _buildDecoration(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      helperText: helperText,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      suffixIcon: suffixIcon != null ? Icon(suffixIcon) : null,
      prefix: prefix,
      suffix: suffix,
      counterText: maxLength != null && showMaxLength ? null : '',
      filled: style == InputFieldStyle.filled,
      border: _getBorderStyle(context),
      enabledBorder: _getBorderStyle(context),
      focusedBorder: _getBorderStyle(context, isFocused: true),
      errorBorder: _getBorderStyle(context, isError: true),
      focusedErrorBorder: _getBorderStyle(
        context,
        isFocused: true,
        isError: true,
      ),
      contentPadding: _getContentPadding(),
      labelStyle: TextStyle(
        fontSize: _getFontSize(),
        fontFamily: 'NotoSansKR',
        color: Colors.black87, // 라벨 텍스트를 검정색으로 변경
      ),
      hintStyle: TextStyle(
        fontSize: _getFontSize(),
        fontFamily: 'NotoSansKR',
        color: Colors.black54, // 힌트 텍스트를 검정색 계열로 변경
      ),
      helperStyle: TextStyle(
        fontSize: _getFontSize() - 2,
        fontFamily: 'NotoSansKR',
        color: colorScheme.onSurface.withValues(alpha: 0.7),
      ),
      errorStyle: TextStyle(
        fontSize: _getFontSize() - 2,
        fontFamily: 'NotoSansKR',
        color: colorScheme.error,
      ),
    );
  }

  /// 테두리 스타일 반환
  InputBorder _getBorderStyle(
    BuildContext context, {
    bool isFocused = false,
    bool isError = false,
  }) {
    final color = isError
        ? Theme.of(context).colorScheme.error
        : isFocused
        ? Theme.of(context).colorScheme.primary
        : Colors.grey.shade300;

    final width = isFocused ? 2.0 : 1.0;

    switch (style) {
      case InputFieldStyle.outlined:
        return OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color, width: width),
        );
      case InputFieldStyle.filled:
        return OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        );
      case InputFieldStyle.underlined:
        return UnderlineInputBorder(
          borderSide: BorderSide(color: color, width: width),
        );
    }
  }

  /// 콘텐츠 패딩 반환
  EdgeInsets _getContentPadding() {
    switch (size) {
      case InputFieldSize.small:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      case InputFieldSize.medium:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
      case InputFieldSize.large:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 16);
    }
  }

  /// 폰트 크기 반환
  double _getFontSize() {
    switch (size) {
      case InputFieldSize.small:
        return 14;
      case InputFieldSize.medium:
        return 16;
      case InputFieldSize.large:
        return 18;
    }
  }
}

/// 검색 입력 필드
class SearchInputField extends StatefulWidget {
  /// 컨트롤러
  final TextEditingController? controller;

  /// 힌트 텍스트
  final String? hintText;

  /// 검색 콜백
  final ValueChanged<String>? onSearch;

  /// 취소 콜백
  final VoidCallback? onCancel;

  /// 자동 포커스 여부
  final bool autofocus;

  /// 검색 버튼 표시 여부
  final bool showSearchButton;

  /// 취소 버튼 표시 여부
  final bool showCancelButton;

  const SearchInputField({
    super.key,
    this.controller,
    this.hintText,
    this.onSearch,
    this.onCancel,
    this.autofocus = false,
    this.showSearchButton = true,
    this.showCancelButton = true,
  });

  @override
  State<SearchInputField> createState() => _SearchInputFieldState();
}

class _SearchInputFieldState extends State<SearchInputField> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    _focusNode.dispose();
    super.dispose();
  }

  void _performSearch() {
    widget.onSearch?.call(_controller.text);
  }

  void _clearSearch() {
    _controller.clear();
    widget.onCancel?.call();
  }

  @override
  Widget build(BuildContext context) {
    return CustomInputField(
      controller: _controller,
      hintText: widget.hintText ?? '검색...',
      prefixIcon: Icons.search,
      suffixIcon: _controller.text.isNotEmpty ? Icons.clear : null,
      onChanged: (value) {
        setState(() {});
        if (value.isEmpty) {
          widget.onCancel?.call();
        }
      },
      onSubmitted: (value) => _performSearch(),
      textInputAction: TextInputAction.search,
      autofocus: widget.autofocus,
      suffix: _controller.text.isNotEmpty && widget.showCancelButton
          ? IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearSearch,
              tooltip: '검색어 지우기',
            )
          : null,
    );
  }
}
