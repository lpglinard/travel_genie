import 'package:flutter_test/flutter_test.dart';
import 'package:travel_genie/models/traveler_profile.dart';

void main() {
  group('TravelerProfile Model', () {
    test('should create a TravelerProfile with default values', () {
      const profile = TravelerProfile();

      expect(profile.travelCompany, isEmpty);
      expect(profile.budget, isNull);
      expect(profile.accommodationTypes, isEmpty);
      expect(profile.interests, isEmpty);
      expect(profile.gastronomicPreferences, isEmpty);
      expect(profile.itineraryStyle, isNull);
      expect(profile.createdAt, isNull);
      expect(profile.updatedAt, isNull);
      expect(profile.isComplete, isFalse);
    });

    test('should create a complete TravelerProfile', () {
      final now = DateTime.now();
      final profile = TravelerProfile(
        travelCompany: const [TravelCompany.solo, TravelCompany.couple],
        budget: TravelBudget.moderate,
        accommodationTypes: const [AccommodationType.comfortHotel],
        interests: const [TravelInterest.culture, TravelInterest.nature],
        gastronomicPreferences: const [GastronomicPreference.localFood],
        itineraryStyle: ItineraryStyle.detailed,
        createdAt: now,
        updatedAt: now,
      );

      expect(profile.travelCompany, contains(TravelCompany.solo));
      expect(profile.travelCompany, contains(TravelCompany.couple));
      expect(profile.budget, equals(TravelBudget.moderate));
      expect(profile.accommodationTypes, contains(AccommodationType.comfortHotel));
      expect(profile.interests, contains(TravelInterest.culture));
      expect(profile.interests, contains(TravelInterest.nature));
      expect(profile.gastronomicPreferences, contains(GastronomicPreference.localFood));
      expect(profile.itineraryStyle, equals(ItineraryStyle.detailed));
      expect(profile.createdAt, equals(now));
      expect(profile.updatedAt, equals(now));
      expect(profile.isComplete, isTrue);
    });

    test('should serialize to and from JSON correctly', () {
      final now = DateTime.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch);
      final originalProfile = TravelerProfile(
        travelCompany: const [TravelCompany.solo, TravelCompany.familyWithChildren],
        budget: TravelBudget.luxury,
        accommodationTypes: const [AccommodationType.resort, AccommodationType.apartment],
        interests: const [TravelInterest.relaxation, TravelInterest.gastronomy],
        gastronomicPreferences: const [GastronomicPreference.gourmetRestaurants, GastronomicPreference.dietaryRestrictions],
        itineraryStyle: ItineraryStyle.spontaneous,
        createdAt: now,
        updatedAt: now,
      );

      final json = originalProfile.toJson();
      final deserializedProfile = TravelerProfile.fromJson(json);

      expect(deserializedProfile.travelCompany, equals(originalProfile.travelCompany));
      expect(deserializedProfile.budget, equals(originalProfile.budget));
      expect(deserializedProfile.accommodationTypes, equals(originalProfile.accommodationTypes));
      expect(deserializedProfile.interests, equals(originalProfile.interests));
      expect(deserializedProfile.gastronomicPreferences, equals(originalProfile.gastronomicPreferences));
      expect(deserializedProfile.itineraryStyle, equals(originalProfile.itineraryStyle));
      expect(deserializedProfile.createdAt, equals(originalProfile.createdAt));
      expect(deserializedProfile.updatedAt, equals(originalProfile.updatedAt));
    });
  });
}