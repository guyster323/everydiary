import 'package:flutter/material.dart';

/// 날짜 선택기 모드
enum DatePickerMode { date, time, dateTime, range }

/// 날짜 선택기 스타일
enum DatePickerStyle { calendar, wheel, compact }

/// 커스텀 날짜 선택기 컴포넌트
/// Material Design 3 기반으로 다양한 스타일과 기능을 지원합니다.
class CustomDatePicker extends StatefulWidget {
  /// 선택된 날짜
  final DateTime? selectedDate;

  /// 선택된 시간
  final TimeOfDay? selectedTime;

  /// 날짜 범위 (range 모드에서 사용)
  final DateTimeRange? selectedRange;

  /// 날짜 선택기 모드
  final DatePickerMode mode;

  /// 날짜 선택기 스타일
  final DatePickerStyle style;

  /// 최소 날짜
  final DateTime? firstDate;

  /// 최대 날짜
  final DateTime? lastDate;

  /// 초기 날짜
  final DateTime? initialDate;

  /// 초기 시간
  final TimeOfDay? initialTime;

  /// 초기 날짜 범위
  final DateTimeRange? initialRange;

  /// 날짜 변경 콜백
  final ValueChanged<DateTime>? onDateChanged;

  /// 시간 변경 콜백
  final ValueChanged<TimeOfDay>? onTimeChanged;

  /// 날짜 범위 변경 콜백
  final ValueChanged<DateTimeRange>? onRangeChanged;

  /// 날짜 선택 콜백
  final ValueChanged<DateTime>? onDateSelected;

  /// 시간 선택 콜백
  final ValueChanged<TimeOfDay>? onTimeSelected;

  /// 날짜 범위 선택 콜백
  final ValueChanged<DateTimeRange>? onRangeSelected;

  /// 헬퍼 텍스트
  final String? helperText;

  /// 에러 텍스트
  final String? errorText;

  /// 라벨 텍스트
  final String? labelText;

  /// 힌트 텍스트
  final String? hintText;

  /// 아이콘
  final IconData? icon;

  /// 비활성화 여부
  final bool enabled;

  /// 읽기 전용 여부
  final bool readOnly;

  /// 필수 여부
  final bool required;

  /// 접근성 라벨
  final String? semanticLabel;

  /// 접근성 힌트
  final String? semanticHint;

  const CustomDatePicker({
    super.key,
    this.selectedDate,
    this.selectedTime,
    this.selectedRange,
    this.mode = DatePickerMode.date,
    this.style = DatePickerStyle.calendar,
    this.firstDate,
    this.lastDate,
    this.initialDate,
    this.initialTime,
    this.initialRange,
    this.onDateChanged,
    this.onTimeChanged,
    this.onRangeChanged,
    this.onDateSelected,
    this.onTimeSelected,
    this.onRangeSelected,
    this.helperText,
    this.errorText,
    this.labelText,
    this.hintText,
    this.icon,
    this.enabled = true,
    this.readOnly = false,
    this.required = false,
    this.semanticLabel,
    this.semanticHint,
  });

