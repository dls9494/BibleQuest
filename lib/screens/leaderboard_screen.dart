import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_data_provider.dart';
import '../services/firebase_service.dart';
import '../models/profile_title.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _displayName = "Player";
  int _weeklyRank = -1;
  int _monthlyRank = -1;
  int _allTimeRank = -1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserInfo();
  }

  void _loadUserInfo() async {
    final name = await FirebaseService.getCurrentUserDisplayName() ?? "Guest Player";
    final uid = await FirebaseService.getCurrentUserUid() ?? "mock_user";
    final rank = await FirebaseService.getWeeklyRank(uid);
    final mRank = await FirebaseService.getMonthlyRank(uid);
    final aRank = await FirebaseService.getAllTimeRank(uid);
    if (mounted) {
      setState(() {
        _displayName = name;
        _weeklyRank = rank;
        _monthlyRank = mRank;
        _allTimeRank = aRank;
      });
      final provider = Provider.of<UserDataProvider>(context, listen: false);
      provider.updateWeeklyRank(rank);
      provider.updateMonthlyRank(mRank);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _refreshLeaderboard() {
    setState(() {}); // Triggers StreamBuilder reload
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Leaderboard updated!', style: TextStyle(fontFamily: 'Outfit')),
        duration: Duration(seconds: 1),
        backgroundColor: Color(0xFF0284C7),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserDataProvider>();
    final quizHighScores = userProvider.quizHighScores;
    final quizPercentages = userProvider.quizPercentages;

    final totalQuizzesCompleted = quizHighScores.length;
    final averageScore = quizPercentages.isEmpty
        ? 0
        : (quizPercentages.values.reduce((a, b) => a + b) / quizPercentages.length).round();
    final bestScore = quizHighScores.isEmpty
        ? 0
        : quizHighScores.values.reduce((a, b) => a > b ? a : b);
    final totalXp = userProvider.totalXp;
    final streakDays = userProvider.streakDays;
    
    final unlocked = userProvider.unlockedLevels;
    final currentLevel = unlocked.isEmpty ? 1 : unlocked.reduce((a, b) => a > b ? a : b);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF3E2723);

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? const [
                        Color(0xFF1A1A2E),
                        Color(0xFF0F3460),
                      ]
                    : const [
                        Color(0xFFFDF6EC),
                        Color(0xFFF3E7D8),
                      ],
              ),
            ),
          ),
          // Luminous background elements
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: Opacity(
                opacity: 0.1,
                child: Container(
                  width: 500,
                  height: 500,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF38BDF8) : const Color(0xFFD4A574).withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? const Color(0xFF38BDF8) : const Color(0xFFD4A574).withValues(alpha: 0.5),
                        blurRadius: 150,
                        spreadRadius: 100,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Custom App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 48), // Spacer to balance refresh button
                      Text(
                        "Leaderboards",
                        style: TextStyle(
                          color: textColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Outfit',
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.refresh, color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF6C4AB6)),
                        onPressed: _refreshLeaderboard,
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 8),
                        // My Stats section
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, bottom: 12.0),
                          child: Text(
                            "My Stats",
                            style: TextStyle(
                              color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF6C4AB6),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Outfit',
                            ),
                          ),
                        ),
                        _buildGlassCard(
                          isGold: true,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: 2,
                              childAspectRatio: 2.2,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              children: [
                                _buildStatItem("Total Quizzes", "$totalQuizzesCompleted"),
                                _buildStatItem("Avg Score", "$averageScore%"),
                                _buildStatItem("Best Score", "$bestScore"),
                                _buildStatItem("Total XP", "$totalXp"),
                                _buildStatItem("Level", "$currentLevel"),
                                _buildStatItem("Streak", "$streakDays Days"),
                                _buildStatItem("Weekly Rank", _weeklyRank > 0 ? "#$_weeklyRank" : "N/A"),
                                _buildStatItem("Monthly Rank", _monthlyRank > 0 ? "#$_monthlyRank" : "N/A"),
                                _buildStatItem("Flashcards", "${userProvider.flashcardsMastered}"),
                                _buildStatItem("Daily Quizzes", "${userProvider.totalDailyChallengesCompleted}"),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Tab Bar Container
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark ? Colors.white.withValues(alpha: 0.2) : const Color(0xFFD4A574).withValues(alpha: 0.4),
                            ),
                            boxShadow: isDark
                                ? null
                                : [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    )
                                  ],
                          ),
                          child: TabBar(
                            controller: _tabController,
                            indicator: BoxDecoration(
                              color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFF6C4AB6).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            indicatorSize: TabBarIndicatorSize.tab,
                            labelColor: isDark ? Colors.white : const Color(0xFF6C4AB6),
                            unselectedLabelColor: isDark ? const Color(0xFF958E9D) : const Color(0xFF8D7B9D),
                            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Outfit', fontSize: 13),
                            dividerColor: Colors.transparent,
                            tabs: const [
                              Tab(text: "Weekly"),
                              Tab(text: "Monthly"),
                              Tab(text: "All Time"),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Leaderboard list matching period tabs
                        SizedBox(
                          height: 400,
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _buildLeaderboardTab('weekly'),
                              _buildLeaderboardTab('monthly'),
                              _buildLeaderboardTab('all_time'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 80), // Spacer for bottom nav
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardTab(String period) {
    final userRank = period == 'weekly' 
        ? _weeklyRank 
        : (period == 'monthly' ? _monthlyRank : _allTimeRank);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subTextColor = isDark ? const Color(0xFFCBC3D4) : const Color(0xFF5D4037);

    return StreamBuilder<Map<String, dynamic>>(
      stream: FirebaseService.getLeaderboardWithCount(period),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF6C4AB6)));
        }

        final data = snapshot.data;
        final list = (data?['scores'] as List?)?.map((e) => Map<String, dynamic>.from(e)).toList() ?? [];
        final totalCount = data?['totalCount'] as int? ?? 0;

        if (list.isEmpty) {
          return Center(
            child: Text(
              'No scores recorded yet.',
              style: TextStyle(color: subTextColor, fontFamily: 'Outfit'),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4.0, right: 4.0, bottom: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Top ${list.length} of $totalCount participants",
                    style: TextStyle(
                      color: subTextColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Outfit',
                    ),
                  ),
                  if (userRank > list.length)
                    Text(
                      "Your rank: #$userRank of $totalCount",
                      style: TextStyle(
                        color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF6C4AB6),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Outfit',
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final entry = list[index];
                  final rank = index + 1;
                  final username = entry['username'] ?? 'Player';
                  final score = entry['score'] ?? 0;
                  final photoURL = entry['photoURL'] as String?;
                  final activeTitleId = entry['activeTitle'] ?? '';

                  final isCurrentUser = username == _displayName;

                  // Resolve active title name
                  String activeTitle = '';
                  if (activeTitleId.isNotEmpty) {
                    final matchingTitle = ProfileTitle.allTitles.firstWhere(
                      (t) => t.id == activeTitleId,
                      orElse: () => ProfileTitle(id: activeTitleId, name: activeTitleId.toUpperCase(), rarity: TitleRarity.common, description: ''),
                    );
                    activeTitle = matchingTitle.name;
                  }

                  // Ranks styling
                  Color rankColor;
                  IconData? rankIcon;
                  bool isTopThree = rank <= 3;
                  
                  if (rank == 1) {
                    rankColor = const Color(0xFFF7BC64); // Gold
                    rankIcon = Icons.workspace_premium;
                  } else if (rank == 2) {
                    rankColor = const Color(0xFFBBC5EB); // Silver
                    rankIcon = Icons.workspace_premium;
                  } else if (rank == 3) {
                    rankColor = const Color(0xFFCD7F32); // Bronze
                    rankIcon = Icons.workspace_premium;
                  } else {
                    rankColor = isDark ? const Color(0xFF958E9D) : const Color(0xFF8D7B9D);
                    rankIcon = null;
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: _buildRankCard(
                      rank: rank,
                      username: username,
                      score: score,
                      photoURL: photoURL,
                      rankColor: rankColor,
                      rankIcon: rankIcon,
                      isTopThree: isTopThree,
                      isCurrentUser: isCurrentUser,
                      activeTitle: activeTitle,
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRankCard({
    required int rank,
    required String username,
    required int score,
    required String? photoURL,
    required Color rankColor,
    required IconData? rankIcon,
    required bool isTopThree,
    required bool isCurrentUser,
    required String activeTitle,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF3E2723);
    final subTextColor = isDark ? const Color(0xFF958E9D) : const Color(0xFF8D7B9D);

    final displayRankColor = isDark
        ? rankColor
        : (rankColor == const Color(0xFFF7BC64)
            ? const Color(0xFFB57C1E) // Gold
            : (rankColor == const Color(0xFFBBC5EB)
                ? Colors.blueGrey.shade600 // Silver
                : (rankColor == const Color(0xFFCD7F32)
                    ? const Color(0xFF8D501D) // Bronze
                    : const Color(0xFF5D4037))));

    final avatarBgColor = isDark ? const Color(0xFF0284C7) : const Color(0xFF6C4AB6);

    // Determine card background and border
    BoxDecoration decoration;
    if (isCurrentUser) {
      // User style: blue/purple border, subtle shadow glow
      decoration = BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? const Color(0xFF0284C7).withValues(alpha: 0.6)
              : const Color(0xFF6C4AB6).withValues(alpha: 0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? const Color(0xFF0284C7).withValues(alpha: 0.2)
                : const Color(0xFF6C4AB6).withValues(alpha: 0.15),
            blurRadius: 10,
            spreadRadius: 1,
          )
        ],
      );
    } else if (rank == 1) {
      // Gold highlight
      decoration = BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? const Color(0xFFF7BC64).withValues(alpha: 0.4)
              : const Color(0xFFD4A574).withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                )
              ],
      );
    } else {
      // Normal / silver / bronze border styling
      Color borderColor = isTopThree
          ? rankColor.withValues(alpha: isDark ? 0.3 : 0.5)
          : (isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFD4A574).withValues(alpha: 0.2));
      decoration = BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.0),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                )
              ],
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: isDark ? 15 : 0, sigmaY: isDark ? 15 : 0),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: decoration,
          child: Row(
            children: [
              // Rank indicator
              SizedBox(
                width: 40,
                child: Center(
                  child: rankIcon != null
                      ? Icon(rankIcon, color: displayRankColor, size: 24)
                      : Text(
                          "$rank",
                          style: TextStyle(
                            color: displayRankColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            fontFamily: 'Outfit',
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 8),

              // Avatar Display
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: avatarBgColor,
                ),
                child: ClipOval(
                  child: photoURL != null && photoURL.isNotEmpty
                      ? _buildAvatarImage(photoURL, 32, username)
                      : Center(
                          child: Text(
                            username.isNotEmpty ? username[0].toUpperCase() : 'P',
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'Outfit', fontWeight: FontWeight.bold),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),

              // Username & You subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username + (activeTitle.isNotEmpty ? " • $activeTitle" : ""),
                      style: TextStyle(
                        color: isCurrentUser
                            ? (isDark ? const Color(0xFF38BDF8) : const Color(0xFF6C4AB6))
                            : textColor,
                        fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.w600,
                        fontSize: 15,
                        fontFamily: 'Outfit',
                      ),
                    ),
                    if (isCurrentUser)
                      Text(
                        "You",
                        style: TextStyle(color: subTextColor, fontSize: 10, fontFamily: 'Outfit'),
                      ),
                  ],
                ),
              ),

              // Score points
              Text(
                "$score",
                style: TextStyle(
                  color: displayRankColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  fontFamily: 'Outfit',
                ),
              ),
              const SizedBox(width: 4),
              Text(
                "pts",
                style: TextStyle(
                  color: displayRankColor.withValues(alpha: 0.7),
                  fontSize: 12,
                  fontFamily: 'Outfit',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: isDark ? const Color(0xFFCBC3D4) : const Color(0xFF5D4037),
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
            fontFamily: 'Outfit',
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: isDark ? const Color(0xFFF7BC64) : const Color(0xFFB57C1E),
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Outfit',
          ),
        ),
      ],
    );
  }

  Widget _buildGlassCard({required Widget child, bool isGold = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: isDark ? 20 : 0, sigmaY: isDark ? 20 : 0),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isGold
                  ? (isDark ? const Color(0xFFF7BC64).withValues(alpha: 0.4) : const Color(0xFFD4A574).withValues(alpha: 0.5))
                  : (isDark ? Colors.white.withValues(alpha: 0.2) : const Color(0xFFD4A574).withValues(alpha: 0.4)),
              width: 1.5,
            ),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildAvatarImage(String url, double size, String name) {
    if (url.startsWith('data:image') && url.contains('base64,')) {
      try {
        final base64Str = url.split('base64,')[1];
        final bytes = base64Decode(base64Str);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          width: size,
          height: size,
          errorBuilder: (context, error, stackTrace) => Center(
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'P',
              style: TextStyle(color: Colors.white, fontSize: size * 0.38, fontFamily: 'Outfit', fontWeight: FontWeight.bold),
            ),
          ),
        );
      } catch (_) {}
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      width: size,
      height: size,
      errorBuilder: (context, error, stackTrace) => Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'P',
          style: TextStyle(color: Colors.white, fontSize: size * 0.38, fontFamily: 'Outfit', fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
