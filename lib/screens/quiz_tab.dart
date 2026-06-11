import 'dart:async';
import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/quiz.dart';
import '../providers/locale_provider.dart';
import '../providers/user_data_provider.dart';
import '../providers/reading_plan_provider.dart';
import '../services/firebase_service.dart';
import '../services/challenge_questions.dart';
import '../widgets/bilingual_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/progress_path_widget.dart';
import '../widgets/timer_capsule.dart';
import '../widgets/verse_of_the_day_card.dart';
import '../widgets/this_day_card.dart';
import '../widgets/quiz_result_share.dart';
import '../widgets/memory_game_card.dart';
import '../widgets/sharpen_weakness_card.dart';
import '../widgets/live_event_card.dart';
import '../services/verse_of_the_day.dart';
import 'flashcard_quiz_screen.dart';
import '../services/category_mapping.dart';
import '../services/activity_service.dart';
import 'main_screen.dart';
import 'profile_screen.dart';
enum QuizTabView { levelPicker, quizPlay }
enum QuizPlayState { intro, question, feedback, summary }

class PulsingRing extends StatefulWidget {
  final Widget child;
  const PulsingRing({super.key, required this.child});

  @override
  State<PulsingRing> createState() => _PulsingRingState();
}

class _PulsingRingState extends State<PulsingRing> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 44 + _controller.value * 20,
              height: 44 + _controller.value * 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFFFD700).withValues(alpha: 1.0 - _controller.value),
                  width: 3,
                ),
              ),
            ),
            widget.child,
          ],
        );
      },
    );
  }
}

// TimerCapsule class removed (moved to lib/widgets/timer_capsule.dart)

class QuizTab extends StatefulWidget {
  const QuizTab({super.key});

  @override
  State<QuizTab> createState() => _QuizTabState();
}

class _QuizTabState extends State<QuizTab> with TickerProviderStateMixin {
  QuizTabView _view = QuizTabView.levelPicker;
  int _selectedLevel = 1;
  final ScrollController _scrollController = ScrollController();
  String _selectedCategory = 'All';

  // Quiz play state
  Quiz? _activeQuiz;
  QuizPlayState _playState = QuizPlayState.intro;
  List<Question> _questions = [];
  int _questionIndex = 0;
  bool _isLoadingQuestions = false;
  
  // Timer & Scoring variables
  Timer? _timer;
  

  int _timeLeft = 20;
  int _totalTimeLimit = 20;
  int _accumulatedScore = 0;
  int _correctAnswersCount = 0;
  int _earnedXp = 0;
  int _totalTimeSpentInQuiz = 0;
  DateTime? _questionStartTime;
  final Map<int, bool> _questionCorrectness = {};

  // User input variables
  dynamic _selectedOptionIndex;
  String? _typedAnswer;
  final _typedAnswerController = TextEditingController();
  bool _isAnswerCorrect = false;

  // Feedback animations
  late AnimationController _feedbackAnimController;
  late Animation<double> _feedbackBounceAnimation;

  // Verse of the Day state
  bool _isVerseOfTheDayDismissed = false;
  DailyVerse? _verseOfTheDay;

