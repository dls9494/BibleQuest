import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Thin wrapper around [FirebaseCrashlytics] that queues errors arriving
/// before Firebase is ready (e.g. during startup) and flushes them once
/// [init] is called.  No crash is ever silently dropped.
class CrashlyticsService {
  CrashlyticsService._();

  // ---------------------------------------------------------------------------
  // Internal state
  // ---------------------------------------------------------------------------

  static bool _initialized = false;

  /// Errors captured before [init] is called.
  /// Each entry: { 'error': Object, 'stack': StackTrace?, 'fatal': bool,
  ///               'reason': String?, 'isFlutterDetails': bool,
  ///               'details': FlutterErrorDetails? }
  static final List<Map<String, dynamic>> _pendingErrors = [];

  /// Breadcrumb log lines captured before [init] is called.
  static final List<String> _pendingLogs = [];

  // ---------------------------------------------------------------------------
  // Initialisation — call once, AFTER Firebase.initializeApp()
  // ---------------------------------------------------------------------------

  /// Enables Crashlytics collection (disabled in debug builds by default) and
  /// flushes any errors that were queued before Firebase was ready.
  static Future<void> init() async {
    // Disable collection during debug so dev crashes don't pollute the dashboard.
    // Remove the condition if you want reports in debug builds too.
    await FirebaseCrashlytics.instance
        .setCrashlyticsCollectionEnabled(!kDebugMode);

    _initialized = true;

    // Flush queued log lines first so they appear as breadcrumbs on the reports.
    for (final msg in _pendingLogs) {
      FirebaseCrashlytics.instance.log(msg);
    }
    _pendingLogs.clear();

    // Flush queued errors.
    for (final entry in _pendingErrors) {
      if (entry['isFlutterDetails'] == true) {
        final details = entry['details'] as FlutterErrorDetails;
        FirebaseCrashlytics.instance.recordFlutterFatalError(details);
      } else {
        await FirebaseCrashlytics.instance.recordError(
          entry['error'] as Object,
          entry['stack'] as StackTrace?,
          fatal: entry['fatal'] as bool? ?? false,
          reason: entry['reason'] as String?,
        );
      }
    }
    _pendingErrors.clear();
  }

  // ---------------------------------------------------------------------------
  // Error recording — safe to call at any time (even before init)
  // ---------------------------------------------------------------------------

  /// Record a non-fatal (or fatal) exception.  Queues automatically if
  /// Crashlytics is not yet initialised.
  static Future<void> recordNonFatal(
    Object error,
    StackTrace? stack, {
    bool fatal = false,
    String? reason,
  }) async {
    if (!_initialized) {
      _pendingErrors.add({
        'isFlutterDetails': false,
        'error': error,
        'stack': stack,
        'fatal': fatal,
        'reason': reason,
      });
      return;
    }
    await FirebaseCrashlytics.instance.recordError(
      error,
      stack,
      fatal: fatal,
      reason: reason,
    );
  }

  /// Record a [FlutterErrorDetails] (passed from [FlutterError.onError]).
  /// Queues automatically if Crashlytics is not yet initialised.
  static Future<void> recordFlutterError(FlutterErrorDetails details) async {
    if (!_initialized) {
      _pendingErrors.add({
        'isFlutterDetails': true,
        'details': details,
      });
      return;
    }
    FirebaseCrashlytics.instance.recordFlutterFatalError(details);
  }

  // ---------------------------------------------------------------------------
  // Helpers — all safe before init
  // ---------------------------------------------------------------------------

  /// Add a searchable custom key/value to crash reports.
  static Future<void> setCustomKey(String key, Object value) async {
    if (!_initialized) return; // Keys can't be queued; skip silently pre-init.
    await FirebaseCrashlytics.instance.setCustomKey(key, value);
  }

  /// Associate a Firebase Auth UID with crash reports.
  static Future<void> setUserId(String userId) async {
    if (!_initialized) return;
    await FirebaseCrashlytics.instance.setUserIdentifier(userId);
  }

  /// Add a breadcrumb log line.  Queues if Crashlytics is not yet initialised.
  static void log(String message) {
    if (!_initialized) {
      _pendingLogs.add(message);
      return;
    }
    FirebaseCrashlytics.instance.log(message);
  }

  /// [DEBUG ONLY] Force a crash to verify the Crashlytics pipeline end-to-end.
  static void triggerTestCrash() {
    assert(kDebugMode, 'triggerTestCrash must only be called in debug builds');
    FirebaseCrashlytics.instance.crash();
  }
}
