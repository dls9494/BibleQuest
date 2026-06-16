import 'package:flutter/material.dart';
import '../services/bible_service.dart';

class ThreeColumnSelector extends StatefulWidget {
  final String initialBookId;
  final int initialChapter;
  final int? initialVerse;
  final void Function(String bookId, int chapter, int verse) onSelected;
  final VoidCallback? onClose;

  const ThreeColumnSelector({
    super.key,
    required this.initialBookId,
    required this.initialChapter,
    this.initialVerse,
    required this.onSelected,
    this.onClose,
  });

  @override
  State<ThreeColumnSelector> createState() => _ThreeColumnSelectorState();
}

class _ThreeColumnSelectorState extends State<ThreeColumnSelector> {
  late List<BibleBook> _books;
  late String _selectedBookId;
  late int _selectedChapter;
  int? _selectedVerse;

  late ScrollController _bookController;
  late ScrollController _chapterController;
  late ScrollController _verseController;

  static const double _bookItemHeight = 48.0;

  @override
  void initState() {
    super.initState();
    _books = BibleService.getBooks();
    _selectedBookId = widget.initialBookId.toLowerCase().replaceAll(' ', '');
    _selectedChapter = widget.initialChapter;
    _selectedVerse = widget.initialVerse ?? 1;

    // Find initial offsets
    final bookIndex = _books.indexWhere((b) => b.id == _selectedBookId);
    final double initialBookOffset = bookIndex >= 0 ? bookIndex * _bookItemHeight : 0.0;

    _bookController = ScrollController(initialScrollOffset: initialBookOffset);
    _chapterController = ScrollController();
    _verseController = ScrollController();
    
    // We will do a post frame scroll to align initial chapter and verse
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentChapter();
      _scrollToCurrentVerse();
    });
  }

  @override
  void dispose() {
    _bookController.dispose();
    _chapterController.dispose();
    _verseController.dispose();
    super.dispose();
  }

  void _scrollToCurrentChapter() {
    if (_chapterController.hasClients) {
      final rowIndex = (_selectedChapter - 1) ~/ 2;
      _chapterController.jumpTo((rowIndex * 46.0).clamp(0.0, _chapterController.position.maxScrollExtent));
    }
  }

  void _scrollToCurrentVerse() {
    if (_verseController.hasClients) {
      final rowIndex = ((_selectedVerse ?? 1) - 1) ~/ 2;
      _verseController.jumpTo((rowIndex * 46.0).clamp(0.0, _verseController.position.maxScrollExtent));
    }
  }

  void _onBookSelected(String bookId) {
    setState(() {
      _selectedBookId = bookId;
      _selectedChapter = 1;
      _selectedVerse = 1;
    });

    if (_chapterController.hasClients) {
      _chapterController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
      );
    }
    if (_verseController.hasClients) {
      _verseController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _onChapterSelected(int chapter) {
    setState(() {
      _selectedChapter = chapter;
      _selectedVerse = 1;
    });

    if (_verseController.hasClients) {
      _verseController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF3E2723);
    final accentGold = const Color(0xFFFFD700);
    final borderGold = const Color(0xFFD4A574);

    final selectedBook = _books.firstWhere(
      (b) => b.id == _selectedBookId,
      orElse: () => _books.first,
    );

    final int totalChapters = selectedBook.chapters;
    final int totalVerses = BibleService.getVerseCount(_selectedBookId, _selectedChapter);

    return Column(
      children: [
        // ── Top Summary Header (Compact, 30-40% smaller) ──
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.black12,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current Selection',
                      style: TextStyle(
                        color: Color(0xFFFFD700),
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        fontFamily: 'Outfit',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${selectedBook.nameEn} $_selectedChapter:${_selectedVerse ?? 1}${selectedBook.nameTe.isNotEmpty ? " • ${selectedBook.nameTe} $_selectedChapter:${_selectedVerse ?? 1}" : ""}',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Outfit',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.navigation_rounded, color: Color(0xFFFFD700), size: 16),
            ],
          ),
        ),

        // ── Column Titles Header (Enhanced letters & accent) ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Row(
            children: [
              Expanded(
                flex: 2, // 50%
                child: Center(
                  child: Text(
                    'BOOK',
                    style: TextStyle(
                      color: accentGold,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      fontFamily: 'Outfit',
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1, // 25%
                child: Center(
                  child: Text(
                    'CHAPTER',
                    style: TextStyle(
                      color: accentGold,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      fontFamily: 'Outfit',
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1, // 25%
                child: Center(
                  child: Text(
                    'VERSE',
                    style: TextStyle(
                      color: accentGold,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      fontFamily: 'Outfit',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Columns Selector ──
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A).withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? Colors.white10 : Colors.black12,
                width: 1.2,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Books Column (50% width)
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(
                          color: isDark ? Colors.white10 : Colors.black12,
                          width: 1,
                        ),
                      ),
                    ),
                    child: ListView.builder(
                      controller: _bookController,
                      itemCount: _books.length,
                      itemExtent: _bookItemHeight,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      itemBuilder: (context, index) {
                        final book = _books[index];
                        final isSelected = book.id == _selectedBookId;

                        return GestureDetector(
                          onTap: () => _onBookSelected(book.id),
                          child: AnimatedScale(
                            scale: isSelected ? 1.04 : 1.0,
                            duration: const Duration(milliseconds: 150),
                            curve: Curves.easeOutCubic,
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? borderGold.withValues(alpha: 0.15)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected ? borderGold : Colors.transparent,
                                  width: 1.2,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: accentGold.withValues(alpha: 0.2),
                                          blurRadius: 6,
                                          spreadRadius: 0.5,
                                        )
                                      ]
                                    : null,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    book.nameEn,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: isSelected ? accentGold : textColor,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      fontSize: 12.5,
                                      fontFamily: 'Outfit',
                                    ),
                                  ),
                                  if (book.nameTe.isNotEmpty)
                                    Text(
                                      book.nameTe,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: isSelected ? borderGold : textColor.withValues(alpha: 0.5),
                                        fontSize: 10,
                                        fontFamily: 'NotoSansTelugu',
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
                ),

                // 2. Chapters Column (25% width - Selectable Pills Grid)
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(
                          color: isDark ? Colors.white10 : Colors.black12,
                          width: 1,
                        ),
                      ),
                    ),
                    child: GridView.builder(
                      controller: _chapterController,
                      padding: const EdgeInsets.all(6),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.1,
                        mainAxisSpacing: 6,
                        crossAxisSpacing: 6,
                      ),
                      itemCount: totalChapters,
                      itemBuilder: (context, index) {
                        final chapterNum = index + 1;
                        final isSelected = chapterNum == _selectedChapter;

                        return GestureDetector(
                          onTap: () => _onChapterSelected(chapterNum),
                          child: AnimatedScale(
                            scale: isSelected ? 1.08 : 1.0,
                            duration: const Duration(milliseconds: 150),
                            curve: Curves.easeOutCubic,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? accentGold.withValues(alpha: 0.15)
                                    : (isDark ? Colors.white.withValues(alpha: 0.02) : Colors.black.withValues(alpha: 0.01)),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected
                                      ? accentGold
                                      : (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05)),
                                  width: 1.2,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: accentGold.withValues(alpha: 0.25),
                                          blurRadius: 6,
                                          spreadRadius: 1,
                                        )
                                      ]
                                    : null,
                              ),
                              child: Text(
                                '$chapterNum',
                                style: TextStyle(
                                  color: isSelected ? accentGold : textColor,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                  fontSize: 13,
                                  fontFamily: 'Outfit',
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // 3. Verses Column (25% width - Selectable Pills Grid)
                Expanded(
                  flex: 1,
                  child: GridView.builder(
                    controller: _verseController,
                    padding: const EdgeInsets.all(6),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.1,
                      mainAxisSpacing: 6,
                      crossAxisSpacing: 6,
                    ),
                    itemCount: totalVerses,
                    itemBuilder: (context, index) {
                      final verseNum = index + 1;
                      final isSelected = verseNum == _selectedVerse;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedVerse = verseNum;
                          });
                          widget.onSelected(_selectedBookId, _selectedChapter, verseNum);
                        },
                        child: AnimatedScale(
                          scale: isSelected ? 1.08 : 1.0,
                          duration: const Duration(milliseconds: 150),
                          curve: Curves.easeOutCubic,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? accentGold.withValues(alpha: 0.15)
                                  : (isDark ? Colors.white.withValues(alpha: 0.02) : Colors.black.withValues(alpha: 0.01)),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? accentGold
                                    : (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05)),
                                width: 1.2,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: accentGold.withValues(alpha: 0.25),
                                        blurRadius: 6,
                                        spreadRadius: 1,
                                      )
                                    ]
                                  : null,
                            ),
                            child: Text(
                              '$verseNum',
                              style: TextStyle(
                                color: isSelected ? accentGold : textColor,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                fontSize: 13,
                                fontFamily: 'Outfit',
                              ),
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
      ],
    );
  }
}
