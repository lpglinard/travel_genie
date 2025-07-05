import 'package:flutter_test/flutter_test.dart';
import 'package:travel_genie/models/traveler_profile.dart';
import 'package:travel_genie/services/profile_completeness_service.dart';

void main() {
  group('ProfileCompletenessService', () {
    test('should return 0% for null profile', () {
      final result = ProfileCompletenessService.calculateCompleteness(null);

      expect(result.percentage, equals(0.0));
      expect(result.percentageAsInt, equals(0));
      expect(result.completedFields, equals(0));
      expect(result.totalFields, equals(6));
      expect(result.isComplete, isFalse);
      expect(result.missingFields, hasLength(6));
      expect(result.missingFields, contains('travelCompany'));
      expect(result.missingFields, contains('budget'));
      expect(result.missingFields, contains('accommodationTypes'));
      expect(result.missingFields, contains('interests'));
      expect(result.missingFields, contains('gastronomicPreferences'));
      expect(result.missingFields, contains('itineraryStyle'));
    });

    test('should return 0% for empty profile', () {
      const profile = TravelerProfile();
      final result = ProfileCompletenessService.calculateCompleteness(profile);

      expect(result.percentage, equals(0.0));
      expect(result.percentageAsInt, equals(0));
      expect(result.completedFields, equals(0));
      expect(result.totalFields, equals(6));
      expect(result.isComplete, isFalse);
      expect(result.missingFields, hasLength(6));
    });

    test('should return 100% for complete profile', () {
      const profile = TravelerProfile(
        travelCompany: [TravelCompany.solo],
        budget: TravelBudget.moderate,
        accommodationTypes: [AccommodationType.comfortHotel],
        interests: [TravelInterest.culture],
        gastronomicPreferences: [GastronomicPreference.localFood],
        itineraryStyle: ItineraryStyle.detailed,
      );
      final result = ProfileCompletenessService.calculateCompleteness(profile);

      expect(result.percentage, equals(1.0));
      expect(result.percentageAsInt, equals(100));
      expect(result.completedFields, equals(6));
      expect(result.totalFields, equals(6));
      expect(result.isComplete, isTrue);
      expect(result.missingFields, isEmpty);
    });

    test('should return 50% for half-complete profile', () {
      const profile = TravelerProfile(
        travelCompany: [TravelCompany.couple],
        budget: TravelBudget.luxury,
        accommodationTypes: [AccommodationType.resort],
        // Missing: interests, gastronomicPreferences, itineraryStyle
      );
      final result = ProfileCompletenessService.calculateCompleteness(profile);

      expect(result.percentage, equals(0.5));
      expect(result.percentageAsInt, equals(50));
      expect(result.completedFields, equals(3));
      expect(result.totalFields, equals(6));
      expect(result.isComplete, isFalse);
      expect(result.missingFields, hasLength(3));
      expect(result.missingFields, contains('interests'));
      expect(result.missingFields, contains('gastronomicPreferences'));
      expect(result.missingFields, contains('itineraryStyle'));
    });

    test('should return correct percentage for partially complete profile', () {
      const profile = TravelerProfile(
        travelCompany: [TravelCompany.familyWithChildren],
        interests: [TravelInterest.nature, TravelInterest.relaxation],
        // Missing: budget, accommodationTypes, gastronomicPreferences, itineraryStyle
      );
      final result = ProfileCompletenessService.calculateCompleteness(profile);

      expect(result.percentage, closeTo(0.333, 0.01)); // 2/6 = 0.333...
      expect(result.percentageAsInt, equals(33));
      expect(result.completedFields, equals(2));
      expect(result.totalFields, equals(6));
      expect(result.isComplete, isFalse);
      expect(result.missingFields, hasLength(4));
    });

    test('should match TravelerProfile.isComplete logic', () {
      // Test cases that should match the isComplete getter
      const completeProfile = TravelerProfile(
        travelCompany: [TravelCompany.solo],
        budget: TravelBudget.moderate,
        accommodationTypes: [AccommodationType.comfortHotel],
        interests: [TravelInterest.culture],
        gastronomicPreferences: [GastronomicPreference.localFood],
        itineraryStyle: ItineraryStyle.detailed,
      );

      const incompleteProfile = TravelerProfile(
        travelCompany: [TravelCompany.solo],
        budget: TravelBudget.moderate,
        // Missing other fields
      );

      final completeResult = ProfileCompletenessService.calculateCompleteness(completeProfile);
      final incompleteResult = ProfileCompletenessService.calculateCompleteness(incompleteProfile);

      expect(completeResult.isComplete, equals(completeProfile.isComplete));
      expect(incompleteResult.isComplete, equals(incompleteProfile.isComplete));
    });
  });
}