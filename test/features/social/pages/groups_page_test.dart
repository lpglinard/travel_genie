import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_genie/pages/groups_page.dart';
import 'package:travel_genie/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  group('GroupsPage', () {
    testWidgets('should render without errors', (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en'), Locale('pt')],
            home: const GroupsPage(),
          ),
        ),
      );

      // Wait for the widget to settle
      await tester.pumpAndSettle();

      // Verify that the page renders
      expect(find.byType(GroupsPage), findsOneWidget);
      
      // Verify that the app bar is present
      expect(find.byType(AppBar), findsOneWidget);
      
      // Verify that the main content is present
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should display groups title and subtitle', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en'), Locale('pt')],
            home: const GroupsPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check for the presence of key text elements
      expect(find.text('Travel Groups'), findsOneWidget);
      expect(find.text('Help us shape the future of group travel planning!'), findsOneWidget);
    });

    testWidgets('should display feedback buttons', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en'), Locale('pt')],
            home: const GroupsPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check for the presence of feedback buttons
      expect(find.text('Yes, I\'d love this!'), findsOneWidget);
      expect(find.text('Not for me'), findsOneWidget);
      
      // Check for button icons
      expect(find.byIcon(Icons.thumb_up_rounded), findsOneWidget);
      expect(find.byIcon(Icons.thumb_down_rounded), findsOneWidget);
    });

    testWidgets('should display feedback card with examples', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en'), Locale('pt')],
            home: const GroupsPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check for feedback question and description
      expect(find.text('Would you like to plan trips with others?'), findsOneWidget);
      expect(find.textContaining('We\'re considering adding a feature'), findsOneWidget);
      
      // Check for examples
      expect(find.text('Think about planning trips with:'), findsOneWidget);
      expect(find.textContaining('Family members'), findsOneWidget);
      expect(find.textContaining('Friends for weekend'), findsOneWidget);
      expect(find.textContaining('Colleagues for team'), findsOneWidget);
      expect(find.textContaining('significant other'), findsOneWidget);
    });
  });
}