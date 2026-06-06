import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/achievement.dart';
import '../models/profile_title.dart';
import '../models/quiz.dart';
import '../services/firebase_service.dart';
import '../services/bible_service.dart';
import '../models/bible.dart';

class UserDataProvider extends ChangeNotifier {
  String? _userId;
  final Set<int> _unlockedLevels = {1};
  int _totalXp = 0;
  int _streakDays = 0;
  DateTime? _lastPlayDate;
  bool _dailyChallengeCompleted = false;
  bool _weeklyChallengeCompleted = false;
  bool _monthlyChallengeCompleted = false;
  String _lastDailyChallengeDate = "";
  String _lastWeeklyChallengeReset = "";
  String _lastMonthlyChallengeReset = "";
  
  final Map<String, int> _quizHighScores = {};
  final Map<String, int> _quizPercentages = {};
  
  // Achievements fields
  final List<Achievement> _achievementsList = Achievement.allAchievements;
  Achievement? _newlyUnlocked;
  
  // Stats fields
  int _totalDailyChallengesCompleted = 0;
  final Set<String> _masteredFlashcards = {};
  double _averageAnswerTime = 0.0;
  int _totalAnswerTimeSpent = 0;
  int _totalQuestionsAnswered = 0;
  final Set<String> _completedQuizTopics = {};
  
  int _weeklyRank = -1;
  int _monthlyRank = -1;
  int? _dailyQuizLevel;
  String _dailyQuizDate = "";
  int _tabIndex = 0;
  
  final Map<int, Set<String>> _seenSets = {};

  // Reading plan tracking fields
  int _completedReadingPlansCount = 0;
  int _highestReadingStreak = 0;
  int _highestReadingProgress = 0;
  int _readingDaysCompleted = 0;
  final Set<String> _completedReadingPlanTypes = {};

  // Feature 3: Streak Miracle Box fields
  final List<int> _streakBoxesOpened = [];
  int _totalMiracleBoxesOpened = 0;
  bool _pendingMiracleBox = false;

  // Feature 4: Bookmarks fields
  final Set<String> _bookmarkedQuestionIds = {};

  // Feature 1: This Day in the Bible quiz completion
  bool _thisDayQuizCompleted = false;

  // Feature 1: Scripture Memory Game
  int _memoryGamesCompleted = 0;

  // Feature 3: Daily Live Event
  int _liveEventsWon = 0;
  int _liveEventsParticipated = 0;

  // Feature 4: 1v1 Battle Mode
  int _battlesWon = 0;
  int _battlesLost = 0;
  int _battlesPlayed = 0;

  // Feature 2: Sharpen Your Weakness & Wisdom Tree
  Map<String, double> _topicPerformance = {};
  Map<String, int> _topicPerformanceCounts = {};
  bool _weaknessQuizCompleted = false;

  // Bible navigation target (set when navigating from reading plan)
  String? _bibleBookId;
  int? _bibleChapter;
  int? _bibleVerse;
  final Set<String> _bookmarkedVerseRefs = {};


  // Exposing Profile fields reactively
  String _displayName = "Guest Player";
  String _username = "guest_username";
  String _email = "guest@example.com";
  String? _photoURL;
  String? _phoneNumber;
  String _authMethod = "anonymous";

  // Title fields
  String _activeTitle = "";
  final List<String> _unlockedTitles = ["novice"];
  int _prayersOffered = 0;
  int _totalShares = 0;

  // Group statistics fields
  int _joinedGroupsCount = 0;
  int _createdGroupsCount = 0;
  int _maxGroupSize = 0;
  int _challengesWon = 0;
  int _challengesCreated = 0;
  List<String> _wonChallengeIds = [];

  // Stream Subscription for Firestore syncing
  StreamSubscription<DocumentSnapshot>? _userDocSubscription;

  // Write Queue variables
  final List<Future<void> Function()> _writeQueue = [];
  bool _isWriting = false;
  final Set<String> _dirtyFields = {};

  void _markDirty(String field) {
    _dirtyFields.add(field);
  }

  void _enqueueWrite(Future<void> Function() writeOperation) {
    _writeQueue.add(writeOperation);
    if (!_isWriting) {
      _processQueue();
    }
  }

  Future<void> _processQueue() async {
    _isWriting = true;
    while (_writeQueue.isNotEmpty) {
      final nextWrite = _writeQueue.removeAt(0);
      try {
        await nextWrite();
      } catch (e) {
        // ignore: avoid_print
        print("Error in write queue operation: $e");
      }
    }
    _isWriting = false;
  }

  Set<int> get unlockedLevels => _unlockedLevels;
  String? get userId => _userId;
  Map<int, Set<String>> get seenSets => _seenSets;

  String get displayName => _displayName;
  String get username => _username;
  String get email => _email;
  String? get photoURL => _photoURL;
  String? get phoneNumber => _phoneNumber;
  String get authMethod => _authMethod;

  String getOrPickUnseenSetForLevel(int level) {
    _seenSets.putIfAbsent(level, () => {});
    final seen = _seenSets[level]!;
    final allSets = {'A', 'B', 'C'};
    final unseen = allSets.difference(seen);
    if (unseen.isEmpty) {
      seen.clear();
      unseen.addAll(allSets);
    }
    final list = unseen.toList();
    list.sort();
    final chosen = list[Random().nextInt(list.length)];
    return chosen;
  }

  void markSetAsSeen(int level, String setId) {
    _seenSets.putIfAbsent(level, () => {});
    _seenSets[level]!.add(setId);
    notifyListeners();
    _markDirty('seenSets');
    _enqueueWrite(() => _saveToFirestore());
  }

  void resetSeenSetsForLevel(int level) {
    _seenSets[level]?.clear();
    notifyListeners();
    _markDirty('seenSets');
    _enqueueWrite(() => _saveToFirestore());
  }

  int get totalXp => _totalXp;
  int get playerLevel => 1 + (_totalXp ~/ 1000);
  int get streakDays => _streakDays;
  DateTime? get lastPlayDate => _lastPlayDate;
  
  bool get dailyChallengeCompleted {
    checkAndResetChallenges();
    return _dailyChallengeCompleted;
  }
  
  bool get weeklyChallengeCompleted {
    checkAndResetChallenges();
    return _weeklyChallengeCompleted;
  }

  bool get monthlyChallengeCompleted {
    checkAndResetChallenges();
    return _monthlyChallengeCompleted;
  }
  
  String get lastDailyChallengeDate => _lastDailyChallengeDate;
  String get lastWeeklyChallengeReset => _lastWeeklyChallengeReset;
  String get lastMonthlyChallengeReset => _lastMonthlyChallengeReset;

  Map<String, int> get quizHighScores => _quizHighScores;
  Map<String, int> get quizPercentages => _quizPercentages;
  
  List<Achievement> get achievements => _achievementsList;
  Achievement? get newlyUnlocked => _newlyUnlocked;
  int get totalDailyChallengesCompleted => _totalDailyChallengesCompleted;
  Set<String> get masteredFlashcards => _masteredFlashcards;
  int get flashcardsMastered => _masteredFlashcards.length;
  double get averageAnswerTime => _averageAnswerTime;
  Set<String> get completedQuizTopics => _completedQuizTopics;
  int get weeklyRank => _weeklyRank;
  int get monthlyRank => _monthlyRank;
  int? get dailyQuizLevel => _dailyQuizLevel;
  int get tabIndex => _tabIndex;

