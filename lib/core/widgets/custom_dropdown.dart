import 'package:flutter/material.dart';

/// 드롭다운 아이템 모델
class DropdownItem<T> {
  /// 값
  final T value;

  /// 표시 텍스트
  final String text;

  /// 아이콘 (선택사항)
  final IconData? icon;

  /// 비활성화 여부
  final bool disabled;

  /// 추가 데이터
  final Map<String, dynamic>? data;

  const DropdownItem({
    required this.value,
    required this.text,
    this.icon,
    this.disabled = false,
    this.data,
  });
}

/// 드롭다운 스타일 옵션
enum DropdownStyle { outlined, filled, underlined }

/// 드롭다운 크기 옵션
enum DropdownSize { small, medium, large }

/// 커스텀 드롭다운 컴포넌트
/// Material Design 3 기반으로 다양한 스타일과 기능을 지원합니다.
class CustomDropdown<T> extends StatefulWidget {
  /// 선택된 값
  final T? value;

  /// 드롭다운 아이템들
  final List<DropdownItem<T>> items;

  /// 값 변경 콜백
  final ValueChanged<T?>? onChanged;

  /// 드롭다운 스타일
  final DropdownStyle style;

  /// 드롭다운 크기
  final DropdownSize size;

  /// 라벨 텍스트
  final String? labelText;

  /// 힌트 텍스트
  final String? hintText;

  /// 헬퍼 텍스트
  final String? helperText;

  /// 에러 텍스트
  final String? errorText;

  /// 아이콘
  final IconData? icon;

  /// 비활성화 여부
  final bool enabled;

  /// 읽기 전용 여부
  final bool readOnly;

  /// 필수 여부
  final bool required;

  /// 검색 가능 여부
  final bool searchable;

  /// 다중 선택 가능 여부
  final bool multiple;

  /// 선택된 값들 (다중 선택 시)
  final List<T>? selectedValues;

  /// 다중 선택 값 변경 콜백
  final ValueChanged<List<T>>? onMultipleChanged;

  /// 커스텀 아이템 빌더
  final Widget Function(BuildContext, DropdownItem<T>)? itemBuilder;

  /// 커스텀 선택된 아이템 빌더
  final Widget Function(BuildContext, DropdownItem<T>)? selectedItemBuilder;

  /// 접근성 라벨
  final String? semanticLabel;

  /// 접근성 힌트
  final String? semanticHint;

  const CustomDropdown({
    super.key,
    this.value,
    required this.items,
    this.onChanged,
    this.style = DropdownStyle.outlined,
    this.size = DropdownSize.medium,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.icon,
    this.enabled = true,
    this.readOnly = false,
    this.required = false,
    this.searchable = false,
    this.multiple = false,
    this.selectedValues,
    this.onMultipleChanged,
    this.itemBuilder,
    this.selectedItemBuilder,
    this.semanticLabel,
    this.semanticHint,
  });

  @override
  State<CustomDropdown<T>> createState() => _CustomDropdownState<T>();
}

class _CustomDropdownState<T> extends State<CustomDropdown<T>> {
  T? _selectedValue;
  List<T> _selectedValues = [];
  final TextEditingController _searchController = TextEditingController();
  List<DropdownItem<T>> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.value;
    _selectedValues = widget.selectedValues ?? [];
    _filteredItems = widget.items;

