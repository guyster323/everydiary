import 'package:flutter/material.dart';

/// 슬라이드 인 애니메이션 위젯
class SlideInAnimation extends StatelessWidget {
  final Widget child;
  final AnimationController controller;
  final Offset begin;
  final Offset end;
  final Curve curve;

  const SlideInAnimation({
    super.key,
    required this.child,
    required this.controller,
    this.begin = const Offset(0, 1),
    this.end = Offset.zero,
    this.curve = Curves.easeOutCubic,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: begin,
            end: end,
          ).animate(CurvedAnimation(parent: controller, curve: curve)),
          child: child,
        );
      },
      child: child,
    );
  }
}

