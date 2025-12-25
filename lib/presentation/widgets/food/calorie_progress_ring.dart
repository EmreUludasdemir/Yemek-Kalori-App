import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class CalorieProgressRing extends StatefulWidget {
  final double current;
  final double goal;
  final double size;
  final double strokeWidth;

  const CalorieProgressRing({
    super.key,
    required this.current,
    required this.goal,
    this.size = 200,
    this.strokeWidth = 16,
  });

  @override
  State<CalorieProgressRing> createState() => _CalorieProgressRingState();
}

class _CalorieProgressRingState extends State<CalorieProgressRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: widget.current / widget.goal)
        .animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward();
  }

  @override
  void didUpdateWidget(CalorieProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.current != widget.current || oldWidget.goal != widget.goal) {
      _animation = Tween<double>(
        begin: oldWidget.current / oldWidget.goal,
        end: widget.current / widget.goal,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = (widget.current / widget.goal).clamp(0.0, 1.0);
    final isOverGoal = widget.current > widget.goal;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            painter: _CalorieRingPainter(
              progress: _animation.value,
              strokeWidth: widget.strokeWidth,
              isOverGoal: isOverGoal,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.current.toStringAsFixed(0),
                    style: TextStyle(
                      fontSize: widget.size * 0.20,
                      fontWeight: FontWeight.bold,
                      color: isOverGoal ? AppColors.error : AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 40,
                    height: 2,
                    color: AppColors.divider,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.goal.toStringAsFixed(0),
                    style: TextStyle(
                      fontSize: widget.size * 0.12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'kalori',
                    style: TextStyle(
                      fontSize: widget.size * 0.08,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CalorieRingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final bool isOverGoal;

  _CalorieRingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.isOverGoal,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final backgroundPaint = Paint()
      ..color = AppColors.divider.withOpacity(0.2)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..shader = LinearGradient(
        colors: isOverGoal
            ? [AppColors.error, AppColors.warning]
            : [AppColors.primary, AppColors.primaryLight],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start from top
      sweepAngle,
      false,
      progressPaint,
    );

    // Outer glow effect
    if (progress > 0) {
      final glowPaint = Paint()
        ..color = (isOverGoal ? AppColors.error : AppColors.primary)
            .withOpacity(0.2)
        ..strokeWidth = strokeWidth + 4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweepAngle,
        false,
        glowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_CalorieRingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isOverGoal != isOverGoal;
  }
}
