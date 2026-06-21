import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../models/quiz.dart';
import '../models/flashcard.dart';
import '../models/prayer_request.dart';
import '../models/referral.dart';
import '../models/church_group.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'real_questions.dart';

class FirebaseService {
  static Future<void> initialize() async {
    if (kDebugMode) {
      print("FirebaseService initialized with real Firebase.");
    }
  }

  static final List<Quiz> _levelQuizzes = _generateInitialQuizzes();

  static List<Quiz> _generateInitialQuizzes() {
    return List<Quiz>.generate(100, (index) {
      final level = index + 1;
      String difficulty;
      if (level <= 33) {
        difficulty = 'easy';
      } else if (level <= 66) {
        difficulty = 'medium';
      } else {
        difficulty = 'hard';
      }
      final List<String> topics = ['Level Challenge', 'Knowledge'];
      if (level <= 5) {
        topics.add('Genesis');
      } else if (level > 5 && level <= 10) {
        topics.add('Exodus');
      }
      return Quiz(
        id: 'level_$level',
        creatorId: 'system',
        titleKey: 'level_quiz_$level',
        bibleVersion: 'BSI Telugu',
        topics: topics,
        isPublic: true,
        questionCount: 12,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        titleEn: 'Level $level Bible Quiz',
        titleTe: 'స్థాయి $level బైబిల్ క్విజ్',
        descriptionEn: 'Test your knowledge on Level $level scriptures!',
        descriptionTe: 'స్థాయి $level లేఖనాలపై మీ జ్ఞానాన్ని పరీక్షించుకోండి!',
        level: level,
        difficulty: difficulty,
      );
    });
  }

  static List<Question> _generateQuestionsForLevel(int level, [String setId = 'A']) {
    final random = Random();
    final points = 1000 + level * 10;

    final List<String> subjectsEn = [
      "Creation", "Noah's Ark", "Abraham's Journey", "Joseph in Egypt",
      "Moses and Exodus", "The Ten Commandments", "Joshua and Jericho", "Samson's Strength",
      "Ruth's Loyalty", "David and Goliath", "Solomon's Wisdom", "Elijah and Fire",
      "Daniel in the Lions' Den", "Jonah and the Fish", "The Birth of Jesus", "John the Baptist",
      "The Sermon on the Mount", "Miracles of Jesus", "Parables of Jesus", "The Crucifixion",
      "The Resurrection", "Pentecost", "Paul's Journeys", "The Armor of God", "The Fruit of the Spirit"
    ];

    final List<String> subjectsTe = [
      "సృష్టి", "నోవహు ఓడ", "అబ్రాహాము ప్రయాణం", "ఐగుప్తులో యోసేపు",
      "మోషే మరియు నిర్గమనం", "పది ఆజ్ఞలు", "యెహోషువ మరియు యెరికో", "సమ్సోను బలం",
      "రూతు విశ్వాస్యత", "దావీదు మరియు గోలియాతు", "సొలొమోను జ్ఞానం", "ఏలీయా మరియు అగ్ని",
      "సింహాల బోనులో దానియేలు", "యోనా మరియు చేప", "యేసు జననం", "బాప్తిస్మమిచ్చు యోహాను",
      "కొండమీది ప్రసంగం", "యేసు అద్భుతాలు", "యేసు ఉపమానాలు", "యేసు సిలువ వేయబడటం",
      "యేసు పునరుث్థానం", "పెంతుకోస్తు", "పౌలు ప్రయాణాలు", "దేవుని సర్వాంగ కవచం", "ఆత్మ ఫలాలు"
    ];

    final List<String> types = ['true_false', 'type_answer'];
    final weightedTypes = [
      ...List.filled(6, 'multiple_choice'),
      ...List.filled(2, 'true_false'),
      ...List.filled(2, 'type_answer'),
      'mixed_format',
      'skills_application',
    ];
    for (int i = 0; i < 10; i++) {
      types.add(weightedTypes[random.nextInt(weightedTypes.length)]);
    }
    types.shuffle(random);

    return List.generate(12, (qIndex) {
      final qNum = qIndex + 1;
      final subjectIndex = (level + qNum) % subjectsEn.length;
      final subjectEn = subjectsEn[subjectIndex];
      final subjectTe = subjectsTe[subjectIndex];

      final type = types[qIndex];
      int timeLimit;
      if (type == 'multiple_choice') {
        timeLimit = 30 + random.nextInt(16);
      } else if (type == 'true_false') {
        timeLimit = 20 + random.nextInt(11);
      } else if (type == 'type_answer') {
        timeLimit = 60 + random.nextInt(31);
      } else if (type == 'mixed_format') {
        timeLimit = 45 + random.nextInt(16);
      } else {
        timeLimit = 60 + random.nextInt(61);
      }

      final questionEn = "Question about $subjectEn for Level $level (Q$qNum) [$type] [Set $setId]";
      final questionTe = "$subjectTe కి సంబంధించిన ప్రశ్న, స్థాయి $level (ప్రశ్న $qNum) [$type] [సెట్ $setId]";
      final explanationEn = "This is the explanation for Level $level Question $qNum Set $setId.";
      final explanationTe = "ఇది స్థాయి $level ప్రశ్న $qNum సెట్ $setId కి సంబంధించిన వివరణ.";

      String? correctAnswerEn;
      String? correctAnswerTe;
      List<Option> options = [];

      if (type == 'multiple_choice' || type == 'mixed_format') {
        final opts = [
          Option(id: 'level_${level}_q${qNum}_${setId}_a', order: 1, isCorrect: true, textEn: 'Correct answer for Q$qNum Set $setId', textTe: 'సరైన సమాధానం Q$qNum సెట్ $setId'),
          Option(id: 'level_${level}_q${qNum}_${setId}_b', order: 2, isCorrect: false, textEn: 'Incorrect Option B', textTe: 'తప్పు సమాధానం B'),
          Option(id: 'level_${level}_q${qNum}_${setId}_c', order: 3, isCorrect: false, textEn: 'Incorrect Option C', textTe: 'తప్పు సమాధానం C'),
          Option(id: 'level_${level}_q${qNum}_${setId}_d', order: 4, isCorrect: false, textEn: 'Incorrect Option D', textTe: 'తప్పు సమాధానం D'),
        ];
        opts.shuffle(random);
        for (int i = 0; i < opts.length; i++) {
          opts[i] = Option(
            id: opts[i].id,
            order: i + 1,
            isCorrect: opts[i].isCorrect,
            textEn: opts[i].textEn,
            textTe: opts[i].textTe,
          );
        }
        options = opts;
      } else if (type == 'true_false') {
        final isTrue = random.nextBool();
        correctAnswerEn = isTrue ? 'True' : 'False';
        correctAnswerTe = isTrue ? 'నిజం' : 'తప్పు';
      } else {
        correctAnswerEn = 'Answer';
        correctAnswerTe = 'సమాధానం';
      }

      return Question(
        id: 'level_${level}_q${qNum}_$setId',
        order: qNum,
        type: type,
        timeLimitSeconds: timeLimit,
        points: points,
        questionEn: questionEn,
        questionTe: questionTe,
        options: options,
        correctAnswerEn: correctAnswerEn,
        correctAnswerTe: correctAnswerTe,
        verseReferenceEn: 'Genesis 1:1',
        verseReferenceTe: 'ఆదికాండము 1:1',
        explanationEn: explanationEn,
        explanationTe: explanationTe,
      );
    });
  }

