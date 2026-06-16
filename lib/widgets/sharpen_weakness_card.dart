import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_data_provider.dart';
import '../models/quiz.dart';
import '../screens/self_paced_screen.dart';

class SharpenWeaknessCard extends StatefulWidget {
  const SharpenWeaknessCard({super.key});

  @override
  State<SharpenWeaknessCard> createState() => _SharpenWeaknessCardState();
}

class _SharpenWeaknessCardState extends State<SharpenWeaknessCard> {
  bool _loading = false;

  void _startWeaknessQuiz(BuildContext context, UserDataProvider provider, String topic) async {
    setState(() {
      _loading = true;
    });

    try {
      final questions = await provider.generateWeaknessQuiz(topic);
      if (!mounted) return;

      final quiz = Quiz(
        id: 'weakness_quiz_${topic.replaceAll(' ', '_')}',
        creatorId: 'system',
        titleKey: 'weakness_quiz',
        titleEn: 'Sharpen Weakness: $topic',
        titleTe: 'బలహీనతను సరిచేసుకోండి: $topic',
        descriptionEn: 'Practice 5 questions to strengthen your knowledge in $topic!',
        descriptionTe: '$topic లో మీ జ్ఞానాన్ని బలోపేతం చేయడానికి 5 ప్రశ్నలను సాధన చేయండి!',
        difficulty: 'medium',
        topics: [topic],
        bibleVersion: 'BSI Telugu',
        isPublic: true,
        level: 1,
        questionCount: 5,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (!mounted) return;
      Navigator.push(
        this.context,
        MaterialPageRoute(
          builder: (ctx) => SelfPacedScreen(
            quiz: quiz,
            questions: questions,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(this.context).showSnackBar(
          SnackBar(content: Text('Error generating weakness quiz: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final topic = context.select<UserDataProvider, String?>((p) => p.getWeakestTopic());
    final isCompleted = context.select<UserDataProvider, bool>((p) => p.weaknessQuizCompleted);

    if (topic == null || isCompleted) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF3E2723);
    final subTextColor = isDark ? Colors.white.withValues(alpha: 0.7) : const Color(0xFF5D4037);

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: isDark ? 12.0 : 0, sigmaY: isDark ? 12.0 : 0),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.amber.withValues(alpha: 0.6), // Amber border for weakness card
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.gps_fixed_rounded,
                        color: Colors.amber,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Sharpen Your Knowledge",
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Outfit',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Topic focus: $topic",
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Outfit',
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "You've had some trouble with this topic recently. Review 5 quick questions to boost your mastery!",
                    style: TextStyle(
                      color: subTextColor,
                      fontSize: 13,
                      height: 1.4,
                      fontFamily: 'Outfit',
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loading ? null : () => _startWeaknessQuiz(context, context.read<UserDataProvider>(), topic),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            "Start 5 Quick Questions (+30 XP)",
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
