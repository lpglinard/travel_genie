import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_genie/models/place.dart';
import 'package:travel_genie/models/place_categories.dart';
import 'package:travel_genie/models/location.dart';
import 'package:travel_genie/pages/place_detail_page.dart';

void main() {
  group('Place Detail Back Navigation Tests', () {
    testWidgets('Back button should navigate to previous screen correctly', (WidgetTester tester) async {
      // Create a test place
      final testPlace = Place(
        placeId: 'test-place-id',
        displayName: 'Test Place',
        displayNameLanguageCode: 'en',
        formattedAddress: '123 Test Street',
        googleMapsUri: 'https://maps.google.com/test',
        category: PlaceCategories.foodAndDrink,
        types: const ['restaurant'],
        location: const Location(lat: 0.0, lng: 0.0),
        orderInDay: 1,
      );

      // Track navigation calls
      String? currentRoute;
      bool backNavigationCalled = false;

      // Create a mock GoRouter with proper navigation stack
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) {
              currentRoute = '/';
              return Scaffold(
                body: Column(
                  children: [
                    const Text('Home Page'),
                    ElevatedButton(
                      onPressed: () => context.go('/trip/test-trip'),
                      child: const Text('Go to Trip'),
                    ),
                  ],
                ),
              );
            },
          ),
          GoRoute(
            path: '/trip/:id',
            builder: (context, state) {
              currentRoute = '/trip/${state.pathParameters['id']}';
              return Scaffold(
                body: Column(
                  children: [
                    const Text('Trip Details Page'),
                    ElevatedButton(
                      onPressed: () => context.go('/place/test-place-id', extra: testPlace),
                      child: const Text('Go to Place Detail'),
                    ),
                  ],
                ),
              );
            },
          ),
          GoRoute(
            path: '/place/:id',
            builder: (context, state) {
              currentRoute = '/place/${state.pathParameters['id']}';
              final place = state.extra as Place;
              return PlaceDetailPage(place: place);
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
      expect(find.text('Home Page'), findsOneWidget);
      expect(currentRoute, equals('/'));

      // Navigate to trip details
      await tester.tap(find.text('Go to Trip'));
      await tester.pumpAndSettle();

      // Verify we're at trip details
      expect(find.text('Trip Details Page'), findsOneWidget);
      expect(currentRoute, equals('/trip/test-trip'));

      // Navigate to place details
      await tester.tap(find.text('Go to Place Detail'));
      await tester.pumpAndSettle();

      // Verify we're at place details
      expect(find.text('Test Place'), findsOneWidget);
      expect(currentRoute, equals('/place/test-place-id'));

      // Find and tap the back button
      final backButton = find.byIcon(Icons.arrow_back);
      expect(backButton, findsOneWidget);

      await tester.tap(backButton);
      await tester.pumpAndSettle();

      // Verify we're back at trip details (not search results)
      expect(find.text('Trip Details Page'), findsOneWidget);
      expect(currentRoute, equals('/trip/test-trip'));
    });

    testWidgets('Back navigation should work from search results to place details', (WidgetTester tester) async {
      // Create a test place
      final testPlace = Place(
        placeId: 'test-place-id',
        displayName: 'Test Place',
        displayNameLanguageCode: 'en',
        formattedAddress: '123 Test Street',
        googleMapsUri: 'https://maps.google.com/test',
        category: PlaceCategories.foodAndDrink,
        types: const ['restaurant'],
        location: const Location(lat: 0.0, lng: 0.0),
        orderInDay: 1,
      );

      // Track navigation calls
      String? currentRoute;

      // Create a mock GoRouter
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) {
              currentRoute = '/';
              return const Scaffold(body: Text('Home Page'));
            },
          ),
          GoRoute(
            path: '/explore',
            builder: (context, state) {
              currentRoute = '/explore';
              return Scaffold(
                body: Column(
                  children: [
                    const Text('Search Results Page'),
                    ElevatedButton(
                      onPressed: () => context.go('/place/test-place-id', extra: testPlace),
                      child: const Text('Go to Place Detail'),
                    ),
                  ],
                ),
              );
            },
          ),
          GoRoute(
            path: '/place/:id',
            builder: (context, state) {
              currentRoute = '/place/${state.pathParameters['id']}';
              final place = state.extra as Place;
              return PlaceDetailPage(place: place);
            },
          ),
        ],
      );

      // Build the app and navigate to search results
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      // Navigate to search results
      router.go('/explore');
      await tester.pumpAndSettle();

      // Verify we're at search results
      expect(find.text('Search Results Page'), findsOneWidget);
      expect(currentRoute, equals('/explore'));

      // Navigate to place details
      await tester.tap(find.text('Go to Place Detail'));
      await tester.pumpAndSettle();

      // Verify we're at place details
      expect(find.text('Test Place'), findsOneWidget);
      expect(currentRoute, equals('/place/test-place-id'));

      // Find and tap the back button
      final backButton = find.byIcon(Icons.arrow_back);
      expect(backButton, findsOneWidget);

      await tester.tap(backButton);
      await tester.pumpAndSettle();

      // Verify we're back at search results
      expect(find.text('Search Results Page'), findsOneWidget);
      expect(currentRoute, equals('/explore'));
    });
  });
}