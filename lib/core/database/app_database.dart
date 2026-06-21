import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();
  AppDatabase._init();

  static const int _dbVersion = 4; // Increment this whenever DB assets are updated.
  final Map<String, Database> _databases = {};

  /// Pre-copies all 7 databases from assets to database directory on first launch.
  Future<void> copyAllDatabasesOnFirstLaunch() async {
    final versions = [
      'telugu_ov',
      'telugu_wbtc',
      'telugu_irv',
      'kjv',
      'asv',
      'web',
      'darby',
    ];
    for (final version in versions) {
      await _copyDatabaseIfNeeded(version);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('db_version_key', _dbVersion);
  }

  Future<void> _copyDatabaseIfNeeded(String version) async {
    final databasesPath = await getDatabasesPath();
    final dbPath = p.join(databasesPath, '$version.sqlite');

    final prefs = await SharedPreferences.getInstance();
    final currentSavedVersion = prefs.getInt('db_version_key') ?? 0;

    final exists = await databaseExists(dbPath);
    if (!exists || currentSavedVersion < _dbVersion) {
      // Create parent directory
      try {
        await Directory(p.dirname(dbPath)).create(recursive: true);
      } catch (_) {}

      // Force delete old version if it exists to allow overwrite
      if (exists) {
        try {
          final file = File(dbPath);
          if (await file.exists()) {
            await file.delete();
          }
        } catch (_) {}
      }

      // Copy from asset
      final assetPath = 'assets/bible/$version.sqlite';
      try {
        final data = await rootBundle.load(assetPath);
        final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        await File(dbPath).writeAsBytes(bytes, flush: true);
      } catch (e) {
        throw Exception('Failed to copy asset $assetPath to local database: $e');
      }
    }
  }

  /// Exposes the SQLite database for a given version.
  Future<Database> getDatabase(String version) async {
    if (_databases.containsKey(version)) {
      final db = _databases[version]!;
      if (db.isOpen) {
        return db;
      }
    }

    await _copyDatabaseIfNeeded(version);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('db_version_key', _dbVersion);

    final databasesPath = await getDatabasesPath();
    final dbPath = p.join(databasesPath, '$version.sqlite');

    final db = await openDatabase(dbPath, readOnly: true);
    _databases[version] = db;
    return db;
  }
}
