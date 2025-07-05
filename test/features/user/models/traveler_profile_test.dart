import 'package:flutter_test/flutter_test.dart';
import 'package:travel_genie/models/traveler_profile.dart';

void main() {
  group('TravelerProfile', () {
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
      // Use a DateTime with millisecond precision to avoid precision loss
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

    test('should handle empty JSON correctly', () {
      final profile = TravelerProfile.fromJson({});

      expect(profile.travelCompany, isEmpty);
      expect(profile.budget, isNull);
      expect(profile.accommodationTypes, isEmpty);
      expect(profile.interests, isEmpty);
      expect(profile.gastronomicPreferences, isEmpty);
      expect(profile.itineraryStyle, isNull);
      expect(profile.createdAt, isNull);
      expect(profile.updatedAt, isNull);
    });

    test('should handle invalid enum values in JSON gracefully', () {
      final json = {
        'travelCompany': ['solo', 'invalid_company'],
        'budget': 'invalid_budget',
        'accommodationTypes': ['hostel', 'invalid_accommodation'],
        'interests': ['culture', 'invalid_interest'],
        'gastronomicPreferences': ['localFood', 'invalid_preference'],
        'itineraryStyle': 'invalid_style',
      };

      final profile = TravelerProfile.fromJson(json);

      expect(profile.travelCompany, contains(TravelCompany.solo));
      expect(profile.travelCompany.length, equals(2)); // Valid value + fallback for invalid
      expect(profile.budget, equals(TravelBudget.moderate)); // Default fallback
      expect(profile.accommodationTypes, contains(AccommodationType.hostel));
      expect(profile.accommodationTypes.length, equals(2)); // Valid value + fallback for invalid
      expect(profile.interests, contains(TravelInterest.culture));
      expect(profile.interests.length, equals(2)); // Valid value + fallback for invalid
      expect(profile.gastronomicPreferences, contains(GastronomicPreference.localFood));
      expect(profile.gastronomicPreferences.length, equals(2)); // Valid value + fallback for invalid
      expect(profile.itineraryStyle, equals(ItineraryStyle.detailed)); // Default fallback
    });

    test('should create a copy with updated values', () {
      const originalProfile = TravelerProfile(
        travelCompany: [TravelCompany.solo],
        budget: TravelBudget.economic,
      );

      final updatedProfile = originalProfile.copyWith(
        travelCompany: const [TravelCompany.couple, TravelCompany.friendsGroup],
        budget: TravelBudget.luxury,
        accommodationTypes: const [AccommodationType.resort],
      );

      expect(updatedProfile.travelCompany, contains(TravelCompany.couple));
      expect(updatedProfile.travelCompany, contains(TravelCompany.friendsGroup));
      expect(updatedProfile.budget, equals(TravelBudget.luxury));
      expect(updatedProfile.accommodationTypes, contains(AccommodationType.resort));

      // Original should remain unchanged
      expect(originalProfile.travelCompany, contains(TravelCompany.solo));
      expect(originalProfile.budget, equals(TravelBudget.economic));
      expect(originalProfile.accommodationTypes, isEmpty);
    });

    test('should correctly determine if profile is complete', () {
      const incompleteProfile1 = TravelerProfile(); // All empty
      expect(incompleteProfile1.isComplete, isFalse);

      const incompleteProfile2 = TravelerProfile(
        travelCompany: [TravelCompany.solo],
        // Missing other required fields
      );
      expect(incompleteProfile2.isComplete, isFalse);

      const completeProfile = TravelerProfile(
        travelCompany: [TravelCompany.solo],
        budget: TravelBudget.moderate,
        accommodationTypes: [AccommodationType.comfortHotel],
        interests: [TravelInterest.culture],
        gastronomicPreferences: [GastronomicPreference.localFood],
        itineraryStyle: ItineraryStyle.detailed,
      );
      expect(completeProfile.isComplete, isTrue);
    });

    test('should have correct equality and hashCode', () {
      final now = DateTime.now();
      final profile1 = TravelerProfile(
        travelCompany: const [TravelCompany.solo],
        budget: TravelBudget.moderate,
        createdAt: now,
      );
      final profile2 = TravelerProfile(
        travelCompany: const [TravelCompany.solo],
        budget: TravelBudget.moderate,
        createdAt: now,
      );
      final profile3 = TravelerProfile(
        travelCompany: const [TravelCompany.couple],
        budget: TravelBudget.moderate,
        createdAt: now,
      );

      expect(profile1, equals(profile2));
      expect(profile1.hashCode, equals(profile2.hashCode));
      expect(profile1, isNot(equals(profile3)));
      expect(profile1.hashCode, isNot(equals(profile3.hashCode)));
    });
  });

  group('TravelCompany enum', () {
    test('should have all expected values', () {
      expect(TravelCompany.values, hasLength(4));
      expect(TravelCompany.values, contains(TravelCompany.solo));
      expect(TravelCompany.values, contains(TravelCompany.couple));
      expect(TravelCompany.values, contains(TravelCompany.familyWithChildren));
      expect(TravelCompany.values, contains(TravelCompany.friendsGroup));
    });
  });

  group('TravelBudget enum', () {
    test('should have all expected values', () {
      expect(TravelBudget.values, hasLength(3));
      expect(TravelBudget.values, contains(TravelBudget.economic));
      expect(TravelBudget.values, contains(TravelBudget.moderate));
      expect(TravelBudget.values, contains(TravelBudget.luxury));
    });
  });

  group('AccommodationType enum', () {
    test('should have all expected values', () {
      expect(AccommodationType.values, hasLength(5));
      expect(AccommodationType.values, contains(AccommodationType.hostel));
      expect(AccommodationType.values, contains(AccommodationType.budgetHotel));
      expect(AccommodationType.values, contains(AccommodationType.comfortHotel));
      expect(AccommodationType.values, contains(AccommodationType.resort));
      expect(AccommodationType.values, contains(AccommodationType.apartment));
    });
  });

  group('TravelInterest enum', () {
    test('should have all expected values', () {
      expect(TravelInterest.values, hasLength(6));
      expect(TravelInterest.values, contains(TravelInterest.culture));
      expect(TravelInterest.values, contains(TravelInterest.nature));
      expect(TravelInterest.values, contains(TravelInterest.nightlife));
      expect(TravelInterest.values, contains(TravelInterest.gastronomy));
      expect(TravelInterest.values, contains(TravelInterest.shopping));
      expect(TravelInterest.values, contains(TravelInterest.relaxation));
    });
  });

  group('GastronomicPreference enum', () {
    test('should have all expected values', () {
      expect(GastronomicPreference.values, hasLength(3));
      expect(GastronomicPreference.values, contains(GastronomicPreference.localFood));
      expect(GastronomicPreference.values, contains(GastronomicPreference.gourmetRestaurants));
      expect(GastronomicPreference.values, contains(GastronomicPreference.dietaryRestrictions));
    });
  });

  group('ItineraryStyle enum', () {
    test('should have all expected values', () {
      expect(ItineraryStyle.values, hasLength(2));
      expect(ItineraryStyle.values, contains(ItineraryStyle.detailed));
      expect(ItineraryStyle.values, contains(ItineraryStyle.spontaneous));
    });
  });
}