  static Future<List<Question>> getRealQuestions(int level, String setId) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('real_questions').doc('${level}_$setId');
      final doc = await docRef.get();
      if (doc.exists && doc.data() != null) {
        final List<dynamic> questionsData = doc.data()!['questions'] ?? [];
        return questionsData.map((q) => Question.fromMap(Map<String, dynamic>.from(q))).toList();
      } else {
        final localMaps = RealQuestionsService.getQuestionsForLevel(level, setId);
        final questions = localMaps.map((q) => Question.fromMap(q)).toList();
        if (questions.isNotEmpty) {
          await docRef.set({
            'questions': questions.map((q) => q.toMap()).toList(),
          });
          return questions;
        }
        final generated = _generateQuestionsForLevel(level, setId);
        await docRef.set({
          'questions': generated.map((q) => q.toMap()).toList(),
        });
        return generated;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching real questions from Firestore: $e");
      }
      final localMaps = RealQuestionsService.getQuestionsForLevel(level, setId);
      if (localMaps.isNotEmpty) {
        return localMaps.map((q) => Question.fromMap(q)).toList();
      }
      return _generateQuestionsForLevel(level, setId);
    }
  }

  static Future<List<Question>> getQuizQuestions(String quizId) async {
    if (quizId.startsWith('level_')) {
      final parts = quizId.split('_');
      if (parts.length >= 2) {
        final level = int.tryParse(parts[1]);
        final setId = parts.length >= 3 ? parts[2] : 'A';
        if (level != null) {
          return getRealQuestions(level, setId);
        }
      }
    }
    try {
      final doc = await FirebaseFirestore.instance.collection('quizzes').doc(quizId).get();
      if (doc.exists && doc.data() != null) {
        final List<dynamic> questionsData = doc.data()!['questions'] ?? [];
        return questionsData.map((q) => Question.fromMap(Map<String, dynamic>.from(q))).toList();
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching custom quiz questions: $e");
      }
    }
    return [];
  }

  static Future<void> saveQuiz(Map<String, dynamic> data) async {
    final quizId = DateTime.now().millisecondsSinceEpoch.toString();
    final uid = await getCurrentUserUid() ?? 'unknown_user';
    final quizData = {
      'id': quizId,
      'creatorId': uid,
      'titleKey': data['title_en'] ?? '',
      'bibleVersion': data['bible_version'] ?? 'Unspecified',
      'topics': const ['UserCreated'],
      'isPublic': true,
      'questionCount': (data['questions'] as List?)?.length ?? 0,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'titleEn': data['title_en'] ?? '',
      'titleTe': data['title_te'] ?? '',
      'descriptionEn': data['desc_en'] ?? '',
      'descriptionTe': data['desc_te'] ?? '',
      'level': data['level'] ?? 1,
      'difficulty': data['difficulty'] ?? 'easy',
    };

    List<Map<String, dynamic>> questionsList = [];
    final listQuestions = data['questions'] as List;
    for (var i = 0; i < listQuestions.length; i++) {
      var qData = listQuestions[i];
      List<Map<String, dynamic>> opts = [];

      if (qData['type'] == 'multiple_choice' && qData['options'] != null) {
        final listOpts = qData['options'] as List;
        for (var j = 0; j < listOpts.length; j++) {
          opts.add({
            'id': '${quizId}_q${i}_$j',
            'order': j + 1,
            'isCorrect': listOpts[j]['isCorrect'] ?? false,
            'textEn': listOpts[j]['textEn'] ?? '',
            'textTe': listOpts[j]['textTe'] ?? '',
          });
        }
      }

      questionsList.add({
        'id': '${quizId}_q$i',
        'order': i + 1,
        'type': qData['type'] ?? 'multiple_choice',
        'timeLimitSeconds': qData['timeLimitSeconds'] ?? 20,
        'points': qData['points'] ?? 1000,
        'questionEn': qData['questionEn'] ?? '',
        'questionTe': qData['questionTe'] ?? '',
        'options': opts,
        'correctAnswerEn': qData['correctAnswerEn'],
        'correctAnswerTe': qData['correctAnswerTe'],
        'verseReferenceEn': qData['verseReferenceEn'] ?? '',
        'verseReferenceTe': qData['verseReferenceTe'] ?? '',
        'explanationEn': qData['explanationEn'] ?? '',
        'explanationTe': qData['explanationTe'] ?? '',
      });
    }

    quizData['questions'] = questionsList;
    await FirebaseFirestore.instance.collection('quizzes').doc(quizId).set(quizData);
  }

  static Future<void> submitScore(String userId, String username, int score) async {
    final photoURL = await getCurrentUserPhotoURL();
    final activeTitle = await getCurrentUserActiveTitle();
    Future<void> submitToCollection(String collectionName) async {
      try {
        final docRef = FirebaseFirestore.instance.collection(collectionName).doc(userId);
        final doc = await docRef.get();
        int currentHigh = 0;
        if (doc.exists) {
          currentHigh = doc.data()?['score'] ?? 0;
        }
        if (score > currentHigh) {
          await docRef.set({
            'userId': userId,
            'username': username,
            'score': score,
            'photoURL': photoURL,
            'activeTitle': activeTitle ?? '',
            'timestamp': FieldValue.serverTimestamp(),
          });
        }
      } catch (e) {
        if (kDebugMode) {
          print("Error submitting score to $collectionName: $e");
        }
      }
    }

    await submitToCollection('weekly_leaderboard');
    await submitToCollection('monthly_leaderboard');
    await submitToCollection('leaderboard_all_time');
  }

  static Future<void> submitWeeklyLeaderboardScore(String userId, String username, int score) async {
    final photoURL = await getCurrentUserPhotoURL();
    final activeTitle = await getCurrentUserActiveTitle();
    try {
      final docRef = FirebaseFirestore.instance.collection('weekly_leaderboard').doc(userId);
      final doc = await docRef.get();
      int currentHigh = 0;
      if (doc.exists) {
        currentHigh = doc.data()?['score'] ?? 0;
      }
      if (score > currentHigh) {
        await docRef.set({
          'userId': userId,
          'username': username,
          'score': score,
          'photoURL': photoURL,
          'activeTitle': activeTitle ?? '',
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error submitting score to weekly_leaderboard: $e");
      }
    }
  }

  static Stream<List<Map<String, dynamic>>> getLeaderboard(String period) {
    final collectionName = period == 'weekly' 
        ? 'weekly_leaderboard' 
        : (period == 'monthly' ? 'monthly_leaderboard' : 'leaderboard_all_time');
    
    return FirebaseFirestore.instance
        .collection(collectionName)
        .orderBy('score', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['userId'] = doc.id;
              return data;
            }).toList());
  }

  static Stream<Map<String, dynamic>> getLeaderboardWithCount(String period) {
    final collectionName = period == 'weekly' 
        ? 'weekly_leaderboard' 
        : (period == 'monthly' ? 'monthly_leaderboard' : 'leaderboard_all_time');
    
    return FirebaseFirestore.instance
        .collection(collectionName)
        .orderBy('score', descending: true)
        .limit(100)
        .snapshots()
        .asyncMap((snapshot) async {
          final scores = snapshot.docs.map((doc) {
            final data = doc.data();
            data['userId'] = doc.id;
            return data;
          }).toList();
          int totalCount = 0;
          try {
            final countSnapshot = await FirebaseFirestore.instance
                .collection(collectionName)
                .count()
                .get();
            totalCount = countSnapshot.count ?? 0;
          } catch (_) {}
          return {
            'scores': scores,
            'totalCount': totalCount,
          };
        });
  }

  static Future<int> getWeeklyRank(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('weekly_leaderboard')
          .doc(userId)
          .get();
      if (!userDoc.exists) return -1;
      final score = userDoc.data()?['score'] ?? 0;
      final querySnapshot = await FirebaseFirestore.instance
          .collection('weekly_leaderboard')
          .where('score', isGreaterThan: score)
          .count()
          .get();
      return (querySnapshot.count ?? 0) + 1;
    } catch (_) {}
    return -1;
  }

  static Future<int> getMonthlyRank(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('monthly_leaderboard')
          .doc(userId)
          .get();
      if (!userDoc.exists) return -1;
      final score = userDoc.data()?['score'] ?? 0;
      final querySnapshot = await FirebaseFirestore.instance
          .collection('monthly_leaderboard')
          .where('score', isGreaterThan: score)
          .count()
          .get();
      return (querySnapshot.count ?? 0) + 1;
    } catch (_) {}
    return -1;
  }

  static Future<int> getAllTimeRank(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('leaderboard_all_time')
          .doc(userId)
          .get();
      if (!userDoc.exists) return -1;
      final score = userDoc.data()?['score'] ?? 0;
      final querySnapshot = await FirebaseFirestore.instance
          .collection('leaderboard_all_time')
          .where('score', isGreaterThan: score)
          .count()
          .get();
      return (querySnapshot.count ?? 0) + 1;
    } catch (_) {}
    return -1;
  }

  static Future<String?> getCurrentUserUid() async => FirebaseAuth.instance.currentUser?.uid;
  
  static Future<String?> getCurrentUserDisplayName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        return doc.data()!['displayName'] as String?;
      }
    } catch (_) {}
    return user.displayName;
  }

  static Future<String?> getCurrentUserUsername() async {
    final uid = await getCurrentUserUid();
    if (uid == null) return null;
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return doc.data()!['username'] as String?;
      }
    } catch (_) {}
    return null;
  }

  static Future<bool> isUsernameUnique(String username) async {
    final uid = await getCurrentUserUid();
    if (uid == null) return false;
    
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: username.trim())
          .limit(1)
          .get();
      if (snapshot.docs.isEmpty) {
        return true;
      }
      return snapshot.docs.first.id == uid;
    } catch (_) {
      return false;
    }
  }

  static Future<void> updateProfile(String name, String username) async {
    final uid = await getCurrentUserUid();
    if (uid == null) return;
    
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.updateDisplayName(name);
    }
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'displayName': name,
      'username': username,
    }, SetOptions(merge: true));
    
    Future<void> updateLeaderboardDoc(String collection) async {
      try {
        final docRef = FirebaseFirestore.instance.collection(collection).doc(uid);
        final doc = await docRef.get();
        if (doc.exists) {
          await docRef.update({'username': username});
        }
      } catch (_) {}
    }
    await updateLeaderboardDoc('weekly_leaderboard');
    await updateLeaderboardDoc('monthly_leaderboard');
    await updateLeaderboardDoc('leaderboard_all_time');
  }
  
  static Future<String?> getCurrentUserEmail() async => FirebaseAuth.instance.currentUser?.email;

  static Future<String?> getCurrentUserPhotoURL() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        return doc.data()!['photoURL'] as String?;
      }
    } catch (_) {}
    return user.photoURL;
  }

  static Future<User?> signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn(
      serverClientId: '906009091818-ft8oah1f317ts3am28oucb8u4p40918o.apps.googleusercontent.com',
    );
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) return null;
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
    final user = userCredential.user;
    if (user != null) {
      await createUserProfile(
        user.uid,
        displayName: user.displayName,
        email: user.email,
        authMethod: 'google',
      );
    }
    return user;
  }

  static Future<void> signInWithEmailAndPassword(String email, String password) async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
  }

  static Future<void> signUpWithEmailAndPassword(String email, String password, String name, String lang, {String? referralCode}) async {
    final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
    final user = userCredential.user;
    if (user != null) {
      await user.updateDisplayName(name);
      await createUserProfile(user.uid, displayName: name, email: email);
      if (referralCode != null && referralCode.isNotEmpty) {
        await applyReferralCode(referralCode, user.uid);
      }
    }
  }

  static Future<void> sendEmailVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  static Future<bool> isEmailVerified() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.reload();
      return user.emailVerified;
    }
    return false;
  }

  static Future<void> checkEmailVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.reload();
      if (!user.emailVerified) {
        throw FirebaseAuthException(
          code: 'email-not-verified',
          message: 'Please verify your email before logging in.',
        );
      }
    }
  }

  static Future<void> signInAnonymously() async {
    await FirebaseAuth.instance.signInAnonymously();
  }

  static Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  static Future<String?> uploadAvatar(String userId, XFile file) async {
    try {
      final ref = FirebaseStorage.instance.ref().child('avatars/$userId.jpg');
      final bytes = await file.readAsBytes();
      await ref.putData(bytes);
      final downloadUrl = await ref.getDownloadURL();
      
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'photoURL': downloadUrl,
      }, SetOptions(merge: true));

      try {
        final weeklyRef = FirebaseFirestore.instance.collection('weekly_leaderboard').doc(userId);
        final weeklyDoc = await weeklyRef.get();
        if (weeklyDoc.exists) {
          await weeklyRef.update({'photoURL': downloadUrl});
        }
      } catch (_) {}

      try {
        final monthlyRef = FirebaseFirestore.instance.collection('monthly_leaderboard').doc(userId);
        final monthlyDoc = await monthlyRef.get();
        if (monthlyDoc.exists) {
          await monthlyRef.update({'photoURL': downloadUrl});
        }
      } catch (_) {}

      try {
        final allTimeRef = FirebaseFirestore.instance.collection('leaderboard_all_time').doc(userId);
        final allTimeDoc = await allTimeRef.get();
        if (allTimeDoc.exists) {
          await allTimeRef.update({'photoURL': downloadUrl});
        }
      } catch (_) {}

      return downloadUrl;
    } catch (e) {
      if (kDebugMode) {
        print("Error uploading avatar: $e");
      }
      return null;
    }
  }

  static Future<void> deleteAccount(String userId) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).delete();
    await FirebaseFirestore.instance.collection('weekly_leaderboard').doc(userId).delete();
    await FirebaseFirestore.instance.collection('monthly_leaderboard').doc(userId).delete();
    await FirebaseFirestore.instance.collection('leaderboard_all_time').doc(userId).delete();

    try {
      final quizSnapshot = await FirebaseFirestore.instance
          .collection('quizzes')
          .where('creatorId', isEqualTo: userId)
          .get();
      for (var doc in quizSnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (_) {}

    try {
      await FirebaseStorage.instance.ref().child('avatars/$userId.jpg').delete();
    } catch (_) {}

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.delete();
    }
  }

  static Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId, int? resendToken) onCodeSent,
    required Function(FirebaseAuthException) onVerificationFailed,
    required Function(PhoneAuthCredential) onVerificationCompleted,
  }) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: onVerificationCompleted,
      verificationFailed: onVerificationFailed,
      codeSent: onCodeSent,
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  static Future<User?> signInWithPhoneCredential(PhoneAuthCredential credential) async {
    final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
    final user = userCredential.user;
    if (user != null) {
      await createUserProfile(
        user.uid,
        displayName: user.displayName,
        phoneNumber: user.phoneNumber,
        authMethod: 'phone',
      );
    }
    return user;
  }

  static Future<User?> linkPhoneCredential(PhoneAuthCredential credential) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userCredential = await currentUser.linkWithCredential(credential);
      final user = userCredential.user;
      if (user != null) {
        await createUserProfile(
          user.uid,
          email: user.email,
          phoneNumber: user.phoneNumber,
          authMethod: 'both',
        );
      }
      return user;
    }
    return null;
  }

  static Future<User?> linkEmailCredential(String email, String password) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final credential = EmailAuthProvider.credential(email: email, password: password);
      final userCredential = await currentUser.linkWithCredential(credential);
      final user = userCredential.user;
      if (user != null) {
        await createUserProfile(
          user.uid,
          email: user.email,
          phoneNumber: user.phoneNumber,
          authMethod: 'both',
        );
      }
      return user;
    }
    return null;
  }

  static Future<void> createUserProfile(String uid, {
    String? displayName,
    String? email,
    String? phoneNumber,
    String? authMethod,
  }) async {
    final docRef = FirebaseFirestore.instance.collection('users').doc(uid);
    final doc = await docRef.get();
    
    final method = authMethod ?? (email != null ? 'email' : (phoneNumber != null ? 'phone' : 'anonymous'));

    if (!doc.exists) {
      String generatedUsername;
      if (email != null && email.isNotEmpty) {
        final prefix = email.split('@').first;
        final suffix = uid.substring(0, min(3, uid.length));
        generatedUsername = '${prefix}_$suffix';
      } else if (phoneNumber != null && phoneNumber.isNotEmpty) {
        final suffix = uid.substring(0, min(3, uid.length));
        generatedUsername = 'user_${phoneNumber.replaceAll('+', '')}_$suffix';
      } else {
        generatedUsername = 'guest_${uid.substring(0, min(5, uid.length))}';
      }

      await docRef.set({
        'uid': uid,
        'displayName': displayName ?? (email != null ? email.split('@').first : (phoneNumber ?? 'Guest')),
        'username': generatedUsername,
        'email': email,
        'phoneNumber': phoneNumber,
        'authMethod': method,
        'createdAt': FieldValue.serverTimestamp(),
        'totalXp': 0,
        'currentLevel': 1,
        'streak': 0,
        'photoURL': null,
        'achievements': [],
        'seenSets': {},
        'totalQuizzesCompleted': 0,
        'totalDailyChallengesCompleted': 0,
        'flashcardsMastered': 0,
        'averageAnswerTime': 0.0,
      });
    } else {
      final existingData = doc.data()!;
      final updates = <String, dynamic>{};
      if (email != null && existingData['email'] == null) {
        updates['email'] = email;
      }
      if (phoneNumber != null && existingData['phoneNumber'] == null) {
        updates['phoneNumber'] = phoneNumber;
      }
      
      final currentEmail = existingData['email'] ?? email;
      final currentPhone = existingData['phoneNumber'] ?? phoneNumber;
      if (currentEmail != null && currentPhone != null) {
        updates['authMethod'] = 'both';
      } else if (authMethod != null) {
        updates['authMethod'] = authMethod;
      }
      
      if (updates.isNotEmpty) {
        await docRef.update(updates);
      }
    }
  }

  static Future<Quiz> getOrCreateWeeklyQuiz() async {
    final now = DateTime.now();
    final monday = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    final sunday = monday.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
    
    final docRef = FirebaseFirestore.instance.collection('weekly_challenges').doc('current');
    
    final weekOfYear = ((now.difference(DateTime(now.year, 1, 1)).inDays) / 7).floor() + 1;
    final fallbackLevel = (weekOfYear % 100) + 1;

    try {
      final doc = await docRef.get();
      if (doc.exists) {
        final data = doc.data()!;
        final endDate = (data['endDate'] as Timestamp).toDate();
        if (now.isBefore(endDate)) {
          final level = data['quizLevel'] as int;
          return Quiz(
            id: 'weekly_$level',
            creatorId: 'system',
            titleKey: 'weekly_challenge',
            bibleVersion: 'BSI Telugu',
            topics: const ['Weekly Challenge'],
            isPublic: false,
            questionCount: 25,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            titleEn: 'Weekly Challenge: Level $level Quiz',
            titleTe: 'వారపు సవాలు: స్థాయి $level క్విజ్',
            descriptionEn: 'Compete in the Weekly Challenge! Top 3 win badges.',
            descriptionTe: 'వారపు సవాలులో పోటీపడండి! మొదటి 3 స్థానాలు బ్యాడ్జీలు పొందుతాయి.',
            level: level,
            difficulty: level <= 33 ? 'easy' : (level <= 66 ? 'medium' : 'hard'),
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching weekly challenge from Firestore: $e");
      }
    }

    try {
      final randomLevel = Random().nextInt(100) + 1;
      await docRef.set({
        'quizLevel': randomLevel,
        'startDate': Timestamp.fromDate(monday),
        'endDate': Timestamp.fromDate(sunday),
      });
      return Quiz(
        id: 'weekly_$randomLevel',
        creatorId: 'system',
        titleKey: 'weekly_challenge',
        bibleVersion: 'BSI Telugu',
        topics: const ['Weekly Challenge'],
        isPublic: false,
        questionCount: 25,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        titleEn: 'Weekly Challenge: Level $randomLevel Quiz',
        titleTe: 'వారపు సవాలు: స్థాయి $randomLevel క్విజ్',
        descriptionEn: 'Compete in the Weekly Challenge! Top 3 win badges.',
        descriptionTe: 'వారపు సవాలులో పోటీపడండి! మొదటి 3 స్థానాలు బ్యాడ్జీలు పొందుతాయి.',
        level: randomLevel,
        difficulty: randomLevel <= 33 ? 'easy' : (randomLevel <= 66 ? 'medium' : 'hard'),
      );
    } catch (e) {
      return Quiz(
        id: 'weekly_$fallbackLevel',
        creatorId: 'system',
        titleKey: 'weekly_challenge',
        bibleVersion: 'BSI Telugu',
        topics: const ['Weekly Challenge'],
        isPublic: false,
        questionCount: 25,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        titleEn: 'Weekly Challenge: Level $fallbackLevel Quiz',
        titleTe: 'వారపు సవాలు: స్థాయి $fallbackLevel క్విజ్',
        descriptionEn: 'Compete in the Weekly Challenge! Top 3 win badges.',
        descriptionTe: 'వారపు సవాలులో పోటీపడండి! మొదటి 3 స్థానాలు బ్యాడ్జీలు పొందుతాయి.',
        level: fallbackLevel,
        difficulty: fallbackLevel <= 33 ? 'easy' : (fallbackLevel <= 66 ? 'medium' : 'hard'),
      );
    }
  }

  // ── Flashcards ──
  static final List<Flashcard> _flashcards = [
    Flashcard(id:'f1', referenceEn:'John 3:16', referenceTe:'యోహాను 3:16', verseEn:'For God so loved the world that He gave His only begotten Son, that whoever believes in Him should not perish but have everlasting life.', verseTe:'దేవుడు లోకమును ఎంతో ప్రేమించెను, ఆయన తన అద్వితీయ కుమారునిగా పుట్టిన వానిని విశ్వసించు ప్రతివాడు నశింపక నిత్యజీవము పొందునట్లు ఆయనను అనుగ్రహించెను.'),
    Flashcard(id:'f2', referenceEn:'Psalm 23:1', referenceTe:'కీర్తన 23:1', verseEn:'The Lord is my shepherd; I shall not want.', verseTe:'యెహోవా నా కాపరి; నాకు లేమి కలుగదు.'),
    Flashcard(id:'f3', referenceEn:'Philippians 4:13', referenceTe:'ఫిలిప్పీయులు 4:13', verseEn:'I can do all things through Christ who strengthens me.', verseTe:'నన్ను బలపరచువానియందు నేను సమస్తమును చేయగలను.'),
    Flashcard(id:'f4', referenceEn:'Genesis 1:1', referenceTe:'ఆదికాండము 1:1', verseEn:'In the beginning God created the heavens and the earth.', verseTe:'ఆదియందు దేవుడు ఆకాశమును భూమిని సృష్టించెను.'),
    Flashcard(id:'f5', referenceEn:'Romans 8:28', referenceTe:'రోమీయులు 8:28', verseEn:'And we know that all things work together for good to those who love God, to those who are the called according to His purpose.', verseTe:'దేవుని ప్రేమించువారికి, ఆయన సంకల్పము చొప్పున పిలువబడినవారికి సమస్తమును మేలుకొరకు సమకూడునని మనకు తెలియును.'),
    Flashcard(id:'f6', referenceEn:'Proverbs 3:5-6', referenceTe:'సామెతలు 3:5-6', verseEn:'Trust in the Lord with all your heart, and lean not on your own understanding; in all your ways acknowledge Him, and He shall direct your paths.', verseTe:'నీ పూర్ణహృదయముతో యెహోవాయందు నమ్మికయుంచుము; నీ స్వంత వివేచనపై ఆనుకొనకుము. నీ ప్రవర్తనలన్నిటియందు ఆయనను అంగీకరించుము; అప్పుడు ఆయన నీ మార్గములను సరాళము చేయును.'),
    Flashcard(id:'f7', referenceEn:'Isaiah 41:10', referenceTe:'యెషయా 41:10', verseEn:'Fear not, for I am with you; be not dismayed, for I am your God. I will strengthen you, yes, I will help you, I will uphold you with My righteous right hand.', verseTe:'భయపడకుము, నేను నీకు తోడుగా ఉన్నాను; జడియకుము, నేను నీ దేవుడను; నేను నిన్ను బలపరతును, నీకు సహాయము చేతును, నా నీతి కుడిచేతితో నిన్ను ఆదుకొందును.'),
    Flashcard(id:'f8', referenceEn:'Matthew 6:33', referenceTe:'మత్తయి 6:33', verseEn:'But seek first the kingdom of God and His righteousness, and all these things shall be added to you.', verseTe:'మొదట దేవుని రాజ్యమును ఆయన నీతిని వెదకుడి; అప్పుడవన్నియు మీకు అనుగ్రహింపబడును.'),
    Flashcard(id:'f9', referenceEn:'2 Timothy 1:7', referenceTe:'2 తిమోతి 1:7', verseEn:'For God has not given us a spirit of fear, but of power and of love and of a sound mind.', verseTe:'దేవుడు మనకు భయముయొక్క ఆత్మనివ్వక శక్తి ప్రేమ మరియు స్వస్థబుద్ధి గల ఆత్మనిచ్చాడు.'),
    Flashcard(id:'f10', referenceEn:'Jeremiah 29:11', referenceTe:'యిర్మీయా 29:11', verseEn:'For I know the thoughts that I think toward you, says the Lord, thoughts of peace and not of evil, to give you a future and a hope.', verseTe:'మీ విషయమై నేను తలంచు తలంపులు నాకు తెలియును; అవి శాంతి తలంపులే గాని కీడు తలంపులు కావు; మీకు భవిష్యత్తును నిరీక్షణను కలుగజేయునవి.'),
    Flashcard(id:'f11', referenceEn:'1 Corinthians 13:4-7', referenceTe:'1 కొరింథీయులు 13:4-7', verseEn:'Love suffers long and is kind; love does not envy; love does not parade itself, is not puffed up; does not behave rudely, does not seek its own, is not provoked, thinks no evil; does not rejoice in iniquity, but rejoices in the truth; bears all things, believes all things, hopes all things, endures all things.', verseTe:'ప్రేమ దీర్ఘశాంతము, దయాళువు; ప్రేమ అసూయపడదు; ప్రేమ ప్రగల్భములు పలుకదు, విర్రవీగదు; అవమర్యాదగా ప్రవర్తించదు, స్వార్థము కోరదు, క్రోధము తెచ్చుకొనదు, కీడు తలంపదు; దుర్నీతియందు సంతోషించక సత్యమునందు సంతోషించును; సమస్తమును సహించును, సమస్తమును నమ్మును, సమస్తమును నిరీక్షించును, సమస్తమును ఓర్చుకొనును.'),
    Flashcard(id:'f12', referenceEn:'Joshua 1:9', referenceTe:'యెహోషువ 1:9', verseEn:'Have I not commanded you? Be strong and of good courage; do not be afraid, nor be dismayed, for the Lord your God is with you wherever you go.', verseTe:'నేను నీకు ఆజ్ఞాపించలేదా? బలముగలిగి ధైర్యము తెచ్చుకొనుము; భయపడకుము జడియకుము; నీవు నడచు ప్రతి స్థలమునందు నీ దేవుడైన యెహోవా నీకు తోడుగా ఉన్నాడు.'),
    Flashcard(id:'f13', referenceEn:'Psalm 119:105', referenceTe:'కీర్తన 119:105', verseEn:'Your word is a lamp to my feet and a light to my path.', verseTe:'నీ వాక్యము నా పాదములకు దీపమును నా మార్గమునకు వెలుగునైయున్నది.'),
    Flashcard(id:'f14', referenceEn:'Romans 12:2', referenceTe:'రోమీయులు 12:2', verseEn:'And do not be conformed to this world, but be transformed by the renewing of your mind, that you may prove what is that good and acceptable and perfect will of God.', verseTe:'ఈ లోక ప్రకారముగా మార్పు చెందక, మీ మనస్సును మార్వుకొని నూతన పరచుకొనుడి; అప్పుడు దేవుని చిత్తము ఏదో, అనగా మంచిదియు, అంగీకారమైనదియు, పరిపూర్ణమైనదియు అని మీరు పరీక్షించి తెలిసికొందురు.'),
    Flashcard(id:'f15', referenceEn:'Galatians 5:22-23', referenceTe:'గలతీయులు 5:22-23', verseEn:'But the fruit of the Spirit is love, joy, peace, longsuffering, kindness, goodness, faithfulness, gentleness, self-control. Against such there is no law.', verseTe:'ఆత్మ ఫలమేమనగా, ప్రేమ, సంతోషము, సమాధానము, దీర్ఘశాంతము, దయాళుత్వము, మంచితనము, విశ్వాస్యత, సాత్వికము, ఆశానిగ్రహము; ఇట్టివాటికి విరుద్ధమైన ధర్మశాస్త్రము లేదు.'),
    Flashcard(id:'f16', referenceEn:'Hebrews 11:1', referenceTe:'హెబ్రీయులు 11:1', verseEn:'Now faith is the substance of things hoped for, the evidence of things not seen.', verseTe:'విశ్వాసము అనునది నిరీక్షింపబడు వాటి యొక్క నిశ్చయతయు, కనబడని వాటి యొక్క నిరూపణయునై యున్నది.'),
    Flashcard(id:'f17', referenceEn:'1 John 1:9', referenceTe:'1 యోహాను 1:9', verseEn:'If we confess our sins, He is faithful and just to forgive us our sins and to cleanse us from all unrighteousness.', verseTe:'మన పాపములను ఒప్పుకొనినయెడల, ఆయన నమ్మదగినవాడును నీతిమంతుడును గనుక మన పాపములను క్షమించి సమస్త దుర్నీతినుండి మనలను శుద్ధిచేయును.'),
    Flashcard(id:'f18', referenceEn:'Matthew 28:19-20', referenceTe:'మత్తయి 28:19-20', verseEn:'Go therefore and make disciples of all the nations, baptizing them in the name of the Father and of the Son and of the Holy Spirit, teaching them to observe all things that I have commanded you; and lo, I am with you always, even to the end of the age.', verseTe:'కాబట్టి మీరు వెళ్లి, సకల జనులను శిష్యులుగా చేయుడి; తండ్రియొక్కయు కుమారునియొక్కయు పరిశుద్ధాత్మయొక్కయు నామమున బాప్తిస్మమిచ్చుచు, నేను మీకు ఆజ్ఞాపించిన సమస్తమును పాటింపవలెనని వారికి బోధించుడి; ఇదిగో యుగసమాప్తి వరకు నేను ఎల్లప్పుడు మీతో ఉన్నాను.'),
    Flashcard(id:'f19', referenceEn:'Psalm 46:1', referenceTe:'కీర్తన 46:1', verseEn:'God is our refuge and strength, a very present help in trouble.', verseTe:'దేవుడు మనకు ఆశ్రయదుర్గము, బలము; శ్రమలయందు ఆయన సహాయము చేయుటకు సిద్ధముగా ఉన్నాడు.'),
    Flashcard(id:'f20', referenceEn:'John 14:6', referenceTe:'యోహాను 14:6', verseEn:'Jesus said to him, "I am the way, the truth, and the life. No one comes to the Father except through Me."', verseTe:'యేసు అతనితో చెప్పెను: "నేనే మార్గమును, సత్యమును, జీవమును; నా ద్వారా తప్ప ఎవడును తండ్రియొద్దకు రాడు."'),
  ];

  static List<Flashcard> getFlashcards() => _flashcards;

  static int getQuizCountForLevel(int level) {
    return _levelQuizzes.where((q) => q.level == level).length;
  }

  static Future<List<Quiz>> getQuizzesForLevel(int level, [String setId = 'A']) async {
    final list = _levelQuizzes.where((q) => q.level == level).toList();
    if (list.isEmpty) return [];
    final q = list.first;
    return [
      Quiz(
        id: 'level_${level}_$setId',
        creatorId: q.creatorId,
        titleKey: q.titleKey,
        bibleVersion: q.bibleVersion,
        topics: q.topics,
        isPublic: q.isPublic,
        questionCount: q.questionCount,
        createdAt: q.createdAt,
        updatedAt: q.updatedAt,
        titleEn: q.titleEn,
        titleTe: q.titleTe,
        descriptionEn: q.descriptionEn,
        descriptionTe: q.descriptionTe,
        level: q.level,
        difficulty: q.difficulty,
        setId: setId,
      )
    ];
  }

  static Future<Quiz> getOrCreateMonthlyQuiz() async {
    return generateMonthlyQuiz();
  }

  static Future<Quiz> generateMonthlyQuiz() async {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final nextMonth = now.month == 12 ? DateTime(now.year + 1, 1, 1) : DateTime(now.year, now.month + 1, 1);
    final lastDayOfMonth = nextMonth.subtract(const Duration(seconds: 1));
    
    final docRef = FirebaseFirestore.instance.collection('monthly_challenges').doc('current');
    final doc = await docRef.get();
    
    if (doc.exists) {
      final data = doc.data()!;
      final endDate = (data['endDate'] as Timestamp).toDate();
      if (now.isBefore(endDate)) {
        final level = data['quizLevel'] as int;
        return Quiz(
          id: 'monthly_$level',
          creatorId: 'system',
          titleKey: 'monthly_challenge',
          bibleVersion: 'BSI Telugu',
          topics: const ['Monthly Challenge'],
          isPublic: false,
          questionCount: 100,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          titleEn: 'Monthly Challenge: Level $level Quiz',
          titleTe: 'నెలవారీ సవాలు: స్థాయి $level క్విజ్',
          descriptionEn: 'Complete the Monthly Challenge and dominate the leaderboard!',
          descriptionTe: 'నెలవారీ సవాలును పూర్తి చేసి, లీడర్‌బోర్డ్‌లో అగ్రస్థానంలో నిలవండి!',
          level: level,
          difficulty: level <= 33 ? 'easy' : (level <= 66 ? 'medium' : 'hard'),
        );
      }
    }
    
    final randomLevel = Random().nextInt(100) + 1;
    await docRef.set({
      'quizLevel': randomLevel,
      'startDate': Timestamp.fromDate(firstDayOfMonth),
      'endDate': Timestamp.fromDate(lastDayOfMonth),
    });
    
    return Quiz(
      id: 'monthly_$randomLevel',
      creatorId: 'system',
      titleKey: 'monthly_challenge',
      bibleVersion: 'BSI Telugu',
      topics: const ['Monthly Challenge'],
      isPublic: false,
      questionCount: 100,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      titleEn: 'Monthly Challenge: Level $randomLevel Quiz',
      titleTe: 'నెలవారీ సవాలు: స్థాయి $randomLevel క్విజ్',
      descriptionEn: 'Complete the Monthly Challenge and dominate the leaderboard!',
      descriptionTe: 'నెలవారీ సవాలును పూర్తి చేసి, లీడర్‌బోర్డ్‌లో అగ్రస్థానంలో నిలవండి!',
      level: randomLevel,
      difficulty: randomLevel <= 33 ? 'easy' : (randomLevel <= 66 ? 'medium' : 'hard'),
    );
  }

  // ── Prayer Requests Wall ──
  static Future<void> submitPrayerRequest(String userId, String userName, String request) async {
    if (userId.isEmpty) {
      throw ArgumentError("User ID cannot be empty. Please sign in to submit a prayer request.");
    }
    if (request.trim().isEmpty) {
      throw ArgumentError("Prayer request content cannot be empty.");
    }
    try {
      final activeTitle = await getCurrentUserActiveTitle();
      await FirebaseFirestore.instance.collection('prayer_requests').add({
        'userId': userId,
        'userName': userName.isEmpty ? "Anonymous" : userName,
        'userTitle': activeTitle ?? '',
        'request': request,
        'createdAt': FieldValue.serverTimestamp(),
        'prayerCount': 0,
        'prayedByUserIds': <String>[],
        'reactions': {
          'praying': 0,
          'amen': 0,
          'encouraged': 0,
        },
        'userReactions': <String, String>{},
        'isAnswered': false,
        'testimony': null,
        'answeredAt': null,
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error submitting prayer request: $e");
      }
      throw Exception("Failed to submit prayer request: ${e.toString()}");
    }
  }

  static Future<void> markPrayerAnswered(String requestId, String testimony) async {
    try {
      await FirebaseFirestore.instance.collection('prayer_requests').doc(requestId).update({
        'isAnswered': true,
        'testimony': testimony.isEmpty ? null : testimony,
        'answeredAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error marking prayer as answered: $e");
      }
      throw Exception("Failed to mark prayer as answered: ${e.toString()}");
    }
  }

  static Stream<List<PrayerRequest>> getPrayerRequests() {
    return FirebaseFirestore.instance
        .collection('prayer_requests')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return <PrayerRequest>[];
      }
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return PrayerRequest.fromFirestore(data, doc.id);
      }).toList();
    }).handleError((error) {
      if (kDebugMode) {
        print("Error fetching prayer requests stream: $error");
      }
      return <PrayerRequest>[];
    });
  }

  static Future<void> prayForRequest(String requestId, String userId) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('prayer_requests').doc(requestId);
      final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) return;
        
        final List<String> prayedByUserIds = List<String>.from(snapshot.data()?['prayedByUserIds'] ?? []);
        if (prayedByUserIds.contains(userId)) {
          // User already prayed, skip
          return;
        }
        
        transaction.update(docRef, {
          'prayerCount': FieldValue.increment(1),
          'prayedByUserIds': FieldValue.arrayUnion([userId]),
        });

        final userSnap = await transaction.get(userRef);
        if (userSnap.exists) {
          final currentPrayers = userSnap.data()?['prayersOffered'] ?? 0;
          transaction.update(userRef, {
            'prayersOffered': currentPrayers + 1,
          });
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error praying for request: $e");
      }
      rethrow;
    }
  }

  static Future<void> reactToPrayer(String requestId, String userId, String reactionType) async {
    try {
      final doc = FirebaseFirestore.instance.collection('prayer_requests').doc(requestId);
      final data = (await doc.get()).data();
      if (data == null) return;
      
      final userReactions = Map<String, String>.from(data['userReactions'] ?? {});
      final reactions = Map<String, int>.from(data['reactions'] ?? {'praying': 0, 'amen': 0, 'encouraged': 0});
      
      // If user already reacted with this type, remove it (toggle)
      if (userReactions[userId] == reactionType) {
        userReactions.remove(userId);
        reactions[reactionType] = max(0, (reactions[reactionType] ?? 1) - 1);
      } else {
        // If user reacted with a different type, remove old reaction first
        if (userReactions.containsKey(userId)) {
          final oldType = userReactions[userId]!;
          reactions[oldType] = max(0, (reactions[oldType] ?? 1) - 1);
        }
        userReactions[userId] = reactionType;
        reactions[reactionType] = (reactions[reactionType] ?? 0) + 1;
      }
      
      await doc.update({
        'reactions': reactions,
        'userReactions': userReactions,
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error reacting to prayer: $e");
      }
      rethrow;
    }
  }

  static Future<void> updatePrayerRequest(String requestId, String newText) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Must be logged in');

    try {
      final docRef = FirebaseFirestore.instance.collection('prayer_requests').doc(requestId);
      final doc = await docRef.get();
      if (!doc.exists) throw Exception('Request not found');
      if (doc.data()?['userId'] != user.uid) throw Exception('Not authorized');

      await docRef.update({
        'request': newText,
        'editedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error updating prayer request: $e");
      }
      rethrow;
    }
  }

  static Future<void> deletePrayerRequest(String requestId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Must be logged in');

    try {
      final docRef = FirebaseFirestore.instance.collection('prayer_requests').doc(requestId);
      final doc = await docRef.get();
      if (!doc.exists) throw Exception('Request not found');
      if (doc.data()?['userId'] != user.uid) throw Exception('Not authorized');

      await docRef.delete();
    } catch (e) {
      if (kDebugMode) {
        print("Error deleting prayer request: $e");
      }
      rethrow;
    }
  }


  static Future<void> saveReadingProgress(String userId, Map<String, dynamic> data) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('reading_plan')
          .doc('current')
          .set(data);
    } catch (e) {
      if (kDebugMode) {
        print("Error saving reading progress: $e");
      }
      rethrow;
    }
  }

  static Future<Map<String, dynamic>?> getReadingProgress(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('reading_plan')
          .doc('current')
          .get();
      if (doc.exists && doc.data() != null) {
        return doc.data();
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print("Error getting reading progress: $e");
      }
      return null;
    }
  }

  // ── Referral System Methods ──
  
  static Future<String> generateReferralCode(String userId) async {
    String prefix = 'USER';
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final data = userDoc.data();
        final name = data?['displayName'] ?? data?['username'] ?? '';
        final cleanName = name.toString().replaceAll(RegExp(r'[^A-Z0-9]'), '').toUpperCase();
        if (cleanName.isNotEmpty) {
          prefix = cleanName.substring(0, min(5, cleanName.length));
        }
      }
    } catch (_) {}

    final random = Random();
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    while (true) {
      final neededLength = 8 - prefix.length;
      String code = prefix;
      for (int i = 0; i < neededLength; i++) {
        code += chars[random.nextInt(chars.length)];
      }

      final query = await FirebaseFirestore.instance
          .collection('referrals')
          .where('referralCode', isEqualTo: code)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        return code;
      }
    }
  }

  static Future<String> getReferralCode(String userId) async {
    final docRef = FirebaseFirestore.instance.collection('referrals').doc(userId);
    final doc = await docRef.get();
    if (doc.exists) {
      final code = doc.data()?['referralCode'];
      if (code != null) return code as String;
    }

    final newCode = await generateReferralCode(userId);
    await docRef.set({
      'userId': userId,
      'referralCode': newCode,
      'referredUsers': [],
      'totalReferrals': 0,
      'xpEarned': 0,
    });
    return newCode;
  }

  static Future<void> applyReferralCode(String code, String newUserId) async {
    final cleanCode = code.trim().toUpperCase();

    final referrerQuery = await FirebaseFirestore.instance
        .collection('referrals')
        .where('referralCode', isEqualTo: cleanCode)
        .limit(1)
        .get();

    if (referrerQuery.docs.isEmpty) {
      throw Exception("Invalid referral code.");
    }

    final referrerDoc = referrerQuery.docs.first;
    final referrerId = referrerDoc.id;

    if (referrerId == newUserId) {
      throw Exception("You cannot refer yourself.");
    }

    final newUserReferralRef = FirebaseFirestore.instance.collection('referrals').doc(newUserId);
    final referrerRef = FirebaseFirestore.instance.collection('referrals').doc(referrerId);
    final referrerUserRef = FirebaseFirestore.instance.collection('users').doc(referrerId);
    final newUserUserRef = FirebaseFirestore.instance.collection('users').doc(newUserId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final newUserReferralSnap = await transaction.get(newUserReferralRef);
      if (newUserReferralSnap.exists && newUserReferralSnap.data()?['appliedCode'] != null) {
        throw Exception("You have already applied a referral code.");
      }

      final referrerSnap = await transaction.get(referrerRef);
      final referrerUserSnap = await transaction.get(referrerUserRef);
      final newUserUserSnap = await transaction.get(newUserUserRef);

      if (!referrerSnap.exists) {
        throw Exception("Referrer record not found.");
      }

      final List<dynamic> referred = List.from(referrerSnap.data()?['referredUsers'] ?? []);
      if (referred.contains(newUserId)) {
        throw Exception("You have already been referred by this user.");
      }
      referred.add(newUserId);
      final int totalRefs = (referrerSnap.data()?['totalReferrals'] ?? 0) + 1;
      final int xpEarned = (referrerSnap.data()?['xpEarned'] ?? 0) + 100;

      transaction.update(referrerRef, {
        'referredUsers': referred,
        'totalReferrals': totalRefs,
        'xpEarned': xpEarned,
      });

      transaction.set(newUserReferralRef, {
        'appliedCode': cleanCode,
        'referredBy': referrerId,
      }, SetOptions(merge: true));

      if (referrerUserSnap.exists) {
        final currentXp = referrerUserSnap.data()?['totalXp'] ?? 0;
        transaction.update(referrerUserRef, {'totalXp': currentXp + 100});
      }

      if (newUserUserSnap.exists) {
        final currentXp = newUserUserSnap.data()?['totalXp'] ?? 0;
        transaction.update(newUserUserRef, {'totalXp': currentXp + 100});
      }
    });
  }

  static Future<Referral> getReferralStats(String userId) async {
    final doc = await FirebaseFirestore.instance.collection('referrals').doc(userId).get();
    if (!doc.exists) {
      final code = await getReferralCode(userId);
      return Referral(
        userId: userId,
        referralCode: code,
        referredUsers: const [],
        totalReferrals: 0,
        xpEarned: 0,
      );
    }

    final data = doc.data()!;
    return Referral(
      userId: userId,
      referralCode: data['referralCode'] ?? '',
      referredUsers: List<String>.from(data['referredUsers'] ?? []),
      totalReferrals: data['totalReferrals'] ?? 0,
      xpEarned: data['xpEarned'] ?? 0,
    );
  }



  // ── Profile Titles Syncing ──
  
  static Future<String?> getCurrentUserActiveTitle() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        return doc.data()!['activeTitle'] as String?;
      }
    } catch (_) {}
    return null;
  }

  static Future<void> updateActiveTitle(String userId, String title) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).set({
      'activeTitle': title,
    }, SetOptions(merge: true));

    Future<void> updateLeaderboardDoc(String collection) async {
      try {
        final docRef = FirebaseFirestore.instance.collection(collection).doc(userId);
        final doc = await docRef.get();
        if (doc.exists) {
          await docRef.update({'activeTitle': title});
        }
      } catch (_) {}
    }

    await updateLeaderboardDoc('weekly_leaderboard');
    await updateLeaderboardDoc('monthly_leaderboard');
    await updateLeaderboardDoc('leaderboard_all_time');
  }

  // ── Daily Live Event Services ──

  static Future<Map<String, dynamic>> getOrCreateLiveEvent(String dateStr) async {
    final docRef = FirebaseFirestore.instance.collection('live_events').doc(dateStr);
    final doc = await docRef.get();
    if (!doc.exists) {
      final level = Random().nextInt(100) + 1;
      final now = DateTime.now();
      final startTime = DateTime(now.year, now.month, now.day, 20, 0); // 8 PM IST
      final endTime = startTime.add(const Duration(minutes: 15));
      final Map<String, dynamic> eventData = {
        'date': dateStr,
        'quizLevel': level,
        'startTime': Timestamp.fromDate(startTime),
        'endTime': Timestamp.fromDate(endTime),
        'participants': <String, dynamic>{},
        'participantNames': <String, dynamic>{},
      };
      await docRef.set(eventData);
      return eventData;
    }
    return doc.data()!;
  }

  static Future<void> submitLiveEventScore(String dateStr, String userId, String displayName, int score) async {
    final docRef = FirebaseFirestore.instance.collection('live_events').doc(dateStr);
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) {
        transaction.set(docRef, {
          'date': dateStr,
          'quizLevel': Random().nextInt(100) + 1,
          'participants': {userId: score},
          'participantNames': {userId: displayName},
        });
      } else {
        final data = snapshot.data()!;
        final participants = Map<String, int>.from(data['participants'] ?? {});
        final participantNames = Map<String, String>.from(data['participantNames'] ?? {});
        participants[userId] = score;
        participantNames[userId] = displayName;
        transaction.update(docRef, {
          'participants': participants,
          'participantNames': participantNames,
        });
      }
    });
  }

  // ── 1v1 Battle Mode Services ──

  static Future<String> createBattle(String challengerId, String challengerName, String? opponentId, String? opponentName) async {
    final level = Random().nextInt(20) + 1;
    final questions = await getRealQuestions(level, 'A');
    final battleQuestions = questions.take(5).map((q) => q.toMap()).toList();
    final docRef = FirebaseFirestore.instance.collection('battles').doc();
    await docRef.set({
      'id': docRef.id,
      'challengerId': challengerId,
      'challengerName': challengerName,
      'opponentId': opponentId,
      'opponentName': opponentName,
      'status': 'waiting',
      'questions': battleQuestions,
      'challengerScore': null,
      'opponentScore': null,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  static Future<void> acceptBattle(String battleId, String opponentId, String opponentName) async {
    await FirebaseFirestore.instance.collection('battles').doc(battleId).update({
      'opponentId': opponentId,
      'opponentName': opponentName,
      'status': 'accepted',
    });
  }

  static Future<void> submitBattleScore(String battleId, String userId, int score) async {
    final docRef = FirebaseFirestore.instance.collection('battles').doc(battleId);
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snap = await transaction.get(docRef);
      if (!snap.exists) return;
      final data = snap.data()!;
      final challengerId = data['challengerId'];
      final opponentId = data['opponentId'];
      
      final Map<String, dynamic> updates = {};
      if (userId == challengerId) {
        updates['challengerScore'] = score;
      } else if (userId == opponentId) {
        updates['opponentScore'] = score;
      }
      
      final newChallengerScore = userId == challengerId ? score : data['challengerScore'];
      final newOpponentScore = userId == opponentId ? score : data['opponentScore'];
      
      if (newChallengerScore != null && newOpponentScore != null) {
        updates['status'] = 'completed';
      } else {
        updates['status'] = 'in_progress';
      }
      
      transaction.update(docRef, updates);
    });
  }

  static Future<List<Map<String, dynamic>>> searchUsersByUsername(String query) async {
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: query)
        .where('username', isLessThanOrEqualTo: '$query\uf8ff')
        .limit(10)
        .get();
    return snap.docs.map((d) => d.data()).toList();
  }

  static Future<List<Map<String, dynamic>>> getSuggestedOpponents(String currentUserId) async {
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .limit(10)
        .get();
    return snap.docs
        .where((d) => d.id != currentUserId)
        .map((d) => d.data())
        .toList();
  }

  // ── Church Groups Service Methods ──

  static Future<String> generateUniqueGroupJoinCode() async {
    final random = Random();
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    while (true) {
      String code = '';
      for (int i = 0; i < 6; i++) {
        code += chars[random.nextInt(chars.length)];
      }
      final query = await FirebaseFirestore.instance
          .collection('church_groups')
          .where('joinCode', isEqualTo: code)
          .limit(1)
          .get();
      if (query.docs.isEmpty) {
        return code;
      }
    }
  }

  static Future<ChurchGroup> createChurchGroup(
      String userId, String pastorName, String name, String description) async {
    final joinCode = await generateUniqueGroupJoinCode();
    final docRef = FirebaseFirestore.instance.collection('church_groups').doc();
    final group = ChurchGroup(
      id: docRef.id,
      name: name,
      description: description,
      pastorId: userId,
      pastorName: pastorName,
      joinCode: joinCode,
      memberIds: [userId],
      memberNames: [pastorName],
      createdAt: DateTime.now(),
      totalMembers: 1,
    );
    await docRef.set(group.toMap());
    return group;
  }

  static Future<ChurchGroup> joinChurchGroup(
      String userId, String userName, String joinCode) async {
    final cleanCode = joinCode.trim().toUpperCase();
    final query = await FirebaseFirestore.instance
        .collection('church_groups')
        .where('joinCode', isEqualTo: cleanCode)
        .limit(1)
        .get();
    if (query.docs.isEmpty) {
      throw Exception('Group not found. Please check the code.');
    }
    final doc = query.docs.first;
    final data = doc.data();
    final List<String> memberIds = List<String>.from(data['memberIds'] ?? []);
    final List<String> memberNames = List<String>.from(data['memberNames'] ?? []);

    if (!memberIds.contains(userId)) {
      memberIds.add(userId);
      memberNames.add(userName);
      await doc.reference.update({
        'memberIds': memberIds,
        'memberNames': memberNames,
        'totalMembers': memberIds.length,
      });
    }

    final updatedData = Map<String, dynamic>.from(data);
    updatedData['memberIds'] = memberIds;
    updatedData['memberNames'] = memberNames;
    updatedData['totalMembers'] = memberIds.length;
    return ChurchGroup.fromFirestore(updatedData, doc.id);
  }

  static Future<void> leaveChurchGroup(String userId, String groupId) async {
    final docRef = FirebaseFirestore.instance.collection('church_groups').doc(groupId);
    final doc = await docRef.get();
    if (!doc.exists) return;
    final data = doc.data()!;
    final List<String> memberIds = List<String>.from(data['memberIds'] ?? []);
    final List<String> memberNames = List<String>.from(data['memberNames'] ?? []);

    final idx = memberIds.indexOf(userId);
    if (idx >= 0) {
      memberIds.removeAt(idx);
      if (idx < memberNames.length) {
        memberNames.removeAt(idx);
      }
      await docRef.update({
        'memberIds': memberIds,
        'memberNames': memberNames,
        'totalMembers': memberIds.length,
      });
    }
  }

  static Stream<List<ChurchGroup>> getUserGroups(String userId) {
    return FirebaseFirestore.instance
        .collection('church_groups')
        .where('memberIds', arrayContains: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChurchGroup.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  static Stream<List<Map<String, dynamic>>> getGroupLeaderboard(String groupId) {
    return FirebaseFirestore.instance
        .collection('church_groups')
        .doc(groupId)
        .snapshots()
        .asyncMap((groupDoc) async {
      if (!groupDoc.exists || groupDoc.data() == null) return [];
      final data = groupDoc.data()!;
      final memberIds = List<String>.from(data['memberIds'] ?? []);
      final memberNames = List<String>.from(data['memberNames'] ?? []);
      if (memberIds.isEmpty) return [];

      final futures = memberIds.map((uid) => FirebaseFirestore.instance.collection('users').doc(uid).get());
      final docs = await Future.wait(futures);

      final List<Map<String, dynamic>> members = [];
      for (var i = 0; i < docs.length; i++) {
        final doc = docs[i];
        if (doc.exists && doc.data() != null) {
          final userData = doc.data()!;
          members.add({
            'uid': doc.id,
            'displayName': userData['displayName'] ?? (i < memberNames.length ? memberNames[i] : 'Member'),
            'username': userData['username'] ?? '',
            'totalXp': userData['totalXp'] ?? 0,
            'activeTitle': userData['activeTitle'] ?? '',
            'photoURL': userData['photoURL'],
          });
        } else {
          members.add({
            'uid': memberIds[i],
            'displayName': i < memberNames.length ? memberNames[i] : 'Member',
            'username': '',
            'totalXp': 0,
            'activeTitle': '',
            'photoURL': null,
          });
        }
      }

      members.sort((a, b) => (b['totalXp'] as int).compareTo(a['totalXp'] as int));
      return members;
    });
  }

  static Future<GroupChallenge> createGroupChallenge(
      String groupId, String title, String description, int quizLevel, DateTime endDate) async {
    final docRef = FirebaseFirestore.instance.collection('group_challenges').doc();
    final challenge = GroupChallenge(
      id: docRef.id,
      groupId: groupId,
      title: title,
      description: description,
      quizLevel: quizLevel,
      startDate: DateTime.now(),
      endDate: endDate,
      participantScores: {},
    );
    await docRef.set(challenge.toMap());
    return challenge;
  }

  static Stream<List<GroupChallenge>> getGroupChallenges(String groupId) {
    return FirebaseFirestore.instance
        .collection('group_challenges')
        .where('groupId', isEqualTo: groupId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => GroupChallenge.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  static Future<void> submitGroupChallengeScore(String challengeId, String userId, int score) async {
    final docRef = FirebaseFirestore.instance.collection('group_challenges').doc(challengeId);
    await docRef.update({
      'participantScores.$userId': score,
    });
  }

  static Future<ChurchGroup?> getGroupById(String groupId) async {
    final doc = await FirebaseFirestore.instance.collection('church_groups').doc(groupId).get();
    if (doc.exists && doc.data() != null) {
      return ChurchGroup.fromFirestore(doc.data()!, doc.id);
    }
    return null;
  }

  static Stream<ChurchGroup?> getGroupStream(String groupId) {
    return FirebaseFirestore.instance
        .collection('church_groups')
        .doc(groupId)
        .snapshots()
        .map((doc) => doc.exists && doc.data() != null
            ? ChurchGroup.fromFirestore(doc.data()!, doc.id)
            : null);
  }

  // --- Follow System ---
  static Future<void> followUser(String followerId, String followingId) async {
    final docId = "${followerId}_$followingId";
    await FirebaseFirestore.instance.collection('follows').doc(docId).set({
      'followerId': followerId,
      'followingId': followingId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> unfollowUser(String followerId, String followingId) async {
    final docId = "${followerId}_$followingId";
    await FirebaseFirestore.instance.collection('follows').doc(docId).delete();
  }

  static Future<bool> isFollowing(String followerId, String followingId) async {
    final docId = "${followerId}_$followingId";
    final doc = await FirebaseFirestore.instance.collection('follows').doc(docId).get();
    return doc.exists;
  }

  static Stream<List<String>> getFollowers(String userId) {
    return FirebaseFirestore.instance
        .collection('follows')
        .where('followingId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => doc.data()['followerId'] as String)
            .toList());
  }

  static Stream<List<String>> getFollowing(String userId) {
    return FirebaseFirestore.instance
        .collection('follows')
        .where('followerId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => doc.data()['followingId'] as String)
            .toList());
  }

  static Future<Map<String, dynamic>?> getUserById(String userId) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return doc.data();
  }

  static Future<String> uploadProfileBanner(File imageFile, String userId) async {
    final ref = FirebaseStorage.instance.ref().child('banners').child('$userId.jpg');
    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }

  static Future<String> uploadProfileAvatar(File imageFile, String userId) async {
    final ref = FirebaseStorage.instance.ref().child('avatars').child('$userId.jpg');
    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }

  static Future<String> addNote(
    String userId,
    String bookId,
    int chapter,
    int? verseNumber,
    String verseReference,
    String text,
  ) async {
    final docRef = await FirebaseFirestore.instance
        .collection('notes')
        .doc(userId)
        .collection('chapter_notes')
        .add({
      'bookId': bookId,
      'chapter': chapter,
      'verseNumber': verseNumber,
      'verseReference': verseReference,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  static Future<void> deleteNote(String userId, String noteId) async {
    await FirebaseFirestore.instance
        .collection('notes')
        .doc(userId)
        .collection('chapter_notes')
        .doc(noteId)
        .delete();
  }

  static Stream<List<Map<String, dynamic>>> getChapterNotes(
    String userId,
    String bookId,
    int chapter,
  ) {
    return FirebaseFirestore.instance
        .collection('notes')
        .doc(userId)
        .collection('chapter_notes')
        .where('bookId', isEqualTo: bookId)
        .where('chapter', isEqualTo: chapter)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();
          list.sort((a, b) {
            final aTime = a['createdAt'] as Timestamp?;
            final bTime = b['createdAt'] as Timestamp?;
            if (aTime == null && bTime == null) return 0;
            if (aTime == null) return 1;
            if (bTime == null) return -1;
            return bTime.compareTo(aTime); // descending (newest first)
          });
          return list;
        });
  }

  static Future<void> addLabelledVerse(
    String userId,
    String bookId,
    int chapter,
    int verse,
    String colour,
  ) async {
    final docId = '${bookId}_${chapter}_$verse';
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('labelled_verses')
        .doc(docId)
        .set({
      'bookId': bookId,
      'chapter': chapter,
      'verse': verse,
      'colour': colour,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> removeLabelledVerse(
    String userId,
    String bookId,
    int chapter,
    int verse,
  ) async {
    final docId = '${bookId}_${chapter}_$verse';
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('labelled_verses')
        .doc(docId)
        .delete();
  }

  static Future<Map<int, String>> getChapterLabelledVerses(
    String userId,
    String bookId,
    int chapter,
  ) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('labelled_verses')
        .where('bookId', isEqualTo: bookId)
        .where('chapter', isEqualTo: chapter)
        .get();
    
    final Map<int, String> result = {};
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final verseNum = data['verse'] as int?;
      final colourHex = data['colour'] as String?;
      if (verseNum != null && colourHex != null) {
        result[verseNum] = colourHex;
      }
    }
    return result;
  }

  static Future<Map<String, String>> getAllLabelledVerses(String userId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('labelled_verses')
        .get();
    
    final Map<String, String> result = {};
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final colourHex = data['colour'] as String?;
      if (colourHex != null) {
        result[doc.id] = colourHex;
      }
    }
    return result;
  }

  static Future<void> toggleFavoriteVerse(
    String userId,
    String bookId,
    int chapter,
    int verse,
    String verseText,
  ) async {
    final docId = '${bookId}_${chapter}_$verse';
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('favorited_verses')
        .doc(docId);
    
    final doc = await docRef.get();
    if (doc.exists) {
      await docRef.delete();
    } else {
      await docRef.set({
        'bookId': bookId,
        'chapter': chapter,
        'verse': verse,
        'verseText': verseText.length > 100 ? '${verseText.substring(0, 100)}...' : verseText,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  static Future<bool> isVerseFavorited(
    String userId,
    String bookId,
    int chapter,
    int verse,
  ) async {
    final docId = '${bookId}_${chapter}_$verse';
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('favorited_verses')
        .doc(docId)
        .get();
    return doc.exists;
  }

  static Future<List<int>> getChapterFavoritedVerses(
    String userId,
    String bookId,
    int chapter,
  ) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('favorited_verses')
        .where('bookId', isEqualTo: bookId)
        .where('chapter', isEqualTo: chapter)
        .get();
    
    return snapshot.docs
        .map((doc) => doc.data()['verse'] as int?)
        .whereType<int>()
        .toList();
  }

  static Stream<List<Map<String, dynamic>>> getFavoritedVerses(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('favorited_verses')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return data;
            }).toList());
  }
}