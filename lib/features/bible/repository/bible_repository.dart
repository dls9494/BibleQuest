import '../../../../core/database/app_database.dart';
import '../../../../models/bible_verse.dart';
import '../../../../services/bible_service.dart' hide BibleVerse, SearchVerse;

abstract class BibleRepository {
  Future<List<String>> getBooks(String version);
  Future<List<int>> getChapters(String version, String bookName);
  Future<List<BibleVerse>> getVerses(String version, String bookName, int chapter);
  Future<List<BibleVerse>> searchVerses(String version, String query);
  Future<BibleVerse?> getVerse(String version, String bookName, int chapter, int verse);
}

class BibleRepositoryImpl implements BibleRepository {
  final AppDatabase _appDatabase;

  BibleRepositoryImpl({AppDatabase? appDatabase}) : _appDatabase = appDatabase ?? AppDatabase.instance;

  @override
  Future<List<String>> getBooks(String version) async {
    // Return standard English book names to ensure consistent routing,
    // lookups, and mapping in UI screens.
    return BibleService.getBooks().map((b) => b.nameEn).toList();
  }

  @override
  Future<List<int>> getChapters(String version, String bookName) async {
    final db = await _appDatabase.getDatabase(version);
    final book = BibleService.findBookByName(bookName);
    final queryBookName = book?.nameEn ?? bookName;

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT DISTINCT chapter FROM verses WHERE LOWER(book_name) = ? ORDER BY chapter',
      [queryBookName.toLowerCase()],
    );
    return List.generate(maps.length, (i) => maps[i]['chapter'] as int);
  }

  @override
  Future<List<BibleVerse>> getVerses(String version, String bookName, int chapter) async {
    final db = await _appDatabase.getDatabase(version);
    final book = BibleService.findBookByName(bookName);
    final queryBookName = book?.nameEn ?? bookName;

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT book_number, book_name, chapter, verse, text FROM verses WHERE LOWER(book_name) = ? AND chapter = ? ORDER BY verse',
      [queryBookName.toLowerCase(), chapter],
    );
    return List.generate(maps.length, (i) => BibleVerse.fromMap(maps[i]));
  }

  @override
  Future<List<BibleVerse>> searchVerses(String version, String query) async {
    if (query.trim().isEmpty) return [];
    final db = await _appDatabase.getDatabase(version);
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT book_number, book_name, chapter, verse, text FROM verses WHERE text LIKE ? LIMIT 50',
      ['%$query%'],
    );
    return List.generate(maps.length, (i) => BibleVerse.fromMap(maps[i]));
  }

  @override
  Future<BibleVerse?> getVerse(String version, String bookName, int chapter, int verse) async {
    final db = await _appDatabase.getDatabase(version);
    final book = BibleService.findBookByName(bookName);
    final queryBookName = book?.nameEn ?? bookName;

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT book_number, book_name, chapter, verse, text FROM verses WHERE LOWER(book_name) = ? AND chapter = ? AND verse = ? LIMIT 1',
      [queryBookName.toLowerCase(), chapter, verse],
    );
    if (maps.isEmpty) return null;
    return BibleVerse.fromMap(maps.first);
  }
}
