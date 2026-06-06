import 'dart:math';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../providers/user_data_provider.dart';
import '../providers/locale_provider.dart';
import '../widgets/wisdom_tree_painter.dart';
import '../services/bible_service.dart';
import '../services/custom_quiz_generator.dart';
import '../models/quiz.dart';
import 'self_paced_screen.dart';

class WisdomTreeScreen extends StatefulWidget {
  const WisdomTreeScreen({super.key});

  @override
  State<WisdomTreeScreen> createState() => _WisdomTreeScreenState();
}

class _WisdomTreeScreenState extends State<WisdomTreeScreen> {
  final GlobalKey _globalKey = GlobalKey();
  String? _selectedBranch;
  Offset? _tooltipPosition;
  bool _loadingQuiz = false;
  bool _isSharing = false;

  static const Map<String, List<String>> _topicBooks = {
    'Torah': ['genesis', 'exodus', 'leviticus', 'numbers', 'deuteronomy'],
    'History': ['joshua', 'judges', 'ruth', '1samuel', '2samuel', '1kings', '2kings', '1chronicles', '2chronicles', 'ezra', 'nehemiah', 'esther'],
    'Wisdom': ['job', 'psalms', 'proverbs', 'ecclesiastes', 'songofsolomon'],
    'Prophets': ['isaiah', 'jeremiah', 'lamentations', 'ezekiel', 'daniel', 'hosea', 'joel', 'amos', 'obadiah', 'jonah', 'micah', 'nahum', 'habakkuk', 'zephaniah', 'haggai', 'zechariah', 'malachi'],
    'Gospels': ['matthew', 'mark', 'luke', 'john'],
    'Acts & Epistles': ['acts', 'romans', '1corinthians', '2corinthians', 'galatians', 'ephesians', 'philippians', 'colossians', '1thessalonians', '2thessalonians', '1timothy', '2timothy', 'titus', 'philemon', 'hebrews', 'james', '1peter', '2peter', '1john', '2john', '3john', 'jude'],
    'Revelation': ['revelation'],
  };

  Offset getBranchEnd(String name, double score, String stage) {
    double trunkHeight = 50.0;
    double maxBranchLength = 35.0;
    switch (stage) {
      case 'Seedling':
        trunkHeight = 40.0;
        maxBranchLength = 25.0;
        break;
      case 'Sprout':
        trunkHeight = 65.0;
        maxBranchLength = 35.0;
        break;
      case 'Young Tree':
        trunkHeight = 90.0;
        maxBranchLength = 50.0;
        break;
      case 'Growing Tree':
        trunkHeight = 120.0;
        maxBranchLength = 65.0;
        break;
      case 'Mature Tree':
        trunkHeight = 145.0;
        maxBranchLength = 80.0;
        break;
      case 'Flourishing Tree':
        trunkHeight = 160.0;
        maxBranchLength = 95.0;
        break;
    }

    final groundY = 360.0 - 25.0;
    final centerX = 320.0 / 2;

    double heightFraction = 0.5;
    double angleDeg = -90.0;

    switch (name) {
      case 'Torah':
        heightFraction = 0.35;
        angleDeg = -140;
        break;
      case 'History':
        heightFraction = 0.50;
        angleDeg = -125;
        break;
      case 'Wisdom':
        heightFraction = 0.70;
        angleDeg = -105;
        break;
      case 'Gospels':
        heightFraction = 0.95;
        angleDeg = -90;
        break;
      case 'Acts & Epistles':
        heightFraction = 0.80;
        angleDeg = -75;
        break;
      case 'Prophets':
        heightFraction = 0.60;
        angleDeg = -55;
        break;
      case 'Revelation':
        heightFraction = 0.40;
        angleDeg = -40;
        break;
    }

    final startY = groundY - (trunkHeight * heightFraction);
    final angleRad = angleDeg * pi / 180.0;
    final branchLength = 15.0 + (maxBranchLength - 15.0) * score;

    return Offset(
      centerX + branchLength * cos(angleRad),
      startY + branchLength * sin(angleRad),
    );
  }

  void _onTapUp(TapUpDetails details, Map<String, double> branchScores, String growthStage) {
    if (growthStage == 'Seedling') return;

    final localPosition = details.localPosition;
    String? closestBranch;
    double minDistance = double.infinity;

    final branches = ['Torah', 'History', 'Wisdom', 'Gospels', 'Acts & Epistles', 'Prophets', 'Revelation'];

    for (final branchName in branches) {
      final score = branchScores[branchName] ?? 0.0;
      final endPoint = getBranchEnd(branchName, score, growthStage);
      final dist = (localPosition - endPoint).distance;
      if (dist < minDistance) {
        minDistance = dist;
        closestBranch = branchName;
      }
    }

    if (minDistance < 40.0 && closestBranch != null) {
      setState(() {
        _selectedBranch = closestBranch;
        _tooltipPosition = getBranchEnd(closestBranch!, branchScores[closestBranch]!, growthStage);
      });
    } else {
      setState(() {
        _selectedBranch = null;
      });
    }
  }

