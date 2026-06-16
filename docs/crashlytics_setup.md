# Firebase Crashlytics — Setup & Usage

## Architecture: Zero-Loss Error Capture

```
main() starts
     │
     ▼
WidgetsFlutterBinding.ensureInitialized()
     │
     ▼
FlutterError.onError  ──► CrashlyticsService.recordFlutterError()
PlatformDispatcher.onError ──► CrashlyticsService.recordNonFatal()
     │                              │
     │                         _initialized == false?
     │                              │ YES → push to _pendingErrors / _pendingLogs
     │
     ▼
NotificationService.init() ...
AudioSession.init() ...
Firebase.initializeApp()        ← crashes here ARE queued & flushed
     │
     ▼
CrashlyticsService.init()       ← sets _initialized = true, flushes queue
     │
     ▼
FirebaseService / SQLite / etc.
     │
     ▼
runApp(...)
```

No crash is ever silently dropped — the queue catches every error that arrives
before Firebase is ready.

---

## Files Changed

| File | Change |
|---|---|
| `pubspec.yaml` | `firebase_crashlytics: ^5.2.3` |
| `android/build.gradle.kts` | `google-services 4.4.2` + `firebase-crashlytics 3.0.4` plugin declarations |
| `android/app/build.gradle.kts` | Applied both plugins to the app module |
| `lib/services/crashlytics_service.dart` | **Full rewrite** — buffered queue, `_initialized` flag, `recordNonFatal`, `recordFlutterError`, `log` all safe pre-init |
| `lib/main.dart` | Error handlers registered **immediately** after `WidgetsFlutterBinding.ensureInitialized()`, before Firebase |
| `lib/screens/settings_screen.dart` | Debug-only "Force Crash" red button (hidden in release via `kDebugMode`) |

---

## CrashlyticsService API

```dart
// Safe to call AT ANY TIME (even before Firebase.initializeApp):

// Non-fatal exception — use from catch blocks
await CrashlyticsService.recordNonFatal(e, stack, reason: 'Bible load failed');

// Flutter framework error — used internally by FlutterError.onError hook
await CrashlyticsService.recordFlutterError(details);

// Breadcrumb log
CrashlyticsService.log('User opened Genesis 1');

// These are only meaningful AFTER init():
await CrashlyticsService.setCustomKey('bible_version', 'telugu_ov');
await CrashlyticsService.setUserId(user.uid);

// Force a crash — DEBUG ONLY
CrashlyticsService.triggerTestCrash();
```

---

## main() Order (Critical)

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Register handlers FIRST — queues errors if Firebase isn't ready yet
  FlutterError.onError = (details) => CrashlyticsService.recordFlutterError(details);
  PlatformDispatcher.instance.onError = (error, stack) {
    CrashlyticsService.recordNonFatal(error, stack, fatal: true);
    return true;
  };

  // 2. Everything else (crashes here ARE captured by the queue above)
  await Firebase.initializeApp(...);

  // 3. init() sets _initialized = true and FLUSHES queued errors
  await CrashlyticsService.init();

  runApp(...);
}
```

---

## Verifying the Pipeline

### Option A — Debug button (easiest)
1. Run in debug mode on a device.
2. Open **Settings → Force Crash (Debug Only)** (red button at bottom).
3. The app crashes immediately.
4. **Re-launch** — Crashlytics uploads on next start.
5. Check [Firebase Console → Crashlytics](https://console.firebase.google.com/project/biblequiz-english-telugu/crashlytics) within ~5 min.

### Option B — Test a startup crash
Temporarily add `throw Exception("Startup crash test");` right after
`WidgetsFlutterBinding.ensureInitialized()` in `main()`.
The exception will be caught by `PlatformDispatcher.instance.onError`, queued,
and flushed to Crashlytics on the next successful launch.

---

## Release Build Behaviour

| Behaviour | Debug | Profile | Release |
|---|---|---|---|
| Collection enabled | ❌ (disabled by default) | ✅ | ✅ |
| Error queue active | ✅ | ✅ | ✅ |
| "Force Crash" button | ✅ (visible) | ❌ (compiled out) | ❌ (compiled out) |
| NDK native crash reporting | ✅ (via Gradle plugin) | ✅ | ✅ |

> To enable collection in debug builds too: remove the `!kDebugMode` condition
> inside `CrashlyticsService.init()`.

---

## Gradle Plugin Versions

| Plugin | Version |
|---|---|
| `com.google.gms.google-services` | 4.4.2 |
| `com.google.firebase.crashlytics` (Gradle) | 3.0.4 |
| `firebase_crashlytics` (Dart) | 5.2.3 |
