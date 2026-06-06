import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/user_data_provider.dart';
import '../services/memory_verses.dart';
import '../services/verse_of_the_day.dart';

enum MemoryGameState { memorize, disappearing, input, feedback, summary }

class MemoryGameScreen extends StatefulWidget {
  const MemoryGameScreen({super.key});

  @override
  State<MemoryGameScreen> createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends State<MemoryGameScreen> {
  // Game state variables
  int _round = 1; // 1, 2, 3
  int _verseIndex = 0; // 0, 1, 2 in each round
  int _totalCorrectWords = 0;
  int _totalPossibleWords = 0;
  
  List<DailyVerse> _gameVerses = [];
  late DailyVerse _currentVerse;
  List<String> _verseWords = [];
  
  // Words selected to disappear
  List<int> _disappearedIndices = [];
  List<int> _currentlyHiddenIndices = [];
  
  MemoryGameState _gameState = MemoryGameState.memorize;
  
  // Timers
  Timer? _memorizeTimer;
  Timer? _disappearTimer;
  int _memorizeSecondsLeft = 10;
  int _disappearStep = 0;
  
  // Controllers
  List<TextEditingController> _controllers = [];
  List<FocusNode> _focusNodes = [];
  List<bool?> _blankCorrectness = []; // null = unchecked, true = correct, false = incorrect

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  @override
  void dispose() {
    _cancelTimers();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _cancelTimers() {
    _memorizeTimer?.cancel();
    _disappearTimer?.cancel();
  }

  void _startNewGame() {
    _round = 1;
    _verseIndex = 0;
    _totalCorrectWords = 0;
    _totalPossibleWords = 0;
    
    // Pick 9 random verses
    _gameVerses = MemoryVersesService.getRandomVerses(9);
    _loadCurrentVerse();
  }

  void _loadCurrentVerse() {
    _cancelTimers();
    _gameState = MemoryGameState.memorize;
    _memorizeSecondsLeft = 10;
    
    final globalIndex = (_round - 1) * 3 + _verseIndex;
    _currentVerse = _gameVerses[globalIndex];
    
    // Split English verse into words
    _verseWords = _currentVerse.verseEn.split(' ');
    
    // Choose words to disappear based on round
    int disappearCount = 3;
    if (_round == 2) disappearCount = 5;
    if (_round == 3) disappearCount = 7;
    
    // Clamp disappearCount to verse length
    if (disappearCount > _verseWords.length) {
      disappearCount = _verseWords.length;
    }
    
    _totalPossibleWords += disappearCount;

    // Pick random unique indices
    final random = Random();
    final Set<int> indices = {};
    while (indices.length < disappearCount) {
      // Avoid index of tiny words if possible, but allow if short verse
      int idx = random.nextInt(_verseWords.length);
      indices.add(idx);
    }
    
    // Sort indices so they are in reading order
    _disappearedIndices = indices.toList()..sort();
    _currentlyHiddenIndices = [];
    _disappearStep = 0;
    
    // Reset controllers
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    
    _controllers = List.generate(disappearCount, (_) => TextEditingController());
    _focusNodes = List.generate(disappearCount, (_) => FocusNode());
    _blankCorrectness = List.filled(disappearCount, null);

    // Start 10-second memorization timer
    _memorizeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_memorizeSecondsLeft > 1) {
          _memorizeSecondsLeft--;
        } else {
          timer.cancel();
          _startDisappearingPhase();
        }
      });
    });
  }

  void _skipMemorize() {
    _memorizeTimer?.cancel();
    _startDisappearingPhase();
  }

  void _startDisappearingPhase() {
    setState(() {
      _gameState = MemoryGameState.disappearing;
    });

    _disappearTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!mounted) return;
      setState(() {
        if (_disappearStep < _disappearedIndices.length) {
          _currentlyHiddenIndices.add(_disappearedIndices[_disappearStep]);
          _disappearStep++;
        } else {
          timer.cancel();
          _startInputPhase();
        }
      });
    });
  }

  void _startInputPhase() {
    setState(() {
      _gameState = MemoryGameState.input;
    });
  }

  String _cleanWord(String word) {
    return word.replaceAll(RegExp(r'[^\w]'), '').toLowerCase().trim();
  }

  void _submitAnswers() {
    int roundCorrect = 0;
    setState(() {
      _gameState = MemoryGameState.feedback;
      for (int i = 0; i < _disappearedIndices.length; i++) {
        final originalWord = _verseWords[_disappearedIndices[i]];
        final userWord = _controllers[i].text;
        
        final isCorrect = _cleanWord(userWord) == _cleanWord(originalWord);
        _blankCorrectness[i] = isCorrect;
        if (isCorrect) {
          roundCorrect++;
        }
      }
      _totalCorrectWords += roundCorrect;
    });
  }

  void _nextVerse() {
    if (_verseIndex < 2) {
      setState(() {
        _verseIndex++;
      });
      _loadCurrentVerse();
    } else if (_round < 3) {
      setState(() {
        _round++;
        _verseIndex = 0;
      });
      _loadCurrentVerse();
    } else {
      // Game Over, go to summary!
      setState(() {
        _gameState = MemoryGameState.summary;
      });
      // Award XP in UserDataProvider
      final xpEarned = _totalCorrectWords * 5; // +5 XP per correct word!
      final provider = Provider.of<UserDataProvider>(context, listen: false);
      provider.addXp(xpEarned);
      provider.completeMemoryGame();
    }
  }

  Widget _buildVerseWithBlanks() {
    final List<InlineSpan> spans = [];
    final textStyle = const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.white,
      fontFamily: 'NotoSerif',
      height: 1.6,
    );

    for (int i = 0; i < _verseWords.length; i++) {
      final isSelectToDisappear = _disappearedIndices.contains(i);
      final isCurrentlyHidden = _currentlyHiddenIndices.contains(i);

      if (isSelectToDisappear && isCurrentlyHidden) {
        // Find local index in selected list
        final localIdx = _disappearedIndices.indexOf(i);
        
        if (_gameState == MemoryGameState.input || _gameState == MemoryGameState.feedback) {
          // Render input field or feedback icon
          final isCorrect = _blankCorrectness[localIdx];
          Color underlineColor = Colors.white54;
          if (isCorrect != null) {
            underlineColor = isCorrect ? Colors.green : Colors.red;
          }
          
          spans.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Container(
                width: 90,
                height: 32,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: TextField(
                  controller: _controllers[localIdx],
                  focusNode: _focusNodes[localIdx],
                  enabled: _gameState == MemoryGameState.input,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isCorrect == null 
                        ? Colors.amberAccent 
                        : (isCorrect ? Colors.greenAccent : Colors.redAccent),
                    fontFamily: 'Outfit',
                  ),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(vertical: 6),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: underlineColor, width: 2)),
                    disabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: underlineColor, width: 2)),
                    focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.amber, width: 2.5)),
                  ),
                  onSubmitted: (_) {
                    if (localIdx < _disappearedIndices.length - 1) {
                      _focusNodes[localIdx + 1].requestFocus();
                    }
                  },
                ),
              ),
            ),
          );
        } else {
          // Disappearing phase blank
          spans.add(
            const TextSpan(
              text: "_____ ",
              style: TextStyle(color: Colors.amberAccent),
            ),
          );
        }
      } else {
        // Normal word
        spans.add(
          TextSpan(
            text: "${_verseWords[i]} ",
            style: isSelectToDisappear ? textStyle.copyWith(color: Colors.amber) : textStyle,
          ),
        );
      }
    }

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(children: spans),
    );
  }

  @override
  Widget build(BuildContext context) {
    
    if (_gameState == MemoryGameState.summary) {
      return _buildSummaryScreen();
    }

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
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
                // Top bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Exit Game?", style: TextStyle(fontFamily: 'Outfit')),
                              content: const Text("You will lose your memory game progress."),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("Cancel"),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context); // pop dialog
                                    Navigator.pop(context); // pop screen
                                  },
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                  child: const Text("Exit"),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      Text(
                        "Round $_round/3 - Verse ${_verseIndex + 1}/3",
                        style: const TextStyle(
                          color: Color(0xFF38BDF8),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Outfit',
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "Score: $_totalCorrectWords/$_totalPossibleWords",
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
                        ),
                      )
                    ],
                  ),
                ),
                
                // Instructions / Game Status header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  child: _buildPhaseStatusHeader(),
                ),

                // Main verse display area
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(28.0),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Telugu translation helper (read-only)
                                Text(
                                  _currentVerse.verseTe,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.white70,
                                    fontFamily: 'NotoSerifTelugu',
                                    height: 1.6,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                const Divider(color: Colors.white24, height: 1),
                                const SizedBox(height: 16),
                                
                                // English verse with blanks
                                _buildVerseWithBlanks(),
                                
                                const SizedBox(height: 24),
                                Text(
                                  "${_currentVerse.referenceTe} / ${_currentVerse.referenceEn}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF38BDF8),
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Outfit',
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
                ),

                // Interactive reveal options for feedback mode
                if (_gameState == MemoryGameState.feedback)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
                    child: Card(
                      color: Colors.white10,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              "Correct Answers:",
                              style: TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: List.generate(_disappearedIndices.length, (idx) {
                                final original = _verseWords[_disappearedIndices[idx]];
                                final isCorrect = _blankCorrectness[idx] ?? false;
                                return Chip(
                                  backgroundColor: isCorrect ? Colors.green.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.2),
                                  side: BorderSide(color: isCorrect ? Colors.green : Colors.red),
                                  label: Text(
                                    "${idx + 1}. $original",
                                    style: TextStyle(
                                      color: isCorrect ? Colors.greenAccent : Colors.redAccent,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Outfit',
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Action controls at bottom
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: _buildPhaseActionButton(),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPhaseStatusHeader() {
    switch (_gameState) {
      case MemoryGameState.memorize:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle),
              child: const Icon(Icons.psychology, color: Colors.black, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Phase 1: Memorize the Verse",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
                  ),
                  Text(
                    "Words disappear in $_memorizeSecondsLeft seconds...",
                    style: const TextStyle(color: Colors.white70, fontSize: 13, fontFamily: 'Outfit'),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(
                value: _memorizeSecondsLeft / 10.0,
                color: Colors.amber,
                backgroundColor: Colors.white12,
                strokeWidth: 3.5,
              ),
            ),
          ],
        );
      case MemoryGameState.disappearing:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Colors.purple, shape: BoxShape.circle),
              child: const Icon(Icons.blur_on_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Phase 2: Words are Disappearing!",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
                  ),
                  Text(
                    "Removing ${_currentlyHiddenIndices.length} of ${_disappearedIndices.length} words...",
                    style: const TextStyle(color: Colors.white70, fontSize: 13, fontFamily: 'Outfit'),
                  ),
                ],
              ),
            ),
          ],
        );
      case MemoryGameState.input:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
              child: const Icon(Icons.edit, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Phase 3: Recall & Type",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
                  ),
                  Text(
                    "Enter the missing ${_disappearedIndices.length} words in the blanks.",
                    style: const TextStyle(color: Colors.white70, fontSize: 13, fontFamily: 'Outfit'),
                  ),
                ],
              ),
            ),
          ],
        );
      case MemoryGameState.feedback:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
              child: const Icon(Icons.check, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Phase 4: Feedback",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
                  ),
                  Text(
                    "Check your spelling and correctness below.",
                    style: TextStyle(color: Colors.white70, fontSize: 13, fontFamily: 'Outfit'),
                  ),
                ],
              ),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPhaseActionButton() {
    if (_gameState == MemoryGameState.memorize) {
      return ElevatedButton(
        onPressed: _skipMemorize,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: const Text(
          "I'M READY",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Outfit'),
        ),
      );
    } else if (_gameState == MemoryGameState.disappearing) {
      return ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey.shade800,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: const Text(
          "DISAPPEARING...",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Outfit', color: Colors.white38),
        ),
      );
    } else if (_gameState == MemoryGameState.input) {
      return ElevatedButton(
        onPressed: _submitAnswers,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0284C7),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: const Text(
          "SUBMIT ANSWERS",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Outfit'),
        ),
      );
    } else if (_gameState == MemoryGameState.feedback) {
      return ElevatedButton(
        onPressed: _nextVerse,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: const Text(
          "NEXT VERSE",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Outfit'),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildSummaryScreen() {
        final totalPercentage = _totalPossibleWords > 0 
        ? ((_totalCorrectWords / _totalPossibleWords) * 100).round() 
        : 0;
    final xpEarned = _totalCorrectWords * 5;
    
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
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.celebration_rounded, size: 80, color: Color(0xFFFFD700)),
                    const SizedBox(height: 24),
                    const Text(
                      "Memory Master!",
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Outfit'),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "You completed the Scripture Memory Game",
                      style: TextStyle(fontSize: 15, color: Colors.white70, fontFamily: 'Outfit'),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    
                    // Stats card
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                          ),
                          child: Column(
                            children: [
                              _buildStatRow("Accuracy", "$totalPercentage%"),
                              const SizedBox(height: 12),
                              _buildStatRow("Recalled Words", "$_totalCorrectWords/$_totalPossibleWords"),
                              const SizedBox(height: 12),
                              _buildStatRow("XP Awarded", "+$xpEarned XP"),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    
                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white10,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                            ),
                          ).child(
                            InkWell(
                              onTap: () {
                                final shareText = "I just recalled $_totalCorrectWords words in the Scripture Memory Game of Bible Quiz app! Can you beat my score? 🧠🏆";
                                Share.share(shareText);
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.share, size: 18),
                                  SizedBox(width: 8),
                                  Text("SHARE RESULT", style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0284C7),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("CLAIM & EXIT", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Outfit')),
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

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14, fontFamily: 'Outfit')),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
      ],
    );
  }
}

extension on ButtonStyle {
  Widget child(Widget child) {
    return ElevatedButton(
      onPressed: null,
      style: this,
      child: child,
    );
  }
}
