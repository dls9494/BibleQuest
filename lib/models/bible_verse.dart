class BibleVerse {
  final int bookNumber;
  final String bookName;
  final int chapter;
  final int verse;
  final String text;

  const BibleVerse({
    required this.bookNumber,
    required this.bookName,
    required this.chapter,
    required this.verse,
    required this.text,
  });

  Map<String, dynamic> toMap() {
    return {
      'book_number': bookNumber,
      'book_name': bookName,
      'chapter': chapter,
      'verse': verse,
      'text': text,
    };
  }

  factory BibleVerse.fromMap(Map<String, dynamic> map) {
    return BibleVerse(
      bookNumber: map['book_number'] as int,
      bookName: map['book_name'] as String,
      chapter: map['chapter'] as int,
      verse: map['verse'] as int,
      text: map['text'] as String,
    );
  }
}
