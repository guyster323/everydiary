import 'package:flutter/material.dart';

/// 스크롤 애니메이션 위젯들
/// 스크롤과 관련된 다양한 애니메이션 효과를 제공합니다.
class ScrollAnimations {
  /// 스크롤 시 나타나는 애니메이션
  static Widget scrollReveal({
    required Widget child,
    Duration duration = const Duration(milliseconds: 600),
    Curve curve = Curves.easeOut,
    double offset = 50.0,
    ScrollRevealDirection direction = ScrollRevealDirection.bottom,
  }) {
    return _ScrollRevealAnimation(
      duration: duration,
      curve: curve,
      offset: offset,
      direction: direction,
      child: child,
    );
  }

  /// 스크롤 시 페이드 인 애니메이션
  static Widget scrollFadeIn({
    required Widget child,
    Duration duration = const Duration(milliseconds: 600),
    Curve curve = Curves.easeOut,
  }) {
    return _ScrollFadeInAnimation(
      duration: duration,
      curve: curve,
      child: child,
    );
  }

  /// 스크롤 시 스케일 애니메이션
  static Widget scrollScale({
    required Widget child,
    Duration duration = const Duration(milliseconds: 600),
    Curve curve = Curves.easeOut,
    double beginScale = 0.8,
    double endScale = 1.0,
  }) {
    return _ScrollScaleAnimation(
      duration: duration,
      curve: curve,
      beginScale: beginScale,
      endScale: endScale,
      child: child,
    );
  }

  /// 스크롤 시 회전 애니메이션
  static Widget scrollRotate({
    required Widget child,
    Duration duration = const Duration(milliseconds: 600),
    Curve curve = Curves.easeOut,
    double beginAngle = -0.1,
    double endAngle = 0.0,
  }) {
    return _ScrollRotateAnimation(
      duration: duration,
      curve: curve,
      beginAngle: beginAngle,
      endAngle: endAngle,
      child: child,
    );
  }

  /// 스크롤 시 복합 애니메이션 (슬라이드 + 페이드)
  static Widget scrollSlideFade({
    required Widget child,
    Duration duration = const Duration(milliseconds: 600),
    Curve curve = Curves.easeOut,
    double offset = 50.0,
    ScrollRevealDirection direction = ScrollRevealDirection.bottom,
  }) {
    return _ScrollSlideFadeAnimation(
      duration: duration,
      curve: curve,
      offset: offset,
      direction: direction,
      child: child,
    );
  }

  /// 스크롤 시 복합 애니메이션 (스케일 + 페이드)
  static Widget scrollScaleFade({
    required Widget child,
    Duration duration = const Duration(milliseconds: 600),
    Curve curve = Curves.easeOut,
    double beginScale = 0.8,
    double endScale = 1.0,
  }) {
    return _ScrollScaleFadeAnimation(
      duration: duration,
      curve: curve,
      beginScale: beginScale,
      endScale: endScale,
      child: child,
    );
  }

  /// 스크롤 시 순차적 애니메이션
  static Widget scrollStaggered({
    required List<Widget> children,
    Duration duration = const Duration(milliseconds: 600),
    Curve curve = Curves.easeOut,
    Duration staggerDelay = const Duration(milliseconds: 100),
    double offset = 50.0,
    ScrollRevealDirection direction = ScrollRevealDirection.bottom,
  }) {
    return Column(
      children: children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;

        return _ScrollRevealAnimation(
          duration: duration,
          curve: curve,
          offset: offset,
          direction: direction,
          delay: Duration(milliseconds: index * staggerDelay.inMilliseconds),
          child: child,
        );
      }).toList(),
    );
  }

  /// 스크롤 시 그리드 애니메이션
  static Widget scrollGrid({
    required List<Widget> children,
    required int crossAxisCount,
    Duration duration = const Duration(milliseconds: 600),
    Curve curve = Curves.easeOut,
    Duration staggerDelay = const Duration(milliseconds: 50),
    double offset = 50.0,
    ScrollRevealDirection direction = ScrollRevealDirection.bottom,
    double mainAxisSpacing = 8.0,
    double crossAxisSpacing = 8.0,
  }) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) {
        return _ScrollRevealAnimation(
          duration: duration,
          curve: curve,
          offset: offset,
          direction: direction,
          delay: Duration(milliseconds: index * staggerDelay.inMilliseconds),
          child: children[index],
        );
      },
    );
  }
}

