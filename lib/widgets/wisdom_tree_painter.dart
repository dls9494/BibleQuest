import 'dart:math';
import 'package:flutter/material.dart';

class WisdomTreePainter extends CustomPainter {
  final String growthStage;
  final Map<String, double> branchScores;
  final Set<String> milestones;
  final bool isDark;

  WisdomTreePainter({
    required this.growthStage,
    required this.branchScores,
    required this.milestones,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw Rainbow / Glory Effect (Level 100 milestone) in the background
    if (milestones.contains('rainbow')) {
      _drawRainbow(canvas, size);
    }

    // 2. Draw Halo around the tree (Level 50 milestone)
    if (milestones.contains('halo')) {
      _drawHalo(canvas, size);
    }

    // Determine trunk parameters based on growth stage
    double trunkHeight = 50.0;
    double trunkThickness = 4.0;
    double maxBranchLength = 35.0;

    switch (growthStage) {
      case 'Seedling':
        trunkHeight = 40.0;
        trunkThickness = 4.0;
        maxBranchLength = 25.0;
        break;
      case 'Sprout':
        trunkHeight = 65.0;
        trunkThickness = 6.0;
        maxBranchLength = 35.0;
        break;
      case 'Young Tree':
        trunkHeight = 90.0;
        trunkThickness = 10.0;
        maxBranchLength = 50.0;
        break;
      case 'Growing Tree':
        trunkHeight = 120.0;
        trunkThickness = 14.0;
        maxBranchLength = 65.0;
        break;
      case 'Mature Tree':
        trunkHeight = 145.0;
        trunkThickness = 18.0;
        maxBranchLength = 80.0;
        break;
      case 'Flourishing Tree':
        trunkHeight = 160.0;
        trunkThickness = 22.0;
        maxBranchLength = 95.0;
        break;
    }

    final groundY = size.height - 25.0;
    final centerX = size.width / 2;

    // 3. Draw Ground / Grass
    _drawGround(canvas, size, groundY);

    // 4. Draw Trunk
    final trunkStart = Offset(centerX, groundY);
    final trunkEnd = Offset(centerX, groundY - trunkHeight);

    final trunkPaint = Paint()
      ..color = isDark ? const Color(0xFF5D4037) : const Color(0xFF3E2723)
      ..strokeWidth = trunkThickness
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(trunkStart, trunkEnd, trunkPaint);

    // If it's just a seedling, draw a tiny baby shoot and stop
    if (growthStage == 'Seedling') {
      _drawSeedlingDetails(canvas, trunkEnd, isDark);
      return;
    }

    // 5. Draw Cross Ornament on Trunk (Level 25 milestone)
    if (milestones.contains('cross')) {
      _drawCrossOnTrunk(canvas, centerX, groundY - (trunkHeight * 0.45), trunkThickness);
    }

    // 6. Draw the 7 main branches
    // We emergence them at different heights along the trunk
    final branches = [
      _BranchData(name: 'Torah', heightFraction: 0.35, angleDeg: -140),
      _BranchData(name: 'History', heightFraction: 0.50, angleDeg: -125),
      _BranchData(name: 'Wisdom', heightFraction: 0.70, angleDeg: -105),
      _BranchData(name: 'Gospels', heightFraction: 0.95, angleDeg: -90),
      _BranchData(name: 'Acts & Epistles', heightFraction: 0.80, angleDeg: -75),
      _BranchData(name: 'Prophets', heightFraction: 0.60, angleDeg: -55),
      _BranchData(name: 'Revelation', heightFraction: 0.40, angleDeg: -40),
    ];

    for (final branch in branches) {
      final score = branchScores[branch.name] ?? 0.0;
      final startY = groundY - (trunkHeight * branch.heightFraction);
      final branchStart = Offset(centerX, startY);

      final angleRad = branch.angleDeg * pi / 180.0;
      // Proportional branch length: minimum stub is 15 pixels
      final branchLength = 15.0 + (maxBranchLength - 15.0) * score;

      final branchEnd = Offset(
        centerX + branchLength * cos(angleRad),
        startY + branchLength * sin(angleRad),
      );

      // Draw branch wood
      final branchPaint = Paint()
        ..color = isDark ? const Color(0xFF6D4C41) : const Color(0xFF4E342E)
        ..strokeWidth = max(2.0, trunkThickness * 0.45)
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      canvas.drawLine(branchStart, branchEnd, branchPaint);

      // Draw leaves / blossoms / fruits
      _drawFoliage(canvas, branchEnd, angleRad, score, branch.name);
    }

    // 7. Draw Golden Leaf (7-day streak milestone)
    if (milestones.contains('golden_leaf')) {
      _drawGoldenLeaf(canvas, Offset(centerX, groundY - trunkHeight - 20));
    }

    // 8. Draw Dove (30-day streak milestone)
    if (milestones.contains('dove')) {
      _drawDove(canvas, Offset(centerX - 80, groundY - trunkHeight - 40));
    }
  }

  void _drawGround(Canvas canvas, Size size, double groundY) {
    final groundPaint = Paint()
      ..color = isDark ? const Color(0xFF2E7D32) : const Color(0xFF4CAF50)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, groundY + 30)
      ..quadraticBezierTo(size.width / 2, groundY - 10, size.width, groundY + 30)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, groundPaint);
  }

  void _drawSeedlingDetails(Canvas canvas, Offset tip, bool isDark) {
    // Draw two tiny green baby leaves at the tip
    final leafPaint = Paint()
      ..color = const Color(0xFF81C784)
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCenter(center: Offset(tip.dx - 6, tip.dy - 3), width: 10, height: 6),
      leafPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(tip.dx + 6, tip.dy - 3), width: 10, height: 6),
      leafPaint,
    );
  }

  void _drawFoliage(Canvas canvas, Offset tip, double angleRad, double score, String branchName) {
    if (score < 0.3) {
      // Bare - do not draw anything
      return;
    }

    final rand = _DeterministicRandom(branchName.hashCode);

    // Leaves (0.3 - 0.6)
    // Blossoms (0.6 - 0.9)
    // Fruit ( > 0.9 )
    Color foliageColor;
    bool isFruit = false;
    bool isBlossom = false;

    if (score >= 0.9) {
      isFruit = true;
      foliageColor = const Color(0xFFE53935); // Apple red
    } else if (score >= 0.6) {
      isBlossom = true;
      foliageColor = const Color(0xFFF48FB1); // Blossom pink
    } else {
      foliageColor = const Color(0xFF66BB6A); // Leaf green
    }

    final foliagePaint = Paint()
      ..color = foliageColor
      ..style = PaintingStyle.fill;

    // Draw leaf cluster background (always draw some green leaves first for blossoms and fruit)
    if (isFruit || isBlossom) {
      final greenPaint = Paint()
        ..color = const Color(0xFF4CAF50).withValues(alpha: 0.85)
        ..style = PaintingStyle.fill;

      for (int i = 0; i < 5; i++) {
        final angleOffset = (rand.nextDouble() - 0.5) * 0.9;
        final dist = 5.0 + rand.nextDouble() * 15.0;
        final lx = tip.dx + dist * cos(angleRad + angleOffset);
        final ly = tip.dy + dist * sin(angleRad + angleOffset);
        canvas.drawCircle(Offset(lx, ly), 6.0 + rand.nextDouble() * 4.0, greenPaint);
      }
    }

    // Draw primary foliage elements
    for (int i = 0; i < 6; i++) {
      final angleOffset = (rand.nextDouble() - 0.5) * 0.8;
      final dist = 4.0 + rand.nextDouble() * 16.0;
      final lx = tip.dx + dist * cos(angleRad + angleOffset);
      final ly = tip.dy + dist * sin(angleRad + angleOffset);

      if (isFruit) {
        // Draw fruit (red circles with small green leaves)
        canvas.drawCircle(Offset(lx, ly), 5.0, foliagePaint);
        // Little golden/yellow highlights
        final highlightPaint = Paint()
          ..color = const Color(0xFFFFEB3B)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(lx - 1.5, ly - 1.5), 1.5, highlightPaint);
      } else if (isBlossom) {
        // Draw blossoms (pink circles)
        canvas.drawCircle(Offset(lx, ly), 5.0, foliagePaint);
        // Blossom center (yellow dot)
        final centerPaint = Paint()
          ..color = const Color(0xFFFFEE58)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(lx, ly), 1.5, centerPaint);
      } else {
        // Draw standard green leaves
        canvas.drawCircle(Offset(lx, ly), 6.5, foliagePaint);
      }
    }
  }

  void _drawCrossOnTrunk(Canvas canvas, double cx, double cy, double thickness) {
    final crossPaint = Paint()
      ..color = const Color(0xFFFFD700).withValues(alpha: 0.8) // Golden glow cross
      ..strokeWidth = max(2.5, thickness * 0.25)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Vertical line
    canvas.drawLine(Offset(cx, cy - 10), Offset(cx, cy + 10), crossPaint);
    // Horizontal line
    canvas.drawLine(Offset(cx - 6, cy - 4), Offset(cx + 6, cy - 4), crossPaint);
  }

  void _drawGoldenLeaf(Canvas canvas, Offset pos) {
    final goldPaint = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(pos.dx, pos.dy - 8)
      ..quadraticBezierTo(pos.dx + 6, pos.dy - 4, pos.dx, pos.dy + 8)
      ..quadraticBezierTo(pos.dx - 6, pos.dy - 4, pos.dx, pos.dy - 8)
      ..close();

    canvas.drawPath(path, goldPaint);

    // Draw little sparkles/star effects
    final sparklePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(pos.dx - 10, pos.dy), Offset(pos.dx + 10, pos.dy), sparklePaint);
    canvas.drawLine(Offset(pos.dx, pos.dy - 10), Offset(pos.dx, pos.dy + 10), sparklePaint);
  }

  void _drawDove(Canvas canvas, Offset pos) {
    final dovePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.fill;

    // Simple geometric representation of a dove flying (wings + body + tail)
    final path = Path()
      ..moveTo(pos.dx, pos.dy) // beak/head
      ..quadraticBezierTo(pos.dx + 8, pos.dy - 6, pos.dx + 16, pos.dy - 2) // body
      ..lineTo(pos.dx + 22, pos.dy - 8) // tail top
      ..lineTo(pos.dx + 20, pos.dy + 2) // tail bottom
      ..quadraticBezierTo(pos.dx + 12, pos.dy + 6, pos.dx + 6, pos.dy + 4) // belly
      ..quadraticBezierTo(pos.dx + 4, pos.dy - 10, pos.dx - 2, pos.dy - 12) // left wing top
      ..quadraticBezierTo(pos.dx + 5, pos.dy - 4, pos.dx + 6, pos.dy) // left wing back
      ..close();

    canvas.drawPath(path, dovePaint);
  }

  void _drawHalo(Canvas canvas, Size size) {
    final haloPaint = Paint()
      ..color = const Color(0xFFFFEE58).withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0;

    final shadowPaint = Paint()
      ..color = const Color(0xFFFFEE58).withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20.0;

    final center = Offset(size.width / 2, size.height * 0.45);
    canvas.drawCircle(center, 90.0, shadowPaint);
    canvas.drawCircle(center, 90.0, haloPaint);
  }

  void _drawRainbow(Canvas canvas, Size size) {
    final colors = [
      Colors.red.withValues(alpha: 0.08),
      Colors.orange.withValues(alpha: 0.08),
      Colors.yellow.withValues(alpha: 0.08),
      Colors.green.withValues(alpha: 0.08),
      Colors.blue.withValues(alpha: 0.08),
      Colors.indigo.withValues(alpha: 0.08),
      Colors.purple.withValues(alpha: 0.08),
    ];

    final center = Offset(size.width / 2, size.height - 25.0);
    double radius = 170.0;

    for (final color in colors) {
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6.0;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        pi,
        pi,
        false,
        paint,
      );
      radius += 6.0;
    }
  }

  @override
  bool shouldRepaint(covariant WisdomTreePainter oldDelegate) {
    return oldDelegate.growthStage != growthStage ||
        oldDelegate.branchScores != branchScores ||
        oldDelegate.milestones != milestones ||
        oldDelegate.isDark != isDark;
  }
}

class _BranchData {
  final String name;
  final double heightFraction;
  final double angleDeg;

  _BranchData({
    required this.name,
    required this.heightFraction,
    required this.angleDeg,
  });
}

// Simple deterministic random generator based on a seed
class _DeterministicRandom {
  int seed;
  _DeterministicRandom(this.seed);
  double nextDouble() {
    seed = (seed * 1103515245 + 12345) & 0x7fffffff;
    return seed / 2147483647.0;
  }
}