  String get activeTitle => _activeTitle;
  List<String> get unlockedTitles => _unlockedTitles;
  int get prayersOffered => _prayersOffered;
  int get totalQuestionsAnswered => _totalQuestionsAnswered;

  int get joinedGroupsCount => _joinedGroupsCount;
  int get createdGroupsCount => _createdGroupsCount;
  int get maxGroupSize => _maxGroupSize;
  int get challengesWon => _challengesWon;
  int get challengesCreated => _challengesCreated;
  List<String> get wonChallengeIds => _wonChallengeIds;

  // Reading plan getters
  int get completedReadingPlansCount => _completedReadingPlansCount;
  int get highestReadingStreak => _highestReadingStreak;
  int get highestReadingProgress => _highestReadingProgress;
  int get readingDaysCompleted => _readingDaysCompleted;
  Set<String> get completedReadingPlanTypes => _completedReadingPlanTypes;

  // Feature 3: Streak Miracle Box getters
  List<int> get streakBoxesOpened => _streakBoxesOpened;
  int get totalMiracleBoxesOpened => _totalMiracleBoxesOpened;
  bool get pendingMiracleBox => _pendingMiracleBox;

  // Feature 4: Bookmarks getters
  Set<String> get bookmarkedQuestionIds => _bookmarkedQuestionIds;

  // Feature 1: This Day in the Bible quiz completion getter
  bool get thisDayQuizCompleted => _thisDayQuizCompleted;

  int get memoryGamesCompleted => _memoryGamesCompleted;
  int get liveEventsWon => _liveEventsWon;
  int get liveEventsParticipated => _liveEventsParticipated;
  int get battlesWon => _battlesWon;
  int get battlesLost => _battlesLost;
  int get battlesPlayed => _battlesPlayed;
  Map<String, double> get topicPerformance => _topicPerformance;
  Map<String, int> get topicPerformanceCounts => _topicPerformanceCounts;
  bool get weaknessQuizCompleted => _weaknessQuizCompleted;

  String? get bibleBookId => _bibleBookId;
  set bibleBookId(String? value) {
    _bibleBookId = value;
    notifyListeners();
  }

  int? get bibleChapter => _bibleChapter;
  set bibleChapter(int? value) {
    _bibleChapter = value;
    notifyListeners();
  }

  int? get bibleVerse => _bibleVerse;
  set bibleVerse(int? value) {
    _bibleVerse = value;
    notifyListeners();
  }

  Set<String> get bookmarkedVerseRefs => _bookmarkedVerseRefs;

  void toggleVerseBookmark(String ref) {
    if (_bookmarkedVerseRefs.contains(ref)) {
      _bookmarkedVerseRefs.remove(ref);
    } else {
      _bookmarkedVerseRefs.add(ref);
    }
    _markDirty('bookmarkedVerses');
    notifyListeners();
    _enqueueWrite(() => _saveToFirestore());
  }

  bool isVerseBookmarked(String ref) {
    return _bookmarkedVerseRefs.contains(ref);
  }


  void setTabIndex(int index) {
    _tabIndex = index;
    notifyListeners();
  }

  void setBibleTarget(String bookId, int chapter, [int? verse]) {
    _bibleBookId = bookId;
    _bibleChapter = chapter;
    _bibleVerse = verse;
    notifyListeners();
  }

  void clearBibleTarget() {
    _bibleBookId = null;
    _bibleChapter = null;
    _bibleVerse = null;
  }

  // --- Real-time Firestore sync listener ---
  void setUserId(String? uid) {
    _userId = uid;
    _userDocSubscription?.cancel();
    _userDocSubscription = null;

    if (uid == null) {
      // Clear data on sign out
      _unlockedLevels.clear();
      _unlockedLevels.add(1);
      _totalXp = 0;
      _streakDays = 0;
      _lastPlayDate = null;
      _dailyChallengeCompleted = false;
      _weeklyChallengeCompleted = false;
      _monthlyChallengeCompleted = false;
      _lastDailyChallengeDate = "";
      _lastWeeklyChallengeReset = "";
      _lastMonthlyChallengeReset = "";
      _quizHighScores.clear();
      _quizPercentages.clear();
      _newlyUnlocked = null;
      _totalDailyChallengesCompleted = 0;
      _masteredFlashcards.clear();
      _averageAnswerTime = 0.0;
      _totalAnswerTimeSpent = 0;
      _totalQuestionsAnswered = 0;
      _completedQuizTopics.clear();
      _weeklyRank = -1;
      _monthlyRank = -1;
      _dailyQuizLevel = null;
      _dailyQuizDate = "";
      _tabIndex = 0;
      _seenSets.clear();
      _completedReadingPlansCount = 0;
      _highestReadingStreak = 0;
      _highestReadingProgress = 0;
      _readingDaysCompleted = 0;
      _completedReadingPlanTypes.clear();
      _displayName = "Guest Player";
      _username = "guest_username";
      _email = "guest@example.com";
      _photoURL = null;
      _phoneNumber = null;
      _authMethod = "anonymous";
      _activeTitle = "";
      _unlockedTitles.clear();
      _unlockedTitles.add("novice");
      _prayersOffered = 0;
      _totalShares = 0;
      _streakBoxesOpened.clear();
      _totalMiracleBoxesOpened = 0;
      _pendingMiracleBox = false;
      _bookmarkedQuestionIds.clear();
      _thisDayQuizCompleted = false;
      _memoryGamesCompleted = 0;
      _liveEventsWon = 0;
      _liveEventsParticipated = 0;
      _battlesWon = 0;
      _battlesLost = 0;
      _battlesPlayed = 0;
      _topicPerformance.clear();
      _weaknessQuizCompleted = false;

      
      // Reset achievements
      for (var a in _achievementsList) {
        a.isUnlocked = false;
        a.currentProgress = 0;
        a.dateUnlocked = null;
      }
      notifyListeners();
    } else {
      // Listen to Firestore document
      _userDocSubscription = FirebaseFirestore.instance.collection('users').doc(uid).snapshots().listen((snapshot) {
        if (snapshot.exists && snapshot.data() != null) {
          _loadFromMap(snapshot.data()!);
        } else {
          // Document does not exist yet (anonymous or legacy first sign-in)
          FirebaseService.createUserProfile(uid, displayName: FirebaseAuth.instance.currentUser?.displayName, email: FirebaseAuth.instance.currentUser?.email);
        }
      }, onError: (e) {
        // ignore: avoid_print
        print("Error listening to user document: $e");
      });
    }
  }