/// 스크롤 리빌 방향 열거형
enum ScrollRevealDirection { top, bottom, left, right }

/// 스크롤 시 나타나는 애니메이션
class _ScrollRevealAnimation extends StatefulWidget {
  const _ScrollRevealAnimation({
    required this.child,
    required this.duration,
    required this.curve,
    required this.offset,
    required this.direction,
    this.delay = Duration.zero,
  });

  final Widget child;
  final Duration duration;
  final Curve curve;
  final double offset;
  final ScrollRevealDirection direction;
  final Duration delay;

  @override
  State<_ScrollRevealAnimation> createState() => _ScrollRevealAnimationState();
}

class _ScrollRevealAnimationState extends State<_ScrollRevealAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _setupAnimation();
  }

  void _setupAnimation() {
    Offset beginOffset;
    switch (widget.direction) {
      case ScrollRevealDirection.top:
        beginOffset = Offset(0, -widget.offset);
        break;
      case ScrollRevealDirection.bottom:
        beginOffset = Offset(0, widget.offset);
        break;
      case ScrollRevealDirection.left:
        beginOffset = Offset(-widget.offset, 0);
        break;
      case ScrollRevealDirection.right:
        beginOffset = Offset(widget.offset, 0);
        break;
    }

    _animation = Tween<Offset>(
      begin: beginOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_isVisible && mounted) {
      final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        final position = renderBox.localToGlobal(Offset.zero);
        final screenHeight = MediaQuery.of(context).size.height;

        if (position.dy < screenHeight * 0.8) {
          setState(() {
            _isVisible = true;
          });

          Future.delayed(widget.delay, () {
            if (mounted) {
              _controller.forward();
            }
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onScroll();
    });

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(offset: _animation.value, child: child);
      },
      child: widget.child,
    );
  }
}

/// 스크롤 시 페이드 인 애니메이션
class _ScrollFadeInAnimation extends StatefulWidget {
  const _ScrollFadeInAnimation({
    required this.child,
    required this.duration,
    required this.curve,
  });

  final Widget child;
  final Duration duration;
  final Curve curve;

  @override
  State<_ScrollFadeInAnimation> createState() => _ScrollFadeInAnimationState();
}

class _ScrollFadeInAnimationState extends State<_ScrollFadeInAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isVisible = false;

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

  void _onScroll() {
    if (!_isVisible && mounted) {
      final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        final position = renderBox.localToGlobal(Offset.zero);
        final screenHeight = MediaQuery.of(context).size.height;

        if (position.dy < screenHeight * 0.8) {
          setState(() {
            _isVisible = true;
          });
          _controller.forward();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onScroll();
    });

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(opacity: _animation.value, child: child);
      },
      child: widget.child,
    );
  }
}

/// 스크롤 시 스케일 애니메이션
class _ScrollScaleAnimation extends StatefulWidget {
  const _ScrollScaleAnimation({
    required this.child,
    required this.duration,
    required this.curve,
    required this.beginScale,
    required this.endScale,
  });

  final Widget child;
  final Duration duration;
  final Curve curve;
  final double beginScale;
  final double endScale;

  @override
  State<_ScrollScaleAnimation> createState() => _ScrollScaleAnimationState();
}

class _ScrollScaleAnimationState extends State<_ScrollScaleAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _animation = Tween<double>(
      begin: widget.beginScale,
      end: widget.endScale,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_isVisible && mounted) {
      final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        final position = renderBox.localToGlobal(Offset.zero);
        final screenHeight = MediaQuery.of(context).size.height;

        if (position.dy < screenHeight * 0.8) {
          setState(() {
            _isVisible = true;
          });
          _controller.forward();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onScroll();
    });

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(scale: _animation.value, child: child);
      },
      child: widget.child,
    );
  }
}

