import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bible_quiz/main.dart';
import 'package:firebase_core/firebase_core.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_core_platform_interface/test.dart';
import 'package:bible_quiz/services/firebase_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();

  // Also mock auth calls to prevent auth listener crashes
  const MethodChannel authChannel = MethodChannel('plugins.flutter.io/firebase_auth');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(authChannel, (MethodCall methodCall) async {
    if (methodCall.method == 'Auth#registerIdTokenListener') {
      return null;
    }
    if (methodCall.method == 'Auth#registerAuthStateListener') {
      return null;
    }
    return null;
  });

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  testWidgets('Bible Quiz app smoke test', (WidgetTester tester) async {
    await FirebaseService.initialize();

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const BibleQuizApp(),
    );

    // Allow translations/resources to load and settle.
    await tester.pumpAndSettle();

    // Verify that the onboarding screen is displayed and shows the app title.
    expect(find.text('Telugu Bible Quiz'), findsWidgets);

    // Verify that the "PLAY SOLO" button is found.
    expect(find.text('PLAY SOLO'), findsOneWidget);
  });
}
