import 'package:flutter_riverpod/legacy.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/database/user_database.dart';

// --- Bookmarks State ---
class BookmarksNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  BookmarksNotifier() : super([]) {
    loadBookmarks();
    _listenToAuth();
  }

  void _listenToAuth() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        syncFromFirestore();
      } else {
        // Clear local bookmarks when logging out
        UserDatabase.instance.clearBookmarks().then((_) => loadBookmarks());
      }
    });
  }

  Future<void> loadBookmarks() async {
    final list = await UserDatabase.instance.getBookmarks();
    state = list;
  }

  Future<void> toggleBookmark({
    required String version,
    required String bookName,
    required int chapter,
    required int verse,
    required String text,
  }) async {
    final id = '${version}_${bookName}_${chapter}_$verse';
    final exists = state.any((item) => item['id'] == id);

    if (exists) {
      await UserDatabase.instance.deleteBookmark(id);
      state = state.where((item) => item['id'] != id).toList();

      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final docId = '${bookName.toLowerCase()}_${chapter}_$verse';
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('favorited_verses')
            .doc(docId)
            .delete();
      }
    } else {
      final bookmark = {
        'id': id,
        'version': version,
        'book_name': bookName,
        'chapter': chapter,
        'verse': verse,
        'text': text,
        'created_at': DateTime.now().toIso8601String(),
      };
      await UserDatabase.instance.saveBookmark(bookmark);
      state = [bookmark, ...state];

      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final docId = '${bookName.toLowerCase()}_${chapter}_$verse';
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('favorited_verses')
            .doc(docId)
            .set({
          'bookId': bookName.toLowerCase(),
          'chapter': chapter,
          'verse': verse,
          'verseText': text.length > 100 ? '${text.substring(0, 100)}...' : text,
          'version': version,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  Future<void> deleteBookmark(String id) async {
    await UserDatabase.instance.deleteBookmark(id);
    state = state.where((item) => item['id'] != id).toList();

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final parts = id.split('_');
      if (parts.length >= 4) {
        final bookName = parts[1];
        final chapter = parts[2];
        final verse = parts[3];
        final docId = '${bookName.toLowerCase()}_${chapter}_$verse';
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('favorited_verses')
            .doc(docId)
            .delete();
      }
    }
  }

  Future<void> syncFromFirestore() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('favorited_verses')
          .get();

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final bookId = data['bookId'] as String? ?? '';
        final chapter = data['chapter'] as int? ?? 1;
        final verse = data['verse'] as int? ?? 1;
        final text = data['verseText'] as String? ?? '';
        final version = data['version'] as String? ?? 'telugu_ov';
        final id = '${version}_${bookId}_${chapter}_$verse';

        final bookmark = {
          'id': id,
          'version': version,
          'book_name': bookId,
          'chapter': chapter,
          'verse': verse,
          'text': text,
          'created_at': (data['createdAt'] as Timestamp?)?.toDate().toIso8601String() ?? DateTime.now().toIso8601String(),
        };
        await UserDatabase.instance.saveBookmark(bookmark);
      }
      await loadBookmarks();
    } catch (_) {}
  }
}

// --- Highlights State ---
class HighlightsNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  HighlightsNotifier() : super([]) {
    loadHighlights();
    _listenToAuth();
  }

  void _listenToAuth() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        syncFromFirestore();
      } else {
        UserDatabase.instance.clearHighlights().then((_) => loadHighlights());
      }
    });
  }

  Future<void> loadHighlights() async {
    final list = await UserDatabase.instance.getHighlights();
    state = list;
  }

  Future<void> saveHighlight({
    required String version,
    required String bookName,
    required int chapter,
    required int verse,
    required String color,
  }) async {
    final id = '${version}_${bookName}_${chapter}_$verse';
    final highlight = {
      'id': id,
      'version': version,
      'book_name': bookName,
      'chapter': chapter,
      'verse': verse,
      'color': color,
      'created_at': DateTime.now().toIso8601String(),
    };
    await UserDatabase.instance.saveHighlight(highlight);
    state = [highlight, ...state.where((item) => item['id'] != id)];

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final docId = '${bookName.toLowerCase()}_${chapter}_$verse';
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('labelled_verses')
          .doc(docId)
          .set({
        'bookId': bookName.toLowerCase(),
        'chapter': chapter,
        'verse': verse,
        'colour': color,
        'version': version,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> deleteHighlight(String id) async {
    await UserDatabase.instance.deleteHighlight(id);
    state = state.where((item) => item['id'] != id).toList();

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final parts = id.split('_');
      if (parts.length >= 4) {
        final bookName = parts[1];
        final chapter = parts[2];
        final verse = parts[3];
        final docId = '${bookName.toLowerCase()}_${chapter}_$verse';
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('labelled_verses')
            .doc(docId)
            .delete();
      }
    }
  }

  Future<void> syncFromFirestore() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('labelled_verses')
          .get();

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final bookId = data['bookId'] as String? ?? '';
        final chapter = data['chapter'] as int? ?? 1;
        final verse = data['verse'] as int? ?? 1;
        final color = data['colour'] as String? ?? '';
        final version = data['version'] as String? ?? 'telugu_ov';
        final id = '${version}_${bookId}_${chapter}_$verse';

        final highlight = {
          'id': id,
          'version': version,
          'book_name': bookId,
          'chapter': chapter,
          'verse': verse,
          'color': color,
          'created_at': (data['updatedAt'] as Timestamp?)?.toDate().toIso8601String() ?? DateTime.now().toIso8601String(),
        };
        await UserDatabase.instance.saveHighlight(highlight);
      }
      await loadHighlights();
    } catch (_) {}
  }
}

