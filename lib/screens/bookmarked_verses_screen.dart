import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/bible.dart';
import '../providers/user_data_provider.dart';
import '../services/bible_service.dart';

class BookmarkedVersesScreen extends StatelessWidget {
  const BookmarkedVersesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserDataProvider>();
    final bookmarks = userProvider.bookmarkedVerseRefs.toList();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final textColor = isDark ? Colors.white : const Color(0xFF3E2723);
    final cardBg = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white;
    final cardBorder = isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFD4A574).withValues(alpha: 0.3);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Saved Verses • బుక్‌మార్క్‌లు',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontFamily: 'Outfit',
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
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
            child: bookmarks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bookmark_border_rounded,
                          size: 64,
                          color: isDark ? Colors.white30 : Colors.black26,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No bookmarked verses yet.\nఇంకా ఏ వచనాన్ని బుక్‌మార్క్ చేయలేదు.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isDark ? Colors.white60 : Colors.black54,
                            fontSize: 16,
                            fontFamily: 'Outfit',
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    itemCount: bookmarks.length,
                    itemBuilder: (context, index) {
                      final ref = bookmarks[index];
                      return _BookmarkedVerseItem(
                        verseRef: ref,
                        cardBg: cardBg,
                        cardBorder: cardBorder,
                        textColor: textColor,
                        onTap: () {
                          final parts = ref.split('_');
                          if (parts.length == 3) {
                            final bookId = parts[0];
                            final chapter = int.tryParse(parts[1]) ?? 1;
                            final verse = int.tryParse(parts[2]) ?? 1;
                            
                            userProvider.setBibleTarget(bookId, chapter, verse);
                            userProvider.setTabIndex(0); // Bible tab is 0
                            Navigator.popUntil(context, (route) => route.isFirst);
                          }
                        },
                        onDismissed: () {
                          userProvider.toggleVerseBookmark(ref);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _BookmarkedVerseItem extends StatelessWidget {
  final String verseRef;
  final Color cardBg;
  final Color cardBorder;
  final Color textColor;
  final VoidCallback onTap;
  final VoidCallback onDismissed;

  const _BookmarkedVerseItem({
    required this.verseRef,
    required this.cardBg,
    required this.cardBorder,
    required this.textColor,
    required this.onTap,
    required this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    final parts = verseRef.split('_');
    if (parts.length < 3) return const SizedBox.shrink();

    final bookId = parts[0];
    final chapter = int.tryParse(parts[1]) ?? 1;
    final verse = int.tryParse(parts[2]) ?? 1;

    final book = BibleService.getBookById(bookId);
    final bookNameEn = book?.nameEn ?? bookId;
    final bookNameTe = book?.nameTe ?? bookId;

    return Dismissible(
      key: Key(verseRef),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.red.shade900,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 28),
      ),
      onDismissed: (dir) => onDismissed(),
      child: FutureBuilder<BibleVerse?>(
        future: _fetchVerse(bookId, chapter, verse),
        builder: (context, snapshot) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final verseTextEn = snapshot.data?.textKjv ?? 'Loading...';
          final verseTextTe = snapshot.data?.textTe ?? 'ప్రక్రియలో ఉంది...';

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cardBorder, width: 1.5),
            ),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$bookNameEn ($bookNameTe) $chapter:$verse',
                          style: TextStyle(
                            color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            fontFamily: 'Outfit',
                          ),
                        ),
                        Icon(
                          Icons.bookmark_added_rounded,
                          color: isDark ? Colors.amber.shade200 : Colors.amber.shade700,
                          size: 18,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      verseTextTe,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: textColor.withValues(alpha: 0.9),
                        fontSize: 14,
                        fontFamily: 'NotoSansTelugu',
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      verseTextEn,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: textColor.withValues(alpha: 0.7),
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        fontFamily: 'Outfit',
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<BibleVerse?> _fetchVerse(String bookId, int chapter, int verse) async {
    final verses = await BibleService.getChapterVerses(bookId, chapter);
    for (final v in verses) {
      if (v.verse == verse) return v;
    }
    return null;
  }
}
