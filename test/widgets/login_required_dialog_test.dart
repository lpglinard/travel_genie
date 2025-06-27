import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../lib/widgets/login_required_dialog.dart';
import '../../lib/l10n/app_localizations.dart';

void main() {
  group('LoginRequiredDialog', () {
    testWidgets('should render LoginRequiredDialog without errors', (WidgetTester tester) async {
      // Create a mock router for testing
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const Scaffold(body: Text('Home')),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const Scaffold(body: Text('Profile')),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
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
        ),
      );

      // Show the dialog
      await tester.tap(find.byType(Scaffold));
      await tester.pumpAndSettle();

      // Trigger the dialog
      final context = tester.element(find.byType(Scaffold));
      await LoginRequiredDialog.show(context);
      await tester.pumpAndSettle();

      // Verify that the dialog is displayed
      expect(find.byType(LoginRequiredDialog), findsOneWidget);
      expect(find.byType(AlertDialog), findsOneWidget);

      // Verify that the title and message are displayed
      expect(find.text('Unlock more features'), findsOneWidget);
      expect(find.text('To save your favorite places and plan personalized trips, create a free account.'), findsOneWidget);

      // Verify that the buttons are displayed
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Create Account'), findsOneWidget);
    });

    testWidgets('should close dialog when cancel is tapped', (WidgetTester tester) async {
      // Create a mock router for testing
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const Scaffold(body: Text('Home')),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
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
        ),
      );

      await tester.pumpAndSettle();

      // Show the dialog
      final context = tester.element(find.byType(Scaffold));
      await LoginRequiredDialog.show(context);
      await tester.pumpAndSettle();

      // Verify dialog is shown
      expect(find.byType(LoginRequiredDialog), findsOneWidget);

      // Tap cancel button
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Verify dialog is closed
      expect(find.byType(LoginRequiredDialog), findsNothing);
    });
  });
}
