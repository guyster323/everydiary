import 'package:flutter/material.dart';

/// 사용자 인터랙션 피드백 애니메이션 위젯들
/// 버튼, 카드, 기타 인터랙티브 요소들의 피드백 애니메이션을 제공합니다.
class InteractionAnimations {
  /// 탭 피드백 애니메이션
  static Widget tapFeedback({
    required Widget child,
    required VoidCallback onTap,
    double scale = 0.95,
    Duration duration = const Duration(milliseconds: 100),
    Curve curve = Curves.easeInOut,
  }) {
    return _TapFeedbackAnimation(
      onTap: onTap,
      scale: scale,
      duration: duration,
      curve: curve,
      child: child,
    );
  }

  /// 호버 피드백 애니메이션
  static Widget hoverFeedback({
    required Widget child,
    required VoidCallback onTap,
    double scale = 1.05,
    Duration duration = const Duration(milliseconds: 200),
    Curve curve = Curves.easeInOut,
  }) {
    return _HoverFeedbackAnimation(
      onTap: onTap,
      scale: scale,
      duration: duration,
      curve: curve,
      child: child,
    );
  }

  /// 리플 효과 애니메이션
  static Widget rippleFeedback({
    required Widget child,
    required VoidCallback onTap,
    Color? rippleColor,
    double borderRadius = 0.0,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        splashColor: rippleColor,
        highlightColor: rippleColor?.withValues(alpha: 0.1),
        child: child,
      ),
    );
  }

  /// 펄스 피드백 애니메이션
  static Widget pulseFeedback({
    required Widget child,
    required VoidCallback onTap,
    double scale = 1.1,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) {
    return _PulseFeedbackAnimation(
      onTap: onTap,
      scale: scale,
      duration: duration,
      curve: curve,
      child: child,
    );
  }

  /// 바운스 피드백 애니메이션
  static Widget bounceFeedback({
    required Widget child,
    required VoidCallback onTap,
    double scale = 1.2,
    Duration duration = const Duration(milliseconds: 200),
    Curve curve = Curves.elasticOut,
  }) {
    return _BounceFeedbackAnimation(
      onTap: onTap,
      scale: scale,
      duration: duration,
      curve: curve,
      child: child,
    );
  }

  /// 샤이크 피드백 애니메이션
  static Widget shakeFeedback({
    required Widget child,
    required VoidCallback onTap,
    double intensity = 10.0,
    Duration duration = const Duration(milliseconds: 500),
  }) {
    return _ShakeFeedbackAnimation(
      onTap: onTap,
      intensity: intensity,
      duration: duration,
      child: child,
    );
  }

  /// 글로우 피드백 애니메이션
  static Widget glowFeedback({
    required Widget child,
    required VoidCallback onTap,
    Color glowColor = Colors.blue,
    double glowRadius = 20.0,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return _GlowFeedbackAnimation(
      onTap: onTap,
      glowColor: glowColor,
      glowRadius: glowRadius,
      duration: duration,
      child: child,
    );
  }

  /// 슬라이드 피드백 애니메이션
  static Widget slideFeedback({
    required Widget child,
    required VoidCallback onTap,
    Offset slideOffset = const Offset(5, 0),
    Duration duration = const Duration(milliseconds: 150),
    Curve curve = Curves.easeInOut,
  }) {
    return _SlideFeedbackAnimation(
      onTap: onTap,
      slideOffset: slideOffset,
      duration: duration,
      curve: curve,
      child: child,
    );
  }

  /// 복합 피드백 애니메이션 (스케일 + 페이드)
  static Widget scaleFadeFeedback({
    required Widget child,
    required VoidCallback onTap,
    double scale = 0.9,
    double fadeOpacity = 0.7,
    Duration duration = const Duration(milliseconds: 150),
    Curve curve = Curves.easeInOut,
  }) {
    return _ScaleFadeFeedbackAnimation(
      onTap: onTap,
      scale: scale,
      fadeOpacity: fadeOpacity,
      duration: duration,
      curve: curve,
      child: child,
    );
  }

  /// 커스텀 피드백 애니메이션
  static Widget customFeedback({
    required Widget child,
    required VoidCallback onTap,
    required Widget Function(
      BuildContext context,
      Animation<double> animation,
      Widget child,
    )
    feedbackBuilder,
    Duration duration = const Duration(milliseconds: 150),
    Curve curve = Curves.easeInOut,
  }) {
    return _CustomFeedbackAnimation(
      onTap: onTap,
      feedbackBuilder: feedbackBuilder,
      duration: duration,
      curve: curve,
      child: child,
    );
  }
}

/// 탭 피드백 애니메이션
class _TapFeedbackAnimation extends StatefulWidget {
  const _TapFeedbackAnimation({
    required this.child,
    required this.onTap,
    required this.scale,
    required this.duration,
    required this.curve,
  });

  final Widget child;
  final VoidCallback onTap;
  final double scale;
  final Duration duration;
  final Curve curve;

  @override
  State<_TapFeedbackAnimation> createState() => _TapFeedbackAnimationState();
}

class _TapFeedbackAnimationState extends State<_TapFeedbackAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _animation = Tween<double>(
      begin: 1.0,
      end: widget.scale,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward().then((_) {
      _controller.reverse();
    });
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.scale(scale: _animation.value, child: child);
        },
        child: widget.child,
      ),
    );
  }
}

