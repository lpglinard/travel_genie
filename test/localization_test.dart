import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/riverpod.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart' as firebase_ui_auth;

import 'package:travel_genie/main.dart';
import 'package:travel_genie/user_providers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:travel_genie/firebase_options.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    setupFirebaseCoreMocks();
    await Firebase.initializeApp(
      name: 'test-localization',
      options: DefaultFirebaseOptions.currentPlatform,
    );
  });

  tearDownAll(() async {
    // Firebase app deletion is not supported in the mocks.
    // Apps are given unique names to avoid conflicts across tests.
  });
  testWidgets('shows English texts when locale is en', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [localeProvider.overrideWith((ref) => const Locale('en'))],
        child: const MyApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Flutter Demo Home Page'), findsOneWidget);
    expect(find.text('Página Inicial do Flutter'), findsNothing);
  });

  testWidgets('shows Portuguese texts when locale is pt', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [localeProvider.overrideWith((ref) => const Locale('pt'))],
        child: const MyApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Página Inicial do Flutter'), findsOneWidget);
    expect(find.text('Flutter Demo Home Page'), findsNothing);
  });

  testWidgets('profile button opens login screen when user is anonymous', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.person));
    await tester.pumpAndSettle();

    expect(find.byType(firebase_ui_auth.SignInScreen), findsOneWidget);
  });
}
