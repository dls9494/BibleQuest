import 'package:flutter/material.dart';
import '../models/quiz.dart';
import '../services/bible_service.dart';
import '../services/custom_quiz_generator.dart';
import 'self_paced_screen.dart';
import '../widgets/gradient_background.dart';

// Represents a selected book with its chapter range
class _BookRange {
  final String bookId;
  int fromChapter;
  int toChapter;

  _BookRange({required this.bookId, required this.fromChapter, required this.toChapter});
}

class CustomQuizCreatorScreen extends StatefulWidget {
  const CustomQuizCreatorScreen({super.key});

  @override
  State<CustomQuizCreatorScreen> createState() => _CustomQuizCreatorScreenState();
}

class _CustomQuizCreatorScreenState extends State<CustomQuizCreatorScreen> {
  int _currentStep = 0;

  // Multi-book selection state
  final List<_BookRange> _selectedBooks = [];
  String _testamentFilter = 'OT';
  String _searchQuery = '';

  // Options
  int _questionCount = 10;
  String _selectedVersion = 'te'; // 'te' | 'kjv'
  String _difficulty = 'medium'; // 'easy' | 'medium' | 'hard'

  bool _isGenerating = false;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1E1E30),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF38BDF8),
          brightness: Brightness.dark,
        ),
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text(
            'Custom Chapter Quiz',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Outfit',
              color: Colors.white,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              if (_currentStep > 0) {
                setState(() => _currentStep--);
              } else {
                Navigator.pop(context);
              }
            },
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
        body: Stack(
          children: [
            const Positioned.fill(
              child: GradientBackground(child: SizedBox.shrink()),
            ),
            SafeArea(
              child: Column(
                children: [
                  // Step Indicator Header
                  _buildStepIndicator(),

                  // Main Step Content
                  Expanded(
                    child: _isGenerating
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(color: Color(0xFF38BDF8)),
                                SizedBox(height: 16),
                                Text(
                                  'Generating your custom quiz...',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                    fontFamily: 'Outfit',
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Container(
                            margin: const EdgeInsets.all(16),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                            ),
                            child: _buildCurrentStepContent(),
                          ),
                  ),

                  // Bottom Actions Navigation
                  if (!_isGenerating) _buildNavigationActions(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    final steps = ['Books', 'Options', 'Generate'];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(steps.length, (index) {
          final isCompleted = index < _currentStep;
          final isActive = index == _currentStep;
          return Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? const Color(0xFF4ADE80)
                        : isActive
                            ? const Color(0xFF38BDF8)
                            : Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isActive ? const Color(0xFF38BDF8) : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: isCompleted
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: isActive || isCompleted ? Colors.white : Colors.white60,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    steps[index],
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isActive
                          ? const Color(0xFF38BDF8)
                          : isCompleted
                              ? Colors.white70
                              : Colors.white38,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                      fontFamily: 'Outfit',
                    ),
                  ),
                ),
                if (index < steps.length - 1) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right,
                    size: 14,
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ],
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildBookSelectionStep();
      case 1:
        return _buildOptionsStep();
      case 2:
        return _buildSummaryStep();
      default:
        return const SizedBox.shrink();
    }
  }

  // ─── Step 0: Multi-book selection ──────────────────────────────────────────
  Widget _buildBookSelectionStep() {
    final allBooks = _testamentFilter == 'OT'
        ? BibleService.getOTBooks()
        : BibleService.getNTBooks();

    final filteredBooks = allBooks.where((b) {
      final q = _searchQuery.toLowerCase();
      return b.nameEn.toLowerCase().contains(q) || b.nameTe.contains(q);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Testament Toggle Selector
        Row(
          children: [
            Expanded(child: _buildTestamentButton('OT', 'Old Testament')),
            const SizedBox(width: 12),
            Expanded(child: _buildTestamentButton('NT', 'New Testament')),
          ],
        ),
        const SizedBox(height: 12),
        // Selected books summary
        if (_selectedBooks.isNotEmpty) ...[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _selectedBooks.map((br) {
                final book = BibleService.getBookById(br.bookId);
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Chip(
                    backgroundColor: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                    side: const BorderSide(color: Color(0xFF38BDF8), width: 1),
                    label: Text(
                      '${book?.nameEn ?? br.bookId} ${br.fromChapter}-${br.toChapter}',
                      style: const TextStyle(
                        color: Color(0xFF38BDF8),
                        fontSize: 11,
                        fontFamily: 'Outfit',
                      ),
                    ),
                    deleteIconColor: const Color(0xFF38BDF8),
                    onDeleted: () {
                      setState(() {
                        _selectedBooks.removeWhere((b) => b.bookId == br.bookId);
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
        ],
        // Search bar
        TextField(
          onChanged: (val) {
            setState(() {
              _searchQuery = val;
            });
          },
          decoration: InputDecoration(
            hintText: 'Search book / పుస్తకాన్ని వెతకండి...',
            hintStyle: const TextStyle(color: Colors.white38),
            prefixIcon: const Icon(Icons.search, color: Colors.white38),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        const SizedBox(height: 12),
        if (_selectedBooks.isEmpty)
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              'Tap a book to add it. You can select multiple books.',
              style: TextStyle(color: Colors.white54, fontSize: 12, fontFamily: 'Outfit'),
              textAlign: TextAlign.center,
            ),
          ),
        // Books Grid/List
        Expanded(
          child: ListView.builder(
            itemCount: filteredBooks.length,
            itemBuilder: (context, index) {
              final b = filteredBooks[index];
              final isSelected = _selectedBooks.any((br) => br.bookId == b.id);
              final bookRange = isSelected
                  ? _selectedBooks.firstWhere((br) => br.bookId == b.id)
                  : null;

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF38BDF8).withValues(alpha: 0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF38BDF8)
                        : Colors.white.withValues(alpha: 0.05),
                  ),
                ),
                child: Column(
                  children: [
                    ListTile(
                      title: Text(
                        b.nameEn,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        b.nameTe,
                        style: const TextStyle(color: Colors.white60, fontFamily: 'NotoSansTelugu'),
                      ),
                      trailing: Text(
                        '${b.chapters} Ch',
                        style: const TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedBooks.removeWhere((br) => br.bookId == b.id);
                          } else {
                            _selectedBooks.add(_BookRange(
                              bookId: b.id,
                              fromChapter: 1,
                              toChapter: b.chapters,
                            ));
                          }
                        });
                      },
                    ),
                    // Chapter range controls when selected
                    if (isSelected && bookRange != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
                        child: Row(
                          children: [
                            const Text('Ch:', style: TextStyle(color: Colors.white60, fontSize: 12)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: DropdownButtonFormField<int>(
                                value: bookRange.fromChapter,
                                isDense: true,
                                decoration: InputDecoration(
                                  labelText: 'From',
                                  labelStyle: const TextStyle(fontSize: 11),
                                  filled: true,
                                  fillColor: Colors.white.withValues(alpha: 0.05),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                ),
                                items: List.generate(b.chapters, (i) => i + 1)
                                    .map((ch) => DropdownMenuItem(value: ch, child: Text('$ch', style: const TextStyle(fontSize: 12))))
                                    .toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() {
                                      bookRange.fromChapter = val;
                                      if (bookRange.toChapter < val) bookRange.toChapter = val;
                                    });
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: DropdownButtonFormField<int>(
                                value: bookRange.toChapter,
                                isDense: true,
                                decoration: InputDecoration(
                                  labelText: 'To',
                                  labelStyle: const TextStyle(fontSize: 11),
                                  filled: true,
                                  fillColor: Colors.white.withValues(alpha: 0.05),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                ),
                                items: List.generate(b.chapters - bookRange.fromChapter + 1, (i) => bookRange.fromChapter + i)
                                    .map((ch) => DropdownMenuItem(value: ch, child: Text('$ch', style: const TextStyle(fontSize: 12))))
                                    .toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() {
                                      bookRange.toChapter = val;
                                    });
                                  }
                                },
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
        ),
      ],
    );
  }

  Widget _buildTestamentButton(String testament, String label) {
    final isSelected = _testamentFilter == testament;
    return GestureDetector(
      onTap: () {
        setState(() {
          _testamentFilter = testament;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF38BDF8).withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF38BDF8) : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          testament,
          style: TextStyle(
            color: isSelected ? const Color(0xFF38BDF8) : Colors.white70,
            fontWeight: FontWeight.bold,
            fontFamily: 'Outfit',
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // ─── Step 1: Options (count, version, difficulty) ─────────────────────────
  Widget _buildOptionsStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Quiz Settings',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Outfit',
            ),
          ),
          const SizedBox(height: 28),

          // Question count
          const Text('Question Count', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [5, 10, 15, 20].map((count) {
              final isSelected = _questionCount == count;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _questionCount = count),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF38BDF8).withValues(alpha: 0.15)
                          : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF38BDF8) : Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$count',
                      style: TextStyle(
                        color: isSelected ? const Color(0xFF38BDF8) : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),

          // Difficulty
          const Text('Difficulty', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 12),
          _buildDifficultySelector(),
          const SizedBox(height: 28),

          // Language version
          const Text('Language', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildVersionPill('te', 'Telugu / తెలుగు')),
              const SizedBox(width: 12),
              Expanded(child: _buildVersionPill('kjv', 'English (KJV)')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultySelector() {
    final difficulties = [
      {
        'key': 'easy',
        'label': 'Easy',
        'desc': 'Simple recall: who, what, where',
        'icon': Icons.sentiment_satisfied_rounded,
        'color': const Color(0xFF4ADE80),
      },
      {
        'key': 'medium',
        'label': 'Medium',
        'desc': 'Context: why, how, fill-in-blanks',
        'icon': Icons.sentiment_neutral_rounded,
        'color': const Color(0xFFFFD700),
      },
      {
        'key': 'hard',
        'label': 'Hard',
        'desc': 'Cross-ref, obscure details',
        'icon': Icons.sentiment_very_dissatisfied_rounded,
        'color': const Color(0xFFFF6B6B),
      },
    ];

    return Column(
      children: difficulties.map((d) {
        final isSelected = _difficulty == d['key'] as String;
        final color = d['color'] as Color;
        return GestureDetector(
          onTap: () => setState(() => _difficulty = d['key'] as String),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected ? color.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? color : Colors.white.withValues(alpha: 0.08),
                width: isSelected ? 1.5 : 1.0,
              ),
            ),
            child: Row(
              children: [
                Icon(d['icon'] as IconData, color: isSelected ? color : Colors.white38, size: 22),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        d['label'] as String,
                        style: TextStyle(
                          color: isSelected ? color : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          fontFamily: 'Outfit',
                        ),
                      ),
                      Text(
                        d['desc'] as String,
                        style: TextStyle(
                          color: isSelected ? color.withValues(alpha: 0.8) : Colors.white38,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check_circle_rounded, color: color, size: 18),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildVersionPill(String version, String label) {
    final isSelected = _selectedVersion == version;
    return GestureDetector(
      onTap: () => setState(() => _selectedVersion = version),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF38BDF8).withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF38BDF8) : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF38BDF8) : Colors.white70,
            fontWeight: FontWeight.bold,
            fontFamily: 'Outfit',
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // ─── Step 2: Summary ──────────────────────────────────────────────────────
  Widget _buildSummaryStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.verified_rounded, size: 64, color: Color(0xFF4ADE80)),
          const SizedBox(height: 20),
          const Text(
            'Quiz Ready!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: 'Outfit',
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Column(
              children: [
                // Books selected
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Books', style: TextStyle(color: Colors.white60, fontSize: 14)),
                    const Spacer(),
                    Flexible(
                      child: Text(
                        _selectedBooks.isEmpty
                            ? 'None selected'
                            : _selectedBooks.map((br) {
                                final b = BibleService.getBookById(br.bookId);
                                return '${b?.nameEn ?? br.bookId} ${br.fromChapter}-${br.toChapter}';
                              }).join(', '),
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24, thickness: 0.5),
                _buildSummaryRow('Questions', '$_questionCount'),
                const Divider(height: 24, thickness: 0.5),
                _buildSummaryRow('Difficulty', _difficulty[0].toUpperCase() + _difficulty.substring(1)),
                const Divider(height: 24, thickness: 0.5),
                _buildSummaryRow('Version', _selectedVersion == 'te' ? 'Telugu' : 'English (KJV)'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 14)),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ],
    );
  }

  // ─── Navigation ──────────────────────────────────────────────────────────
  Widget _buildNavigationActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          if (_currentStep > 0) ...[
            Expanded(
              child: ElevatedButton(
                onPressed: () => setState(() => _currentStep--),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.05),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                ),
                child: const Text('Back', style: TextStyle(fontFamily: 'Outfit')),
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: ElevatedButton(
              onPressed: _onNextPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF38BDF8),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
              ),
              child: Text(
                _currentStep == 2 ? 'GENERATE & PLAY' : 'Continue',
                style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onNextPressed() {
    if (_currentStep == 0) {
      // Validate at least one book selected
      if (_selectedBooks.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one book.')),
        );
        return;
      }
      setState(() => _currentStep++);
    } else if (_currentStep == 1) {
      setState(() => _currentStep++);
    } else {
      _generateQuiz();
    }
  }

  Future<void> _generateQuiz() async {
    if (_selectedBooks.isEmpty) return;
    setState(() => _isGenerating = true);

    try {
      final questions = await CustomQuizGenerator.generateMultiBookQuiz(
        bookRanges: _selectedBooks
            .map((br) => {'bookId': br.bookId, 'from': br.fromChapter, 'to': br.toChapter})
            .toList(),
        questionCount: _questionCount,
        version: _selectedVersion,
        difficulty: _difficulty,
      );

      if (questions.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No verses/questions found in selected range.')),
          );
        }
        setState(() => _isGenerating = false);
        return;
      }

      // Build title
      final booksLabel = _selectedBooks.map((br) {
        final b = BibleService.getBookById(br.bookId);
        return b?.nameEn ?? br.bookId;
      }).join('+');

      final customQuiz = Quiz(
        id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
        creatorId: 'custom',
        titleKey: 'custom',
        bibleVersion: _selectedVersion == 'te' ? 'BSI Telugu' : 'KJV',
        topics: const ['Custom'],
        isPublic: false,
        questionCount: questions.length,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        titleEn: 'Custom: $booksLabel ($_difficulty)',
        titleTe: 'కస్టమ్: $booksLabel',
        descriptionEn: 'Custom $_difficulty quiz from $booksLabel',
        descriptionTe: 'కస్టమ్ క్విజ్: $booksLabel',
        level: 1,
        difficulty: _difficulty,
      );

      if (mounted) {
        setState(() => _isGenerating = false);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => SelfPacedScreen(quiz: customQuiz, questions: questions),
          ),
        );
      }
    } catch (e) {
      // ignore: avoid_print
      print("Error generating quiz: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate quiz: $e')),
        );
      }
      setState(() => _isGenerating = false);
    }
  }
}
