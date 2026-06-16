import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Production-grade analytics service wrapping [FirebaseAnalytics].
///
/// Every method is safe to call before Firebase Analytics is fully ready
/// because the underlying SDK queues events internally.
///
/// In **debug builds** a local ring-buffer ([debugEventLog]) is maintained so
/// the companion [AnalyticsDebugScreen] can display live event history.
class AnalyticsService {
  AnalyticsService._();

  static final _fa = FirebaseAnalytics.instance;

  // ---------------------------------------------------------------------------
  // Debug event log (debug mode only — ring-buffer, max 100 entries)
  // ---------------------------------------------------------------------------

  /// Ordered list of recent events.  Only populated in debug builds.
  static final List<AnalyticsEvent> debugEventLog = [];
  static const int _maxDebugEvents = 100;

  static void _debug(String name, [Map<String, Object?>? params]) {
    if (!kDebugMode) return;
    final event = AnalyticsEvent(
      name: name,
      params: params ?? {},
      timestamp: DateTime.now(),
    );
    debugEventLog.add(event);
    if (debugEventLog.length > _maxDebugEvents) {
      debugEventLog.removeAt(0);
    }
  }

  // ---------------------------------------------------------------------------
  // GoRouter / Screen tracking
  // ---------------------------------------------------------------------------

