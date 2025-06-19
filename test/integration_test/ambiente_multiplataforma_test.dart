import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_genie/app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:travel_genie/firebase_options.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    setupFirebaseCoreMocks();
    await Firebase.initializeApp(
      name: 'test-integration',
      options: DefaultFirebaseOptions.currentPlatform,
    );
  });

  tearDownAll(() async {
    // Firebase app deletion is not supported in the mocks.
    // Apps are given unique names to avoid conflicts across tests.
  });

  group('TG-4: Ambiente Multiplataforma', () {
    testWidgets('home shows search field', (tester) async {
      await tester.pumpWidget(const ProviderScope(child: MyApp()));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });
  });
}
