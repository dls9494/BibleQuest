import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class QuizResultShare extends StatelessWidget {
  final String title;
  final int score;
  final int totalQuestions;
  final int xpEarned;
  final int percentage;

  const QuizResultShare({
    super.key,
    required this.title,
    required this.score,
    required this.totalQuestions,
    required this.xpEarned,
    required this.percentage,
  });

  static Future<void> shareResult({
    required BuildContext context,
    required String title,
    required int score,
    required int totalQuestions,
    required int xpEarned,
    required int percentage,
    required VoidCallback onShareSuccess,
  }) async {
    final GlobalKey boundaryKey = GlobalKey();

    // Show dialog with the share card briefly
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        // We will capture it automatically after layout
        Future.delayed(const Duration(milliseconds: 600), () async {
          try {
            RenderRepaintBoundary? boundary = boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
            if (boundary != null) {
              ui.Image image = await boundary.toImage(pixelRatio: 3.0);
              ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
              if (byteData != null) {
                final Uint8List pngBytes = byteData.buffer.asUint8List();
                final tempDir = await getTemporaryDirectory();
                final file = await File('${tempDir.path}/quiz_result_${DateTime.now().millisecondsSinceEpoch}.png').create();
                await file.writeAsBytes(pngBytes);
                
                // Close dialog
                if (dialogContext.mounted && Navigator.canPop(dialogContext)) {
                  Navigator.pop(dialogContext);
                }

                // Share
                await SharePlus.instance.share(
                  ShareParams(
                    text: 'I scored $score/$totalQuestions on "$title" in the Telugu Bible Quiz! Can you beat my score? 🏆',
                    files: [XFile(file.path)],
                  ),
                );

                onShareSuccess();
              }
            } else {
              if (dialogContext.mounted && Navigator.canPop(dialogContext)) {
                Navigator.pop(dialogContext);
              }
            }
          } catch (e) {
            // ignore: avoid_print
            print("Error sharing: $e");
            if (dialogContext.mounted && Navigator.canPop(dialogContext)) {
              Navigator.pop(dialogContext);
            }
          }
        });

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Repaint boundary wraps the card
              RepaintBoundary(
                key: boundaryKey,
                child: QuizResultShare(
                  title: title,
                  score: score,
                  totalQuestions: totalQuestions,
                  xpEarned: xpEarned,
                  percentage: percentage,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Preparing share card...",
                style: TextStyle(color: Colors.white70, fontSize: 14, fontFamily: 'Outfit'),
              ),
              const SizedBox(height: 8),
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    int starsCount = 0;
    if (percentage >= 90) {
      starsCount = 3;
    } else if (percentage >= 70) {
      starsCount = 2;
    } else if (percentage >= 40) {
      starsCount = 1;
    }

    return Container(
      width: 340,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F2027),
            Color(0xFF203A43),
            Color(0xFF2C5364),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFFFD700).withAlpha(128),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(100),
            blurRadius: 15,
            spreadRadius: 2,
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Branding Header
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "✝",
                style: TextStyle(
                  color: Color(0xFFFFD700),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "Telugu Bible Quiz",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Outfit',
                  shadows: [
                    Shadow(
                      color: Colors.white.withAlpha(76),
                      blurRadius: 5,
                    )
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Separator line
          Container(
            height: 1.5,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.white.withAlpha(128),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Quiz Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF38BDF8),
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Outfit',
            ),
          ),
          const SizedBox(height: 16),
          // Score badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(20),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withAlpha(38),
              ),
            ),
            child: Column(
              children: [
                Text(
                  "$score / $totalQuestions",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Outfit',
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Correct Answers",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontFamily: 'Outfit',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Stars
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (i) {
              final hasStar = i < starsCount;
              return Icon(
                Icons.star,
                size: 44,
                color: hasStar ? const Color(0xFFFFD700) : Colors.white.withAlpha(38),
                shadows: hasStar
                    ? [
                        const Shadow(
                          color: Color(0xFFFFD700),
                          blurRadius: 10,
                        )
                      ]
                    : null,
              );
            }),
          ),
          const SizedBox(height: 20),
          // XP Earned
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF4ADE80).withAlpha(25),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF4ADE80).withAlpha(76),
              ),
            ),
            child: Text(
              "+$xpEarned XP",
              style: const TextStyle(
                color: Color(0xFF4ADE80),
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Outfit',
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Message
          const Text(
            "Can you beat my score? 🏆",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFFFD700),
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Outfit',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Play now!",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white54,
              fontSize: 12,
              fontFamily: 'Outfit',
            ),
          ),
        ],
      ),
    );
  }
}
