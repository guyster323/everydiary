import 'package:flutter/material.dart';

/// 네비게이션 아이템 모델 클래스
class NavigationItem {
  /// 아이콘
  final IconData icon;

  /// 활성화된 아이콘 (선택사항)
  final IconData? activeIcon;

  /// 라벨
  final String label;

  /// 배지 텍스트 (선택사항)
  final String? badge;

  /// 배지 색상 (선택사항)
  final Color? badgeColor;

  /// 배지 배경색 (선택사항)
  final Color? badgeBackgroundColor;

  /// 툴팁 (선택사항)
  final String? tooltip;

  /// 접근성 라벨 (선택사항)
  final String? semanticLabel;

  /// 접근성 힌트 (선택사항)
  final String? semanticHint;

  /// 비활성화 여부
  final bool isDisabled;

  const NavigationItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    this.badge,
    this.badgeColor,
    this.badgeBackgroundColor,
    this.tooltip,
    this.semanticLabel,
    this.semanticHint,
    this.isDisabled = false,
  });

  /// 활성화된 아이콘 반환
  IconData get effectiveIcon => activeIcon ?? icon;
}

/// 네비게이션 타입 열거형
enum NavigationType { fixed, shifting, labeled, iconOnly }

/// 네비게이션 스타일 열거형
enum NavigationStyle { elevated, flat, outlined }

/// 커스텀 하단 네비게이션 바 컴포넌트
/// Material Design 3 기반으로 다양한 스타일과 기능을 지원하는 하단 네비게이션 바입니다.
class CustomBottomNavigation extends StatefulWidget {
  /// 네비게이션 아이템들
  final List<NavigationItem> items;

  /// 현재 선택된 인덱스
  final int currentIndex;

  /// 탭 선택 콜백
  final ValueChanged<int>? onTap;

  /// 네비게이션 타입
  final NavigationType type;

  /// 네비게이션 스타일
  final NavigationStyle style;

  /// 배경색
  final Color? backgroundColor;

  /// 선택된 아이템 색상
  final Color? selectedItemColor;

  /// 선택되지 않은 아이템 색상
  final Color? unselectedItemColor;

  /// 선택된 아이템 배경색
  final Color? selectedItemBackgroundColor;

  /// 선택되지 않은 아이템 배경색
  final Color? unselectedItemBackgroundColor;

  /// 아이콘 크기
  final double iconSize;

  /// 라벨 폰트 크기
  final double labelFontSize;

  /// 선택된 라벨 폰트 크기
  final double selectedLabelFontSize;

  /// 선택되지 않은 라벨 폰트 크기
  final double unselectedLabelFontSize;

  /// 애니메이션 지속 시간
  final Duration animationDuration;

  /// 애니메이션 곡선
  final Curve animationCurve;

  /// 그림자 여부
  final bool showShadow;

  /// 그림자 색상
  final Color? shadowColor;

  /// 그림자 높이
  final double elevation;

  /// 상단 테두리 여부
  final bool showTopBorder;

  /// 상단 테두리 색상
  final Color? topBorderColor;

  /// 상단 테두리 두께
  final double topBorderWidth;

  /// 접근성 라벨
  final String? semanticLabel;

  /// 접근성 힌트
  final String? semanticHint;

  const CustomBottomNavigation({
    super.key,
    required this.items,
    required this.currentIndex,
    this.onTap,
    this.type = NavigationType.fixed,
    this.style = NavigationStyle.elevated,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.selectedItemBackgroundColor,
    this.unselectedItemBackgroundColor,
    this.iconSize = 24.0,
    this.labelFontSize = 12.0,
    this.selectedLabelFontSize = 12.0,
    this.unselectedLabelFontSize = 12.0,
    this.animationDuration = const Duration(milliseconds: 200),
    this.animationCurve = Curves.easeInOut,
    this.showShadow = true,
    this.shadowColor,
    this.elevation = 8.0,
    this.showTopBorder = false,
    this.topBorderColor,
    this.topBorderWidth = 1.0,
    this.semanticLabel,
    this.semanticHint,
  }) : assert(items.length >= 2, '최소 2개의 아이템이 필요합니다.'),
       assert(items.length <= 5, '최대 5개의 아이템만 지원됩니다.'),
       assert(
         currentIndex >= 0 && currentIndex < items.length,
         'currentIndex가 유효하지 않습니다.',
       );

