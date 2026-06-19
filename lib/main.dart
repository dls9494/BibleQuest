import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider;
import 'core/database/app_database.dart';
import 'core/navigation/app_router.dart';
import 'package:firebase_core/firebase_core.dart' hide FirebaseService;
import 'package:firebase_auth/firebase_auth.dart';
import 'l10n/app_localizations.dart';
import 'providers/locale_provider.dart';
import 'providers/user_data_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/reading_plan_provider.dart';
import 'screens/auth_screen.dart';
import 'screens/main_screen.dart';
import 'services/firebase_service.dart';
import 'services/real_questions.dart';
import 'services/audio_service.dart';
import 'services/notification_service.dart';
import 'services/local_storage_service.dart';
import 'services/connectivity_service.dart';
import 'services/crashlytics_service.dart';
import 'widgets/gradient_background.dart';
import 'package:audio_session/audio_session.dart';
import 'package:audio_service/audio_service.dart' as as_pkg;

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Register error handlers IMMEDIATELY, before Firebase or anything else ──
  // CrashlyticsService queues errors internally until init() is called below.
  FlutterError.onError = (FlutterErrorDetails details) {
    CrashlyticsService.recordFlutterError(details);
  };
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    CrashlyticsService.recordNonFatal(error, stack, fatal: true);
    return true;
  };

  String? initError;
  try {
    await NotificationService.init();
    await NotificationService.requestPermissions();
    
    // Configure audio session
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());

    // Initialize local storage and connectivity monitoring
    await LocalStorageService.init();
    ConnectivityService.init();

    // Initialize background audio handler
    final handler = await as_pkg.AudioService.init(
      builder: () => AudioService(),
      config: const as_pkg.AudioServiceConfig(
        androidNotificationChannelId: 'com.biblequest.audio',
        androidNotificationChannelName: 'Bible Audio Playback',
        androidNotificationOngoing: true,
        androidNotificationIcon: 'drawable/ic_stat_bible',
      ),
    );
    AudioService.instance = handler;
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: 'AIzaSyByEA5roslXE3tIX3H0ll3hh9gpWD3ilrw',
            authDomain: 'biblequiz-english-telugu.firebaseapp.com',
            projectId: 'biblequiz-english-telugu',
            storageBucket: 'biblequiz-english-telugu.firebasestorage.app',
            messagingSenderId: '906009091818',
            appId: '1:906009091818:web:6d3671bf7b81b911d9c193',
          ),
        );
      }
    } on FirebaseException catch (e) {
      if (e.code != 'duplicate-app') {
        rethrow;
      }
    } catch (e) {
      if (!e.toString().contains('duplicate-app') && !e.toString().contains('already exists')) {
        rethrow;
      }
    }
    // Initialise Crashlytics (disabled in debug builds)
    await CrashlyticsService.init();
    await FirebaseService.initialize();
    await RealQuestionsService.initializeRealQuestions();
    // Copy all SQLite assets locally
    await AppDatabase.instance.copyAllDatabasesOnFirstLaunch();
  } catch (e) {
    initError = e.toString();
  }

  runApp(ProviderScope(child: BibleQuizApp(initializationError: initError)));
}

class InitializationErrorScreen extends StatelessWidget {
  final String error;
  const InitializationErrorScreen({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1A1A2E),
                  Color(0xFF0F3460),
                ],
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    padding: const EdgeInsets.all(32.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    constraints: const BoxConstraints(maxWidth: 450),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
                        const SizedBox(height: 24),
                        const Text(
                          "Firebase Connection Error",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Outfit',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Failed to initialize database connectivity. Please ensure you are connected to the internet and restart the application.\n\nError details:\n$error",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontFamily: 'Outfit',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthWatcher extends StatefulWidget {
  const AuthWatcher({super.key});

  @override
  State<AuthWatcher> createState() => _AuthWatcherState();
}

class _AuthWatcherState extends State<AuthWatcher> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App resumed — verify auth state is still valid
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // User is still logged in, restore session
        context.read<UserDataProvider>().restoreSession(user);
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF1A1A2E),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_stories, color: Color(0xFF38BDF8), size: 64),
                  SizedBox(height: 24),
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF38BDF8)),
                  ),
                ],
              ),
            ),
          );
        }
        if (snapshot.hasData && snapshot.data != null) {
          final user = snapshot.data!;
          if (user.providerData.any((p) => p.providerId == 'password') && !user.emailVerified) {
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              await FirebaseAuth.instance.signOut();
            });
            return const AuthScreen();
          }
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              context.read<UserDataProvider>().restoreSession(user);
            }
          });
          return const MainScreen();
        }
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            context.read<UserDataProvider>().setUserId(null);
          }
        });
        // Not authenticated — show auth screen
        return const AuthScreen();
      },
    );
  }
}

