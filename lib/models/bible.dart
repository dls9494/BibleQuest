class BibleBook {
  final String id; // e.g. 'genesis', 'matthew'
  final String nameEn;
  final String nameTe;
  final int chapters;
  final String testament; // 'OT' or 'NT'

  const BibleBook({
    required this.id,
    required this.nameEn,
    required this.nameTe,
    required this.chapters,
    required this.testament,
  });
}

class BibleChapterRef {
  final String bookId;
  final String bookNameEn;
  final int chapter;

  const BibleChapterRef({
    required this.bookId,
    required this.bookNameEn,
    required this.chapter,
  });
}

class BibleVerse {
  final int chapter;
  final int verse;
  final String textTe;
  final String textKjv;
  final String textNhv;

  const BibleVerse({
    required this.chapter,
    required this.verse,
    required this.textTe,
    required this.textKjv,
    required this.textNhv,
  });
}

class SearchVerse extends BibleVerse {
  final String bookId;
  final String bookNameEn;
  final String bookNameTe;

  const SearchVerse({
    required this.bookId,
    required this.bookNameEn,
    required this.bookNameTe,
    required super.chapter,
    required super.verse,
    required super.textTe,
    required super.textKjv,
    required super.textNhv,
  });
}