/// 호버 피드백 애니메이션
class _HoverFeedbackAnimation extends StatefulWidget {
  const _HoverFeedbackAnimation({
    required this.child,
    required this.onTap,
    required this.scale,
    required this.duration,
    required this.curve,
  });

  final Widget child;
  final VoidCallback onTap;
  final double scale;
  final Duration duration;
  final Curve curve;

  @override
  State<_HoverFeedbackAnimation> createState() =>
      _HoverFeedbackAnimationState();
}

class _HoverFeedbackAnimationState extends State<_HoverFeedbackAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _animation = Tween<double>(
      begin: 1.0,
      end: widget.scale,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        _controller.forward();
      },
      onExit: (_) {
        _controller.reverse();
      },
      child: GestureDetector(
        onTap: _handleTap,
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform.scale(scale: _animation.value, child: child);
          },
          child: widget.child,
        ),
      ),
    );
  }
}

/// 펄스 피드백 애니메이션
class _PulseFeedbackAnimation extends StatefulWidget {
  const _PulseFeedbackAnimation({
    required this.child,
    required this.onTap,
    required this.scale,
    required this.duration,
    required this.curve,
  });

  final Widget child;
  final VoidCallback onTap;
  final double scale;
  final Duration duration;
  final Curve curve;

  @override
  State<_PulseFeedbackAnimation> createState() =>
      _PulseFeedbackAnimationState();
}

class _PulseFeedbackAnimationState extends State<_PulseFeedbackAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _animation = Tween<double>(
      begin: 1.0,
      end: widget.scale,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward().then((_) {
      _controller.reverse();
    });
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.scale(scale: _animation.value, child: child);
        },
        child: widget.child,
      ),
    );
  }
}

/// 바운스 피드백 애니메이션
class _BounceFeedbackAnimation extends StatefulWidget {
  const _BounceFeedbackAnimation({
    required this.child,
    required this.onTap,
    required this.scale,
    required this.duration,
    required this.curve,
  });

  final Widget child;
  final VoidCallback onTap;
  final double scale;
  final Duration duration;
  final Curve curve;

  @override
  State<_BounceFeedbackAnimation> createState() =>
      _BounceFeedbackAnimationState();
}

class _BounceFeedbackAnimationState extends State<_BounceFeedbackAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _animation = Tween<double>(
      begin: 1.0,
      end: widget.scale,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward().then((_) {
      _controller.reverse();
    });
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.scale(scale: _animation.value, child: child);
        },
        child: widget.child,
      ),
    );
  }
}

/// 샤이크 피드백 애니메이션
class _ShakeFeedbackAnimation extends StatefulWidget {
  const _ShakeFeedbackAnimation({
    required this.child,
    required this.onTap,
    required this.intensity,
    required this.duration,
  });

