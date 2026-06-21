import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/gradient_background.dart';
import '../services/bible_service.dart';
import '../widgets/three_column_selector.dart';

class ChapterListScreen extends StatelessWidget {
  final String version;
  final String bookName;

  const ChapterListScreen({
    super.key,
    required this.version,
    required this.bookName,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? (isDark ? Colors.white : Color(0xFF3E2723));

    // Get metadata for display & initial selection
    final metadataBook = BibleService.getBooks().firstWhere(
      (b) => b.id == bookName.toLowerCase().replaceAll(' ', ''),
      orElse: () => BibleBook(
        id: bookName.toLowerCase().replaceAll(' ', ''),
        nameEn: bookName,
        nameTe: '',
        chapters: 1,
        testament: 'OT',
      ),
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Bible Navigation',
              style: TextStyle(
                color: Color(0xFFFFD700),
                fontWeight: FontWeight.bold,
                fontFamily: 'Outfit',
                fontSize: 16,
              ),
            ),
            Text(
              'Select Book • Chapter • Verse',
              style: TextStyle(
                color: textColor.withValues(alpha: 0.6),
                fontFamily: 'Outfit',
                fontSize: 11,
              ),
            ),
          ],
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => context.go('/bible'),
        ),
      ),
      body: Stack(
        children: [
          const Positioned.fill(
            child: GradientBackground(child: SizedBox.shrink()),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ThreeColumnSelector(
                      initialBookId: metadataBook.id,
                      initialChapter: 1,
                      onSelected: (bookId, chapter, verse) {
                        final selectedBook = BibleService.getBooks().firstWhere(
                          (b) => b.id == bookId,
                          orElse: () => metadataBook,
                        );
                        // Navigate directly to the reader
                        context.push('/bible/$version/${selectedBook.nameEn}/$chapter?verse=$verse');
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