/// 스크롤 시 회전 애니메이션
class _ScrollRotateAnimation extends StatefulWidget {
  const _ScrollRotateAnimation({
    required this.child,
    required this.duration,
    required this.curve,
    required this.beginAngle,
    required this.endAngle,
  });

  final Widget child;
  final Duration duration;
  final Curve curve;
  final double beginAngle;
  final double endAngle;

  @override
  State<_ScrollRotateAnimation> createState() => _ScrollRotateAnimationState();
}

class _ScrollRotateAnimationState extends State<_ScrollRotateAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _animation = Tween<double>(
      begin: widget.beginAngle,
      end: widget.endAngle,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_isVisible && mounted) {
      final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        final position = renderBox.localToGlobal(Offset.zero);
        final screenHeight = MediaQuery.of(context).size.height;

        if (position.dy < screenHeight * 0.8) {
          setState(() {
            _isVisible = true;
          });
          _controller.forward();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onScroll();
    });

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _animation.value * 2 * 3.14159,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// 스크롤 시 복합 애니메이션 (슬라이드 + 페이드)
class _ScrollSlideFadeAnimation extends StatefulWidget {
  const _ScrollSlideFadeAnimation({
    required this.child,
    required this.duration,
    required this.curve,
    required this.offset,
    required this.direction,
  });

  final Widget child;
  final Duration duration;
  final Curve curve;
  final double offset;
  final ScrollRevealDirection direction;

  @override
  State<_ScrollSlideFadeAnimation> createState() =>
      _ScrollSlideFadeAnimationState();
}

class _ScrollSlideFadeAnimationState extends State<_ScrollSlideFadeAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _setupAnimations();
  }

  void _setupAnimations() {
    Offset beginOffset;
    switch (widget.direction) {
      case ScrollRevealDirection.top:
        beginOffset = Offset(0, -widget.offset);
        break;
      case ScrollRevealDirection.bottom:
        beginOffset = Offset(0, widget.offset);
        break;
      case ScrollRevealDirection.left:
        beginOffset = Offset(-widget.offset, 0);
        break;
      case ScrollRevealDirection.right:
        beginOffset = Offset(widget.offset, 0);
        break;
    }

    _slideAnimation = Tween<Offset>(
      begin: beginOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_isVisible && mounted) {
      final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        final position = renderBox.localToGlobal(Offset.zero);
        final screenHeight = MediaQuery.of(context).size.height;

        if (position.dy < screenHeight * 0.8) {
          setState(() {
            _isVisible = true;
          });
          _controller.forward();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onScroll();
    });

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: _slideAnimation.value,
          child: Opacity(opacity: _fadeAnimation.value, child: child),
        );
      },
      child: widget.child,
    );
  }
}

/// 스크롤 시 복합 애니메이션 (스케일 + 페이드)
class _ScrollScaleFadeAnimation extends StatefulWidget {
  const _ScrollScaleFadeAnimation({
    required this.child,
    required this.duration,
    required this.curve,
    required this.beginScale,
    required this.endScale,
  });

  final Widget child;
  final Duration duration;
  final Curve curve;
  final double beginScale;
  final double endScale;

  @override
  State<_ScrollScaleFadeAnimation> createState() =>
      _ScrollScaleFadeAnimationState();
}

class _ScrollScaleFadeAnimationState extends State<_ScrollScaleFadeAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _scaleAnimation = Tween<double>(
      begin: widget.beginScale,
      end: widget.endScale,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_isVisible && mounted) {
      final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        final position = renderBox.localToGlobal(Offset.zero);
        final screenHeight = MediaQuery.of(context).size.height;

        if (position.dy < screenHeight * 0.8) {
          setState(() {
            _isVisible = true;
          });
          _controller.forward();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onScroll();
    });

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(opacity: _fadeAnimation.value, child: child),
        );
      },
      child: widget.child,
    );
  }
}

