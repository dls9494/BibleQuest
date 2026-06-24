import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/bible_service.dart';
import '../widgets/three_column_selector.dart';
import '../widgets/gradient_background.dart';

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
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/bible'),
        ),
        title: const Text(
          'Bible Navigation • బైబిల్ నావిగేషన్',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Outfit',
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: GradientBackground(
        child: HybridSelector(
          initialBookId: metadataBook.id,
          initialChapter: 1,
          onSelected: (bookId, chapter, verse) {
            final selectedBook = BibleService.getBooks().firstWhere(
              (b) => b.id == bookId,
              orElse: () => metadataBook,
            );
            context.push(
              '/bible/$version/${selectedBook.nameEn}/$chapter?verse=$verse',
            );
          },
        ),
      ),
    );
  }
}
