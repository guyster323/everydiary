import 'package:flutter/material.dart';

import '../theme/theme_manager.dart' as theme_manager;

/// 테마 전환 위젯
/// 테마 모드를 변경할 수 있는 다양한 UI 컴포넌트들을 제공합니다.
class ThemeSwitchWidget extends StatelessWidget {
  /// 위젯 타입
  final ThemeSwitchType type;

  /// 테마 매니저
  final theme_manager.ThemeManager? themeManager;

  /// 크기
  final double? size;

  /// 색상
  final Color? color;

  /// 라벨 표시 여부
  final bool showLabel;

  /// 라벨 스타일
  final TextStyle? labelStyle;

  /// 아이콘 크기
  final double? iconSize;

  /// 애니메이션 지속 시간
  final Duration animationDuration;

  /// 애니메이션 고선
  final Curve animationCurve;

  const ThemeSwitchWidget({
    super.key,
    this.type = ThemeSwitchType.switchButton,
    this.themeManager,
    this.size,
    this.color,
    this.showLabel = false,
    this.labelStyle,
    this.iconSize,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
  });

  @override
  Widget build(BuildContext context) {
    final manager = themeManager ?? theme_manager.ThemeManager();

    return AnimatedBuilder(
      animation: manager,
      builder: (context, child) {
        switch (type) {
          case ThemeSwitchType.switchButton:
            return _buildSwitchButton(context, manager);
          case ThemeSwitchType.iconButton:
            return _buildIconButton(context, manager);
          case ThemeSwitchType.dropdown:
            return _buildDropdown(context, manager);
          case ThemeSwitchType.radioGroup:
            return _buildRadioGroup(context, manager);
          case ThemeSwitchType.segmentedControl:
            return _buildSegmentedControl(context, manager);
        }
      },
    );
  }

  /// 스위치 버튼 구성
  Widget _buildSwitchButton(
    BuildContext context,
    theme_manager.ThemeManager manager,
  ) {
    final isDark = manager.isDarkTheme(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLabel) ...[
          Text(
            '다크 모드',
            style: labelStyle ?? Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(width: 8),
        ],
        Switch(
          value: isDark,
          onChanged: (value) {
            if (value) {
              manager.setDarkMode();
            } else {
              manager.setLightMode();
            }
          },
          activeThumbColor: color,
        ),
      ],
    );
  }

  /// 아이콘 버튼 구성
  Widget _buildIconButton(
    BuildContext context,
    theme_manager.ThemeManager manager,
  ) {
    return IconButton(
      onPressed: () => manager.toggleTheme(),
      icon: AnimatedSwitcher(
        duration: animationDuration,
        transitionBuilder: (child, animation) {
          return RotationTransition(turns: animation, child: child);
        },
        child: Icon(
          manager.getThemeModeIcon(),
          key: ValueKey(manager.currentThemeMode),
          size: iconSize ?? size ?? 24,
          color: color,
        ),
      ),
      tooltip: manager.getThemeModeName(),
    );
  }

  /// 드롭다운 구성
  Widget _buildDropdown(
    BuildContext context,
    theme_manager.ThemeManager manager,
  ) {
    return DropdownButton<theme_manager.ThemeMode>(
      value: manager.currentThemeMode,
      onChanged: (theme_manager.ThemeMode? newValue) {
        if (newValue != null) {
          manager.setThemeMode(newValue);
        }
      },
      items: theme_manager.ThemeMode.values
          .map<DropdownMenuItem<theme_manager.ThemeMode>>((
            theme_manager.ThemeMode mode,
          ) {
            return DropdownMenuItem<theme_manager.ThemeMode>(
              value: mode,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getThemeModeIcon(mode),
                    size: iconSize ?? 20,
                    color: color,
                  ),
                  const SizedBox(width: 8),
                  Text(_getThemeModeName(mode)),
                ],
              ),
            );
          })
          .toList(),
    );
  }

  /// 라디오 그룹 구성
  Widget _buildRadioGroup(
    BuildContext context,
    theme_manager.ThemeManager manager,
  ) {
    final color = Theme.of(context).colorScheme.onSurface;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: theme_manager.ThemeMode.values.map((mode) {
        return RadioListTile<theme_manager.ThemeMode>(
          title: Text(_getThemeModeName(mode)),
          subtitle: Text(_getThemeModeDescription(mode)),
          value: mode,
          // ignore: deprecated_member_use
          groupValue: manager.currentThemeMode,
          // ignore: deprecated_member_use
          onChanged: (theme_manager.ThemeMode? value) {
            if (value != null) {
              manager.setThemeMode(value);
            }
          },
          secondary: Icon(_getThemeModeIcon(mode), color: color),
        );
      }).toList(),
    );
  }

  /// 세그먼트 컨트롤 구성
  Widget _buildSegmentedControl(
    BuildContext context,
    theme_manager.ThemeManager manager,
  ) {
    return SegmentedButton<theme_manager.ThemeMode>(
      segments: theme_manager.ThemeMode.values.map((mode) {
        return ButtonSegment<theme_manager.ThemeMode>(
          value: mode,
          label: Text(_getThemeModeName(mode)),
          icon: Icon(_getThemeModeIcon(mode)),
        );
      }).toList(),
      selected: {manager.currentThemeMode},
      onSelectionChanged: (Set<theme_manager.ThemeMode> selection) {
        if (selection.isNotEmpty) {
          manager.setThemeMode(selection.first);
        }
      },
    );
  }

  /// 테마 모드 아이콘 반환
  IconData _getThemeModeIcon(theme_manager.ThemeMode mode) {
    switch (mode) {
      case theme_manager.ThemeMode.light:
        return Icons.light_mode;
      case theme_manager.ThemeMode.dark:
        return Icons.dark_mode;
      case theme_manager.ThemeMode.system:
        return Icons.brightness_auto;
    }
  }

  /// 테마 모드 이름 반환
  String _getThemeModeName(theme_manager.ThemeMode mode) {
    switch (mode) {
      case theme_manager.ThemeMode.light:
        return '라이트';
      case theme_manager.ThemeMode.dark:
        return '다크';
      case theme_manager.ThemeMode.system:
        return '시스템';
    }
  }

  /// 테마 모드 설명 반환
  String _getThemeModeDescription(theme_manager.ThemeMode mode) {
    switch (mode) {
      case theme_manager.ThemeMode.light:
        return '밝은 테마 사용';
      case theme_manager.ThemeMode.dark:
        return '어두운 테마 사용';
      case theme_manager.ThemeMode.system:
        return '시스템 설정 따름';
    }
  }

  // === 편의 팩토리 메서드들 ===

  /// 스위치 버튼
  static Widget switchButton({
    theme_manager.ThemeManager? themeManager,
    bool showLabel = true,
    TextStyle? labelStyle,
    Color? color,
  }) {
    return ThemeSwitchWidget(
      type: ThemeSwitchType.switchButton,
      themeManager: themeManager,
      showLabel: showLabel,
      labelStyle: labelStyle,
      color: color,
    );
  }

  /// 아이콘 버튼
  static Widget iconButton({
    theme_manager.ThemeManager? themeManager,
    double? size,
    Color? color,
  }) {
    return ThemeSwitchWidget(
      type: ThemeSwitchType.iconButton,
      themeManager: themeManager,
      size: size,
      color: color,
    );
  }

  /// 드롭다운
  static Widget dropdown({
    theme_manager.ThemeManager? themeManager,
    double? iconSize,
    Color? color,
  }) {
    return ThemeSwitchWidget(
      type: ThemeSwitchType.dropdown,
      themeManager: themeManager,
      iconSize: iconSize,
      color: color,
    );
  }

  /// 라디오 그룹
  static Widget radioGroup({
    theme_manager.ThemeManager? themeManager,
    Color? color,
  }) {
    return ThemeSwitchWidget(
      type: ThemeSwitchType.radioGroup,
      themeManager: themeManager,
      color: color,
    );
  }

  /// 세그먼트 컨트롤
  static Widget segmentedControl({theme_manager.ThemeManager? themeManager}) {
    return ThemeSwitchWidget(
      type: ThemeSwitchType.segmentedControl,
      themeManager: themeManager,
    );
  }
}

