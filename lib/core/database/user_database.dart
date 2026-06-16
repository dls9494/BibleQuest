import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class UserDatabase {
  static final UserDatabase instance = UserDatabase._init();
  UserDatabase._init();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('user_data.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE bookmarks (
        id TEXT PRIMARY KEY,
        version TEXT,
        book_name TEXT,
        chapter INTEGER,
        verse INTEGER,
        text TEXT,
        created_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE highlights (
        id TEXT PRIMARY KEY,
        version TEXT,
        book_name TEXT,
        chapter INTEGER,
        verse INTEGER,
        color TEXT,
        created_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE notes (
        id TEXT PRIMARY KEY,
        version TEXT,
        book_name TEXT,
        chapter INTEGER,
        verse INTEGER,
        text TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE reading_progress (
        id TEXT PRIMARY KEY,
        version TEXT,
        book_name TEXT,
        chapter INTEGER,
        verse INTEGER,
        read_at TEXT
      )
    ''');
  }

  // --- CRUD Bookmarks ---
  Future<List<Map<String, dynamic>>> getBookmarks() async {
    final db = await database;
    return await db.query('bookmarks', orderBy: 'created_at DESC');
  }

  Future<void> saveBookmark(Map<String, dynamic> bookmark) async {
    final db = await database;
    await db.insert(
      'bookmarks',
      bookmark,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteBookmark(String id) async {
    final db = await database;
    await db.delete('bookmarks', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearBookmarks() async {
    final db = await database;
    await db.delete('bookmarks');
  }

  // --- CRUD Highlights ---
  Future<List<Map<String, dynamic>>> getHighlights() async {
    final db = await database;
    return await db.query('highlights', orderBy: 'created_at DESC');
  }

  Future<void> saveHighlight(Map<String, dynamic> highlight) async {
    final db = await database;
    await db.insert(
      'highlights',
      highlight,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteHighlight(String id) async {
    final db = await database;
    await db.delete('highlights', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearHighlights() async {
    final db = await database;
    await db.delete('highlights');
  }

  // --- CRUD Notes ---
  Future<List<Map<String, dynamic>>> getNotes() async {
    final db = await database;
    return await db.query('notes', orderBy: 'updated_at DESC');
  }

  Future<void> saveNote(Map<String, dynamic> note) async {
    final db = await database;
    await db.insert(
      'notes',
      note,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteNote(String id) async {
    final db = await database;
    await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearNotes() async {
    final db = await database;
    await db.delete('notes');
  }

  // --- CRUD Reading Progress ---
  Future<List<Map<String, dynamic>>> getReadingProgress() async {
    final db = await database;
    return await db.query('reading_progress', orderBy: 'read_at DESC');
  }

  Future<void> saveReadingProgress(Map<String, dynamic> progress) async {
    final db = await database;
    await db.insert(
      'reading_progress',
      progress,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteReadingProgress(String id) async {
    final db = await database;
    await db.delete('reading_progress', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearReadingProgress() async {
    final db = await database;
    await db.delete('reading_progress');
  }
}
