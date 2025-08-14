import 'package:flutter/material.dart';
import 'dart:math' as math;

class EmvChipWidget extends StatefulWidget {
  final double width;
  final double height;

  const EmvChipWidget({super.key, this.width = 32.0, this.height = 24.0});

  @override
  State<EmvChipWidget> createState() => _EmvChipWidgetState();
}

class _EmvChipWidgetState extends State<EmvChipWidget>
    with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  late AnimationController _reflectionController;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _reflectionAnimation;

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

    _reflectionAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _reflectionController, curve: Curves.easeInOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        children: [
          _buildChipBase(),
          _buildMetallicSurface(),
          _buildContactPads(),
          _buildShimmerEffect(),
          _buildReflectionEffect(),
          _buildEdgeHighlights(),
        ],
      ),
    );
  }

  Widget _buildChipBase() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.width * 0.08),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF5F5F5),
            Color(0xFFE0E0E0),
            Color(0xFFBDBDBD),
            Color(0xFF9E9E9E),
            Color(0xFF757575),
          ],
          stops: [0.0, 0.2, 0.5, 0.8, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: widget.width * 0.08,
            offset: Offset(0, widget.height * 0.05),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: widget.width * 0.15,
            offset: Offset(0, widget.height * 0.08),
          ),
        ],
      ),
    );
  }

  Widget _buildMetallicSurface() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.width * 0.08),
        gradient: RadialGradient(
          center: const Alignment(-0.2, -0.2),
          radius: 1.2,
          colors: [
            Colors.white.withValues(alpha: 0.6),
            Colors.white.withValues(alpha: 0.2),
            Colors.white.withValues(alpha: 0.05),
            Colors.transparent,
          ],
          stops: const [0.0, 0.3, 0.7, 1.0],
        ),
      ),
    );
  }

  Widget _buildContactPads() {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: CustomPaint(painter: ContactPadsPainter()),
    );
  }

  Widget _buildShimmerEffect() {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.width * 0.08),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.transparent,
                Colors.white.withValues(alpha: 0.3),
                Colors.transparent,
              ],
              stops: [
                math.max(0.0, _shimmerAnimation.value - 0.3),
                _shimmerAnimation.value,
                math.min(1.0, _shimmerAnimation.value + 0.3),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReflectionEffect() {
    return AnimatedBuilder(
      animation: _reflectionAnimation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.width * 0.08),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withValues(
                  alpha: 0.2 * _reflectionAnimation.value,
                ),
                Colors.transparent,
                Colors.black.withValues(
                  alpha: 0.1 * _reflectionAnimation.value,
                ),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEdgeHighlights() {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
    );
  }
}

class ContactPadsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final darkPadPaint =
        Paint()
          ..color = const Color(0xFF4A4A4A)
          ..style = PaintingStyle.fill;

    final lightPadPaint =
        Paint()
          ..color = const Color(0xFF707070)
          ..style = PaintingStyle.fill;

    final highlightPaint =
        Paint()
          ..color = Colors.white.withValues(alpha: 0.3)
          ..style = PaintingStyle.fill;

    // More realistic pad layout - actual EMV pattern
    final padSize = size.width * 0.08;
    final spacingX = size.width * 0.105;
    final spacingY = size.height * 0.16;
    final startX = size.width * 0.08;
    final startY = size.height * 0.12;

    // Draw contact pads in authentic EMV pattern
    for (int row = 0; row < 5; row++) {
      for (int col = 0; col < 8; col++) {
        double x = startX + col * spacingX;
        double y = startY + row * spacingY;

        // Create more realistic EMV contact pattern
        bool shouldSkip = false;

        // Skip corner contacts for authentic look
        if (row == 0 && (col == 0 || col == 7)) shouldSkip = true;
        if (row == 4 && (col == 0 || col == 7)) shouldSkip = true;

        if (shouldSkip) continue;

        // Alternate pad colors for depth
        Paint currentPaint =
            (row + col) % 2 == 0 ? darkPadPaint : lightPadPaint;

        // Main contact pad with slight variation
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x, y, padSize, padSize * 0.9),
            Radius.circular(padSize * 0.15),
          ),
          currentPaint,
        );

        // Top highlight for 3D effect
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x, y, padSize, padSize * 0.4),
            Radius.circular(padSize * 0.1),
          ),
          highlightPaint,
        );

        // Side shadow for depth
        final shadowPaint =
            Paint()
              ..color = Colors.black.withValues(alpha: 0.2)
              ..style = PaintingStyle.fill;

        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              x + padSize * 0.1,
              y + padSize * 0.7,
              padSize * 0.9,
              padSize * 0.2,
            ),
            Radius.circular(padSize * 0.05),
          ),
          shadowPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