// --- Notes State ---
class NotesNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  NotesNotifier() : super([]) {
    loadNotes();
    _listenToAuth();
  }

  void _listenToAuth() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        syncFromFirestore();
      } else {
        UserDatabase.instance.clearNotes().then((_) => loadNotes());
      }
    });
  }

  Future<void> loadNotes() async {
    final list = await UserDatabase.instance.getNotes();
    state = list;
  }

  Future<void> saveNote({
    required String version,
    required String bookName,
    required int chapter,
    required int verse,
    required String text,
  }) async {
    final id = '${version}_${bookName}_${chapter}_$verse';
    final note = {
      'id': id,
      'version': version,
      'book_name': bookName,
      'chapter': chapter,
      'verse': verse,
      'text': text,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
    await UserDatabase.instance.saveNote(note);
    state = [note, ...state.where((item) => item['id'] != id)];

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await FirebaseFirestore.instance
          .collection('notes')
          .doc(uid)
          .collection('chapter_notes')
          .doc(id)
          .set({
        'bookId': bookName.toLowerCase(),
        'chapter': chapter,
        'verseNumber': verse,
        'verseReference': '$bookName $chapter:$verse',
        'text': text,
        'version': version,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> deleteNote(String id) async {
    await UserDatabase.instance.deleteNote(id);
    state = state.where((item) => item['id'] != id).toList();

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await FirebaseFirestore.instance
          .collection('notes')
          .doc(uid)
          .collection('chapter_notes')
          .doc(id)
          .delete();
    }
  }

  Future<void> syncFromFirestore() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('notes')
          .doc(uid)
          .collection('chapter_notes')
          .get();

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final bookId = data['bookId'] as String? ?? '';
        final chapter = data['chapter'] as int? ?? 1;
        final verse = data['verseNumber'] as int? ?? 1;
        final text = data['text'] as String? ?? '';
        final version = data['version'] as String? ?? 'telugu_ov';
        final id = doc.id;

        final note = {
          'id': id,
          'version': version,
          'book_name': bookId,
          'chapter': chapter,
          'verse': verse,
          'text': text,
          'created_at': (data['createdAt'] as Timestamp?)?.toDate().toIso8601String() ?? DateTime.now().toIso8601String(),
          'updated_at': (data['updatedAt'] as Timestamp?)?.toDate().toIso8601String() ?? DateTime.now().toIso8601String(),
        };
        await UserDatabase.instance.saveNote(note);
      }
      await loadNotes();
    } catch (_) {}
  }
}

// --- Reading Progress State ---
class ReadingProgressNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  ReadingProgressNotifier() : super([]) {
    loadReadingProgress();
    _listenToAuth();
  }

  void _listenToAuth() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        syncFromFirestore();
      } else {
        UserDatabase.instance.clearReadingProgress().then((_) => loadReadingProgress());
      }
    });
  }

  Future<void> loadReadingProgress() async {
    final list = await UserDatabase.instance.getReadingProgress();
    state = list;
  }

  Future<void> saveReadingProgress({
    required String version,
    required String bookName,
    required int chapter,
    required int verse,
  }) async {
    final id = '${version}_${bookName}_$chapter';
    final progress = {
      'id': id,
      'version': version,
      'book_name': bookName,
      'chapter': chapter,
      'verse': verse,
      'read_at': DateTime.now().toIso8601String(),
    };
    await UserDatabase.instance.saveReadingProgress(progress);
    state = [progress, ...state.where((item) => item['id'] != id)];

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('reading_progress')
          .doc(id)
          .set({
        'bookId': bookName.toLowerCase(),
        'chapter': chapter,
        'verse': verse,
        'version': version,
        'readAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> syncFromFirestore() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('reading_progress')
          .get();

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final bookId = data['bookId'] as String? ?? '';
        final chapter = data['chapter'] as int? ?? 1;
        final verse = data['verse'] as int? ?? 1;
        final version = data['version'] as String? ?? 'telugu_ov';
        final id = doc.id;

        final progress = {
          'id': id,
          'version': version,
          'book_name': bookId,
          'chapter': chapter,
          'verse': verse,
          'read_at': (data['readAt'] as Timestamp?)?.toDate().toIso8601String() ?? DateTime.now().toIso8601String(),
        };
        await UserDatabase.instance.saveReadingProgress(progress);
      }
      await loadReadingProgress();
    } catch (_) {}
  }
}

// --- Riverpod Providers ---
final bookmarksProvider = StateNotifierProvider<BookmarksNotifier, List<Map<String, dynamic>>>((ref) {
  return BookmarksNotifier();
});

final highlightsProvider = StateNotifierProvider<HighlightsNotifier, List<Map<String, dynamic>>>((ref) {
  return HighlightsNotifier();
});

final notesProvider = StateNotifierProvider<NotesNotifier, List<Map<String, dynamic>>>((ref) {
  return NotesNotifier();
});

final readingProgressProvider = StateNotifierProvider<ReadingProgressNotifier, List<Map<String, dynamic>>>((ref) {
  return ReadingProgressNotifier();
});