  final Widget child;
  final VoidCallback onTap;
  final double intensity;
  final Duration duration;

  @override
  State<_ShakeFeedbackAnimation> createState() =>
      _ShakeFeedbackAnimationState();
}

class _ShakeFeedbackAnimationState extends State<_ShakeFeedbackAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward().then((_) {
      _controller.reset();
    });
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final shake =
              widget.intensity *
              (0.5 - (0.5 * (1 - _animation.value)).abs()) *
              (1 - _animation.value);

          return Transform.translate(offset: Offset(shake, 0), child: child);
        },
        child: widget.child,
      ),
    );
  }
}

/// 글로우 피드백 애니메이션
class _GlowFeedbackAnimation extends StatefulWidget {
  const _GlowFeedbackAnimation({
    required this.child,
    required this.onTap,
    required this.glowColor,
    required this.glowRadius,
    required this.duration,
  });

  final Widget child;
  final VoidCallback onTap;
  final Color glowColor;
  final double glowRadius;
  final Duration duration;

  @override
  State<_GlowFeedbackAnimation> createState() => _GlowFeedbackAnimationState();
}

class _GlowFeedbackAnimationState extends State<_GlowFeedbackAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward().then((_) {
      _controller.reverse();
    });
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: widget.glowColor.withValues(
                    alpha: _animation.value * 0.5,
                  ),
                  blurRadius: widget.glowRadius * _animation.value,
                  spreadRadius: widget.glowRadius * _animation.value * 0.5,
                ),
              ],
            ),
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}

/// 슬라이드 피드백 애니메이션
class _SlideFeedbackAnimation extends StatefulWidget {
  const _SlideFeedbackAnimation({
    required this.child,
    required this.onTap,
    required this.slideOffset,
    required this.duration,
    required this.curve,
  });

  final Widget child;
  final VoidCallback onTap;
  final Offset slideOffset;
  final Duration duration;
  final Curve curve;

  @override
  State<_SlideFeedbackAnimation> createState() =>
      _SlideFeedbackAnimationState();
}

class _SlideFeedbackAnimationState extends State<_SlideFeedbackAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _animation = Tween<Offset>(
      begin: Offset.zero,
      end: widget.slideOffset,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward().then((_) {
      _controller.reverse();
    });
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.translate(offset: _animation.value, child: child);
        },
        child: widget.child,
      ),
    );
  }
}

/// 복합 피드백 애니메이션 (스케일 + 페이드)
class _ScaleFadeFeedbackAnimation extends StatefulWidget {
  const _ScaleFadeFeedbackAnimation({
    required this.child,
    required this.onTap,
    required this.scale,
    required this.fadeOpacity,
    required this.duration,
    required this.curve,
  });

  final Widget child;
  final VoidCallback onTap;
  final double scale;
  final double fadeOpacity;
  final Duration duration;
  final Curve curve;

  @override
  State<_ScaleFadeFeedbackAnimation> createState() =>
      _ScaleFadeFeedbackAnimationState();
}

class _ScaleFadeFeedbackAnimationState
    extends State<_ScaleFadeFeedbackAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scale,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: widget.fadeOpacity,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward().then((_) {
      _controller.reverse();
    });
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(opacity: _fadeAnimation.value, child: child),
          );
        },
        child: widget.child,
      ),
    );
  }
}

/// 커스텀 피드백 애니메이션
class _CustomFeedbackAnimation extends StatefulWidget {
  const _CustomFeedbackAnimation({
    required this.child,
    required this.onTap,
    required this.feedbackBuilder,
    required this.duration,
    required this.curve,
  });

  final Widget child;
  final VoidCallback onTap;
  final Widget Function(
    BuildContext context,
    Animation<double> animation,
    Widget child,
  )
  feedbackBuilder;
  final Duration duration;
  final Curve curve;

  @override
  State<_CustomFeedbackAnimation> createState() =>
      _CustomFeedbackAnimationState();
}

class _CustomFeedbackAnimationState extends State<_CustomFeedbackAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward().then((_) {
      _controller.reverse();
    });
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: widget.feedbackBuilder(context, _animation, widget.child),
    );
  }
}
