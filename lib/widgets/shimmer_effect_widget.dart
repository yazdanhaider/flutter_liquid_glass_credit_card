import 'package:flutter/material.dart';
import 'dart:math' as math;

class ShimmerEffectWidget extends StatefulWidget {
  final Widget child;
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final double intensity;
  final bool isFlipped;

  const ShimmerEffectWidget({
    super.key,
    required this.child,
    required this.width,
    required this.height,
    this.borderRadius,
    this.intensity = 0.4,
    this.isFlipped = false,
  });

  @override
  State<ShimmerEffectWidget> createState() => _ShimmerEffectWidgetState();
}

class _ShimmerEffectWidgetState extends State<ShimmerEffectWidget>
    with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  late AnimationController _reflectionController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _reflectionController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _reflectionController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius ?? BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          widget.child,
          AnimatedBuilder(
            animation: _shimmerAnimation,
            builder: (context, child) {
              return ClipRRect(
                borderRadius: widget.borderRadius ?? BorderRadius.circular(20),
                child: Container(
                  width: widget.width,
                  height: widget.height,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.transparent,
                        Colors.white.withValues(alpha: widget.intensity * 0.3),
                        Colors.transparent,
                      ],
                      stops: [
                        math.max(0.0, _shimmerAnimation.value - 0.1),
                        _shimmerAnimation.value,
                        math.min(1.0, _shimmerAnimation.value + 0.1),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
