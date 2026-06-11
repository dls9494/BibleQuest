import 'package:flutter/material.dart';
import 'bible_screen.dart';
import 'package:provider/provider.dart';
import '../models/reading_plan.dart';
import '../providers/reading_plan_provider.dart';
import '../providers/user_data_provider.dart';
import '../services/reading_plan_data.dart';
import '../services/bible_service.dart';
import '../services/reading_quiz_questions.dart';
import '../widgets/bilingual_text.dart';

class ReadingPlanScreen extends StatefulWidget {
  const ReadingPlanScreen({super.key});

  @override
  State<ReadingPlanScreen> createState() => _ReadingPlanScreenState();
}

class _ReadingPlanScreenState extends State<ReadingPlanScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserDataProvider>(context, listen: false);
      if (userProvider.userId != null) {
        Provider.of<ReadingPlanProvider>(context, listen: false)
            .loadCurrentPlan(userProvider.userId!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final planProvider = Provider.of<ReadingPlanProvider>(context);
    final userProvider = Provider.of<UserDataProvider>(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFFDF6EC),
      appBar: AppBar(
        backgroundColor: isDark ? Colors.transparent : const Color(0xFFFDF6EC),
        elevation: 0,
        title: const Text(
          "Bible Reading Plans",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Outfit',
          ),
        ),
        actions: [
          if (planProvider.currentPlan != null)
            IconButton(
              icon: Icon(
                Icons.refresh,
                color: isDark ? Colors.white70 : const Color(0xFF3E2723),
              ),
              tooltip: "Reset / Change Plan",
              onPressed: () => _showResetConfirmation(context, planProvider, userProvider),
            ),
        ],
      ),
      body: planProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : planProvider.currentPlan == null
              ? _buildEnrollmentView(context, planProvider, userProvider)
              : _buildActivePlanDashboard(context, planProvider, userProvider),
    );
  }

  // --- 1. Enrollment Dashboard ---
  Widget _buildEnrollmentView(
    BuildContext context,
    ReadingPlanProvider planProvider,
    UserDataProvider userProvider,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView(
      padding: const EdgeInsets.all(20.0),
      children: [
        const SizedBox(height: 10),
        Icon(
          Icons.menu_book_rounded,
          size: 72,
          color: isDark ? const Color(0xFFBB86FC) : const Color(0xFF6C4AB6),
        ),
        const SizedBox(height: 16),
        const Text(
          "Choose Your Reading Plan",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Outfit',
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          "Spend time in God's Word daily, test your retention, and earn bonus XP!",
          style: TextStyle(
            fontSize: 15,
            color: isDark ? Colors.white70 : const Color(0xFF5D4037),
            fontFamily: 'Outfit',
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        _buildPlanEnrollmentCard(
          context,
          planType: '30_day',
          titleEn: "30-Day Bible Overview",
          titleTe: "30 రోజుల బైబిల్ అవలోకనం",
          desc: "Read foundational passages from Genesis to Revelation. Perfect for getting started.",
          duration: "30 Days",
          color: const Color(0xFF6C4AB6),
          planProvider: planProvider,
          userProvider: userProvider,
        ),
        const SizedBox(height: 20),
        _buildPlanEnrollmentCard(
          context,
          planType: '90_day',
          titleEn: "90-Day New Testament",
          titleTe: "90 రోజుల నూతన నిబంధన",
          desc: "Go deeper with a complete reading of the New Testament (Matthew to Revelation).",
          duration: "90 Days",
          color: const Color(0xFF00B4D8),
          planProvider: planProvider,
          userProvider: userProvider,
        ),
        const SizedBox(height: 20),
        _buildPlanEnrollmentCard(
          context,
          planType: '365_day',
          titleEn: "365-Day Whole Bible",
          titleTe: "365 రోజుల సంపూర్ణ బైబిల్",
          desc: "A comprehensive daily journey through the Old and New Testaments in one year.",
          duration: "365 Days",
          color: const Color(0xFF2A9D8F),
          planProvider: planProvider,
          userProvider: userProvider,
        ),
      ],
    );
  }

  Widget _buildPlanEnrollmentCard(
    BuildContext context, {
    required String planType,
    required String titleEn,
    required String titleTe,
    required String desc,
    required String duration,
    required Color color,
    required ReadingPlanProvider planProvider,
    required UserDataProvider userProvider,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _confirmEnrollment(context, planType, titleEn, planProvider, userProvider),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BilingualText(
                          englishText: titleEn,
                          teluguText: titleTe,
                          englishStyle: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF3E2723),
                            fontFamily: 'Outfit',
                          ),
                          teluguStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3E2723),
                            fontFamily: 'Outfit',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: color.withValues(alpha: 0.5)),
                    ),
                    child: Text(
                      duration,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                desc,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white60 : const Color(0xFF5D4037),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 18),
                      const SizedBox(width: 4),
                      Text(
                        "+10 XP/read",
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white70 : const Color(0xFF5D4037),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.quiz_rounded, color: Colors.orangeAccent, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        "+25 XP/quiz",
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white70 : const Color(0xFF5D4037),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: isDark ? Colors.white54 : const Color(0xFF3E2723),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmEnrollment(
    BuildContext context,
    String planType,
    String planName,
    ReadingPlanProvider planProvider,
    UserDataProvider userProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Enroll in Plan"),
          content: Text("Are you sure you want to start the $planName? Your progress on any current reading plan will be reset."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                if (userProvider.userId != null) {
                  await planProvider.startPlan(userProvider.userId!, planType, userProvider);
                }
              },
              child: Text("Start"),
            ),
          ],
        );
      },
    );
  }

  // --- 2. Active Plan Dashboard ---
  Widget _buildActivePlanDashboard(
    BuildContext context,
    ReadingPlanProvider planProvider,
    UserDataProvider userProvider,
  ) {
    final plan = planProvider.currentPlan!;
    final planDays = ReadingPlanData.getPlanDays(plan.planType);
    
    // Safety check in case index out of bounds
    final currentDayIndex = (plan.currentDay - 1).clamp(0, planDays.length - 1);
    final todayReading = planDays.isNotEmpty ? planDays[currentDayIndex] : null;

    final completedCount = plan.completedDays.length;
    final totalDays = planDays.length;
    final progressPercent = totalDays > 0 ? (completedCount / totalDays) : 0.0;

    String displayPlanName = "";
    if (plan.planType == '30_day') {
      displayPlanName = "30-Day Bible Overview";
    } else if (plan.planType == '90_day') {
      displayPlanName = "90-Day New Testament";
    } else {
      displayPlanName = "365-Day Whole Bible";
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Plan Header Stats Card
          _buildStatsCard(context, plan, completedCount, totalDays, progressPercent, displayPlanName),
          const SizedBox(height: 20),

          // Today's Reading Card
          if (todayReading != null)
            _buildTodayReadingCard(context, planProvider, userProvider, plan, todayReading),

          const SizedBox(height: 25),
          const Text(
            "Plan Journey",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Outfit',
            ),
          ),
          const SizedBox(height: 10),

          // Reading Grid / History
          _buildReadingHistoryGrid(context, plan, planDays),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildStatsCard(
    BuildContext context,
    ReadingPlan plan,
    int completed,
    int total,
    double percent,
    String planName,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        planName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white70 : const Color(0xFF5D4037),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Day $completed of $total completed",
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white54 : const Color(0xFF7D5C50),
                        ),
                      ),
                    ],
                  ),
                ),
                // Streak badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.local_fire_department_rounded, color: Colors.orange, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        "${plan.streak} d streak",
                        style: const TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: percent,
                      minHeight: 10,
                      backgroundColor: isDark ? Colors.white10 : Colors.grey.shade200,
                      color: isDark ? const Color(0xFFBB86FC) : const Color(0xFF6C4AB6),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "${(percent * 100).toInt()}%",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white70 : const Color(0xFF3E2723),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayReadingCard(
    BuildContext context,
    ReadingPlanProvider planProvider,
    UserDataProvider userProvider,
    ReadingPlan plan,
    ReadingDay day,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRead = plan.completedDays.contains(day.day);
    final isQuizDone = plan.quizDaysCompleted.contains(day.day);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isRead ? Colors.green.withValues(alpha: 0.4) : const Color(0xFFFFD700).withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openBibleFromReference(day.versesEn, userProvider),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isRead ? Colors.green.withValues(alpha: 0.15) : const Color(0xFFFFD700).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isRead ? Icons.check_circle_rounded : Icons.star_rounded,
                      color: isRead ? Colors.green : const Color(0xFFFFD700),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Today's Reading (Day ${day.day}) • 📖 Tap to read",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white60 : const Color(0xFF7D5C50),
                          ),
                        ),
                        const SizedBox(height: 2),
                        BilingualText(
                          englishText: day.titleEn,
                          teluguText: day.titleTe,
                          englishStyle: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : const Color(0xFF3E2723),
                          ),
                          teluguStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3E2723),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24, thickness: 1),
              const Text(
                "Summary / సారాంశం",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              const SizedBox(height: 6),
              BilingualText(
                englishText: day.summaryEn,
                teluguText: day.summaryTe,
                englishStyle: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white70 : const Color(0xFF5D4037),
                  height: 1.4,
                ),
                teluguStyle: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF5D4037),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              
              // Action Row
              if (!isRead)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      if (userProvider.userId != null) {
                        await planProvider.markDayRead(userProvider.userId!, day.day, userProvider);
                      }
                    },
                    icon: const Icon(Icons.check_circle_outline_rounded),
                    label: const Text(
                      "Mark as Read (+10 XP)",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2A9D8F),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                )
              else ...[
                // Reading completed indicator
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.done_all_rounded, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(
                        "Reading Completed! (+10 XP)",
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                
                // Daily Quiz section
                if (!isQuizDone)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _launchReadingQuiz(context, plan.planType, day.day, day.versesEn, planProvider, userProvider),
                      icon: const Icon(Icons.quiz_rounded),
                      label: const Text(
                        "Take Daily Quiz (+25 XP)",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF9F1C),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.celebration_rounded, color: Colors.amber),
                        const SizedBox(width: 8),
                        Text(
                          "Quiz Completed! (+25 XP awarded)",
                          style: TextStyle(
                            color: isDark ? Colors.amber : Colors.amber.shade800,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadingHistoryGrid(
    BuildContext context,
    ReadingPlan plan,
    List<ReadingDay> planDays,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userProvider = Provider.of<UserDataProvider>(context, listen: false);
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: planDays.length,
      itemBuilder: (context, index) {
        final dayNum = index + 1;
        final isCompleted = plan.completedDays.contains(dayNum);
        final isCurrent = plan.currentDay == dayNum;
        final isLocked = dayNum > plan.currentDay;

        Color itemBg;
        Color borderCol = Colors.transparent;
        Widget content;

        if (isCompleted) {
          itemBg = Colors.green.withValues(alpha: isDark ? 0.25 : 0.15);
          borderCol = Colors.green;
          content = Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "$dayNum",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const Icon(Icons.check_circle_rounded, color: Colors.green, size: 14),
            ],
          );
        } else if (isCurrent) {
          itemBg = const Color(0xFFFFD700).withValues(alpha: isDark ? 0.25 : 0.15);
          borderCol = const Color(0xFFFFD700);
          content = Stack(
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "$dayNum",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const Text("Today", style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          );
        } else {
          itemBg = isDark ? Colors.white.withValues(alpha: 0.03) : Colors.grey.shade300.withValues(alpha: 0.5);
          content = Center(
            child: Text(
              "$dayNum",
              style: TextStyle(
                color: isLocked ? Colors.grey : (isDark ? Colors.white70 : const Color(0xFF3E2723)),
                fontSize: 13,
              ),
            ),
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: itemBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderCol, width: 2),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: isLocked ? null : () => _openBibleFromReference(planDays[index].versesEn, userProvider),
            child: content,
          ),
        );
      },
    );
  }

  void _openBibleFromReference(String reference, UserDataProvider userProvider) {
    final firstPart = reference.split(RegExp(r'[,;]'))[0].trim();
    final ref = BibleService.parseReadingRef(firstPart);
    if (ref != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BibleScreen(
            initialBook: ref.bookId,
            initialChapter: ref.chapter,
          ),
        ),
      );
    }
  }

  void _showResetConfirmation(
    BuildContext context,
    ReadingPlanProvider planProvider,
    UserDataProvider userProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Reset Plan"),
          content: const Text(
            "Are you sure you want to reset your active reading plan? This will clear your current day progression on this plan. Achievements already unlocked will remain.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                if (userProvider.userId != null) {
                  await planProvider.resetPlan(userProvider.userId!, userProvider);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Reset Plan"),
            ),
          ],
        );
      },
    );
  }

  // --- 3. Kahoot-style Quiz Dialog ---
  void _launchReadingQuiz(
    BuildContext context,
    String planType,
    int day,
    String versesInfo,
    ReadingPlanProvider planProvider,
    UserDataProvider userProvider,
  ) {
    final questions = ReadingQuizQuestions.getQuestions(planType, day, versesInfo: versesInfo);
    if (questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No questions found for this day.")),
      );
      return;
    }

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      pageBuilder: (context, anim1, anim2) {
        return ReadingQuizView(
          questions: questions,
          onComplete: () async {
            if (userProvider.userId != null) {
              await planProvider.completeQuizForDay(userProvider.userId!, day, userProvider);
            }
          },
        );
      },
    );
  }
}

