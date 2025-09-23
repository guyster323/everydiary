import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../accessibility/accessibility_utils.dart';

/// 커스텀 앱바 위젯
/// 다양한 스타일과 기능을 지원하는 재사용 가능한 앱바입니다.
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.subtitle,
    this.leading,
    this.actions,
    this.flexibleSpace,
    this.bottom,
    this.elevation,
    this.shadowColor,
    this.surfaceTintColor,
    this.backgroundColor,
    this.foregroundColor,
    this.iconTheme,
    this.actionsIconTheme,
    this.titleTextStyle,
    this.toolbarTextStyle,
    this.centerTitle,
    this.titleSpacing,
    this.toolbarOpacity = 1.0,
    this.bottomOpacity = 1.0,
    this.automaticallyImplyLeading = true,
    this.primary = true,
    this.excludeHeaderSemantics = false,
    this.scrolledUnderElevation,
    this.scrollUnderElevation,
    this.notificationPredicate = defaultScrollNotificationPredicate,
    this.toolbarHeight,
    this.leadingWidth,
    this.systemOverlayStyle,
    this.scrollable = false,
    this.collapsible = false,
    this.pinned = false,
    this.floating = false,
    this.snap = false,
    this.expandedHeight,
    this.onExpandedChanged,
  });

  /// 제목 텍스트
  final String? title;

  /// 제목 위젯
  final Widget? titleWidget;

  /// 부제목
  final String? subtitle;

  /// 선행 위젯 (보통 뒤로가기 버튼)
  final Widget? leading;

  /// 액션 위젯들
  final List<Widget>? actions;

  /// 유연한 공간
  final Widget? flexibleSpace;

  /// 하단 위젯
  final PreferredSizeWidget? bottom;

  /// 그림자 높이
  final double? elevation;

  /// 그림자 색상
  final Color? shadowColor;

  /// 표면 틴트 색상
  final Color? surfaceTintColor;

  /// 배경색
  final Color? backgroundColor;

  /// 전경색
  final Color? foregroundColor;

  /// 아이콘 테마
  final IconThemeData? iconTheme;

  /// 액션 아이콘 테마
  final IconThemeData? actionsIconTheme;

  /// 제목 텍스트 스타일
  final TextStyle? titleTextStyle;

  /// 툴바 텍스트 스타일
  final TextStyle? toolbarTextStyle;

  /// 제목 중앙 정렬 여부
  final bool? centerTitle;

  /// 제목 간격
  final double? titleSpacing;

  /// 툴바 투명도
  final double toolbarOpacity;

  /// 하단 투명도
  final double bottomOpacity;

  /// 자동 선행 위젯 표시 여부
  final bool automaticallyImplyLeading;

  /// 기본 앱바 여부
  final bool primary;

  /// 헤더 시맨틱 제외 여부
  final bool excludeHeaderSemantics;

  /// 스크롤 시 그림자 높이
  final double? scrolledUnderElevation;

  /// 스크롤 시 그림자 높이 (deprecated)
  final double? scrollUnderElevation;

  /// 알림 조건
  final ScrollNotificationPredicate notificationPredicate;

  /// 툴바 높이
  final double? toolbarHeight;

  /// 선행 위젯 너비
  final double? leadingWidth;

  /// 시스템 오버레이 스타일
  final SystemUiOverlayStyle? systemOverlayStyle;

  /// 스크롤 가능 여부
  final bool scrollable;

  /// 접을 수 있는 여부
  final bool collapsible;

  /// 고정 여부
  final bool pinned;

  /// 떠있는 여부
  final bool floating;

  /// 스냅 여부
  final bool snap;

  /// 확장된 높이
  final double? expandedHeight;

  /// 확장 상태 변경 콜백
  final ValueChanged<bool>? onExpandedChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // 스크롤 가능한 앱바인 경우
    if (scrollable && collapsible) {
      return _buildSliverAppBar(context, theme, colorScheme);
    }

    // 일반 앱바
    return _buildAppBar(context, theme, colorScheme);
  }

  /// 일반 앱바 생성
  Widget _buildAppBar(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final appBar = AppBar(
      title: _buildTitle(),
      leading: leading,
      actions: actions,
      flexibleSpace: flexibleSpace,
      bottom: bottom,
      elevation: elevation,
      shadowColor: shadowColor,
      surfaceTintColor: surfaceTintColor,
      backgroundColor: backgroundColor ?? colorScheme.surface,
      foregroundColor: foregroundColor ?? colorScheme.onSurface,
      iconTheme: iconTheme,
      actionsIconTheme: actionsIconTheme,
      titleTextStyle: titleTextStyle,
      toolbarTextStyle: toolbarTextStyle,
      centerTitle: centerTitle,
      titleSpacing: titleSpacing,
      automaticallyImplyLeading: automaticallyImplyLeading,
      primary: primary,
      excludeHeaderSemantics: excludeHeaderSemantics,
      scrolledUnderElevation: scrolledUnderElevation ?? 0.0,
      toolbarHeight: toolbarHeight ?? kToolbarHeight,
      leadingWidth: leadingWidth,
      systemOverlayStyle: systemOverlayStyle,
    );

    // 접근성 적용
    return AccessibilityUtils.semanticHeading(
      label: title ?? '앱바',
      level: 1,
      child: appBar,
    );
  }

  /// 슬리버 앱바 생성
  Widget _buildSliverAppBar(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return SliverAppBar(
      title: _buildTitle(),
      leading: leading,
      actions: actions,
      flexibleSpace: flexibleSpace,
      bottom: bottom,
      elevation: elevation,
      shadowColor: shadowColor,
      surfaceTintColor: surfaceTintColor,
      backgroundColor: backgroundColor ?? colorScheme.surface,
      foregroundColor: foregroundColor ?? colorScheme.onSurface,
      iconTheme: iconTheme,
      actionsIconTheme: actionsIconTheme,
      titleTextStyle: titleTextStyle,
      toolbarTextStyle: toolbarTextStyle,
      centerTitle: centerTitle,
      titleSpacing: titleSpacing,
      automaticallyImplyLeading: automaticallyImplyLeading,
      primary: primary,
      excludeHeaderSemantics: excludeHeaderSemantics,
      toolbarHeight: toolbarHeight ?? kToolbarHeight,
      leadingWidth: leadingWidth,
      systemOverlayStyle: systemOverlayStyle,
      pinned: pinned,
      floating: floating,
      snap: snap,
      expandedHeight: expandedHeight,
    );
  }

  /// 제목 위젯 생성
  Widget? _buildTitle() {
    if (titleWidget != null) {
      return titleWidget;
    }

    if (title != null) {
      if (subtitle != null) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title!, style: titleTextStyle),
            Text(
              subtitle!,
              style: titleTextStyle?.copyWith(
                fontSize: (titleTextStyle?.fontSize ?? 20) * 0.8,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        );
      }

      return Text(title!, style: titleTextStyle);
    }

    return null;
  }

  @override
  Size get preferredSize {
    if (bottom != null) {
      return Size.fromHeight(
        (toolbarHeight ?? kToolbarHeight) + bottom!.preferredSize.height,
      );
    }
    return Size.fromHeight(toolbarHeight ?? kToolbarHeight);
  }
}

