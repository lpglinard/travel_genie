import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../../lib/models/place.dart';
import '../../lib/models/location.dart';
import '../../lib/widgets/search_results/search_result_card.dart';
import '../../lib/providers/user_providers.dart';
import '../../lib/services/firestore_service.dart';
import '../../lib/l10n/app_localizations.dart';

// Mock FirestoreService for testing
class MockFirestoreService extends FirestoreService {
  MockFirestoreService() : super(FirebaseFirestore.instance);

  @override
  Future<bool> isPlaceSaved(String userId, String placeId) async {
    return false; // Default to not saved for testing
  }

  @override
  Future<void> savePlace(String userId, Place place) async {
    // Mock implementation - do nothing
  }

  @override
  Future<void> removePlace(String userId, String placeId) async {
    // Mock implementation - do nothing
  }
}

void main() {
  group('SearchResultCard', () {
    late Place testPlace;

    setUp(() {
      testPlace = Place(
        placeId: 'test_place_id',
        displayName: 'Test Place',
        displayNameLanguageCode: 'en',
        formattedAddress: 'Test Address, Test City',
        googleMapsUri: 'https://maps.google.com/test',
        location: Location(lat: 0.0, lng: 0.0),
        photos: [],
        types: ['restaurant'],
        rating: 4.5,
      );
    });

    testWidgets('should render SearchResultCard without errors', (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              firestoreServiceProvider.overrideWith((ref) => MockFirestoreService()),
            ],
            child: MaterialApp(
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
                body: SearchResultCard(
                  place: testPlace,
                  index: 0,
                  query: 'test query',
                ),
              ),
            ),
          ),
        );

        // Verify that the widget renders without errors
        expect(find.byType(SearchResultCard), findsOneWidget);

        // Verify that the place name is displayed
        expect(find.text('Test Place'), findsOneWidget);

        // Verify that the save button is present
        expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      });
    });

    testWidgets('should show save button for places with photos', (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              firestoreServiceProvider.overrideWith((ref) => MockFirestoreService()),
            ],
            child: MaterialApp(
              home: Scaffold(
                body: SearchResultCard(
                  place: testPlace,
                  index: 0,
                  query: 'test query',
                ),
              ),
            ),
          ),
        );

        // Verify that the save button is present
        expect(find.byIcon(Icons.favorite_border), findsOneWidget);
      });
    });
  });
}
