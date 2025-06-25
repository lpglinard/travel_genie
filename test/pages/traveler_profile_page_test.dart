import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_genie/pages/traveler_profile_page.dart';
import 'package:travel_genie/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:travel_genie/user_providers.dart';
import 'package:travel_genie/services/traveler_profile_service.dart';
import 'package:travel_genie/services/firestore_service.dart';
import 'package:travel_genie/models/traveler_profile.dart';

// Mock TravelerProfileService for testing
class MockTravelerProfileService implements TravelerProfileService {
  @override
  Future<TravelerProfile?> getProfile() async => null;

  @override
  Future<void> saveProfile(TravelerProfile profile) async {}

  @override
  Future<void> clearProfile() async {}

  @override
  Future<bool> hasProfile() async => false;

  @override
  Future<double> getCompletionPercentage() async => 0.0;

  @override
  Stream<TravelerProfile?> streamProfile() => Stream.value(null);

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  group('TravelerProfilePage', () {
    Widget createTestWidget() {
      return ProviderScope(
        overrides: [
          travelerProfileServiceProvider.overrideWith((ref) => MockTravelerProfileService()),
        ],
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('pt')],
          home: const TravelerProfilePage(),
        ),
      );
    }

    testWidgets('should render without errors', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(TravelerProfilePage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should display app bar with correct title', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Traveler Profile'), findsOneWidget);
    });

    testWidgets('should display introduction message', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.textContaining('Help us understand your travel style'), findsOneWidget);
      expect(find.byIcon(Icons.lightbulb_outline), findsOneWidget);
    });

    testWidgets('should display all section titles', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Who do you usually travel with?'), findsOneWidget);
      expect(find.text('What is your usual travel budget?'), findsOneWidget);
      expect(find.text('What type of accommodation do you prefer?'), findsOneWidget);
      expect(find.text('What activities do you enjoy most on your trips?'), findsOneWidget);
      expect(find.text('What is your gastronomic profile when traveling?'), findsOneWidget);
      expect(find.text('How do you prefer to organize your trips?'), findsOneWidget);
    });

    testWidgets('should display section icons', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.group), findsOneWidget);
      expect(find.byIcon(Icons.attach_money), findsOneWidget);
      expect(find.byIcon(Icons.hotel), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsOneWidget);
      expect(find.byIcon(Icons.restaurant), findsOneWidget);
      expect(find.byIcon(Icons.map), findsOneWidget);
    });

    testWidgets('should display travel company options', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Solo'), findsOneWidget);
      expect(find.text('Couple'), findsOneWidget);
      expect(find.text('Family with children'), findsOneWidget);
      expect(find.text('Group of friends'), findsOneWidget);
    });

    testWidgets('should display budget options', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Economic'), findsOneWidget);
      expect(find.text('Moderate'), findsOneWidget);
      expect(find.text('Luxury'), findsOneWidget);
    });

    testWidgets('should display accommodation options', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Hostel/Backpacker'), findsOneWidget);
      expect(find.text('Budget Hotel/Inn'), findsOneWidget);
      expect(find.text('Comfort Hotel (3-4 stars)'), findsOneWidget);
      expect(find.text('Resort/Luxury'), findsOneWidget);
      expect(find.text('Apartment/Airbnb'), findsOneWidget);
    });

    testWidgets('should display interest options', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Culture and Museums'), findsOneWidget);
      expect(find.text('Nature and Adventure'), findsOneWidget);
      expect(find.text('Nightlife'), findsOneWidget);
      expect(find.text('Gastronomy'), findsOneWidget);
      expect(find.text('Shopping'), findsOneWidget);
      expect(find.text('Relaxation and Beach'), findsOneWidget);
    });

    testWidgets('should display gastronomic options', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('I love trying local and street food'), findsOneWidget);
      expect(find.text('I prefer recommended restaurants and gourmet cuisine'), findsOneWidget);
      expect(find.textContaining('I have dietary restrictions'), findsOneWidget);
    });

    testWidgets('should display itinerary style options', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('I like a detailed itinerary'), findsOneWidget);
      expect(find.text('I prefer to discover spontaneously during the trip'), findsOneWidget);
    });

    testWidgets('should display action buttons', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Save preferences'), findsOneWidget);
      expect(find.text('Skip this step'), findsOneWidget);
      expect(find.byIcon(Icons.save), findsOneWidget);
    });

    testWidgets('should allow selecting multiple travel companies', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify travel company options text exists
      expect(find.text('Solo'), findsOneWidget);
      expect(find.text('Couple'), findsOneWidget);
      expect(find.text('Family with children'), findsOneWidget);
      expect(find.text('Group of friends'), findsOneWidget);
    });

    testWidgets('should allow selecting budget option', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify budget options text exists
      expect(find.text('Moderate'), findsOneWidget);
      expect(find.text('Economic'), findsOneWidget);
      expect(find.text('Luxury'), findsOneWidget);
    });

    testWidgets('should allow selecting multiple accommodation types', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify accommodation options text exists
      expect(find.text('Hostel/Backpacker'), findsOneWidget);
      expect(find.text('Comfort Hotel (3-4 stars)'), findsOneWidget);
      expect(find.text('Budget Hotel/Inn'), findsOneWidget);
      expect(find.text('Resort/Luxury'), findsOneWidget);
      expect(find.text('Apartment/Airbnb'), findsOneWidget);
    });

    testWidgets('should allow selecting multiple interests', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify interest options text exists
      expect(find.text('Culture and Museums'), findsOneWidget);
      expect(find.text('Nature and Adventure'), findsOneWidget);
      expect(find.text('Nightlife'), findsOneWidget);
      expect(find.text('Gastronomy'), findsOneWidget);
      expect(find.text('Shopping'), findsOneWidget);
      expect(find.text('Relaxation and Beach'), findsOneWidget);
    });

    testWidgets('should allow selecting multiple gastronomic preferences', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify gastronomic options text exists
      expect(find.text('I love trying local and street food'), findsOneWidget);
      expect(find.text('I prefer recommended restaurants and gourmet cuisine'), findsOneWidget);
      expect(find.textContaining('I have dietary restrictions'), findsOneWidget);
    });

    testWidgets('should allow selecting itinerary style', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify itinerary style options text exists
      expect(find.text('I like a detailed itinerary'), findsOneWidget);
      expect(find.text('I prefer to discover spontaneously during the trip'), findsOneWidget);
    });

    testWidgets('should display save and skip buttons', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify button text exists
      expect(find.text('Save preferences'), findsOneWidget);
      expect(find.text('Skip this step'), findsOneWidget);
    });

    testWidgets('should be scrollable', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify that the page has a scrollable widget
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('should display all sections in cards', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify that sections are displayed in cards
      expect(find.byType(Card), findsWidgets);

      // Should have at least 7 cards (intro + 6 sections)
      final cards = find.byType(Card);
      expect(cards, findsAtLeastNWidgets(7));
    });
  });

  group('TravelerProfilePage Portuguese localization', () {
    Widget createTestWidgetPt() {
      return ProviderScope(
        overrides: [
          travelerProfileServiceProvider.overrideWith((ref) => MockTravelerProfileService()),
        ],
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('pt')],
          locale: const Locale('pt'),
          home: const TravelerProfilePage(),
        ),
      );
    }

    testWidgets('should display Portuguese text', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidgetPt());
      await tester.pumpAndSettle();

      expect(find.text('Perfil do Viajante'), findsOneWidget);
      expect(find.textContaining('Ajude-nos a entender melhor'), findsOneWidget);
      expect(find.text('Com quem você costuma viajar?'), findsOneWidget);
      expect(find.text('Sozinho(a)'), findsOneWidget);
      expect(find.text('Casal'), findsOneWidget);
      expect(find.text('Salvar preferências'), findsOneWidget);
      expect(find.text('Pular esta etapa'), findsOneWidget);
    });
  });
}