/// 편의 생성자들
extension CustomAppBarConvenience on CustomAppBar {
  /// 간단한 앱바
  static CustomAppBar simple({
    required String title,
    Widget? leading,
    List<Widget>? actions,
    VoidCallback? onBackPressed,
    Color? backgroundColor,
    Color? foregroundColor,
  }) {
    return CustomAppBar(
      title: title,
      leading:
          leading ??
          (onBackPressed != null
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: onBackPressed,
                )
              : null),
      actions: actions,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      centerTitle: true,
    );
  }

  /// 검색 앱바
  static CustomAppBar search({
    required String title,
    required TextEditingController searchController,
    ValueChanged<String>? onSearchChanged,
    VoidCallback? onSearchSubmitted,
    VoidCallback? onBackPressed,
    List<Widget>? actions,
    Color? backgroundColor,
    Color? foregroundColor,
  }) {
    return CustomAppBar(
      title: title,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: onBackPressed,
      ),
      actions: [
        SizedBox(
          width: 200,
          child: TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            onSubmitted: onSearchSubmitted != null
                ? (_) => onSearchSubmitted()
                : null,
            decoration: const InputDecoration(
              hintText: '검색...',
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 8),
            ),
          ),
        ),
        ...?actions,
      ],
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      centerTitle: false,
    );
  }

  /// 탭 앱바
  static CustomAppBar withTabs({
    required String title,
    required List<String> tabs,
    required int selectedIndex,
    required ValueChanged<int> onTabChanged,
    Widget? leading,
    List<Widget>? actions,
    Color? backgroundColor,
    Color? foregroundColor,
  }) {
    return CustomAppBar(
      title: title,
      leading: leading,
      actions: actions,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      centerTitle: true,
      bottom: TabBar(
        tabs: tabs.map((tab) => Tab(text: tab)).toList(),
        isScrollable: tabs.length > 3,
        onTap: onTabChanged,
      ),
    );
  }

  /// 확장 가능한 앱바
  static CustomAppBar expandable({
    required String title,
    required Widget expandedContent,
    Widget? leading,
    List<Widget>? actions,
    double? expandedHeight,
    bool pinned = true,
    bool floating = false,
    bool snap = false,
    Color? backgroundColor,
    Color? foregroundColor,
  }) {
    return CustomAppBar(
      title: title,
      leading: leading,
      actions: actions,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      centerTitle: true,
      scrollable: true,
      collapsible: true,
      pinned: pinned,
      floating: floating,
      snap: snap,
      expandedHeight: expandedHeight ?? 200,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(title),
        background: expandedContent,
      ),
    );
  }

  /// 투명한 앱바
  static CustomAppBar transparent({
    required String title,
    Widget? leading,
    List<Widget>? actions,
    VoidCallback? onBackPressed,
    Color? foregroundColor,
  }) {
    return CustomAppBar(
      title: title,
      leading:
          leading ??
          (onBackPressed != null
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: onBackPressed,
                )
              : null),
      actions: actions,
      backgroundColor: Colors.transparent,
      foregroundColor: foregroundColor,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
    );
  }
}
