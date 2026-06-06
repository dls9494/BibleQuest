import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/user_data_provider.dart';
import '../services/firebase_service.dart';
import '../models/quiz.dart';
import 'self_paced_screen.dart';

class LiveEventScreen extends StatefulWidget {
  const LiveEventScreen({super.key});

  @override
  State<LiveEventScreen> createState() => _LiveEventScreenState();
}

class _LiveEventScreenState extends State<LiveEventScreen> {
  Timer? _countdownTimer;
  Duration _timeToStart = Duration.zero;
  bool _isLive = false;
  String _dateStr = "";
  bool _hasParticipated = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _checkStatus();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) => _checkStatus());
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _checkStatus() {
    final status = _getLiveEventStatus();
    if (!mounted) return;
    setState(() {
      _isLive = status['isLive'];
      _timeToStart = status['difference'];
      _dateStr = status['dateStr'];
    });
  }

  Map<String, dynamic> _getLiveEventStatus() {
    final now = DateTime.now().toUtc().add(const Duration(hours: 5, minutes: 30)); // IST
    final isLive = now.hour == 20 && now.minute >= 0 && now.minute < 15;
    
    DateTime targetTime = DateTime(now.year, now.month, now.day, 20, 0);
    if (now.hour > 20 || (now.hour == 20 && now.minute >= 15)) {
      targetTime = targetTime.add(const Duration(days: 1));
    }
    final difference = targetTime.difference(now);
    
    return {
      'isLive': isLive,
      'difference': difference,
      'dateStr': "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}",
    };
  }

  void _joinLiveQuiz(UserDataProvider userProvider) async {
    setState(() {
      _loading = true;
    });

    try {
      final event = await FirebaseService.getOrCreateLiveEvent(_dateStr);
      final level = event['quizLevel'] ?? 12;
      final questions = await FirebaseService.getRealQuestions(level, 'A');
      final quizQuestions = questions.take(10).toList(); // 10 questions for Live Quiz

      if (!mounted) return;

      final quiz = Quiz(
        id: 'live_quiz_$_dateStr',
        creatorId: 'system',
        titleKey: 'live_event_quiz',
        titleEn: 'Daily Live Quiz - $_dateStr',
        titleTe: 'రోజువారీ లైవ్ క్విజ్ - $_dateStr',
        descriptionEn: '🔴 10 Questions, One Champion. Compete live now!',
        descriptionTe: '🔴 10 ప్రశ్నలు, ఒక విజేత. ఇప్పుడే లైవ్‌లో పోటీపడండి!',
        difficulty: 'medium',
        topics: const ['Live Event'],
        bibleVersion: 'BSI Telugu',
        isPublic: true,
        level: level,
        questionCount: 10,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Launch Quiz
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SelfPacedScreen(
            quiz: quiz,
            questions: quizQuestions,
          ),
        ),
      );

      // Award participation
      userProvider.recordLiveEventParticipation();

      // Submit score to live leaderboard
      // Let's assume we can fetch user's last quiz score or we can intercept completed quiz.
      // Wait, in this screen we want to retrieve the score they just got!
      // To do this simply, we can get their highscore of 'live_quiz_$_dateStr' from UserDataProvider:
      final score = userProvider.quizHighScores['live_quiz_$_dateStr'] ?? 0;
      await FirebaseService.submitLiveEventScore(_dateStr, userProvider.userId!, userProvider.displayName, score);
      
      setState(() {
        _hasParticipated = true;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error joining live quiz: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(d.inHours);
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserDataProvider>(context);
    
    // Check if user has already played today's live quiz
    if (userProvider.quizHighScores.containsKey('live_quiz_$_dateStr')) {
      _hasParticipated = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("🔴 Daily Live Event"),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1A1A2E), Color(0xFF0F3460)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A1A2E), Color(0xFF0F3460)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!_isLive && !_hasParticipated) ...[
                    // Event countdown layout
                    const SizedBox(height: 40),
                    Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.03),
                              border: Border.all(color: Colors.white12, width: 2),
                            ),
                          ),
                          Column(
                            children: [
                              const Icon(Icons.timer, color: Colors.amber, size: 40),
                              const SizedBox(height: 8),
                              const Text("STARTS IN", style: TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
                              const SizedBox(height: 4),
                              Text(
                                _formatDuration(_timeToStart),
                                style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                          ),
                          child: Column(
                            children: const [
                              Text(
                                "📅 Daily live quiz runs every night",
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Event matches open at 8:00 PM IST and close at 8:15 PM IST. Answer 10 fast-paced questions, climb the leaderboard, and unlock the Daily Champion badge!",
                                style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5, fontFamily: 'Outfit'),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ] else if (_isLive && !_hasParticipated) ...[
                    // Active Live Event layout
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.red.withValues(alpha: 0.5), width: 1.5),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.radio_button_checked_rounded, color: Colors.red, size: 48),
                          const SizedBox(height: 16),
                          const Text(
                            "LIVE NOW",
                            style: TextStyle(color: Colors.red, fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Outfit', letterSpacing: 2),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "10 Questions, One Champion. Compete in tonight's live quiz!",
                            style: TextStyle(color: Colors.white70, fontSize: 14, fontFamily: 'Outfit'),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _loading ? null : () => _joinLiveQuiz(userProvider),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: _loading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : const Text("JOIN EVENT NOW", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Outfit')),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // Already participated / Live Leaderboard view
                    const SizedBox(height: 20),
                    const Text(
                      "🏆 Tonight's Live Leaderboard",
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Watch real-time participant score updates.",
                      style: TextStyle(color: Colors.white60, fontSize: 13, fontFamily: 'Outfit'),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance.collection('live_events').doc(_dateStr).snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || !snapshot.data!.exists) {
                          return const Center(child: Text("No live data available yet.", style: TextStyle(color: Colors.white60)));
                        }
                        
                        final data = snapshot.data!.data() as Map<String, dynamic>;
                        final participants = Map<String, int>.from(data['participants'] ?? {});
                        final names = Map<String, String>.from(data['participantNames'] ?? {});
                        
                        if (participants.isEmpty) {
                          return const Center(child: Text("No participants yet.", style: TextStyle(color: Colors.white60)));
                        }
                        
                        final sortedIds = participants.keys.toList()
                          ..sort((a, b) => participants[b]!.compareTo(participants[a]!));
                        
                        // Check if current user is the winner (first place)
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (sortedIds.first == userProvider.userId) {
                            // Automatically award live event win
                            if (userProvider.liveEventsWon == 0) {
                              userProvider.recordLiveEventWin();
                            }
                          }
                        });

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: sortedIds.length,
                          itemBuilder: (context, index) {
                            final uid = sortedIds[index];
                            final name = names[uid] ?? "Participant";
                            final score = participants[uid] ?? 0;
                            final isMe = uid == userProvider.userId;
                            
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: isMe ? Colors.amber.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.05),
                                border: Border.all(color: isMe ? Colors.amber : Colors.white10),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: index == 0 
                                      ? Colors.amber 
                                      : (index == 1 ? Colors.grey : (index == 2 ? Colors.brown : Colors.white12)),
                                  foregroundColor: index < 3 ? Colors.black : Colors.white,
                                  child: Text("${index + 1}", style: const TextStyle(fontWeight: FontWeight.bold)),
                                ),
                                title: Text(
                                  name + (isMe ? " (You)" : ""),
                                  style: TextStyle(
                                    color: isMe ? Colors.amberAccent : Colors.white,
                                    fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
                                    fontFamily: 'Outfit',
                                  ),
                                ),
                                trailing: Text(
                                  "$score pts",
                                  style: TextStyle(
                                    color: isMe ? Colors.amberAccent : Colors.white70,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Outfit',
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
