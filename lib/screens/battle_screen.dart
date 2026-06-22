import '../widgets/gradient_background.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/text_styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/user_data_provider.dart';
import '../services/firebase_service.dart';
import '../services/analytics_service.dart';
import '../models/quiz.dart';
import 'self_paced_screen.dart';

class BattleScreen extends StatefulWidget {
  const BattleScreen({super.key});

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _suggestedOpponents = [];
  bool _searching = false;
  bool _loadingSuggestions = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadSuggestions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadSuggestions() async {
    final userProvider = context.read<UserDataProvider>();
    setState(() {
      _loadingSuggestions = true;
    });
    try {
      final suggestions = await FirebaseService.getSuggestedOpponents(userProvider.userId!);
      setState(() {
        _suggestedOpponents = suggestions;
      });
    } catch (_) {}
    setState(() {
      _loadingSuggestions = false;
    });
  }

  void _searchUsers(String query) async {
    if (query.trim().isEmpty) return;
    setState(() {
      _searching = true;
    });
    try {
      final results = await FirebaseService.searchUsersByUsername(query);
      setState(() {
        _searchResults = results;
      });
    } catch (_) {}
    setState(() {
      _searching = false;
    });
  }

  void _challengeUser(UserDataProvider userProvider, String opponentId, String opponentName) async {
    try {
      await FirebaseService.createBattle(
        userProvider.userId!,
        userProvider.displayName,
        opponentId,
        opponentName,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Challenge sent to $opponentName! ⚔️')),
      );
      _searchController.clear();
      setState(() {
        _searchResults.clear();
      });
      _tabController.animateTo(1); // Go to pending/active tab
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send challenge: $e')),
        );
      }
    }
  }

  void _acceptBattle(UserDataProvider userProvider, String battleId, String challengerName) async {
    try {
      await FirebaseService.acceptBattle(battleId, userProvider.userId!, userProvider.displayName);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Challenge from $challengerName accepted!')),
      );
    } catch (_) {}
  }

  void _playBattle(UserDataProvider userProvider, Map<String, dynamic> battleData) async {
    final battleId = battleData['id'];
    // Analytics: battle started
    AnalyticsService.logBattleStarted();
    final questionsData = battleData['questions'] as List;
    final questions = questionsData.map((q) => Question.fromMap(Map<String, dynamic>.from(q))).toList();

    final opponentName = battleData['challengerId'] == userProvider.userId 
        ? (battleData['opponentName'] ?? "Opponent")
        : battleData['challengerName'];

    final quiz = Quiz(
      id: 'battle_quiz_$battleId',
      creatorId: 'system',
      titleKey: 'battle_quiz',
      titleEn: '1v1 Battle vs $opponentName',
      titleTe: '$opponentName తో 1v1 యుద్ధం',
      descriptionEn: '5 questions. Speed and accuracy count! Beat your opponent!',
      descriptionTe: '5 ప్రశ్నలు. వేగం మరియు ఖచ్చితత్వం ముఖ్యం! మీ ప్రత్యర్థిని ఓడించండి!',
      difficulty: 'medium',
      topics: const ['1v1 Battle'],
      bibleVersion: 'BSI Telugu',
      isPublic: true,
      level: 1,
      questionCount: 5,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelfPacedScreen(
          quiz: quiz,
          questions: questions,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild only when userId changes (e.g. login/logout), not on every provider update
    context.select<UserDataProvider, String?>((p) => p.userId);
    // Use read for passing provider to action methods (no reactive dependency)
    final userProvider = context.read<UserDataProvider>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "⚔️ 1v1 Battle Mode",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Outfit',
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: TabControllerTabBar(
          tabController: _tabController,
          tabs: const [
            Tab(text: "New Challenge"),
            Tab(text: "My Battles"),
            Tab(text: "Results"),
          ],
        ),
        flexibleSpace: const Positioned.fill(child: GradientBackground(child: SizedBox.shrink())),
      ),
      body: Stack(
        children: [
          const Positioned.fill(child: GradientBackground(child: SizedBox.shrink())),
          
          SafeArea(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildNewChallengeTab(userProvider),
                _buildMyBattlesTab(userProvider),
                _buildResultsTab(userProvider),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewChallengeTab(UserDataProvider userProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Find an Opponent",
            style: AppTextStyles.sectionHeader.copyWith(color: Colors.white, fontFamily: 'Outfit'),
          ),
          const SizedBox(height: 12),
          
          // Search Box
          TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white, fontFamily: 'Outfit'),
            decoration: InputDecoration(
              hintText: "Enter username to challenge...",
              hintStyle: const TextStyle(color: Colors.white30, fontFamily: 'Outfit'),
              prefixIcon: const Icon(Icons.search, color: Colors.white30),
              suffixIcon: IconButton(
                icon: const Icon(Icons.arrow_forward, color: Colors.amber),
                onPressed: () => _searchUsers(_searchController.text),
              ),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.05),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.white10),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.amber),
              ),
            ),
            onSubmitted: _searchUsers,
          ),
          const SizedBox(height: 20),
          
          // Search Results
          if (_searching)
            const Center(child: CircularProgressIndicator(color: Colors.amber))
          else if (_searchResults.isNotEmpty) ...[
            const Text("Search Results", style: TextStyle(color: Colors.amber, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final user = _searchResults[index];
                final uid = user['userId'] ?? '';
                final name = user['displayName'] ?? user['username'] ?? 'Player';
                if (uid == userProvider.userId) return const SizedBox.shrink();
                
                return _buildPlayerListItem(userProvider, uid, name);
              },
            ),
            const SizedBox(height: 20),
          ],
          
          // Suggested Opponents
          const Text(
            "Suggested Players",
            style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
          ),
          const SizedBox(height: 8),
          if (_loadingSuggestions)
            const Center(child: CircularProgressIndicator(color: Colors.white30))
          else if (_suggestedOpponents.isEmpty)
            const Text("No active players found.", style: TextStyle(color: Colors.white30, fontSize: 13, fontFamily: 'Outfit'))
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _suggestedOpponents.length,
              itemBuilder: (context, index) {
                final user = _suggestedOpponents[index];
                final uid = user['userId'] ?? '';
                final name = user['displayName'] ?? user['username'] ?? 'Player';
                if (uid == userProvider.userId) return const SizedBox.shrink();
                
                return _buildPlayerListItem(userProvider, uid, name);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildPlayerListItem(UserDataProvider userProvider, String uid, String name) {
    return Card(
      color: Colors.white.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
        trailing: ElevatedButton(
          onPressed: () => _challengeUser(userProvider, uid, name),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text("CHALLENGE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      ),
    );
  }

  Widget _buildMyBattlesTab(UserDataProvider userProvider) {
    // Listen to active battles
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('battles')
          .where('status', whereIn: ['waiting', 'accepted', 'in_progress'])
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No active battles.", style: TextStyle(color: Colors.white30, fontFamily: 'Outfit')));
        }
        
        final battles = snapshot.data!.docs
            .map((d) => d.data() as Map<String, dynamic>)
            .where((b) => b['challengerId'] == userProvider.userId || b['opponentId'] == userProvider.userId)
            .toList();

        if (battles.isEmpty) {
          return const Center(child: Text("No active battles.", style: TextStyle(color: Colors.white30, fontFamily: 'Outfit')));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: battles.length,
          itemBuilder: (context, index) {
            final battle = battles[index];
            final challengerName = battle['challengerName'];
            final opponentName = battle['opponentName'] ?? "Waiting...";
            final status = battle['status'];
            
            final isChallenger = battle['challengerId'] == userProvider.userId;
            final isWaitingOpponent = !isChallenger && status == 'waiting';
            
            final hasPlayed = isChallenger 
                ? battle['challengerScore'] != null 
                : battle['opponentScore'] != null;

            return Card(
              color: Colors.white.withValues(alpha: 0.05),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "$challengerName vs $opponentName",
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            status.toUpperCase(),
                            style: const TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (isWaitingOpponent)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () => _acceptBattle(userProvider, battle['id'], challengerName),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                            child: const Text("ACCEPT"),
                          )
                        ],
                      )
                    else if (status == 'accepted' || status == 'in_progress')
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            hasPlayed ? "✅ Score submitted" : "⏳ Ready to play",
                            style: TextStyle(color: hasPlayed ? Colors.green : Colors.white60, fontSize: 13, fontFamily: 'Outfit'),
                          ),
                          if (!hasPlayed)
                            ElevatedButton(
                              onPressed: () => _playBattle(userProvider, battle),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
                              child: const Text("PLAY"),
                            ),
                        ],
                      )
                    else if (isChallenger && status == 'waiting')
                      const Text(
                        "Waiting for opponent to accept...",
                        style: TextStyle(color: Colors.white30, fontSize: 12, fontFamily: 'Outfit'),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildResultsTab(UserDataProvider userProvider) {
    // Listen to completed battles
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('battles')
          .where('status', isEqualTo: 'completed')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No completed battles.", style: TextStyle(color: Colors.white30, fontFamily: 'Outfit')));
        }
        
        final completedBattles = snapshot.data!.docs
            .map((d) => d.data() as Map<String, dynamic>)
            .where((b) => b['challengerId'] == userProvider.userId || b['opponentId'] == userProvider.userId)
            .toList();

        if (completedBattles.isEmpty) {
          return const Center(child: Text("No completed battles.", style: TextStyle(color: Colors.white30, fontFamily: 'Outfit')));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: completedBattles.length,
          itemBuilder: (context, index) {
            final battle = completedBattles[index];
            final challengerName = battle['challengerName'];
            final opponentName = battle['opponentName'] ?? "Opponent";
            final challengerScore = battle['challengerScore'] ?? 0;
            final opponentScore = battle['opponentScore'] ?? 0;
            
            final isChallenger = battle['challengerId'] == userProvider.userId;
            final myScore = isChallenger ? challengerScore : opponentScore;
            final opScore = isChallenger ? opponentScore : challengerScore;
            
            final won = myScore > opScore;
            final draw = myScore == opScore;
            
            Color resultColor = Colors.red;
            String resultText = "LOST";
            if (draw) {
              resultColor = Colors.grey;
              resultText = "DRAW";
            } else if (won) {
              resultColor = Colors.green;
              resultText = "WON";
            }

            // Award wins / claim reward
            WidgetsBinding.instance.addPostFrameCallback((_) {
              // We check battleId reward tracking in local provider
              userProvider.recordBattleResult(won);
              // Analytics: battle completed
              AnalyticsService.logBattleCompleted(won: won);
            });

            return Card(
              color: Colors.white.withValues(alpha: 0.05),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "$challengerName vs $opponentName",
                            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Your Score: $myScore | Opponent: $opScore",
                            style: const TextStyle(color: Colors.white60, fontSize: 13, fontFamily: 'Outfit'),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: resultColor.withValues(alpha: 0.2),
                        border: Border.all(color: resultColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        resultText,
                        style: TextStyle(color: resultColor, fontWeight: FontWeight.bold, fontSize: 12, fontFamily: 'Outfit'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class TabControllerTabBar extends StatelessWidget implements PreferredSizeWidget {
  final TabController tabController;
  final List<Widget> tabs;

  const TabControllerTabBar({
    super.key,
    required this.tabController,
    required this.tabs,
  });

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: tabController,
      indicatorColor: Colors.amber,
      labelColor: Colors.amber,
      unselectedLabelColor: Colors.white60,
      labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
      tabs: tabs,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(48);
}
