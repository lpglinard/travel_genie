import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/riverpod.dart';

import 'package:travel_genie/main.dart';
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

  testWidgets('language toggle switches between pt and en', (tester) async {
    tester.binding.platformDispatcher.localeTestValue = const Locale('pt');
    tester.binding.platformDispatcher.localesTestValue = const [Locale('pt')];
    addTearDown(tester.binding.platformDispatcher.clearLocaleTestValue);
    addTearDown(tester.binding.platformDispatcher.clearLocalesTestValue);

    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle();

    // Should start in Portuguese due to system locale
    expect(find.text('Página Inicial do Flutter'), findsOneWidget);

    // Switch to English
    await tester.tap(find.byIcon(Icons.language));
    await tester.pumpAndSettle();
    expect(find.text('Flutter Demo Home Page'), findsOneWidget);

    // Switch back to Portuguese
    await tester.tap(find.byIcon(Icons.language));
    await tester.pumpAndSettle();
    expect(find.text('Página Inicial do Flutter'), findsOneWidget);
  });
}
