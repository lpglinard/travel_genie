import 'package:flutter_test/flutter_test.dart';
import 'package:travel_genie/models/traveler_profile.dart';

void main() {
  group('TravelerProfile Model Tests', () {
    test('should handle completion percentage calculation correctly', () {
      // Test the completion percentage calculation logic
      const emptyProfile = TravelerProfile();
      const partialProfile = TravelerProfile(
        travelCompany: [TravelCompany.solo],
        budget: TravelBudget.moderate,
      );
      const completeProfile = TravelerProfile(
        travelCompany: [TravelCompany.solo],
        budget: TravelBudget.moderate,
        accommodationTypes: [AccommodationType.comfortHotel],
        interests: [TravelInterest.culture],
        gastronomicPreferences: [GastronomicPreference.localFood],
        itineraryStyle: ItineraryStyle.detailed,
      );

      // Test empty profile
      expect(emptyProfile.isComplete, isFalse);

      // Test partial profile
      expect(partialProfile.isComplete, isFalse);

      // Test complete profile
      expect(completeProfile.isComplete, isTrue);
    });
  });
}
