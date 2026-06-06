import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/flashcard.dart';
import '../providers/locale_provider.dart';
import '../providers/user_data_provider.dart';
import '../services/firebase_service.dart';
import '../widgets/gradient_background.dart';
import '../widgets/bilingual_text.dart';

class FlashcardQuizScreen extends StatefulWidget {
  const FlashcardQuizScreen({super.key});

  @override
  State<FlashcardQuizScreen> createState() => _FlashcardQuizScreenState();
}

class _FlashcardQuizScreenState extends State<FlashcardQuizScreen> {
  List<Flashcard> _cards = [];
  int _currentIndex = 0;
  List<String> _options = [];
  String _correctOption = "";
  
  bool _answered = false;
  int? _selectedOptionIndex;
  int _correctCount = 0;
  int _score = 0;
  bool _isFinished = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  void _loadCards() {
    final cards = List<Flashcard>.from(FirebaseService.getFlashcards());
    cards.shuffle(); // Shuffle cards for random quiz questions
    
    // Take a maximum of 10 questions for a quick quiz
    setState(() {
      _cards = cards.take(10).toList();
      _loading = false;
    });
    
    if (_cards.isNotEmpty) {
      _generateOptions();
    }
  }

  void _generateOptions() {
    final card = _cards[_currentIndex];
    final lp = Provider.of<LocaleProvider>(context, listen: false);

    // Get correct answer text
    _correctOption = lp.getContentText(card.verseEn, card.verseTe);

    // Select 3 random other verses as distractors
    final allCards = FirebaseService.getFlashcards();
    final distractors = allCards
        .where((c) => c.id != card.id)
        .map((c) => lp.getContentText(c.verseEn, c.verseTe))
        .toList();
    
    distractors.shuffle();

    final List<String> list = [
      _correctOption,
      distractors[0],
      distractors[1],
      distractors[2],
    ];
    list.shuffle();

    setState(() {
      _options = list;
      _answered = false;
      _selectedOptionIndex = null;
    });
  }

  void _submitAnswer(int index) {
    if (_answered) return;

    final selectedText = _options[index];
    final isCorrect = selectedText == _correctOption;

    if (isCorrect) {
      _correctCount++;
      _score += 100; // 100 points per correct answer
    }

    setState(() {
      _selectedOptionIndex = index;
      _answered = true;
    });
  }

  void _nextOrFinish() async {
    if (_currentIndex < _cards.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _generateOptions();
    } else {
      // Complete quiz and award XP
      final userProvider = Provider.of<UserDataProvider>(context, listen: false);
      
      // Flashcard quiz awards flat 50 Completion XP + score/10
      int earnedXp = 50 + (_score ~/ 10);
      
      if (userProvider.streakDays > 0) {
        earnedXp = (earnedXp * (1.0 + userProvider.streakDays * 0.05)).round();
      }

      userProvider.addXp(earnedXp);
      
      final displayName = await FirebaseService.getCurrentUserDisplayName() ?? "Guest";
      final uid = await FirebaseService.getCurrentUserUid() ?? "u";
      await FirebaseService.submitScore(uid, displayName, _score);

      setState(() {
        _isFinished = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (_cards.isEmpty) {
            return const Scaffold(
              body: Center(child: Text('No flashcards available.', style: TextStyle(color: Colors.white))),
            );
          }

          if (_isFinished) {
            return _buildSummaryScreen();
          }

          final card = _cards[_currentIndex];
          final lp = Provider.of<LocaleProvider>(context);

          return Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              title: Text('Flashcard Quiz (${_currentIndex + 1}/${_cards.length})'),
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Text('✝', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: Stack(
              children: [
                Positioned.fill(
                  child: const GradientBackground(child: SizedBox.shrink()),
                ),
                SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Center(
                        child: Text(
                          'Select the correct verse for this reference:',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Reference citation panel
                      Card(
                        color: Colors.white.withAlpha(20),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: Colors.white.withAlpha(30)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Center(
                            child: BilingualText(
                              englishText: card.referenceEn,
                              teluguText: card.referenceTe,
                              englishStyle: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'NotoSerif'),
                              teluguStyle: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'NotoSerifTelugu'),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Options
                      ...List.generate(4, (index) {
                        final text = _options[index];
                        final isSelected = _selectedOptionIndex == index;
                        final isCorrectOpt = text == _correctOption;

                        Color bg;
                        if (!_answered) {
                          bg = isSelected ? Colors.blue : Colors.white.withAlpha(15);
                        } else {
                          if (isCorrectOpt) {
                            bg = Colors.green;
                          } else if (isSelected) {
                            bg = Colors.red;
                          } else {
                            bg = Colors.white.withAlpha(5);
                          }
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: GestureDetector(
                            onTap: _answered ? null : () => _submitAnswer(index),
                            child: Container(
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: bg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected && !_answered ? Colors.blue : Colors.white.withAlpha(20),
                                  width: isSelected && !_answered ? 2 : 1,
                                ),
                              ),
                              child: Text(
                                text,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: lp.fontFamily == 'NotoSansTelugu' ? 'NotoSerifTelugu' : 'NotoSerif',
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ),
                        );
                      }),

                      if (_answered) ...[
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _nextOrFinish,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0284C7),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(_currentIndex == _cards.length - 1 ? 'FINISH' : 'NEXT'),
                        ),
                      ],
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
},
),
);
  }

  Widget _buildSummaryScreen() {
    final percentage = ((_correctCount / _cards.length) * 100).round();
    final userProvider = Provider.of<UserDataProvider>(context, listen: false);
    int earnedXp = 50 + (_score ~/ 10);
    
    if (userProvider.streakDays > 0) {
      earnedXp = (earnedXp * (1.0 + userProvider.streakDays * 0.05)).round();
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
                    const Text(
                      '🎉 FLASHCARD QUIZ COMPLETE!',
                      style: TextStyle(color: Colors.green, fontSize: 26, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
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
                            _summaryRow('Correct Questions', '$_correctCount / ${_cards.length}'),
                            const Divider(color: Colors.white12),
                            _summaryRow('Accuracy', '$percentage%'),
                            const Divider(color: Colors.white12),
                            _summaryRow('Quiz Score', '$_score pts'),
                            const Divider(color: Colors.white12),
                            _summaryRow('XP Reward', '+$earnedXp XP', valueColor: Colors.yellow),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
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
