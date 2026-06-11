import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audio_service/audio_service.dart' as as_pkg;
import 'package:shared_preferences/shared_preferences.dart';
import 'bible_service.dart';

class AudioService extends as_pkg.BaseAudioHandler {
  static late final AudioService instance;

  final FlutterTts _tts = FlutterTts();
  
  bool _isPlaying = false;
  int _currentVerseIndex = -1;
  List<as_pkg.MediaItem> _versesQueue = [];
  String _bookId = '';
  int _chapter = 1;
  String _language = 'te-IN';
  bool _autoAdvance = true;
  double _playbackSpeed = 1.0;

  final StreamController<Map<String, int>> _verseChangedController =
      StreamController<Map<String, int>>.broadcast();
  Stream<Map<String, int>> get onVerseChanged => _verseChangedController.stream;

  AudioService() {
    _initTts();
  }

  void _initTts() {
    _tts.setVolume(1.0);
    _tts.setPitch(1.0);

    _tts.setStartHandler(() {
      _isPlaying = true;
      playbackState.add(playbackState.value.copyWith(
        playing: true,
        processingState: as_pkg.AudioProcessingState.ready,
        controls: _getControls(),
        updatePosition: Duration.zero,
      ));
      _emitState();
    });

    _tts.setCompletionHandler(() {
      _isPlaying = false;
      playbackState.add(playbackState.value.copyWith(
        playing: false,
        processingState: as_pkg.AudioProcessingState.ready,
        controls: _getControls(),
      ));
      _onVerseComplete();
    });

    _tts.setCancelHandler(() {
      _isPlaying = false;
      playbackState.add(playbackState.value.copyWith(
        playing: false,
        processingState: as_pkg.AudioProcessingState.ready,
        controls: _getControls(),
      ));
    });

    _tts.setErrorHandler((_) {
      _isPlaying = false;
      playbackState.add(playbackState.value.copyWith(
        playing: false,
        processingState: as_pkg.AudioProcessingState.error,
        controls: _getControls(),
      ));
    });
  }

  List<as_pkg.MediaControl> _getControls() {
    return [
      as_pkg.MediaControl.skipToPrevious,
      if (_isPlaying) as_pkg.MediaControl.pause else as_pkg.MediaControl.play,
      as_pkg.MediaControl.stop,
      as_pkg.MediaControl.skipToNext,
    ];
  }

  // ─── Backward compatibility for VerseOfTheDayCard ────────────────────────

  static Future<void> speak(String text, {String language = 'te-IN'}) async {
    // If playing chapter, stop it first
    if (instance._versesQueue.isNotEmpty) {
      await instance.stop();
    }
    await instance._tts.setLanguage(language);
    // Set speed rate to normal for one-off speaking
    await instance._tts.setSpeechRate(0.5);
    await instance._tts.speak(text);
  }

  static Future<void> stopSpeech() async {
    await instance._tts.stop();
  }

  static void setHandlers({
    required VoidCallback onStart,
    required VoidCallback onComplete,
    required VoidCallback onError,
  }) {
    instance._tts.setStartHandler(() {
      onStart();
    });
    instance._tts.setCompletionHandler(() {
      onComplete();
    });
    instance._tts.setCancelHandler(() {
      onComplete();
    });
    instance._tts.setErrorHandler((_) {
      onError();
    });
  }

  // ─── Chapter Playback Logic ──────────────────────────────────────────────

  Future<void> playChapter(
    String bookId,
    int chapter,
    List<String> versesTexts,
    String language, {
    int startVerseIndex = 0,
  }) async {
    // Reset TTS completion handlers to chapter playback
    _initTts();

    _bookId = bookId;
    _chapter = chapter;
    _language = language;

    final prefs = await SharedPreferences.getInstance();
    _autoAdvance = prefs.getBool('audio_auto_advance') ?? true;
    _playbackSpeed = prefs.getDouble('audio_speed') ?? 1.0;

    final book = BibleService.getBookById(bookId);
    final bookName = language == 'te-IN' ? (book?.nameTe ?? bookId) : (book?.nameEn ?? bookId);

    // Build the queue of MediaItems
    _versesQueue = List.generate(versesTexts.length, (index) {
      final verseNum = index + 1;
      return as_pkg.MediaItem(
        id: '${bookId}_${chapter}_$verseNum',
        album: 'Bible / బైబిల్',
        title: '$bookName $chapter:$verseNum',
        artist: language == 'te-IN' ? 'తెలుగు బైబిల్ క్విజ్' : 'Telugu Bible Quiz',
        extras: {'text': versesTexts[index]},
      );
    });

    queue.add(_versesQueue);
    _currentVerseIndex = startVerseIndex.clamp(0, _versesQueue.length - 1);

    // Set speed rate
    double rate = _playbackSpeed * 0.5;
    await _tts.setSpeechRate(rate);
    await _tts.setLanguage(language);

    await play();
  }

