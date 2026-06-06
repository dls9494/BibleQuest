import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/church_group.dart';
import '../models/quiz.dart';
import '../providers/user_data_provider.dart';
import '../services/firebase_service.dart';
import 'self_paced_screen.dart';

class GroupDetailScreen extends StatefulWidget {
  final String groupId;

  const GroupDetailScreen({super.key, required this.groupId});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  String _formatTimeRemaining(DateTime endDate) {
    final now = DateTime.now();
    final difference = endDate.difference(now);
    if (difference.isNegative) {
      return "Completed";
    }
    final days = difference.inDays;
    final hours = difference.inHours % 24;
    final minutes = difference.inMinutes % 60;
    final seconds = difference.inSeconds % 60;

    String twoDigits(int n) => n.toString().padLeft(2, '0');

    if (days > 0) {
      return "$days d, ${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}";
    }
    return "${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}";
  }

  void _showCreateChallengeDialog(ChurchGroup group) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final levelController = TextEditingController(text: "1");
    DateTime? selectedDate;
    bool isCreating = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A2E).withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                        width: 1.5,
                      ),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            "Create Group Challenge",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Outfit',
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: titleController,
                            style: const TextStyle(color: Colors.white, fontFamily: 'Outfit'),
                            decoration: InputDecoration(
                              hintText: "Challenge Title",
                              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.05),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFF38BDF8)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: descController,
                            style: const TextStyle(color: Colors.white, fontFamily: 'Outfit'),
                            decoration: InputDecoration(
                              hintText: "Description",
                              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.05),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFF38BDF8)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: levelController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.white, fontFamily: 'Outfit'),
                            decoration: InputDecoration(
                              hintText: "Quiz Level (1-100)",
                              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.05),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFF38BDF8)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          InkWell(
                            onTap: () async {
                              final pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now().add(const Duration(days: 1)),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 30)),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: const ColorScheme.dark(
                                        primary: Color(0xFF38BDF8),
                                        onPrimary: Color(0xFF1A1A2E),
                                        surface: Color(0xFF1A1A2E),
                                        onSurface: Colors.white,
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (pickedDate != null) {
                                if (!context.mounted) return;
                                final pickedTime = await showTimePicker(
                                  context: context,
                                  initialTime: const TimeOfDay(hour: 23, minute: 59),
                                  builder: (context, child) {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: const ColorScheme.dark(
                                          primary: Color(0xFF38BDF8),
                                          onPrimary: Color(0xFF1A1A2E),
                                          surface: Color(0xFF1A1A2E),
                                          onSurface: Colors.white,
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );
                                if (pickedTime != null) {
                                  setDialogState(() {
                                    selectedDate = DateTime(
                                      pickedDate.year,
                                      pickedDate.month,
                                      pickedDate.day,
                                      pickedTime.hour,
                                      pickedTime.minute,
                                    );
                                  });
                                }
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    selectedDate == null
                                        ? "Select End Date & Time"
                                        : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year} ${selectedDate!.hour.toString().padLeft(2, '0')}:${selectedDate!.minute.toString().padLeft(2, '0')}",
                                    style: TextStyle(
                                      color: selectedDate == null
                                          ? Colors.white.withValues(alpha: 0.5)
                                          : Colors.white,
                                      fontFamily: 'Outfit',
                                    ),
                                  ),
                                  const Icon(Icons.calendar_today, color: Color(0xFF38BDF8), size: 20),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  onPressed: isCreating ? null : () => Navigator.of(dialogContext).pop(),
                                  child: Text(
                                    "Cancel",
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.7),
                                      fontFamily: 'Outfit',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: isCreating
                                      ? null
                                      : () async {
                                          final title = titleController.text.trim();
                                          final desc = descController.text.trim();
                                          final lvlStr = levelController.text.trim();
                                          final int? level = int.tryParse(lvlStr);

                                          if (title.isEmpty || desc.isEmpty) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text("Please fill all text fields.")),
                                            );
                                            return;
                                          }
                                          if (level == null || level < 1 || level > 100) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text("Level must be between 1 and 100.")),
                                            );
                                            return;
                                          }
                                          if (selectedDate == null) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text("Please select an end date.")),
                                            );
                                            return;
                                          }

                                          final userProvider = Provider.of<UserDataProvider>(context, listen: false);
                                          final scaffoldMessenger = ScaffoldMessenger.of(context);
                                          final navigator = Navigator.of(dialogContext);
                                          setDialogState(() => isCreating = true);
                                          try {
                                            await FirebaseService.createGroupChallenge(
                                              group.id,
                                              title,
                                              desc,
                                              level,
                                              selectedDate!,
                                            );

                                            // Update challengesCreated stat
                                            userProvider.incrementChallengesCreated();

                                            navigator.pop();
                                            scaffoldMessenger.showSnackBar(
                                              const SnackBar(content: Text("Challenge created successfully!")),
                                            );
                                          } catch (e) {
                                            scaffoldMessenger.showSnackBar(
                                              SnackBar(content: Text("Error: $e")),
                                            );
                                            setDialogState(() => isCreating = false);
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF38BDF8),
                                    foregroundColor: const Color(0xFF1A1A2E),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: isCreating
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1A1A2E)),
                                        )
                                      : const Text("Create", style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
                                ),
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
        );
      },
    );
  }

  void _playChallenge(GroupChallenge challenge) {
    final challengeQuiz = Quiz(
      id: 'challenge_${challenge.id}',
      creatorId: 'system',
      titleKey: 'group_challenge',
      bibleVersion: 'BSI Telugu',
      topics: const ['Group Challenge'],
      isPublic: false,
      questionCount: 10,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      titleEn: challenge.title,
      titleTe: challenge.title,
      descriptionEn: challenge.description,
      descriptionTe: challenge.description,
      level: challenge.quizLevel,
      difficulty: challenge.quizLevel <= 33 ? 'easy' : (challenge.quizLevel <= 66 ? 'medium' : 'hard'),
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SelfPacedScreen(
          quiz: challengeQuiz,
          groupChallengeId: challenge.id,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserDataProvider>();
    final uid = userProvider.userId ?? '';

    return StreamBuilder<ChurchGroup?>(
      stream: FirebaseService.getGroupStream(widget.groupId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF1A1A2E),
            body: Center(child: CircularProgressIndicator(color: Color(0xFF38BDF8))),
          );
        }

        final group = snapshot.data;
        if (group == null) {
          return Scaffold(
            backgroundColor: const Color(0xFF1A1A2E),
            appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
            body: const Center(child: Text("Group not found.", style: TextStyle(color: Colors.white, fontFamily: 'Outfit'))),
          );
        }

        final isPastor = group.pastorId == uid;

        return Scaffold(
          body: Stack(
            children: [
              // Background Gradient
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
              // Content scroll view
              SafeArea(
                child: CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      floating: true,
                      pinned: false,
                      title: Text(group.name, style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          _buildHeaderCard(group),
                          const SizedBox(height: 20),
                          _buildChallengesSection(group, isPastor, uid, userProvider),
                          const SizedBox(height: 20),
                          _buildLeaderboardSection(group, uid),
                          const SizedBox(height: 20),
                          _buildMemberListSection(group),
                          const SizedBox(height: 40),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeaderCard(ChurchGroup group) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                group.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Outfit',
                ),
              ),
              if (group.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  group.description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 15,
                    fontFamily: 'Outfit',
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "PASTOR / LEADER",
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        group.pastorName,
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600, fontFamily: 'Outfit'),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "MEMBERS",
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${group.totalMembers}",
                        style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(color: Colors.white24, height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Join Code:",
                    style: TextStyle(color: Colors.white70, fontSize: 14, fontFamily: 'Outfit'),
                  ),
                  Row(
                    children: [
                      Text(
                        group.joinCode,
                        style: const TextStyle(
                          color: Color(0xFF38BDF8),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                          fontFamily: 'Outfit',
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.copy, color: Color(0xFF38BDF8), size: 20),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: group.joinCode));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Join code copied to clipboard!")),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChallengesSection(
      ChurchGroup group, bool isPastor, String uid, UserDataProvider userProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Group Challenges",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
            ),
            if (isPastor)
              ElevatedButton.icon(
                onPressed: () => _showCreateChallengeDialog(group),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                  foregroundColor: const Color(0xFF38BDF8),
                  side: const BorderSide(color: Color(0xFF38BDF8), width: 1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
                icon: const Icon(Icons.add, size: 16),
                label: const Text("Create", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
              ),
          ],
        ),
        const SizedBox(height: 10),
        StreamBuilder<List<GroupChallenge>>(
          stream: FirebaseService.getGroupChallenges(group.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: Padding(padding: EdgeInsets.all(12.0), child: CircularProgressIndicator(color: Color(0xFF38BDF8))));
            }

            final challenges = snapshot.data ?? [];
            if (challenges.isEmpty) {
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                ),
                child: Center(
                  child: Text(
                    "No active challenges.",
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 14, fontFamily: 'Outfit'),
                  ),
                ),
              );
            }

            final activeChallenges = challenges.where((c) => c.endDate.isAfter(DateTime.now())).toList();
            final completedChallenges = challenges.where((c) => !c.endDate.isAfter(DateTime.now())).toList();

            return Column(
              children: [
                if (activeChallenges.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 6.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text("ACTIVE", style: TextStyle(color: Color(0xFF38BDF8), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1, fontFamily: 'Outfit')),
                    ),
                  ),
                  ...activeChallenges.map((challenge) => _buildChallengeCard(challenge, false, uid, group, userProvider)),
                ],
                if (completedChallenges.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 6.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text("COMPLETED", style: TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1, fontFamily: 'Outfit')),
                    ),
                  ),
                  ...completedChallenges.map((challenge) => _buildChallengeCard(challenge, true, uid, group, userProvider)),
                ],
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildChallengeCard(GroupChallenge challenge, bool isCompleted, String uid,
      ChurchGroup group, UserDataProvider userProvider) {
    final hasPlayed = challenge.participantScores.containsKey(uid);
    final userScore = challenge.participantScores[uid];

    String winnerName = 'No participants';
    int maxScore = -1;
    String winnerId = '';

    if (challenge.participantScores.isNotEmpty) {
      challenge.participantScores.forEach((key, val) {
        if (val > maxScore) {
          maxScore = val;
          winnerId = key;
        }
      });

      // Find winner displayName
      final memberIndex = group.memberIds.indexOf(winnerId);
      if (memberIndex >= 0 && memberIndex < group.memberNames.length) {
        winnerName = group.memberNames[memberIndex];
      } else {
        winnerName = 'Group Member';
      }

      // Proactively credit challenge wins for the current user
      if (isCompleted && winnerId == uid && !userProvider.wonChallengeIds.contains(challenge.id)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          userProvider.recordChallengeWin(challenge.id);
        });
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: isCompleted ? 0.03 : 0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isCompleted ? Colors.white.withValues(alpha: 0.05) : const Color(0xFF38BDF8).withValues(alpha: 0.25),
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          challenge.title,
                          style: TextStyle(
                            color: isCompleted ? Colors.white70 : Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Outfit',
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          challenge.description,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 13,
                            fontFamily: 'Outfit',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "Level ${challenge.quizLevel}",
                      style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
                    ),
                  ),
                ],
              ),
              const Divider(color: Colors.white10, height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (!isCompleted) ...[
                    Row(
                      children: [
                        const Icon(Icons.timer, color: Color(0xFF38BDF8), size: 16),
                        const SizedBox(width: 4),
                        Text(
                          _formatTimeRemaining(challenge.endDate),
                          style: const TextStyle(
                            color: Color(0xFF38BDF8),
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Outfit',
                          ),
                        ),
                      ],
                    ),
                    if (hasPlayed)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "Played: $userScore",
                          style: const TextStyle(color: Colors.greenAccent, fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
                        ),
                      )
                    else
                      ElevatedButton(
                        onPressed: () => _playChallenge(challenge),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF38BDF8),
                          foregroundColor: const Color(0xFF1A1A2E),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          minimumSize: const Size(0, 32),
                        ),
                        child: const Text("Play", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
                      ),
                  ] else ...[
                    // Completed challenge layout
                    Row(
                      children: [
                        const Icon(Icons.emoji_events, color: Color(0xFFFFD700), size: 16),
                        const SizedBox(width: 4),
                        Text(
                          "Winner: $winnerName ($maxScore)",
                          style: const TextStyle(color: Color(0xFFFFD700), fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Outfit'),
                        ),
                      ],
                    ),
                    Text(
                      hasPlayed ? "My Score: $userScore" : "Didn't participate",
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12, fontFamily: 'Outfit'),
                    ),
                  ],
                ],
              ),
              // Real-time participant mini-leaderboard
              if (challenge.participantScores.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        "PARTICIPANTS",
                        style: TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
                      ),
                      const SizedBox(height: 4),
                      ...challenge.participantScores.entries.map((entry) {
                        final memberId = entry.key;
                        final score = entry.value;
                        final index = group.memberIds.indexOf(memberId);
                        final name = index >= 0 && index < group.memberNames.length
                            ? group.memberNames[index]
                            : 'Member';
                        final isCurrentUser = memberId == uid;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                name + (isCurrentUser ? " (You)" : ""),
                                style: TextStyle(
                                  color: isCurrentUser ? const Color(0xFF38BDF8) : Colors.white70,
                                  fontSize: 12,
                                  fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                                  fontFamily: 'Outfit',
                                ),
                              ),
                              Text(
                                "$score pts",
                                style: TextStyle(
                                  color: isCurrentUser ? const Color(0xFF38BDF8) : Colors.white54,
                                  fontSize: 12,
                                  fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                                  fontFamily: 'Outfit',
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeaderboardSection(ChurchGroup group, String uid) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          "Group Leaderboard",
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
        ),
        const SizedBox(height: 10),
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: FirebaseService.getGroupLeaderboard(group.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: Padding(padding: EdgeInsets.all(12.0), child: CircularProgressIndicator(color: Color(0xFF38BDF8))));
            }

            final leaderboard = snapshot.data ?? [];
            if (leaderboard.isEmpty) {
              return const Center(child: Text("No data.", style: TextStyle(color: Colors.white54)));
            }

            return ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: leaderboard.length,
                  itemBuilder: (context, index) {
                    final member = leaderboard[index];
                    final memberUid = member['uid'] as String;
                    final isMe = memberUid == uid;
                    final totalXp = member['totalXp'] as int;
                    final activeTitle = member['activeTitle'] as String;

                    Widget rankWidget;
                    if (index == 0) {
                      rankWidget = const Text("🥇", style: TextStyle(fontSize: 18));
                    } else if (index == 1) {
                      rankWidget = const Text("🥈", style: TextStyle(fontSize: 18));
                    } else if (index == 2) {
                      rankWidget = const Text("🥉", style: TextStyle(fontSize: 18));
                    } else {
                      rankWidget = Text(
                        "${index + 1}",
                        style: const TextStyle(color: Colors.white38, fontSize: 14, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
                      );
                    }

                    return Container(
                      color: isMe ? const Color(0xFF38BDF8).withValues(alpha: 0.08) : Colors.transparent,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Row(
                        children: [
                          SizedBox(width: 30, child: rankWidget),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  member['displayName'] + (isMe ? " (You)" : ""),
                                  style: TextStyle(
                                    color: isMe ? const Color(0xFF38BDF8) : Colors.white,
                                    fontWeight: isMe ? FontWeight.bold : FontWeight.w500,
                                    fontSize: 15,
                                    fontFamily: 'Outfit',
                                  ),
                                ),
                                if (activeTitle.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    activeTitle.toUpperCase(),
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.4),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                      fontFamily: 'Outfit',
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Text(
                            "$totalXp XP",
                            style: TextStyle(
                              color: isMe ? const Color(0xFF38BDF8) : Colors.white70,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              fontFamily: 'Outfit',
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMemberListSection(ChurchGroup group) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          "Member List",
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: group.memberIds.length,
              itemBuilder: (context, index) {
                final name = group.memberNames[index];
                return ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                    radius: 14,
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : 'M',
                      style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    name,
                    style: const TextStyle(color: Colors.white70, fontSize: 14, fontFamily: 'Outfit'),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