  @override
  State<CustomBottomNavigation> createState() => _CustomBottomNavigationState();
}

class _CustomBottomNavigationState extends State<CustomBottomNavigation>
    with TickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // 색상 결정
    final effectiveBackgroundColor = _getBackgroundColor(colorScheme);
    final effectiveSelectedItemColor = _getSelectedItemColor(colorScheme);
    final effectiveUnselectedItemColor = _getUnselectedItemColor(colorScheme);
    final effectiveShadowColor = _getShadowColor(colorScheme);

    // 네비게이션 바 위젯 구성
    Widget navigationWidget = _buildNavigationBar(
      context: context,
      theme: theme,
      colorScheme: colorScheme,
      backgroundColor: effectiveBackgroundColor,
      selectedItemColor: effectiveSelectedItemColor,
      unselectedItemColor: effectiveUnselectedItemColor,
      shadowColor: effectiveShadowColor,
    );

    // 접근성 래핑
    if (widget.semanticLabel != null || widget.semanticHint != null) {
      navigationWidget = Semantics(
        label: widget.semanticLabel,
        hint: widget.semanticHint,
        child: navigationWidget,
      );
    }

    return navigationWidget;
  }

  /// 네비게이션 바 위젯 구성
  Widget _buildNavigationBar({
    required BuildContext context,
    required ThemeData theme,
    required ColorScheme colorScheme,
    required Color backgroundColor,
    required Color selectedItemColor,
    required Color unselectedItemColor,
    required Color shadowColor,
  }) {
    switch (widget.type) {
      case NavigationType.fixed:
        return _buildFixedNavigationBar(
          context: context,
          theme: theme,
          colorScheme: colorScheme,
          backgroundColor: backgroundColor,
          selectedItemColor: selectedItemColor,
          unselectedItemColor: unselectedItemColor,
          shadowColor: shadowColor,
        );

      case NavigationType.shifting:
        return _buildShiftingNavigationBar(
          context: context,
          theme: theme,
          colorScheme: colorScheme,
          backgroundColor: backgroundColor,
          selectedItemColor: selectedItemColor,
          unselectedItemColor: unselectedItemColor,
          shadowColor: shadowColor,
        );

      case NavigationType.labeled:
        return _buildLabeledNavigationBar(
          context: context,
          theme: theme,
          colorScheme: colorScheme,
          backgroundColor: backgroundColor,
          selectedItemColor: selectedItemColor,
          unselectedItemColor: unselectedItemColor,
          shadowColor: shadowColor,
        );

      case NavigationType.iconOnly:
        return _buildIconOnlyNavigationBar(
          context: context,
          theme: theme,
          colorScheme: colorScheme,
          backgroundColor: backgroundColor,
          selectedItemColor: selectedItemColor,
          unselectedItemColor: unselectedItemColor,
          shadowColor: shadowColor,
        );
    }
  }

  /// 고정 네비게이션 바 구성
  Widget _buildFixedNavigationBar({
    required BuildContext context,
    required ThemeData theme,
    required ColorScheme colorScheme,
    required Color backgroundColor,
    required Color selectedItemColor,
    required Color unselectedItemColor,
    required Color shadowColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: widget.showShadow
            ? [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: widget.elevation,
                  offset: Offset(0, -widget.elevation / 2),
                ),
              ]
            : null,
        border: widget.showTopBorder
            ? Border(
                top: BorderSide(
                  color: widget.topBorderColor ?? colorScheme.outline,
                  width: widget.topBorderWidth,
                ),
              )
            : null,
      ),
      child: SafeArea(
        child: Container(
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _buildNavigationItems(
              selectedItemColor: selectedItemColor,
              unselectedItemColor: unselectedItemColor,
            ),
          ),
        ),
      ),
    );
  }

  /// 시프팅 네비게이션 바 구성
  Widget _buildShiftingNavigationBar({
    required BuildContext context,
    required ThemeData theme,
    required ColorScheme colorScheme,
    required Color backgroundColor,
    required Color selectedItemColor,
    required Color unselectedItemColor,
    required Color shadowColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: widget.showShadow
            ? [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: widget.elevation,
                  offset: Offset(0, -widget.elevation / 2),
                ),
              ]
            : null,
        border: widget.showTopBorder
            ? Border(
                top: BorderSide(
                  color: widget.topBorderColor ?? colorScheme.outline,
                  width: widget.topBorderWidth,
                ),
              )
            : null,
      ),
      child: SafeArea(
        child: Container(
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _buildShiftingNavigationItems(
              selectedItemColor: selectedItemColor,
              unselectedItemColor: unselectedItemColor,
            ),
          ),
        ),
      ),
    );
  }

  /// 라벨드 네비게이션 바 구성
  Widget _buildLabeledNavigationBar({
    required BuildContext context,
    required ThemeData theme,
    required ColorScheme colorScheme,
    required Color backgroundColor,
    required Color selectedItemColor,
    required Color unselectedItemColor,
    required Color shadowColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: widget.showShadow
            ? [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: widget.elevation,
                  offset: Offset(0, -widget.elevation / 2),
                ),
              ]
            : null,
        border: widget.showTopBorder
            ? Border(
                top: BorderSide(
                  color: widget.topBorderColor ?? colorScheme.outline,
                  width: widget.topBorderWidth,
                ),
              )
            : null,
      ),
      child: SafeArea(
        child: Container(
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _buildNavigationItems(
              selectedItemColor: selectedItemColor,
              unselectedItemColor: unselectedItemColor,
              showLabels: true,
            ),
          ),
        ),
      ),
    );
  }

  /// 아이콘만 네비게이션 바 구성
  Widget _buildIconOnlyNavigationBar({
    required BuildContext context,
    required ThemeData theme,
    required ColorScheme colorScheme,
    required Color backgroundColor,
    required Color selectedItemColor,
    required Color unselectedItemColor,
    required Color shadowColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        boxShadow: widget.showShadow
            ? [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: widget.elevation,
                  offset: Offset(0, -widget.elevation / 2),
                ),
              ]
            : null,
        border: widget.showTopBorder
            ? Border(
                top: BorderSide(
                  color: widget.topBorderColor ?? colorScheme.outline,
                  width: widget.topBorderWidth,
                ),
              )
            : null,
      ),
      child: SafeArea(
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _buildNavigationItems(
              selectedItemColor: selectedItemColor,
              unselectedItemColor: unselectedItemColor,
              showLabels: false,
            ),
          ),
        ),
      ),
    );
  }

  /// 네비게이션 아이템들 구성
  List<Widget> _buildNavigationItems({
    required Color selectedItemColor,
    required Color unselectedItemColor,
    bool showLabels = true,
  }) {
    return widget.items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final isSelected = index == widget.currentIndex;

      return _buildNavigationItem(
        item: item,
        index: index,
        isSelected: isSelected,
        selectedItemColor: selectedItemColor,
        unselectedItemColor: unselectedItemColor,
        showLabels: showLabels,
      );
    }).toList();
  }

  /// 시프팅 네비게이션 아이템들 구성
  List<Widget> _buildShiftingNavigationItems({
    required Color selectedItemColor,
    required Color unselectedItemColor,
  }) {
    return widget.items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final isSelected = index == widget.currentIndex;

      return _buildShiftingNavigationItem(
        item: item,
        index: index,
        isSelected: isSelected,
        selectedItemColor: selectedItemColor,
        unselectedItemColor: unselectedItemColor,
      );
    }).toList();
  }

  /// 네비게이션 아이템 구성
  Widget _buildNavigationItem({
    required NavigationItem item,
    required int index,
    required bool isSelected,
    required Color selectedItemColor,
    required Color unselectedItemColor,
    required bool showLabels,
  }) {
    final color = isSelected ? selectedItemColor : unselectedItemColor;
    final fontSize = isSelected
        ? widget.selectedLabelFontSize
        : widget.unselectedLabelFontSize;

    Widget itemWidget = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 아이콘과 배지
        Stack(
          children: [
            AnimatedContainer(
              duration: widget.animationDuration,
              curve: widget.animationCurve,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? (widget.selectedItemBackgroundColor ??
                          selectedItemColor.withValues(alpha: 0.1))
                    : (widget.unselectedItemBackgroundColor ??
                          Colors.transparent),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isSelected ? item.effectiveIcon : item.icon,
                size: widget.iconSize,
                color: item.isDisabled ? color.withValues(alpha: 0.38) : color,
              ),
            ),
            // 배지
            if (item.badge != null && item.badge!.isNotEmpty)
              Positioned(right: 0, top: 0, child: _buildBadge(item)),
          ],
        ),
        // 라벨
        if (showLabels) ...[
          const SizedBox(height: 4),
          AnimatedDefaultTextStyle(
            duration: widget.animationDuration,
            curve: widget.animationCurve,
            style: TextStyle(
              color: item.isDisabled ? color.withValues(alpha: 0.38) : color,
              fontSize: fontSize,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
            child: Text(item.label),
          ),
        ],
      ],
    );

    // 툴팁 래핑
    if (item.tooltip != null) {
      itemWidget = Tooltip(message: item.tooltip!, child: itemWidget);
    }

    // 접근성 래핑
    if (item.semanticLabel != null || item.semanticHint != null) {
      itemWidget = Semantics(
        label: item.semanticLabel ?? item.label,
        hint: item.semanticHint,
        button: true,
        selected: isSelected,
        enabled: !item.isDisabled,
        child: itemWidget,
      );
    }

    // 탭 제스처 래핑
    return Expanded(
      child: GestureDetector(
        onTap: item.isDisabled ? null : () => widget.onTap?.call(index),
        child: itemWidget,
      ),
    );
  }

  /// 시프팅 네비게이션 아이템 구성
  Widget _buildShiftingNavigationItem({
    required NavigationItem item,
    required int index,
    required bool isSelected,
    required Color selectedItemColor,
    required Color unselectedItemColor,
  }) {
    final color = isSelected ? selectedItemColor : unselectedItemColor;

    Widget itemWidget = AnimatedContainer(
      duration: widget.animationDuration,
      curve: widget.animationCurve,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? (widget.selectedItemBackgroundColor ?? selectedItemColor)
            : (widget.unselectedItemBackgroundColor ?? Colors.transparent),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 아이콘과 배지
          Stack(
            children: [
              Icon(
                isSelected ? item.effectiveIcon : item.icon,
                size: widget.iconSize,
                color: item.isDisabled
                    ? (isSelected
                          ? Colors.white.withValues(alpha: 0.7)
                          : color.withValues(alpha: 0.38))
                    : (isSelected ? Colors.white : color),
              ),
              // 배지
              if (item.badge != null && item.badge!.isNotEmpty)
                Positioned(
                  right: -8,
                  top: -8,
                  child: _buildBadge(item, isWhite: isSelected),
                ),
            ],
          ),
          // 라벨
          if (isSelected) ...[
            const SizedBox(width: 8),
            AnimatedDefaultTextStyle(
              duration: widget.animationDuration,
              curve: widget.animationCurve,
              style: TextStyle(
                color: item.isDisabled
                    ? Colors.white.withValues(alpha: 0.7)
                    : Colors.white,
                fontSize: widget.selectedLabelFontSize,
                fontWeight: FontWeight.w600,
              ),
              child: Text(item.label),
            ),
          ],
        ],
      ),
    );

    // 툴팁 래핑
    if (item.tooltip != null) {
      itemWidget = Tooltip(message: item.tooltip!, child: itemWidget);
    }

    // 접근성 래핑
    if (item.semanticLabel != null || item.semanticHint != null) {
      itemWidget = Semantics(
        label: item.semanticLabel ?? item.label,
        hint: item.semanticHint,
        button: true,
        selected: isSelected,
        enabled: !item.isDisabled,
        child: itemWidget,
      );
    }

    // 탭 제스처 래핑
    return Expanded(
      child: GestureDetector(
        onTap: item.isDisabled ? null : () => widget.onTap?.call(index),
        child: itemWidget,
      ),
    );
  }

  /// 배지 구성
  Widget _buildBadge(NavigationItem item, {bool isWhite = false}) {
    final badgeColor = item.badgeColor ?? (isWhite ? Colors.white : Colors.red);
    final badgeBackgroundColor =
        item.badgeBackgroundColor ?? (isWhite ? Colors.red : Colors.white);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: badgeBackgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: isWhite ? Border.all(color: Colors.red, width: 1) : null,
      ),
      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
      child: Text(
        item.badge!,
        style: TextStyle(
          color: badgeColor,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// 배경색 결정
  Color _getBackgroundColor(ColorScheme colorScheme) {
    if (widget.backgroundColor != null) return widget.backgroundColor!;
    return colorScheme.surface;
  }

  /// 선택된 아이템 색상 결정
  Color _getSelectedItemColor(ColorScheme colorScheme) {
    if (widget.selectedItemColor != null) return widget.selectedItemColor!;
    return colorScheme.primary;
  }

  /// 선택되지 않은 아이템 색상 결정
  Color _getUnselectedItemColor(ColorScheme colorScheme) {
    if (widget.unselectedItemColor != null) return widget.unselectedItemColor!;
    return colorScheme.onSurface.withValues(alpha: 0.6);
  }

  /// 그림자 색상 결정
  Color _getShadowColor(ColorScheme colorScheme) {
    if (widget.shadowColor != null) return widget.shadowColor!;
    return Colors.black.withValues(alpha: 0.1);
  }

  // === 편의 팩토리 메서드들 ===
  // 주석 처리: 현재 사용되지 않는 convenience factory 메서드들

  /* /// 기본 네비게이션 바
  static Widget basic({
    required List<NavigationItem> items,
    required int currentIndex,
    ValueChanged<int>? onTap,
    Color? backgroundColor,
    Color? selectedItemColor,
    Color? unselectedItemColor,
    String? semanticLabel,
  }) {
    return CustomBottomNavigation(
      items: items,
      currentIndex: currentIndex,
      onTap: onTap,
      type: NavigationType.fixed,
      backgroundColor: backgroundColor,
      selectedItemColor: selectedItemColor,
      unselectedItemColor: unselectedItemColor,
      semanticLabel: semanticLabel,
    );
  }

  /// 시프팅 네비게이션 바
  static Widget shifting({
    required List<NavigationItem> items,
    required int currentIndex,
    ValueChanged<int>? onTap,
    Color? backgroundColor,
    Color? selectedItemColor,
    Color? unselectedItemColor,
    String? semanticLabel,
  }) {
    return CustomBottomNavigation(
      items: items,
      currentIndex: currentIndex,
      onTap: onTap,
      type: NavigationType.shifting,
      backgroundColor: backgroundColor,
      selectedItemColor: selectedItemColor,
      unselectedItemColor: unselectedItemColor,
      semanticLabel: semanticLabel,
    );
  }

  /// 라벨드 네비게이션 바
  static Widget labeled({
    required List<NavigationItem> items,
    required int currentIndex,
    ValueChanged<int>? onTap,
    Color? backgroundColor,
    Color? selectedItemColor,
    Color? unselectedItemColor,
    String? semanticLabel,
  }) {
    return CustomBottomNavigation(
      items: items,
      currentIndex: currentIndex,
      onTap: onTap,
      type: NavigationType.labeled,
      backgroundColor: backgroundColor,
      selectedItemColor: selectedItemColor,
      unselectedItemColor: unselectedItemColor,
      semanticLabel: semanticLabel,
    );
  }

  /// 아이콘만 네비게이션 바
  static Widget iconOnly({
    required List<NavigationItem> items,
    required int currentIndex,
    ValueChanged<int>? onTap,
    Color? backgroundColor,
    Color? selectedItemColor,
    Color? unselectedItemColor,
    String? semanticLabel,
  }) {
    return CustomBottomNavigation(
      items: items,
      currentIndex: currentIndex,
      onTap: onTap,
      type: NavigationType.iconOnly,
      backgroundColor: backgroundColor,
      selectedItemColor: selectedItemColor,
      unselectedItemColor: unselectedItemColor,
      semanticLabel: semanticLabel,
    );
  }

  /// 일기 앱용 네비게이션 바
  static Widget diary({
    required int currentIndex,
    ValueChanged<int>? onTap,
    String? homeBadge,
    String? diaryBadge,
    String? statisticsBadge,
    String? settingsBadge,
    Color? backgroundColor,
    Color? selectedItemColor,
    Color? unselectedItemColor,
  }) {
    return CustomBottomNavigation(
      items: [
        NavigationItem(
          icon: Icons.home_outlined,
          activeIcon: Icons.home,
          label: '홈',
          badge: homeBadge,
          semanticLabel: '홈 화면',
        ),
        NavigationItem(
          icon: Icons.book_outlined,
          activeIcon: Icons.book,
          label: '일기',
          badge: diaryBadge,
          semanticLabel: '일기 목록',
        ),
        NavigationItem(
          icon: Icons.analytics_outlined,
          activeIcon: Icons.analytics,
          label: '통계',
          badge: statisticsBadge,
          semanticLabel: '통계 화면',
        ),
        NavigationItem(
          icon: Icons.settings_outlined,
          activeIcon: Icons.settings,
          label: '설정',
          badge: settingsBadge,
          semanticLabel: '설정 화면',
        ),
      ],
      currentIndex: currentIndex,
      onTap: onTap,
      type: NavigationType.fixed,
      backgroundColor: backgroundColor,
      selectedItemColor: selectedItemColor,
      unselectedItemColor: unselectedItemColor,
      semanticLabel: '메인 네비게이션',
    );
  }

  /// 소셜 앱용 네비게이션 바
  static Widget social({
    required int currentIndex,
    ValueChanged<int>? onTap,
    String? feedBadge,
    String? messagesBadge,
    String? notificationsBadge,
    String? profileBadge,
    Color? backgroundColor,
    Color? selectedItemColor,
    Color? unselectedItemColor,
  }) {
    return CustomBottomNavigation(
      items: [
        NavigationItem(
          icon: Icons.home_outlined,
          activeIcon: Icons.home,
          label: '피드',
          badge: feedBadge,
          semanticLabel: '피드 화면',
        ),
        NavigationItem(
          icon: Icons.chat_outlined,
          activeIcon: Icons.chat,
          label: '메시지',
          badge: messagesBadge,
          semanticLabel: '메시지 화면',
        ),
        NavigationItem(
          icon: Icons.notifications_outlined,
          activeIcon: Icons.notifications,
          label: '알림',
          badge: notificationsBadge,
          semanticLabel: '알림 화면',
        ),
        NavigationItem(
          icon: Icons.person_outline,
          activeIcon: Icons.person,
          label: '프로필',
          badge: profileBadge,
          semanticLabel: '프로필 화면',
        ),
      ],
      currentIndex: currentIndex,
      onTap: onTap,
      type: NavigationType.fixed,
      backgroundColor: backgroundColor,
      selectedItemColor: selectedItemColor,
      unselectedItemColor: unselectedItemColor,
      semanticLabel: '소셜 네비게이션',
    );
  }

  /// 쇼핑 앱용 네비게이션 바
  static Widget shopping({
    required int currentIndex,
    ValueChanged<int>? onTap,
    String? homeBadge,
    String? searchBadge,
    String? cartBadge,
    String? wishlistBadge,
    String? profileBadge,
    Color? backgroundColor,
    Color? selectedItemColor,
    Color? unselectedItemColor,
  }) {
    return CustomBottomNavigation(
      items: [
        NavigationItem(
          icon: Icons.home_outlined,
          activeIcon: Icons.home,
          label: '홈',
          badge: homeBadge,
          semanticLabel: '홈 화면',
        ),
        NavigationItem(
          icon: Icons.search_outlined,
          activeIcon: Icons.search,
          label: '검색',
          badge: searchBadge,
          semanticLabel: '검색 화면',
        ),
        NavigationItem(
          icon: Icons.shopping_cart_outlined,
          activeIcon: Icons.shopping_cart,
          label: '장바구니',
          badge: cartBadge,
          semanticLabel: '장바구니 화면',
        ),
        NavigationItem(
          icon: Icons.favorite_outline,
          activeIcon: Icons.favorite,
          label: '위시리스트',
          badge: wishlistBadge,
          semanticLabel: '위시리스트 화면',
        ),
        NavigationItem(
          icon: Icons.person_outline,
          activeIcon: Icons.person,
          label: '프로필',
          badge: profileBadge,
          semanticLabel: '프로필 화면',
        ),
      ],
      currentIndex: currentIndex,
      onTap: onTap,
      type: NavigationType.fixed,
      backgroundColor: backgroundColor,
      selectedItemColor: selectedItemColor,
      unselectedItemColor: unselectedItemColor,
      semanticLabel: '쇼핑 네비게이션',
    );
  }

  /// 미디어 앱용 네비게이션 바
  static Widget media({
    required int currentIndex,
    ValueChanged<int>? onTap,
    String? homeBadge,
    String? libraryBadge,
    String? searchBadge,
    String? downloadsBadge,
    Color? backgroundColor,
    Color? selectedItemColor,
    Color? unselectedItemColor,
  }) {
    return CustomBottomNavigation(
      items: [
        NavigationItem(
          icon: Icons.home_outlined,
          activeIcon: Icons.home,
          label: '홈',
          badge: homeBadge,
          semanticLabel: '홈 화면',
        ),
        NavigationItem(
          icon: Icons.library_music_outlined,
          activeIcon: Icons.library_music,
          label: '라이브러리',
          badge: libraryBadge,
          semanticLabel: '라이브러리 화면',
        ),
        NavigationItem(
          icon: Icons.search_outlined,
          activeIcon: Icons.search,
          label: '검색',
          badge: searchBadge,
          semanticLabel: '검색 화면',
        ),
        NavigationItem(
          icon: Icons.download_outlined,
          activeIcon: Icons.download,
          label: '다운로드',
          badge: downloadsBadge,
          semanticLabel: '다운로드 화면',
        ),
      ],
      currentIndex: currentIndex,
      onTap: onTap,
      type: NavigationType.fixed,
      backgroundColor: backgroundColor,
      selectedItemColor: selectedItemColor,
      unselectedItemColor: unselectedItemColor,
      semanticLabel: '미디어 네비게이션',
    );
  }
  */
}
