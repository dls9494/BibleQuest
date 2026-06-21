import '../core/database/app_database.dart';
import '../models/bible.dart';
export '../models/bible.dart';

class BibleService {
  // ─── In-memory cache ─────────────────────────────────────────────────────
  static List<SearchVerse>? _searchIndex;

  // ─── Book metadata ───────────────────────────────────────────────────────
  static const List<BibleBook> _books = [
    // ── Old Testament ──
    BibleBook(id: 'genesis',       nameEn: 'Genesis',          nameTe: 'ఆదికాండము',         chapters: 50,  testament: 'OT'),
    BibleBook(id: 'exodus',        nameEn: 'Exodus',           nameTe: 'నిర్గమకాండము',       chapters: 40,  testament: 'OT'),
    BibleBook(id: 'leviticus',     nameEn: 'Leviticus',        nameTe: 'లేవీయకాండము',        chapters: 27,  testament: 'OT'),
    BibleBook(id: 'numbers',       nameEn: 'Numbers',          nameTe: 'సంఖ్యాకాండము',       chapters: 36,  testament: 'OT'),
    BibleBook(id: 'deuteronomy',   nameEn: 'Deuteronomy',      nameTe: 'ద్వితీయోపదేశకాండము', chapters: 34,  testament: 'OT'),
    BibleBook(id: 'joshua',        nameEn: 'Joshua',           nameTe: 'యెహోషువ',            chapters: 24,  testament: 'OT'),
    BibleBook(id: 'judges',        nameEn: 'Judges',           nameTe: 'న్యాయాధిపతులు',      chapters: 21,  testament: 'OT'),
    BibleBook(id: 'ruth',          nameEn: 'Ruth',             nameTe: 'రూతు',               chapters: 4,   testament: 'OT'),
    BibleBook(id: '1samuel',       nameEn: '1 Samuel',         nameTe: '1 సమూయేలు',          chapters: 31,  testament: 'OT'),
    BibleBook(id: '2samuel',       nameEn: '2 Samuel',         nameTe: '2 సమూయేలు',          chapters: 24,  testament: 'OT'),
    BibleBook(id: '1kings',        nameEn: '1 Kings',          nameTe: '1 రాజులు',            chapters: 22,  testament: 'OT'),
    BibleBook(id: '2kings',        nameEn: '2 Kings',          nameTe: '2 రాజులు',            chapters: 25,  testament: 'OT'),
    BibleBook(id: '1chronicles',   nameEn: '1 Chronicles',     nameTe: '1 దినవృత్తాంతములు',  chapters: 29,  testament: 'OT'),
    BibleBook(id: '2chronicles',   nameEn: '2 Chronicles',     nameTe: '2 దినవృత్తాంతములు',  chapters: 36,  testament: 'OT'),
    BibleBook(id: 'ezra',          nameEn: 'Ezra',             nameTe: 'ఎజ్రా',               chapters: 10,  testament: 'OT'),
    BibleBook(id: 'nehemiah',      nameEn: 'Nehemiah',         nameTe: 'నెహెమ్యా',            chapters: 13,  testament: 'OT'),
    BibleBook(id: 'esther',        nameEn: 'Esther',           nameTe: 'ఎస్తేరు',             chapters: 10,  testament: 'OT'),
    BibleBook(id: 'job',           nameEn: 'Job',              nameTe: 'యోబు',               chapters: 42,  testament: 'OT'),
    BibleBook(id: 'psalms',        nameEn: 'Psalms',           nameTe: 'కీర్తనలు',            chapters: 150, testament: 'OT'),
    BibleBook(id: 'proverbs',      nameEn: 'Proverbs',         nameTe: 'సామెతలు',             chapters: 31,  testament: 'OT'),
    BibleBook(id: 'ecclesiastes',  nameEn: 'Ecclesiastes',     nameTe: 'ప్రసంగి',             chapters: 12,  testament: 'OT'),
    BibleBook(id: 'songofsolomon', nameEn: 'Song of Solomon',  nameTe: 'పరమగీతము',           chapters: 8,   testament: 'OT'),
    BibleBook(id: 'isaiah',        nameEn: 'Isaiah',           nameTe: 'యెషయా',              chapters: 66,  testament: 'OT'),
    BibleBook(id: 'jeremiah',      nameEn: 'Jeremiah',         nameTe: 'యిర్మీయా',            chapters: 52,  testament: 'OT'),
    BibleBook(id: 'lamentations',  nameEn: 'Lamentations',     nameTe: 'విలాపవాక్యములు',     chapters: 5,   testament: 'OT'),
    BibleBook(id: 'ezekiel',       nameEn: 'Ezekiel',          nameTe: 'యెహెజ్కేలు',          chapters: 48,  testament: 'OT'),
    BibleBook(id: 'daniel',        nameEn: 'Daniel',           nameTe: 'దానియేలు',            chapters: 12,  testament: 'OT'),
    BibleBook(id: 'hosea',         nameEn: 'Hosea',            nameTe: 'హోషేయ',              chapters: 14,  testament: 'OT'),
    BibleBook(id: 'joel',          nameEn: 'Joel',             nameTe: 'యోవేలు',             chapters: 3,   testament: 'OT'),
    BibleBook(id: 'amos',          nameEn: 'Amos',             nameTe: 'ఆమోసు',              chapters: 9,   testament: 'OT'),
    BibleBook(id: 'obadiah',       nameEn: 'Obadiah',          nameTe: 'ఓబద్యా',             chapters: 1,   testament: 'OT'),
    BibleBook(id: 'jonah',         nameEn: 'Jonah',            nameTe: 'యోనా',               chapters: 4,   testament: 'OT'),
    BibleBook(id: 'micah',         nameEn: 'Micah',            nameTe: 'మీకా',               chapters: 7,   testament: 'OT'),
    BibleBook(id: 'nahum',         nameEn: 'Nahum',            nameTe: 'నహూము',              chapters: 3,   testament: 'OT'),
    BibleBook(id: 'habakkuk',      nameEn: 'Habakkuk',         nameTe: 'హబక్కూకు',           chapters: 3,   testament: 'OT'),
    BibleBook(id: 'zephaniah',     nameEn: 'Zephaniah',        nameTe: 'జెఫన్యా',             chapters: 3,   testament: 'OT'),
    BibleBook(id: 'haggai',        nameEn: 'Haggai',           nameTe: 'హగ్గయి',             chapters: 2,   testament: 'OT'),
    BibleBook(id: 'zechariah',     nameEn: 'Zechariah',        nameTe: 'జెకర్యా',             chapters: 14,  testament: 'OT'),
    BibleBook(id: 'malachi',       nameEn: 'Malachi',          nameTe: 'మలాకీ',              chapters: 4,   testament: 'OT'),
    // ── New Testament ──
    BibleBook(id: 'matthew',       nameEn: 'Matthew',          nameTe: 'మత్తయి',             chapters: 28,  testament: 'NT'),
    BibleBook(id: 'mark',          nameEn: 'Mark',             nameTe: 'మార్కు',             chapters: 16,  testament: 'NT'),
    BibleBook(id: 'luke',          nameEn: 'Luke',             nameTe: 'లూకా',               chapters: 24,  testament: 'NT'),
    BibleBook(id: 'john',          nameEn: 'John',             nameTe: 'యోహాను',             chapters: 21,  testament: 'NT'),
    BibleBook(id: 'acts',          nameEn: 'Acts',             nameTe: 'అపొస్తలుల కార్యములు', chapters: 28, testament: 'NT'),
    BibleBook(id: 'romans',        nameEn: 'Romans',           nameTe: 'రోమీయులకు',          chapters: 16,  testament: 'NT'),
    BibleBook(id: '1corinthians',  nameEn: '1 Corinthians',    nameTe: '1 కొరింథీయులకు',     chapters: 16,  testament: 'NT'),
    BibleBook(id: '2corinthians',  nameEn: '2 Corinthians',    nameTe: '2 కొరింథీయులకు',     chapters: 13,  testament: 'NT'),
    BibleBook(id: 'galatians',     nameEn: 'Galatians',        nameTe: 'గలతీయులకు',          chapters: 6,   testament: 'NT'),
    BibleBook(id: 'ephesians',     nameEn: 'Ephesians',        nameTe: 'ఎఫెసీయులకు',         chapters: 6,   testament: 'NT'),
    BibleBook(id: 'philippians',   nameEn: 'Philippians',      nameTe: 'ఫిలిప్పీయులకు',      chapters: 4,   testament: 'NT'),
    BibleBook(id: 'colossians',    nameEn: 'Colossians',       nameTe: 'కొలొస్సయులకు',       chapters: 4,   testament: 'NT'),
    BibleBook(id: '1thessalonians',nameEn: '1 Thessalonians',  nameTe: '1 థెస్సలొనీకయులకు',  chapters: 5,   testament: 'NT'),
    BibleBook(id: '2thessalonians',nameEn: '2 Thessalonians',  nameTe: '2 థెస్సలొనీకయులకు',  chapters: 3,   testament: 'NT'),
    BibleBook(id: '1timothy',      nameEn: '1 Timothy',        nameTe: '1 తిమోతికి',         chapters: 6,   testament: 'NT'),
    BibleBook(id: '2timothy',      nameEn: '2 Timothy',        nameTe: '2 తిమోతికి',         chapters: 4,   testament: 'NT'),
    BibleBook(id: 'titus',         nameEn: 'Titus',            nameTe: 'తీతుకు',             chapters: 3,   testament: 'NT'),
    BibleBook(id: 'philemon',      nameEn: 'Philemon',         nameTe: 'ఫిలేమోనుకు',         chapters: 1,   testament: 'NT'),
    BibleBook(id: 'hebrews',       nameEn: 'Hebrews',          nameTe: 'హెబ్రీయులకు',         chapters: 13,  testament: 'NT'),
    BibleBook(id: 'james',         nameEn: 'James',            nameTe: 'యాకోబు',             chapters: 5,   testament: 'NT'),
    BibleBook(id: '1peter',        nameEn: '1 Peter',          nameTe: '1 పేతురు',            chapters: 5,   testament: 'NT'),
    BibleBook(id: '2peter',        nameEn: '2 Peter',          nameTe: '2 పేతురు',            chapters: 3,   testament: 'NT'),
    BibleBook(id: '1john',         nameEn: '1 John',           nameTe: '1 యోహాను',            chapters: 5,   testament: 'NT'),
    BibleBook(id: '2john',         nameEn: '2 John',           nameTe: '2 యోహాను',            chapters: 1,   testament: 'NT'),
    BibleBook(id: '3john',         nameEn: '3 John',           nameTe: '3 యోహాను',            chapters: 1,   testament: 'NT'),
    BibleBook(id: 'jude',          nameEn: 'Jude',             nameTe: 'యూదా',               chapters: 1,   testament: 'NT'),
    BibleBook(id: 'revelation',    nameEn: 'Revelation',       nameTe: 'ప్రకటన గ్రంథము',    chapters: 22,  testament: 'NT'),
  ];



