import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_core_platform_interface/test.dart';
import 'package:bible_quiz/models/referral.dart';
import 'package:bible_quiz/models/profile_title.dart';
import 'package:bible_quiz/providers/user_data_provider.dart';
import 'package:bible_quiz/models/prayer_request.dart';
import 'package:bible_quiz/services/bible_service.dart';
import 'package:bible_quiz/services/custom_quiz_generator.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  setupFirebaseCoreMocks();

  setUpAll(() async {
    await Firebase.initializeApp();

    // Set up mock asset bundle loading using local files
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMessageHandler(
      'flutter/assets',
      (ByteData? message) async {
        if (message == null) return null;
        final key = utf8.decode(message.buffer.asUint8List(message.offsetInBytes, message.lengthInBytes));
        final file = File(key);
        if (file.existsSync()) {
          final bytes = file.readAsBytesSync();
          return ByteData.view(bytes.buffer, bytes.offsetInBytes, bytes.lengthInBytes);
        }
        return null;
      },
    );
  });

  group('Referral Model Tests', () {
    test('fromMap and toMap serializations work correctly', () {
      final referral = Referral(
        userId: 'user123',
        referralCode: 'CODE1234',
        referredUsers: ['userA', 'userB'],
        totalReferrals: 2,
        xpEarned: 200,
      );

      final map = referral.toMap();
      expect(map['userId'], 'user123');
      expect(map['referralCode'], 'CODE1234');
      expect(map['referredUsers'], containsAll(['userA', 'userB']));
      expect(map['totalReferrals'], 2);
      expect(map['xpEarned'], 200);

      final deserialized = Referral.fromMap(map, 'user123');
      expect(deserialized.userId, 'user123');
      expect(deserialized.referralCode, 'CODE1234');
      expect(deserialized.referredUsers, containsAll(['userA', 'userB']));
      expect(deserialized.totalReferrals, 2);
      expect(deserialized.xpEarned, 200);
    });

    test('fromMap handles missing/null values gracefully with defaults', () {
      final map = <String, dynamic>{
        'referralCode': 'TESTCODE',
      };

      final deserialized = Referral.fromMap(map, 'user456');
      expect(deserialized.userId, 'user456');
      expect(deserialized.referralCode, 'TESTCODE');
      expect(deserialized.referredUsers, isEmpty);
      expect(deserialized.totalReferrals, 0);
      expect(deserialized.xpEarned, 0);
    });
  });

  group('ProfileTitle Model Tests', () {
    test('Title list contains all expected titles', () {
      final titleIds = ProfileTitle.allTitles.map((t) => t.id).toList();
      expect(titleIds, containsAll([
        'novice',
        'intercessor',
        'dedicated',
        'flawless',
        'speed_demon',
        'quiz_master',
        'bible_scholar',
        'lightning',
        'unstoppable',
      ]));
    });

    test('Rarities are properly assigned', () {
      final novice = ProfileTitle.allTitles.firstWhere((t) => t.id == 'novice');
      final unstoppable = ProfileTitle.allTitles.firstWhere((t) => t.id == 'unstoppable');

      expect(novice.rarity, TitleRarity.common);
      expect(unstoppable.rarity, TitleRarity.legendary);
    });
  });

  group('UserDataProvider Title Verification', () {
    test('Novice title is unlocked by default', () {
      final provider = UserDataProvider();
      expect(provider.unlockedTitles, contains('novice'));
      expect(provider.isTitleUnlocked('novice'), isTrue);
    });

    test('Verify unlock logic for Intercessor title', () {
      final provider = UserDataProvider();
      // Initially not unlocked (prayersOffered = 0)
      expect(provider.isTitleUnlocked('intercessor'), isFalse);
    });

    test('Verify unlock logic for Dedicated title', () {
      final provider = UserDataProvider();
      // Initially not unlocked
      expect(provider.isTitleUnlocked('dedicated'), isFalse);
    });

    test('Verify unlock logic for Flawless title', () {
      final provider = UserDataProvider();
      // Initially not unlocked
      expect(provider.isTitleUnlocked('flawless'), isFalse);
    });
  });

  group('PrayerRequest Model Tests', () {
    test('fromFirestore and toMap serialization work correctly with reactions', () {
      final request = PrayerRequest(
        id: 'request123',
        userId: 'user123',
        userName: 'John Doe',
        request: 'Pray for health',
        createdAt: DateTime(2026, 6, 6),
        prayerCount: 5,
        prayedByUserIds: ['userA', 'userB'],
        userTitle: 'quiz_master',
        reactions: const {
          'praying': 2,
          'amen': 3,
          'encouraged': 1,
        },
        userReactions: const {
          'userA': 'praying',
          'userB': 'amen',
        },
      );

      final map = request.toMap();
      expect(map['userId'], 'user123');
      expect(map['userName'], 'John Doe');
      expect(map['request'], 'Pray for health');
      expect(map['prayerCount'], 5);
      expect(map['prayedByUserIds'], containsAll(['userA', 'userB']));
      expect(map['userTitle'], 'quiz_master');
      expect(map['reactions']['praying'], 2);
      expect(map['reactions']['amen'], 3);
      expect(map['reactions']['encouraged'], 1);
      expect(map['userReactions']['userA'], 'praying');
      expect(map['userReactions']['userB'], 'amen');

      final deserialized = PrayerRequest.fromFirestore(map, 'request123');
      expect(deserialized.id, 'request123');
      expect(deserialized.userId, 'user123');
      expect(deserialized.userName, 'John Doe');
      expect(deserialized.request, 'Pray for health');
      expect(deserialized.prayerCount, 5);
      expect(deserialized.prayedByUserIds, containsAll(['userA', 'userB']));
      expect(deserialized.userTitle, 'quiz_master');
      expect(deserialized.reactions['praying'], 2);
      expect(deserialized.reactions['amen'], 3);
      expect(deserialized.reactions['encouraged'], 1);
      expect(deserialized.userReactions['userA'], 'praying');
      expect(deserialized.userReactions['userB'], 'amen');
    });

    test('fromFirestore handles null/empty reactions maps gracefully', () {
      final map = <String, dynamic>{
        'userId': 'user789',
        'userName': 'Jane Doe',
        'request': 'Another prayer',
      };

      final deserialized = PrayerRequest.fromFirestore(map, 'request456');
      expect(deserialized.id, 'request456');
      expect(deserialized.userId, 'user789');
      expect(deserialized.userName, 'Jane Doe');
      expect(deserialized.request, 'Another prayer');
      expect(deserialized.reactions['praying'], 0);
      expect(deserialized.reactions['amen'], 0);
      expect(deserialized.reactions['encouraged'], 0);
      expect(deserialized.userReactions, isEmpty);
    });
  });

  group('Bible Data & Custom Quiz Generator Tests', () {
    test('Verify BibleService loads chapters successfully', () async {
      final genesis1 = await BibleService.getChapter('genesis', 1, 'kjv');
      expect(genesis1, isNotEmpty);
      expect(genesis1.containsKey(1), isTrue);
      expect(genesis1[1], contains('In the beginning'));

      final isaiah1 = await BibleService.getChapter('isaiah', 1, 'kjv');
      expect(isaiah1, isNotEmpty);
      expect(isaiah1.containsKey(1), isTrue);
    });

    test('Verify CustomQuizGenerator generates quiz for Genesis', () async {
      final questions = await CustomQuizGenerator.generateQuiz(
        bookId: 'genesis',
        fromChapter: 1,
        toChapter: 3,
        questionCount: 5,
        version: 'kjv',
      );

      expect(questions, isNotEmpty);
      expect(questions.length, equals(5));
      for (final q in questions) {
        expect(q.questionEn, isNotEmpty);
        expect(q.options, hasLength(4));
        expect(q.options.any((o) => o.isCorrect), isTrue);
      }
    });

    test('Verify CustomQuizGenerator generates quiz for Isaiah', () async {
      final questions = await CustomQuizGenerator.generateQuiz(
        bookId: 'isaiah',
        fromChapter: 1,
        toChapter: 5,
        questionCount: 5,
        version: 'te',
      );

      expect(questions, isNotEmpty);
      expect(questions.length, equals(5));
      for (final q in questions) {
        expect(q.questionTe, isNotEmpty);
        expect(q.options, hasLength(4));
        expect(q.options.any((o) => o.isCorrect), isTrue);
      }
    });
  });
}
