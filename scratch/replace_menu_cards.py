import os

def main():
    file_path = "/home/david/Music/Bible Quiz/lib/screens/main_screen.dart"
    
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()

    # We want to replace everything from "  Widget _buildBibleCards() {"
    # to the start of "class TestamentBooksScreen"
    start_marker = "  Widget _buildBibleCards() {"
    end_marker = "class TestamentBooksScreen"

    start_idx = content.find(start_marker)
    if start_idx == -1:
        print(f"Error: Could not find start marker '{start_marker}'")
        return

    end_idx = content.find(end_marker)
    if end_idx == -1:
        print(f"Error: Could not find end marker '{end_marker}'")
        return

    replacement = """  Widget _buildBibleCards() {
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

    final otIcon = SvgPicture.asset(LuxuryIconAssets.oldTestament, width: 44, height: 44);
    final ntIcon = SvgPicture.asset(LuxuryIconAssets.newTestament, width: 44, height: 44);

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
      Widget? backgroundDecoration,
    }) {
      return GamifiedMenuCard(
        title: title,
        subtitle: subtitle,
        iconWidget: iconWidget,
        gradientColors: gradientColors,
        glowColor: glowColor,
        onTap: onTap,
        backgroundDecoration: backgroundDecoration,
      );
    }

    final quizIcon = SvgPicture.asset(LuxuryIconAssets.quiz, width: 44, height: 44);
    final challengeIcon = SvgPicture.asset(LuxuryIconAssets.challenges, width: 44, height: 44);

    if (isNarrow) {
      return Column(
        children: [
          buildQuizChallengesCardWidget(
            title: "Quiz",
            subtitle: "Levels 1–100 • Test Your Knowledge",
            iconWidget: quizIcon,
            gradientColors: const [Color(0xFF00E676), Color(0xFF00C853)],
            glowColor: const Color(0xFF00E676),
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
    final planIcon = SvgPicture.asset(LuxuryIconAssets.readingPlans, width: 44, height: 44);
    final memoryIcon = SvgPicture.asset(LuxuryIconAssets.scriptureMemory, width: 44, height: 44);
    final creatorIcon = SvgPicture.asset(LuxuryIconAssets.quizCreator, width: 44, height: 44);

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
    final leaderboardIcon = SvgPicture.asset(LuxuryIconAssets.leaderboard, width: 44, height: 44);
    final prayerWallIcon = SvgPicture.asset(LuxuryIconAssets.prayerWall, width: 44, height: 44);
    final socialIcon = SvgPicture.asset(LuxuryIconAssets.socialFeed, width: 44, height: 44);
    final wisdomIcon = SvgPicture.asset(LuxuryIconAssets.wisdomTree, width: 44, height: 44);
    final bookmarkIcon = SvgPicture.asset(LuxuryIconAssets.bookmarks, width: 44, height: 44);
    final favoriteIcon = SvgPicture.asset(LuxuryIconAssets.favorites, width: 44, height: 44);

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

  @override
  State<GamifiedMenuCard> createState() => _GamifiedMenuCardState();
}

class _GamifiedMenuCardState extends State<GamifiedMenuCard> with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeOut),
    );
    _glowAnimation = Tween<double>(begin: 0.15, end: 0.35).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
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

    final Widget animatedIcon = AnimatedBuilder(
      animation: _pressController,
      builder: (context, child) {
        final glowVal = _glowAnimation.value;
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: 64,
            height: 64,
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
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  offset: const Offset(0, 4),
                  blurRadius: 8,
                ),
                BoxShadow(
                  color: widget.glowColor.withValues(alpha: glowVal),
                  blurRadius: 10 + (glowVal * 20),
                  spreadRadius: glowVal * 6,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
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
                widget.iconWidget,
              ],
            ),
          ),
        );
      },
    );

    return GestureDetector(
      onTapDown: (_) {
        _pressController.forward();
      },
      onTapUp: (_) {
        _pressController.reverse();
        widget.onTap();
      },
      onTapCancel: () {
        _pressController.reverse();
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
                    animatedIcon,
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
                    animatedIcon,
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

"""

    new_content = content[:start_idx] + replacement + content[end_idx:]

    with open(file_path, "w", encoding="utf-8") as f:
        f.write(new_content)
    print("Successfully replaced card code in main_screen.dart!")

if __name__ == "__main__":
    main()
