import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/bible.dart';

class BibleService {
  // ─── In-memory cache ─────────────────────────────────────────────────────
  static final Map<String, Map<String, dynamic>> _versionCaches = {};
  static final Map<String, Map<int, String>> _chapterCache = {};
  static List<SearchVerse>? _searchIndex;

  static const Map<String, String> versionToAssetPath = {
    'te': 'assets/bible/telugu_ov.json',
    'kjv': 'assets/bible/kjv_bible.json',
    'nhv': 'assets/bible/nhv_bible.json',
    'english_kjv': 'assets/bible/english_kjv.json',
    'english_asv': 'assets/bible/english_asv.json',
    'english_web': 'assets/bible/english_web.json',
    'english_darby': 'assets/bible/english_darby.json',
    'telugu_ov': 'assets/bible/telugu_ov.json',
  };

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

  // Map from book id → English name in JSON (to look up in asset)
  static const Map<String, String> _idToJsonName = {
    'genesis': 'Genesis',
    'exodus': 'Exodus',
    'leviticus': 'Leviticus',
    'numbers': 'Numbers',
    'deuteronomy': 'Deuteronomy',
    'joshua': 'Joshua',
    'judges': 'Judges',
    'ruth': 'Ruth',
    '1samuel': '1 Samuel',
    '2samuel': '2 Samuel',
    '1kings': '1 Kings',
    '2kings': '2 Kings',
    '1chronicles': '1 Chronicles',
    '2chronicles': '2 Chronicles',
    'ezra': 'Ezra',
    'nehemiah': 'Nehemiah',
    'esther': 'Esther',
    'job': 'Job',
    'psalms': 'Psalms',
    'proverbs': 'Proverbs',
    'ecclesiastes': 'Ecclesiastes',
    'songofsolomon': 'Song of Solomon',
    'isaiah': 'Isaiah',
    'jeremiah': 'Jeremiah',
    'lamentations': 'Lamentations',
    'ezekiel': 'Ezekiel',
    'daniel': 'Daniel',
    'hosea': 'Hosea',
    'joel': 'Joel',
    'amos': 'Amos',
    'obadiah': 'Obadiah',
    'jonah': 'Jonah',
    'micah': 'Micah',
    'nahum': 'Nahum',
    'habakkuk': 'Habakkuk',
    'zephaniah': 'Zephaniah',
    'haggai': 'Haggai',
    'zechariah': 'Zechariah',
    'malachi': 'Malachi',
    'matthew': 'Matthew',
    'mark': 'Mark',
    'luke': 'Luke',
    'john': 'John',
    'acts': 'Acts',
    'romans': 'Romans',
    '1corinthians': '1 Corinthians',
    '2corinthians': '2 Corinthians',
    'galatians': 'Galatians',
    'ephesians': 'Ephesians',
    'philippians': 'Philippians',
    'colossians': 'Colossians',
    '1thessalonians': '1 Thessalonians',
    '2thessalonians': '2 Thessalonians',
    '1timothy': '1 Timothy',
    '2timothy': '2 Timothy',
    'titus': 'Titus',
    'philemon': 'Philemon',
    'hebrews': 'Hebrews',
    'james': 'James',
    '1peter': '1 Peter',
    '2peter': '2 Peter',
    '1john': '1 John',
    '2john': '2 John',
    '3john': '3 John',
    'jude': 'Jude',
    'revelation': 'Revelation',
  };

  static List<BibleBook> getBooks() => _books;
  static List<BibleBook> getAllBooks() => _books;
  static List<BibleBook> getOTBooks() => _books.where((b) => b.testament == 'OT').toList();
  static List<BibleBook> getNTBooks() => _books.where((b) => b.testament == 'NT').toList();

