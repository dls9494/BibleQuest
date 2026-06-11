import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_data_provider.dart';
import '../services/firebase_service.dart';
import '../services/bible_service.dart';
import '../models/bible.dart';
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
import 'bookmarks_screen.dart';
import 'favorites_screen.dart';
import '../widgets/miracle_box_dialog.dart';
import '../widgets/app_drawer.dart';
import '../widgets/gradient_background.dart';
import '../services/icon_assets.dart';

class MainScreen extends StatefulWidget {
  static final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserDataProvider>();
    if (userProvider.pendingMiracleBox) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showMiracleBoxDialog();
      });
    }

    // Deep-linking to Bible Screen if target book is set
    if (userProvider.bibleBookId != null && userProvider.bibleChapter != null) {
      final bookId = userProvider.bibleBookId!;
      final chapter = userProvider.bibleChapter!;
      final verse = userProvider.bibleVerse;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && userProvider.bibleBookId != null) {
          userProvider.clearBibleTarget();
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
    final textColor = isDark ? Colors.white : const Color(0xFF3E2723);

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
          IconButton(
            icon: Icon(Icons.account_circle_outlined, color: textColor, size: 26),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          const Positioned.fill(
            child: GradientBackground(child: SizedBox.shrink()),
          ),
          SafeArea(
            child: _buildMainMenu(),
          ),
        ],
      ),
    );
  }

  Widget _buildMainMenu() {
    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
          _buildSectionHeader("📖 BIBLE"),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: SliverToBoxAdapter(
              child: _buildBibleCards(),
            ),
          ),
          _buildSectionHeader("🎯 QUIZ & CHALLENGES"),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: SliverToBoxAdapter(
              child: _buildQuizAndChallengesCards(),
            ),
          ),
          _buildSectionHeader("📚 LEARNING"),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: SliverToBoxAdapter(
              child: _buildLearningCards(),
            ),
          ),
          _buildSectionHeader("👥 COMMUNITY"),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: SliverToBoxAdapter(
              child: _buildCommunityCards(),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 16),
          ),
        ],
      );
  }

  Widget _buildSectionHeader(String title) {
    return SliverPadding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 4),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: 1.2,
                fontFamily: 'Outfit',
              ),
            ),
            const SizedBox(height: 6),
            Container(
              height: 2,
              width: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFD4A574),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBibleCards() {
    final width = MediaQuery.of(context).size.width;
    final isNarrow = width < 360;

    Widget buildTestamentCardWidget(String title, String subtitle, Widget iconWidget, List<Color> gradientColors, Color glowColor, String testamentType) {
      return GamifiedMenuCard(
        title: title,
        subtitle: subtitle,
        iconWidget: iconWidget,
        gradientColors: gradientColors,
        glowColor: glowColor,
        onTap: () => _showTestamentBookIndex(testamentType, title),
      );
    }

    final otIcon = Image.asset(IconAssets.oldTestament, width: 44, height: 44);
    final ntIcon = Image.asset(IconAssets.newTestament, width: 44, height: 44);

    if (isNarrow) {
      return Column(
        children: [
          buildTestamentCardWidget(
            "Old Testament",
            "39 Books • The Beginning",
            otIcon,
            const [Color(0xFFFFC107), Color(0xFFFF8F00)],
            const Color(0xFFFFC107),
            'OT',
          ),
          const SizedBox(height: 12),
          buildTestamentCardWidget(
            "New Testament",
            "27 Books • The Fulfillment",
            ntIcon,
            const [Color(0xFF448AFF), Color(0xFF2962FF)],
            const Color(0xFF448AFF),
            'NT',
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(
            child: buildTestamentCardWidget(
              "Old Testament",
              "39 Books • The Beginning",
              otIcon,
              const [Color(0xFFFFC107), Color(0xFFFF8F00)],
              const Color(0xFFFFC107),
              'OT',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: buildTestamentCardWidget(
              "New Testament",
              "27 Books • The Fulfillment",
              ntIcon,
              const [Color(0xFF448AFF), Color(0xFF2962FF)],
              const Color(0xFF448AFF),
              'NT',
            ),
          ),
        ],
      );
    }
  }

  void _showTestamentBookIndex(String testamentType, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TestamentBooksScreen(
          testamentType: testamentType,
          title: title,
        ),
      ),
    );
  }

  Widget _buildQuizAndChallengesCards() {
    final width = MediaQuery.of(context).size.width;
    final isNarrow = width < 360;

    Widget buildQuizChallengesCardWidget({
      required String title,
      required String subtitle,
      required Widget iconWidget,
      required List<Color> gradientColors,
      required Color glowColor,
      required VoidCallback onTap,
      bool pulse = false,
      Widget? backgroundDecoration,
    }) {
      return GamifiedMenuCard(
        title: title,
        subtitle: subtitle,
        iconWidget: iconWidget,
        gradientColors: gradientColors,
        glowColor: glowColor,
        onTap: onTap,
        pulse: pulse,
        backgroundDecoration: backgroundDecoration,
      );
    }

    final quizIcon = Image.asset(IconAssets.quiz, width: 44, height: 44);
    final challengeIcon = Image.asset(IconAssets.challenges, width: 44, height: 44);

    if (isNarrow) {
      return Column(
        children: [
          buildQuizChallengesCardWidget(
            title: "Quiz",
            subtitle: "Levels 1–100 • Test Your Knowledge",
            iconWidget: quizIcon,
            gradientColors: const [Color(0xFF00E676), Color(0xFF00C853)],
            glowColor: const Color(0xFF00E676),
            pulse: true,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QuizTab())),
          ),
          const SizedBox(height: 12),
          buildQuizChallengesCardWidget(
            title: "Challenges",
            subtitle: "Daily • Weekly • Monthly • Compete",
            iconWidget: challengeIcon,
            gradientColors: const [Color(0xFFFFD700), Color(0xFFFFAB00)],
            glowColor: const Color(0xFFFFD700),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChallengesScreen())),
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(
            child: buildQuizChallengesCardWidget(
              title: "Quiz",
              subtitle: "Levels 1–100 • Test Your Knowledge",
              iconWidget: quizIcon,
              gradientColors: const [Color(0xFF00E676), Color(0xFF00C853)],
              glowColor: const Color(0xFF00E676),
              pulse: true,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QuizTab())),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: buildQuizChallengesCardWidget(
              title: "Challenges",
              subtitle: "Daily • Weekly • Monthly • Compete",
              iconWidget: challengeIcon,
              gradientColors: const [Color(0xFFFFD700), Color(0xFFFFAB00)],
              glowColor: const Color(0xFFFFD700),
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChallengesScreen())),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildLearningCards() {
    final planIcon = Image.asset(IconAssets.readingPlans, width: 44, height: 44);
    final memoryIcon = Image.asset(IconAssets.scriptureMemory, width: 44, height: 44);
    final creatorIcon = Image.asset(IconAssets.quizCreator, width: 44, height: 44);

    return Row(
      children: [
        Expanded(
          child: GamifiedMenuCard(
            title: "Reading Plans",
            subtitle: "30 • 90 • 365 Day Plans",
            iconWidget: planIcon,
            gradientColors: const [Color(0xFF66BB6A), Color(0xFF43A047)],
            glowColor: const Color(0xFF66BB6A),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReadingPlanScreen())),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GamifiedMenuCard(
            title: "Scripture Memory",
            subtitle: "Memorize • Retain • Grow",
            iconWidget: memoryIcon,
            gradientColors: const [Color(0xFFFF9800), Color(0xFFF57C00)],
            glowColor: const Color(0xFFFF9800),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MemoryGameScreen())),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GamifiedMenuCard(
            title: "Quiz Creator",
            subtitle: "Create • Customize • Challenge",
            iconWidget: creatorIcon,
            gradientColors: const [Color(0xFFAB47BC), Color(0xFF7B1FA2)],
            glowColor: const Color(0xFFAB47BC),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomQuizCreatorScreen())),
          ),
        ),
      ],
    );
  }

  Widget _buildCommunityCards() {
    final leaderboardIcon = Image.asset(IconAssets.leaderboard, width: 44, height: 44);
    final prayerWallIcon = Image.asset(IconAssets.prayerWall, width: 44, height: 44);
    final socialIcon = Image.asset(IconAssets.socialFeed, width: 44, height: 44);
    final wisdomIcon = Image.asset(IconAssets.wisdomTree, width: 44, height: 44);
    final bookmarkIcon = Image.asset(IconAssets.bookmarks, width: 44, height: 44);
    final favoriteIcon = Image.asset(IconAssets.favorites, width: 44, height: 44);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: GamifiedMenuCard(
                title: "Leaderboard",
                subtitle: "Weekly • Monthly • All-Time • Climb",
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
                subtitle: "Share • Pray • Connect",
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
                subtitle: "Feed of Faith • Stay Connected",
                iconWidget: socialIcon,
                gradientColors: const [Color(0xFFFF7043), Color(0xFFE64A19)],
                glowColor: const Color(0xFFFF7043),
                isRowLayout: true,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SocialFeedScreen())),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GamifiedMenuCard(
                title: "Wisdom Tree",
                subtitle: "Growth & Achievements • Flourish",
                iconWidget: wisdomIcon,
                gradientColors: const [Color(0xFFFFCA28), Color(0xFFFF8F00)],
                glowColor: const Color(0xFFFFCA28),
                isRowLayout: true,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WisdomTreeScreen())),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: GamifiedMenuCard(
                title: "Bookmarks",
                subtitle: "Secured Notes • Your Archive",
                iconWidget: bookmarkIcon,
                gradientColors: const [Color(0xFFEF5350), Color(0xFFC62828)],
                glowColor: const Color(0xFFEF5350),
                isRowLayout: true,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BookmarksScreen())),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GamifiedMenuCard(
                title: "Favorites",
                subtitle: "Treasured Verses • Collect & Reflect",
                iconWidget: favoriteIcon,
                gradientColors: const [Color(0xFFFFD700), Color(0xFFFFAB00)],
                glowColor: const Color(0xFFFFD700),
                isRowLayout: true,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesScreen())),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class GamifiedMenuCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final Widget iconWidget;
  final List<Color> gradientColors;
  final Color glowColor;
  final VoidCallback onTap;
  final bool isRowLayout;
  final bool pulse;
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
    this.pulse = false,
    this.backgroundDecoration,
  });

  @override
  State<GamifiedMenuCard> createState() => _GamifiedMenuCardState();
}