/// 테마 전환 위젯 타입 열거형
enum ThemeSwitchType {
  switchButton,
  iconButton,
  dropdown,
  radioGroup,
  segmentedControl,
}

/// 테마 전환 플로팅 액션 버튼
class ThemeSwitchFAB extends StatelessWidget {
  /// 테마 매니저
  final theme_manager.ThemeManager? themeManager;

  /// 크기
  final double? size;

  /// 배경색
  final Color? backgroundColor;

  /// 전경색
  final Color? foregroundColor;

  /// 툴팁
  final String? tooltip;

  const ThemeSwitchFAB({
    super.key,
    this.themeManager,
    this.size,
    this.backgroundColor,
    this.foregroundColor,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final manager = themeManager ?? theme_manager.ThemeManager();

    return AnimatedBuilder(
      animation: manager,
      builder: (context, child) {
        return FloatingActionButton(
          onPressed: () => manager.toggleTheme(),
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          tooltip: tooltip ?? manager.getThemeModeName(),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return RotationTransition(turns: animation, child: child);
            },
            child: Icon(
              manager.getThemeModeIcon(),
              key: ValueKey(manager.currentThemeMode),
            ),
          ),
        );
      },
    );
  }
}

/// 테마 전환 앱바 액션
class ThemeSwitchAppBarAction extends StatelessWidget {
  /// 테마 매니저
  final theme_manager.ThemeManager? themeManager;

  /// 아이콘 크기
  final double? iconSize;

  /// 색상
  final Color? color;

  /// 툴팁
  final String? tooltip;

  const ThemeSwitchAppBarAction({
    super.key,
    this.themeManager,
    this.iconSize,
    this.color,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final manager = themeManager ?? theme_manager.ThemeManager();

    return AnimatedBuilder(
      animation: manager,
      builder: (context, child) {
        return IconButton(
          onPressed: () => manager.toggleTheme(),
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return RotationTransition(turns: animation, child: child);
            },
            child: Icon(
              manager.getThemeModeIcon(),
              key: ValueKey(manager.currentThemeMode),
              size: iconSize,
              color: color,
            ),
          ),
          tooltip: tooltip ?? manager.getThemeModeName(),
        );
      },
    );
  }
}
