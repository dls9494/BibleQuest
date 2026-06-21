import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as rp;
import 'package:provider/provider.dart' as provider_pkg;
import 'package:go_router/go_router.dart';
import '../providers/user_data_provider.dart';
import '../services/firebase_service.dart';
import '../services/bible_service.dart';
import '../services/icon_assets.dart';
import 'quiz_tab.dart';
import 'bible_screen.dart';
import 'challenges_screen.dart';
import 'reading_plan_screen.dart';
import 'memory_game_screen.dart';
import 'custom_quiz_creator.dart';
import 'leaderboard_screen.dart';
import 'prayer_wall_screen.dart';
import 'social_feed_screen.dart';
import 'wisdom_tree_screen.dart';

import '../widgets/miracle_box_dialog.dart';
import '../widgets/app_drawer.dart';
import '../widgets/gradient_background.dart';
import '../features/user_data/providers/user_data_providers.dart';
import '../widgets/daily_verse_card.dart';
import '../theme/text_styles.dart';
import '../constants/theme.dart';

class MainScreen extends rp.ConsumerStatefulWidget {
  static final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  const MainScreen({super.key});

  @override
  rp.ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends rp.ConsumerState<MainScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
    BibleService.getBooks();
  }

  void _checkAuth() async {
    final uid = await FirebaseService.getCurrentUserUid();
    if (uid == null && mounted) {
      Navigator.pushReplacementNamed(context, '/auth');
    }
  }

  bool _isMiracleBoxDialogOpen = false;

  void _showMiracleBoxDialog() {
    if (_isMiracleBoxDialogOpen) return;
    _isMiracleBoxDialogOpen = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const MiracleBoxDialog(),
    ).then((_) {
      _isMiracleBoxDialogOpen = false;
    });
  }

  Widget _buildAvatarImage(String url, double size) {
    if (url.startsWith('data:image') && url.contains('base64,')) {
      try {
        final base64Str = url.split('base64,')[1];
        final bytes = base64Decode(base64Str);
        return ClipOval(
          child: Image.memory(
            bytes,
            fit: BoxFit.cover,
            width: size,
            height: size,
            errorBuilder: (_, __, ___) => Icon(Icons.person, color: Colors.white, size: size * 0.6),
          ),
        );
      } catch (_) {}
    }
    if (url.startsWith('assets/')) {
      return ClipOval(
        child: Image.asset(
          url,
          fit: BoxFit.cover,
          width: size,
          height: size,
        ),
      );
    }
    return ClipOval(
      child: Image.network(
        url,
        fit: BoxFit.cover,
        width: size,
        height: size,
        errorBuilder: (_, __, ___) => Icon(Icons.person, color: Colors.white, size: size * 0.6),
      ),
    );
  }

  Widget _buildFlatIcon(String assetPath, IconData fallbackIcon, Color fallbackColor, {double size = 22}) {
    if (assetPath.isEmpty) {
      return Icon(fallbackIcon, size: size, color: fallbackColor);
    }
    return Image.asset(
      assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          fallbackIcon,
          size: size,
          color: fallbackColor,
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final pendingMiracleBox = provider_pkg.Provider.of<UserDataProvider>(context).pendingMiracleBox;
    final bibleBookId = provider_pkg.Provider.of<UserDataProvider>(context).bibleBookId;
    final bibleChapter = provider_pkg.Provider.of<UserDataProvider>(context).bibleChapter;
    final bibleVerse = provider_pkg.Provider.of<UserDataProvider>(context).bibleVerse;

    if (pendingMiracleBox) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showMiracleBoxDialog();
      });
    }

    // Deep-linking to Bible Screen if target book is set
    if (bibleBookId != null && bibleChapter != null) {
      final bookId = bibleBookId;
      final chapter = bibleChapter;
      final verse = bibleVerse;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          provider_pkg.Provider.of<UserDataProvider>(context, listen: false).clearBibleTarget();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BibleScreen(
                initialBook: bookId,
                initialChapter: chapter,
                initialVerse: verse,
              ),
            ),
          );
        }
      });
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? (isDark ? Colors.white : Color(0xFF3E2723));
    final photoURL = provider_pkg.Provider.of<UserDataProvider>(context).photoURL;

    return Scaffold(
      key: MainScreen.scaffoldKey,
      drawer: const AppDrawer(),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: textColor, size: 24),
          onPressed: () {
            MainScreen.scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: Text(
          "Bible Quest",
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            fontFamily: 'Outfit',
          ),
        ),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/profile');
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: photoURL != null && photoURL.isNotEmpty
                    ? Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white24,
                        ),
                        child: _buildAvatarImage(photoURL, 32),
                      )
                    : const CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.white24,
                        child: Icon(Icons.person, color: Colors.white, size: 20),
                      ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          const Positioned.fill(
            child: GradientBackground(child: SizedBox.shrink()),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: _buildMainMenu(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 24, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppTheme.gold,
              fontWeight: FontWeight.w600,
              fontSize: 13,
              letterSpacing: 2.0,
              fontFamily: 'Outfit',
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 1.5,
            width: 24,
            decoration: BoxDecoration(
              color: AppTheme.gold.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainMenu() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? (isDark ? Colors.white : Color(0xFF3E2723));

    // Icons Setup
    final otIcon = _buildFlatIcon(IconAssets.oldTestament, Icons.auto_stories, Colors.amber, size: 20);
    final ntIcon = _buildFlatIcon(IconAssets.newTestament, Icons.auto_stories, Colors.blue, size: 20);
    final quizIcon = _buildFlatIcon(IconAssets.quiz, Icons.quiz, Colors.green, size: 20);
    final challengeIcon = _buildFlatIcon(IconAssets.challenges, Icons.emoji_events, Colors.amber, size: 20);
    final planIcon = _buildFlatIcon(IconAssets.readingPlans, Icons.calendar_month, Colors.green, size: 20);
    final memoryIcon = _buildFlatIcon(IconAssets.scriptureMemory, Icons.psychology, Colors.orange, size: 20);
    final creatorIcon = _buildFlatIcon(IconAssets.quizCreator, Icons.create, Colors.purple, size: 20);
    final leaderboardIcon = _buildFlatIcon(IconAssets.leaderboard, Icons.leaderboard, Colors.blue, size: 16);
    final prayerWallIcon = _buildFlatIcon(IconAssets.prayerWall, Icons.volunteer_activism, Colors.teal, size: 16);
    final socialIcon = _buildFlatIcon(IconAssets.socialFeed, Icons.forum, Colors.deepOrange, size: 16);
    final wisdomIcon = _buildFlatIcon(IconAssets.wisdomTree, Icons.forest, Colors.amber, size: 16);
    final bookmarkIcon = _buildFlatIcon(IconAssets.bookmarks, Icons.bookmark, Colors.red, size: 16);
    final favoriteIcon = _buildFlatIcon(IconAssets.favorites, Icons.favorite, Colors.amber, size: 16);
    final notesIcon = _buildFlatIcon('', Icons.note_alt_rounded, Colors.orange, size: 16);
    final searchIcon = _buildFlatIcon('', Icons.search_rounded, Colors.cyan, size: 16);

    final readingProgress = ref.watch(readingProgressProvider);
    final lastRead = readingProgress.isNotEmpty ? readingProgress.first : null;
    Widget? continueReadingCard;

    if (lastRead != null) {
      final lastBookName = lastRead['book_name'] as String;
      final lastChapter = lastRead['chapter'] as int;
      final lastVersion = lastRead['version'] as String;
      final lastVerse = lastRead['verse'] as int? ?? 1;
      
      final bookMeta = BibleService.findBookByName(lastBookName);
      final displayBookNameEn = bookMeta?.nameEn ?? lastBookName;
      final displayName = '$displayBookNameEn $lastChapter:$lastVerse';

      DateTime? readAtDate;
      try {
        if (lastRead['read_at'] != null) {
          readAtDate = DateTime.parse(lastRead['read_at'] as String);
        }
      } catch (_) {}

      String relativeTime = '';
      if (readAtDate != null) {
        final diff = DateTime.now().difference(readAtDate);
        if (diff.inSeconds < 60) {
          relativeTime = 'Just now';
        } else if (diff.inMinutes < 60) {
          relativeTime = '${diff.inMinutes} minutes ago';
        } else if (diff.inHours < 24) {
          relativeTime = '${diff.inHours} hours ago';
        } else {
          relativeTime = '${diff.inDays} days ago';
        }
      }

      final cardColor = isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05);
      const accentColor = Color(0xFFFFD700);

      continueReadingCard = Padding(
        padding: const EdgeInsets.only(bottom: 14.0),
        child: Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08), width: 1.0),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    context.push('/bible/$lastVersion/$lastBookName/$lastChapter?verse=$lastVerse');
                  },
                  borderRadius: BorderRadius.circular(18),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 18.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Continue Reading',
                                style: AppTextStyles.bodyText.copyWith(
                                  color: accentColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  letterSpacing: 0.4,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                displayName.toUpperCase(),
                                style: AppTextStyles.screenTitle.copyWith(
                                  color: textColor,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 22,
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                relativeTime.isNotEmpty
                                    ? 'Last opened $relativeTime'
                                    : 'Last opened recently',
                                style: AppTextStyles.bodyText.copyWith(
                                  color: isDark ? Colors.white54 : Colors.black54,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: accentColor.withValues(alpha: 0.18), width: 1),
                            color: accentColor.withValues(alpha: 0.08),
                          ),
                          child: Text(
                            'Resume →',
                            style: AppTextStyles.bodyText.copyWith(
                              color: accentColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── READ SECTION ────────────────────────────────────────────────────
          _buildSectionHeader("📖 READ"),
          if (continueReadingCard != null) continueReadingCard,
          Row(
            children: [
              Expanded(
                child: GamifiedMenuCard(
                  title: "Old Testament",
                  subtitle: "39 Books",
                  iconWidget: otIcon,
                  gradientColors: const [Color(0xFFFFC107), Color(0xFFFF8F00)],
                  glowColor: const Color(0xFFFFC107),
                  onTap: () => context.push('/bible'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GamifiedMenuCard(
                  title: "New Testament",
                  subtitle: "27 Books",
                  iconWidget: ntIcon,
                  gradientColors: const [Color(0xFF448AFF), Color(0xFF2962FF)],
                  glowColor: const Color(0xFF448AFF),
                  onTap: () => context.push('/bible'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: GamifiedMenuCard(
                  title: "Search Scripture",
                  subtitle: "Keyword search",
                  iconWidget: searchIcon,
                  gradientColors: const [Color(0xFF00E5FF), Color(0xFF00838F)],
                  glowColor: const Color(0xFF00E5FF),
                  isRowLayout: true,
                  onTap: () => context.push('/search'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const DailyVerseCard(),

          // ── LEARN SECTION ───────────────────────────────────────────────────
          _buildSectionHeader("📚 LEARN"),
          Row(
            children: [
              Expanded(
                child: GamifiedMenuCard(
                  title: "Reading Plans",
                  subtitle: "Daily tracks",
                  iconWidget: planIcon,
                  gradientColors: const [Color(0xFF66BB6A), Color(0xFF43A047)],
                  glowColor: const Color(0xFF66BB6A),
                  isRowLayout: true,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReadingPlanScreen())),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GamifiedMenuCard(
                  title: "Scripture Memory",
                  subtitle: "Memorization games",
                  iconWidget: memoryIcon,
                  gradientColors: const [Color(0xFFFF9800), Color(0xFFF57C00)],
                  glowColor: const Color(0xFFFF9800),
                  isRowLayout: true,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MemoryGameScreen())),
                ),
              ),
            ],
          ),

          // ── PLAY SECTION ────────────────────────────────────────────────────
          _buildSectionHeader("🎮 PLAY"),
          Row(
            children: [
              Expanded(
                child: GamifiedMenuCard(
                  title: "Quiz Mode",
                  subtitle: "Levels 1–100",
                  iconWidget: quizIcon,
                  gradientColors: const [Color(0xFF00E676), Color(0xFF00C853)],
                  glowColor: const Color(0xFF00E676),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QuizTab())),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GamifiedMenuCard(
                  title: "Challenges",
                  subtitle: "Daily & Weekly",
                  iconWidget: challengeIcon,
                  gradientColors: const [Color(0xFFFFD700), Color(0xFFFFAB00)],
                  glowColor: const Color(0xFFFFD700),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChallengesScreen())),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: GamifiedMenuCard(
                  title: "Quiz Creator",
                  subtitle: "Make your own quiz",
                  iconWidget: creatorIcon,
                  gradientColors: const [Color(0xFFAB47BC), Color(0xFF7B1FA2)],
                  glowColor: const Color(0xFFAB47BC),
                  isRowLayout: true,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomQuizCreatorScreen())),
                ),
              ),
            ],
          ),

          // ── GROW SECTION ────────────────────────────────────────────────────
          _buildSectionHeader("🌱 GROW"),
          Row(
            children: [
              Expanded(
                child: GamifiedMenuCard(
                  title: "Bookmarks",
                  subtitle: "Saved verses",
                  iconWidget: bookmarkIcon,
                  gradientColors: const [Color(0xFFEF5350), Color(0xFFC62828)],
                  glowColor: const Color(0xFFEF5350),
                  isRowLayout: true,
                  onTap: () => context.push('/bookmarks'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GamifiedMenuCard(
                  title: "Highlights",
                  subtitle: "Color marked",
                  iconWidget: favoriteIcon,
                  gradientColors: const [Color(0xFFFFD700), Color(0xFFFFAB00)],
                  glowColor: const Color(0xFFFFD700),
                  isRowLayout: true,
                  onTap: () => context.push('/highlights'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: GamifiedMenuCard(
                  title: "Study Notes",
                  subtitle: "Personal reflections",
                  iconWidget: notesIcon,
                  gradientColors: const [Color(0xFFFF8A65), Color(0xFFD84315)],
                  glowColor: const Color(0xFFFF8A65),
                  isRowLayout: true,
                  onTap: () => context.push('/notes'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GamifiedMenuCard(
                  title: "Wisdom Tree",
                  subtitle: "Growth & badges",
                  iconWidget: wisdomIcon,
                  gradientColors: const [Color(0xFFFFCA28), Color(0xFFFF8F00)],
                  glowColor: const Color(0xFFFFCA28),
                  isRowLayout: true,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WisdomTreeScreen())),
                ),
              ),
            ],
          ),

          // ── COMMUNITY SECTION ───────────────────────────────────────────────
          _buildSectionHeader("👥 COMMUNITY"),
          Row(
            children: [
              Expanded(
                child: GamifiedMenuCard(
                  title: "Leaderboard",
                  subtitle: "See global ranks",
                  iconWidget: leaderboardIcon,
                  gradientColors: const [Color(0xFF42A5F5), Color(0xFF1E88E5)],
                  glowColor: const Color(0xFF42A5F5),
                  isRowLayout: true,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LeaderboardScreen())),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GamifiedMenuCard(
                  title: "Prayer Wall",
                  subtitle: "Intercede together",
                  iconWidget: prayerWallIcon,
                  gradientColors: const [Color(0xFF26A69A), Color(0xFF00897B)],
                  glowColor: const Color(0xFF26A69A),
                  isRowLayout: true,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrayerWallScreen())),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: GamifiedMenuCard(
                  title: "Social Feed",
                  subtitle: "Feed & achievements",
                  iconWidget: socialIcon,
                  gradientColors: const [Color(0xFFFF7043), Color(0xFFE64A19)],
                  glowColor: const Color(0xFFFF7043),
                  isRowLayout: true,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SocialFeedScreen())),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class GamifiedMenuCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget iconWidget;
  final List<Color> gradientColors;
  final Color glowColor;
  final VoidCallback onTap;
  final bool isRowLayout;
  final Widget? backgroundDecoration;

  const GamifiedMenuCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.iconWidget,
    required this.gradientColors,
    required this.glowColor,
    required this.onTap,
    this.isRowLayout = false,
    this.backgroundDecoration,
  });

  Widget _buildGlassCard(BuildContext context, {required Widget child, Color? borderColor}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: borderColor?.withValues(alpha: 0.1) ?? (isDark ? Colors.white10 : Colors.black12),
                width: 1.0,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? (isDark ? Colors.white : Color(0xFF3E2723));
    final subTextColor = Theme.of(context).textTheme.bodyMedium?.color ?? (isDark ? Colors.white70 : Color(0xFF5D4037));

    final double iconSize = isRowLayout ? 30.0 : 34.0;

    // Static circular glassmorphism container for flat PNG/fallback icons
    Widget iconContainer = Container(
      width: iconSize,
      height: iconSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.16),
            Colors.white.withValues(alpha: 0.06),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            offset: const Offset(0, 1.5),
            blurRadius: 4,
          ),
          BoxShadow(
            color: glowColor.withValues(alpha: 0.06),
            blurRadius: 8,
            spreadRadius: 0.4,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glint Highlight (top-left)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.25),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                  stops: const [0.0, 0.5],
                ),
              ),
            ),
          ),
          // Darkening Shadow (bottom-right)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.black.withValues(alpha: 0.0),
                    Colors.black.withValues(alpha: 0.1),
                  ],
                  stops: const [0.5, 1.0],
                ),
              ),
            ),
          ),
          iconWidget,
        ],
      ),
    );

    return GestureDetector(
      onTap: onTap,
      child: _buildGlassCard(
        context,
        borderColor: glowColor,
        child: Padding(
          padding: isRowLayout
              ? const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0)
              : const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          child: isRowLayout
              ? Row(
                  children: [
                    iconContainer,
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: AppTextStyles.cardTitle.copyWith(
                              color: textColor,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: AppTextStyles.bodyText.copyWith(
                              color: subTextColor,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: subTextColor, size: 20),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    iconContainer,
                    const SizedBox(height: 8),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.cardTitle.copyWith(
                        color: textColor,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyText.copyWith(
                          color: subTextColor,
                          fontSize: 11,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}

class TestamentBooksScreen extends StatelessWidget {
  final String testament; // 'old' or 'new'

  const TestamentBooksScreen({
    super.key,
    required this.testament,
  });

  @override
  Widget build(BuildContext context) {
    final testamentType = testament == 'old' ? 'OT' : 'NT';
    final title = testament == 'old' ? 'Old Testament' : 'New Testament';
    final books = BibleService.getBooks().where((b) => b.testament == testamentType).toList();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? (isDark ? Colors.white : Color(0xFF3E2723));

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          title,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontFamily: 'Outfit',
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          const Positioned.fill(
            child: GradientBackground(child: SizedBox.shrink()),
          ),
          SafeArea(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: books.length,
              itemExtent: 56,
              itemBuilder: (context, index) {
                final book = books[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? Colors.white10 : Colors.black12,
                        width: 1,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () async {
                          final result = await Navigator.push<Map<String, dynamic>>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChapterGridScreen(book: book),
                            ),
                          );
                          if (result != null && context.mounted) {
                            final int chapter = result['chapter'] as int;
                            final int verse = result['verse'] as int;

                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BibleScreen(
                                  initialBook: book.id,
                                  initialChapter: chapter,
                                  initialVerse: verse,
                                ),
                              ),
                            );
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      book.nameEn,
                                      style: TextStyle(
                                        color: textColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        fontFamily: 'Outfit',
                                      ),
                                    ),
                                    Text(
                                      book.nameTe,
                                      style: const TextStyle(
                                        color: Color(0xFFD4A574),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 11,
                                        fontFamily: 'NotoSansTelugu',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "${book.chapters} Chapters",
                                    style: TextStyle(
                                      color: isDark ? Colors.white70 : Colors.black54,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Outfit',
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    color: isDark ? Colors.white54 : Colors.black38,
                                    size: 18,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ChapterGridScreen extends StatelessWidget {
  final BibleBook book;

  const ChapterGridScreen({
    super.key,
    required this.book,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? (isDark ? Colors.white : Color(0xFF3E2723));

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              book.nameEn,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontFamily: 'Outfit',
                fontSize: 18,
              ),
            ),
            Text(
              book.nameTe,
              style: const TextStyle(
                color: Color(0xFFD4A574),
                fontWeight: FontWeight.w600,
                fontFamily: 'NotoSansTelugu',
                fontSize: 12,
              ),
            ),
          ],
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          const Positioned.fill(
            child: GradientBackground(child: SizedBox.shrink()),
          ),
          SafeArea(
            child: GridView.count(
              crossAxisCount: 5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              padding: const EdgeInsets.all(24),
              childAspectRatio: 1.0,
              children: List.generate(book.chapters, (index) {
                final chapterNumber = index + 1;
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? Colors.white10 : Colors.black12,
                            width: 1,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            onTap: () async {
                              final verseCount = BibleService.getVerseCount(book.id, chapterNumber);
                              final verse = await Navigator.push<int>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => VerseGridScreen(
                                    bookId: book.id,
                                    chapter: chapterNumber,
                                    verseCount: verseCount,
                                  ),
                                ),
                              );
                              if (verse != null && context.mounted) {
                                Navigator.pop(context, {
                                  'chapter': chapterNumber,
                                  'verse': verse,
                                });
                              }
                            },
                            child: Center(
                              child: Text(
                                "$chapterNumber",
                                style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  fontFamily: 'Outfit',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class VerseGridScreen extends StatelessWidget {
  final String bookId;
  final int chapter;
  final int verseCount;

  const VerseGridScreen({
    super.key,
    required this.bookId,
    required this.chapter,
    required this.verseCount,
  });

  @override
  Widget build(BuildContext context) {
    final book = BibleService.getBookById(bookId);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color ?? (isDark ? Colors.white : Color(0xFF3E2723));

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              book?.nameEn ?? '',
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontFamily: 'Outfit',
                fontSize: 18,
              ),
            ),
            Text(
              "${book?.nameTe ?? ''} $chapter",
              style: const TextStyle(
                color: Color(0xFFD4A574),
                fontWeight: FontWeight.w600,
                fontFamily: 'NotoSansTelugu',
                fontSize: 12,
              ),
            ),
          ],
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          const Positioned.fill(
            child: GradientBackground(child: SizedBox.shrink()),
          ),
          SafeArea(
            child: GridView.count(
              crossAxisCount: 6,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              padding: const EdgeInsets.all(24),
              childAspectRatio: 1.0,
              children: List.generate(verseCount, (index) {
                final verseNumber = index + 1;
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.04),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? Colors.white10 : Colors.black12,
                            width: 1,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            onTap: () => Navigator.pop(context, verseNumber),
                            child: Center(
                              child: Text(
                                "$verseNumber",
                                style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  fontFamily: 'Outfit',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
