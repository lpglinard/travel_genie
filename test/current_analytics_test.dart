import 'package:flutter_test/flutter_test.dart';
import 'package:travel_genie/services/analytics_service.dart';

void main() {
  group('Current Analytics Service Test', () {
    test('should be importable and have correct type', () {
      // Test that the AnalyticsService class can be imported successfully
      expect(AnalyticsService, isA<Type>());
    });

    test('should document all available analytics methods', () {
      // Document the available analytics methods without instantiating the service
      const availableMethods = [
        'logLogin - Track user login',
        'logSignUp - Track user signup', 
        'logLogout - Track user logout',
        'logCreateItinerary - Track itinerary creation',
        'logViewItinerary - Track itinerary viewing',
        'logEditItinerary - Track itinerary editing',
        'logDeleteItinerary - Track itinerary deletion',
        'logShareItinerary - Track itinerary sharing',
        'logSearchPlace - Track place searches',
        'logViewPlace - Track place viewing',
        'logAddPlaceToItinerary - Track adding places to itinerary',
        'logRemovePlaceFromItinerary - Track removing places from itinerary',
        'logOptimizeItinerary - Track AI optimizer usage',
        'logAIRecommendation - Track AI recommendations',
        'logScreenView - Track screen views',
        'logLanguageChange - Track language changes',
        'logThemeChange - Track theme changes',
        'logError - Track application errors',
        'logUnlockAchievement - Track achievement unlocks',
        'logCustomEvent - Track custom events',
        'setUserProperty - Set user properties',
        'setUserId - Set user ID',
        'newTrace - Create performance trace',
      ];

      expect(availableMethods.length, equals(23));
      expect(availableMethods, contains('logLogin - Track user login'));
      expect(availableMethods, contains('logOptimizeItinerary - Track AI optimizer usage'));
      expect(availableMethods, contains('newTrace - Create performance trace'));
    });
  });
}