  @override
  Future<void> play() async {
    if (_versesQueue.isEmpty) return;
    if (_currentVerseIndex < 0 || _currentVerseIndex >= _versesQueue.length) {
      _currentVerseIndex = 0;
    }

    final mediaItem = _versesQueue[_currentVerseIndex];
    this.mediaItem.add(mediaItem);

    playbackState.add(playbackState.value.copyWith(
      playing: true,
      processingState: as_pkg.AudioProcessingState.ready,
      controls: _getControls(),
      updatePosition: Duration.zero,
    ));

    final text = mediaItem.extras?['text'] as String? ?? '';
    await _tts.speak(text);
    _emitState();
  }

  @override
  Future<void> pause() async {
    await _tts.stop();
    _isPlaying = false;
    playbackState.add(playbackState.value.copyWith(
      playing: false,
      processingState: as_pkg.AudioProcessingState.ready,
      controls: _getControls(),
    ));
    _emitState();
  }

  @override
  Future<void> stop() async {
    await _tts.stop();
    _isPlaying = false;

    // Save position before stopping if valid
    if (_bookId.isNotEmpty && _versesQueue.isNotEmpty && _currentVerseIndex >= 0) {
      await savePosition(_bookId, _chapter, _currentVerseIndex);
    }

    _versesQueue = [];
    queue.add([]);
    mediaItem.add(null);
    _currentVerseIndex = -1;

    playbackState.add(playbackState.value.copyWith(
      playing: false,
      processingState: as_pkg.AudioProcessingState.idle,
      controls: [],
    ));
    _emitState();
  }

  @override
  Future<void> skipToNext() async {
    if (_versesQueue.isEmpty) return;
    if (_currentVerseIndex + 1 < _versesQueue.length) {
      _currentVerseIndex++;
      await play();
    } else {
      // Completed last verse in chapter
      if (_autoAdvance) {
        await _advanceToNextChapter();
      } else {
        await stop();
      }
    }
  }

  @override
  Future<void> skipToPrevious() async {
    if (_versesQueue.isEmpty) return;
    if (_currentVerseIndex - 1 >= 0) {
      _currentVerseIndex--;
      await play();
    } else {
      // Re-play the first verse
      await play();
    }
  }

  @override
  Future<void> setSpeed(double speed) async {
    _playbackSpeed = speed;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('audio_speed', speed);

    double rate = speed * 0.5;
    await _tts.setSpeechRate(rate);

    playbackState.add(playbackState.value.copyWith(
      speed: speed,
    ));
  }

  void _onVerseComplete() {
    // TTS completed the utterance. Skip to next.
    skipToNext();
  }

  Future<void> _advanceToNextChapter() async {
    final book = BibleService.getBookById(_bookId);
    if (book == null) {
      await stop();
      return;
    }

    int nextChapter = _chapter + 1;
    String nextBookId = _bookId;

    if (nextChapter > book.chapters) {
      // Move to next book in canonical order
      final allBooks = BibleService.getAllBooks();
      final currentBookIdx = allBooks.indexWhere((b) => b.id == _bookId);
      if (currentBookIdx != -1 && currentBookIdx + 1 < allBooks.length) {
        final nextBook = allBooks[currentBookIdx + 1];
        nextBookId = nextBook.id;
        nextChapter = 1;
      } else {
        // Last book, last chapter
        await stop();
        return;
      }
    }

    final nextVerses = await BibleService.getChapterVerses(nextBookId, nextChapter);
    if (nextVerses.isEmpty) {
      await stop();
      return;
    }

    final isTelugu = _language == 'te-IN';
    final List<String> versesTexts = nextVerses.map((v) => isTelugu ? v.textTe : v.textKjv).toList();

    // Automatically trigger next chapter audio
    await playChapter(nextBookId, nextChapter, versesTexts, _language, startVerseIndex: 0);
  }

  void _emitState() {
    _verseChangedController.add({
      'current': _currentVerseIndex,
      'total': _versesQueue.length,
    });
  }

  // ─── Bookmark Persistency ────────────────────────────────────────────────

  Future<void> savePosition(String bookId, int chapter, int verseIndex) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('audio_book', bookId);
    await prefs.setInt('audio_chapter', chapter);
    await prefs.setInt('audio_verse', verseIndex);
  }

  Future<Map<String, dynamic>?> getSavedPosition() async {
    final prefs = await SharedPreferences.getInstance();
    final bookId = prefs.getString('audio_book');
    final chapter = prefs.getInt('audio_chapter');
    final verse = prefs.getInt('audio_verse');
    if (bookId != null && chapter != null && verse != null) {
      return {
        'bookId': bookId,
        'chapter': chapter,
        'verse': verse,
      };
    }
    return null;
  }

  Future<void> clearSavedPosition() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('audio_book');
    await prefs.remove('audio_chapter');
    await prefs.remove('audio_verse');
  }

  Future<void> setAutoAdvance(bool enabled) async {
    _autoAdvance = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('audio_auto_advance', enabled);
  }

  bool get autoAdvance => _autoAdvance;
  double get playbackSpeed => _playbackSpeed;
  int get currentVerseIndex => _currentVerseIndex;
  String get currentBookId => _bookId;
  int get currentChapter => _chapter;
  bool get isActive => _versesQueue.isNotEmpty;
  bool get isPlaying => _isPlaying;
  Map<String, int> get currentVerseInfo => {
    'current': _currentVerseIndex,
    'total': _versesQueue.length,
  };
}