  String _getRating(double score) {
    if (score < 0.3) return 'Bare';
    if (score < 0.6) return 'Leaves';
    if (score < 0.9) return 'Blossoms';
    return 'Fruitful';
  }

  void _startStudyQuiz(String topic) async {
    final books = _topicBooks[topic] ?? ['genesis'];
    final randomBookId = books[Random().nextInt(books.length)];
    final book = BibleService.getBookById(randomBookId);
    if (book == null) return;

    setState(() {
      _loadingQuiz = true;
    });

    try {
      final lp = context.read<LocaleProvider>();
      final version = lp.contentMode == ContentLanguageMode.telugu ? 'te' : 'kjv';

      final questions = await CustomQuizGenerator.generateQuiz(
        bookId: book.id,
        fromChapter: 1,
        toChapter: book.chapters,
        questionCount: 5,
        version: version,
      );

      if (!mounted) return;

      final quiz = Quiz(
        id: 'wisdom_tree_quiz_${topic.replaceAll(' ', '_')}_${book.id}',
        creatorId: 'system',
        titleKey: 'wisdom_tree_quiz',
        titleEn: '$topic Quiz: ${book.nameEn}',
        titleTe: '$topic క్విజ్: ${book.nameTe}',
        descriptionEn: 'Practice 5 questions in the $topic topic group focusing on ${book.nameEn}!',
        descriptionTe: '${book.nameTe} లో $topic కి సంబంధించిన 5 ప్రశ్నలను సాధన చేయండి!',
        difficulty: 'medium',
        topics: [topic],
        bibleVersion: version == 'te' ? 'BSI Telugu' : 'KJV English',
        isPublic: true,
        level: 1,
        questionCount: 5,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Dismiss tooltip
      setState(() {
        _selectedBranch = null;
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (ctx) => SelfPacedScreen(
            quiz: quiz,
            questions: questions,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating study quiz: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loadingQuiz = false;
        });
      }
    }
  }

  Future<void> _shareTreeImage(String name) async {
    setState(() {
      _isSharing = true;
      _selectedBranch = null; // Hide tooltip for clean image
    });

    // Wait for frame rendering
    await Future.delayed(const Duration(milliseconds: 100));

    try {
      final boundary = _globalKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData?.buffer.asUint8List();

      if (pngBytes != null) {
        final tempDir = await getTemporaryDirectory();
        final file = await File('${tempDir.path}/wisdom_tree.png').create();
        await file.writeAsBytes(pngBytes);

        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Take a look at my Wisdom Tree! 🌳 It grows as I study the Scriptures on the Bible Quiz App. My current growth stage is "$name". Join me!',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing image: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserDataProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final progressMap = userProvider.getTreeGrowthProgress();
    final growthStageName = progressMap['stage'] as String;
    final progressPercent = progressMap['percent'] as double;
    final nextStageName = progressMap['nextStage'] as String;

    final milestones = userProvider.getTreeMilestones();

    // Pull branch scores, providing default of 0.0 if not completed yet
    final branches = ['Torah', 'History', 'Wisdom', 'Gospels', 'Acts & Epistles', 'Prophets', 'Revelation'];
    final branchScores = <String, double>{};
    for (final b in branches) {
      branchScores[b] = userProvider.topicPerformance[b] ?? 0.0;
    }

    final textColor = isDark ? Colors.white : const Color(0xFF3E2723);
    final cardBg = isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white;
    final cardBorder = isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFD4A574).withValues(alpha: 0.3);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'My Wisdom Tree',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontFamily: 'Outfit',
            fontSize: 22,
          ),
        ),
        actions: [
          if (!_isSharing)
            IconButton(
              icon: Icon(Icons.share, color: textColor),
              onPressed: () {
                _shareTreeImage(growthStageName);
                userProvider.recordShare();
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
                    ? [const Color(0xFF1A1A2E), const Color(0xFF0F3460)]
                    : [const Color(0xFFFFFDF9), const Color(0xFFFBEEDB)],
              ),
            ),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  
                  // Top Info card
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: cardBorder, width: 1.5),
                        ),
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Text(
                              '🌳 Level ${userProvider.playerLevel} Tree',
                              style: TextStyle(
                                color: textColor,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Outfit',
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'The Wisdom Tree represents your progress. Correct quiz answers, reading, and streaks cause it to grow branches, foliage, and bear fruit.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isDark ? Colors.white70 : const Color(0xFF5D4037),
                                fontSize: 13,
                                height: 1.4,
                                fontFamily: 'Outfit',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // RepaintBoundary wrapping the visual tree canvas
                  Center(
                    child: RepaintBoundary(
                      key: _globalKey,
                      child: Container(
                        width: 320,
                        height: 360,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.black.withValues(alpha: 0.15) : Colors.amber.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: cardBorder, width: 1),
                        ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            GestureDetector(
                              onTapUp: (details) => _onTapUp(details, branchScores, growthStageName),
                              child: CustomPaint(
                                size: const Size(320, 360),
                                painter: WisdomTreePainter(
                                  growthStage: growthStageName,
                                  branchScores: branchScores,
                                  milestones: milestones,
                                  isDark: isDark,
                                ),
                              ),
                            ),
                            
                            // Interactive Tooltip Overlay
                            if (_selectedBranch != null && _tooltipPosition != null)
                              Positioned(
                                left: _tooltipPosition!.dx - 80,
                                top: _tooltipPosition!.dy - 110,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: BackdropFilter(
                                    filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                                    child: Container(
                                      width: 160,
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? Colors.black.withValues(alpha: 0.8)
                                            : Colors.white.withValues(alpha: 0.9),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                                          width: 1,
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            _selectedBranch!,
                                            style: TextStyle(
                                              color: textColor,
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Outfit',
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Mastery: ${(_getRating(branchScores[_selectedBranch!] ?? 0.0))}',
                                            style: TextStyle(
                                              color: isDark ? Colors.amber.shade200 : Colors.amber.shade800,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Outfit',
                                            ),
                                          ),
                                          Text(
                                            'Score: ${((branchScores[_selectedBranch!] ?? 0.0) * 100).round()}%',
                                            style: TextStyle(
                                              color: isDark ? Colors.white70 : Colors.black87,
                                              fontSize: 11,
                                              fontFamily: 'Outfit',
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          SizedBox(
                                            height: 24,
                                            width: double.infinity,
                                            child: ElevatedButton(
                                              onPressed: _loadingQuiz
                                                  ? null
                                                  : () => _startStudyQuiz(_selectedBranch!),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(0xFFFFD700),
                                                foregroundColor: Colors.black,
                                                padding: EdgeInsets.zero,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                              ),
                                              child: _loadingQuiz
                                                  ? const SizedBox(
                                                      height: 10,
                                                      width: 10,
                                                      child: CircularProgressIndicator(
                                                        strokeWidth: 1.5,
                                                        color: Colors.black,
                                                      ),
                                                    )
                                                  : const Text(
                                                      'Study More',
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.bold,
                                                        fontFamily: 'Outfit',
                                                      ),
                                                    ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  
                  if (growthStageName != 'Seedling')
                    Center(
                      child: Text(
                        '💡 Tap branch tips to view details and study more.',
                        style: TextStyle(
                          color: isDark ? Colors.white60 : const Color(0xFF5D4037).withValues(alpha: 0.8),
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          fontFamily: 'Outfit',
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Growth Stage Card
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: cardBorder, width: 1.5),
                        ),
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'GROWTH STAGE',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Outfit',
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      growthStageName,
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Outfit',
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${userProvider.totalXp} XP',
                                    style: const TextStyle(
                                      color: Color(0xFFFFD700),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      fontFamily: 'Outfit',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: progressPercent,
                                minHeight: 8,
                                backgroundColor: isDark ? Colors.white10 : Colors.grey[300],
                                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF81C784)),
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (nextStageName.isNotEmpty)
                              Text(
                                'Next Stage: $nextStageName',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                  fontFamily: 'Outfit',
                                ),
                                textAlign: TextAlign.right,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Active Milestones Ornaments Card
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: cardBorder, width: 1.5),
                        ),
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Tree Milestones',
                              style: TextStyle(
                                color: textColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Outfit',
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildMilestoneRow('🍂 Golden Leaf', '7-Day Study Streak', milestones.contains('golden_leaf')),
                            const SizedBox(height: 8),
                            _buildMilestoneRow('🕊️ Holy Dove', '30-Day Study Streak', milestones.contains('dove')),
                            const SizedBox(height: 8),
                            _buildMilestoneRow('✝ Trunk Cross', 'Reach Level 25', milestones.contains('cross')),
                            const SizedBox(height: 8),
                            _buildMilestoneRow('😇 Glowing Halo', 'Reach Level 50', milestones.contains('halo')),
                            const SizedBox(height: 8),
                            _buildMilestoneRow('🌈 Rainbow Canopy', 'Reach Level 100', milestones.contains('rainbow')),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneRow(String title, String subtitle, bool unlocked) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF3E2723);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: unlocked ? textColor : Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  fontFamily: 'Outfit',
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontFamily: 'Outfit',
                ),
              ),
            ],
          ),
        ),
        Icon(
          unlocked ? Icons.check_circle_rounded : Icons.lock_outline_rounded,
          color: unlocked ? const Color(0xFF81C784) : Colors.grey,
          size: 20,
        ),
      ],
    );
  }
}
