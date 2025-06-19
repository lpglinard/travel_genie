import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_genie/models/location.dart';
import 'package:travel_genie/models/place.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:travel_genie/l10n/app_localizations.dart';
import 'package:travel_genie/pages/place_detail_page.dart';

void main() {
  testWidgets('shows basic place information', (tester) async {
    const place = Place(
      placeId: '1',
      displayName: 'Test Place',
      formattedAddress: '123 Street',
      googleMapsUri: 'https://maps.google.com/?q=1',
      location: Location(lat: 0, lng: 0),
    );

    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('pt')],
      home: const PlaceDetailPage(place: place),
    ));

    expect(find.text('Test Place'), findsOneWidget);
    expect(find.text('123 Street'), findsOneWidget);
  });
}