  static List<BibleBook> getBooks() => _books;
  static List<BibleBook> getAllBooks() => _books;
  static List<BibleBook> getOTBooks() => _books.where((b) => b.testament == 'OT').toList();
  static List<BibleBook> getNTBooks() => _books.where((b) => b.testament == 'NT').toList();

  static BibleBook? getBookById(String id) {
    try {
      final lid = id.toLowerCase().replaceAll(' ', '');
      return _books.firstWhere((b) => b.id == lid);
    } catch (_) {
      return findBookByName(id);
    }
  }

  /// Parse a reading reference like "Genesis 1-11" or "Matthew 5" → BibleChapterRef
  static BibleChapterRef? parseReadingRef(String ref) {
    // Try to match "BookName chapter-range" pattern
    final patterns = [
      RegExp(r'^(.+?)\s+(\d+)(?:-\d+)?$'),   // "Genesis 1-11" or "Genesis 1"
      RegExp(r'^(\d+\s+\w+)\s+(\d+)(?:-\d+)?$'), // "1 Samuel 1-3"
    ];
    for (final pattern in patterns) {
      final match = pattern.firstMatch(ref.trim());
      if (match != null) {
        final bookName = match.group(1)!.trim();
        final chapter = int.tryParse(match.group(2)!) ?? 1;
        final book = findBookByName(bookName);
        if (book != null) {
          return BibleChapterRef(
            bookId: book.id,
            bookNameEn: book.nameEn,
            chapter: chapter,
          );
        }
      }
    }
    return null;
  }

