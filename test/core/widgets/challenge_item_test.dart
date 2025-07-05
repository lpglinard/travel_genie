import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../../../lib/models/challenge.dart';
import '../../../lib/widgets/home/challenge_item.dart';
import '../../../lib/l10n/app_localizations.dart';

void main() {
  group('ChallengeItem', () {
    late Challenge testChallenge;

    setUp(() {
      testChallenge = const Challenge(
        id: 'test_challenge',
        titleKey: 'challengeCreateAccountTitle',
        descriptionKey: 'challengeCreateAccountDescription',
        goal: 1,
        type: 'test',
        isActive: true,
        endDate: 9999999999999,
        displayOrder: 1,
        rewardType: 'badge',
        rewardValue: 'test_badge',
      );
    });

    testWidgets('should render ChallengeItem without errors', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('pt'),
          ],
          home: Scaffold(
            body: ChallengeItem(challenge: testChallenge),
          ),
        ),
      );

      // Verify that the widget renders without errors
      expect(find.byType(ChallengeItem), findsOneWidget);

      // Verify that the GestureDetector is present
      expect(find.byType(GestureDetector), findsOneWidget);

      // Verify that the progress indicator is present
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('should execute callback when tapped', (WidgetTester tester) async {
      bool callbackExecuted = false;

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('pt'),
          ],
          home: Scaffold(
            body: ChallengeItem(
              challenge: testChallenge,
              onTap: () {
                callbackExecuted = true;
              },
            ),
          ),
        ),
      );

      // Verify callback is not executed initially
      expect(callbackExecuted, false);

      // Tap the challenge item by finding any text within it
      await tester.tap(find.text('Create Account').first);
      await tester.pump();

      // Verify callback was executed
      expect(callbackExecuted, true);
    });

    testWidgets('should not crash when tapped without callback', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('pt'),
          ],
          home: Scaffold(
            body: ChallengeItem(challenge: testChallenge),
          ),
        ),
      );

      // Tap the challenge item without callback - should not crash
      await tester.tap(find.text('Create Account').first);
      await tester.pump();

      // Verify widget is still present and functional
      expect(find.byType(ChallengeItem), findsOneWidget);
    });
  });
}
