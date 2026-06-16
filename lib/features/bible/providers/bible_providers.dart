import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../repository/bible_repository.dart';
import '../../../models/bible_verse.dart';
import '../../../core/database/app_database.dart';

class DailyVerse {
  final String version;
  final String bookName;
  final int chapter;
  final int verse;
  final String text;

  const DailyVerse({
    required this.version,
    required this.bookName,
    required this.chapter,
    required this.verse,
    required this.text,
  });
}

final bibleRepositoryProvider = Provider<BibleRepository>((ref) {
  return BibleRepositoryImpl();
});

final booksProvider = FutureProvider.family<List<String>, String>((ref, version) {
  return ref.watch(bibleRepositoryProvider).getBooks(version);
});

final chaptersProvider = FutureProvider.family<List<int>, (String version, String bookName)>((ref, arg) {
  return ref.watch(bibleRepositoryProvider).getChapters(arg.$1, arg.$2);
});

final versesProvider = FutureProvider.family<List<BibleVerse>, (String version, String bookName, int chapter)>((ref, arg) {
  return ref.watch(bibleRepositoryProvider).getVerses(arg.$1, arg.$2, arg.$3);
});

final verseProvider = FutureProvider.family<BibleVerse?, (String version, String bookName, int chapter, int verse)>((ref, arg) {
  return ref.watch(bibleRepositoryProvider).getVerse(arg.$1, arg.$2, arg.$3, arg.$4);
});

class SearchResult {
  final String version;
  final String bookName;
  final int chapter;
  final int verse;
  final String text;

  const SearchResult({
    required this.version,
    required this.bookName,
    required this.chapter,
    required this.verse,
    required this.text,
  });
}

class SearchNotifier extends StateNotifier<AsyncValue<List<SearchResult>>> {
  final BibleRepository _repository;
  SearchNotifier(this._repository) : super(const AsyncValue.data([]));

  Future<void> search(String version, String query) async {
    if (query.trim().length < 2) {
      state = const AsyncValue.data([]);
      return;
    }
    state = const AsyncValue.loading();
    try {
      final List<String> versionsToSearch = version == 'all'
          ? ['telugu_ov', 'telugu_wbtc', 'telugu_irv', 'kjv', 'asv', 'web', 'darby']
          : [version];

      final List<SearchResult> allResults = [];
      for (final v in versionsToSearch) {
        final verses = await _repository.searchVerses(v, query);
        allResults.addAll(verses.map((verse) => SearchResult(
              version: v,
              bookName: verse.bookName,
              chapter: verse.chapter,
              verse: verse.verse,
              text: verse.text,
            )));
      }
      state = AsyncValue.data(allResults);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void clear() {
    state = const AsyncValue.data([]);
  }
}

final searchProvider = StateNotifierProvider<SearchNotifier, AsyncValue<List<SearchResult>>>((ref) {
  final repo = ref.watch(bibleRepositoryProvider);
  return SearchNotifier(repo);
});

final activeVersionProvider = StateProvider<String>((ref) => 'telugu_ov');

final dailyVerseProvider = FutureProvider<DailyVerse?>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final todayStr = DateTime.now().toIso8601String().substring(0, 10);

  final cachedDate = prefs.getString('daily_verse_date');
  if (cachedDate == todayStr) {
    final version = prefs.getString('daily_verse_version') ?? 'telugu_ov';
    final bookName = prefs.getString('daily_verse_book') ?? 'Genesis';
    final chapter = prefs.getInt('daily_verse_chapter') ?? 1;
    final verse = prefs.getInt('daily_verse_verse') ?? 1;
    final text = prefs.getString('daily_verse_text') ?? '';

    if (text.isNotEmpty) {
      return DailyVerse(
        version: version,
        bookName: bookName,
        chapter: chapter,
        verse: verse,
        text: text,
      );
    }
  }

  try {
    final db = await AppDatabase.instance.getDatabase('telugu_ov');
    final countRes = await db.rawQuery('SELECT COUNT(*) FROM verses');
    final count = countRes.isNotEmpty ? countRes.first.values.first as int : 31101;

    final offset = Random().nextInt(count);
    final List<Map<String, dynamic>> rows = await db.rawQuery(
      'SELECT book_name, chapter, verse, text FROM verses LIMIT 1 OFFSET ?',
      [offset],
    );

    if (rows.isNotEmpty) {
      final row = rows.first;
      final bookName = row['book_name'] as String;
      final chapter = row['chapter'] as int;
      final verse = row['verse'] as int;
      final text = row['text'] as String;
      const version = 'telugu_ov';

      await prefs.setString('daily_verse_date', todayStr);
      await prefs.setString('daily_verse_version', version);
      await prefs.setString('daily_verse_book', bookName);
      await prefs.setInt('daily_verse_chapter', chapter);
      await prefs.setInt('daily_verse_verse', verse);
      await prefs.setString('daily_verse_text', text);

      return DailyVerse(
        version: version,
        bookName: bookName,
        chapter: chapter,
        verse: verse,
        text: text,
      );
    }
  } catch (e) {
    // Fallback if DB is not ready
    return const DailyVerse(
      version: 'telugu_ov',
      bookName: 'Genesis',
      chapter: 1,
      verse: 1,
      text: 'ఆదియందు దేవుడు భూమ్యాకాశములను సృజించెను.',
    );
  }
  return null;
});
