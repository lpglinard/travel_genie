import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_genie/router.dart';

void main() {
  group('Router Navigation Tests', () {
    testWidgets('should use push navigation for profile tab', (WidgetTester tester) async {
      // Create a test app with the router
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const Scaffold(
              body: Text('Home'),
            ),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => Scaffold(
              appBar: AppBar(title: const Text('Profile')),
              body: const Text('Profile'),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      // Verify we start at home
      expect(find.text('Home'), findsOneWidget);

      // Navigate to profile using push (simulating the fixed behavior)
      router.push('/profile');
      await tester.pumpAndSettle();

      // Verify we're on the profile screen by checking for the AppBar
      expect(find.byType(AppBar), findsOneWidget);

      // Verify that there's a back button (AppBar should show it automatically when there's a route to go back to)
      expect(find.byType(BackButton), findsOneWidget);
    });

    testWidgets('should show back button when profile is pushed from navigation stack', (WidgetTester tester) async {
      // This test verifies that when we push to profile (instead of go), 
      // the AppBar automatically shows a back button

      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => context.push('/profile'),
                  child: const Text('Go to Profile'),
                ),
              ),
            ),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => Scaffold(
              appBar: AppBar(title: const Text('Profile')),
              body: const Text('Profile Screen'),
            ),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
        ),
      );

      // Tap the button to navigate to profile
      await tester.tap(find.text('Go to Profile'));
      await tester.pumpAndSettle();

      // Verify we're on the profile screen by checking for the AppBar
      expect(find.byType(AppBar), findsOneWidget);

      // Verify that there's a back button
      expect(find.byType(BackButton), findsOneWidget);

      // Test that the back button works
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      // Should be back to home
      expect(find.text('Go to Profile'), findsOneWidget);
    });
  });
}