class BibleQuizApp extends StatelessWidget {
  final String? initializationError;
  const BibleQuizApp({super.key, this.initializationError});

  @override
  Widget build(BuildContext context) {
    if (initializationError != null) {
      return MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Telugu Bible Quiz',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        home: InitializationErrorScreen(error: initializationError!),
      );
    }
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => UserDataProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ReadingPlanProvider()),
      ],
      child: Consumer2<LocaleProvider, ThemeProvider>(
        builder: (context, localeProvider, themeProvider, _) {
          return MaterialApp.router(
            routerConfig: appRouter,
            title: 'Telugu Bible Quiz',
            debugShowCheckedModeBanner: false,
            locale: const Locale('en'),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en')],
            themeMode: themeProvider.themeMode,
            theme: _buildLightTheme(context),
            darkTheme: _buildDarkTheme(context),
            builder: (context, child) => GradientBackground(child: child!),
          );
        },
      ),
    );
  }

  ThemeData _buildLightTheme(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6C4AB6), // Deep purple
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.transparent,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Color(0xFFFDF6EC), // Parchment background
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF3E2723)), // Dark brown
        titleTextStyle: TextStyle(
          color: Color(0xFF3E2723), // Dark brown
          fontSize: themeProvider.scaledFontSize(20),
          fontWeight: FontWeight.bold,
          fontFamily: themeProvider.useSerifFonts ? 'Georgia' : 'Outfit',
        ),
      ),
      actionIconTheme: ActionIconThemeData(
        backButtonIconBuilder: (BuildContext context) => Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Text(
            '✝',
            style: TextStyle(
              color: Color(0xFF3E2723), // Dark brown
              fontSize: themeProvider.scaledFontSize(24),
              fontWeight: FontWeight.bold,
              fontFamily: themeProvider.useSerifFonts ? 'Georgia' : 'Outfit',
            ),
          ),
        ),
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(
          color: Color(0xFF3E2723),
          fontSize: themeProvider.scaledFontSize(16),
          fontFamily: themeProvider.useSerifFonts ? 'Georgia' : 'Outfit',
        ),
        bodyMedium: TextStyle(
          color: Color(0xFF5D4037),
          fontSize: themeProvider.scaledFontSize(14),
          height: 1.5,
          fontFamily: themeProvider.useSerifFonts ? 'Georgia' : 'Outfit',
        ),
        titleLarge: TextStyle(
          color: Color(0xFF3E2723),
          fontSize: themeProvider.scaledFontSize(20),
          fontWeight: FontWeight.bold,
          fontFamily: themeProvider.useSerifFonts ? 'Georgia' : 'Outfit',
        ),
      ),
    );
  }

  ThemeData _buildDarkTheme(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFE21B3C),
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.transparent,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: themeProvider.scaledFontSize(20),
          fontWeight: FontWeight.bold,
          fontFamily: themeProvider.useSerifFonts ? 'Georgia' : 'Outfit',
        ),
      ),
      actionIconTheme: ActionIconThemeData(
        backButtonIconBuilder: (BuildContext context) => Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Text(
            '✝',
            style: TextStyle(
              color: Colors.white,
              fontSize: themeProvider.scaledFontSize(24),
              fontWeight: FontWeight.bold,
              fontFamily: themeProvider.useSerifFonts ? 'Georgia' : 'Outfit',
            ),
          ),
        ),
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(
          color: Colors.white,
          fontSize: themeProvider.scaledFontSize(16),
          height: 1.7, // English line height 1.7 as per requirement
          fontFamily: themeProvider.useSerifFonts ? 'Georgia' : 'Outfit',
        ),
        bodyMedium: TextStyle(
          color: Color(0xFF5D4037),
          fontSize: themeProvider.scaledFontSize(14),
          height: 1.5,
          fontFamily: themeProvider.useSerifFonts ? 'Georgia' : 'Outfit',
        ),
        titleLarge: TextStyle(
          color: Colors.white,
          fontSize: themeProvider.scaledFontSize(20),
          fontWeight: FontWeight.bold,
          fontFamily: themeProvider.useSerifFonts ? 'Georgia' : 'Outfit',
        ),
      ),
    );
  }
}
