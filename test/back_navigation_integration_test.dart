import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('Back Navigation Integration Tests', () {
    testWidgets('Context.pop() should work correctly in navigation stack', (WidgetTester tester) async {
      // Track navigation state
      String currentRoute = '/';
      
      // Create a simple router to test navigation behavior
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) {
              currentRoute = '/';
              return Scaffold(
                body: Column(
                  children: [
                    const Text('Home'),
                    ElevatedButton(
                      onPressed: () => context.go('/page1'),
                      child: const Text('Go to Page 1'),
                    ),
                  ],
                ),
              );
            },
          ),
          GoRoute(
            path: '/page1',
            builder: (context, state) {
              currentRoute = '/page1';
              return Scaffold(
                appBar: AppBar(
                  title: const Text('Page 1'),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.pop(),
                  ),
                ),
                body: Column(
                  children: [
                    const Text('Page 1'),
                    ElevatedButton(
                      onPressed: () => context.go('/page2'),
                      child: const Text('Go to Page 2'),
                    ),
                  ],
                ),
              );
            },
          ),
          GoRoute(
            path: '/page2',
            builder: (context, state) {
              currentRoute = '/page2';
              return Scaffold(
                appBar: AppBar(
                  title: const Text('Page 2'),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.pop(),
                  ),
                ),
                body: const Text('Page 2'),
              );
            },
          ),
        ],
      );

      // Build the app
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify we start at home
      expect(find.text('Home'), findsOneWidget);
      expect(currentRoute, equals('/'));

      // Navigate to page 1
      await tester.tap(find.text('Go to Page 1'));
      await tester.pumpAndSettle();

      // Verify we're at page 1
      expect(find.text('Page 1'), findsOneWidget);
      expect(currentRoute, equals('/page1'));

      // Navigate to page 2
      await tester.tap(find.text('Go to Page 2'));
      await tester.pumpAndSettle();

      // Verify we're at page 2
      expect(find.text('Page 2'), findsOneWidget);
      expect(currentRoute, equals('/page2'));

      // Use back button to go back to page 1
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Verify we're back at page 1
      expect(find.text('Page 1'), findsOneWidget);
      expect(currentRoute, equals('/page1'));

      // Use back button to go back to home
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Verify we're back at home
      expect(find.text('Home'), findsOneWidget);
      expect(currentRoute, equals('/'));
    });
  });
}