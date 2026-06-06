import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/this_day_data.dart';
import '../providers/user_data_provider.dart';

class ThisDayCard extends StatelessWidget {
  const ThisDayCard({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserDataProvider>(context);
    final event = ThisDayDataService.getTodayEvent();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final textColor = isDark ? Colors.white : const Color(0xFF3E2723);
    final subTextColor = isDark ? Colors.white.withValues(alpha: 0.7) : const Color(0xFF5D4037);
    final isCompleted = userProvider.thisDayQuizCompleted;

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
                color: const Color(0xFF7B1FA2).withValues(alpha: 0.5), // Deep purple border
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
                  // Header
                  Row(
                    children: [
                      const Text(
                        "📅 ",
                        style: TextStyle(fontSize: 18),
                      ),
                      Expanded(
                        child: Text(
                          "On this day in the Bible...",
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Outfit',
                          ),
                        ),
                      ),
                      if (isCompleted)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.withValues(alpha: 0.5)),
                          ),
                          child: const Text(
                            "Completed",
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Outfit',
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Title
                  Text(
                    event.titleTe,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'NotoSerifTelugu',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.titleEn,
                    style: TextStyle(
                      color: textColor.withValues(alpha: 0.8),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'NotoSerif',
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Description
                  Text(
                    event.descriptionTe,
                    style: TextStyle(
                      color: subTextColor,
                      fontSize: 14,
                      height: 1.5,
                      fontFamily: 'NotoSerifTelugu',
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    event.descriptionEn,
                    style: TextStyle(
                      color: subTextColor.withValues(alpha: 0.8),
                      fontSize: 13,
                      height: 1.4,
                      fontFamily: 'NotoSerif',
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Verse Reference
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "${event.verseReferenceTe} / ${event.verseReferenceEn}",
                      style: const TextStyle(
                        color: Color(0xFF7B1FA2),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Outfit',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Action Button
                  ElevatedButton(
                    onPressed: isCompleted
                        ? null
                        : () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ThisDayQuizView(
                                  event: event,
                                  onComplete: () {
                                    userProvider.completeThisDayQuiz();
                                  },
                                ),
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A148C), // Deep Purple
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade800,
                      disabledForegroundColor: Colors.white38,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      isCompleted ? "Quiz Completed (+25 XP Claimed)" : "Take Quiz (+25 XP)",
                      style: const TextStyle(
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

class ThisDayQuizView extends StatefulWidget {
  final BibleEvent event;
  final VoidCallback onComplete;

  const ThisDayQuizView({
    super.key,
    required this.event,
    required this.onComplete,
  });

  @override
  State<ThisDayQuizView> createState() => _ThisDayQuizViewState();
}

class _ThisDayQuizViewState extends State<ThisDayQuizView> {
  int _currentIndex = 0;
  int _score = 0;
  int? _selectedAnswerIndex;
  bool _hasAnswered = false;

  final List<Color> _optionColors = [
    const Color(0xFFE21B3C), // Red
    const Color(0xFF1368CE), // Blue
    const Color(0xFFD89E00), // Yellow
    const Color(0xFF26890C), // Green
  ];

  void _handleOptionSelect(int index, List<ThisDayOption> options) {
    if (_hasAnswered) return;
    setState(() {
      _selectedAnswerIndex = index;
      _hasAnswered = true;
      if (options[index].isCorrect) {
        _score++;
      }
    });

    // Auto-advance after 1.5 seconds
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      if (_currentIndex < widget.event.quizQuestions.length - 1) {
        setState(() {
          _currentIndex++;
          _selectedAnswerIndex = null;
          _hasAnswered = false;
        });
      } else {
        // Complete the quiz
        widget.onComplete();
        setState(() {
          _currentIndex = widget.event.quizQuestions.length; // Summary state
        });
      }
    });
  }

  void _confirmExit(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Exit Quiz?", style: TextStyle(fontFamily: 'Outfit')),
        content: const Text("You will lose your progress for this quiz."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // pop dialog
              Navigator.of(context).pop(); // pop quiz
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Exit"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final questions = widget.event.quizQuestions;

    // Summary screen
    if (_currentIndex >= questions.length) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFFDF6EC),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.celebration_rounded, size: 80, color: Color(0xFFFFD700)),
                const SizedBox(height: 20),
                const Text(
                  "Quiz Complete!",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
                ),
                const SizedBox(height: 10),
                Text(
                  "You scored $_score out of ${questions.length}",
                  style: TextStyle(fontSize: 18, color: isDark ? Colors.white70 : const Color(0xFF5D4037)),
                ),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bolt, color: Colors.amber, size: 24),
                      SizedBox(width: 8),
                      Text(
                        "Earned +25 XP Bonus!",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.amber),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2A9D8F),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Finish", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final question = questions[_currentIndex];
    final options = question.options;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFFDF6EC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Question ${_currentIndex + 1} of ${questions.length}",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _confirmExit(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Question Card
              Expanded(
                flex: 4,
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              question.questionTe,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : const Color(0xFF3E2723),
                                height: 1.4,
                                fontFamily: 'NotoSerifTelugu',
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              question.questionEn,
                              style: TextStyle(
                                fontSize: 15,
                                color: isDark ? Colors.white60 : const Color(0xFF5D4037),
                                height: 1.4,
                                fontFamily: 'NotoSerif',
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Kahoot-style options grid
              Expanded(
                flex: 6,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.25,
                  ),
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final option = options[index];
                    final isSelected = _selectedAnswerIndex == index;
                    final isCorrect = option.isCorrect;
                    
                    Color btnColor = _optionColors[index % _optionColors.length];
                    BorderSide border = BorderSide.none;

                    if (_hasAnswered) {
                      if (isCorrect) {
                        btnColor = const Color(0xFF26890C); // green
                        border = const BorderSide(color: Colors.white, width: 3);
                      } else if (isSelected) {
                        btnColor = const Color(0xFFE21B3C); // red
                      } else {
                        btnColor = btnColor.withValues(alpha: 0.2); // faded out
                      }
                    }

                    return Card(
                      color: btnColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: border,
                      ),
                      elevation: isSelected ? 8 : 2,
                      child: InkWell(
                        onTap: () => _handleOptionSelect(index, options),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Center(
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    option.textTe,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'NotoSerifTelugu',
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    option.textEn,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                      fontFamily: 'NotoSerif',
                                      fontStyle: FontStyle.italic,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