    if (widget.searchable) {
      _searchController.addListener(_onSearchChanged);
    }
  }

  @override
  void didUpdateWidget(CustomDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _selectedValue = widget.value;
    }
    if (widget.selectedValues != oldWidget.selectedValues) {
      _selectedValues = widget.selectedValues ?? [];
    }
    if (widget.items != oldWidget.items) {
      _filteredItems = widget.items;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      final query = _searchController.text.toLowerCase();
      _filteredItems = widget.items.where((item) {
        return item.text.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (widget.multiple) {
      return _buildMultipleDropdown(theme, colorScheme);
    } else {
      return _buildSingleDropdown(theme, colorScheme);
    }
  }

  /// 단일 선택 드롭다운 구성
  Widget _buildSingleDropdown(ThemeData theme, ColorScheme colorScheme) {
    return Semantics(
      label: widget.semanticLabel ?? widget.labelText,
      hint: widget.semanticHint ?? widget.hintText,
      child: DropdownButtonFormField<T>(
        initialValue: _selectedValue,
        items: _filteredItems.map((item) {
          return DropdownMenuItem<T>(
            value: item.value,
            enabled: !item.disabled,
            child: _buildDropdownItem(item, theme, colorScheme),
          );
        }).toList(),
        onChanged: widget.enabled && !widget.readOnly
            ? (T? value) {
                setState(() {
                  _selectedValue = value;
                });
                widget.onChanged?.call(value);
              }
            : null,
        decoration: _buildInputDecoration(theme, colorScheme),
        icon: Icon(
          Icons.arrow_drop_down,
          color: widget.enabled
              ? colorScheme.onSurface
              : colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        isExpanded: true,
        menuMaxHeight: 300,
        selectedItemBuilder: widget.selectedItemBuilder != null
            ? (context) => _filteredItems
                  .where((item) => item.value == _selectedValue)
                  .map((item) => widget.selectedItemBuilder!(context, item))
                  .toList()
            : null,
      ),
    );
  }

  /// 다중 선택 드롭다운 구성
  Widget _buildMultipleDropdown(ThemeData theme, ColorScheme colorScheme) {
    return Semantics(
      label: widget.semanticLabel ?? widget.labelText,
      hint: widget.semanticHint ?? widget.hintText,
      child: InkWell(
        onTap: widget.enabled && !widget.readOnly
            ? _showMultipleSelectionDialog
            : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: _getContentPadding(),
          decoration: _buildBoxDecoration(theme, colorScheme),
          child: Row(
            children: [
              if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  color: widget.enabled
                      ? colorScheme.onSurface
                      : colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.labelText != null) ...[
                      Text(
                        widget.labelText! + (widget.required ? ' *' : ''),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: widget.enabled
                              ? colorScheme.onSurface
                              : colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    Text(
                      _getMultipleSelectionText(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: widget.enabled
                            ? colorScheme.onSurface
                            : colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    if (widget.helperText != null &&
                        widget.errorText == null) ...[
                      const SizedBox(height: 4),
                      Text(
                        widget.helperText!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                    if (widget.errorText != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        widget.errorText!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.error,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.arrow_drop_down,
                color: widget.enabled
                    ? colorScheme.onSurface
                    : colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 다중 선택 텍스트 반환
  String _getMultipleSelectionText() {
    if (_selectedValues.isEmpty) {
      return widget.hintText ?? '항목을 선택하세요';
    }

    if (_selectedValues.length == 1) {
      final item = widget.items.firstWhere(
        (item) => item.value == _selectedValues.first,
      );
      return item.text;
    }

    return '${_selectedValues.length}개 항목 선택됨';
  }

  /// 다중 선택 다이얼로그 표시
  Future<void> _showMultipleSelectionDialog() async {
    final result = await showDialog<List<T>>(
      context: context,
      builder: (context) => _MultipleSelectionDialog<T>(
        items: widget.items,
        selectedValues: _selectedValues,
        searchable: widget.searchable,
        title: widget.labelText ?? '항목 선택',
      ),
    );

    if (result != null) {
      setState(() {
        _selectedValues = result;
      });
      widget.onMultipleChanged?.call(result);
    }
  }

  /// 드롭다운 아이템 구성
  Widget _buildDropdownItem(
    DropdownItem<T> item,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    if (widget.itemBuilder != null) {
      return widget.itemBuilder!(context, item);
    }

    return Row(
      children: [
        if (item.icon != null) ...[
          Icon(
            item.icon,
            size: 20,
            color: item.disabled
                ? colorScheme.onSurface.withValues(alpha: 0.3)
                : colorScheme.onSurface,
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Text(
            item.text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: item.disabled
                  ? colorScheme.onSurface.withValues(alpha: 0.3)
                  : colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  /// 입력 데코레이션 구성
  InputDecoration _buildInputDecoration(
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return InputDecoration(
      labelText: widget.labelText,
      hintText: widget.hintText,
      helperText: widget.helperText,
      errorText: widget.errorText,
      prefixIcon: widget.icon != null ? Icon(widget.icon) : null,
      filled: widget.style == DropdownStyle.filled,
      border: _getBorderStyle(),
      enabledBorder: _getBorderStyle(),
      focusedBorder: _getBorderStyle(isFocused: true),
      errorBorder: _getBorderStyle(isError: true),
      focusedErrorBorder: _getBorderStyle(isFocused: true, isError: true),
      contentPadding: _getContentPadding(),
      labelStyle: TextStyle(
        fontSize: _getFontSize(),
        fontFamily: 'NotoSansKR',
        color: colorScheme.onSurface,
      ),
      hintStyle: TextStyle(
        fontSize: _getFontSize(),
        fontFamily: 'NotoSansKR',
        color: Colors.grey.shade500,
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

  /// BoxDecoration 반환
  BoxDecoration _buildBoxDecoration(ThemeData theme, ColorScheme colorScheme) {
    final isFilled = widget.style == DropdownStyle.filled;
    final isError = widget.errorText != null;

    return BoxDecoration(
      color: isFilled ? colorScheme.surfaceContainerHighest : null,
      borderRadius: BorderRadius.circular(12),
      border: widget.style == DropdownStyle.outlined
          ? Border.all(
              color: isError ? colorScheme.error : Colors.grey.shade300,
              width: 1.0,
            )
          : null,
    );
  }

  /// 테두리 스타일 반환
  InputBorder _getBorderStyle({bool isFocused = false, bool isError = false}) {
    final color = isError
        ? Theme.of(context).colorScheme.error
        : isFocused
        ? Theme.of(context).colorScheme.primary
        : Colors.grey.shade300;

    final width = isFocused ? 2.0 : 1.0;

    switch (widget.style) {
      case DropdownStyle.outlined:
        return OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color, width: width),
        );
      case DropdownStyle.filled:
        return OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        );
      case DropdownStyle.underlined:
        return UnderlineInputBorder(
          borderSide: BorderSide(color: color, width: width),
        );
    }
  }

  /// 콘텐츠 패딩 반환
  EdgeInsets _getContentPadding() {
    switch (widget.size) {
      case DropdownSize.small:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      case DropdownSize.medium:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
      case DropdownSize.large:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 16);
    }
  }

  /// 폰트 크기 반환
  double _getFontSize() {
    switch (widget.size) {
      case DropdownSize.small:
        return 14;
      case DropdownSize.medium:
        return 16;
      case DropdownSize.large:
        return 18;
    }
  }
}

/// 다중 선택 다이얼로그
class _MultipleSelectionDialog<T> extends StatefulWidget {
  /// 드롭다운 아이템들
  final List<DropdownItem<T>> items;

  /// 선택된 값들
  final List<T> selectedValues;

  /// 검색 가능 여부
  final bool searchable;

  /// 제목
  final String title;

  const _MultipleSelectionDialog({
    required this.items,
    required this.selectedValues,
    required this.searchable,
    required this.title,
  });

  @override
  State<_MultipleSelectionDialog<T>> createState() =>
      _MultipleSelectionDialogState<T>();
}

class _MultipleSelectionDialogState<T>
    extends State<_MultipleSelectionDialog<T>> {
  late List<T> _selectedValues;
  final TextEditingController _searchController = TextEditingController();
  List<DropdownItem<T>> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _selectedValues = List.from(widget.selectedValues);
    _filteredItems = widget.items;

    if (widget.searchable) {
      _searchController.addListener(_onSearchChanged);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      final query = _searchController.text.toLowerCase();
      _filteredItems = widget.items.where((item) {
        return item.text.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _toggleSelection(T value) {
    setState(() {
      if (_selectedValues.contains(value)) {
        _selectedValues.remove(value);
      } else {
        _selectedValues.add(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.searchable) ...[
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: '검색...',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _filteredItems.length,
                itemBuilder: (context, index) {
                  final item = _filteredItems[index];
                  final isSelected = _selectedValues.contains(item.value);

                  return CheckboxListTile(
                    title: Text(item.text),
                    subtitle: item.icon != null ? Icon(item.icon) : null,
                    value: isSelected,
                    onChanged: item.disabled
                        ? null
                        : (bool? value) {
                            _toggleSelection(item.value);
                          },
                    enabled: !item.disabled,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_selectedValues),
          child: const Text('확인'),
        ),
      ],
    );
  }
}

/// 드롭다운 폼 필드
class CustomDropdownFormField<T> extends FormField<T> {
  /// 드롭다운 아이템들
  final List<DropdownItem<T>> items;

  /// 드롭다운 스타일
  final DropdownStyle style;

  /// 드롭다운 크기
  final DropdownSize size;

  /// 힌트 텍스트
  final String? hintText;

  /// 헬퍼 텍스트
  final String? helperText;

  /// 아이콘
  final IconData? icon;

  /// 읽기 전용 여부
  final bool readOnly;

  /// 필수 여부
  final bool required;

  /// 검색 가능 여부
  final bool searchable;

  /// 다중 선택 가능 여부
  final bool multiple;

  /// 선택된 값들 (다중 선택 시)
  final List<T>? selectedValues;

  /// 다중 선택 값 변경 콜백
  final ValueChanged<List<T>>? onMultipleChanged;

  /// 커스텀 아이템 빌더
  final Widget Function(BuildContext, DropdownItem<T>)? itemBuilder;

  /// 커스텀 선택된 아이템 빌더
  final Widget Function(BuildContext, DropdownItem<T>)? selectedItemBuilder;

  /// 접근성 라벨
  final String? semanticLabel;

  /// 접근성 힌트
  final String? semanticHint;
  final bool _enabled;

  @override
  bool get enabled => _enabled;

  CustomDropdownFormField({
    super.key,
    required super.validator,
    super.initialValue,
    super.onSaved,
    required this.items,
    this.style = DropdownStyle.outlined,
    this.size = DropdownSize.medium,
    this.hintText,
    this.helperText,
    this.icon,
    bool enabled = true,
    this.readOnly = false,
    this.required = false,
    this.searchable = false,
    this.multiple = false,
    this.selectedValues,
    this.onMultipleChanged,
    this.itemBuilder,
    this.selectedItemBuilder,
    this.semanticLabel,
    this.semanticHint,
  }) : _enabled = enabled,
       super(
         builder: (FormFieldState<T> state) {
           return CustomDropdown<T>(
             value: state.value,
             items: items,
             style: style,
             size: size,
             hintText: hintText,
             helperText: helperText,
             errorText: state.errorText,
             icon: icon,
             enabled: enabled,
             readOnly: readOnly,
             required: required,
             searchable: searchable,
             multiple: multiple,
             selectedValues: selectedValues,
             onMultipleChanged: onMultipleChanged,
             itemBuilder: itemBuilder,
             selectedItemBuilder: selectedItemBuilder,
             semanticLabel: semanticLabel,
             semanticHint: semanticHint,
             onChanged: (value) {
               state.didChange(value);
             },
           );
         },
       );
}

/// 드롭다운 유틸리티
class DropdownUtils {
  /// 문자열 리스트를 드롭다운 아이템으로 변환
  static List<DropdownItem<String>> fromStringList(List<String> items) {
    return items
        .map((item) => DropdownItem<String>(value: item, text: item))
        .toList();
  }

  /// 맵을 드롭다운 아이템으로 변환
  static List<DropdownItem<T>> fromMap<T>(Map<T, String> map) {
    return map.entries
        .map((entry) => DropdownItem<T>(value: entry.key, text: entry.value))
        .toList();
  }

  /// 열거형을 드롭다운 아이템으로 변환
  static List<DropdownItem<T>> fromEnum<T extends Enum>(List<T> enumValues) {
    return enumValues
        .map((value) => DropdownItem<T>(value: value, text: value.name))
        .toList();
  }

  /// 선택된 아이템 찾기
  static DropdownItem<T>? findSelectedItem<T>(
    List<DropdownItem<T>> items,
    T? value,
  ) {
    try {
      return items.firstWhere((item) => item.value == value);
    } catch (e) {
      return null;
    }
  }

  /// 선택된 아이템들 찾기
  static List<DropdownItem<T>> findSelectedItems<T>(
    List<DropdownItem<T>> items,
    List<T> values,
  ) {
    return items.where((item) => values.contains(item.value)).toList();
  }
}
