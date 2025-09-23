import 'package:flutter/material.dart';

/// 페이드 인 애니메이션 위젯
class FadeInAnimation extends StatelessWidget {
  final Widget child;
  final AnimationController controller;
  final Duration? delay;
  final Curve curve;

  const FadeInAnimation({
    super.key,
    required this.child,
    required this.controller,
    this.delay,
    this.curve = Curves.easeInOut,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return FadeTransition(opacity: controller, child: child);
      },
      child: child,
    );
  }
}

