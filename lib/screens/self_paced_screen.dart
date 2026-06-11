import 'dart:ui';
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/quiz.dart';
import '../providers/locale_provider.dart';
import '../providers/user_data_provider.dart';
import '../services/firebase_service.dart';
import '../services/challenge_questions.dart';
import '../services/monthly_questions.dart';
import '../widgets/gradient_background.dart';
import '../widgets/timer_capsule.dart';
import '../widgets/bilingual_text.dart';
import '../widgets/quiz_result_share.dart';
import '../services/activity_service.dart';

class SelfPacedScreen extends StatefulWidget {
  final Quiz quiz;
  final List<Question>? questions;
  final bool isDailyChallenge;
  final String? groupChallengeId;

  const SelfPacedScreen({
    super.key,
    required this.quiz,
    this.questions,
    this.isDailyChallenge = false,
    this.groupChallengeId,
  });

  @override
  State<SelfPacedScreen> createState() => _SelfPacedScreenState();
}

class _SelfPacedScreenState extends State<SelfPacedScreen> with TickerProviderStateMixin {
  List<Question> _questions = [];
  int _qIndex = 0;
  dynamic _selectedOption;
  String? _typedAnswer;
  final _textController = TextEditingController();
  bool _answered = false;
  bool _loading = true;
  late Stopwatch _stopwatch;

  // Timer variables
  Timer? _timer;
  int _timeLeft = 0;
  int _totalTimeLimit = 0;

  // Solo stats
  int _correctCount = 0;
  int _score = 0;
  bool _isFinished = false;
  final Map<int, bool> _questionCorrectness = {};

  // Feedback animations
  late AnimationController _feedbackAnimController;
  late Animation<double> _feedbackFadeAnimation;
  late Animation<double> _feedbackBounceAnimation;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch()..start();
    _loadQuestions();
    _feedbackAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _feedbackFadeAnimation = CurvedAnimation(
      parent: _feedbackAnimController,
      curve: Curves.easeIn,
    );
    _feedbackBounceAnimation = CurvedAnimation(
      parent: _feedbackAnimController,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _textController.dispose();
    _feedbackAnimController.dispose();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    if (widget.questions != null) {
      _questions = widget.questions!;
    } else if (widget.isDailyChallenge) {
      final list = ChallengeQuestions.getDailyQuestions();
      final todayStr = DateTime.now().toIso8601String().substring(0, 10);
      final seed = todayStr.hashCode;
      final shuffledList = List<Map<String, dynamic>>.from(list)..shuffle(Random(seed));
      _questions = shuffledList.map((q) => Question.fromMap(q)).toList();
    } else if (widget.quiz.id.startsWith('weekly_')) {
      final list = ChallengeQuestions.getWeeklyQuestions();
      _questions = list.map((q) => Question.fromMap(q)).toList();
    } else if (widget.quiz.id.startsWith('monthly_')) {
      final list = MonthlyQuestions.getMonthlyQuestions();
      _questions = list.map((q) => Question.fromMap(q)).toList();
    } else {
      _questions = await FirebaseService.getQuizQuestions(widget.quiz.id);
    }
    setState(() => _loading = false);
    _startTimerForQuestion();
  }

