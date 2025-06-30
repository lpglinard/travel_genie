import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:network_image_mock/network_image_mock.dart';

import 'package:travel_genie/widgets/home/active_trip_section.dart';
import 'package:travel_genie/models/trip.dart';
import 'package:travel_genie/l10n/app_localizations.dart';

void main() {
  group('ActiveTripSection', () {
    testWidgets('displays horizontal list of trip cards', (WidgetTester tester) async {
      final trips = [
        Trip(
          id: '1',
          title: 'Trip to Paris',
          description: 'Amazing trip to Paris',
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 7)),
          coverImageUrl: 'https://example.com/paris.jpg',
          userId: 'user1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        Trip(
          id: '2',
          title: 'Trip to Tokyo',
          description: 'Wonderful trip to Tokyo',
          startDate: DateTime.now().add(const Duration(days: 10)),
          endDate: DateTime.now().add(const Duration(days: 17)),
          coverImageUrl: 'https://example.com/tokyo.jpg',
          userId: 'user1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      await mockNetworkImagesFor(() async {
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
              locale: const Locale('en'),
              home: Scaffold(
                body: ActiveTripSection(trips: trips),
              ),
            ),
          ),
        );

        await tester.pump();

        // Verify that the section title is displayed (plural for 2 trips)
        expect(find.text('Your Active Trips'), findsOneWidget);

        // Verify that both trip cards are displayed
        expect(find.text('Trip to Paris'), findsOneWidget);
        expect(find.text('Trip to Tokyo'), findsOneWidget);

        // Verify that the horizontal list is scrollable
        expect(find.byType(ListView), findsOneWidget);
        final listView = tester.widget<ListView>(find.byType(ListView));
        expect(listView.scrollDirection, Axis.horizontal);
      });
    });

    testWidgets('displays empty state when no trips', (WidgetTester tester) async {
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
            locale: const Locale('en'),
            home: Scaffold(
              body: ActiveTripSection(trips: const []),
            ),
          ),
        ),
      );

      await tester.pump();

      // Verify that the section title is still displayed (plural for 0 trips)
      expect(find.text('Your Active Trips'), findsOneWidget);

      // Verify that no trip cards are displayed
      expect(find.byType(Card), findsNothing);
    });

    testWidgets('displays singular title for one trip', (WidgetTester tester) async {
      final trips = [
        Trip(
          id: '1',
          title: 'Trip to Paris',
          description: 'Amazing trip to Paris',
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 7)),
          coverImageUrl: 'https://example.com/paris.jpg',
          userId: 'user1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      await mockNetworkImagesFor(() async {
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
              locale: const Locale('en'),
              home: Scaffold(
                body: ActiveTripSection(trips: trips),
              ),
            ),
          ),
        );

        await tester.pump();

        // Verify that the section title is displayed (singular for 1 trip)
        expect(find.text('Your Active Trip'), findsOneWidget);

        // Verify that the trip card is displayed
        expect(find.text('Trip to Paris'), findsOneWidget);

        // Verify that the horizontal list is scrollable
        expect(find.byType(ListView), findsOneWidget);
        final listView = tester.widget<ListView>(find.byType(ListView));
        expect(listView.scrollDirection, Axis.horizontal);
      });
    });
  });
}
