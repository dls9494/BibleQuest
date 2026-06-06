import 'package:flutter/material.dart';

class TimerCapsule extends StatefulWidget {
  final int timeLeft;
  final int totalTimeLimit;

  const TimerCapsule({
    super.key,
    required this.timeLeft,
    required this.totalTimeLimit,
  });

  @override
  State<TimerCapsule> createState() => _TimerCapsuleState();
}

class _TimerCapsuleState extends State<TimerCapsule> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _checkPulse();
  }

  @override
  void didUpdateWidget(covariant TimerCapsule oldWidget) {
    super.didUpdateWidget(oldWidget);
    _checkPulse();
  }

  void _checkPulse() {
    if (widget.timeLeft <= 5 && widget.timeLeft > 0) {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      if (_pulseController.isAnimating) {
        _pulseController.stop();
        _pulseController.value = 0.0;
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color _getProgressColor(double progress) {
    if (progress > 0.5) {
      // 100% to 50%: Green (#26890C) to Yellow (#D89E00)
      return Color.lerp(
        const Color(0xFFD89E00),
        const Color(0xFF26890C),
        (progress - 0.5) * 2,
      )!;
    } else {
      // 50% to 0%: Yellow (#D89E00) to Red (#E21B3C)
      return Color.lerp(
        const Color(0xFFE21B3C),
        const Color(0xFFD89E00),
        progress * 2,
      )!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double progress = (widget.timeLeft / (widget.totalTimeLimit > 0 ? widget.totalTimeLimit : 1)).clamp(0.0, 1.0);
    final Color barColor = _getProgressColor(progress);

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return ScaleTransition(
          scale: _scaleAnimation,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              height: 14,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(7),
                border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1),
              ),
              child: Stack(
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final double filledWidth = constraints.maxWidth * progress;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: filledWidth,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(7),
                          color: barColor,
                          boxShadow: [
                            BoxShadow(
                              color: barColor.withValues(alpha: 0.4),
                              blurRadius: 6,
                              spreadRadius: 1,
                            )
                          ],
                        ),
                      );
                    },
                  ),
                  Center(
                    child: Text(
                      '${widget.timeLeft}s',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Outfit',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