  Future<void> restoreSession(User user) async {
    if (_userId == user.uid) return; // Already restored
    
    _userId = user.uid;
    _displayName = user.displayName ?? '';
    _email = user.email ?? '';
    
    _userDocSubscription?.cancel();
    _userDocSubscription = null;
    
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .get();
    
    if (doc.exists) {
      _loadFromMap(doc.data()!);
    } else {
      await FirebaseService.createUserProfile(
        _userId!,
        displayName: user.displayName,
        email: user.email,
      );
    }
    
    _userDocSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        _loadFromMap(snapshot.data()!);
      }
    }, onError: (e) {
      // ignore: avoid_print
      print("Error listening to user document: $e");
    });
    
    notifyListeners();
  }

  void _loadFromMap(Map<String, dynamic> data) {
    _totalXp = data['totalXp'] ?? 0;
    _streakDays = data['streak'] ?? 0;
    _dailyChallengeCompleted = data['dailyChallengeCompleted'] ?? false;
    _weeklyChallengeCompleted = data['weeklyChallengeCompleted'] ?? false;
    _monthlyChallengeCompleted = data['monthlyChallengeCompleted'] ?? false;
    _lastDailyChallengeDate = data['lastDailyChallengeDate'] ?? "";
    _lastWeeklyChallengeReset = data['lastWeeklyChallengeReset'] ?? "";
    _lastMonthlyChallengeReset = data['lastMonthlyChallengeReset'] ?? "";
    _totalDailyChallengesCompleted = data['totalDailyChallengesCompleted'] ?? 0;
    _averageAnswerTime = (data['averageAnswerTime'] ?? 0.0).toDouble();
    _totalAnswerTimeSpent = data['totalAnswerTimeSpent'] ?? 0;
    _totalQuestionsAnswered = data['totalQuestionsAnswered'] ?? 0;
    _totalShares = data['totalShares'] ?? 0;
    _displayName = data['displayName'] ?? "Guest Player";
    _username = data['username'] ?? "guest_username";
    _email = data['email'] ?? "guest@example.com";
    _photoURL = data['photoURL'];
    _phoneNumber = data['phoneNumber'];
    _authMethod = data['authMethod'] ?? 'anonymous';
    
    _activeTitle = data['activeTitle'] ?? '';
    final titlesList = data['unlockedTitles'] as List?;
    _unlockedTitles.clear();
    if (titlesList != null) {
      _unlockedTitles.addAll(List<String>.from(titlesList));
    }
    if (!_unlockedTitles.contains('novice')) {
      _unlockedTitles.add('novice');
    }
    _prayersOffered = data['prayersOffered'] ?? 0;
    _joinedGroupsCount = data['joinedGroupsCount'] ?? 0;
    _createdGroupsCount = data['createdGroupsCount'] ?? 0;
    _maxGroupSize = data['maxGroupSize'] ?? 0;
    _challengesWon = data['challengesWon'] ?? 0;
    _challengesCreated = data['challengesCreated'] ?? 0;
    _wonChallengeIds = List<String>.from(data['wonChallengeIds'] ?? []);

    if (data['lastPlayDate'] != null) {
      _lastPlayDate = DateTime.tryParse(data['lastPlayDate'].toString());
    } else {
      _lastPlayDate = null;
    }

    final levels = data['unlockedLevels'] as List?;
    _unlockedLevels.clear();
    if (levels != null) {
      _unlockedLevels.addAll(List<int>.from(levels));
    } else {
      _unlockedLevels.add(1);
    }

    final highScores = data['quizHighScores'] as Map?;
    _quizHighScores.clear();
    if (highScores != null) {
      highScores.forEach((k, v) {
        _quizHighScores[k.toString()] = v as int;
      });
    }

    final percentages = data['quizPercentages'] as Map?;
    _quizPercentages.clear();
    if (percentages != null) {
      percentages.forEach((k, v) {
        _quizPercentages[k.toString()] = v as int;
      });
    }

    final mastered = data['masteredFlashcards'] as List?;
    _masteredFlashcards.clear();
    if (mastered != null) {
      _masteredFlashcards.addAll(List<String>.from(mastered));
    }

    final topics = data['completedQuizTopics'] as List?;
    _completedQuizTopics.clear();
    if (topics != null) {
      _completedQuizTopics.addAll(List<String>.from(topics));
    }

    final seenSetsMap = data['seenSets'] as Map?;
    _seenSets.clear();
    if (seenSetsMap != null) {
      seenSetsMap.forEach((key, value) {
        final level = int.tryParse(key.toString());
        if (level != null) {
          _seenSets[level] = Set<String>.from(List<String>.from(value));
        }
      });
    }

    _completedReadingPlansCount = data['completedReadingPlansCount'] ?? 0;
    _highestReadingStreak = data['highestReadingStreak'] ?? 0;
    _highestReadingProgress = data['highestReadingProgress'] ?? 0;
    _readingDaysCompleted = data['readingDaysCompleted'] ?? 0;
    final planTypes = data['completedReadingPlanTypes'] as List?;
    _completedReadingPlanTypes.clear();
    if (planTypes != null) {
      _completedReadingPlanTypes.addAll(List<String>.from(planTypes));
    }

    final strBoxes = data['streakBoxesOpened'] as List?;
    _streakBoxesOpened.clear();
    if (strBoxes != null) {
      _streakBoxesOpened.addAll(List<int>.from(strBoxes));
    }
    _totalMiracleBoxesOpened = data['totalMiracleBoxesOpened'] ?? 0;
    _pendingMiracleBox = data['pendingMiracleBox'] ?? false;

    final bkmarks = data['bookmarkedQuestions'] as List?;
    _bookmarkedQuestionIds.clear();
    if (bkmarks != null) {
      _bookmarkedQuestionIds.addAll(List<String>.from(bkmarks));
    }

    final bkmarkVerses = data['bookmarkedVerses'] as List?;
    _bookmarkedVerseRefs.clear();
    if (bkmarkVerses != null) {
      _bookmarkedVerseRefs.addAll(List<String>.from(bkmarkVerses));
    }
    _thisDayQuizCompleted = data['thisDayQuizCompleted'] ?? false;
    _memoryGamesCompleted = data['memoryGamesCompleted'] ?? 0;
    _liveEventsWon = data['liveEventsWon'] ?? 0;
    _liveEventsParticipated = data['liveEventsParticipated'] ?? 0;
    _battlesWon = data['battlesWon'] ?? 0;
    _battlesLost = data['battlesLost'] ?? 0;
    _battlesPlayed = data['battlesPlayed'] ?? 0;
    _weaknessQuizCompleted = data['weaknessQuizCompleted'] ?? false;

    if (data['topicPerformance'] != null) {
      final Map<String, dynamic> rawMap = data['topicPerformance'];
      _topicPerformance = {};
      rawMap.forEach((k, v) {
        if (v is num) {
          _topicPerformance[k] = v.toDouble();
        } else if (v is List) {
          if (v.isNotEmpty) {
            double sum = 0;
            for (var item in v) {
              if (item is num) sum += item;
            }
            _topicPerformance[k] = sum / v.length;
          }
        }
      });
    } else {
      _topicPerformance = {};
    }

    if (data['topicPerformanceCounts'] != null) {
      final Map<String, dynamic> rawMap = data['topicPerformanceCounts'];
      _topicPerformanceCounts = rawMap.map((k, v) => MapEntry(k, v as int));
    } else {
      _topicPerformanceCounts = {};
    }


    final achs = data['achievements'] as List?;
    if (achs != null) {
      for (var item in achs) {
        final map = Map<String, dynamic>.from(item);
        final id = map['id'];
        final idx = _achievementsList.indexWhere((a) => a.id == id);
        if (idx >= 0) {
          _achievementsList[idx].isUnlocked = map['isUnlocked'] ?? false;
          _achievementsList[idx].currentProgress = map['currentProgress'] ?? 0;
          if (map['dateUnlocked'] != null) {
            _achievementsList[idx].dateUnlocked = DateTime.tryParse(map['dateUnlocked']);
          }
        }
      }
    }

    checkAndResetChallenges();
    notifyListeners();
  }

  Future<void> _saveToFirestore() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    if (_dirtyFields.isEmpty) return;

    final updates = <String, dynamic>{};
    for (final field in _dirtyFields) {
      switch (field) {
        case 'totalXp':
          updates['totalXp'] = _totalXp;
          break;
        case 'unlockedLevels':
          updates['unlockedLevels'] = _unlockedLevels.toList();
          break;
        case 'streak':
          updates['streak'] = _streakDays;
          break;
        case 'lastPlayDate':
          updates['lastPlayDate'] = _lastPlayDate?.toIso8601String();
          break;
        case 'dailyChallengeCompleted':
          updates['dailyChallengeCompleted'] = _dailyChallengeCompleted;
          break;
        case 'weeklyChallengeCompleted':
          updates['weeklyChallengeCompleted'] = _weeklyChallengeCompleted;
          break;
        case 'monthlyChallengeCompleted':
          updates['monthlyChallengeCompleted'] = _monthlyChallengeCompleted;
          break;
        case 'lastDailyChallengeDate':
          updates['lastDailyChallengeDate'] = _lastDailyChallengeDate;
          break;
        case 'lastWeeklyChallengeReset':
          updates['lastWeeklyChallengeReset'] = _lastWeeklyChallengeReset;
          break;
        case 'lastMonthlyChallengeReset':
          updates['lastMonthlyChallengeReset'] = _lastMonthlyChallengeReset;
          break;
        case 'totalDailyChallengesCompleted':
          updates['totalDailyChallengesCompleted'] = _totalDailyChallengesCompleted;
          break;
        case 'quizHighScores':
          updates['quizHighScores'] = Map<String, dynamic>.from(_quizHighScores);
          break;
        case 'quizPercentages':
          updates['quizPercentages'] = Map<String, dynamic>.from(_quizPercentages);
          break;
        case 'masteredFlashcards':
          updates['masteredFlashcards'] = _masteredFlashcards.toList();
          break;
        case 'completedQuizTopics':
          updates['completedQuizTopics'] = _completedQuizTopics.toList();
          break;
        case 'seenSets':
          updates['seenSets'] = _seenSets.map((k, v) => MapEntry(k.toString(), v.toList()));
          break;
        case 'completedReadingPlansCount':
          updates['completedReadingPlansCount'] = _completedReadingPlansCount;
          break;
        case 'highestReadingStreak':
          updates['highestReadingStreak'] = _highestReadingStreak;
          break;
        case 'highestReadingProgress':
          updates['highestReadingProgress'] = _highestReadingProgress;
          break;
        case 'readingDaysCompleted':
          updates['readingDaysCompleted'] = _readingDaysCompleted;
          break;
        case 'completedReadingPlanTypes':
          updates['completedReadingPlanTypes'] = _completedReadingPlanTypes.toList();
          break;
        case 'streakBoxesOpened':
          updates['streakBoxesOpened'] = _streakBoxesOpened;
          break;
        case 'totalMiracleBoxesOpened':
          updates['totalMiracleBoxesOpened'] = _totalMiracleBoxesOpened;
          break;
        case 'pendingMiracleBox':
          updates['pendingMiracleBox'] = _pendingMiracleBox;
          break;
        case 'bookmarkedQuestions':
          updates['bookmarkedQuestions'] = _bookmarkedQuestionIds.toList();
          break;
        case 'bookmarkedVerses':
          updates['bookmarkedVerses'] = _bookmarkedVerseRefs.toList();
          break;
        case 'thisDayQuizCompleted':
          updates['thisDayQuizCompleted'] = _thisDayQuizCompleted;
          break;
        case 'memoryGamesCompleted':
          updates['memoryGamesCompleted'] = _memoryGamesCompleted;
          break;
        case 'liveEventsWon':
          updates['liveEventsWon'] = _liveEventsWon;
          break;
        case 'liveEventsParticipated':
          updates['liveEventsParticipated'] = _liveEventsParticipated;
          break;
        case 'battlesWon':
          updates['battlesWon'] = _battlesWon;
          break;
        case 'battlesLost':
          updates['battlesLost'] = _battlesLost;
          break;
        case 'battlesPlayed':
          updates['battlesPlayed'] = _battlesPlayed;
          break;
        case 'topicPerformance':
          updates['topicPerformance'] = _topicPerformance;
          break;
        case 'topicPerformanceCounts':
          updates['topicPerformanceCounts'] = _topicPerformanceCounts;
          break;
        case 'weaknessQuizCompleted':
          updates['weaknessQuizCompleted'] = _weaknessQuizCompleted;
          break;

        case 'achievements':
          updates['achievements'] = _achievementsList.map((a) => a.toMap()).toList();
          break;
        case 'averageAnswerTime':
          updates['averageAnswerTime'] = _averageAnswerTime;
          break;
        case 'totalAnswerTimeSpent':
          updates['totalAnswerTimeSpent'] = _totalAnswerTimeSpent;
          break;
        case 'totalQuestionsAnswered':
          updates['totalQuestionsAnswered'] = _totalQuestionsAnswered;
          break;
        case 'totalShares':
          updates['totalShares'] = _totalShares;
          break;
        case 'phoneNumber':
          updates['phoneNumber'] = _phoneNumber;
          break;
        case 'authMethod':
          updates['authMethod'] = _authMethod;
          break;
        case 'activeTitle':
          updates['activeTitle'] = _activeTitle;
          break;
        case 'unlockedTitles':
          updates['unlockedTitles'] = _unlockedTitles;
          break;
        case 'joinedGroupsCount':
          updates['joinedGroupsCount'] = _joinedGroupsCount;
          break;
        case 'createdGroupsCount':
          updates['createdGroupsCount'] = _createdGroupsCount;
          break;
        case 'maxGroupSize':
          updates['maxGroupSize'] = _maxGroupSize;
          break;
        case 'challengesWon':
          updates['challengesWon'] = _challengesWon;
          break;
        case 'challengesCreated':
          updates['challengesCreated'] = _challengesCreated;
          break;
        case 'wonChallengeIds':
          updates['wonChallengeIds'] = _wonChallengeIds;
          break;
      }
    }

    _dirtyFields.clear();

    if (updates.isEmpty) return;

    try {
      final batch = FirebaseFirestore.instance.batch();
      final docRef = FirebaseFirestore.instance.collection('users').doc(uid);
      batch.set(docRef, updates, SetOptions(merge: true));
      await batch.commit();
    } catch (e) {
      // ignore: avoid_print
      print("Error saving user state to Firestore: $e");
    }
  }

  void addXp(int xp) {
    _totalXp += xp;
    _markDirty('totalXp');
    checkAchievements();
    notifyListeners();
    _enqueueWrite(() => _saveToFirestore());
  }

  void unlockNextLevel(int completedLevel) {
    if (completedLevel < 100) {
      _unlockedLevels.add(completedLevel + 1);
      _markDirty('unlockedLevels');
      checkAchievements();
      notifyListeners();
      _enqueueWrite(() => _saveToFirestore());
    }
  }

  int get totalShares => _totalShares;

  void recordShare() {
    _totalShares++;
    _markDirty('totalShares');
    checkAchievements();
    notifyListeners();
    _enqueueWrite(() => _saveToFirestore());
  }

  void submitQuizResult(String quizId, int score, int percentage) {
    final prevHighScore = _quizHighScores[quizId] ?? 0;
    if (score > prevHighScore) {
      _quizHighScores[quizId] = score;
      _markDirty('quizHighScores');
    }

    final prevPercentage = _quizPercentages[quizId] ?? 0;
    if (percentage > prevPercentage) {
      _quizPercentages[quizId] = percentage;
      _markDirty('quizPercentages');
    }
    
    updateStreak();
    checkAchievements();
    notifyListeners();
    _enqueueWrite(() => _saveToFirestore());
  }

  void completeQuiz(String quizId, int score, int percentage, int timeSpentSeconds, int questionsCount, List<String> topics) {
    final prevHighScore = _quizHighScores[quizId] ?? 0;
    if (score > prevHighScore) {
      _quizHighScores[quizId] = score;
      _markDirty('quizHighScores');
    }

    final prevPercentage = _quizPercentages[quizId] ?? 0;
    if (percentage > prevPercentage) {
      _quizPercentages[quizId] = percentage;
      _markDirty('quizPercentages');
    }

    if (questionsCount > 0) {
      _totalAnswerTimeSpent += timeSpentSeconds;
      _totalQuestionsAnswered += questionsCount;
      _averageAnswerTime = _totalAnswerTimeSpent / _totalQuestionsAnswered;
      _markDirty('totalAnswerTimeSpent');
      _markDirty('totalQuestionsAnswered');
      _markDirty('averageAnswerTime');
    }

    if (topics.isNotEmpty) {
      for (var topic in topics) {
        _completedQuizTopics.add(topic);
      }
      _markDirty('completedQuizTopics');
    }
    
    updateStreak();
    checkAchievements();
    notifyListeners();
    _enqueueWrite(() => _saveToFirestore());
  }

  void completeDailyChallenge(int bonusXp) {
    _dailyChallengeCompleted = true;
    _totalDailyChallengesCompleted += 1;
    _totalXp += bonusXp;
    _markDirty('dailyChallengeCompleted');
    _markDirty('totalDailyChallengesCompleted');
    _markDirty('totalXp');
    updateStreak();
    checkAchievements();
    notifyListeners();
    _enqueueWrite(() => _saveToFirestore());
  }

  void completeWeeklyChallenge(int bonusXp) {
    _weeklyChallengeCompleted = true;
    _totalXp += bonusXp;
    _markDirty('weeklyChallengeCompleted');
    _markDirty('totalXp');
    updateStreak();
    checkAchievements();
    notifyListeners();
    _enqueueWrite(() => _saveToFirestore());
  }

  void completeMonthlyChallenge(int bonusXp) {
    _monthlyChallengeCompleted = true;
    _totalXp += bonusXp;
    _markDirty('monthlyChallengeCompleted');
    _markDirty('totalXp');
    updateStreak();
    checkAchievements();
    notifyListeners();
    _enqueueWrite(() => _saveToFirestore());
  }

  DateTime getStartOfCurrentWeeklyChallengePeriod(DateTime now) {
    int daysFromSaturday = now.weekday - DateTime.saturday;
    if (daysFromSaturday < 0) {
      daysFromSaturday += 7;
    }
    DateTime lastSaturday8PM = DateTime(now.year, now.month, now.day, 20, 0, 0).subtract(Duration(days: daysFromSaturday));
    if (lastSaturday8PM.isAfter(now)) {
      lastSaturday8PM = lastSaturday8PM.subtract(const Duration(days: 7));
    }
    return lastSaturday8PM;
  }

  String getStartOfCurrentMonthlyChallengePeriod(DateTime now) {
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    return firstDayOfMonth.toIso8601String().substring(0, 10);
  }

  void checkAndResetChallenges() {
    final now = DateTime.now();
    final todayStr = now.toIso8601String().substring(0, 10);
    bool changed = false;
    bool resetDaily = false;
    bool resetWeekly = false;
    bool resetMonthly = false;

    if (_lastDailyChallengeDate != todayStr) {
      resetDaily = true;
      changed = true;
    }

    final currentPeriodStart = getStartOfCurrentWeeklyChallengePeriod(now).toIso8601String();
    if (_lastWeeklyChallengeReset != currentPeriodStart) {
      resetWeekly = true;
      changed = true;
    }

    final currentMonthlyPeriodStart = getStartOfCurrentMonthlyChallengePeriod(now);
    if (_lastMonthlyChallengeReset != currentMonthlyPeriodStart) {
      resetMonthly = true;
      changed = true;
    }

    if (changed) {
      Future.microtask(() {
        if (resetDaily) {
          _lastDailyChallengeDate = todayStr;
          _dailyChallengeCompleted = false;
          _thisDayQuizCompleted = false;
          _weaknessQuizCompleted = false;
          _markDirty('lastDailyChallengeDate');
          _markDirty('dailyChallengeCompleted');
          _markDirty('thisDayQuizCompleted');
          _markDirty('weaknessQuizCompleted');
        }

        if (resetWeekly) {
          _lastWeeklyChallengeReset = currentPeriodStart;
          _weeklyChallengeCompleted = false;
          _markDirty('lastWeeklyChallengeReset');
          _markDirty('weeklyChallengeCompleted');
        }
        if (resetMonthly) {
          _lastMonthlyChallengeReset = currentMonthlyPeriodStart;
          _monthlyChallengeCompleted = false;
          _markDirty('lastMonthlyChallengeReset');
          _markDirty('monthlyChallengeCompleted');
        }
        notifyListeners();
        _enqueueWrite(() => _saveToFirestore());
      });
    }
  }

  void markFlashcardMastered(String cardId, bool isMastered) {
    if (isMastered) {
      _masteredFlashcards.add(cardId);
    } else {
      _masteredFlashcards.remove(cardId);
    }
    _markDirty('masteredFlashcards');
    checkAchievements();
    notifyListeners();
    _enqueueWrite(() => _saveToFirestore());
  }

  void updateStreak() {
    final now = DateTime.now();
    if (_lastPlayDate == null) {
      _streakDays = 1;
    } else {
      final difference = now.difference(_lastPlayDate!).inDays;
      if (difference == 1) {
        _streakDays += 1;
      } else if (difference > 1) {
        _streakDays = 1;
      }
    }
    _lastPlayDate = now;
    _markDirty('streak');
    _markDirty('lastPlayDate');

    if (_streakDays % 7 == 0 && _streakDays > 0 && !_streakBoxesOpened.contains(_streakDays)) {
      _pendingMiracleBox = true;
      _markDirty('pendingMiracleBox');
    }

    checkAchievements();
  }


  void resetDailyChallenge() {
    _dailyChallengeCompleted = false;
    _markDirty('dailyChallengeCompleted');
    notifyListeners();
    _enqueueWrite(() => _saveToFirestore());
  }

  void claimMiracleBox(int xpReward) {
    _pendingMiracleBox = false;
    if (!_streakBoxesOpened.contains(_streakDays)) {
      _streakBoxesOpened.add(_streakDays);
    }
    _totalMiracleBoxesOpened++;
    _markDirty('pendingMiracleBox');
    _markDirty('streakBoxesOpened');
    _markDirty('totalMiracleBoxesOpened');
    addXp(xpReward);
    checkAchievements();
    notifyListeners();
    _enqueueWrite(() => _saveToFirestore());
  }

  void toggleBookmark(String questionId) {
    if (_bookmarkedQuestionIds.contains(questionId)) {
      _bookmarkedQuestionIds.remove(questionId);
    } else {
      _bookmarkedQuestionIds.add(questionId);
    }
    _markDirty('bookmarkedQuestions');
    notifyListeners();
    _enqueueWrite(() => _saveToFirestore());
  }

  bool isBookmarked(String questionId) {
    return _bookmarkedQuestionIds.contains(questionId);
  }

  void incrementJoinedGroups() {
    _joinedGroupsCount++;
    _markDirty('joinedGroupsCount');
    checkAchievements();
    notifyListeners();
    _enqueueWrite(() => _saveToFirestore());
  }

  void decrementJoinedGroups() {
    if (_joinedGroupsCount > 0) {
      _joinedGroupsCount--;
      _markDirty('joinedGroupsCount');
      checkAchievements();
      notifyListeners();
      _enqueueWrite(() => _saveToFirestore());
    }
  }

  void incrementCreatedGroups() {
    _createdGroupsCount++;
    _markDirty('createdGroupsCount');
    checkAchievements();
    notifyListeners();
    _enqueueWrite(() => _saveToFirestore());
  }

  void updateMaxGroupSize(int size) {
    if (size > _maxGroupSize) {
      _maxGroupSize = size;
      _markDirty('maxGroupSize');
      checkAchievements();
      notifyListeners();
      _enqueueWrite(() => _saveToFirestore());
    }
  }

  void recordChallengeWin(String challengeId) {
    if (!_wonChallengeIds.contains(challengeId)) {
      _wonChallengeIds.add(challengeId);
      _challengesWon = _wonChallengeIds.length;
      _markDirty('wonChallengeIds');
      _markDirty('challengesWon');
      checkAchievements();
      notifyListeners();
      _enqueueWrite(() => _saveToFirestore());
    }
  }

  void incrementChallengesCreated() {
    _challengesCreated++;
    _markDirty('challengesCreated');
    checkAchievements();
    notifyListeners();
    _enqueueWrite(() => _saveToFirestore());
  }

  List<String> getBookmarkedQuestions() {
    return _bookmarkedQuestionIds.toList();
  }

  void completeThisDayQuiz() {
    _thisDayQuizCompleted = true;
    _markDirty('thisDayQuizCompleted');
    addXp(25);
    notifyListeners();
    _enqueueWrite(() => _saveToFirestore());
  }


  void clearNewlyUnlocked() {
    _newlyUnlocked = null;
    notifyListeners();
  }

  void updateReadingStats({
    required int streak,
    required int progressPercent,
    required int totalDaysCompleted,
    String? finishedPlanType,
  }) {
    bool changed = false;
    if (streak > _highestReadingStreak) {
      _highestReadingStreak = streak;
      _markDirty('highestReadingStreak');
      changed = true;
    }
    if (progressPercent > _highestReadingProgress) {
      _highestReadingProgress = progressPercent;
      _markDirty('highestReadingProgress');
      changed = true;
    }
    if (totalDaysCompleted > _readingDaysCompleted) {
      _readingDaysCompleted = totalDaysCompleted;
      _markDirty('readingDaysCompleted');
      changed = true;
    }
    if (finishedPlanType != null && !_completedReadingPlanTypes.contains(finishedPlanType)) {
      _completedReadingPlanTypes.add(finishedPlanType);
      _completedReadingPlansCount = _completedReadingPlanTypes.length;
      _markDirty('completedReadingPlanTypes');
      _markDirty('completedReadingPlansCount');
      changed = true;
    }
    
    if (changed) {
      checkAchievements();
      notifyListeners();
      _enqueueWrite(() => _saveToFirestore());
    }
  }

  void updateWeeklyRank(int rank) {
    _weeklyRank = rank;
    checkAchievements();
    notifyListeners();
    _enqueueWrite(() => _saveToFirestore());
  }

  void updateMonthlyRank(int rank) {
    _monthlyRank = rank;
    checkAchievements();
    notifyListeners();
    _enqueueWrite(() => _saveToFirestore());
  }

  int getDailyQuizLevel() {
    final todayStr = DateTime.now().toIso8601String().substring(0, 10);
    if (_dailyQuizDate != todayStr || _dailyQuizLevel == null) {
      _dailyQuizDate = todayStr;
      _dailyQuizLevel = Random().nextInt(100) + 1;
      _dailyChallengeCompleted = false;
      _markDirty('dailyChallengeCompleted');
      notifyListeners();
      _enqueueWrite(() => _saveToFirestore());
    }
    return _dailyQuizLevel!;
  }

  void checkAchievements() {
    bool anyNewUnlock = false;

    for (var achievement in _achievementsList) {
      if (achievement.isUnlocked) continue;

      int progress = 0;
      bool meetsCondition = false;

      switch (achievement.type) {
        case 'milestone':
          progress = _quizHighScores.length;
          meetsCondition = progress >= achievement.requiredCount;
          break;
        case 'perfect_score':
          progress = _quizPercentages.values.any((p) => p == 100) ? 1 : 0;
          meetsCondition = progress >= achievement.requiredCount;
          break;
        case 'streak':
          progress = _streakDays;
          meetsCondition = progress >= achievement.requiredCount;
          break;
        case 'level_unlocked':
          progress = playerLevel;
          meetsCondition = progress >= achievement.requiredCount;
          break;
        case 'speed':
          progress = _averageAnswerTime > 0 ? _averageAnswerTime.round() : 999;
          meetsCondition = _averageAnswerTime > 0 && _averageAnswerTime <= achievement.requiredCount;
          break;
        case 'topic_mastery':
          if (achievement.id == "topic_genesis") {
            int completedCount = 0;
            for (int lvl = 1; lvl <= 5; lvl++) {
              if (_quizHighScores.containsKey('level_$lvl')) {
                completedCount++;
              }
            }
            progress = completedCount;
            meetsCondition = completedCount >= 5;
          } else if (achievement.id == "topic_exodus") {
            int completedCount = 0;
            for (int lvl = 6; lvl <= 10; lvl++) {
              if (_quizHighScores.containsKey('level_$lvl')) {
                completedCount++;
              }
            }
            progress = completedCount;
            meetsCondition = completedCount >= 5;
          }
          break;
        case 'flashcard_mastery':
          progress = _masteredFlashcards.length;
          meetsCondition = progress >= achievement.requiredCount;
          break;
        case 'daily_challenge':
          progress = _totalDailyChallengesCompleted;
          meetsCondition = progress >= achievement.requiredCount;
          break;
        case 'weekly_leaderboard':
          if (achievement.id == "weekly_champion_1st") {
            progress = (_weeklyRank == 1) ? 1 : 0;
          } else if (achievement.id == "weekly_champion_2nd") {
            progress = (_weeklyRank == 2) ? 1 : 0;
          } else if (achievement.id == "weekly_champion_3rd") {
            progress = (_weeklyRank == 3) ? 1 : 0;
          }
          meetsCondition = progress >= achievement.requiredCount;
          break;
        case 'monthly_leaderboard':
          if (achievement.id == "monthly_champion_1st") {
            progress = (_monthlyRank == 1) ? 1 : 0;
          } else if (achievement.id == "monthly_champion_2nd") {
            progress = (_monthlyRank == 2) ? 1 : 0;
          } else if (achievement.id == "monthly_champion_3rd") {
            progress = (_monthlyRank == 3) ? 1 : 0;
          }
          meetsCondition = progress >= achievement.requiredCount;
          break;
        case 'reading_streak':
          progress = _highestReadingStreak;
          meetsCondition = progress >= achievement.requiredCount;
          break;
        case 'reading_milestone':
          if (achievement.id == "reading_start") {
            progress = _readingDaysCompleted;
            meetsCondition = progress >= achievement.requiredCount;
          } else if (achievement.id == "reading_progress_50") {
            progress = _highestReadingProgress;
            meetsCondition = progress >= achievement.requiredCount;
          } else if (achievement.id == "reading_plan_finish") {
            progress = _completedReadingPlansCount;
            meetsCondition = progress >= 1;
          } else if (achievement.id == "reading_scholar") {
            progress = _completedReadingPlansCount;
            meetsCondition = progress >= achievement.requiredCount;
          }
          break;
        case 'share':
          progress = _totalShares;
          meetsCondition = progress >= achievement.requiredCount;
          break;
        case 'miracle_box':
          progress = _totalMiracleBoxesOpened;
          meetsCondition = progress >= achievement.requiredCount;
          break;
        case 'memory_game':
          progress = _memoryGamesCompleted;
          meetsCondition = progress >= achievement.requiredCount;
          break;
        case 'live_event_win':
          progress = _liveEventsWon;
          meetsCondition = progress >= achievement.requiredCount;
          break;
        case 'live_event_participate':
          progress = _liveEventsParticipated;
          meetsCondition = progress >= achievement.requiredCount;
          break;
        case 'battle_win':
          progress = _battlesWon;
          meetsCondition = progress >= achievement.requiredCount;
          break;
        case 'wisdom_tree':
          if (achievement.id == 'wisdom_tree_mature') {
            progress = _totalXp >= 5001 ? 1 : 0;
            meetsCondition = _totalXp >= 5001;
          } else if (achievement.id == 'wisdom_tree_fruitful') {
            int fruitCount = 0;
            _topicPerformance.forEach((k, v) {
              if (v > 0.9) fruitCount++;
            });
            progress = fruitCount;
            meetsCondition = fruitCount >= 3;
          } else if (achievement.id == 'wisdom_tree_full_bloom') {
            int bloomCount = 0;
            final groups = ['Torah', 'History', 'Wisdom', 'Prophets', 'Gospels', 'Acts & Epistles', 'Revelation'];
            for (final g in groups) {
              final score = _topicPerformance[g] ?? 0.0;
              if (score >= 0.6) bloomCount++;
            }
            progress = bloomCount;
            meetsCondition = bloomCount >= 7;
          }
          break;
        case 'church_groups':
          if (achievement.id == "fellowship") {
            progress = _joinedGroupsCount;
          } else if (achievement.id == "group_leader") {
            progress = _createdGroupsCount;
          } else if (achievement.id == "community_builder") {
            progress = _maxGroupSize;
          } else if (achievement.id == "challenge_champion") {
            progress = _challengesWon;
          } else if (achievement.id == "shepherd") {
            progress = _challengesCreated;
          }
          meetsCondition = progress >= achievement.requiredCount;
          break;
      }

      if (achievement.currentProgress != progress) {
        achievement.currentProgress = progress;
        _markDirty('achievements');
      }
      if (meetsCondition && !achievement.isUnlocked) {
        achievement.isUnlocked = true;
        achievement.dateUnlocked = DateTime.now();
        _newlyUnlocked = achievement;
        anyNewUnlock = true;
        _markDirty('achievements');
      }
    }

    if (anyNewUnlock) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }

    // Check titles after achievements check
    checkTitleUnlocks();
  }

  bool isTitleUnlocked(String titleId) {
    switch (titleId) {
      case 'novice':
        return true;
      case 'intercessor':
        return _prayersOffered >= 1;
      case 'dedicated':
        return _streakDays >= 7;
      case 'flawless':
        return _quizPercentages.values.any((p) => p == 100);
      case 'speed_demon':
        return _averageAnswerTime > 0 && _averageAnswerTime < 5.0 && _totalQuestionsAnswered >= 10;
      case 'quiz_master':
        return playerLevel >= 25 || _quizHighScores.length >= 50;
      case 'bible_scholar':
        return _completedReadingPlansCount >= 3;
      case 'lightning':
        return _averageAnswerTime > 0 && _averageAnswerTime < 3.0 && _totalQuestionsAnswered >= 10;
      case 'unstoppable':
        return _streakDays >= 30;
      default:
        return false;
    }
  }

  void checkTitleUnlocks() {
    bool unlockedAny = false;
    for (final title in ProfileTitle.allTitles) {
      if (!_unlockedTitles.contains(title.id)) {
        if (isTitleUnlocked(title.id)) {
          _unlockedTitles.add(title.id);
          unlockedAny = true;

          // Create dynamic newly unlocked title achievement notification
          final dummyAchievement = Achievement(
            id: 'title_${title.id}',
            title: title.name, // Display title name in dialog
            description: title.description,
            type: 'milestone',
            requiredCount: 1,
            icon: Icons.workspace_premium_rounded,
            isUnlocked: true,
            currentProgress: 1,
            dateUnlocked: DateTime.now(),
          );
          _newlyUnlocked = dummyAchievement;
        }
      }
    }
    if (unlockedAny) {
      _markDirty('unlockedTitles');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
      _enqueueWrite(() => _saveToFirestore());
    }
  }

  void setActiveTitle(String title) {
    if (_activeTitle == title) return;
    if (_unlockedTitles.contains(title) || title.isEmpty) {
      _activeTitle = title;
      _markDirty('activeTitle');
      notifyListeners();
      _enqueueWrite(() => FirebaseService.updateActiveTitle(_userId!, title));
    }
  }

  void completeMemoryGame() {
    _memoryGamesCompleted++;
    _markDirty('memoryGamesCompleted');
    checkAchievements();
    notifyListeners();
    _enqueueWrite(() => _saveToFirestore());
  }

  void recordLiveEventParticipation() {
    _liveEventsParticipated++;
    _markDirty('liveEventsParticipated');
    checkAchievements();
    notifyListeners();
    _enqueueWrite(() => _saveToFirestore());
  }

  void recordLiveEventWin() {
    _liveEventsWon++;
    _markDirty('liveEventsWon');
    checkAchievements();
    notifyListeners();
    _enqueueWrite(() => _saveToFirestore());
  }

  void recordBattleResult(bool won) {
    _battlesPlayed++;
    if (won) {
      _battlesWon++;
    } else {
      _battlesLost++;
    }
    _markDirty('battlesPlayed');
    _markDirty('battlesWon');
    _markDirty('battlesLost');
    checkAchievements();
    notifyListeners();
    _enqueueWrite(() => _saveToFirestore());
  }

  void updateTopicPerformance(String bookId, double score) {
    final topicGroup = getTopicGroup(bookId);
    final currentAvg = _topicPerformance[topicGroup] ?? 0.0;
    final currentCount = _topicPerformanceCounts[topicGroup] ?? 0;
    
    final newAvg = (currentAvg * currentCount + score) / (currentCount + 1);
    
    _topicPerformance[topicGroup] = newAvg;
    _topicPerformanceCounts[topicGroup] = currentCount + 1;
    
    _markDirty('topicPerformance');
    _markDirty('topicPerformanceCounts');
    checkAchievements();
    notifyListeners();
    _enqueueWrite(() => _saveToFirestore());
  }

  String getTopicGroup(String bookId) {
    final lbook = bookId.toLowerCase().replaceAll(' ', '');
    if (const ['genesis', 'exodus', 'leviticus', 'numbers', 'deuteronomy'].contains(lbook)) {
      return 'Torah';
    }
    if (const ['joshua', 'judges', 'ruth', '1samuel', '2samuel', '1kings', '2kings', '1chronicles', '2chronicles', 'ezra', 'nehemiah', 'esther'].contains(lbook)) {
      return 'History';
    }
    if (const ['job', 'psalms', 'proverbs', 'ecclesiastes', 'songofsolomon'].contains(lbook)) {
      return 'Wisdom';
    }
    if (const ['isaiah', 'jeremiah', 'lamentations', 'ezekiel', 'daniel', 'hosea', 'joel', 'amos', 'obadiah', 'jonah', 'micah', 'nahum', 'habakkuk', 'zephaniah', 'haggai', 'zechariah', 'malachi'].contains(lbook)) {
      return 'Prophets';
    }
    if (const ['matthew', 'mark', 'luke', 'john'].contains(lbook)) {
      return 'Gospels';
    }
    if (const ['acts', 'romans', '1corinthians', '2corinthians', 'galatians', 'ephesians', 'philippians', 'colossians', '1thessalonians', '2thessalonians', '1timothy', '2timothy', 'titus', 'philemon', 'hebrews', 'james', '1peter', '2peter', '1john', '2john', '3john', 'jude'].contains(lbook)) {
      return 'Acts & Epistles';
    }
    if (lbook == 'revelation') {
      return 'Revelation';
    }
    return 'Torah'; // Fallback
  }

  String? extractBookIdFromReference(String reference) {
    if (reference.isEmpty) return null;
    final lastSpaceIdx = reference.lastIndexOf(RegExp(r'\s+\d+'));
    if (lastSpaceIdx == -1) {
      return _findBookIdByName(reference.trim());
    }
    final bookName = reference.substring(0, lastSpaceIdx).trim();
    return _findBookIdByName(bookName);
  }

  String? _findBookIdByName(String name) {
    final lname = name.toLowerCase().replaceAll(' ', '').replaceAll('&', 'and');
    for (final book in BibleService.getAllBooks()) {
      if (book.nameEn.toLowerCase().replaceAll(' ', '') == lname) return book.id;
      if (book.nameTe == name) return book.id;
      if (book.id == lname) return book.id;
    }
    return null;
  }

  Set<String> parseBookIdsFromText(String text) {
    final Set<String> bookIds = {};
    if (text.isEmpty) return bookIds;
    
    String tempText = text.toLowerCase()
      .replaceAll('1st', '1')
      .replaceAll('2nd', '2')
      .replaceAll('3rd', '3')
      .replaceAll('&', 'and')
      .replaceAll('and', ' ');
      
    final sortedBooks = List<BibleBook>.from(BibleService.getAllBooks())
      ..sort((a, b) => b.nameEn.length.compareTo(a.nameEn.length));
      
    for (final book in sortedBooks) {
      final nameLower = book.nameEn.toLowerCase().replaceAll('&', 'and');
      if (tempText.contains(nameLower)) {
        bookIds.add(book.id);
        tempText = tempText.replaceAll(nameLower, ' ');
      } else if (tempText.contains(book.id)) {
        bookIds.add(book.id);
        tempText = tempText.replaceAll(book.id, ' ');
      }
    }
    return bookIds;
  }

  Map<String, dynamic> getTreeGrowthProgress() {
    final xp = _totalXp;
    String stage = 'Seedling';
    int minXp = 0;
    int maxXp = 100;
    String nextStage = 'Sprout';
    
    if (xp <= 100) {
      stage = 'Seedling';
      minXp = 0;
      maxXp = 100;
      nextStage = 'Sprout';
    } else if (xp <= 500) {
      stage = 'Sprout';
      minXp = 101;
      maxXp = 500;
      nextStage = 'Young Tree';
    } else if (xp <= 2000) {
      stage = 'Young Tree';
      minXp = 501;
      maxXp = 2000;
      nextStage = 'Growing Tree';
    } else if (xp <= 5000) {
      stage = 'Growing Tree';
      minXp = 2001;
      maxXp = 5000;
      nextStage = 'Mature Tree';
    } else if (xp <= 10000) {
      stage = 'Mature Tree';
      minXp = 5001;
      maxXp = 10000;
      nextStage = 'Flourishing Tree';
    } else {
      stage = 'Flourishing Tree';
      minXp = 10001;
      maxXp = 10000;
      nextStage = '';
    }
    
    double percent = 1.0;
    if (maxXp > minXp) {
      percent = ((xp - minXp) / (maxXp - minXp)).clamp(0.0, 1.0);
    }
    
    return {
      'stage': stage,
      'minXp': minXp,
      'maxXp': maxXp,
      'nextStage': nextStage,
      'percent': percent,
    };
  }

  Set<String> getTreeMilestones() {
    final milestones = <String>{};
    if (_streakDays >= 7) milestones.add('golden_leaf');
    if (_streakDays >= 30) milestones.add('dove');
    if (playerLevel >= 25) milestones.add('cross');
    if (playerLevel >= 50) milestones.add('halo');
    if (playerLevel >= 100) milestones.add('rainbow');
    return milestones;
  }

  String? getWeakestTopic() {
    if (_quizHighScores.length < 3) return null;
    String? weakestTopic;
    double lowestAverage = 101.0;
    _topicPerformance.forEach((topic, avg) {
      if (avg < lowestAverage) {
        lowestAverage = avg;
        weakestTopic = topic;
      }
    });
    return weakestTopic;
  }

  Future<List<Question>> generateWeaknessQuiz(String topic) async {
    List<int> levels = [];
    final ltopic = topic.toLowerCase();
    if (ltopic == 'genesis' || ltopic == 'torah') {
      levels = [1, 2, 3, 4, 5];
    } else if (ltopic == 'exodus' || ltopic == 'history') {
      levels = [6, 7, 8, 9, 10];
    } else {
      levels = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
    }

    List<Question> allQuestions = [];
    for (int lvl in levels) {
      for (String set in ['A', 'B', 'C']) {
        final qs = await FirebaseService.getRealQuestions(lvl, set);
        allQuestions.addAll(qs);
      }
    }

    if (allQuestions.isEmpty) {
      return List.generate(5, (index) {
        return Question(
          id: 'weakness_${topic}_$index',
          order: index + 1,
          type: 'multiple_choice',
          timeLimitSeconds: 30,
          points: 1000,
          questionEn: "Question ${index + 1} about $topic",
          questionTe: "$topic గురించిన ప్రశ్న ${index + 1}",
          options: [
            Option(id: 'weakness_opt_a', order: 1, isCorrect: true, textEn: "Correct Answer", textTe: "సరైన సమాధానం"),
            Option(id: 'weakness_opt_b', order: 2, isCorrect: false, textEn: "Incorrect Option 1", textTe: "తప్పు సమాధానం 1"),
            Option(id: 'weakness_opt_c', order: 3, isCorrect: false, textEn: "Incorrect Option 2", textTe: "తప్పు సమాధానం 2"),
            Option(id: 'weakness_opt_d', order: 4, isCorrect: false, textEn: "Incorrect Option 3", textTe: "తప్పు సమాధానం 3"),
          ],
          verseReferenceEn: "Genesis 1:1",
          verseReferenceTe: "ఆదికాండము 1:1",
          explanationEn: "This is the explanation.",
          explanationTe: "ఇది వివరణ.",
        );
      });
    }

    allQuestions.shuffle();
    return allQuestions.take(5).toList();
  }

  void markWeaknessQuizCompleted() {
    _weaknessQuizCompleted = true;
    _markDirty('weaknessQuizCompleted');
    addXp(30);
    notifyListeners();
    _enqueueWrite(() => _saveToFirestore());
  }

  @override
  void dispose() {
    _userDocSubscription?.cancel();
    super.dispose();
  }
}
