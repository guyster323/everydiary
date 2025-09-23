import 'package:flutter/material.dart';

/// 애니메이션이 적용된 리스트뷰 위젯
class AnimatedListView extends StatefulWidget {
  final List<Widget> children;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final Duration animationDuration;
  final Duration staggerDuration;
  final Curve animationCurve;

  const AnimatedListView({
    super.key,
    required this.children,
    this.controller,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
    this.animationDuration = const Duration(milliseconds: 300),
    this.staggerDuration = const Duration(milliseconds: 100),
    this.animationCurve = Curves.easeOutCubic,
  });

  @override
  State<AnimatedListView> createState() => _AnimatedListViewState();
}

class _AnimatedListViewState extends State<AnimatedListView>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<Offset>> _slideAnimations;
  late List<Animation<double>> _fadeAnimations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _controllers = List.generate(
      widget.children.length,
      (index) =>
          AnimationController(duration: widget.animationDuration, vsync: this),
    );

    _slideAnimations = List.generate(
      widget.children.length,
      (index) =>
          Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
            CurvedAnimation(
              parent: _controllers[index],
              curve: widget.animationCurve,
            ),
          ),
    );

    _fadeAnimations = List.generate(
      widget.children.length,
      (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controllers[index],
          curve: widget.animationCurve,
        ),
      ),
    );

    // 지연된 애니메이션 시작
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(
        Duration(milliseconds: i * widget.staggerDuration.inMilliseconds),
        () {
          if (mounted) {
            _controllers[i].forward();
          }
        },
      );
    }
  }

  @override
  void didUpdateWidget(AnimatedListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.children.length != widget.children.length) {
      _disposeControllers();
      _initializeAnimations();
    }
  }

  void _disposeControllers() {
    for (final controller in _controllers) {
      controller.dispose();
    }
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: widget.controller,
      padding: widget.padding,
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics,
      itemCount: widget.children.length,
      itemBuilder: (context, index) {
        if (index >= _controllers.length) {
          return widget.children[index];
        }

        return AnimatedBuilder(
          animation: _controllers[index],
          builder: (context, child) {
            return SlideTransition(
              position: _slideAnimations[index],
              child: FadeTransition(
                opacity: _fadeAnimations[index],
                child: widget.children[index],
              ),
            );
          },
        );
      },
    );
  }
}

/// 애니메이션이 적용된 그리드뷰 위젯
class AnimatedGridView extends StatefulWidget {
  final List<Widget> children;
  final int crossAxisCount;
  final double childAspectRatio;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final Duration animationDuration;
  final Duration staggerDuration;
  final Curve animationCurve;

  const AnimatedGridView({
    super.key,
    required this.children,
    this.crossAxisCount = 2,
    this.childAspectRatio = 1.0,
    this.crossAxisSpacing = 8.0,
    this.mainAxisSpacing = 8.0,
    this.controller,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
    this.animationDuration = const Duration(milliseconds: 300),
    this.staggerDuration = const Duration(milliseconds: 100),
    this.animationCurve = Curves.easeOutCubic,
  });

  @override
  State<AnimatedGridView> createState() => _AnimatedGridViewState();
}

class _AnimatedGridViewState extends State<AnimatedGridView>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<Offset>> _slideAnimations;
  late List<Animation<double>> _fadeAnimations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _controllers = List.generate(
      widget.children.length,
      (index) =>
          AnimationController(duration: widget.animationDuration, vsync: this),
    );

    _slideAnimations = List.generate(
      widget.children.length,
      (index) =>
          Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
            CurvedAnimation(
              parent: _controllers[index],
              curve: widget.animationCurve,
            ),
          ),
    );

    _fadeAnimations = List.generate(
      widget.children.length,
      (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controllers[index],
          curve: widget.animationCurve,
        ),
      ),
    );

    // 지연된 애니메이션 시작
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(
        Duration(milliseconds: i * widget.staggerDuration.inMilliseconds),
        () {
          if (mounted) {
            _controllers[i].forward();
          }
        },
      );
    }
  }

  @override
  void didUpdateWidget(AnimatedGridView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.children.length != widget.children.length) {
      _disposeControllers();
      _initializeAnimations();
    }
  }

  void _disposeControllers() {
    for (final controller in _controllers) {
      controller.dispose();
    }
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: widget.controller,
      padding: widget.padding,
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.crossAxisCount,
        childAspectRatio: widget.childAspectRatio,
        crossAxisSpacing: widget.crossAxisSpacing,
        mainAxisSpacing: widget.mainAxisSpacing,
      ),
      itemCount: widget.children.length,
      itemBuilder: (context, index) {
        if (index >= _controllers.length) {
          return widget.children[index];
        }

        return AnimatedBuilder(
          animation: _controllers[index],
          builder: (context, child) {
            return SlideTransition(
              position: _slideAnimations[index],
              child: FadeTransition(
                opacity: _fadeAnimations[index],
                child: widget.children[index],
              ),
            );
          },
        );
      },
    );
  }
}
