import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bible_quiz/main.dart';
import 'package:firebase_core/firebase_core.dart' hide FirebaseService;
// ignore: depend_on_referenced_packages
import 'package:firebase_core_platform_interface/test.dart';
import 'package:bible_quiz/services/firebase_service.dart';
import 'package:bible_quiz/services/local_storage_service.dart';
import 'package:bible_quiz/services/connectivity_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
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
    await LocalStorageService.init();
    ConnectivityService.init();
  });

  testWidgets('Bible Quiz app smoke test', (WidgetTester tester) async {
    await FirebaseService.initialize();

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const BibleQuizApp(),
    );

    // Allow translations/resources to load and settle.
    await tester.pumpAndSettle();

    // Verify that the onboarding screen is displayed and shows the welcome title.
    expect(find.text('Welcome Back'), findsWidgets);

    // Verify that the "Continue as Guest" button is found.
    expect(find.text('Continue as Guest'), findsOneWidget);
  });
}
