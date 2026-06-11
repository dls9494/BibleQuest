import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/user_data_provider.dart';
import 'profile_screen.dart';
import 'leaderboard_screen.dart';

class SocialFeedScreen extends StatefulWidget {
  const SocialFeedScreen({super.key});

  @override
  State<SocialFeedScreen> createState() => _SocialFeedScreenState();
}

class _SocialFeedScreenState extends State<SocialFeedScreen> {
  final ScrollController _scrollController = ScrollController();
  List<DocumentSnapshot> _activities = [];
  bool _isLoading = false;
  bool _hasMore = true;
  final int _limit = 20;
  DocumentSnapshot? _lastDocument;
  List<String> _followingIds = [];
  bool _isLoadingFollowing = true;

  @override
  void initState() {
    super.initState();
    _loadFollowingAndActivities();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && _hasMore && _followingIds.isNotEmpty) {
        _loadMoreActivities();
      }
    }
  }

  Future<void> _loadFollowingAndActivities() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _isLoadingFollowing = true;
    });

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingFollowing = false;
        });
      }
      return;
    }

    try {
      // Get the following list as a single snapshot
      final followingSnapshot = await FirebaseFirestore.instance
          .collection('follows')
          .where('followerId', isEqualTo: uid)
          .get();

      _followingIds = followingSnapshot.docs
          .map((doc) => doc.data()['followingId'] as String)
          .toList();

      if (mounted) {
        setState(() {
          _isLoadingFollowing = false;
        });
      }

      if (_followingIds.isEmpty) {
        if (mounted) {
          setState(() {
            _activities = [];
            _isLoading = false;
            _hasMore = false;
          });
        }
        return;
      }

      // Load initial activities
      // Firestore whereIn supports up to 30 elements
      final queryFollowing = _followingIds.take(30).toList();
      final query = FirebaseFirestore.instance
          .collection('activities')
          .where('userId', whereIn: queryFollowing)
          .orderBy('timestamp', descending: true)
          .limit(_limit);

      final snapshot = await query.get();

      if (mounted) {
        setState(() {
          _activities = snapshot.docs;
          _isLoading = false;
          if (snapshot.docs.length < _limit) {
            _hasMore = false;
          } else {
            _lastDocument = snapshot.docs.last;
          }
        });
      }
    } catch (e) {
      // ignore: avoid_print
      print("Error loading social feed: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadMoreActivities() async {
    if (_isLoading || !_hasMore || _followingIds.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final queryFollowing = _followingIds.take(30).toList();
      var query = FirebaseFirestore.instance
          .collection('activities')
          .where('userId', whereIn: queryFollowing)
          .orderBy('timestamp', descending: true)
          .limit(_limit);

      if (_lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      final snapshot = await query.get();

      if (mounted) {
        setState(() {
          _activities.addAll(snapshot.docs);
          _isLoading = false;
          if (snapshot.docs.length < _limit) {
            _hasMore = false;
          } else {
            _lastDocument = snapshot.docs.last;
          }
        });
      }
    } catch (e) {
      // ignore: avoid_print
      print("Error loading more activities: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshFeed() async {
    await _loadFollowingAndActivities();
  }

  String _formatTimeAgo(dynamic timestamp) {
    if (timestamp == null) return "Just now";
    DateTime dateTime;
    if (timestamp is Timestamp) {
      dateTime = timestamp.toDate();
    } else if (timestamp is DateTime) {
      dateTime = timestamp;
    } else {
      return "";
    }

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return "Just now";
    } else if (difference.inHours < 1) {
      return "${difference.inMinutes}m ago";
    } else if (difference.inDays < 1) {
      return "${difference.inHours}h ago";
    } else if (difference.inDays < 7) {
      return "${difference.inDays}d ago";
    } else {
      return DateFormat('MMM d, yyyy').format(dateTime);
    }
  }

  Map<String, dynamic> _getActivityUiDetails(String type) {
    switch (type) {
      case 'quiz_completed':
        return {
          'icon': Icons.quiz,
          'color': const Color(0xFFA855F7), // Purple
          'title': 'Quiz Completed',
        };
      case 'achievement_unlocked':
        return {
          'icon': Icons.emoji_events,
          'color': const Color(0xFFEAB308), // Yellow/Gold
          'title': 'Achievement Unlocked',
        };
      case 'prayer_request':
        return {
          'icon': Icons.volunteer_activism,
          'color': const Color(0xFFF43F5E), // Rose
          'title': 'Prayer Request',
        };
      case 'level_up':
        return {
          'icon': Icons.trending_up,
          'color': const Color(0xFF3B82F6), // Blue
          'title': 'Level Up',
        };
      case 'streak_milestone':
        return {
          'icon': Icons.local_fire_department,
          'color': const Color(0xFFF97316), // Orange
          'title': 'Streak Milestone',
        };
      case 'battle_won':
        return {
          'icon': Icons.sports_esports,
          'color': const Color(0xFF06B6D4), // Cyan
          'title': 'Battle Victory',
        };
      case 'group_joined':
        return {
          'icon': Icons.group_add,
          'color': const Color(0xFF10B981), // Green
          'title': 'Joined Group',
        };
      default:
        return {
          'icon': Icons.notifications,
          'color': const Color(0xFF6B7280), // Gray
          'title': 'Activity',
        };
    }
  }

  Widget _buildActivityContent(String type, Map<String, dynamic> data) {
    final TextStyle boldStyle = const TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.white,
      fontFamily: 'Outfit',
    );
    final TextStyle normalStyle = const TextStyle(
      color: Colors.white70,
      fontFamily: 'Outfit',
    );

    switch (type) {
      case 'quiz_completed':
        final quizName = data['quizName'] ?? 'Quiz';
        final correct = data['correctAnswers'] ?? 0;
        final total = data['totalQuestions'] ?? 0;
        return RichText(
          text: TextSpan(
            style: normalStyle,
            children: [
              const TextSpan(text: "Completed "),
              TextSpan(text: quizName, style: boldStyle),
              const TextSpan(text: " with "),
              TextSpan(text: "$correct/$total", style: boldStyle),
              const TextSpan(text: " correct answers!"),
            ],
          ),
        );
      case 'achievement_unlocked':
        final achName = data['achievementName'] ?? 'Achievement';
        final desc = data['description'] ?? '';
        return RichText(
          text: TextSpan(
            style: normalStyle,
            children: [
              const TextSpan(text: "Unlocked "),
              TextSpan(text: achName, style: boldStyle),
              if (desc.isNotEmpty) TextSpan(text: " - $desc"),
            ],
          ),
        );
      case 'prayer_request':
        final text = data['requestText'] ?? '';
        return RichText(
          text: TextSpan(
            style: normalStyle,
            children: [
              const TextSpan(text: "Posted a prayer request:\n"),
              TextSpan(
                text: '"$text"',
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.white,
                  fontFamily: 'Outfit',
                  height: 1.4,
                ),
              ),
            ],
          ),
        );
      case 'level_up':
        final oldLvl = data['oldLevel'] ?? 1;
        final newLvl = data['newLevel'] ?? 2;
        return RichText(
          text: TextSpan(
            style: normalStyle,
            children: [
              const TextSpan(text: "Leveled up from "),
              TextSpan(text: "Level $oldLvl", style: boldStyle),
              const TextSpan(text: " to "),
              TextSpan(text: "Level $newLvl", style: boldStyle),
              const TextSpan(text: "! 🚀"),
            ],
          ),
        );
      case 'streak_milestone':
        final days = data['streakDays'] ?? 0;
        return RichText(
          text: TextSpan(
            style: normalStyle,
            children: [
              const TextSpan(text: "Reached a "),
              TextSpan(text: "$days-day", style: boldStyle),
              const TextSpan(text: " streak milestone! 🔥"),
            ],
          ),
        );
      case 'battle_won':
        final wins = data['battlesWon'] ?? 1;
        return RichText(
          text: TextSpan(
            style: normalStyle,
            children: [
              const TextSpan(text: "Won a live quiz battle! 🏆 Total battles won: "),
              TextSpan(text: "$wins", style: boldStyle),
            ],
          ),
        );
      case 'group_joined':
        final groupName = data['groupName'] ?? 'Group';
        return RichText(
          text: TextSpan(
            style: normalStyle,
            children: [
              const TextSpan(text: "Joined the church group "),
              TextSpan(text: groupName, style: boldStyle),
              const TextSpan(text: "! 👥"),
            ],
          ),
        );
      default:
        return Text("Performed some actions", style: normalStyle);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserDataProvider>(context, listen: false);

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient matching standard glassmorphism UI
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF1E1B4B), // Very dark indigo
                  Color(0xFF0F172A), // Very dark slate
                  Color(0xFF111827), // Very dark gray
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    children: [
                      const Icon(Icons.people_outline, color: Color(0xFF38BDF8), size: 28),
                      const SizedBox(width: 12),
                      const Text(
                        "Social Feed",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Outfit',
                        ),
                      ),
                      const Spacer(),
                      if (_isLoading && _activities.isNotEmpty)
                        const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: _isLoadingFollowing
                      ? const Center(
                          child: CircularProgressIndicator(color: Color(0xFF38BDF8)),
                        )
                      : _followingIds.isEmpty
                          ? _buildEmptyState(userProvider)
                          : RefreshIndicator(
                              onRefresh: _refreshFeed,
                              color: const Color(0xFF38BDF8),
                              backgroundColor: const Color(0xFF1E1B4B),
                              child: _activities.isEmpty && _isLoading
                                  ? const Center(
                                      child: CircularProgressIndicator(color: Color(0xFF38BDF8)),
                                    )
                                  : _activities.isEmpty
                                      ? _buildEmptyFeedState()
                                      : ListView.builder(
                                          controller: _scrollController,
                                          physics: const AlwaysScrollableScrollPhysics(),
                                          itemCount: _activities.length + (_hasMore ? 1 : 0),
                                          itemBuilder: (context, index) {
                                            if (index == _activities.length) {
                                              return const Padding(
                                                padding: EdgeInsets.symmetric(vertical: 24.0),
                                                child: Center(
                                                  child: SizedBox(
                                                    height: 24,
                                                    width: 24,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2.5,
                                                      color: Color(0xFF38BDF8),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }

                                            final activityDoc = _activities[index];
                                            final activity = activityDoc.data() as Map<String, dynamic>;
                                            final String type = activity['type'] ?? '';
                                            final String userName = activity['userName'] ?? 'User';
                                            final dynamic data = activity['data'] ?? {};
                                            final dynamic timestamp = activity['timestamp'];

                                            final details = _getActivityUiDetails(type);
                                            final IconData icon = details['icon'];
                                            final Color color = details['color'];

                                            return Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(16),
                                                child: BackdropFilter(
                                                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.white.withValues(alpha: 0.05),
                                                      borderRadius: BorderRadius.circular(16),
                                                      border: Border.all(
                                                        color: Colors.white.withValues(alpha: 0.08),
                                                        width: 1,
                                                      ),
                                                    ),
                                                    padding: const EdgeInsets.all(16),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        GestureDetector(
                                                          behavior: HitTestBehavior.opaque,
                                                          onTap: () {
                                                            final activityUserId = activity['userId'] as String? ?? '';
                                                            if (activityUserId.isNotEmpty) {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder: (context) => ProfileScreen(userId: activityUserId),
                                                                ),
                                                              );
                                                            }
                                                          },
                                                          child: Row(
                                                            children: [
                                                              CircleAvatar(
                                                                radius: 18,
                                                                backgroundColor: color.withValues(alpha: 0.2),
                                                                child: Text(
                                                                  userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                                                                  style: TextStyle(
                                                                    color: color,
                                                                    fontWeight: FontWeight.bold,
                                                                    fontFamily: 'Outfit',
                                                                    fontSize: 14,
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(width: 10),
                                                              Expanded(
                                                                child: Text(
                                                                  userName,
                                                                  style: const TextStyle(
                                                                    color: Colors.white,
                                                                    fontWeight: FontWeight.bold,
                                                                    fontFamily: 'Outfit',
                                                                    fontSize: 15,
                                                                  ),
                                                                  overflow: TextOverflow.ellipsis,
                                                                ),
                                                              ),
                                                              Text(
                                                                _formatTimeAgo(timestamp),
                                                                style: TextStyle(
                                                                  color: Colors.white.withValues(alpha: 0.4),
                                                                  fontSize: 12,
                                                                  fontFamily: 'Outfit',
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        const SizedBox(height: 12),
                                                        // Content Row: Icon and Details
                                                        Row(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Container(
                                                              padding: const EdgeInsets.all(8),
                                                              decoration: BoxDecoration(
                                                                color: color.withValues(alpha: 0.15),
                                                                borderRadius: BorderRadius.circular(10),
                                                              ),
                                                              child: Icon(
                                                                icon,
                                                                color: color,
                                                                size: 20,
                                                              ),
                                                            ),
                                                            const SizedBox(width: 12),
                                                            Expanded(
                                                              child: _buildActivityContent(type, data),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                            ),
                ),
                // Padding for bottom nav bar spacing since scaffold extendBody is true
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(UserDataProvider userProvider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF38BDF8).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.people_outline,
                size: 64,
                color: Color(0xFF38BDF8),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Start Building Your Feed!",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Outfit',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              "Follow friends and other players to see their quiz accomplishments, unlocked achievements, and group updates here.",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontFamily: 'Outfit',
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LeaderboardScreen()),
                );
              },
              icon: const Icon(Icons.search),
              label: const Text(
                "DISCOVER PEOPLE",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  fontFamily: 'Outfit',
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF38BDF8),
                foregroundColor: const Color(0xFF1E1B4B),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyFeedState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.dynamic_feed,
                size: 64,
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "No Activities Yet",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Outfit',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              "The players you follow haven't posted any updates or completed quizzes yet. Pull down to refresh or check back later!",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontFamily: 'Outfit',
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
