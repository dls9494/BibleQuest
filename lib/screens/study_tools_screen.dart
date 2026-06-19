import '../widgets/gradient_background.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/flashcard.dart';
import '../providers/locale_provider.dart';
import '../providers/user_data_provider.dart';
import '../services/firebase_service.dart';
import '../widgets/bilingual_text.dart';

class StudyToolsScreen extends StatefulWidget {
  const StudyToolsScreen({super.key});

  @override
  State<StudyToolsScreen> createState() => _StudyToolsScreenState();
}

class _StudyToolsScreenState extends State<StudyToolsScreen> with SingleTickerProviderStateMixin {
  List<Flashcard> _cards = [];
  int _currentIndex = 0;
  bool _showBack = false;

  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _cards = FirebaseService.getFlashcards();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
    _flipAnimation.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _flip() {
    if (_showBack) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() => _showBack = !_showBack);
  }

  void _toggleMastered() {
    final card = _cards[_currentIndex];
    final userProvider = context.read<UserDataProvider>();
    final wasMastered = userProvider.masteredFlashcards.contains(card.id);
    userProvider.markFlashcardMastered(card.id, !wasMastered);
  }

  void _nextCard() {
    if (_currentIndex < _cards.length - 1) {
      setState(() {
        _currentIndex++;
        _showBack = false;
        _flipController.reset();
      });
    }
  }

  void _prevCard() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _showBack = false;
        _flipController.reset();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final lp = context.watch<LocaleProvider>();
    if (_cards.isEmpty) {
      return const Scaffold(
        backgroundColor: Color(0xFF121414),
        body: Center(child: Text("No flashcards available.", style: TextStyle(color: Colors.white, fontFamily: 'Outfit'))),
      );
    }

    final masteredFlashcards = context.select<UserDataProvider, Set<String>>((p) => p.masteredFlashcards);
    final card = _cards[_currentIndex];
    final isMastered = masteredFlashcards.contains(card.id);
    final double progress = _cards.isEmpty ? 0.0 : (masteredFlashcards.length / _cards.length).clamp(0.0, 1.0);

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          const Positioned.fill(child: GradientBackground(child: SizedBox.shrink())),
          // Ambient background lights
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
          // Content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Color(0xFF38BDF8)),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        "Scripture Mastery",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Outfit',
                        ),
                      ),
                      const SizedBox(width: 48), // Spacer to balance back button
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 16),
                        
                        // Progress Tracker Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Mastered",
                              style: TextStyle(
                                color: Color(0xFFCBC3D4),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Outfit',
                              ),
                            ),
                            Text(
                              "${masteredFlashcards.length} / ${_cards.length}",
                              style: const TextStyle(
                                color: Color(0xFF38BDF8),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Outfit',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Custom glass progress bar
                        Container(
                          height: 8,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Stack(
                            children: [
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    width: constraints.maxWidth * progress,
                                    height: double.infinity,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF4ADE80),
                                      borderRadius: BorderRadius.circular(4),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF4ADE80).withValues(alpha: 0.5),
                                          blurRadius: 8,
                                        )
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),

                        // 3D Flip Card Container
                        Center(
                          child: GestureDetector(
                            onTap: _flip,
                            child: SizedBox(
                              width: 320,
                              height: 400,
                              child: AnimatedBuilder(
                                animation: _flipAnimation,
                                builder: (context, child) {
                                  final double value = _flipAnimation.value;
                                  final bool isFront = value < 0.5;

                                  // Apply custom 3D rotation transform matrix
                                  return Transform(
                                    transform: Matrix4.identity()
                                      ..setEntry(3, 2, 0.001)
                                      ..rotateY(value * 3.14159265),
                                    alignment: Alignment.center,
                                    child: isFront
                                        ? _buildCardFront(card, lp)
                                        : Transform(
                                            transform: Matrix4.identity()..rotateY(3.14159265),
                                            alignment: Alignment.center,
                                            child: _buildCardBack(card, lp),
                                          ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Controls Panel
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Previous Card Button
                            _buildCircleButton(
                              icon: Icons.arrow_back,
                              onPressed: _currentIndex > 0 ? _prevCard : null,
                            ),
                            const SizedBox(width: 24),
                            // Got It Mastered Toggle Button (Large Center Button)
                            GestureDetector(
                              onTap: _toggleMastered,
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: isMastered ? const Color(0xFFF97316) : const Color(0xFF22C55E),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: (isMastered ? const Color(0xFFF97316) : const Color(0xFF22C55E))
                                          .withValues(alpha: 0.4),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                    )
                                  ],
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 24),
                            // Next Card Button
                            _buildCircleButton(
                              icon: Icons.arrow_forward,
                              onPressed: _currentIndex < _cards.length - 1 ? _nextCard : null,
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
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

  Widget _buildCardFront(Flashcard card, LocaleProvider lp) {
    return _buildCardBase(
      borderColor: BorderSide(color: Colors.white.withValues(alpha: 0.2), width: 1.0),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF3B4665),
          Color(0xFF1E2020),
        ],
      ),
      icon: Icons.menu_book,
      iconColor: Colors.white.withValues(alpha: 0.2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BilingualText(
            englishText: card.referenceEn,
            teluguText: card.referenceTe,
            englishStyle: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              fontFamily: 'NotoSerif',
            ),
            teluguStyle: const TextStyle(
              color: Color(0xFFBBC5EB),
              fontSize: 32,
              fontWeight: FontWeight.bold,
              fontFamily: 'NotoSerifTelugu',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.touch_app, color: Colors.white.withValues(alpha: 0.4), size: 14),
              const SizedBox(width: 6),
              Text(
                "Tap to flip",
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 13,
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardBack(Flashcard card, LocaleProvider lp) {
    return _buildCardBase(
      borderColor: BorderSide(color: const Color(0xFFF7BC64).withValues(alpha: 0.3), width: 1.5),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF825600),
          Color(0xFF1E2020),
        ],
      ),
      icon: Icons.format_quote,
      iconColor: const Color(0xFFF7BC64).withValues(alpha: 0.2),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              card.verseEn,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                height: 1.5,
                fontFamily: 'NotoSerif',
              ),
              textAlign: TextAlign.center,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: SizedBox(
                width: 60,
                child: Divider(color: Color(0xFF825600), height: 1),
              ),
            ),
            Text(
              card.verseTe,
              style: const TextStyle(
                color: Color(0xFFFFD295),
                fontSize: 18,
                height: 1.6,
                fontWeight: FontWeight.bold,
                fontFamily: 'NotoSerifTelugu',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardBase({
    required BorderSide? borderColor,
    required Gradient gradient,
    required IconData icon,
    required Color iconColor,
    required Widget child,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(28.0),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(24),
            border: Border.fromBorderSide(borderColor ?? BorderSide.none),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 0,
                right: 0,
                child: Icon(
                  icon,
                  size: 48,
                  color: iconColor,
                ),
              ),
              Center(child: child),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircleButton({required IconData icon, required VoidCallback? onPressed}) {
    final bool disabled = onPressed == null;
    return Opacity(
      opacity: disabled ? 0.3 : 1.0,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: IconButton(
              icon: Icon(icon, color: const Color(0xFF38BDF8)),
              onPressed: onPressed,
            ),
          ),
        ),
      ),
    );
  }
}
