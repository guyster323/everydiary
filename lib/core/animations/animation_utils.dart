import 'package:flutter/material.dart';

/// 애니메이션 유틸리티 클래스
/// 공통적으로 사용되는 애니메이션 설정과 헬퍼 함수들을 제공합니다.
class AnimationUtils {
  /// 기본 애니메이션 지속 시간
  static const Duration defaultDuration = Duration(milliseconds: 300);

  /// 빠른 애니메이션 지속 시간
  static const Duration fastDuration = Duration(milliseconds: 150);

  /// 느린 애니메이션 지속 시간
  static const Duration slowDuration = Duration(milliseconds: 500);

  /// 매우 느린 애니메이션 지속 시간
  static const Duration verySlowDuration = Duration(milliseconds: 800);

  /// 기본 커브
  static const Curve defaultCurve = Curves.easeInOut;

  /// 빠른 커브
  static const Curve fastCurve = Curves.easeOut;

  /// 느린 커브
  static const Curve slowCurve = Curves.easeIn;

  /// 바운스 커브
  static const Curve bounceCurve = Curves.elasticOut;

  /// 스프링 커브
  static const Curve springCurve = Curves.elasticInOut;

  /// 페이드 인 애니메이션
  static Widget fadeIn({
    required Widget child,
    Duration duration = defaultDuration,
    Curve curve = defaultCurve,
    Duration? delay,
  }) {
    return _DelayedAnimation(
      delay: delay,
      child: TweenAnimationBuilder<double>(
        duration: duration,
        curve: curve,
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Opacity(opacity: value, child: child);
        },
        child: child,
      ),
    );
  }

  /// 페이드 아웃 애니메이션
  static Widget fadeOut({
    required Widget child,
    Duration duration = defaultDuration,
    Curve curve = defaultCurve,
    Duration? delay,
  }) {
    return _DelayedAnimation(
      delay: delay,
      child: TweenAnimationBuilder<double>(
        duration: duration,
        curve: curve,
        tween: Tween(begin: 1.0, end: 0.0),
        builder: (context, value, child) {
          return Opacity(opacity: value, child: child);
        },
        child: child,
      ),
    );
  }

  /// 슬라이드 인 애니메이션 (위에서 아래로)
  static Widget slideInFromTop({
    required Widget child,
    Duration duration = defaultDuration,
    Curve curve = defaultCurve,
    Duration? delay,
    double offset = 50.0,
  }) {
    return _DelayedAnimation(
      delay: delay,
      child: TweenAnimationBuilder<Offset>(
        duration: duration,
        curve: curve,
        tween: Tween(begin: Offset(0, -offset), end: Offset.zero),
        builder: (context, value, child) {
          return Transform.translate(offset: value, child: child);
        },
        child: child,
      ),
    );
  }

  /// 슬라이드 인 애니메이션 (아래에서 위로)
  static Widget slideInFromBottom({
    required Widget child,
    Duration duration = defaultDuration,
    Curve curve = defaultCurve,
    Duration? delay,
    double offset = 50.0,
  }) {
    return _DelayedAnimation(
      delay: delay,
      child: TweenAnimationBuilder<Offset>(
        duration: duration,
        curve: curve,
        tween: Tween(begin: Offset(0, offset), end: Offset.zero),
        builder: (context, value, child) {
          return Transform.translate(offset: value, child: child);
        },
        child: child,
      ),
    );
  }

  /// 슬라이드 인 애니메이션 (왼쪽에서 오른쪽으로)
  static Widget slideInFromLeft({
    required Widget child,
    Duration duration = defaultDuration,
    Curve curve = defaultCurve,
    Duration? delay,
    double offset = 50.0,
  }) {
    return _DelayedAnimation(
      delay: delay,
      child: TweenAnimationBuilder<Offset>(
        duration: duration,
        curve: curve,
        tween: Tween(begin: Offset(-offset, 0), end: Offset.zero),
        builder: (context, value, child) {
          return Transform.translate(offset: value, child: child);
        },
        child: child,
      ),
    );
  }

  /// 슬라이드 인 애니메이션 (오른쪽에서 왼쪽으로)
  static Widget slideInFromRight({
    required Widget child,
    Duration duration = defaultDuration,
    Curve curve = defaultCurve,
    Duration? delay,
    double offset = 50.0,
  }) {
    return _DelayedAnimation(
      delay: delay,
      child: TweenAnimationBuilder<Offset>(
        duration: duration,
        curve: curve,
        tween: Tween(begin: Offset(offset, 0), end: Offset.zero),
        builder: (context, value, child) {
          return Transform.translate(offset: value, child: child);
        },
        child: child,
      ),
    );
  }

  /// 스케일 애니메이션
  static Widget scaleIn({
    required Widget child,
    Duration duration = defaultDuration,
    Curve curve = defaultCurve,
    Duration? delay,
    double beginScale = 0.0,
    double endScale = 1.0,
  }) {
    return _DelayedAnimation(
      delay: delay,
      child: TweenAnimationBuilder<double>(
        duration: duration,
        curve: curve,
        tween: Tween(begin: beginScale, end: endScale),
        builder: (context, value, child) {
          return Transform.scale(scale: value, child: child);
        },
        child: child,
      ),
    );
  }

  /// 회전 애니메이션
  static Widget rotateIn({
    required Widget child,
    Duration duration = defaultDuration,
    Curve curve = defaultCurve,
    Duration? delay,
    double beginAngle = -0.5,
    double endAngle = 0.0,
  }) {
    return _DelayedAnimation(
      delay: delay,
      child: TweenAnimationBuilder<double>(
        duration: duration,
        curve: curve,
        tween: Tween(begin: beginAngle, end: endAngle),
        builder: (context, value, child) {
          return Transform.rotate(
            angle: value * 2 * 3.14159, // 라디안으로 변환
            child: child,
          );
        },
        child: child,
      ),
    );
  }

  /// 복합 애니메이션 (페이드 + 슬라이드)
  static Widget fadeSlideIn({
    required Widget child,
    Duration duration = defaultDuration,
    Curve curve = defaultCurve,
    Duration? delay,
    Offset slideOffset = const Offset(0, 30),
  }) {
    return _DelayedAnimation(
      delay: delay,
      child: TweenAnimationBuilder<Map<String, double>>(
        duration: duration,
        curve: curve,
        tween: Tween(
          begin: {'opacity': 0.0, 'x': slideOffset.dx, 'y': slideOffset.dy},
          end: {'opacity': 1.0, 'x': 0.0, 'y': 0.0},
        ),
        builder: (context, value, child) {
          return Opacity(
            opacity: value['opacity']!,
            child: Transform.translate(
              offset: Offset(value['x']!, value['y']!),
              child: child,
            ),
          );
        },
        child: child,
      ),
    );
  }

  /// 바운스 애니메이션
  static Widget bounceIn({
    required Widget child,
    Duration duration = slowDuration,
    Curve curve = bounceCurve,
    Duration? delay,
  }) {
    return _DelayedAnimation(
      delay: delay,
      child: TweenAnimationBuilder<double>(
        duration: duration,
        curve: curve,
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Transform.scale(scale: value, child: child);
        },
        child: child,
      ),
    );
  }

  /// 펄스 애니메이션
  static Widget pulse({
    required Widget child,
    Duration duration = const Duration(milliseconds: 1000),
    Duration? delay,
  }) {
    return _DelayedAnimation(
      delay: delay,
      child: TweenAnimationBuilder<double>(
        duration: duration,
        tween: Tween(begin: 1.0, end: 1.1),
        builder: (context, value, child) {
          return Transform.scale(scale: value, child: child);
        },
        child: child,
      ),
    );
  }

  /// 페이지 전환 애니메이션 (슬라이드)
  static PageRouteBuilder<T> slidePageRoute<T>({
    required Widget page,
    Duration duration = defaultDuration,
    Curve curve = defaultCurve,
    Offset beginOffset = const Offset(1.0, 0.0),
    Offset endOffset = Offset.zero,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final slideAnimation = Tween<Offset>(
          begin: beginOffset,
          end: endOffset,
        ).animate(CurvedAnimation(parent: animation, curve: curve));

        return SlideTransition(position: slideAnimation, child: child);
      },
    );
  }

  /// 페이지 전환 애니메이션 (페이드)
  static PageRouteBuilder<T> fadePageRoute<T>({
    required Widget page,
    Duration duration = defaultDuration,
    Curve curve = defaultCurve,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(parent: animation, curve: curve));

        return FadeTransition(opacity: fadeAnimation, child: child);
      },
    );
  }

  /// 페이지 전환 애니메이션 (스케일)
  static PageRouteBuilder<T> scalePageRoute<T>({
    required Widget page,
    Duration duration = defaultDuration,
    Curve curve = defaultCurve,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final scaleAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(parent: animation, curve: curve));

        return ScaleTransition(scale: scaleAnimation, child: child);
      },
    );
  }
}

/// 지연된 애니메이션을 위한 헬퍼 위젯
class _DelayedAnimation extends StatefulWidget {
  const _DelayedAnimation({required this.child, this.delay});

  final Widget child;
  final Duration? delay;

  @override
  State<_DelayedAnimation> createState() => _DelayedAnimationState();
}

class _DelayedAnimationState extends State<_DelayedAnimation> {
  bool _show = false;

  @override
  void initState() {
    super.initState();
    if (widget.delay != null) {
      Future.delayed(widget.delay!, () {
        if (mounted) {
          setState(() {
            _show = true;
          });
        }
      });
    } else {
      _show = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _show ? widget.child : const SizedBox.shrink();
  }
}

