import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/quiz.dart';
import '../providers/locale_provider.dart';
import '../providers/user_data_provider.dart';
import '../services/firebase_service.dart';
import 'self_paced_screen.dart';
import 'battle_screen.dart';

class ChallengesScreen extends StatefulWidget {
  const ChallengesScreen({super.key});

  @override
  State<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends State<ChallengesScreen> {
  Timer? _countdownTimer;
  Quiz? _weeklyQuiz;
  Quiz? _monthlyQuiz;
  bool _loadingWeekly = true;
  bool _loadingMonthly = true;
  int? _dailyQuizLevel;

  @override
  void initState() {
    super.initState();
    _loadQuizzes();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final userProvider = Provider.of<UserDataProvider>(context, listen: false);
        setState(() {
          _dailyQuizLevel = userProvider.getDailyQuizLevel();
        });
      }
    });
  }

  void _loadQuizzes() async {
    _loadWeeklyQuiz();
    _loadMonthlyQuiz();
  }

  Future<void> _loadWeeklyQuiz() async {
    try {
      final quiz = await FirebaseService.getOrCreateWeeklyQuiz();
      if (mounted) {
        setState(() {
          _weeklyQuiz = quiz;
          _loadingWeekly = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loadingWeekly = false);
      }
    }
  }

  Future<void> _loadMonthlyQuiz() async {
    try {
      final quiz = await FirebaseService.getOrCreateMonthlyQuiz();
      if (mounted) {
        setState(() {
          _monthlyQuiz = quiz;
          _loadingMonthly = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loadingMonthly = false);
      }
    }
  }

  void _startTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  Duration _getDailyTimeRemaining() {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    return midnight.difference(now);
  }

  String _formatDailyTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  String _getWeeklyRemaining() {
    final now = DateTime.now();
    int daysFromSaturday = now.weekday - DateTime.saturday;
    if (daysFromSaturday < 0) {
      daysFromSaturday += 7;
    }
    DateTime lastSaturday8PM = DateTime(now.year, now.month, now.day, 20, 0, 0).subtract(Duration(days: daysFromSaturday));
    if (lastSaturday8PM.isAfter(now)) {
      lastSaturday8PM = lastSaturday8PM.subtract(const Duration(days: 7));
    }
    final nextSaturday8PM = lastSaturday8PM.add(const Duration(days: 7));
    final diff = nextSaturday8PM.difference(now);
    final days = diff.inDays;
    final hours = diff.inHours % 24;
    final minutes = diff.inMinutes % 60;
    final seconds = diff.inSeconds % 60;

    String twoDigits(int n) => n.toString().padLeft(2, '0');
    if (days == 0) {
      return "Time left: ${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}";
    }
    return "Time left: $days d, ${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}";
  }

  String _getMonthlyRemaining() {
    final now = DateTime.now();
    final nextMonth = now.month == 12 ? DateTime(now.year + 1, 1, 1) : DateTime(now.year, now.month + 1, 1);
    final diff = nextMonth.difference(now);
    final days = diff.inDays;
    final hours = diff.inHours % 24;
    if (days == 0) {
      return "$hours hours remaining";
    }
    return "$days days, $hours hours remaining";
  }

  void _startDailyChallenge(UserDataProvider userProvider) {
    if (userProvider.dailyChallengeCompleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Daily challenge already completed today!', style: TextStyle(fontFamily: 'Outfit'))),
      );
      return;
    }

    final level = _dailyQuizLevel ?? userProvider.dailyQuizLevel ?? userProvider.getDailyQuizLevel();
    final dailyQuiz = Quiz(
      id: 'daily',
      creatorId: 'system',
      titleKey: 'daily_challenge',
      bibleVersion: 'BSI Telugu',
      topics: const ['Daily Challenge'],
      isPublic: false,
      questionCount: 12,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      titleEn: 'Daily Challenge: Level $level Quiz',
      titleTe: 'రోజువారీ సవాలు: స్థాయి $level క్విజ్',
      descriptionEn: 'Complete this quiz to earn Double XP and keep your streak!',
      descriptionTe: 'డబుల్ XP సంపాదించడానికి మరియు మీ స్ట్రీక్‌ను ఉంచడానికి ఈ క్విజ్ పూర్తి చేయండి!',
      level: level,
      difficulty: level <= 33 ? 'easy' : (level <= 66 ? 'medium' : 'hard'),
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SelfPacedScreen(
          quiz: dailyQuiz,
          isDailyChallenge: true,
        ),
      ),
    ).then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _playQuiz(Quiz quiz) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SelfPacedScreen(
          quiz: quiz,
        ),
      ),
    ).then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserDataProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF3E2723);

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? const [
                        Color(0xFF1A1A2E),
                        Color(0xFF0F3460),
                      ]
                    : const [
                        Color(0xFFFDF6EC),
                        Color(0xFFF3E7D8),
                      ],
              ),
            ),
          ),
          // Luminous background glow
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: Opacity(
                opacity: 0.1,
                child: Container(
                  width: 500,
                  height: 500,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF38BDF8) : const Color(0xFFD4A574).withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? const Color(0xFF38BDF8) : const Color(0xFFD4A574).withValues(alpha: 0.5),
                        blurRadius: 150,
                        spreadRadius: 100,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                  child: Text(
                    "Challenges",
                    style: TextStyle(
                      color: textColor,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Outfit',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 1. Daily Challenge Card
                        _buildChallengeCard(
                          title: "Daily Challenge",
                          icon: Icons.calendar_today,
                          accentColor: const Color(0xFFF7BC64), // Gold
                          subtitle: userProvider.dailyChallengeCompleted
                              ? localeProvider.getContentText(
                                  "Success! Today's challenge is completed. Return tomorrow!",
                                  "విజయం! నేటి సవాలు పూర్తయింది. రేపు తిరిగి రండి!",
                                )
                              : localeProvider.getContentText(
                                  "Test your knowledge with today's featured Level ${_dailyQuizLevel ?? userProvider.dailyQuizLevel ?? 1} verses.",
                                  "నేటి ప్రత్యేక స్థాయి ${_dailyQuizLevel ?? userProvider.dailyQuizLevel ?? 1} లేఖనాలతో మీ జ్ఞానాన్ని పరీక్షించుకోండి.",
                                ),
                          countdownText: userProvider.dailyChallengeCompleted
                              ? "Next reset in ${_formatDailyTime(_getDailyTimeRemaining())}"
                              : "Time left: ${_formatDailyTime(_getDailyTimeRemaining())}",
                          buttonText: userProvider.dailyChallengeCompleted ? "COMPLETED" : "PLAY NOW",
                          buttonColor: const Color(0xFF6B46C1), // Deep Purple
                          buttonTextColor: Colors.white,
                          onPlay: userProvider.dailyChallengeCompleted
                              ? null
                              : () => _startDailyChallenge(userProvider),
                          isLoading: false,
                        ),
                        const SizedBox(height: 20),

                        // 2. Weekly Challenge Card
                        _buildChallengeCard(
                          title: "Weekly Challenge",
                          icon: Icons.emoji_events,
                          accentColor: const Color(0xFF38BDF8), // Cyan/Blue
                          subtitle: userProvider.weeklyChallengeCompleted
                              ? localeProvider.getContentText(
                                  "Success! This week's challenge is completed. Return next week!",
                                  "విజయం! ఈ వారం సవాలు పూర్తయింది. వచ్చే వారం తిరిగి రండి!",
                                )
                              : (_weeklyQuiz == null
                                  ? ""
                                  : localeProvider.getContentText(
                                      "Compete in this week's special level ${_weeklyQuiz!.level} quiz to rank on the weekly leaderboard!",
                                      "వారపు లీడర్‌బోర్డ్‌లో స్థానం పొందడానికి ఈ వారం ప్రత్యేక స్థాయి ${_weeklyQuiz!.level} క్విజ్‌లో పోటీపడండి!",
                                    )),
                          countdownText: _getWeeklyRemaining(),
                          buttonText: userProvider.weeklyChallengeCompleted ? "COMPLETED" : "PLAY NOW",
                          buttonColor: const Color(0xFF0284C7),
                          buttonTextColor: Colors.white,
                          onPlay: (userProvider.weeklyChallengeCompleted || _weeklyQuiz == null)
                              ? null
                              : () => _playQuiz(_weeklyQuiz!),
                          isLoading: _loadingWeekly,
                          showLeaderboardButton: true,
                          onLeaderboardPressed: () => userProvider.setTabIndex(2),
                        ),
                        const SizedBox(height: 20),

                        // 3. Monthly Challenge Card
                        _buildChallengeCard(
                          title: "Monthly Challenge",
                          icon: Icons.workspace_premium,
                          accentColor: const Color(0xFFF59E0B), // Dark Gold/Orange Crown
                          subtitle: userProvider.monthlyChallengeCompleted
                              ? localeProvider.getContentText(
                                  "Success! This month's challenge is completed. Return next month!",
                                  "విజయం! ఈ నెల సవాలు పూర్తయింది. వచ్చే నెల తిరిగి రండి!",
                                )
                              : (_monthlyQuiz == null
                                  ? ""
                                  : localeProvider.getContentText(
                                      "🔥 100 Questions • 20,000 Max Points • 70% Very Hard!\nMaster this month's ultimate challenge to prove your Bible mastery!",
                                      "🔥 100 ప్రశ్నలు • 20,000 గరిష్ట పాయింట్లు • 70% చాలా కఠినం!\nమీ బైబిల్ నైపుణ్యాన్ని నిరూపించడానికి ఈ నెల అంతిమ సవాలులో నైపుణ్యం సాధించండి!",
                                    )),
                          countdownText: _getMonthlyRemaining(),
                          buttonText: userProvider.monthlyChallengeCompleted ? "COMPLETED" : "PLAY NOW",
                          buttonColor: const Color(0xFFF59E0B),
                          buttonTextColor: Colors.white,
                          onPlay: (userProvider.monthlyChallengeCompleted || _monthlyQuiz == null)
                              ? null
                              : () => _playQuiz(_monthlyQuiz!),
                          isLoading: _loadingMonthly,
                          showLeaderboardButton: true,
                          onLeaderboardPressed: () => userProvider.setTabIndex(2),
                        ),
                        const SizedBox(height: 20),

                        // 4. Battle a Friend Card
                        _buildBattleCard(),
                        const SizedBox(height: 80), // Padding for bottom nav
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeCard({
    required String title,
    required IconData icon,
    required Color accentColor,
    required String subtitle,
    required String countdownText,
    required String buttonText,
    required Color buttonColor,
    required Color buttonTextColor,
    required VoidCallback? onPlay,
    required bool isLoading,
    bool showLeaderboardButton = false,
    VoidCallback? onLeaderboardPressed,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF3E2723);
    final subTextColor = isDark ? const Color(0xFFCBC3D4) : const Color(0xFF5D4037);

    final displayAccentColor = isDark
        ? accentColor
        : (accentColor == const Color(0xFF38BDF8)
            ? const Color(0xFF0284C7)
            : (accentColor == const Color(0xFFF7BC64)
                ? const Color(0xFFB57C1E)
                : const Color(0xFFD97706)));

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: isDark ? 15 : 0, sigmaY: isDark ? 15 : 0),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.07) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? const Color(0xFFF7BC64).withValues(alpha: 0.4)
                  : const Color(0xFFD4A574).withValues(alpha: 0.4), // Gold border
              width: 1.5,
            ),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: displayAccentColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: displayAccentColor, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Outfit',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: CircularProgressIndicator(color: Color(0xFF38BDF8)),
                  ),
                )
              else ...[
                Text(
                  subtitle,
                  style: TextStyle(
                    color: subTextColor,
                    fontSize: 14,
                    fontFamily: 'Outfit',
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        countdownText,
                        style: TextStyle(
                          color: displayAccentColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Outfit',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      children: [
                        if (showLeaderboardButton && onLeaderboardPressed != null) ...[
                          IconButton(
                            onPressed: onLeaderboardPressed,
                            icon: Icon(Icons.leaderboard, color: isDark ? Colors.white70 : const Color(0xFF6C4AB6)),
                            tooltip: 'View Leaderboard',
                          ),
                          const SizedBox(width: 8),
                        ],
                        ElevatedButton(
                          onPressed: onPlay,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: onPlay == null
                                ? (isDark ? Colors.white24 : Colors.black12)
                                : buttonColor,
                            foregroundColor: buttonTextColor,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: onPlay == null ? 0 : 4,
                          ),
                          child: Text(
                            buttonText,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              fontFamily: 'Outfit',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBattleCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF3E2723);
    final subTextColor = isDark ? const Color(0xFFCBC3D4) : const Color(0xFF5D4037);
    const accentColor = Color(0xFFFF6B35);
    final displayAccentColor = isDark ? accentColor : const Color(0xFFD4440D);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: isDark ? 15 : 0, sigmaY: isDark ? 15 : 0),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.07) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? accentColor.withValues(alpha: 0.5)
                  : accentColor.withValues(alpha: 0.35),
              width: 1.5,
            ),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: displayAccentColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.sports_kabaddi_rounded, color: displayAccentColor, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    "⚔️ Battle a Friend",
                    style: TextStyle(
                      color: textColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Outfit',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                "Challenge any player to a 1v1 Bible quiz battle! Answer 5 questions — fastest and most accurate player wins.",
                style: TextStyle(
                  color: subTextColor,
                  fontSize: 14,
                  fontFamily: 'Outfit',
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const BattleScreen()),
                    );
                  },
                  icon: const Icon(Icons.flash_on_rounded, size: 18),
                  label: const Text(
                    "CHALLENGE NOW",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      fontFamily: 'Outfit',
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: displayAccentColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