  @override
  void initState() {
    super.initState();
    _loadVerseOfTheDay();
    _feedbackAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _feedbackBounceAnimation = CurvedAnimation(
      parent: _feedbackAnimController,
      curve: Curves.elasticOut,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserDataProvider>(context, listen: false);
      if (userProvider.userId != null) {
        Provider.of<ReadingPlanProvider>(context, listen: false)
            .loadCurrentPlan(userProvider.userId!);
      }
    });
  }

  void _loadVerseOfTheDay() async {
    final verse = VerseOfTheDayService.getVerseOfTheDay();
    if (mounted) {
      setState(() {
        _verseOfTheDay = verse;
      });
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final lastDismissedDate = prefs.getString('verse_dismissed_date') ?? '';
      final todayStr = DateTime.now().toIso8601String().substring(0, 10);
      if (mounted) {
        setState(() {
          _isVerseOfTheDayDismissed = (lastDismissedDate == todayStr);
        });
      }
    } catch (_) {}
  }

  void _dismissVerseOfTheDay() async {
    setState(() {
      _isVerseOfTheDayDismissed = true;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final todayStr = DateTime.now().toIso8601String().substring(0, 10);
      await prefs.setString('verse_dismissed_date', todayStr);
    } catch (_) {}
  }

  @override
  void dispose() {
    _timer?.cancel();
    _typedAnswerController.dispose();
    _scrollController.dispose();
    _feedbackAnimController.dispose();
    super.dispose();
  }



  void _startQuizForLevel(int level) async {
    final userProvider = Provider.of<UserDataProvider>(context, listen: false);
    final unlocked = userProvider.unlockedLevels;
    
    if (!unlocked.contains(level)) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Level $level is locked. Complete level ${level - 1} first."),
          backgroundColor: Colors.redAccent,
        ),
      );
    } else {
      final setId = userProvider.getOrPickUnseenSetForLevel(level);
      final quizzes = await FirebaseService.getQuizzesForLevel(level, setId);
      if (quizzes.isNotEmpty) {
        _startQuiz(quizzes.first);
      }
    }
  }

  void _showFullMap() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Full Map",
      barrierColor: Colors.black.withValues(alpha: 0.85),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        final highestUnlocked = Provider.of<UserDataProvider>(context, listen: false).unlockedLevels.isNotEmpty
            ? Provider.of<UserDataProvider>(context, listen: false).unlockedLevels.reduce((a, b) => a > b ? a : b)
            : 1;
        return FullJourneyMap(
          currentLevel: highestUnlocked,
          selectedLevel: _selectedLevel,
          onLevelSelected: (level) {
            _startQuizForLevel(level);
          },
        );
      },
    );
  }

  void _startQuiz(Quiz quiz) async {
    setState(() {
      _selectedLevel = quiz.level;
      _activeQuiz = quiz;
      _isLoadingQuestions = true;
      _playState = QuizPlayState.intro;
      _view = QuizTabView.quizPlay;
      _accumulatedScore = 0;
      _correctAnswersCount = 0;
      _questionIndex = 0;
      _totalTimeSpentInQuiz = 0;
      _questionCorrectness.clear();
    });

    List<Question> questions;
    if (quiz.id == 'daily') {
      final list = ChallengeQuestions.getDailyQuestions();
      final todayStr = DateTime.now().toIso8601String().substring(0, 10);
      final seed = todayStr.hashCode;
      final shuffledList = List<Map<String, dynamic>>.from(list)..shuffle(Random(seed));
      questions = shuffledList.map((q) => Question.fromMap(q)).toList();
    } else if (quiz.id.startsWith('weekly_')) {
      final list = ChallengeQuestions.getWeeklyQuestions();
      questions = list.map((q) => Question.fromMap(q)).toList();
    } else {
      questions = await FirebaseService.getQuizQuestions(quiz.id);
    }
    
    setState(() {
      _questions = questions;
      _isLoadingQuestions = false;
    });
  }

  void _startQuestion() {
    final q = _questions[_questionIndex];
    setState(() {
      _playState = QuizPlayState.question;
      _selectedOptionIndex = null;
      _typedAnswer = null;
      _typedAnswerController.clear();
      _timeLeft = q.timeLimitSeconds;
      _totalTimeLimit = q.timeLimitSeconds;
      _questionStartTime = DateTime.now();
    });

    // Start timer for all levels
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        _timer?.cancel();
        _revealAnswer(timedOut: true);
      }
    });
  }

  void _revealAnswer({bool timedOut = false}) {
    _timer?.cancel();
    final timeSpent = _questionStartTime != null ? DateTime.now().difference(_questionStartTime!).inSeconds : 0;
    _totalTimeSpentInQuiz += timeSpent;
    
    final q = _questions[_questionIndex];
    bool correct = false;

    if (!timedOut) {
      if ((q.type == 'multiple_choice' || q.type == 'mixed_format') && _selectedOptionIndex != null) {
        correct = q.options[_selectedOptionIndex as int].isCorrect;
      } else if (q.type == 'true_false' && _selectedOptionIndex != null) {
        final selectedStr = _selectedOptionIndex == 0 ? 'True' : 'False';
        correct = q.correctAnswerEn == selectedStr;
      } else if ((q.type == 'type_answer' || q.type == 'skills_application') && _typedAnswer != null) {
        correct = _typedAnswer!.trim().toLowerCase() == (q.correctAnswerEn ?? '').trim().toLowerCase();
      }
    }

    int scoreEarned = 0;
    if (correct) {
      // Points scaled by remaining time
      double multiplier = _timeLeft / (_totalTimeLimit > 0 ? _totalTimeLimit : 1);
      scoreEarned = (q.points * multiplier).round();
      _correctAnswersCount++;
    }

    _questionCorrectness[_questionIndex] = correct;

    setState(() {
      _isAnswerCorrect = correct;
      _accumulatedScore += scoreEarned;
      _playState = QuizPlayState.feedback;
    });
    _feedbackAnimController.forward(from: 0.0);
  }

  void _nextOrFinish() async {
    if (_questionIndex < _questions.length - 1) {
      setState(() {
        _questionIndex++;
      });
      _startQuestion();
    } else {
      // Quiz Finished! Submit results and calculate progression
      final percentage = ((_correctAnswersCount / _questions.length) * 100).round();
      final userProvider = Provider.of<UserDataProvider>(context, listen: false);

      for (int i = 0; i < _questions.length; i++) {
        final q = _questions[i];
        final bookId = userProvider.extractBookIdFromReference(q.verseReferenceEn);
        if (bookId != null) {
          final correct = _questionCorrectness[i] ?? false;
          userProvider.updateTopicPerformance(bookId, correct ? 1.0 : 0.0);
        }
      }
      
      // XP reward based on score, plus base quiz completion XP (100 XP)
      _earnedXp = 100 + (_accumulatedScore ~/ 10);
      
      // Apply streak multiplier
      if (userProvider.streakDays > 0) {
        double multiplier = 1.0 + (userProvider.streakDays * 0.05); // e.g. 1.05x, 1.1x
        _earnedXp = (_earnedXp * multiplier).round();
      }

      // Check daily/weekly challenge bonus (double XP / extra XP)
      bool isDaily = _activeQuiz?.id == 'daily' || _activeQuiz?.id.startsWith('daily_') == true;
      bool isWeekly = _activeQuiz?.id.startsWith('weekly_') == true;
      
      final displayName = await FirebaseService.getCurrentUserDisplayName() ?? "Player";
      final uid = await FirebaseService.getCurrentUserUid() ?? "u";

      if (isDaily) {
        _earnedXp += 50;
        userProvider.completeDailyChallenge(_earnedXp);
      } else if (isWeekly) {
        _earnedXp += 200;
        userProvider.completeWeeklyChallenge(_earnedXp);
        await FirebaseService.submitWeeklyLeaderboardScore(uid, displayName, _accumulatedScore);
      } else {
        userProvider.addXp(_earnedXp);
        await FirebaseService.submitScore(uid, displayName, _accumulatedScore);
      }

      userProvider.completeQuiz(
        _activeQuiz!.id,
        _accumulatedScore,
        percentage,
        _totalTimeSpentInQuiz,
        _questions.length,
        _activeQuiz!.topics,
      );

      ActivityService.logActivity(
        uid,
        displayName,
        'quiz_completed',
        {
          'quizId': _activeQuiz!.id,
          'quizName': _activeQuiz!.titleEn,
          'score': _accumulatedScore,
          'correctAnswers': _correctAnswersCount,
          'totalQuestions': _questions.length,
        },
      );

      // Level Unlock check (requires 70% score)
      if (percentage >= 70) {
        userProvider.unlockNextLevel(_selectedLevel);
      } else {
        // Failed the level — mark this set as seen so next attempt uses a different set
        if (_activeQuiz != null) {
          userProvider.markSetAsSeen(_selectedLevel, _activeQuiz!.setId);
        }
      }

      setState(() {
        _playState = QuizPlayState.summary;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    
    switch (_view) {
      case QuizTabView.levelPicker:
        return _buildLevelPicker(loc);
      case QuizTabView.quizPlay:
        return _buildQuizPlay(loc);
    }
  }

  // ── 1. Level Picker / Progress Journey view ──
  Widget _buildLevelPicker(AppLocalizations loc) {
    final userProvider = context.watch<UserDataProvider>();
    final unlocked = userProvider.unlockedLevels;
    final highestUnlocked = unlocked.isEmpty ? 1 : unlocked.reduce((a, b) => a > b ? a : b);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF3E2723);
    final accentColor = isDark ? const Color(0xFF38BDF8) : const Color(0xFF6C4AB6);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Bible Quiz",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Outfit',
          ),
        ),
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              )
            : IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () {
                  MainScreen.scaffoldKey.currentState?.openDrawer();
                },
              ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
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
          // Ambient background glow
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
          // Scrollable content list
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Custom Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.auto_stories, color: accentColor, size: 28),
                      Text(
                        "Telugu Bible Quiz",
                        style: TextStyle(
                          color: textColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Outfit',
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.auto_stories, color: accentColor),
                        tooltip: 'Scripture Mastery',
                        onPressed: () {
                          // Standard route for study tools
                          Navigator.pushNamed(context, '/study-tools');
                        },
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 12),
                        // Study Tools / Flashcards Banner
                        _buildStudyBanner(),
                        const SizedBox(height: 24),

                        // Section 1: Progress Path
                        GestureDetector(
                          onTap: _showFullMap,
                          behavior: HitTestBehavior.opaque,
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Your Journey",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Outfit',
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(Icons.map, color: Color(0xFF38BDF8), size: 18),
                                    SizedBox(width: 4),
                                    Text(
                                      "View Map",
                                      style: TextStyle(
                                        color: Color(0xFF38BDF8),
                                        fontFamily: 'Outfit',
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        ProgressPathWidget(
                          currentLevel: highestUnlocked,
                          onLevelTap: _startQuizForLevel,
                        ),
                        _buildReadingPlanCard(),
                        const SizedBox(height: 12),

                        // === FEATURE CARDS (above level grid) ===
                        // 1. Verse of the Day
                        if (!_isVerseOfTheDayDismissed && _verseOfTheDay != null) ...[
                          VerseOfTheDayCard(
                            verse: _verseOfTheDay!,
                            onDismiss: _dismissVerseOfTheDay,
                          ),
                          const SizedBox(height: 12),
                        ],
                        // 2. This Day in the Bible
                        const ThisDayCard(),
                        const SizedBox(height: 12),
                        // 3. Scripture Memory Game
                        const MemoryGameCard(),
                        const SizedBox(height: 12),
                        // 4. Sharpen Your Weakness (conditional)
                        const SharpenWeaknessCard(),
                        const SizedBox(height: 12),
                        // 5. Custom Chapter Quiz
                        _buildCustomQuizCard(),
                        const SizedBox(height: 20),

                        _buildCategoryFilters(),
                        const SizedBox(height: 16),

                        // Section 2: 2-Column Grid of Level Cards
                        const Text(
                          "Select Level",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Outfit',
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildLevelGrid(unlocked, highestUnlocked),
                        const SizedBox(height: 24),

                        // Live Event Card (below level grid)
                        const LiveEventCard(),
                        const SizedBox(height: 80), // Pad bottom
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildReadingPlanCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Consumer<ReadingPlanProvider>(
      builder: (context, planProvider, _) {
        final plan = planProvider.currentPlan;
        final hasPlan = plan != null;

        String title = hasPlan ? "Continue Reading Plan" : "Bible Reading Plans";
        String subtitle = hasPlan
            ? "Day ${plan.completedDays.length} completed • Streak: ${plan.streak} days"
            : "Enroll in a 30, 90, or 365 day reading plan";
        IconData icon = hasPlan ? Icons.menu_book_rounded : Icons.library_books_rounded;

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: hasPlan
                  ? const Color(0xFFFFD700).withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.15),
              width: 1.5,
            ),
          ),
          color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.of(context).pushNamed('/reading-plan');
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: hasPlan
                          ? const Color(0xFFFFD700).withValues(alpha: 0.15)
                          : const Color(0xFF6C4AB6).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: hasPlan ? const Color(0xFFFFD700) : const Color(0xFFBB86FC),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: isDark ? Colors.white : const Color(0xFF3E2723),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Outfit',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: isDark ? Colors.white70 : const Color(0xFF5D4037),
                            fontSize: 13,
                            fontFamily: 'Outfit',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: isDark ? Colors.white38 : const Color(0xFF3E2723),
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStudyBanner() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF3E2723);
    final subTextColor = isDark ? const Color(0xFFCBC3D4) : const Color(0xFF5D4037);
    final accentColor = isDark ? const Color(0xFF38BDF8) : const Color(0xFF6C4AB6);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: isDark ? 15 : 0, sigmaY: isDark ? 15 : 0),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.2) : const Color(0xFFD4A574).withValues(alpha: 0.4),
            ),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.menu_book, color: accentColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Scripture Study',
                      style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Outfit'),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Study bilingual flashcards & test your memory!',
                      style: TextStyle(color: subTextColor, fontSize: 12, fontFamily: 'Outfit'),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/study-tools');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor.withValues(alpha: 0.2),
                      foregroundColor: accentColor,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: accentColor, width: 1),
                      ),
                      elevation: 0,
                    ),
                    child: const Text('STUDY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, fontFamily: 'Outfit')),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const FlashcardQuizScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD700),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 4,
                    ),
                    child: const Text('QUIZ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, fontFamily: 'Outfit')),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilters() {
    final categories = [
      'All',
      'Old Testament',
      'New Testament',
      'Prophets',
      'Gospels',
      'Epistles',
      'Wisdom',
      'History',
      'Law'
    ];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedCategory == category;

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(
                category,
                style: TextStyle(
                  color: isSelected
                      ? (category == 'All' || category == 'Old Testament' || category == 'New Testament' ? Colors.white : Colors.black)
                      : (isDark ? Colors.white70 : const Color(0xFF3E2723)),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontFamily: 'Outfit',
                  fontSize: 13,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedCategory = category;
                  });
                }
              },
              selectedColor: (category == 'All' || category == 'Old Testament' || category == 'New Testament')
                  ? const Color(0xFF6C4AB6) // Purple for broad categories
                  : const Color(0xFFFFD700), // Gold for specific subcategories
              backgroundColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? ((category == 'All' || category == 'Old Testament' || category == 'New Testament')
                          ? const Color(0xFF6C4AB6)
                          : const Color(0xFFFFD700))
                      : (isDark ? Colors.white24 : const Color(0xFF6C4AB6).withValues(alpha: 0.2)),
                  width: 1.5,
                ),
              ),
              showCheckmark: false,
            ),
          );
        },
      ),
    );
  }

  Widget _buildLevelGrid(Set<int> unlocked, int highestUnlocked) {
    final filteredLevels = <int>[];
    for (int l = 1; l <= 100; l++) {
      final quizCat = CategoryMapping.getCategoryFromLevel(l);
      if (CategoryMapping.matchesCategory(quizCat, _selectedCategory)) {
        filteredLevels.add(l);
      }
    }

    if (filteredLevels.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32.0),
        child: Center(
          child: Text(
            "No quizzes found in this category.",
            style: TextStyle(color: Colors.white70, fontSize: 16, fontFamily: 'Outfit'),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.3,
      ),
      itemCount: filteredLevels.length,
      itemBuilder: (context, index) {
        final level = filteredLevels[index];
        final isCompleted = unlocked.contains(level) && level < highestUnlocked;
        final isCurrent = level == highestUnlocked;
        final isLocked = !unlocked.contains(level);

        final diff = level <= 33 ? 'Easy' : (level <= 66 ? 'Medium' : 'Hard');

        final isDark = Theme.of(context).brightness == Brightness.dark;
        Color borderCol;
        BoxDecoration decoration;

        if (isCompleted) {
          borderCol = isDark ? const Color(0xFFF7BC64) : const Color(0xFFD4A574);
          decoration = BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderCol.withValues(alpha: 0.5), width: 1.5),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
          );
        } else if (isCurrent) {
          borderCol = isDark ? const Color(0xFF38BDF8) : const Color(0xFF6C4AB6);
          decoration = BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.12) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderCol, width: 2),
            boxShadow: [
              BoxShadow(
                color: borderCol.withValues(alpha: isDark ? 0.1 : 0.2),
                blurRadius: 8,
              )
            ],
          );
        } else {
          borderCol = isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFD4A574).withValues(alpha: 0.2);
          decoration = BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderCol, width: 1),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ],
          );
        }

        String semanticsLabel = 'Level $level, difficulty $diff.';
        if (isLocked) {
          semanticsLabel += ' Locked.';
        } else if (isCompleted) {
          semanticsLabel += ' Completed.';
        } else {
          semanticsLabel += ' Current level.';
        }

        return Semantics(
          button: true,
          enabled: !isLocked,
          label: semanticsLabel,
          child: GestureDetector(
            onTap: () => _startQuizForLevel(level),
          child: Opacity(
            opacity: isLocked ? 0.6 : 1.0,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: isDark ? 15 : 0, sigmaY: isDark ? 15 : 0),
                child: Container(
                  decoration: decoration,
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Level $level',
                            style: TextStyle(
                              color: isLocked
                                  ? (isDark ? const Color(0xFF958E9D) : Colors.grey.shade500)
                                  : (isDark ? Colors.white : const Color(0xFF3E2723)),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Outfit',
                            ),
                          ),
                          Icon(
                            isLocked
                                ? Icons.lock
                                : (isCompleted ? Icons.check_circle : Icons.play_circle),
                            color: isLocked
                                ? (isDark ? const Color(0xFF958E9D) : Colors.grey.shade400)
                                : (isCompleted
                                    ? (isDark ? const Color(0xFFF7BC64) : const Color(0xFFD4A574))
                                    : (isDark ? const Color(0xFF38BDF8) : const Color(0xFF6C4AB6))),
                            size: 18,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isLocked
                                  ? Colors.transparent
                                  : (level <= 33
                                      ? Colors.green.withValues(alpha: 0.15)
                                      : (level <= 66
                                          ? Colors.orange.withValues(alpha: 0.15)
                                          : Colors.red.withValues(alpha: 0.15))),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              diff,
                              style: TextStyle(
                                color: isLocked
                                    ? (isDark ? const Color(0xFF958E9D) : Colors.grey.shade500)
                                    : (level <= 33
                                        ? (isDark ? Colors.greenAccent : Colors.green.shade800)
                                        : (level <= 66
                                            ? (isDark ? Colors.orangeAccent : Colors.orange.shade800)
                                            : (isDark ? Colors.redAccent : Colors.red.shade800))),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Outfit',
                              ),
                            ),
                          ),
                          Text(
                            "1 Quiz",
                            style: TextStyle(
                              color: isDark ? const Color(0xFFCBC3D4) : const Color(0xFF5D4037).withValues(alpha: 0.8),
                              fontSize: 11,
                              fontFamily: 'Outfit',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      },
    );
  }



  // ── 2. Quiz Play view state machine ──
  Widget _buildQuizPlay(AppLocalizations loc) {
    if (_isLoadingQuestions) {
      return const Scaffold(
        backgroundColor: Color(0xFF121414),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF38BDF8))),
      );
    }
    
    switch (_playState) {
      case QuizPlayState.intro:
        return _buildPlayIntro();
      case QuizPlayState.question:
      case QuizPlayState.feedback:
        return _buildPlayQuestion();
      case QuizPlayState.summary:
        return _buildPlaySummary();
    }
  }

  Widget _buildPlayIntro() {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A1A2E), Color(0xFF0F3460)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(28.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      child: const Icon(Icons.star, size: 72, color: Color(0xFFFFD700)),
                    ),
                    const SizedBox(height: 24),
                    BilingualText(
                      englishText: _activeQuiz?.titleEn ?? '',
                      teluguText: _activeQuiz?.titleTe ?? '',
                      englishStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Outfit'),
                      teluguStyle: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'NotoSerifTelugu'),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Questions: ${_questions.length} | Difficulty: ${_activeQuiz?.difficulty.toUpperCase()} | Set ${_activeQuiz?.setId ?? "A"}',
                      style: const TextStyle(color: Color(0xFFCBC3D4), fontSize: 16, fontFamily: 'Outfit'),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFB4AB).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFFFB4AB)),
                      ),
                      child: const Text(
                        '⏱️ TIMED MODE ACTIVE',
                        style: TextStyle(color: Color(0xFFFFB4AB), fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
                      ),
                    ),
                    const SizedBox(height: 40),
                    InkWell(
                      onTap: _startQuestion,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0284C7),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0284C7).withValues(alpha: 0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            )
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'START QUIZ',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Outfit'),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _view = QuizTabView.levelPicker;
                        });
                      },
                      child: const Text('Back to Levels', style: TextStyle(color: Color(0xFF38BDF8), fontSize: 15, fontFamily: 'Outfit')),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayQuestion() {
    final q = _questions[_questionIndex];
    final lp = Provider.of<LocaleProvider>(context);
    final isFeedback = _playState == QuizPlayState.feedback;
    
    // Kahoot colors: Red, Blue, Yellow, Green
    final colors = [
      const Color(0xFFE21B3C),
      const Color(0xFF1368CE),
      const Color(0xFFD89E00),
      const Color(0xFF26890C),
    ];

    if (isFeedback) {
      return _buildFeedbackOverlay(q, lp);
    }

    return Scaffold(
      body: Stack(
        children: [
          // Gradient Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A1A2E), Color(0xFF0F3460)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Custom Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            _view = QuizTabView.levelPicker;
                          });
                        },
                      ),
                      Text(
                        'Question ${_questionIndex + 1} of ${_questions.length}',
                        style: const TextStyle(
                          color: Color(0xFF38BDF8),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Outfit',
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          'Score: $_accumulatedScore',
                          style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Outfit'),
                        ),
                      ),
                    ],
                  ),
                ),

                // Timer Capsule
                TimerCapsule(
                  timeLeft: _timeLeft,
                  totalTimeLimit: _totalTimeLimit,
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Question Card (Glass style)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                            child: Container(
                              padding: const EdgeInsets.all(24.0),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                              ),
                              child: Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 28.0, bottom: 8.0),
                                    child: Column(
                                      children: [
                                        Text(
                                          q.questionEn,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'NotoSerif',
                                            height: 1.4,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          q.questionTe,
                                          style: const TextStyle(
                                            color: Color(0xFFCBC3D4),
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'NotoSerifTelugu',
                                            height: 1.4,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    top: -10,
                                    right: -10,
                                    child: Consumer<UserDataProvider>(
                                      builder: (context, userProvider, child) {
                                        final bookmarked = userProvider.isBookmarked(q.id);
                                        return IconButton(
                                          icon: Icon(
                                            bookmarked ? Icons.bookmark : Icons.bookmark_outline,
                                            color: bookmarked ? Colors.amber : Colors.white54,
                                          ),
                                          onPressed: () {
                                            userProvider.toggleBookmark(q.id);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  bookmarked ? "Removed bookmark" : "Bookmarked question",
                                                  style: const TextStyle(fontFamily: 'Outfit'),
                                                ),
                                                duration: const Duration(seconds: 1),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // MCQ Options (Grid / Kahoot Colors)
                        if (q.type == 'multiple_choice' || q.type == 'mixed_format')
                          GridView.count(
                            crossAxisCount: 2,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            shrinkWrap: true,
                            childAspectRatio: 1.3,
                            physics: const NeverScrollableScrollPhysics(),
                            children: List.generate(q.options.length, (i) {
                              final opt = q.options[i];
                              final Color optionColor = colors[i % colors.length];

                              final optionText = '${opt.textEn} / ${opt.textTe}';
                              final isSelected = _selectedOptionIndex == i;
                              return Semantics(
                                button: true,
                                label: 'Option ${i + 1}: $optionText',
                                selected: isSelected,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedOptionIndex = i;
                                    });
                                    _revealAnswer();
                                  },
                                  child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: optionColor,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: optionColor.withValues(alpha: 0.3),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      )
                                    ],
                                  ),
                                  child: Center(
                                    child: SingleChildScrollView(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            opt.textEn,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Outfit',
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            opt.textTe,
                                            style: TextStyle(
                                              color: Colors.white.withValues(alpha: 0.87),
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'NotoSerifTelugu',
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
                            }),
                          ),

                        // True / False Options
                        if (q.type == 'true_false')
                          Row(
                            children: [
                              Expanded(
                                child: _buildPlayTfButton(true, colors[1]), // Blue
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildPlayTfButton(false, colors[0]), // Red
                              ),
                            ],
                          ),

                        // Short Answer text input field
                        if (q.type == 'type_answer' || q.type == 'skills_application')
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                                ),
                                child: TextField(
                                  controller: _typedAnswerController,
                                  style: const TextStyle(color: Colors.white, fontFamily: 'Outfit'),
                                  decoration: InputDecoration(
                                    labelText: 'Your Answer / మీ సమాధానం',
                                    labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontFamily: 'Outfit'),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                  ),
                                  onChanged: (v) => setState(() => _typedAnswer = v),
                                ),
                              ),
                              const SizedBox(height: 24),
                              InkWell(
                                onTap: (_typedAnswer != null && _typedAnswer!.trim().isNotEmpty)
                                    ? () => _revealAnswer()
                                    : null,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  decoration: BoxDecoration(
                                    color: (_typedAnswer != null && _typedAnswer!.trim().isNotEmpty)
                                        ? const Color(0xFF0284C7)
                                        : Colors.white24,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: (_typedAnswer != null && _typedAnswer!.trim().isNotEmpty)
                                        ? [
                                            BoxShadow(
                                              color: const Color(0xFF0284C7).withValues(alpha: 0.4),
                                              blurRadius: 10,
                                            )
                                          ]
                                        : null,
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'SUBMIT',
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayTfButton(bool isTrueOpt, Color buttonColor) {
    final labelText = isTrueOpt ? 'True' : 'False';
    final isSelected = _selectedOptionIndex == (isTrueOpt ? 0 : 1);
    return Semantics(
      button: true,
      selected: isSelected,
      label: labelText,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedOptionIndex = isTrueOpt ? 0 : 1;
          });
          _revealAnswer();
        },
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            color: buttonColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: buttonColor.withValues(alpha: 0.3),
                blurRadius: 10,
              )
            ],
          ),
          child: Center(
            child: Text(
              isTrueOpt ? 'TRUE' : 'FALSE',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
                fontFamily: 'Outfit',
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── 3. Feedback overlay (Correct / Incorrect designs) ──
  Widget _buildFeedbackOverlay(Question q, LocaleProvider lp) {
    if (_isAnswerCorrect) {
      // Correct feedback screen matching quiz_feedback_correct.html
      return Scaffold(
        body: Stack(
          children: [
            // Background
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1A1A2E), Color(0xFF0F3460)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            // Correct glowing light
            Positioned.fill(
              child: Align(
                alignment: Alignment.center,
                child: Opacity(
                  opacity: 0.15,
                  child: Container(
                    width: 400,
                    height: 400,
                    decoration: const BoxDecoration(
                      color: Color(0xFF4ADE80),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF4ADE80),
                          blurRadius: 120,
                          spreadRadius: 80,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 32),
                          // Green Check with bounce transition
                          ScaleTransition(
                            scale: _feedbackBounceAnimation,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: const Color(0xFF4ADE80).withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFF4ADE80).withValues(alpha: 0.4)),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF4ADE80).withValues(alpha: 0.2),
                                    blurRadius: 20,
                                  )
                                ],
                              ),
                              child: const Center(
                                child: Icon(Icons.check_circle, color: Color(0xFF4ADE80), size: 56),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Correct!",
                            style: TextStyle(
                              color: Color(0xFF4ADE80),
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Outfit',
                              shadows: [
                                Shadow(
                                  color: Color(0xFF4ADE80),
                                  blurRadius: 15,
                                )
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Scripture Verse Card (Gold Tint)
                          _buildGlassCard(
                            isGold: true,
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.menu_book, color: Color(0xFFF7BC64), size: 24),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              q.verseReferenceEn.isNotEmpty ? q.verseReferenceEn : "Genesis 1:3",
                                              style: const TextStyle(
                                                color: Color(0xFFFFDDB2),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                fontFamily: 'NotoSerif',
                                              ),
                                            ),
                                            if (q.verseReferenceTe.isNotEmpty)
                                              Text(
                                                q.verseReferenceTe,
                                                style: const TextStyle(
                                                  color: Color(0xFFF7BC64),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  fontFamily: 'NotoSerifTelugu',
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 12.0),
                                    child: Divider(color: Colors.white12, height: 1),
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.lightbulb, color: Color(0xFF38BDF8), size: 24),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              q.explanationEn.isNotEmpty ? q.explanationEn : "And God said, 'Let there be light,' and there was light.",
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 15,
                                                height: 1.4,
                                                fontFamily: 'NotoSerif',
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              q.explanationTe.isNotEmpty ? q.explanationTe : "(మరియు దేవుడు వెలుగు కలుగును గాక అని పలికెను; అప్పుడు వెలుగు కలిగెను.)",
                                              style: const TextStyle(
                                                color: Color(0xFFCBC3D4),
                                                fontSize: 15,
                                                height: 1.4,
                                                fontFamily: 'NotoSerifTelugu',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Button Panel
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Semantics(
                      button: true,
                      label: _questionIndex == _questions.length - 1 ? 'Finish quiz' : 'Next question',
                      child: InkWell(
                        onTap: _nextOrFinish,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0284C7),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0284C7).withValues(alpha: 0.4),
                                blurRadius: 15,
                              )
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _questionIndex == _questions.length - 1 ? 'FINISH' : 'NEXT QUESTION',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15, fontFamily: 'Outfit', letterSpacing: 1.1),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      // Incorrect feedback screen matching quiz_feedback_incorrect.html
      String correctOptName = "";
      if (q.type == 'multiple_choice' || q.type == 'mixed_format') {
        final correctOpt = q.options.firstWhere((o) => o.isCorrect);
        correctOptName = lp.contentMode == ContentLanguageMode.telugu ? correctOpt.textTe : correctOpt.textEn;
      } else {
        correctOptName = lp.contentMode == ContentLanguageMode.telugu
            ? (q.correctAnswerTe ?? 'సమాధానం')
            : (q.correctAnswerEn ?? 'Answer');
      }

      return Scaffold(
        body: Stack(
          children: [
            // Background
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1A1A2E), Color(0xFF0F3460)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            // Incorrect glowing light
            Positioned.fill(
              child: Align(
                alignment: Alignment.center,
                child: Opacity(
                  opacity: 0.1,
                  child: Container(
                    width: 400,
                    height: 400,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFB4AB),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFFFFB4AB),
                          blurRadius: 120,
                          spreadRadius: 80,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 32),
                          // Red Cancel with bounce transition
                          ScaleTransition(
                            scale: _feedbackBounceAnimation,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFB4AB).withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xFFFFB4AB).withValues(alpha: 0.4)),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFFB4AB).withValues(alpha: 0.1),
                                    blurRadius: 20,
                                  )
                                ],
                              ),
                              child: const Center(
                                child: Icon(Icons.close, color: Color(0xFFFFB4AB), size: 56),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Incorrect!",
                            style: TextStyle(
                              color: Color(0xFFFFB4AB),
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Outfit',
                              shadows: [
                                Shadow(
                                  color: Color(0xFFFFB4AB),
                                  blurRadius: 15,
                                )
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Explanation Card (Gold Tint)
                          _buildGlassCard(
                            isGold: true,
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.menu_book, color: Color(0xFFF7BC64), size: 24),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              q.verseReferenceEn.isNotEmpty ? q.verseReferenceEn : "Genesis 1:3",
                                              style: const TextStyle(
                                                color: Color(0xFFFFDDB2),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                fontFamily: 'NotoSerif',
                                              ),
                                            ),
                                            if (q.verseReferenceTe.isNotEmpty)
                                              Text(
                                                q.verseReferenceTe,
                                                style: const TextStyle(
                                                  color: Color(0xFFF7BC64),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  fontFamily: 'NotoSerifTelugu',
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 12.0),
                                    child: Divider(color: Colors.white12, height: 1),
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.tips_and_updates, color: Color(0xFFF7BC64), size: 24),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "The correct answer was $correctOptName.",
                                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              q.explanationEn,
                                              style: const TextStyle(
                                                color: Color(0xFFCBC3D4),
                                                fontSize: 15,
                                                height: 1.4,
                                                fontFamily: 'NotoSerif',
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              q.explanationTe,
                                              style: const TextStyle(
                                                color: Color(0xFFCBC3D4),
                                                fontSize: 15,
                                                height: 1.4,
                                                fontFamily: 'NotoSerifTelugu',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Button Panel
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Semantics(
                      button: true,
                      label: _questionIndex == _questions.length - 1 ? 'Finish quiz' : 'Next question',
                      child: InkWell(
                        onTap: _nextOrFinish,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0284C7),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0284C7).withValues(alpha: 0.4),
                                blurRadius: 15,
                              )
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _questionIndex == _questions.length - 1 ? 'FINISH' : 'NEXT QUESTION',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15, fontFamily: 'Outfit', letterSpacing: 1.1),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  // ── 4. Quiz Play Summary View ──
  Widget _buildPlaySummary() {
    final percentage = ((_correctAnswersCount / _questions.length) * 100).round();
    final pass = percentage >= 70;
    
    // Star calculations
    int starsCount = 0;
    if (percentage >= 90) {
      starsCount = 3;
    } else if (percentage >= 70) {
      starsCount = 2;
    } else if (percentage >= 40) {
      starsCount = 1;
    }

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1A1A2E),
                  Color(0xFF0F3460),
                ],
              ),
            ),
          ),
          // Ambient background glow
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: Opacity(
                opacity: 0.1,
                child: Container(
                  width: 500,
                  height: 500,
                  decoration: const BoxDecoration(
                    color: Color(0xFF38BDF8),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF38BDF8),
                        blurRadius: 150,
                        spreadRadius: 100,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Content Scroll
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Badge: Level Up! / Completed
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0284C7), Color(0xFF38BDF8)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0284C7).withValues(alpha: 0.5),
                              blurRadius: 10,
                            )
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.stars, color: Colors.white, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'LEVEL COMPLETED!',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12, fontFamily: 'Outfit', letterSpacing: 1.1),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Score Display
                    Text(
                      '$_accumulatedScore / ${12 * (1000 + _selectedLevel * 10)} pts',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Outfit',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    // Stars reveal with glow
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (i) {
                        final hasStar = i < starsCount;
                        return Icon(
                          Icons.star,
                          size: 54,
                          color: hasStar ? const Color(0xFFFFD700) : Colors.white.withValues(alpha: 0.15),
                          shadows: hasStar
                              ? [
                                  const Shadow(
                                    color: Color(0xFFFFD700),
                                    blurRadius: 15,
                                  )
                                ]
                              : null,
                        );
                      }),
                    ),
                    const SizedBox(height: 20),

                    // XP Gained indicator
                    Text(
                      '+$_earnedXp XP',
                      style: const TextStyle(
                        color: Color(0xFF4ADE80),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Outfit',
                        shadows: [
                          Shadow(
                            color: Color(0xFF4ADE80),
                            blurRadius: 10,
                          )
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Details Card
                    _buildGlassCard(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Text(
                              'Quiz completed! You answered $_correctAnswersCount/12 correctly.',
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Outfit', height: 1.4),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            if (pass && _selectedLevel < 100)
                              Text(
                                'Level ${_selectedLevel + 1} has been unlocked!',
                                style: const TextStyle(color: Color(0xFF4ADE80), fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
                                textAlign: TextAlign.center,
                              ),
                            if (!pass)
                              const Text(
                                'Score at least 70% accuracy to unlock the next level!',
                                style: TextStyle(color: Color(0xFFF7BC64), fontSize: 14, fontFamily: 'Outfit'),
                                textAlign: TextAlign.center,
                              ),
                          ],
                        ),
                      ),
                    ),
                    // Share Result Button
                    InkWell(
                      onTap: () {
                        final title = _activeQuiz?.titleEn ?? "Level $_selectedLevel Quiz";
                        final percentage = ((_correctAnswersCount / _questions.length) * 100).round();
                        QuizResultShare.shareResult(
                          context: context,
                          title: title,
                          score: _correctAnswersCount,
                          totalQuestions: _questions.length,
                          xpEarned: _earnedXp,
                          percentage: percentage,
                          onShareSuccess: () {
                            Provider.of<UserDataProvider>(context, listen: false).recordShare();
                          },
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6366F1).withAlpha(100),
                              blurRadius: 10,
                            )
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.share, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'SHARE RESULT',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                fontFamily: 'Outfit',
                                letterSpacing: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Action Buttons (Replay, Continue)
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              if (_activeQuiz != null) {
                                _startQuiz(_activeQuiz!);
                              }
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                              ),
                              child: const Center(
                                child: Text(
                                  'REPLAY',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Outfit', letterSpacing: 1.1),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _view = QuizTabView.levelPicker;
                              });
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0284C7),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF0284C7).withValues(alpha: 0.4),
                                    blurRadius: 10,
                                  )
                                ],
                              ),
                              child: const Center(
                                child: Text(
                                  'CONTINUE',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Outfit', letterSpacing: 1.1),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomQuizCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF3E2723);
    final subTextColor = isDark ? const Color(0xFFCBC3D4) : const Color(0xFF5D4037);
    final accentColor = const Color(0xFF10B981); // Emerald green

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: isDark ? 15 : 0, sigmaY: isDark ? 15 : 0),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.2) : const Color(0xFFD4A574).withValues(alpha: 0.4),
              ),
              boxShadow: isDark
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.tune_rounded, color: accentColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Custom Chapter Quiz',
                        style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Outfit'),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Generate a quiz from a custom chapter range!',
                        style: TextStyle(color: subTextColor, fontSize: 12, fontFamily: 'Outfit'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/custom-quiz-creator');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: const Text('CREATE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, fontFamily: 'Outfit')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassCard({required Widget child, bool isGold = false}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isGold ? const Color(0xFFF7BC64).withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
