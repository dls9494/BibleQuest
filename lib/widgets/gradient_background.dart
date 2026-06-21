import 'package:flutter/material.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1B1E35),
            Color(0xFF1B223D),
            Color(0xFF1A2644),
            Color(0xFF162B4E),
            Color(0xFF15335A),
          ],
        ),
      ),
      child: child,
    );
  }
}
