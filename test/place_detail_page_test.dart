import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_genie/models/location.dart';
import 'package:travel_genie/models/place.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:travel_genie/l10n/app_localizations.dart';
import 'package:travel_genie/pages/place_detail_page.dart';

void main() {
  testWidgets('shows basic place information', (tester) async {
    final place = Place(
      placeId: '1',
      displayName: 'Test Place',
      displayNameLanguageCode: 'en',
      formattedAddress: '123 Street',
      googleMapsUri: 'https://maps.google.com/?q=1',
      location: const Location(lat: 0, lng: 0),
    );

    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('pt')],
      home: PlaceDetailPage(place: place),
    ));

    // The title is now in a Text widget, not in an AppBar
    expect(find.text('Test Place'), findsOneWidget);
    expect(find.text('123 Street'), findsOneWidget);
  });

  testWidgets('shows extended place information when available', (tester) async {
    final place = Place(
      placeId: '1',
      displayName: 'Test Place',
      displayNameLanguageCode: 'en',
      formattedAddress: '123 Street',
      googleMapsUri: 'https://maps.google.com/?q=1',
      websiteUri: 'https://example.com',
      types: const ['restaurant', 'food'],
      rating: 4.5,
      userRatingCount: 123,
      location: const Location(lat: 0, lng: 0),
      openingHours: const ['Monday: 9AM-5PM', 'Tuesday: 9AM-5PM'],
      generativeSummary: 'This is a great place to visit.',
      disclosureText: 'AI generated content',
    );

    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('pt')],
      home: PlaceDetailPage(place: place),
    ));

    // Basic information
    expect(find.text('Test Place'), findsOneWidget);
    expect(find.text('123 Street'), findsOneWidget);

    // Rating and reviews
    expect(find.text('4.5'), findsOneWidget);
    expect(find.text('(123 reviews)'), findsOneWidget);

    // Types
    expect(find.text('RESTAURANT'), findsOneWidget);

    // Opening hours
    // Check for either Open Now or Closed Now
    expect(
      find.text('Open Now').evaluate().isNotEmpty || 
      find.text('Closed Now').evaluate().isNotEmpty,
      isTrue
    );
    expect(find.text('Tap for hours'), findsOneWidget);

    // Additional information
    expect(find.text('Additional Information'), findsOneWidget);
    expect(find.text('Price'), findsOneWidget);
    expect(find.text('Free'), findsOneWidget);
    expect(find.text('Average Visit Time'), findsOneWidget);
    expect(find.text('1-2 hours'), findsOneWidget);

    // Website button
    expect(find.text('Website'), findsOneWidget);
    expect(find.text('Visit official website'), findsOneWidget);

    // Google Maps
    expect(find.text('View on Google Maps'), findsOneWidget);
    expect(find.text('Open in external app'), findsOneWidget);

    // Map preview
    expect(find.text('Location'), findsOneWidget);
    expect(find.text('Open in Google Maps'), findsOneWidget);

    // Description
    expect(find.text('Description'), findsOneWidget);
    expect(find.text('This is a great place to visit.'), findsOneWidget);
    expect(find.text('AI generated content'), findsOneWidget);

    // Action buttons
    expect(find.text('Save'), findsOneWidget);
    expect(find.text('Add to Itinerary'), findsOneWidget);
  });

  testWidgets('tests interaction with UI elements', (tester) async {
    final place = Place(
      placeId: '1',
      displayName: 'Test Place',
      displayNameLanguageCode: 'en',
      formattedAddress: '123 Street',
      googleMapsUri: 'https://maps.google.com/?q=1',
      websiteUri: 'https://example.com',
      types: const ['restaurant', 'food'],
      rating: 4.5,
      userRatingCount: 123,
      location: const Location(lat: 0, lng: 0),
      openingHours: const ['Monday: 9AM-5PM', 'Tuesday: 9AM-5PM'],
      generativeSummary: 'This is a great place to visit.',
      disclosureText: 'AI generated content',
    );

    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('pt')],
      home: PlaceDetailPage(place: place),
    ));

    // Test back button
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);

    // Test share button
    expect(find.byIcon(Icons.share), findsOneWidget);

    // Test Save button
    await tester.tap(find.text('Save'));
    await tester.pump();

    // Test Add to Itinerary button
    await tester.tap(find.text('Add to Itinerary'));
    await tester.pump();
  });
}