  static BibleBook? findBookByName(String name) {
    final lname = name.toLowerCase().replaceAll(' ', '');
    for (final book in _books) {
      if (book.nameEn.toLowerCase().replaceAll(' ', '') == lname) return book;
      if (book.nameTe == name) return book;
      if (book.id == lname) return book;
    }
    return null;
  }

  // ─── SQLite loading ───────────────────────────────────────────────────────

  static String mapLegacyVersion(String version) {
    final v = version.toLowerCase().trim();
    if (v == 'te' || v == 'telugu_ov' || v == 'telugu') {
      return 'telugu_ov';
    }
    if (v == 'telugu_irv' || v == 'irv') {
      return 'telugu_irv';
    }
    if (v == 'telugu_wbtc' || v == 'wbtc') {
      return 'telugu_wbtc';
    }
    if (v == 'kjv' || v == 'english_kjv' || v == 'english_kjv21') {
      return 'kjv';
    }
    if (v == 'asv' || v == 'english_asv') {
      return 'asv';
    }
    if (v == 'web' || v == 'english_web') {
      return 'web';
    }
    if (v == 'darby' || v == 'english_darby') {
      return 'darby';
    }
    
    // Contain matches
    if (v.contains('irv')) return 'telugu_irv';
    if (v.contains('wbtc')) return 'telugu_wbtc';
    if (v.contains('asv')) return 'asv';
    if (v.contains('web')) return 'web';
    if (v.contains('darby')) return 'darby';
    if (v.contains('telugu') || v.startsWith('te')) return 'telugu_ov';
    
    return 'kjv';
  }

