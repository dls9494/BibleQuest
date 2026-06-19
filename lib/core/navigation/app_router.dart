import 'package:go_router/go_router.dart';
import '../../main.dart';
import '../../screens/auth_screen.dart';
import '../../screens/main_screen.dart';
import '../../screens/bible_screen.dart';
import '../../screens/book_list_screen.dart';
import '../../screens/chapter_list_screen.dart';
import '../../screens/bookmarks_screen.dart';
import '../../screens/highlights_screen.dart';
import '../../screens/notes_screen.dart';
import '../../screens/search_screen.dart';
import '../../screens/quiz_creator_screen.dart';
import '../../screens/study_tools_screen.dart';
import '../../screens/reading_plan_screen.dart';
import '../../screens/custom_quiz_creator.dart';
import '../../screens/settings_screen.dart';
import '../../screens/profile_screen.dart';
import '../../screens/analytics_debug_screen.dart';
import '../../services/analytics_service.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  navigatorKey: navigatorKey,
  // Automatic screen tracking via FirebaseAnalyticsObserver
  observers: [AnalyticsService.observer],
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const AuthWatcher(),
    ),
    GoRoute(
      path: '/auth',
      builder: (context, state) => const AuthScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const MainScreen(),
    ),
    GoRoute(
      path: '/bible',
      builder: (context, state) => const BookListScreen(),
    ),
    GoRoute(
      path: '/bible/:version/:bookName',
      builder: (context, state) {
        final version = state.pathParameters['version']!;
        final bookName = state.pathParameters['bookName']!;
        return ChapterListScreen(version: version, bookName: bookName);
      },
    ),
    GoRoute(
      path: '/bible/:version/:bookName/:chapter',
      builder: (context, state) {
        final bookName = state.pathParameters['bookName']!;
        final chapter = int.tryParse(state.pathParameters['chapter']!) ?? 1;
        final verseStr = state.uri.queryParameters['verse'];
        final verse = verseStr != null ? int.tryParse(verseStr) : null;
        return BibleScreen(
          initialBook: bookName,
          initialChapter: chapter,
          initialVerse: verse,
        );
      },
    ),
    GoRoute(
      path: '/search',
      builder: (context, state) => const SearchScreen(),
    ),
    GoRoute(
      path: '/bookmarks',
      builder: (context, state) => const BookmarksScreen(),
    ),
    GoRoute(
      path: '/highlights',
      builder: (context, state) => const HighlightsScreen(),
    ),
    GoRoute(
      path: '/notes',
      builder: (context, state) => const NotesScreen(),
    ),
    GoRoute(
      path: '/create-quiz',
      builder: (context, state) => const QuizCreatorScreen(),
    ),
    GoRoute(
      path: '/study-tools',
      builder: (context, state) => const StudyToolsScreen(),
    ),
    GoRoute(
      path: '/reading-plan',
      builder: (context, state) => const ReadingPlanScreen(),
    ),
    GoRoute(
      path: '/custom-quiz-creator',
      builder: (context, state) => const CustomQuizCreatorScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/analytics-debug',
      builder: (context, state) => const AnalyticsDebugScreen(),
    ),
  ],
);