class _GamifiedMenuCardState extends State<GamifiedMenuCard> with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _scaleAnimation;
  AnimationController? _pulseController;
  Animation<double>? _pulseAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeOut),
    );

    if (widget.pulse) {
      _pulseController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 1),
      )..repeat(reverse: true);
      _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
        CurvedAnimation(parent: _pulseController!, curve: Curves.easeInOut),
      );
    }
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _pulseController?.dispose();
    super.dispose();
  }

  void _handleTap() {
    _bounceController.forward().then((_) {
      if (mounted) {
        _bounceController.reverse();
      }
    });
    widget.onTap();
  }

  Widget _buildGlassCard({required Widget child, Color? borderColor}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: borderColor ?? (isDark ? Colors.white10 : Colors.black12),
                width: 1.2,
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
    final textColor = isDark ? Colors.white : const Color(0xFF3E2723);
    final subTextColor = isDark ? Colors.white70 : const Color(0xFF5D4037);

    // Build static 64dp circular glassmorphism container
    Widget iconContainer = AnimatedContainer(
      duration: const Duration(milliseconds: 80),
      width: 64,
      height: 64,
      transform: Matrix4.translationValues(0, _isPressed ? 2.0 : 0.0, 0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.12),
            Colors.white.withValues(alpha: 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1.2,
        ),
        boxShadow: _isPressed
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  offset: const Offset(0, 2),
                  blurRadius: 6,
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  offset: const Offset(0, 1),
                  blurRadius: 4,
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.075),
                  offset: const Offset(0, 0.5),
                  blurRadius: 2,
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: widget.glowColor.withValues(alpha: 0.15),
                  blurRadius: 8,
                  spreadRadius: 1,
                  offset: const Offset(0, 0),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  offset: const Offset(0, 6),
                  blurRadius: 12,
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  offset: const Offset(0, 3),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  offset: const Offset(0, 1),
                  blurRadius: 4,
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: widget.glowColor.withValues(alpha: 0.35),
                  blurRadius: 15,
                  spreadRadius: 2,
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
                    Colors.white.withValues(alpha: 0.3),
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
                    Colors.black.withValues(alpha: 0.15),
                  ],
                  stops: const [0.5, 1.0],
                ),
              ),
            ),
          ),
          widget.iconWidget,
        ],
      ),
    );

    // Apply animations
    if (_pulseAnimation != null) {
      iconContainer = ScaleTransition(
        scale: _pulseAnimation!,
        child: iconContainer,
      );
    }
    iconContainer = ScaleTransition(
      scale: _scaleAnimation,
      child: iconContainer,
    );

    // 3D Perspective tilt
    final tiltedIcon = Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateX(0.05)
        ..rotateY(0.05),
      alignment: Alignment.center,
      child: iconContainer,
    );

    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _isPressed = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          _isPressed = false;
        });
        _handleTap();
      },
      onTapCancel: () {
        setState(() {
          _isPressed = false;
        });
      },
      child: _buildGlassCard(
        borderColor: widget.glowColor.withValues(alpha: 0.3),
        child: Padding(
          padding: widget.isRowLayout
              ? const EdgeInsets.all(14.0)
              : const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: widget.isRowLayout
              ? Row(
                  children: [
                    tiltedIcon,
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.title,
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              fontFamily: 'Outfit',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.subtitle,
                            style: TextStyle(
                              color: subTextColor,
                              fontSize: 10,
                              fontFamily: 'Outfit',
                            ),
                            maxLines: 2,
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
                    tiltedIcon,
                    const SizedBox(height: 12),
                    Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        fontFamily: 'Outfit',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.subtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: subTextColor,
                        fontSize: 10,
                        fontFamily: 'Outfit',
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}



class TestamentBooksScreen extends StatelessWidget {
  final String testamentType; // 'OT' or 'NT'
  final String title;

  const TestamentBooksScreen({
    super.key,
    required this.testamentType,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final books = BibleService.getBooks().where((b) => b.testament == testamentType).toList();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF3E2723);

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
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: books.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final book = books[index];
                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
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
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          title: Text(
                            book.nameEn,
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              fontFamily: 'Outfit',
                            ),
                          ),
                          subtitle: Text(
                            book.nameTe,
                            style: const TextStyle(
                              color: Color(0xFFD4A574),
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              fontFamily: 'NotoSansTelugu',
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "${book.chapters} Chapters",
                                style: TextStyle(
                                  color: isDark ? Colors.white70 : Colors.black54,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Outfit',
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(Icons.chevron_right_rounded, color: isDark ? Colors.white54 : Colors.black38),
                            ],
                          ),
                          onTap: () async {
                            final chapter = await Navigator.push<int>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChapterGridScreen(book: book),
                              ),
                            );
                            if (chapter != null && context.mounted) {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BibleScreen(
                                    initialBook: book.id,
                                    initialChapter: chapter,
                                  ),
                                ),
                              );
                            }
                          },
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
    final textColor = isDark ? Colors.white : const Color(0xFF3E2723);

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
            child: GridView.builder(
              padding: const EdgeInsets.all(24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: book.chapters,
              itemBuilder: (context, index) {
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
                            onTap: () => Navigator.pop(context, chapterNumber),
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
              },
            ),
          ),
        ],
      ),
    );
  }
}
