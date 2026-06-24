import 'package:flutter/material.dart';
import '../services/bible_service.dart';

class HybridSelector extends StatefulWidget {
  final String initialBookId;
  final int initialChapter;
  final int? initialVerse;
  final void Function(String bookId, int chapter, int verse) onSelected;

  const HybridSelector({
    super.key,
    required this.initialBookId,
    required this.initialChapter,
    this.initialVerse,
    required this.onSelected,
  });

  @override
  State<HybridSelector> createState() => _HybridSelectorState();
}

class _HybridSelectorState extends State<HybridSelector>
    with SingleTickerProviderStateMixin {
  late List<BibleBook> _books;
  late String _selectedBookId;
  late int _selectedChapter;
  late int _selectedVerse;

  late ScrollController _railController;
  late TabController _tabController;

  // Recents
  final List<String> _recents = ['Jn 3:16', 'Gen 1:1', 'Ps 119:1', 'Rev 22:1'];

  static const double _railItemHeight = 66.0;

  @override
  void initState() {
    super.initState();
    _books = BibleService.getBooks();
    _selectedBookId = widget.initialBookId.toLowerCase().replaceAll(' ', '');
    _selectedChapter = widget.initialChapter;
    _selectedVerse = widget.initialVerse ?? 1;

    _tabController = TabController(length: 2, vsync: this);

    final bookIndex = _books.indexWhere((b) => b.id == _selectedBookId);
    _railController = ScrollController(
      initialScrollOffset:
          bookIndex >= 0 ? (bookIndex * _railItemHeight).clamp(0.0, double.infinity) : 0.0,
    );
  }

  @override
  void dispose() {
    _railController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  BibleBook get _selectedBook =>
      _books.firstWhere((b) => b.id == _selectedBookId, orElse: () => _books.first);

  void _onBookSelected(String bookId) {
    setState(() {
      _selectedBookId = bookId;
      _selectedChapter = 1;
      _selectedVerse = 1;
    });
    _tabController.animateTo(0);
  }

  void _onChapterSelected(int chapter) {
    setState(() {
      _selectedChapter = chapter;
      _selectedVerse = 1;
    });
    _tabController.animateTo(1);
  }

  void _onVerseSelected(int verse) {
    setState(() => _selectedVerse = verse);
    widget.onSelected(_selectedBookId, _selectedChapter, verse);
  }

  String get _refBadge {
    final abbr = _selectedBook.nameEn.length > 4
        ? _selectedBook.nameEn.substring(0, 3)
        : _selectedBook.nameEn;
    return '$abbr $_selectedChapter:$_selectedVerse';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SideRail(
          books: _books,
          selectedBookId: _selectedBookId,
          onBookSelected: _onBookSelected,
          controller: _railController,
        ),
        Expanded(
          child: Column(
            children: [
              _BookHeader(
                book: _selectedBook,
                refText: _refBadge,
              ),
              _GoldTabBar(controller: _tabController),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _ChapterGrid(
                      totalChapters: _selectedBook.chapters,
                      selectedChapter: _selectedChapter,
                      onChapterSelected: _onChapterSelected,
                    ),
                    _VerseGrid(
                      totalVerses: BibleService.getVerseCount(
                          _selectedBookId, _selectedChapter),
                      selectedVerse: _selectedVerse,
                      onVerseSelected: _onVerseSelected,
                    ),
                  ],
                ),
              ),
              _RecentsStrip(recents: _recents),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────
// Side Rail
// ─────────────────────────────────────────
class _SideRail extends StatelessWidget {
  final List<BibleBook> books;
  final String selectedBookId;
  final ScrollController controller;
  final void Function(String) onBookSelected;

  const _SideRail({
    required this.books,
    required this.selectedBookId,
    required this.controller,
    required this.onBookSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF3E2723);
    final subTextColor = textColor.withValues(alpha: 0.7);
    final dividerColor = isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.08);
    final goldColor = isDark ? const Color(0xFFFFD700) : const Color(0xFF8B6914);
    final goldTextColor = isDark ? const Color(0xFFD4A574) : const Color(0xFF8B6914);
    final muteTextColor = textColor.withValues(alpha: 0.4);

    return Container(
      width: 110,
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.02) : Colors.white.withValues(alpha: 0.4),
        border: Border(right: BorderSide(color: dividerColor)),
      ),
      child: Column(
        children: [
          Container(
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: dividerColor)),
            ),
            child: Text(
              'BOOK',
              style: TextStyle(
                fontSize: 9.6,
                letterSpacing: 1.4,
                fontWeight: FontWeight.w700,
                color: muteTextColor,
                fontFamily: 'Outfit',
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: controller,
              itemCount: books.length,
              itemBuilder: (context, index) {
                final book = books[index];
                final isSelected = book.id == selectedBookId;

                // Insert OT/NT divider
                final prevTestament = index > 0 ? books[index - 1].testament : null;
                final showDivider =
                    prevTestament != null && prevTestament != book.testament;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (showDivider)
                      Container(
                        height: 24,
                        alignment: Alignment.center,
                        child: Text(
                          book.testament == 'OT' ? 'OLD TESTAMENT' : 'NEW TESTAMENT',
                          style: TextStyle(
                            fontSize: 8.5,
                            letterSpacing: 1.0,
                            fontWeight: FontWeight.w700,
                            color: goldTextColor.withValues(alpha: 0.6),
                            fontFamily: 'Outfit',
                          ),
                        ),
                      ),
                    SizedBox(
                      height: 66,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => onBookSelected(book.id),
                          splashColor: const Color(0xFFFFD700).withValues(alpha: 0.15),
                          highlightColor: const Color(0xFFFFD700).withValues(alpha: 0.05),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFFFD700).withValues(alpha: 0.15))
                                  : Colors.transparent,
                              border: Border(
                                left: BorderSide(
                                  color: isSelected ? goldColor : Colors.transparent,
                                  width: 3.5,
                                ),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  book.nameTe.isNotEmpty ? book.nameTe : book.nameEn,
                                  style: TextStyle(
                                    fontSize: 16.63,
                                    fontWeight: FontWeight.normal,
                                    color: isSelected ? goldColor : textColor,
                                    fontFamily: 'NotoSansTelugu',
                                    height: 1.1,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  book.nameEn,
                                  style: TextStyle(
                                    fontSize: 13.86,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? goldTextColor.withValues(alpha: 0.8)
                                        : subTextColor,
                                    fontFamily: 'Outfit',
                                    height: 1.1,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Book Header
// ─────────────────────────────────────────
class _BookHeader extends StatelessWidget {
  final BibleBook book;
  final String refText;
  const _BookHeader({required this.book, required this.refText});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF3E2723);
    final subTextColor = textColor.withValues(alpha: 0.7);
    final dividerColor = isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.08);
    final goldColor = isDark ? const Color(0xFFFFD700) : const Color(0xFF8B6914);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.02) : Colors.white.withValues(alpha: 0.4),
        border: Border(bottom: BorderSide(color: dividerColor)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.nameTe.isNotEmpty ? book.nameTe : book.nameEn,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                    color: textColor,
                    fontFamily: 'NotoSansTelugu',
                    height: 1.25,
                  ),
                ),
                if (book.nameTe.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    book.nameEn,
                    style: TextStyle(
                      fontSize: 14.4,
                      fontWeight: FontWeight.w800,
                      color: subTextColor,
                      height: 1.1,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    _Pill(label: '${book.chapters} chapters', gold: true),
                    _Pill(label: book.testament == 'OT' ? 'Old Testament' : 'New Testament'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFFFD700).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: goldColor.withValues(alpha: 0.6), width: 1.2),
            ),
            child: Text(
              refText,
              style: TextStyle(
                color: goldColor,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                fontFamily: 'Outfit',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final bool gold;
  const _Pill({required this.label, this.gold = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF3E2723);
    final cardBgColor = isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white;
    final cardBorderColor = isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFD4A574).withValues(alpha: 0.3);
    final goldColor = isDark ? const Color(0xFFFFD700) : const Color(0xFF8B6914);
    final subTextColor = textColor.withValues(alpha: 0.7);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: gold ? (isDark ? const Color(0xFFFFD700).withValues(alpha: 0.15) : const Color(0xFFFFD700).withValues(alpha: 0.2)) : cardBgColor,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: gold ? goldColor.withValues(alpha: 0.4) : cardBorderColor,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: gold ? goldColor : subTextColor,
          fontFamily: 'Outfit',
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Gold Tab Bar
// ─────────────────────────────────────────
class _GoldTabBar extends StatelessWidget {
  final TabController controller;
  const _GoldTabBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF3E2723);
    final dividerColor = isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.08);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.01) : Colors.white.withValues(alpha: 0.2),
        border: Border(bottom: BorderSide(color: dividerColor)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: SizedBox(
        height: 38,
        child: TabBar(
          controller: controller,
          labelColor: textColor,
          unselectedLabelColor: textColor.withValues(alpha: 0.5),
          indicator: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.10) : const Color(0xFFFFD700).withValues(alpha: 0.2),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.15) : const Color(0xFFD4A574).withValues(alpha: 0.4),
              width: 0.8,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent,
          labelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            fontFamily: 'Outfit',
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            fontFamily: 'Outfit',
          ),
          tabs: const [
            Tab(text: 'CHAPTER'),
            Tab(text: 'VERSE'),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Chapter Grid
// ─────────────────────────────────────────
class _ChapterGrid extends StatelessWidget {
  final int totalChapters;
  final int selectedChapter;
  final void Function(int) onChapterSelected;

  const _ChapterGrid({
    required this.totalChapters,
    required this.selectedChapter,
    required this.onChapterSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF3E2723);
    final cardBgColor = isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white;
    final cardBorderColor = isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFD4A574).withValues(alpha: 0.3);
    final dividerColor = isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.08);
    final goldTextColor = isDark ? const Color(0xFFD4A574) : const Color(0xFF8B6914);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
          child: Row(
            children: [
              Container(
                width: 3.5,
                height: 14,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFB300)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'SELECT CHAPTER',
                style: TextStyle(
                  color: goldTextColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  letterSpacing: 1.2,
                  fontFamily: 'Outfit',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Divider(
                  color: dividerColor,
                  thickness: 0.8,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(12, 2, 12, 12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 1.1,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
            ),
            itemCount: totalChapters,
            itemBuilder: (context, index) {
              final num = index + 1;
              final isSel = num == selectedChapter;
              return Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                child: Ink(
                  decoration: BoxDecoration(
                    color: isSel ? null : cardBgColor,
                    gradient: isSel
                        ? LinearGradient(
                            colors: isDark
                                ? [const Color(0xFFFFD700), const Color(0xFFFFB300)]
                                : [const Color(0xFF8B6914), const Color(0xFFB3923F)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          )
                        : null,
                    borderRadius: BorderRadius.circular(8),
                    border: isSel
                        ? null
                        : Border.all(
                            color: cardBorderColor,
                            width: 1,
                          ),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    splashColor: const Color(0xFFFFD700).withValues(alpha: 0.15),
                    highlightColor: const Color(0xFFFFD700).withValues(alpha: 0.05),
                    onTap: () => onChapterSelected(num),
                    child: Center(
                      child: Text(
                        '$num',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isSel
                              ? (isDark ? const Color(0xFF0B0F1A) : Colors.white)
                              : textColor.withValues(alpha: 0.8),
                          fontFamily: 'Outfit',
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────
// Verse Grid
// ─────────────────────────────────────────
class _VerseGrid extends StatelessWidget {
  final int totalVerses;
  final int selectedVerse;
  final void Function(int) onVerseSelected;

  const _VerseGrid({
    required this.totalVerses,
    required this.selectedVerse,
    required this.onVerseSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF3E2723);
    final cardBgColor = isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white;
    final cardBorderColor = isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFD4A574).withValues(alpha: 0.3);
    final dividerColor = isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.08);
    final goldTextColor = isDark ? const Color(0xFFD4A574) : const Color(0xFF8B6914);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
          child: Row(
            children: [
              Container(
                width: 3.5,
                height: 14,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFB300)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'SELECT VERSE',
                style: TextStyle(
                  color: goldTextColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  letterSpacing: 1.2,
                  fontFamily: 'Outfit',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Divider(
                  color: dividerColor,
                  thickness: 0.8,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(12, 2, 12, 12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 1.2,
              mainAxisSpacing: 5,
              crossAxisSpacing: 5,
            ),
            itemCount: totalVerses,
            itemBuilder: (context, index) {
              final num = index + 1;
              final isSel = num == selectedVerse;
              return Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                child: Ink(
                  decoration: BoxDecoration(
                    color: isSel ? null : cardBgColor,
                    gradient: isSel
                        ? LinearGradient(
                            colors: isDark
                                ? [const Color(0xFFFFD700), const Color(0xFFFFB300)]
                                : [const Color(0xFF8B6914), const Color(0xFFB3923F)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          )
                        : null,
                    borderRadius: BorderRadius.circular(8),
                    border: isSel
                        ? null
                        : Border.all(
                            color: cardBorderColor,
                            width: 1,
                          ),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    splashColor: const Color(0xFFFFD700).withValues(alpha: 0.15),
                    highlightColor: const Color(0xFFFFD700).withValues(alpha: 0.05),
                    onTap: () => onVerseSelected(num),
                    child: Center(
                      child: Text(
                        '$num',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isSel
                              ? (isDark ? const Color(0xFF0B0F1A) : Colors.white)
                              : textColor.withValues(alpha: 0.8),
                          fontFamily: 'Outfit',
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────
// Recents Strip
// ─────────────────────────────────────────
class _RecentsStrip extends StatelessWidget {
  final List<String> recents;
  const _RecentsStrip({required this.recents});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF3E2723);
    final cardBgColor = isDark ? Colors.white.withValues(alpha: 0.04) : Colors.white;
    final cardBorderColor = isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFD4A574).withValues(alpha: 0.3);
    final dividerColor = isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.08);
    final goldColor = isDark ? const Color(0xFFFFD700) : const Color(0xFF8B6914);
    final goldTextColor = isDark ? const Color(0xFFD4A574) : const Color(0xFF8B6914);
    final subTextColor = textColor.withValues(alpha: 0.8);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.02) : Colors.white.withValues(alpha: 0.4),
        border: Border(top: BorderSide(color: dividerColor)),
      ),
      child: Row(
        children: [
          Text(
            'RECENT',
            style: TextStyle(
              fontSize: 9,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w700,
              color: goldTextColor,
              fontFamily: 'Outfit',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: recents
                    .map(
                      (r) => Container(
                        margin: const EdgeInsets.only(right: 5),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: recents.indexOf(r) == 0
                              ? (isDark ? const Color(0xFFFFD700).withValues(alpha: 0.2) : const Color(0xFFFFD700).withValues(alpha: 0.25))
                              : cardBgColor,
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(
                            color: recents.indexOf(r) == 0
                                ? goldColor.withValues(alpha: 0.6)
                                : cardBorderColor,
                          ),
                        ),
                        child: Text(
                          r,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: recents.indexOf(r) == 0
                                ? FontWeight.w600
                                : FontWeight.normal,
                            color: recents.indexOf(r) == 0 ? goldColor : subTextColor,
                            fontFamily: 'Outfit',
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