  /// Returns {verseNumber: text} for a given book/chapter/version.
  static Future<Map<int, String>> getChapter(String bookId, int chapter, String version) async {
    final mappedVersion = mapLegacyVersion(version);
    final db = await AppDatabase.instance.getDatabase(mappedVersion);
    final book = getBookById(bookId);
    final queryBookName = book?.nameEn ?? bookId;

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT verse, text FROM verses WHERE LOWER(book_name) = ? AND chapter = ? ORDER BY verse',
      [queryBookName.toLowerCase(), chapter],
    );

    final result = <int, String>{};
    for (final row in maps) {
      result[row['verse'] as int] = row['text'] as String;
    }
    return result;
  }

  /// Returns verses for bilingual mode: {verse: {te: text, kjv: text}}
  static Future<Map<int, Map<String, String>>> getChapterBilingual(
      String bookId, int chapter) async {
    final te = await getChapter(bookId, chapter, 'telugu_ov');
    final kjv = await getChapter(bookId, chapter, 'kjv');

    final result = <int, Map<String, String>>{};
    final allVerses = {...te.keys, ...kjv.keys};
    for (final v in allVerses) {
      result[v] = {
        'te': te[v] ?? 'ఈ వచనం త్వరలో అందుబాటులోకి వస్తుంది.',
        'kjv': kjv[v] ?? 'This verse will be available soon.',
      };
    }
    return result;
  }

  /// Returns all verses in a chapter range as flat list for quiz generation
  static Future<List<Map<String, String>>> getVersesForRange(
      String bookId, int fromChapter, int toChapter, String version) async {
    final verses = <Map<String, String>>[];
    for (int ch = fromChapter; ch <= toChapter; ch++) {
      final chData = await getChapter(bookId, ch, version);
      chData.forEach((v, text) {
        final book = getBookById(bookId);
        verses.add({
          'ref': '${book?.nameEn ?? bookId} $ch:$v',
          'text': text,
          'chapter': ch.toString(),
          'verse': v.toString(),
        });
      });
    }
    return verses;
  }

  /// Returns a list of BibleVerse objects for a given book and chapter.
  static Future<List<BibleVerse>> getChapterVerses(String bookId, int chapter) async {
    final te = await getChapter(bookId, chapter, 'telugu_ov');
    final kjv = await getChapter(bookId, chapter, 'kjv');
    final nhv = await getChapter(bookId, chapter, 'web');

    final result = <BibleVerse>[];
    final allVerses = {...te.keys, ...kjv.keys, ...nhv.keys}.toList()..sort();
    for (final v in allVerses) {
      result.add(BibleVerse(
        chapter: chapter,
        verse: v,
        textTe: te[v] ?? 'ఈ వచనం త్వరలో అందుబాటులోకి వస్తుంది.',
        textKjv: kjv[v] ?? 'This verse will be available soon.',
        textNhv: nhv[v] ?? 'This verse will be available soon.',
      ));
    }
    return result;
  }

  static Future<List<SearchVerse>> getSearchIndex() async {
    if (_searchIndex != null) return _searchIndex!;

    final dbTe = await AppDatabase.instance.getDatabase('telugu_ov');
    final dbKjv = await AppDatabase.instance.getDatabase('kjv');
    final dbNiv = await AppDatabase.instance.getDatabase('web');

    final List<Map<String, dynamic>> versesTe = await dbTe.rawQuery(
      'SELECT book_number, book_name, chapter, verse, text FROM verses ORDER BY book_number, chapter, verse'
    );
    final List<Map<String, dynamic>> versesKjv = await dbKjv.rawQuery(
      'SELECT book_number, book_name, chapter, verse, text FROM verses ORDER BY book_number, chapter, verse'
    );
    final List<Map<String, dynamic>> versesNiv = await dbNiv.rawQuery(
      'SELECT book_number, book_name, chapter, verse, text FROM verses ORDER BY book_number, chapter, verse'
    );

    final Map<String, String> mapTe = {};
    for (final row in versesTe) {
      final key = "${row['book_number']}:${row['chapter']}:${row['verse']}";
      mapTe[key] = row['text'] as String;
    }

    final Map<String, String> mapNiv = {};
    for (final row in versesNiv) {
      final key = "${row['book_number']}:${row['chapter']}:${row['verse']}";
      mapNiv[key] = row['text'] as String;
    }

    final list = <SearchVerse>[];
    for (final row in versesKjv) {
      final bookNum = row['book_number'] as int;
      final bookNameEn = row['book_name'] as String;
      final ch = row['chapter'] as int;
      final v = row['verse'] as int;
      final textKjv = row['text'] as String;

      final key = "$bookNum:$ch:$v";
      final textTe = mapTe[key] ?? '';
      final textNiv = mapNiv[key] ?? '';

      final book = _books.firstWhere(
        (b) => b.nameEn.toLowerCase() == bookNameEn.toLowerCase(),
        orElse: () => _books[bookNum - 1],
      );

      list.add(SearchVerse(
        bookId: book.id,
        bookNameEn: book.nameEn,
        bookNameTe: book.nameTe,
        chapter: ch,
        verse: v,
        textTe: textTe,
        textKjv: textKjv,
        textNhv: textNiv,
      ));
    }

    _searchIndex = list;
    return list;
  }

  static int getVerseCount(String bookId, int chapter) {
    final counts = _verseCounts[bookId.toLowerCase()];
    if (counts != null && chapter > 0 && chapter <= counts.length) {
      return counts[chapter - 1];
    }
    return 0;
  }

  static const Map<String, List<int>> _verseCounts = {
    'genesis': [31, 25, 24, 26, 32, 22, 24, 22, 29, 32, 32, 20, 18, 24, 21, 16, 27, 33, 38, 18, 34, 24, 20, 67, 34, 35, 46, 22, 35, 43, 55, 32, 20, 31, 29, 43, 36, 30, 23, 23, 57, 38, 34, 34, 28, 34, 31, 22, 33, 26],
    'exodus': [22, 25, 22, 31, 23, 30, 25, 32, 35, 29, 10, 51, 22, 31, 27, 36, 16, 27, 25, 26, 36, 31, 33, 18, 40, 37, 21, 43, 46, 38, 18, 35, 23, 35, 35, 38, 29, 31, 43, 38],
    'leviticus': [17, 16, 17, 35, 19, 30, 38, 36, 24, 20, 47, 8, 59, 57, 33, 34, 16, 30, 37, 27, 24, 33, 44, 23, 55, 46, 34],
    'numbers': [54, 34, 51, 49, 31, 27, 89, 26, 23, 36, 35, 16, 33, 45, 41, 50, 13, 32, 22, 29, 35, 41, 30, 25, 18, 65, 23, 31, 40, 16, 54, 42, 56, 29, 34, 13],
    'deuteronomy': [46, 37, 29, 49, 33, 25, 26, 20, 29, 22, 32, 32, 18, 29, 23, 22, 20, 22, 21, 20, 23, 30, 25, 22, 19, 19, 26, 68, 29, 20, 30, 52, 29, 12],
    'joshua': [18, 24, 17, 24, 15, 27, 26, 35, 27, 43, 23, 24, 33, 15, 63, 10, 18, 28, 51, 9, 45, 34, 16, 33],
    'judges': [36, 23, 31, 24, 31, 40, 25, 35, 57, 18, 40, 15, 25, 20, 20, 31, 13, 31, 30, 48, 25],
    'ruth': [22, 23, 18, 22],
    '1samuel': [28, 36, 21, 22, 12, 21, 17, 22, 27, 27, 15, 25, 23, 52, 35, 23, 58, 30, 24, 42, 15, 23, 29, 22, 44, 25, 12, 25, 11, 31, 13],
    '2samuel': [27, 32, 39, 12, 25, 23, 29, 18, 13, 19, 27, 31, 39, 33, 37, 23, 29, 33, 43, 26, 22, 51, 39, 25],
    '1kings': [53, 46, 28, 34, 18, 38, 51, 66, 28, 29, 43, 33, 34, 31, 34, 34, 24, 46, 21, 43, 29, 53],
    '2kings': [18, 25, 27, 44, 27, 33, 20, 29, 37, 36, 21, 21, 25, 29, 38, 20, 41, 37, 37, 21, 26, 20, 37, 20, 30],
    '1chronicles': [54, 55, 24, 43, 26, 81, 40, 40, 44, 14, 47, 40, 14, 17, 29, 43, 27, 17, 19, 8, 30, 19, 32, 31, 31, 32, 34, 21, 30],
    '2chronicles': [17, 18, 17, 22, 14, 42, 22, 18, 31, 19, 23, 16, 22, 15, 19, 14, 19, 34, 11, 37, 20, 12, 21, 27, 28, 23, 9, 27, 36, 27, 21, 33, 25, 33, 27, 23],
    'ezra': [11, 70, 13, 24, 17, 22, 28, 36, 15, 44],
    'nehemiah': [11, 20, 32, 23, 19, 19, 73, 18, 38, 39, 36, 47, 31],
    'esther': [22, 23, 15, 17, 14, 14, 10, 17, 32, 3],
    'job': [22, 13, 26, 21, 27, 30, 21, 22, 35, 22, 20, 25, 28, 22, 35, 22, 16, 21, 29, 29, 34, 30, 17, 25, 6, 14, 23, 28, 25, 31, 40, 22, 33, 37, 16, 33, 24, 41, 30, 24, 34, 17],
    'psalms': [6, 12, 8, 8, 12, 10, 17, 9, 20, 18, 7, 8, 6, 7, 5, 11, 15, 50, 14, 9, 13, 31, 6, 10, 22, 12, 14, 9, 11, 12, 24, 11, 22, 22, 28, 12, 40, 22, 13, 17, 13, 11, 5, 26, 17, 11, 9, 14, 20, 23, 19, 9, 6, 7, 23, 13, 11, 11, 17, 12, 8, 12, 11, 10, 13, 20, 7, 35, 36, 5, 24, 20, 28, 23, 10, 12, 20, 72, 13, 19, 16, 8, 18, 12, 13, 17, 7, 18, 52, 17, 16, 15, 5, 23, 11, 13, 12, 9, 9, 5, 8, 28, 22, 35, 45, 48, 43, 13, 31, 7, 10, 10, 9, 8, 18, 19, 2, 29, 176, 7, 8, 9, 4, 8, 5, 6, 5, 6, 8, 8, 3, 18, 3, 3, 21, 26, 9, 8, 24, 13, 10, 7, 12, 15, 21, 10, 20, 14, 9, 6],
    'proverbs': [33, 22, 35, 27, 23, 35, 27, 36, 18, 32, 31, 28, 25, 35, 33, 33, 28, 24, 29, 30, 31, 29, 35, 34, 28, 28, 27, 28, 27, 33, 31],
    'ecclesiastes': [18, 26, 22, 16, 20, 12, 29, 17, 18, 20, 10, 14],
    'songofsolomon': [17, 17, 11, 16, 16, 13, 13, 14],
    'isaiah': [31, 22, 26, 6, 30, 13, 25, 22, 21, 34, 16, 6, 22, 32, 9, 14, 14, 7, 25, 6, 17, 25, 18, 23, 12, 21, 13, 29, 24, 33, 9, 20, 24, 17, 10, 22, 38, 22, 8, 31, 29, 25, 28, 28, 25, 13, 15, 22, 26, 11, 23, 15, 12, 17, 13, 12, 21, 14, 21, 22, 11, 12, 19, 12, 25, 24],
    'jeremiah': [19, 37, 25, 31, 31, 30, 34, 22, 26, 25, 23, 17, 27, 22, 21, 21, 27, 23, 15, 18, 14, 30, 40, 10, 38, 24, 22, 17, 32, 24, 40, 44, 26, 22, 19, 32, 21, 28, 18, 16, 18, 22, 13, 30, 5, 28, 7, 47, 39, 46, 64, 34],
    'lamentations': [22, 22, 66, 22, 22],
    'ezekiel': [28, 10, 27, 17, 17, 14, 27, 18, 11, 22, 25, 28, 23, 23, 8, 63, 24, 32, 14, 49, 32, 31, 49, 27, 17, 21, 36, 26, 21, 26, 18, 32, 33, 31, 15, 38, 28, 23, 29, 49, 26, 20, 27, 31, 25, 24, 23, 35],
    'daniel': [21, 49, 30, 37, 31, 28, 28, 27, 27, 21, 45, 13],
    'hosea': [11, 23, 5, 19, 15, 11, 16, 14, 17, 15, 12, 14, 16, 9],
    'joel': [20, 32, 21],
    'amos': [15, 16, 15, 13, 27, 14, 17, 14, 15],
    'obadiah': [21],
    'jonah': [17, 10, 10, 11],
    'micah': [16, 13, 12, 13, 15, 16, 20],
    'nahum': [15, 13, 19],
    'habakkuk': [17, 20, 19],
    'zephaniah': [18, 15, 20],
    'haggai': [15, 23],
    'zechariah': [21, 13, 10, 14, 11, 15, 14, 23, 17, 12, 17, 14, 9, 21],
    'malachi': [14, 17, 18, 6],
    'matthew': [25, 23, 17, 25, 48, 34, 29, 34, 38, 42, 30, 50, 58, 36, 39, 28, 27, 35, 30, 34, 46, 46, 39, 51, 46, 75, 66, 20],
    'mark': [45, 28, 35, 41, 43, 56, 37, 38, 50, 52, 33, 44, 37, 72, 47, 20],
    'luke': [80, 52, 38, 44, 39, 49, 50, 56, 62, 42, 54, 59, 35, 35, 32, 31, 37, 43, 48, 47, 38, 71, 56, 53],
    'john': [51, 25, 36, 54, 47, 71, 53, 59, 41, 42, 57, 50, 38, 31, 27, 33, 26, 40, 42, 31, 25],
    'acts': [26, 47, 26, 37, 42, 15, 60, 40, 43, 48, 30, 25, 52, 28, 41, 40, 34, 28, 41, 38, 40, 30, 35, 27, 27, 32, 44, 31],
    'romans': [32, 29, 31, 25, 21, 23, 25, 39, 33, 21, 36, 21, 14, 23, 33, 27],
    '1corinthians': [31, 16, 23, 21, 13, 20, 40, 13, 27, 33, 34, 31, 13, 40, 58, 24],
    '2corinthians': [24, 17, 18, 18, 21, 18, 16, 24, 15, 18, 33, 21, 14],
    'galatians': [24, 21, 29, 31, 26, 18],
    'ephesians': [23, 22, 21, 32, 33, 24],
    'philippians': [30, 30, 21, 23],
    'colossians': [29, 23, 25, 18],
    '1thessalonians': [10, 20, 13, 18, 28],
    '2thessalonians': [12, 17, 18],
    '1timothy': [20, 15, 16, 16, 25, 21],
    '2timothy': [18, 26, 17, 22],
    'titus': [16, 15, 15],
    'philemon': [25],
    'hebrews': [14, 18, 19, 16, 14, 20, 28, 13, 28, 39, 40, 29, 25],
    'james': [27, 26, 18, 17, 20],
    '1peter': [25, 25, 22, 19, 14],
    '2peter': [21, 22, 18],
    '1john': [10, 29, 24, 21, 21],
    '2john': [13],
    '3john': [14],
    'jude': [25],
    'revelation': [20, 29, 22, 11, 14, 17, 17, 13, 21, 11, 19, 17, 18, 20, 8, 21, 18, 24, 21, 15, 27, 21],
  };
}