  @override
  State<CustomDatePicker> createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<CustomDatePicker> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  DateTimeRange? _selectedRange;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate ?? widget.initialDate;
    _selectedTime = widget.selectedTime ?? widget.initialTime;
    _selectedRange = widget.selectedRange ?? widget.initialRange;
  }

  @override
  void didUpdateWidget(CustomDatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedDate != oldWidget.selectedDate) {
      _selectedDate = widget.selectedDate;
    }
    if (widget.selectedTime != oldWidget.selectedTime) {
      _selectedTime = widget.selectedTime;
    }
    if (widget.selectedRange != oldWidget.selectedRange) {
      _selectedRange = widget.selectedRange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Semantics(
      label: widget.semanticLabel ?? widget.labelText,
      hint: widget.semanticHint ?? widget.hintText,
      textField: true,
      enabled: widget.enabled,
      child: InkWell(
        onTap: widget.enabled && !widget.readOnly ? _showDatePicker : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: widget.errorText != null
                  ? colorScheme.error
                  : Colors.grey.shade300,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(12),
            color: widget.enabled
                ? colorScheme.surface
                : colorScheme.surface.withValues(alpha: 0.6),
          ),
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
                      _getDisplayText(),
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
                _getTrailingIcon(),
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

  /// 표시할 텍스트 반환
  String _getDisplayText() {
    if (widget.hintText != null && _getSelectedValue() == null) {
      return widget.hintText!;
    }

    switch (widget.mode) {
      case DatePickerMode.date:
        if (_selectedDate != null) {
          return _formatDate(_selectedDate!);
        }
        break;
      case DatePickerMode.time:
        if (_selectedTime != null) {
          return _formatTime(_selectedTime!);
        }
        break;
      case DatePickerMode.dateTime:
        if (_selectedDate != null && _selectedTime != null) {
          return '${_formatDate(_selectedDate!)} ${_formatTime(_selectedTime!)}';
        } else if (_selectedDate != null) {
          return _formatDate(_selectedDate!);
        } else if (_selectedTime != null) {
          return _formatTime(_selectedTime!);
        }
        break;
      case DatePickerMode.range:
        if (_selectedRange != null) {
          return '${_formatDate(_selectedRange!.start)} - ${_formatDate(_selectedRange!.end)}';
        }
        break;
    }

    return widget.hintText ?? '날짜를 선택하세요';
  }

  /// 선택된 값 반환
  dynamic _getSelectedValue() {
    switch (widget.mode) {
      case DatePickerMode.date:
        return _selectedDate;
      case DatePickerMode.time:
        return _selectedTime;
      case DatePickerMode.dateTime:
        return _selectedDate != null && _selectedTime != null
            ? DateTime(
                _selectedDate!.year,
                _selectedDate!.month,
                _selectedDate!.day,
                _selectedTime!.hour,
                _selectedTime!.minute,
              )
            : null;
      case DatePickerMode.range:
        return _selectedRange;
    }
  }

  /// 트레일링 아이콘 반환
  IconData _getTrailingIcon() {
    switch (widget.mode) {
      case DatePickerMode.date:
        return Icons.calendar_today;
      case DatePickerMode.time:
        return Icons.access_time;
      case DatePickerMode.dateTime:
        return Icons.date_range;
      case DatePickerMode.range:
        return Icons.date_range;
    }
  }

  /// 날짜 포맷팅
  String _formatDate(DateTime date) {
    return '${date.year}년 ${date.month}월 ${date.day}일';
  }

  /// 시간 포맷팅
  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  /// 날짜 선택기 표시
  Future<void> _showDatePicker() async {
    switch (widget.mode) {
      case DatePickerMode.date:
        await _showDatePickerDialog();
        break;
      case DatePickerMode.time:
        await _showTimePickerDialog();
        break;
      case DatePickerMode.dateTime:
        await _showDateTimePickerDialog();
        break;
      case DatePickerMode.range:
        await _showDateRangePickerDialog();
        break;
    }
  }

  /// 날짜 선택기 다이얼로그 표시
  Future<void> _showDatePickerDialog() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: widget.firstDate ?? DateTime(1900),
      lastDate: widget.lastDate ?? DateTime(2100),
      locale: const Locale('ko', 'KR'),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      widget.onDateChanged?.call(picked);
      widget.onDateSelected?.call(picked);
    }
  }

  /// 시간 선택기 다이얼로그 표시
  Future<void> _showTimePickerDialog() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
      widget.onTimeChanged?.call(picked);
      widget.onTimeSelected?.call(picked);
    }
  }

  /// 날짜/시간 선택기 다이얼로그 표시
  Future<void> _showDateTimePickerDialog() async {
    // 먼저 날짜 선택
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: widget.firstDate ?? DateTime(1900),
      lastDate: widget.lastDate ?? DateTime(2100),
      locale: const Locale('ko', 'KR'),
    );

    if (pickedDate != null) {
      // 그 다음 시간 선택
      if (!mounted) return;
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: _selectedTime ?? TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDate = pickedDate;
          _selectedTime = pickedTime;
        });

        final DateTime dateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        widget.onDateChanged?.call(pickedDate);
        widget.onTimeChanged?.call(pickedTime);
        widget.onDateSelected?.call(dateTime);
        widget.onTimeSelected?.call(pickedTime);
      }
    }
  }

  /// 날짜 범위 선택기 다이얼로그 표시
  Future<void> _showDateRangePickerDialog() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: widget.firstDate ?? DateTime(1900),
      lastDate: widget.lastDate ?? DateTime(2100),
      initialDateRange: _selectedRange,
      locale: const Locale('ko', 'KR'),
    );

    if (picked != null && picked != _selectedRange) {
      setState(() {
        _selectedRange = picked;
      });
      widget.onRangeChanged?.call(picked);
      widget.onRangeSelected?.call(picked);
    }
  }
}

/// 날짜 선택기 폼 필드
class CustomDatePickerFormField extends FormField<DateTime> {
  /// 날짜 선택기 모드
  final DatePickerMode mode;

  /// 날짜 선택기 스타일
  final DatePickerStyle style;

  /// 최소 날짜
  final DateTime? firstDate;

  /// 최대 날짜
  final DateTime? lastDate;

  /// 초기 날짜
  final DateTime? initialDate;

  /// 초기 시간
  final TimeOfDay? initialTime;

  /// 초기 날짜 범위
  final DateTimeRange? initialRange;

  /// 날짜 변경 콜백
  final ValueChanged<DateTime>? onDateChanged;

  /// 시간 변경 콜백
  final ValueChanged<TimeOfDay>? onTimeChanged;

  /// 날짜 범위 변경 콜백
  final ValueChanged<DateTimeRange>? onRangeChanged;

  /// 날짜 선택 콜백
  final ValueChanged<DateTime>? onDateSelected;

  /// 시간 선택 콜백
  final ValueChanged<TimeOfDay>? onTimeSelected;

  /// 날짜 범위 선택 콜백
  final ValueChanged<DateTimeRange>? onRangeSelected;

