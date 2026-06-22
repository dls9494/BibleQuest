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

    final textColor = Colors.white;
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

  Widget _buildSectionHeader(String title, {double topPadding = 24.0}) {
    final parts = title.split(' / ');
    final String teluguPart = parts[0];
    final String englishPart = parts.length > 1 ? parts[1] : '';

    return Padding(
      padding: EdgeInsets.only(left: 20, right: 20, top: topPadding, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: TextStyle(
                color: AppTheme.gold,
                fontWeight: FontWeight.w600,
                fontSize: 13,
                letterSpacing: 2.0,
              ),
              children: [
                TextSpan(
                  text: teluguPart,
                  style: const TextStyle(
                    fontFamily: 'Mandali',
                  ),
                ),
                if (englishPart.isNotEmpty) ...[
                  const TextSpan(
                    text: ' / ',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                    ),
                  ),
                  TextSpan(
                    text: englishPart,
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                    ),
                  ),
                ],
              ],
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

    // Icons Setup — Section 6: flat assets at correct sizes
    final otIcon = _buildFlatIcon(IconAssets.oldTestament, Icons.auto_stories, Colors.amber, size: 96);
    final ntIcon = _buildFlatIcon(IconAssets.newTestament, Icons.auto_stories, Colors.blue, size: 96);
    final searchIcon = _buildFlatIcon('assets/icons/flat/search.png', Icons.search_rounded, Colors.cyan, size: 68);
    final planIcon = _buildFlatIcon(IconAssets.readingPlans, Icons.calendar_month, Colors.green, size: 68);
    final memoryIcon = _buildFlatIcon(IconAssets.scriptureMemory, Icons.psychology, Colors.orange, size: 78);
    final quizIcon = _buildFlatIcon(IconAssets.quiz, Icons.quiz, Colors.green, size: 78);
    final challengeIcon = _buildFlatIcon(IconAssets.challenges, Icons.emoji_events, Colors.amber, size: 78);
    final creatorIcon = _buildFlatIcon(IconAssets.quizCreator, Icons.create, Colors.purple, size: 78);
    final bookmarkIcon = _buildFlatIcon(IconAssets.bookmarks, Icons.bookmark, Colors.red, size: 68);
    final favoriteIcon = _buildFlatIcon(IconAssets.favorites, Icons.favorite, Colors.amber, size: 78);
    final notesIcon = _buildFlatIcon('assets/icons/flat/notes.png', Icons.note_alt_rounded, Colors.orange, size: 68);
    final wisdomIcon = _buildFlatIcon(IconAssets.wisdomTree, Icons.forest, Colors.amber, size: 78);
    final leaderboardIcon = _buildFlatIcon(IconAssets.leaderboard, Icons.leaderboard, Colors.blue, size: 78);
    final prayerWallIcon = _buildFlatIcon(IconAssets.prayerWall, Icons.volunteer_activism, Colors.teal, size: 78);
    final socialIcon = _buildFlatIcon(IconAssets.socialFeed, Icons.forum, Colors.deepOrange, size: 78);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── READ SECTION ────────────────────────────────────────────────────
          _buildSectionHeader("📖 వాక్య అధ్యయనం / READ", topPadding: 12.0),
          const DailyVerseCard(),
          const SizedBox(height: 12),
          // OT/NT: allowIconOverflow — icon floats above card, text below
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: GamifiedMenuCard(
                  title: "పాత నిబంధన",
                  englishTitle: "Old Testament",
                  subtitle: "39 Books",
                  iconWidget: otIcon,
                  gradientColors: const [Color(0xFFFFC107), Color(0xFFFF8F00)],
                  glowColor: const Color(0xFFFFC107),
                  allowIconOverflow: false,
                  iconSize: 96,
                  onTap: () => context.push('/bible'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GamifiedMenuCard(
                  title: "కొత్త నిబంధన",
                  englishTitle: "New Testament",
                  subtitle: "27 Books",
                  iconWidget: ntIcon,
                  gradientColors: const [Color(0xFF448AFF), Color(0xFF2962FF)],
                  glowColor: const Color(0xFF448AFF),
                  allowIconOverflow: false,
                  iconSize: 96,
                  onTap: () => context.push('/bible'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: GamifiedMenuCard(
                  title: "వాక్య శోధన",
                  englishTitle: "Search Scripture",
                  subtitle: "Keyword search",
                  iconWidget: searchIcon,
                  gradientColors: const [Color(0xFF00E5FF), Color(0xFF00838F)],
                  glowColor: const Color(0xFF00E5FF),
                  allowIconOverflow: false,
                  iconSize: 68,
                  titleFontSize: 13,
                  subtitleFontSize: 9,
                  cardPadding: 4,
                  onTap: () => context.push('/search'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GamifiedMenuCard(
                  title: "పఠన ప్రణాళికలు",
                  englishTitle: "Reading Plans",
                  subtitle: "Daily tracks",
                  iconWidget: planIcon,
                  gradientColors: const [Color(0xFF66BB6A), Color(0xFF43A047)],
                  glowColor: const Color(0xFF66BB6A),
                  allowIconOverflow: false,
                  iconSize: 68,
                  titleFontSize: 13,
                  subtitleFontSize: 9,
                  cardPadding: 4,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReadingPlanScreen())),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GamifiedMenuCard(
                  title: "భద్రపరచిన వచనాలు",
                  englishTitle: "Bookmarks",
                  subtitle: "Saved verses",
                  iconWidget: bookmarkIcon,
                  gradientColors: const [Color(0xFFEF5350), Color(0xFFC62828)],
                  glowColor: const Color(0xFFEF5350),
                  allowIconOverflow: false,
                  iconSize: 68,
                  titleFontSize: 13,
                  subtitleFontSize: 9,
                  cardPadding: 4,
                  onTap: () => context.push('/bookmarks'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GamifiedMenuCard(
                  title: "అధ్యయన గమనికలు",
                  englishTitle: "Study Notes",
                  subtitle: "Personal reflections",
                  iconWidget: notesIcon,
                  gradientColors: const [Color(0xFFFF8A65), Color(0xFFD84315)],
                  glowColor: const Color(0xFFFF8A65),
                  allowIconOverflow: false,
                  iconSize: 68,
                  titleFontSize: 13,
                  subtitleFontSize: 9,
                  cardPadding: 4,
                  onTap: () => context.push('/notes'),
                ),
              ),
            ],
          ),

          // ── PLAY SECTION ────────────────────────────────────────────────────
          _buildSectionHeader("🎯 బైబిల్ సవాళ్లు / PLAY", topPadding: 12.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: GamifiedMenuCard(
                  title: "బైబిల్ ప్రశ్నోత్తరాలు",
                  englishTitle: "Quiz Mode",
                  subtitle: "Levels 1–100",
                  iconWidget: quizIcon,
                  gradientColors: const [Color(0xFF00E676), Color(0xFF00C853)],
                  glowColor: const Color(0xFF00E676),
                  allowIconOverflow: false,
                  iconSize: 78,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QuizTab())),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GamifiedMenuCard(
                  title: "సవాళ్లు",
                  englishTitle: "Challenges",
                  subtitle: "Daily & Weekly",
                  iconWidget: challengeIcon,
                  gradientColors: const [Color(0xFFFFD700), Color(0xFFFFAB00)],
                  glowColor: const Color(0xFFFFD700),
                  allowIconOverflow: false,
                  iconSize: 78,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChallengesScreen())),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: GamifiedMenuCard(
                  title: "వాక్య జ్ఞాపకం",
                  englishTitle: "Scripture Memory",
                  subtitle: "Memorization games",
                  iconWidget: memoryIcon,
                  gradientColors: const [Color(0xFFFF9800), Color(0xFFF57C00)],
                  glowColor: const Color(0xFFFF9800),
                  allowIconOverflow: false,
                  iconSize: 78,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MemoryGameScreen())),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GamifiedMenuCard(
                  title: "క్విజ్ సృష్టికర్త",
                  englishTitle: "Quiz Creator",
                  subtitle: "Make your own quiz",
                  iconWidget: creatorIcon,
                  gradientColors: const [Color(0xFFAB47BC), Color(0xFF7B1FA2)],
                  glowColor: const Color(0xFFAB47BC),
                  allowIconOverflow: false,
                  iconSize: 78,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomQuizCreatorScreen())),
                ),
              ),
            ],
          ),

          // ── GROW SECTION ────────────────────────────────────────────────────
          _buildSectionHeader("🌱 ఆత్మీయ వృద్ధి / GROW", topPadding: 12.0),
          Row(
            children: [
              Expanded(
                child: GamifiedMenuCard(
                  title: "హైలైట్స్",
                  englishTitle: "Highlights",
                  subtitle: "Color marked",
                  iconWidget: favoriteIcon,
                  gradientColors: const [Color(0xFFFFD700), Color(0xFFFFAB00)],
                  glowColor: const Color(0xFFFFD700),
                  onTap: () => context.push('/highlights'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GamifiedMenuCard(
                  title: "జ్ఞాన వృక్షం",
                  englishTitle: "Wisdom Tree",
                  subtitle: "Growth & badges",
                  iconWidget: wisdomIcon,
                  gradientColors: const [Color(0xFFFFCA28), Color(0xFFFF8F00)],
                  glowColor: const Color(0xFFFFCA28),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WisdomTreeScreen())),
                ),
              ),
            ],
          ),

          // ── COMMUNITY SECTION ───────────────────────────────────────────────
          _buildSectionHeader("🤝 సహవాసం / COMMUNITY", topPadding: 12.0),
          Row(
            children: [
              Expanded(
                child: GamifiedMenuCard(
                  title: "అగ్రస్థానాలు",
                  englishTitle: "Leaderboard",
                  subtitle: "See global ranks",
                  iconWidget: leaderboardIcon,
                  gradientColors: const [Color(0xFF42A5F5), Color(0xFF1E88E5)],
                  glowColor: const Color(0xFF42A5F5),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LeaderboardScreen())),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GamifiedMenuCard(
                  title: "కలిసి ప్రార్థిద్దాం",
                  englishTitle: "Prayer Wall",
                  subtitle: "Intercede together",
                  iconWidget: prayerWallIcon,
                  gradientColors: const [Color(0xFF26A69A), Color(0xFF00897B)],
                  glowColor: const Color(0xFF26A69A),
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
                  title: "విశ్వాసుల ఫీడ్",
                  englishTitle: "Social Feed",
                  subtitle: "Feed & achievements",
                  iconWidget: socialIcon,
                  gradientColors: const [Color(0xFFFF7043), Color(0xFFE64A19)],
                  glowColor: const Color(0xFFFF7043),
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
  final String? englishTitle;
  final String subtitle;
  final Widget iconWidget;
  final List<Color> gradientColors;
  final Color glowColor;
  final VoidCallback onTap;
  final bool isRowLayout;
  final Widget? backgroundDecoration;
  final bool allowIconOverflow;
  final bool showChevron;
  final double iconSize;
  final double? titleFontSize;
  final double? subtitleFontSize;
  final double? cardPadding;

  const GamifiedMenuCard({
    super.key,
    required this.title,
    this.englishTitle,
    required this.subtitle,
    required this.iconWidget,
    required this.gradientColors,
    required this.glowColor,
    required this.onTap,
    this.isRowLayout = false,
    this.backgroundDecoration,
    this.allowIconOverflow = false,
    this.showChevron = true,
    this.iconSize = 78.0,
    this.titleFontSize,
    this.subtitleFontSize,
    this.cardPadding,
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
    final textColor = Colors.white;
    final subTextColor = Colors.white70;

    // ── Section 7: allowIconOverflow layout ──────────────────────────────────
    // Half of the icon floats above the glass card top edge.
    // A Padding(top: halfIcon) reserves that space in the parent Row so the
    // overflowing icon is never clipped.
    if (allowIconOverflow && !isRowLayout) {
      final double halfIcon = iconSize / 2;
      return GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.only(top: halfIcon),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              _buildGlassCard(
                context,
                borderColor: glowColor,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(cardPadding ?? 10.0, halfIcon + 8, cardPadding ?? 10.0, 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.cardTitle.copyWith(
                          color: textColor,
                          fontSize: titleFontSize ?? 22,
                          fontFamily: 'Mandali',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (englishTitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          englishTitle!,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyText.copyWith(
                            color: subTextColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (subtitle.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyText.copyWith(
                            color: subTextColor,
                            fontSize: subtitleFontSize ?? 11,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Positioned(
                top: -halfIcon,
                left: 0,
                right: 0,
                child: Center(child: iconWidget),
              ),
            ],
          ),
        ),
      );
    }

    final double verticalPadding;
    final double spacingHeight;
    if (cardPadding != null) {
      double totalReserved = 72.0 - iconSize;
      if (englishTitle != null) {
        totalReserved -= 11.0;
      }
      spacingHeight = (totalReserved / 3).clamp(2.0, 8.0);
      verticalPadding = ((totalReserved - spacingHeight) / 2).clamp(0.0, 8.0);
    } else {
      verticalPadding = 8.0;
      spacingHeight = 8.0;
    }

    // ── Standard card (row or column) ────────────────────────────────────────
    return GestureDetector(
      onTap: onTap,
      child: _buildGlassCard(
        context,
        borderColor: glowColor,
        child: Padding(
          padding: isRowLayout
              ? const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0)
              : EdgeInsets.symmetric(
                  vertical: verticalPadding,
                  horizontal: cardPadding ?? 10.0,
                ),
          child: isRowLayout
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    iconWidget,
                    const SizedBox(width: 12),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: AppTextStyles.cardTitle.copyWith(
                              color: textColor,
                              fontSize: titleFontSize ?? 20,
                              fontFamily: 'Mandali',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (englishTitle != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              englishTitle!,
                              style: AppTextStyles.bodyText.copyWith(
                                color: subTextColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          if (subtitle.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              style: AppTextStyles.bodyText.copyWith(
                                color: subTextColor,
                                fontSize: subtitleFontSize ?? 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (showChevron) ...[
                      const SizedBox(width: 8),
                      Icon(Icons.chevron_right_rounded, color: subTextColor, size: 20),
                    ],
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    iconWidget,
                    SizedBox(height: spacingHeight),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.cardTitle.copyWith(
                        color: textColor,
                        fontSize: titleFontSize ?? 22,
                        fontFamily: 'Mandali',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (englishTitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        englishTitle!,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyText.copyWith(
                          color: subTextColor,
                          fontSize: titleFontSize ?? 15,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyText.copyWith(
                          color: subTextColor,
                          fontSize: subtitleFontSize ?? 11,
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
    final textColor = Colors.white;

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
                                        fontSize: 12,
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
    final textColor = Colors.white;

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
    final textColor = Colors.white;

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
