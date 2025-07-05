import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_genie/models/place.dart';
import 'package:travel_genie/models/place_categories.dart';
import 'package:travel_genie/models/location.dart';
import 'package:travel_genie/trip/widgets/trip_itinerary_tab.dart';

void main() {
  group('PlaceTile Navigation Tests', () {
    testWidgets('PlaceTile should navigate to place detail page when tapped', (WidgetTester tester) async {
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
      String? navigatedPath;
      Object? navigatedExtra;

      // Create a mock GoRouter
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const Scaffold(body: Text('Home')),
          ),
          GoRoute(
            path: '/place/:id',
            builder: (context, state) {
              navigatedPath = state.uri.path;
              navigatedExtra = state.extra;
              return const Scaffold(body: Text('Place Detail'));
            },
          ),
        ],
      );

      // Build the widget
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      // Navigate to a page that contains PlaceTile
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: GoRouter(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) => Scaffold(
                    body: PlaceTile(place: testPlace),
                  ),
                ),
                GoRoute(
                  path: '/place/:id',
                  builder: (context, state) {
                    navigatedPath = state.uri.path;
                    navigatedExtra = state.extra;
                    return const Scaffold(body: Text('Place Detail'));
                  },
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the PlaceTile and tap it
      final placeTileFinder = find.byType(ListTile);
      expect(placeTileFinder, findsOneWidget);

      await tester.tap(placeTileFinder);
      await tester.pumpAndSettle();

      // Verify navigation occurred
      expect(navigatedPath, equals('/place/test-place-id'));
      expect(navigatedExtra, equals(testPlace));
    });

    testWidgets('PlaceTile should display place information correctly', (WidgetTester tester) async {
      // Create a test place with rating
      final testPlace = Place(
        placeId: 'test-place-id',
        displayName: 'Amazing Restaurant',
        displayNameLanguageCode: 'en',
        formattedAddress: '456 Food Street',
        googleMapsUri: 'https://maps.google.com/test',
        category: PlaceCategories.foodAndDrink,
        types: const ['restaurant'],
        location: const Location(lat: 0.0, lng: 0.0),
        orderInDay: 1,
        rating: 4.5,
        userRatingCount: 123,
        estimatedDurationMinutes: 90,
      );

      // Build the widget
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: PlaceTile(place: testPlace),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify place information is displayed
      expect(find.text('Amazing Restaurant'), findsOneWidget);
      expect(find.text('456 Food Street'), findsOneWidget);
      expect(find.text('4.5'), findsOneWidget);
      expect(find.text('(123)'), findsOneWidget);
      expect(find.text('90min'), findsOneWidget);
      expect(find.byIcon(Icons.place), findsOneWidget);
      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.byIcon(Icons.access_time), findsOneWidget);
    });
  });
}
