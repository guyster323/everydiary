import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// 로딩 애니메이션 위젯들
/// 다양한 로딩 상태를 표시하는 애니메이션 위젯들을 제공합니다.
class LoadingAnimations {
  /// 기본 로딩 인디케이터
  static Widget circular({
    double size = 24.0,
    Color? color,
    double strokeWidth = 2.0,
  }) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(color ?? Colors.blue),
      ),
    );
  }

  /// 선형 로딩 인디케이터
  static Widget linear({
    double height = 4.0,
    Color? color,
    Color? backgroundColor,
  }) {
    return LinearProgressIndicator(
      minHeight: height,
      valueColor: AlwaysStoppedAnimation<Color>(color ?? Colors.blue),
      backgroundColor: backgroundColor ?? Colors.grey[300],
    );
  }

  /// 점프하는 점들 애니메이션
  static Widget bouncingDots({
    double size = 8.0,
    Color? color,
    Duration duration = const Duration(milliseconds: 600),
  }) {
    return _BouncingDots(
      size: size,
      color: color ?? Colors.blue,
      duration: duration,
    );
  }

  /// 펄스 애니메이션
  static Widget pulse({
    double size = 24.0,
    Color? color,
    Duration duration = const Duration(milliseconds: 1000),
  }) {
    return _PulseAnimation(
      size: size,
      color: color ?? Colors.blue,
      duration: duration,
    );
  }

  /// 스피너 애니메이션
  static Widget spinner({
    double size = 24.0,
    Color? color,
    Duration duration = const Duration(milliseconds: 1200),
  }) {
    return _SpinnerAnimation(
      size: size,
      color: color ?? Colors.blue,
      duration: duration,
    );
  }

  /// 웨이브 애니메이션
  static Widget wave({
    double size = 24.0,
    Color? color,
    Duration duration = const Duration(milliseconds: 1000),
  }) {
    return _WaveAnimation(
      size: size,
      color: color ?? Colors.blue,
      duration: duration,
    );
  }

  /// Lottie 애니메이션
  static Widget lottie({
    required String assetPath,
    double? width,
    double? height,
    bool repeat = true,
    bool reverse = false,
    Duration? duration,
  }) {
    return Lottie.asset(
      assetPath,
      width: width,
      height: height,
      repeat: repeat,
      reverse: reverse,
      fit: BoxFit.contain,
    );
  }

  /// 텍스트와 함께 로딩
  static Widget withText({
    required String text,
    Widget? loadingWidget,
    double spacing = 16.0,
    MainAxisAlignment alignment = MainAxisAlignment.center,
  }) {
    return Column(
      mainAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        loadingWidget ?? circular(),
        SizedBox(height: spacing),
        Text(text, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }

  /// 버튼 내부 로딩
  static Widget button({double size = 16.0, Color? color}) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2.0,
        valueColor: AlwaysStoppedAnimation<Color>(color ?? Colors.white),
      ),
    );
  }

  /// 오버레이 로딩
  static Widget overlay({
    required Widget child,
    bool isLoading = false,
    String? loadingText,
    Color? backgroundColor,
  }) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: backgroundColor ?? Colors.black.withValues(alpha: 0.3),
            child: Center(child: withText(text: loadingText ?? '로딩 중...')),
          ),
      ],
    );
  }
}

/// 점프하는 점들 애니메이션
class _BouncingDots extends StatefulWidget {
  const _BouncingDots({
    required this.size,
    required this.color,
    required this.duration,
  });

  final double size;
  final Color color;
  final Duration duration;

  @override
  State<_BouncingDots> createState() => _BouncingDotsState();
}

class _BouncingDotsState extends State<_BouncingDots>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (index) => AnimationController(duration: widget.duration, vsync: this),
    );

    _animations = _controllers.map((controller) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
    }).toList();

    _startAnimations();
  }

  void _startAnimations() {
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              child: Transform.translate(
                offset: Offset(0, -_animations[index].value * 10),
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

/// 펄스 애니메이션
class _PulseAnimation extends StatefulWidget {
  const _PulseAnimation({
    required this.size,
    required this.color,
    required this.duration,
  });

  final double size;
  final Color color;
  final Duration duration;

  @override
  State<_PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<_PulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _animation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}

/// 스피너 애니메이션
class _SpinnerAnimation extends StatefulWidget {
  const _SpinnerAnimation({
    required this.size,
    required this.color,
    required this.duration,
  });

  final double size;
  final Color color;
  final Duration duration;

  @override
  State<_SpinnerAnimation> createState() => _SpinnerAnimationState();
}

class _SpinnerAnimationState extends State<_SpinnerAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 2 * 3.14159,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              border: Border.all(color: widget.color, width: 2),
              borderRadius: BorderRadius.circular(widget.size / 2),
            ),
            child: CustomPaint(
              painter: _SpinnerPainter(color: widget.color, strokeWidth: 2),
            ),
          ),
        );
      },
    );
  }
}

/// 스피너 페인터
class _SpinnerPainter extends CustomPainter {
  const _SpinnerPainter({required this.color, required this.strokeWidth});

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2, // -90도에서 시작
      3.14159 * 1.5, // 270도 호
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 웨이브 애니메이션
class _WaveAnimation extends StatefulWidget {
  const _WaveAnimation({
    required this.size,
    required this.color,
    required this.duration,
  });

  final double size;
  final Color color;
  final Duration duration;

  @override
  State<_WaveAnimation> createState() => _WaveAnimationState();
}

class _WaveAnimationState extends State<_WaveAnimation>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      5,
      (index) => AnimationController(duration: widget.duration, vsync: this),
    );

    _animations = _controllers.map((controller) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
    }).toList();

    _startAnimations();
  }

  void _startAnimations() {
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 1),
              child: Container(
                width: 3,
                height: widget.size * (0.3 + _animations[index].value * 0.7),
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