  /// 헬퍼 텍스트
  final String? helperText;

  /// 라벨 텍스트
  final String? labelText;

  /// 힌트 텍스트
  final String? hintText;

  /// 아이콘
  final IconData? icon;

  /// 읽기 전용 여부
  final bool readOnly;

  /// 필수 여부
  final bool required;

  /// 접근성 라벨
  final String? semanticLabel;

  /// 접근성 힌트
  final String? semanticHint;
  final bool _enabled;

  @override
  bool get enabled => _enabled;

  CustomDatePickerFormField({
    super.key,
    required super.validator,
    super.initialValue,
    super.onSaved,
    this.mode = DatePickerMode.date,
    this.style = DatePickerStyle.calendar,
    this.firstDate,
    this.lastDate,
    this.initialDate,
    this.initialTime,
    this.initialRange,
    this.onDateChanged,
    this.onTimeChanged,
    this.onRangeChanged,
    this.onDateSelected,
    this.onTimeSelected,
    this.onRangeSelected,
    this.helperText,
    this.labelText,
    this.hintText,
    this.icon,
    bool enabled = true,
    this.readOnly = false,
    this.required = false,
    this.semanticLabel,
    this.semanticHint,
  }) : _enabled = enabled,
       super(
         builder: (FormFieldState<DateTime> state) {
           return CustomDatePicker(
             selectedDate: state.value,
             mode: mode,
             style: style,
             firstDate: firstDate,
             lastDate: lastDate,
             initialDate: initialDate,
             initialTime: initialTime,
             initialRange: initialRange,
             onDateChanged: (date) {
               state.didChange(date);
               onDateChanged?.call(date);
             },
             onTimeChanged: onTimeChanged,
             onRangeChanged: onRangeChanged,
             onDateSelected: onDateSelected,
             onTimeSelected: onTimeSelected,
             onRangeSelected: onRangeSelected,
             helperText: helperText,
             errorText: state.errorText,
             labelText: labelText,
             hintText: hintText,
             icon: icon,
             enabled: enabled,
             readOnly: readOnly,
             required: required,
             semanticLabel: semanticLabel,
             semanticHint: semanticHint,
           );
         },
       );
}

/// 날짜 선택기 유틸리티
class DatePickerUtils {
  /// 날짜 포맷팅
  static String formatDate(DateTime date, {String format = 'yyyy-MM-dd'}) {
    switch (format) {
      case 'yyyy-MM-dd':
        return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      case 'yyyy년 MM월 dd일':
        return '${date.year}년 ${date.month}월 ${date.day}일';
      case 'MM/dd/yyyy':
        return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
      case 'dd/MM/yyyy':
        return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      default:
        return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
  }

  /// 시간 포맷팅
  static String formatTime(TimeOfDay time, {bool use24Hour = true}) {
    if (use24Hour) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else {
      final hour = time.hour == 0
          ? 12
          : (time.hour > 12 ? time.hour - 12 : time.hour);
      final period = time.hour < 12 ? 'AM' : 'PM';
      return '${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period';
    }
  }

  /// 날짜 범위 포맷팅
  static String formatDateRange(
    DateTimeRange range, {
    String format = 'yyyy-MM-dd',
  }) {
    return '${formatDate(range.start, format: format)} - ${formatDate(range.end, format: format)}';
  }

  /// 날짜가 범위 내에 있는지 확인
  static bool isDateInRange(DateTime date, DateTime start, DateTime end) {
    return date.isAfter(start.subtract(const Duration(days: 1))) &&
        date.isBefore(end.add(const Duration(days: 1)));
  }

  /// 두 날짜 사이의 일수 계산
  static int daysBetween(DateTime start, DateTime end) {
    return end.difference(start).inDays;
  }

  /// 날짜에 일수 추가
  static DateTime addDays(DateTime date, int days) {
    return date.add(Duration(days: days));
  }

  /// 날짜에서 일수 빼기
  static DateTime subtractDays(DateTime date, int days) {
    return date.subtract(Duration(days: days));
  }

  /// 오늘 날짜 반환
  static DateTime today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// 내일 날짜 반환
  static DateTime tomorrow() {
    return addDays(today(), 1);
  }

  /// 어제 날짜 반환
  static DateTime yesterday() {
    return subtractDays(today(), 1);
  }

  /// 이번 주 시작일 반환 (월요일)
  static DateTime startOfWeek() {
    final today = DateTime.now();
    final weekday = today.weekday;
    return subtractDays(today, weekday - 1);
  }

  /// 이번 주 마지막일 반환 (일요일)
  static DateTime endOfWeek() {
    final today = DateTime.now();
    final weekday = today.weekday;
    return addDays(today, 7 - weekday);
  }

  /// 이번 달 시작일 반환
  static DateTime startOfMonth() {
    final today = DateTime.now();
    return DateTime(today.year, today.month, 1);
  }

  /// 이번 달 마지막일 반환
  static DateTime endOfMonth() {
    final today = DateTime.now();
    return DateTime(today.year, today.month + 1, 0);
  }
}
