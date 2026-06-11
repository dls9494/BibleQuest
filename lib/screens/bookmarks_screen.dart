import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/quiz.dart';
import '../providers/user_data_provider.dart';
import '../services/real_questions.dart';
import '../services/bible_service.dart';
import 'bible_screen.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class BookmarkedVerse {
  final String ref;
  final String bookId;
  final int chapter;
  final int verse;
  final String textTe;
  final String textEn;

  BookmarkedVerse({
    required this.ref,
    required this.bookId,
    required this.chapter,
    required this.verse,
    required this.textTe,
    required this.textEn,
  });
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  int _selectedTabIndex = 0; // 0: Quiz, 1: Bible

  List<Question> _loadBookmarkedQuestions(List<String> bookmarkedIds) {
    List<Question> list = [];
    if (bookmarkedIds.isEmpty) return list;

    // Search cached questions in RealQuestionsService
    for (int level = 1; level <= 50; level++) {
      for (String setId in ['A', 'B', 'C']) {
        final rawQuestions = RealQuestionsService.getQuestionsForLevel(level, setId);
        for (var qMap in rawQuestions) {
          final question = Question.fromMap(qMap);
          if (bookmarkedIds.contains(question.id)) {
            list.add(question);
          }
        }
      }
    }
    return list;
  }

  Future<List<BookmarkedVerse>> _loadBookmarkedVerses(Set<String> verseRefs) async {
    List<BookmarkedVerse> list = [];
    for (final ref in verseRefs) {
      final parts = ref.split('_');
      if (parts.length < 3) continue;
      final bookId = parts[0];
      final chapter = int.tryParse(parts[1]) ?? 1;
      final verse = int.tryParse(parts[2]) ?? 1;
      
      try {
        final teMap = await BibleService.getChapter(bookId, chapter, 'te');
        final enMap = await BibleService.getChapter(bookId, chapter, 'kjv');
        list.add(BookmarkedVerse(
          ref: ref,
          bookId: bookId,
          chapter: chapter,
          verse: verse,
          textTe: teMap[verse] ?? 'ఈ వచనం అందుబాటులో లేదు.',
          textEn: enMap[verse] ?? 'This verse is not available.',
        ));
      } catch (_) {}
    }
    // Sort logically by bible canon order
    final allBooks = BibleService.getBooks();
    list.sort((a, b) {
      final indexA = allBooks.indexWhere((book) => book.id == a.bookId);
      final indexB = allBooks.indexWhere((book) => book.id == b.bookId);
      if (indexA != indexB) return indexA.compareTo(indexB);
      if (a.chapter != b.chapter) return a.chapter.compareTo(b.chapter);
      return a.verse.compareTo(b.verse);
    });
    return list;
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String description,
    required Color textColor,
    required Color subTextColor,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 70,
              color: subTextColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Outfit',
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: subTextColor,
                fontFamily: 'Outfit',
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserDataProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF3E2723);
    final subTextColor = isDark ? Colors.white70 : const Color(0xFF5D4037);

    final bookmarkedIds = userProvider.getBookmarkedQuestions();
    final questions = _loadBookmarkedQuestions(bookmarkedIds);

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
                    ? const [Color(0xFF1A1A2E), Color(0xFF0F3460)]
                    : const [Color(0xFFFDF6EC), Color(0xFFF3E7D8)],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Custom App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "My Bookmarks 📚",
                        style: TextStyle(
                          color: textColor,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Outfit',
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white24, height: 1),

                // Tab Selection Segmented Control
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedTabIndex = 0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _selectedTabIndex == 0
                                    ? const Color(0xFFFFD700).withValues(alpha: 0.2)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: _selectedTabIndex == 0
                                    ? Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.4))
                                    : null,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "Quiz Bookmarks",
                                style: TextStyle(
                                  color: _selectedTabIndex == 0 ? const Color(0xFFFFD700) : textColor.withValues(alpha: 0.6),
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Outfit',
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedTabIndex = 1),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _selectedTabIndex == 1
                                    ? const Color(0xFFFFD700).withValues(alpha: 0.2)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: _selectedTabIndex == 1
                                    ? Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.4))
                                    : null,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "Bible Bookmarks",
                                style: TextStyle(
                                  color: _selectedTabIndex == 1 ? const Color(0xFFFFD700) : textColor.withValues(alpha: 0.6),
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Outfit',
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                Expanded(
                  child: _selectedTabIndex == 0
                      ? (questions.isEmpty
                          ? _buildEmptyState(
                              icon: Icons.bookmark_outline_rounded,
                              title: "No Quiz Bookmarks",
                              description: "Bookmark difficult questions during quizzes to review them later here.",
                              textColor: textColor,
                              subTextColor: subTextColor,
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16.0),
                              itemCount: questions.length,
                              itemBuilder: (context, index) {
                                final question = questions[index];
                                return BookmarkCard(
                                  key: Key(question.id),
                                  question: question,
                                  onDismissed: () {
                                    userProvider.toggleBookmark(question.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text("Bookmark removed"),
                                        action: SnackBarAction(
                                          label: "Undo",
                                          onPressed: () {
                                            userProvider.toggleBookmark(question.id);
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                  isDark: isDark,
                                  textColor: textColor,
                                  subTextColor: subTextColor,
                                );
                              },
                            ))
                      : FutureBuilder<List<BookmarkedVerse>>(
                          future: _loadBookmarkedVerses(userProvider.bookmarkedVerseRefs),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
                                ),
                              );
                            }
                            if (snapshot.hasError) {
                              return Center(
                                child: Text(
                                  "Error: ${snapshot.error}",
                                  style: TextStyle(color: textColor, fontFamily: 'Outfit'),
                                ),
                              );
                            }
                            final verses = snapshot.data ?? [];
                            if (verses.isEmpty) {
                              return _buildEmptyState(
                                icon: Icons.menu_book_rounded,
                                title: "No Bible Bookmarks",
                                description: "Tap the bookmark icon next to a verse in the Bible reader to save it here.",
                                textColor: textColor,
                                subTextColor: subTextColor,
                              );
                            }

                            return ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              itemCount: verses.length,
                              itemBuilder: (context, index) {
                                final v = verses[index];
                                final book = BibleService.getBookById(v.bookId);
                                final bookName = book?.nameEn ?? v.bookId;
                                final reference = '$bookName ${v.chapter}:${v.verse}';

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12.0),
                                  child: Dismissible(
                                    key: Key(v.ref),
                                    direction: DismissDirection.endToStart,
                                    onDismissed: (direction) {
                                      userProvider.toggleVerseBookmark(v.ref);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text("Removed $reference bookmark"),
                                          action: SnackBarAction(
                                            label: "Undo",
                                            onPressed: () {
                                              userProvider.toggleVerseBookmark(v.ref);
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                    background: Container(
                                      alignment: Alignment.centerRight,
                                      padding: const EdgeInsets.only(right: 20.0),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade900,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 28),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(
                                              color: isDark ? Colors.white12 : const Color(0xFFD4A574).withValues(alpha: 0.3),
                                              width: 1,
                                            ),
                                          ),
                                          child: Material(
                                            color: Colors.transparent,
                                            borderRadius: BorderRadius.circular(16),
                                            child: InkWell(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) => BibleScreen(
                                                      initialBook: v.bookId,
                                                      initialChapter: v.chapter,
                                                      initialVerse: v.verse,
                                                    ),
                                                  ),
                                                );
                                              },
                                              borderRadius: BorderRadius.circular(16),
                                              child: Padding(
                                                padding: const EdgeInsets.all(16.0),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        const Icon(Icons.bookmark, color: Color(0xFFFFD700), size: 18),
                                                        const SizedBox(width: 8),
                                                        Text(
                                                          reference,
                                                          style: const TextStyle(
                                                            color: Color(0xFFFFD700),
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 14,
                                                            fontFamily: 'Outfit',
                                                          ),
                                                        ),
                                                        const Spacer(),
                                                        Icon(
                                                          Icons.chevron_right_rounded,
                                                          color: subTextColor.withValues(alpha: 0.5),
                                                          size: 20,
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      v.textTe,
                                                      maxLines: 3,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        color: textColor.withValues(alpha: 0.9),
                                                        fontSize: 14,
                                                        fontFamily: 'NotoSansTelugu',
                                                        height: 1.4,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      v.textEn,
                                                      maxLines: 3,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        color: textColor.withValues(alpha: 0.7),
                                                        fontSize: 13,
                                                        fontFamily: 'Outfit',
                                                        fontStyle: FontStyle.italic,
                                                        height: 1.4,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
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
        ],
      ),
    );
  }
}

class BookmarkCard extends StatefulWidget {
  final Question question;
  final VoidCallback onDismissed;
  final bool isDark;
  final Color textColor;
  final Color subTextColor;

  const BookmarkCard({
    super.key,
    required this.question,
    required this.onDismissed,
    required this.isDark,
    required this.textColor,
    required this.subTextColor,
  });

  @override
  State<BookmarkCard> createState() => _BookmarkCardState();
}

class _BookmarkCardState extends State<BookmarkCard> {
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    final question = widget.question;

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Dismissible(
        key: Key(question.id),
        direction: DismissDirection.endToStart,
        onDismissed: (direction) => widget.onDismissed(),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20.0),
          decoration: BoxDecoration(
            color: Colors.red.shade900,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 28),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: widget.isDark ? 12.0 : 0, sigmaY: widget.isDark ? 12.0 : 0),
            child: Container(
              decoration: BoxDecoration(
                color: widget.isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.isDark ? Colors.white12 : const Color(0xFFD4A574).withValues(alpha: 0.3),
                  width: 1,
                ),
                boxShadow: widget.isDark
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
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
                    // Question text
                    Text(
                      question.questionTe,
                      style: TextStyle(
                        color: widget.textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'NotoSerifTelugu',
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      question.questionEn,
                      style: TextStyle(
                        color: widget.textColor.withValues(alpha: 0.8),
                        fontSize: 14,
                        fontFamily: 'NotoSerif',
                        fontStyle: FontStyle.italic,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Tap to reveal / Revealed section
                    if (!_revealed)
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _revealed = true;
                          });
                        },
                        icon: const Icon(Icons.visibility_rounded, size: 18),
                        label: const Text("Reveal Answer", style: TextStyle(fontFamily: 'Outfit')),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C4AB6),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Divider(color: Colors.white24),
                          const SizedBox(height: 8),
                          // Options list
                          ...question.options.map((option) {
                            final isCorrect = option.isCorrect;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8.0),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: isCorrect
                                    ? Colors.green.withValues(alpha: 0.2)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isCorrect
                                      ? Colors.green
                                      : (widget.isDark ? Colors.white12 : Colors.black12),
                                  width: isCorrect ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isCorrect
                                        ? Icons.check_circle_rounded
                                        : Icons.radio_button_off_rounded,
                                    color: isCorrect ? Colors.green : widget.subTextColor.withValues(alpha: 0.6),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          option.textTe,
                                          style: TextStyle(
                                            color: widget.textColor,
                                            fontSize: 13,
                                            fontWeight: isCorrect ? FontWeight.bold : FontWeight.normal,
                                            fontFamily: 'NotoSerifTelugu',
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          option.textEn,
                                          style: TextStyle(
                                            color: widget.textColor.withValues(alpha: 0.7),
                                            fontSize: 12,
                                            fontStyle: FontStyle.italic,
                                            fontFamily: 'NotoSerif',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          
                          const SizedBox(height: 12),
                          // Verse Reference
                          if (question.verseReferenceTe.isNotEmpty || question.verseReferenceEn.isNotEmpty) ...[
                            Row(
                              children: [
                                const Icon(Icons.bookmark_outline_rounded, color: Colors.amber, size: 16),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    "${question.verseReferenceTe} / ${question.verseReferenceEn}",
                                    style: const TextStyle(
                                      color: Colors.amber,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      fontFamily: 'Outfit',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                          ],
                          
                          // Explanation
                          if (question.explanationTe.isNotEmpty || question.explanationEn.isNotEmpty) ...[
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: widget.isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.02),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    question.explanationTe,
                                    style: TextStyle(
                                      color: widget.textColor.withValues(alpha: 0.9),
                                      fontSize: 13,
                                      fontFamily: 'NotoSerifTelugu',
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    question.explanationEn,
                                    style: TextStyle(
                                      color: widget.textColor.withValues(alpha: 0.8),
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                      fontFamily: 'NotoSerif',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          
                          const SizedBox(height: 12),
                          // Hide button
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _revealed = false;
                              });
                            },
                            icon: const Icon(Icons.visibility_off_rounded, size: 16),
                            label: const Text("Hide Answer", style: TextStyle(fontFamily: 'Outfit')),
                            style: TextButton.styleFrom(
                              foregroundColor: widget.textColor.withValues(alpha: 0.6),
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
  }
}