  /// The [FirebaseAnalyticsObserver] to pass to [MaterialApp.router].
  static FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _fa);

  /// Log an explicit screen view (for screens not managed by GoRouter).
  static Future<void> logScreenView(String screenName) async {
    _debug('screen_view', {'screen_name': screenName});
    await _fa.logScreenView(screenName: screenName);
  }

  // ---------------------------------------------------------------------------
  // Bible analytics
  // ---------------------------------------------------------------------------

  static Future<void> logBibleOpen({required String translation}) async {
    _debug('bible_open', {'translation': translation});
    await _fa.logEvent(
      name: 'bible_open',
      parameters: {'translation': translation},
    );
  }

  static Future<void> logChapterOpen({
    required String book,
    required int chapter,
    required String translation,
  }) async {
    _debug('chapter_open', {
      'book': book,
      'chapter': chapter,
      'translation': translation,
    });
    await _fa.logEvent(
      name: 'chapter_open',
      parameters: {
        'book': book,
        'chapter': chapter,
        'translation': translation,
      },
    );
  }

  static Future<void> logSearch({
    required String query,
    required String translation,
  }) async {
    _debug('bible_search', {'query': query, 'translation': translation});
    await _fa.logSearch(searchTerm: '$query ($translation)');
    // Also log a custom event with full context
    await _fa.logEvent(
      name: 'bible_search',
      parameters: {'query': query, 'translation': translation},
    );
  }

  static Future<void> logBookmarkAdded({
    required String book,
    required int chapter,
    required int verse,
  }) async {
    _debug('bookmark_added', {
      'book': book,
      'chapter': chapter,
      'verse': verse,
    });
    await _fa.logEvent(
      name: 'bookmark_added',
      parameters: {'book': book, 'chapter': chapter, 'verse': verse},
    );
  }

  static Future<void> logHighlightAdded({required String color}) async {
    _debug('highlight_added', {'color': color});
    await _fa.logEvent(
      name: 'highlight_added',
      parameters: {'color': color},
    );
  }

  static Future<void> logNoteCreated() async {
    _debug('note_created');
    await _fa.logEvent(name: 'note_created');
  }

  static Future<void> logAudioStarted({required String translation}) async {
    _debug('audio_started', {'translation': translation});
    await _fa.logEvent(
      name: 'audio_started',
      parameters: {'translation': translation},
    );
  }

  static Future<void> logAudioCompleted({required String translation}) async {
    _debug('audio_completed', {'translation': translation});
    await _fa.logEvent(
      name: 'audio_completed',
      parameters: {'translation': translation},
    );
  }

  static Future<void> logDailyVerseOpened() async {
    _debug('daily_verse_opened');
    await _fa.logEvent(name: 'daily_verse_opened');
  }

  // ---------------------------------------------------------------------------
  // Reading Plan analytics
  // ---------------------------------------------------------------------------

  static Future<void> logReadingPlanStarted({
    required String planName,
  }) async {
    _debug('reading_plan_started', {'plan_name': planName});
    await _fa.logEvent(
      name: 'reading_plan_started',
      parameters: {'plan_name': planName},
    );
  }

  static Future<void> logReadingPlanCompleted({
    required String planName,
  }) async {
    _debug('reading_plan_completed', {'plan_name': planName});
    await _fa.logEvent(
      name: 'reading_plan_completed',
      parameters: {'plan_name': planName},
    );
  }

  // ---------------------------------------------------------------------------
  // Quiz analytics
  // ---------------------------------------------------------------------------

  static Future<void> logQuizStarted({required String quizType}) async {
    _debug('quiz_started', {'quiz_type': quizType});
    await _fa.logEvent(
      name: 'quiz_started',
      parameters: {'quiz_type': quizType},
    );
  }

  static Future<void> logQuizCompleted({
    required String quizType,
    required int score,
  }) async {
    _debug('quiz_completed', {'quiz_type': quizType, 'score': score});
    await _fa.logEvent(
      name: 'quiz_completed',
      parameters: {'quiz_type': quizType, 'score': score},
    );
  }

  // ---------------------------------------------------------------------------
  // Achievement & Community analytics
  // ---------------------------------------------------------------------------

  static Future<void> logAchievementUnlocked({
    required String achievementId,
  }) async {
    _debug('achievement_unlocked', {'achievement_id': achievementId});
    await _fa.logEvent(
      name: 'achievement_unlocked',
      parameters: {'achievement_id': achievementId},
    );
  }

  static Future<void> logPrayerRequestCreated() async {
    _debug('prayer_request_created');
    await _fa.logEvent(name: 'prayer_request_created');
  }

  static Future<void> logPrayerReaction() async {
    _debug('prayer_reaction');
    await _fa.logEvent(name: 'prayer_reaction');
  }

  static Future<void> logBattleStarted() async {
    _debug('battle_started');
    await _fa.logEvent(name: 'battle_started');
  }

  static Future<void> logBattleCompleted({required bool won}) async {
    _debug('battle_completed', {'won': won ? 'true' : 'false'});
    await _fa.logEvent(
      name: 'battle_completed',
      parameters: {'won': won ? 'true' : 'false'},
    );
  }

  static Future<void> logGroupJoined() async {
    _debug('group_joined');
    await _fa.logEvent(name: 'group_joined');
  }

  // ---------------------------------------------------------------------------
  // User Properties
  // ---------------------------------------------------------------------------

  /// Sets user-scoped properties for segmentation in the Firebase console.
  /// All parameters are optional — only non-null values are set.
  static Future<void> setUserProperties({
    String? preferredLanguage,
    String? selectedTranslation,
    int? userLevel,
    int? streakDays,
    String? accountType,
  }) async {
    if (preferredLanguage != null) {
      await _fa.setUserProperty(
          name: 'preferred_language', value: preferredLanguage);
    }
    if (selectedTranslation != null) {
      await _fa.setUserProperty(
          name: 'selected_translation', value: selectedTranslation);
    }
    if (userLevel != null) {
      await _fa.setUserProperty(
          name: 'user_level', value: userLevel.toString());
    }
    if (streakDays != null) {
      await _fa.setUserProperty(
          name: 'streak_days', value: streakDays.toString());
    }
    if (accountType != null) {
      await _fa.setUserProperty(name: 'account_type', value: accountType);
    }

    _debug('_set_user_properties', {
      if (preferredLanguage != null) 'preferred_language': preferredLanguage,
      if (selectedTranslation != null)
        'selected_translation': selectedTranslation,
      if (userLevel != null) 'user_level': userLevel,
      if (streakDays != null) 'streak_days': streakDays,
      if (accountType != null) 'account_type': accountType,
    });
  }
}

/// Data class representing a single recorded analytics event (debug mode only).
class AnalyticsEvent {
  final String name;
  final Map<String, Object?> params;
  final DateTime timestamp;

  const AnalyticsEvent({
    required this.name,
    required this.params,
    required this.timestamp,
  });

  @override
  String toString() {
    final ts =
        '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}';
    if (params.isEmpty) return '[$ts] $name';
    final paramStr = params.entries.map((e) => '${e.key}=${e.value}').join(', ');
    return '[$ts] $name  {$paramStr}';
  }
}