  static BibleBook? getBookById(String id) {
    try {
      return _books.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
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

  // ─── Asset loading ───────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> _loadVersion(String version) async {
    if (_versionCaches.containsKey(version)) {
      return _versionCaches[version]!;
    }
    final assetPath = versionToAssetPath[version];
    if (assetPath == null) return {};
    try {
      final jsonStr = await rootBundle.loadString(assetPath);
      final decoded = json.decode(jsonStr) as Map<String, dynamic>;
      _versionCaches[version] = decoded;
      return decoded;
    } catch (e) {
      // ignore: avoid_print
      print("Error loading version $version: $e");
      return {};
    }
  }

  static Future<Map<String, dynamic>> _loadKjv() => _loadVersion('kjv');
  static Future<Map<String, dynamic>> _loadTelugu() => _loadVersion('te');
  static Future<Map<String, dynamic>> _loadNhv() => _loadVersion('nhv');

  /// Returns {verseNumber: text} for a given book/chapter/version.
  /// version: 'te' | 'kjv' | 'nhv' | 'english_kjv' | 'english_asv' | ...
  static Future<Map<int, String>> getChapter(String bookId, int chapter, String version) async {
    final cacheKey = "$version:$bookId:$chapter";
    if (_chapterCache.containsKey(cacheKey)) {
      return _chapterCache[cacheKey]!;
    }

    final jsonName = _idToJsonName[bookId] ?? '';
    if (jsonName.isEmpty) return {};

    final data = await _loadVersion(version);

    final bookData = data[jsonName] as Map<String, dynamic>?;
    if (bookData == null) return {};

    final chapterData = bookData[chapter.toString()] as Map<String, dynamic>?;
    if (chapterData == null) return {};

    final result = <int, String>{};
    chapterData.forEach((verseKey, text) {
      final verseNum = int.tryParse(verseKey);
      if (verseNum != null) {
        result[verseNum] = text.toString();
      }
    });

    _chapterCache[cacheKey] = result;
    return result;
  }

  /// Returns verses for bilingual mode: {verse: {te: text, kjv: text}}
  static Future<Map<int, Map<String, String>>> getChapterBilingual(
      String bookId, int chapter) async {
    final te = await getChapter(bookId, chapter, 'te');
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
    final te = await getChapter(bookId, chapter, 'te');
    final kjv = await getChapter(bookId, chapter, 'kjv');
    final nhv = await getChapter(bookId, chapter, 'nhv');

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

    final kjv = await _loadKjv();
    final telugu = await _loadTelugu();
    final nhv = await _loadNhv();

    final list = <SearchVerse>[];
    for (final book in _books) {
      final jsonName = _idToJsonName[book.id] ?? '';
      if (jsonName.isEmpty) continue;

      final bookKjv = kjv[jsonName] as Map<String, dynamic>? ?? {};
      final bookTe = telugu[jsonName] as Map<String, dynamic>? ?? {};
      final bookNhv = nhv[jsonName] as Map<String, dynamic>? ?? {};

      final chapters = {...bookKjv.keys, ...bookTe.keys, ...bookNhv.keys}.toList();
      chapters.sort((a, b) => int.parse(a).compareTo(int.parse(b)));

      for (final chStr in chapters) {
        final ch = int.tryParse(chStr) ?? 1;
        final chKjv = bookKjv[chStr] as Map<String, dynamic>? ?? {};
        final chTe = bookTe[chStr] as Map<String, dynamic>? ?? {};
        final chNhv = bookNhv[chStr] as Map<String, dynamic>? ?? {};

        final verses = {...chKjv.keys, ...chTe.keys, ...chNhv.keys}.toList();
        verses.sort((a, b) => int.parse(a).compareTo(int.parse(b)));

        for (final vStr in verses) {
          final v = int.tryParse(vStr) ?? 1;
          list.add(SearchVerse(
            bookId: book.id,
            bookNameEn: book.nameEn,
            bookNameTe: book.nameTe,
            chapter: ch,
            verse: v,
            textTe: chTe[vStr]?.toString() ?? '',
            textKjv: chKjv[vStr]?.toString() ?? '',
            textNhv: chNhv[vStr]?.toString() ?? '',
          ));
        }
      }
    }
    _searchIndex = list;
    return _searchIndex!;
  }
}
