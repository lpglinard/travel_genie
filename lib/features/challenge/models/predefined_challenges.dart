import 'challenge.dart';

// Predefined challenges based on the new requirements
class PredefinedChallenges {
  static List<Challenge> getActiveChallenges() {
    return [
      Challenge(
        id: "create_account",
        titleKey: "challengeCreateAccountTitle",
        descriptionKey: "challengeCreateAccountDescription",
        goal: 1,
        type: "create_account",
        isActive: true,
        endDate: 9999999999999,
        displayOrder: 1,
        rewardType: "badge",
        rewardValue: "starter_badge",
      ),
      Challenge(
        id: "complete_profile",
        titleKey: "challengeCompleteProfileTitle",
        descriptionKey: "challengeCompleteProfileDescription",
        goal: 1,
        type: "complete_profile",
        isActive: true,
        endDate: 9999999999999,
        displayOrder: 2,
        rewardType: "unlock",
        rewardValue: "personalized_recommendations",
      ),
      Challenge(
        id: "create_trip",
        titleKey: "challengeCreateTripTitle",
        descriptionKey: "challengeCreateTripDescription",
        goal: 1,
        type: "create_trip",
        isActive: true,
        endDate: 9999999999999,
        displayOrder: 3,
        rewardType: "progress",
        rewardValue: "trip_started",
      ),
      Challenge(
        id: "save_place",
        titleKey: "challengeSavePlaceTitle",
        descriptionKey: "challengeSavePlaceDescription",
        goal: 1,
        type: "save_place",
        isActive: true,
        endDate: 9999999999999,
        displayOrder: 4,
        rewardType: "badge",
        rewardValue: "explorer_badge",
      ),
      Challenge(
        id: "generate_itinerary",
        titleKey: "challengeGenerateItineraryTitle",
        descriptionKey: "challengeGenerateItineraryDescription",
        goal: 1,
        type: "generate_itinerary",
        isActive: true,
        endDate: 9999999999999,
        displayOrder: 5,
        rewardType: "badge",
        rewardValue: "ai_master_badge",
      ),
    ];
  }
}