  void _startTimerForQuestion() {
    _timer?.cancel();
    if (_questions.isEmpty || _qIndex >= _questions.length) return;
    final q = _questions[_qIndex];
    setState(() {
      _timeLeft = q.timeLimitSeconds;
      _totalTimeLimit = q.timeLimitSeconds;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        _timer?.cancel();
        _autoSubmitOnTimeout();
      }
    });
  }

  void _autoSubmitOnTimeout() {
    _questionCorrectness[_qIndex] = false;
    setState(() {
      _answered = true;
    });
    _feedbackAnimController.forward(from: 0.0);
  }

  void _submitAnswer() {
    if (_selectedOption == null && (_typedAnswer == null || _typedAnswer!.trim().isEmpty)) {
      return;
    }
    _timer?.cancel();
    
    final q = _questions[_qIndex];
    final correct = _isCorrect(q);
    _questionCorrectness[_qIndex] = correct;
    
    if (correct) {
      _correctCount++;
      double multiplier = _timeLeft / (_totalTimeLimit > 0 ? _totalTimeLimit : 1);
      _score += (q.points * multiplier).round();
    }

    setState(() => _answered = true);
    _feedbackAnimController.forward(from: 0.0);
  }

  void _nextQuestion() {
    if (_qIndex < _questions.length - 1) {
      setState(() {
        _answered = false;
        _selectedOption = null;
        _typedAnswer = null;
        _textController.clear();
        _qIndex++;
      });
      _startTimerForQuestion();
    } else {
      _finishQuiz();
    }
  }

  void _finishQuiz() async {
    _stopwatch.stop();
    final userProvider = Provider.of<UserDataProvider>(context, listen: false);
    
    int xp = 100 + (_score ~/ 10);
    if (userProvider.streakDays > 0) {
      xp = (xp * (1.0 + userProvider.streakDays * 0.05)).round();
    }

    final displayName = await FirebaseService.getCurrentUserDisplayName() ?? "Guest";
    final uid = await FirebaseService.getCurrentUserUid() ?? "u";

    if (widget.isDailyChallenge) {
      userProvider.completeDailyChallenge(xp + 50);
    } else if (widget.quiz.id.startsWith('weekly_')) {
      userProvider.completeWeeklyChallenge(xp + 200);
      await FirebaseService.submitWeeklyLeaderboardScore(uid, displayName, _score);
    } else if (widget.quiz.id.startsWith('monthly_')) {
      xp += 1000;
      userProvider.completeMonthlyChallenge(xp);
      await FirebaseService.submitScore(uid, displayName, _score);
    } else {
      userProvider.addXp(xp);
      await FirebaseService.submitScore(uid, displayName, _score);
    }

    if (widget.groupChallengeId != null) {
      await FirebaseService.submitGroupChallengeScore(widget.groupChallengeId!, uid, _score);
    }

    for (int i = 0; i < _questions.length; i++) {
      final q = _questions[i];
      final bookId = userProvider.extractBookIdFromReference(q.verseReferenceEn);
      if (bookId != null) {
        final correct = _questionCorrectness[i] ?? false;
        userProvider.updateTopicPerformance(bookId, correct ? 1.0 : 0.0);
      }
    }

    final percentage = ((_correctCount / _questions.length) * 100).round();
    userProvider.completeQuiz(
      widget.quiz.id,
      _score,
      percentage,
      _stopwatch.elapsed.inSeconds,
      _questions.length,
      widget.quiz.topics,
    );

    ActivityService.logActivity(
      uid,
      displayName,
      'quiz_completed',
      {
        'quizId': widget.quiz.id,
        'quizName': widget.quiz.titleEn,
        'score': _score,
        'correctAnswers': _correctCount,
        'totalQuestions': _questions.length,
      },
    );

    if (widget.quiz.id.startsWith('weakness_quiz_')) {
      userProvider.markWeaknessQuizCompleted();
    }

    if (widget.quiz.id.startsWith('battle_quiz_')) {
      final battleId = widget.quiz.id.replaceFirst('battle_quiz_', '');
      await FirebaseService.submitBattleScore(battleId, uid, _score);
    }

    setState(() {
      _isFinished = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final lp = context.watch<LocaleProvider>();

    return Theme(
      data: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE21B3C),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF1A1A2E),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Outfit',
          ),
        ),
      ),
      child: Builder(
        builder: (context) {
          if (_loading) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (_questions.isEmpty) {
            return Scaffold(body: Center(child: Text(loc.noQuizzes)));
          }

          if (_isFinished) {
            return _buildSummaryScreen(loc);
          }

          final q = _questions[_qIndex];
          final qText = lp.getContentText(q.questionEn, q.questionTe);
          final colors = [Colors.red, Colors.blue, Colors.orange, Colors.green];

          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              title: Text('${widget.quiz.titleEn} (${_qIndex + 1}/${_questions.length})'),
              leading: IconButton(
                icon: const Text('✝', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                onPressed: () => Navigator.pop(context),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            body: Stack(
              children: [
                Positioned.fill(
                  child: const GradientBackground(child: SizedBox.shrink()),
                ),
                SafeArea(
                  child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TimerCapsule(
                  timeLeft: _timeLeft,
                  totalTimeLimit: _totalTimeLimit,
                ),
                const SizedBox(height: 16),
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
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                qText,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: lp.fontFamily,
                                  color: Colors.white,
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),
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
                const SizedBox(height: 24),
                
                // MCQ option grid
                if (q.type == 'multiple_choice' || q.type == 'mixed_format')
                  GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    shrinkWrap: true,
                    childAspectRatio: 1.5,
                    physics: const NeverScrollableScrollPhysics(),
                    children: List.generate(q.options.length, (i) {
                      final opt = q.options[i];
                      final text = lp.getContentText(opt.textEn, opt.textTe);
                      final sel = _selectedOption == i;
                      final correct = opt.isCorrect;
                      Color bg;
                      
                      if (!_answered) {
                        bg = sel ? colors[i % colors.length] : colors[i % colors.length].withAlpha(80);
                      } else {
                        if (correct) {
                          bg = Colors.green;
                        } else if (sel) {
                          bg = Colors.red;
                        } else {
                          bg = colors[i % colors.length].withAlpha(30);
                        }
                      }
                      
                      return Semantics(
                        button: true,
                        label: 'Option ${i + 1}: $text',
                        selected: sel,
                        enabled: !_answered,
                        child: GestureDetector(
                          onTap: _answered ? null : () => setState(() => _selectedOption = i),
                          child: Container(
                            decoration: BoxDecoration(
                              color: bg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: sel && !_answered ? Colors.white : Colors.transparent, width: sel && !_answered ? 2 : 1),
                            ),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(
                                  text,
                                  style: TextStyle(fontSize: 16, color: Colors.white, fontFamily: lp.fontFamily, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),

                // True / False buttons
                if (q.type == 'true_false')
                  Row(
                    children: [
                      Expanded(child: _tfButton('True', 'నిజం', 'true', q, lp)),
                      const SizedBox(width: 12),
                      Expanded(child: _tfButton('False', 'తప్పు', 'false', q, lp)),
                    ],
                  ),

                // Type answer input field
                if (q.type == 'type_answer' || q.type == 'skills_application')
                  TextField(
                    controller: _textController,
                    enabled: !_answered,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Your answer',
                      labelStyle: TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
                    ),
                    onChanged: (v) => setState(() => _typedAnswer = v),
                  ),
                const SizedBox(height: 24),

                if (!_answered)
                  Semantics(
                    button: true,
                    label: 'Submit Answer',
                    enabled: (_selectedOption != null || (_typedAnswer != null && _typedAnswer!.trim().isNotEmpty)),
                    child: ElevatedButton(
                      onPressed: (_selectedOption != null || (_typedAnswer != null && _typedAnswer!.trim().isNotEmpty)) ? _submitAnswer : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0284C7),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(loc.submitAnswer, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),

                if (_answered) ...[
                  const SizedBox(height: 24),
                  FadeTransition(
                    opacity: _feedbackFadeAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            ScaleTransition(
                              scale: _feedbackBounceAnimation,
                              child: Icon(
                                _isCorrect(q) ? Icons.check_circle : Icons.cancel,
                                color: _isCorrect(q) ? Colors.green : Colors.red,
                                size: 48,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _isCorrect(q) ? loc.correct.toUpperCase() : loc.incorrect.toUpperCase(),
                              style: TextStyle(
                                color: _isCorrect(q) ? Colors.green : Colors.red,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Outfit',
                                shadows: [
                                  Shadow(
                                    color: _isCorrect(q) ? Colors.greenAccent.withValues(alpha: 0.8) : Colors.redAccent.withValues(alpha: 0.8),
                                    blurRadius: 15,
                                    offset: Offset.zero,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Correct Answer reveal for type answer
                        if (!_isCorrect(q) && (q.type == 'type_answer' || q.type == 'skills_application')) ...[
                          Text(
                            'Correct Answer: ${q.correctAnswerEn} (${q.correctAnswerTe})',
                            style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 12),
                        ],

                        // Verse reference
                        if (q.verseReferenceEn.isNotEmpty) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(20),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.amber.shade200,
                                    width: 1.5,
                                  ),
                                ),
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '📖 ${loc.verseReference}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    BilingualText(
                                      englishText: q.verseReferenceEn,
                                      teluguText: q.verseReferenceTe,
                                      englishStyle: const TextStyle(color: Colors.white70, fontFamily: 'NotoSerif', fontSize: 14),
                                      teluguStyle: const TextStyle(color: Colors.white, fontFamily: 'NotoSerifTelugu', fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],

                        // Explanation
                        if (q.explanationEn.isNotEmpty) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(20),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.amber.shade200,
                                    width: 1.5,
                                  ),
                                ),
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '🏮 ${loc.explanation}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    BilingualText(
                                      englishText: q.explanationEn,
                                      teluguText: q.explanationTe,
                                      englishStyle: const TextStyle(color: Colors.white70, fontFamily: 'NotoSerif', fontSize: 14),
                                      teluguStyle: const TextStyle(color: Colors.white, fontFamily: 'NotoSerifTelugu', fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        Semantics(
                          button: true,
                          label: _qIndex == _questions.length - 1 ? 'Finish quiz' : 'Next question',
                          child: ElevatedButton(
                            onPressed: _nextQuestion,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0284C7),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text(
                              _qIndex == _questions.length - 1 ? 'FINISH' : loc.next,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
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
      ],
    ),
  );
},
),
);
  }

  bool _isCorrect(Question q) {
    if ((q.type == 'multiple_choice' || q.type == 'mixed_format') && _selectedOption != null && _selectedOption is int) {
      return q.options[_selectedOption as int].isCorrect;
    }
    if (q.type == 'true_false') {
      final enAnswer = _selectedOption == 'true' ? 'True' : 'False';
      return q.correctAnswerEn == enAnswer;
    }
    if ((q.type == 'type_answer' || q.type == 'skills_application') && _typedAnswer != null) {
      final cleanInput = _typedAnswer!.trim().toLowerCase();
      final cleanEn = (q.correctAnswerEn ?? '').trim().toLowerCase();
      final cleanTe = (q.correctAnswerTe ?? '').trim().toLowerCase();
      return cleanInput == cleanEn || cleanInput == cleanTe;
    }
    return false;
  }

  Widget _tfButton(String en, String te, String id, Question q, LocaleProvider lp) {
    final sel = _selectedOption == id;
    final correct = (q.correctAnswerEn == en);
    Color bg;
    if (!_answered) {
      bg = sel ? (en == 'True' ? Colors.green : Colors.red) : Colors.grey.shade800;
    } else {
      if (correct) {
        bg = Colors.green;
      } else if (sel) {
        bg = Colors.red;
      } else {
        bg = Colors.grey.shade900;
      }
    }
    final text = lp.getContentText(en, te);
    return Semantics(
      button: true,
      label: text,
      selected: sel,
      enabled: !_answered,
      child: GestureDetector(
        onTap: _answered ? null : () => setState(() => _selectedOption = id),
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: sel && !_answered ? Colors.white : Colors.grey, width: sel && !_answered ? 2 : 1),
          ),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryScreen(AppLocalizations loc) {
    final percentage = ((_correctCount / _questions.length) * 100).round();
    
    // Earned XP calculation
    final userProvider = Provider.of<UserDataProvider>(context, listen: false);
    int earnedXp = 100 + (_score ~/ 10);
    if (userProvider.streakDays > 0) {
      earnedXp = (earnedXp * (1.0 + userProvider.streakDays * 0.05)).round();
    }
    if (widget.isDailyChallenge) {
      earnedXp += 50;
    } else if (widget.quiz.id.startsWith('weekly_')) {
      earnedXp += 200;
    } else if (widget.quiz.id.startsWith('monthly_')) {
      earnedXp += 1000;
    }
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: const GradientBackground(child: SizedBox.shrink()),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      widget.isDailyChallenge 
                          ? '🏆 DAILY CHALLENGE COMPLETE!' 
                          : (widget.quiz.id.startsWith('weekly_') 
                              ? '🏆 WEEKLY CHALLENGE COMPLETE!' 
                              : (widget.quiz.id.startsWith('monthly_') 
                                  ? '🏆 MONTHLY CHALLENGE COMPLETE!' 
                                  : '🎉 QUIZ COMPLETE!')),
                      style: const TextStyle(color: Colors.green, fontSize: 26, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    
                    Card(
                      color: Colors.white.withAlpha(20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.white.withAlpha(30)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            _summaryRow('Correct Questions', '$_correctCount / ${_questions.length}'),
                            const Divider(color: Colors.white12),
                            _summaryRow('Accuracy', '$percentage%'),
                            const Divider(color: Colors.white12),
                            _summaryRow('Base Score', '$_score pts'),
                            const Divider(color: Colors.white12),
                            _summaryRow('XP Reward', '+$earnedXp XP', valueColor: Colors.yellow),
                          ],
                        ),
                      ),
                    ),
                    // Share Result Button
                    InkWell(
                      onTap: () {
                        final title = widget.quiz.titleEn;
                        final percentage = ((_correctCount / _questions.length) * 100).round();
                        QuizResultShare.shareResult(
                          context: context,
                          title: title,
                          score: _correctCount,
                          totalQuestions: _questions.length,
                          xpEarned: earnedXp,
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

                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0284C7),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('CONTINUE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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

  Widget _summaryRow(String label, String value, {Color valueColor = Colors.white}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 16)),
          Text(
            value,
            style: TextStyle(color: valueColor, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
          ),
        ],
      ),
    );
  }
}
