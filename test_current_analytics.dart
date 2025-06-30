import 'package:flutter_test/flutter_test.dart';
import 'package:travel_genie/services/analytics_service.dart';

void main() {
  group('Current Analytics Service Test', () {
    late AnalyticsService analyticsService;

    setUp(() {
      analyticsService = AnalyticsService();
    });

    test('should create AnalyticsService instance', () {
      expect(analyticsService, isNotNull);
      expect(analyticsService, isA<AnalyticsService>());
    });

    test('should have observer property', () {
      expect(analyticsService.observer, isNotNull);
    });

    test('should have all authentication methods', () async {
      // Test that methods exist and can be called without throwing
      expect(() => analyticsService.logLogin(), returnsNormally);
      expect(() => analyticsService.logSignUp(), returnsNormally);
      expect(() => analyticsService.logLogout(), returnsNormally);
    });

    test('should have all trip and itinerary methods', () async {
      expect(() => analyticsService.logCreateItinerary(id: 'test', destination: 'Paris'), returnsNormally);
      expect(() => analyticsService.logViewItinerary(id: 'test', destination: 'Paris'), returnsNormally);
      expect(() => analyticsService.logEditItinerary(id: 'test', action: 'add_place'), returnsNormally);
      expect(() => analyticsService.logDeleteItinerary(id: 'test'), returnsNormally);
      expect(() => analyticsService.logShareItinerary(id: 'test', method: 'email'), returnsNormally);
    });

    test('should have all place and location methods', () async {
      expect(() => analyticsService.logSearchPlace(query: 'restaurants', location: 'Paris'), returnsNormally);
      expect(() => analyticsService.logViewPlace(placeId: 'place123', placeName: 'Eiffel Tower', category: 'attraction'), returnsNormally);
      expect(() => analyticsService.logAddPlaceToItinerary(placeId: 'place123', placeName: 'Eiffel Tower', itineraryId: 'trip123'), returnsNormally);
      expect(() => analyticsService.logRemovePlaceFromItinerary(placeId: 'place123', placeName: 'Eiffel Tower', itineraryId: 'trip123'), returnsNormally);
    });

    test('should have AI and optimization methods', () async {
      expect(() => analyticsService.logUseAIOptimizer(itineraryId: 'trip123', optimizationType: 'route'), returnsNormally);
      expect(() => analyticsService.logAIRecommendation(recommendationType: 'place', placeId: 'place123', accepted: 'true'), returnsNormally);
    });

    test('should have user engagement methods', () async {
      expect(() => analyticsService.logScreenView(screenName: 'home'), returnsNormally);
      expect(() => analyticsService.logUserEngagement(engagementType: 'scroll', duration: 30), returnsNormally);
    });

    test('should have app settings methods', () async {
      expect(() => analyticsService.logLanguageChange('en'), returnsNormally);
      expect(() => analyticsService.logThemeChange('dark'), returnsNormally);
    });

    test('should have error and performance methods', () async {
      expect(() => analyticsService.logError(errorType: 'network', errorMessage: 'Connection failed'), returnsNormally);
      expect(() => analyticsService.logPerformanceMetric(metricName: 'load_time', value: 1.5), returnsNormally);
    });

    test('should have user interaction methods', () async {
      expect(() => analyticsService.logButtonTap(buttonName: 'create_trip'), returnsNormally);
      expect(() => analyticsService.logDragStart(itemType: 'place', itemId: 'place123'), returnsNormally);
      expect(() => analyticsService.logDragEnd(itemType: 'place', itemId: 'place123', successful: true), returnsNormally);
      expect(() => analyticsService.logSearchInteraction(action: 'start', query: 'restaurants'), returnsNormally);
      expect(() => analyticsService.logDialogInteraction(dialogType: 'confirmation', action: 'open'), returnsNormally);
      expect(() => analyticsService.logWidgetInteraction(widgetType: 'card', action: 'tap'), returnsNormally);
    });

    test('should have achievement methods', () async {
      expect(() => analyticsService.logUnlockAchievement(achievementId: 'first_trip', achievementName: 'First Trip Created'), returnsNormally);
    });

    test('should have custom event and user property methods', () async {
      expect(() => analyticsService.logCustomEvent(eventName: 'test_event', parameters: {'key': 'value'}), returnsNormally);
      expect(() => analyticsService.setUserProperty(name: 'user_type', value: 'premium'), returnsNormally);
      expect(() => analyticsService.setUserId('user123'), returnsNormally);
    });

    test('should have performance monitoring methods', () {
      expect(() => analyticsService.newTrace('test_trace'), returnsNormally);
      expect(() => analyticsService.startTrace('test_trace'), returnsNormally);
      expect(() => analyticsService.stopTrace('test_trace'), returnsNormally);
    });
  });
}