// --- Quiz Play View Widget ---
class ReadingQuizView extends StatefulWidget {
  final List<ReadingQuestion> questions;
  final VoidCallback onComplete;

  const ReadingQuizView({
    super.key,
    required this.questions,
    required this.onComplete,
  });

  @override
  State<ReadingQuizView> createState() => _ReadingQuizViewState();
}

class _ReadingQuizViewState extends State<ReadingQuizView> {
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

  final List<IconData> _optionIcons = [
    Icons.warning_amber_rounded, // Triangle placeholder representation
    Icons.diamond_outlined, // Diamond
    Icons.circle_outlined, // Circle
    Icons.crop_square_outlined, // Square
  ];

  void _handleOptionSelect(int index) {
    if (_hasAnswered) return;
    final userProvider = context.read<UserDataProvider>();
    final q = widget.questions[_currentIndex];
    final isCorrect = index == q.correctAnswerIndex;
    final bookId = userProvider.extractBookIdFromReference(q.verseReference);
    if (bookId != null) {
      userProvider.updateTopicPerformance(bookId, isCorrect ? 1.0 : 0.0);
    }

    setState(() {
      _selectedAnswerIndex = index;
      _hasAnswered = true;
      if (isCorrect) {
        _score++;
      }
    });

    // Auto-advance after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      if (_currentIndex < widget.questions.length - 1) {
        setState(() {
          _currentIndex++;
          _selectedAnswerIndex = null;
          _hasAnswered = false;
        });
      } else {
        // Complete the quiz
        widget.onComplete();
        setState(() {
          _currentIndex = widget.questions.length; // triggers summary state
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Summary screen
    if (_currentIndex >= widget.questions.length) {
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
                  "You scored $_score out of ${widget.questions.length}",
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

    final question = widget.questions[_currentIndex];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFFDF6EC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Question ${_currentIndex + 1} of ${widget.questions.length}",
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
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    final isSelected = _selectedAnswerIndex == index;
                    final isCorrect = question.correctAnswerIndex == index;
                    
                    Color btnColor = _optionColors[index];
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
                      elevation: _hasAnswered ? 1 : 4,
                      color: btnColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: border,
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => _handleOptionSelect(index),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(_optionIcons[index], color: Colors.white.withValues(alpha: 0.8), size: 24),
                              const SizedBox(height: 8),
                              Expanded(
                                child: Center(
                                  child: SingleChildScrollView(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          question.optionsTe[index],
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          question.optionsEn[index],
                                          style: TextStyle(
                                            color: Colors.white.withValues(alpha: 0.8),
                                            fontSize: 10,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
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

  void _confirmExit(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Exit Quiz?"),
          content: const Text("If you exit now, your current score won't be saved and you won't receive the XP bonus."),
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
              child: const Text("Exit"),
            ),
          ],
        );
      },
    );
  }
}
