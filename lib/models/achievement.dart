import 'package:flutter/material.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final String type; // milestone, perfect_score, streak, level_unlocked, speed, topic_mastery, flashcard_mastery, daily_challenge
  final int requiredCount;
  final IconData icon;
  bool isUnlocked;
  int currentProgress;
  DateTime? dateUnlocked;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.requiredCount,
    required this.icon,
    this.isUnlocked = false,
    this.currentProgress = 0,
    this.dateUnlocked,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'isUnlocked': isUnlocked,
      'currentProgress': currentProgress,
      'dateUnlocked': dateUnlocked?.toIso8601String(),
    };
  }

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    String? type,
    int? requiredCount,
    IconData? icon,
    bool? isUnlocked,
    int? currentProgress,
    DateTime? dateUnlocked,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      requiredCount: requiredCount ?? this.requiredCount,
      icon: icon ?? this.icon,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      currentProgress: currentProgress ?? this.currentProgress,
      dateUnlocked: dateUnlocked ?? this.dateUnlocked,
    );
  }

  static List<Achievement> get allAchievements => [
        // Milestone
        Achievement(
          id: "milestone_5",
          title: "Getting Started",
          description: "Complete 5 quizzes",
          type: "milestone",
          requiredCount: 5,
          icon: Icons.emoji_events,
        ),
        Achievement(
          id: "milestone_10",
          title: "Quiz Explorer",
          description: "Complete 10 quizzes",
          type: "milestone",
          requiredCount: 10,
          icon: Icons.emoji_events,
        ),
        Achievement(
          id: "milestone_25",
          title: "Quiz Enthusiast",
          description: "Complete 25 quizzes",
          type: "milestone",
          requiredCount: 25,
          icon: Icons.emoji_events,
        ),
        Achievement(
          id: "milestone_50",
          title: "Quiz Master",
          description: "Complete 50 quizzes",
          type: "milestone",
          requiredCount: 50,
          icon: Icons.emoji_events,
        ),
        Achievement(
          id: "milestone_100",
          title: "Quiz Champion",
          description: "Complete 100 quizzes",
          type: "milestone",
          requiredCount: 100,
          icon: Icons.emoji_events,
        ),

        // Perfect Score
        Achievement(
          id: "perfect_score_1",
          title: "Flawless",
          description: "Get 100% on any quiz",
          type: "perfect_score",
          requiredCount: 1,
          icon: Icons.star,
        ),

        // Streak
        Achievement(
          id: "streak_3",
          title: "Consistent",
          description: "3-day streak",
          type: "streak",
          requiredCount: 3,
          icon: Icons.local_fire_department,
        ),
        Achievement(
          id: "streak_7",
          title: "Dedicated",
          description: "7-day streak",
          type: "streak",
          requiredCount: 7,
          icon: Icons.local_fire_department,
        ),
        Achievement(
          id: "streak_30",
          title: "Unstoppable",
          description: "30-day streak",
          type: "streak",
          requiredCount: 30,
          icon: Icons.local_fire_department,
        ),

        // Level Unlocked
        Achievement(
          id: "level_10",
          title: "Beginner",
          description: "Reach level 10",
          type: "level_unlocked",
          requiredCount: 10,
          icon: Icons.lock_open,
        ),
        Achievement(
          id: "level_25",
          title: "Intermediate",
          description: "Reach level 25",
          type: "level_unlocked",
          requiredCount: 25,
          icon: Icons.lock_open,
        ),
        Achievement(
          id: "level_50",
          title: "Advanced",
          description: "Reach level 50",
          type: "level_unlocked",
          requiredCount: 50,
          icon: Icons.lock_open,
        ),
        Achievement(
          id: "level_75",
          title: "Expert",
          description: "Reach level 75",
          type: "level_unlocked",
          requiredCount: 75,
          icon: Icons.lock_open,
        ),
        Achievement(
          id: "level_100",
          title: "Promised Land",
          description: "Reach level 100",
          type: "level_unlocked",
          requiredCount: 100,
          icon: Icons.lock_open,
        ),

        // Speed
        Achievement(
          id: "speed_10",
          title: "Quick Thinker",
          description: "Average answer time <= 10 seconds",
          type: "speed",
          requiredCount: 10, // representing 10 seconds limit
          icon: Icons.timer,
        ),
        Achievement(
          id: "speed_5",
          title: "Lightning",
          description: "Average answer time <= 5 seconds",
          type: "speed",
          requiredCount: 5, // representing 5 seconds limit
          icon: Icons.timer,
        ),

        // Topic Mastery
        Achievement(
          id: "topic_genesis",
          title: "Genesis Expert",
          description: "Complete all quizzes in \"Genesis\" topic",
          type: "topic_mastery",
          requiredCount: 5,
          icon: Icons.menu_book,
        ),
        Achievement(
          id: "topic_exodus",
          title: "Exodus Expert",
          description: "Complete all quizzes in \"Exodus\" topic",
          type: "topic_mastery",
          requiredCount: 5,
          icon: Icons.menu_book,
        ),

        // Flashcard Mastery
        Achievement(
          id: "flashcard_10",
          title: "Memorizer",
          description: "Master 10 flashcards",
          type: "flashcard_mastery",
          requiredCount: 10,
          icon: Icons.school,
        ),
        Achievement(
          id: "flashcard_25",
          title: "Scholar",
          description: "Master 25 flashcards",
          type: "flashcard_mastery",
          requiredCount: 25,
          icon: Icons.school,
        ),
        Achievement(
          id: "flashcard_50",
          title: "Sage",
          description: "Master 50 flashcards",
          type: "flashcard_mastery",
          requiredCount: 50,
          icon: Icons.school,
        ),
        Achievement(
          id: "flashcard_100",
          title: "Master",
          description: "Master 100 flashcards",
          type: "flashcard_mastery",
          requiredCount: 100,
          icon: Icons.school,
        ),

        // Daily Challenge
        Achievement(
          id: "daily_5",
          title: "Challenger",
          description: "Complete 5 daily challenges",
          type: "daily_challenge",
          requiredCount: 5,
          icon: Icons.calendar_today,
        ),
        Achievement(
          id: "daily_10",
          title: "Competitor",
          description: "Complete 10 daily challenges",
          type: "daily_challenge",
          requiredCount: 10,
          icon: Icons.calendar_today,
        ),
        Achievement(
          id: "daily_25",
          title: "Warrior",
          description: "Complete 25 daily challenges",
          type: "daily_challenge",
          requiredCount: 25,
          icon: Icons.calendar_today,
        ),
        
        // Weekly Leaderboard
        Achievement(
          id: "weekly_champion_1st",
          title: "Weekly 1st Place",
          description: "Earn 1st place in the weekly leaderboard",
          type: "weekly_leaderboard",
          requiredCount: 1,
          icon: Icons.emoji_events,
        ),
        Achievement(
          id: "weekly_champion_2nd",
          title: "Weekly 2nd Place",
          description: "Earn 2nd place in the weekly leaderboard",
          type: "weekly_leaderboard",
          requiredCount: 1,
          icon: Icons.emoji_events,
        ),
        Achievement(
          id: "weekly_champion_3rd",
          title: "Weekly 3rd Place",
          description: "Earn 3rd place in the weekly leaderboard",
          type: "weekly_leaderboard",
          requiredCount: 1,
          icon: Icons.emoji_events,
        ),

        // Monthly Leaderboard
        Achievement(
          id: "monthly_champion_1st",
          title: "Monthly 1st Place",
          description: "Earn 1st place in the monthly leaderboard",
          type: "monthly_leaderboard",
          requiredCount: 1,
          icon: Icons.emoji_events,
        ),
        Achievement(
          id: "monthly_champion_2nd",
          title: "Monthly 2nd Place",
          description: "Earn 2nd place in the monthly leaderboard",
          type: "monthly_leaderboard",
          requiredCount: 1,
          icon: Icons.emoji_events,
        ),
        Achievement(
          id: "monthly_champion_3rd",
          title: "Monthly 3rd Place",
          description: "Earn 3rd place in the monthly leaderboard",
          type: "monthly_leaderboard",
          requiredCount: 1,
          icon: Icons.emoji_events,
        ),

        // Reading Plan Achievements
        Achievement(
          id: "reading_start",
          title: "Getting Started",
          description: "Complete 1 day of a reading plan",
          type: "reading_milestone",
          requiredCount: 1,
          icon: Icons.book,
        ),
        Achievement(
          id: "reading_streak_7",
          title: "Week Warrior",
          description: "7-day reading plan streak",
          type: "reading_streak",
          requiredCount: 7,
          icon: Icons.local_fire_department,
        ),
        Achievement(
          id: "reading_streak_30",
          title: "Monthly Devotion",
          description: "30-day reading plan streak",
          type: "reading_streak",
          requiredCount: 30,
          icon: Icons.local_fire_department,
        ),
        Achievement(
          id: "reading_progress_50",
          title: "Halfway There",
          description: "Complete 50% of any reading plan",
          type: "reading_milestone",
          requiredCount: 50,
          icon: Icons.star_half,
        ),
        Achievement(
          id: "reading_plan_finish",
          title: "Plan Finisher",
          description: "Complete any reading plan",
          type: "reading_milestone",
          requiredCount: 100,
          icon: Icons.check_circle_outline_rounded,
        ),
        Achievement(
          id: "reading_scholar",
          title: "Bible Scholar",
          description: "Complete all 3 reading plans",
          type: "reading_milestone",
          requiredCount: 3,
          icon: Icons.school_rounded,
        ),
        Achievement(
          id: "share_1",
          title: "Spread the Word",
          description: "Share your first quiz result",
          type: "share",
          requiredCount: 1,
          icon: Icons.share,
        ),
        Achievement(
          id: "share_10",
          title: "Evangelist",
          description: "Share 10 quiz results",
          type: "share",
          requiredCount: 10,
          icon: Icons.share,
        ),
        Achievement(
          id: "miracle_seeker",
          title: "Miracle Seeker",
          description: "Open 5 Miracle Boxes",
          type: "miracle_box",
          requiredCount: 5,
          icon: Icons.card_giftcard,
        ),
        Achievement(
          id: "memory_master",
          title: "Memory Master",
          description: "Complete 10 scripture memory games",
          type: "memory_game",
          requiredCount: 10,
          icon: Icons.psychology,
        ),
        Achievement(
          id: "daily_champion",
          title: "Daily Champion",
          description: "Win a Daily Live Event",
          type: "live_event_win",
          requiredCount: 1,
          icon: Icons.workspace_premium,
        ),
        Achievement(
          id: "live_participant",
          title: "Live Participant",
          description: "Participate in 5 live events",
          type: "live_event_participate",
          requiredCount: 5,
          icon: Icons.group,
        ),
        Achievement(
          id: "first_victory",
          title: "First Victory",
          description: "Win your first 1v1 battle",
          type: "battle_win",
          requiredCount: 1,
          icon: Icons.shield,
        ),
        Achievement(
          id: "warrior_battle",
          title: "Warrior",
          description: "Win 10 battles",
          type: "battle_win",
          requiredCount: 10,
          icon: Icons.sports_martial_arts,
        ),
        Achievement(
          id: "champion_battle",
          title: "Champion",
          description: "Win 25 battles",
          type: "battle_win",
          requiredCount: 25,
          icon: Icons.military_tech,
        ),
        Achievement(
          id: "wisdom_tree_mature",
          title: "Tree of Life",
          description: "Reach the Mature Tree stage",
          type: "wisdom_tree",
          requiredCount: 1,
          icon: Icons.park_rounded,
        ),
        Achievement(
          id: "wisdom_tree_fruitful",
          title: "Fruitful",
          description: "Have 3 branches with fruit in your Wisdom Tree",
          type: "wisdom_tree",
          requiredCount: 3,
          icon: Icons.eco_rounded,
        ),
        Achievement(
          id: "wisdom_tree_full_bloom",
          title: "Full Bloom",
          description: "Have all 7 branches with blossoms or fruit",
          type: "wisdom_tree",
          requiredCount: 7,
          icon: Icons.local_florist_rounded,
        ),
      ];
}

