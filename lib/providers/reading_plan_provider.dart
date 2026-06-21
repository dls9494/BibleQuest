import 'package:flutter/foundation.dart';
import '../models/reading_plan.dart';
import '../services/firebase_service.dart';
import 'user_data_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/reading_plan_data.dart';

class ReadingPlanProvider extends ChangeNotifier {
  bool _isLoading = false;
  ReadingPlan? _currentPlan;

  bool get isLoading => _isLoading;
  ReadingPlan? get currentPlan => _currentPlan;

  int _getPlanLength(String planType) {
    if (planType == '90_day') return 90;
    if (planType == '365_day') return 365;
    return 30;
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool isYesterday(DateTime prev, DateTime now) {
    final yesterday = now.subtract(const Duration(days: 1));
    return prev.year == yesterday.year && prev.month == yesterday.month && prev.day == yesterday.day;
  }

  Future<void> loadCurrentPlan(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await FirebaseService.getReadingProgress(userId);
      if (data != null) {
        _currentPlan = ReadingPlan.fromMap(data);
      } else {
        _currentPlan = null;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error loading current plan: $e");
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> startPlan(String userId, String planType, UserDataProvider userDataProvider) async {
    _isLoading = true;
    notifyListeners();
    try {
      final newPlan = ReadingPlan(
        planType: planType,
        startDate: DateTime.now(),
        currentDay: 1,
        completedDays: [],
        quizDaysCompleted: [],
        streak: 0,
        lastReadDate: null,
      );
      await FirebaseService.saveReadingProgress(userId, newPlan.toMap());
      _currentPlan = newPlan;
      
      // Update UserDataProvider reading stats
      userDataProvider.updateReadingStats(
        streak: 0,
        progressPercent: 0,
        totalDaysCompleted: 0,
      );
    } catch (e) {
      if (kDebugMode) {
        print("Error starting plan: $e");
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markDayRead(String userId, int day, UserDataProvider userDataProvider) async {
    if (_currentPlan == null) return;
    
    final plan = _currentPlan!;
    if (plan.completedDays.contains(day)) return;

    _isLoading = true;
    notifyListeners();

    try {
      final now = DateTime.now();
      final lastRead = plan.lastReadDate;
      int newStreak = plan.streak;

      if (lastRead == null) {
        newStreak = 1;
      } else if (isSameDay(lastRead, now)) {
        // Streak remains unchanged
      } else if (isYesterday(lastRead, now)) {
        newStreak = plan.streak + 1;
      } else {
        newStreak = 1;
      }

      final updatedCompletedDays = List<int>.from(plan.completedDays)..add(day);
      
      final planLength = _getPlanLength(plan.planType);
      
      int nextDay = plan.currentDay;
      if (day == plan.currentDay && day < planLength) {
        nextDay = plan.currentDay + 1;
      }

      final updatedPlan = plan.copyWith(
        completedDays: updatedCompletedDays,
        streak: newStreak,
        lastReadDate: now,
        currentDay: nextDay,
      );

      await FirebaseService.saveReadingProgress(userId, updatedPlan.toMap());
      _currentPlan = updatedPlan;

      // Award XP for reading
      userDataProvider.addXp(10);

      // Update topic performance for books read
      final days = ReadingPlanData.getPlanDays(plan.planType);
      if (day - 1 < days.length) {
        final dayData = days[day - 1];
        final bookIds = userDataProvider.parseBookIdsFromText(dayData.versesEn);
        for (final bookId in bookIds) {
          userDataProvider.updateTopicPerformance(bookId, 1.0);
        }
      }

      // Check if finished
      final isFinished = updatedCompletedDays.length == planLength;

      // Update UserDataProvider stats & check achievements
      userDataProvider.updateReadingStats(
        streak: newStreak,
        progressPercent: (updatedCompletedDays.length * 100) ~/ planLength,
        totalDaysCompleted: updatedCompletedDays.length,
        finishedPlanType: isFinished ? plan.planType : null,
      );
    } catch (e) {
      if (kDebugMode) {
        print("Error marking day as read: $e");
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> completeQuizForDay(String userId, int day, UserDataProvider userDataProvider) async {
    if (_currentPlan == null) return;

    final plan = _currentPlan!;
    if (plan.quizDaysCompleted.contains(day)) return;

    _isLoading = true;
    notifyListeners();

    try {
      final updatedQuizDaysCompleted = List<int>.from(plan.quizDaysCompleted)..add(day);
      final updatedPlan = plan.copyWith(
        quizDaysCompleted: updatedQuizDaysCompleted,
      );

      await FirebaseService.saveReadingProgress(userId, updatedPlan.toMap());
      _currentPlan = updatedPlan;

      // Award XP for quiz completion
      userDataProvider.addXp(25);
    } catch (e) {
      if (kDebugMode) {
        print("Error completing reading quiz: $e");
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetPlan(String userId, UserDataProvider userDataProvider) async {
    _isLoading = true;
    notifyListeners();
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('reading_plan')
          .doc('current')
          .delete();
          
      _currentPlan = null;

      // Reset statistics on the UserDataProvider side if needed
      // (but generally achievements and history completed count persist. That's fine)
    } catch (e) {
      if (kDebugMode) {
        print("Error resetting reading plan: $e");
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
