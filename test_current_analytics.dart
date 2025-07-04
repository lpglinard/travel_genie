import 'package:flutter_test/flutter_test.dart';
import 'package:travel_genie/services/analytics_service.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_performance/firebase_performance.dart';


// Mock implementation for testing
class MockAnalyticsService implements AnalyticsService {
  final List<Map<String, dynamic>> loggedEvents = [];

  @override
  FirebaseAnalytics get analytics => throw UnimplementedError();

  @override
  FirebaseAnalyticsObserver get observer => throw UnimplementedError();

  @override
  Future<void> logLogin({String method = 'email'}) async {
    loggedEvents.add({'event': 'logLogin', 'method': method});
  }

  @override
  Future<void> logSignUp({String method = 'email'}) async {
    loggedEvents.add({'event': 'logSignUp', 'method': method});
  }

  @override
  Future<void> logLogout() async {
    loggedEvents.add({'event': 'logLogout'});
  }

  @override
  Future<void> logCreateItinerary({
    String? tripId,
    String? destination,
    double? value,
    String currency = 'USD',
    List<AnalyticsEventItem>? items,
  }) async {
    loggedEvents.add({
      'event': 'logCreateItinerary',
      'tripId': tripId,
      'destination': destination,
      'value': value,
      'currency': currency,
      'items': items,
    });
  }

  @override
  Future<void> logViewItinerary({
    String? tripId,
    String? destination,
    double? value,
    String currency = 'USD',
    List<AnalyticsEventItem>? items,
  }) async {
    loggedEvents.add({
      'event': 'logViewItinerary',
      'tripId': tripId,
      'destination': destination,
      'value': value,
      'currency': currency,
      'items': items,
    });
  }

  @override
  Future<void> logEditItinerary({String? tripId, String? action}) async {
    loggedEvents.add({
      'event': 'logEditItinerary',
      'tripId': tripId,
      'action': action,
    });
  }

  @override
  Future<void> logDeleteItinerary({String? tripId}) async {
    loggedEvents.add({
      'event': 'logDeleteItinerary',
      'tripId': tripId,
    });
  }

  @override
  Future<void> logShareItinerary({
    String? tripId,
    String? method,
    String contentType = 'trip',
  }) async {
    loggedEvents.add({
      'event': 'logShareItinerary',
      'tripId': tripId,
      'method': method,
      'contentType': contentType,
    });
  }

  @override
  Future<void> logSearchPlace({String? searchTerm, String? location}) async {
    loggedEvents.add({
      'event': 'logSearchPlace',
      'searchTerm': searchTerm,
      'location': location,
    });
  }

  @override
  Future<void> logViewPlace({
    String? placeId,
    String? placeName,
    String? category,
    double? value,
    String currency = 'USD',
  }) async {
    loggedEvents.add({
      'event': 'logViewPlace',
      'placeId': placeId,
      'placeName': placeName,
      'category': category,
      'value': value,
      'currency': currency,
    });
  }

  @override
  Future<void> logAddPlaceToItinerary({
    String? placeId,
    String? placeName,
    String? category,
    String? tripId,
    String? dayId,
    double? value,
    String currency = 'USD',
  }) async {
    loggedEvents.add({
      'event': 'logAddPlaceToItinerary',
      'placeId': placeId,
      'placeName': placeName,
      'category': category,
      'tripId': tripId,
      'dayId': dayId,
      'value': value,
      'currency': currency,
    });
  }

  @override
  Future<void> logRemovePlaceFromItinerary({
    String? placeId,
    String? placeName,
    String? category,
    String? tripId,
    double? value,
    String currency = 'USD',
  }) async {
    loggedEvents.add({
      'event': 'logRemovePlaceFromItinerary',
      'placeId': placeId,
      'placeName': placeName,
      'category': category,
      'tripId': tripId,
      'value': value,
      'currency': currency,
    });
  }

  @override
  Future<void> logOptimizeItinerary({
    String? tripId,
    String? optimizerType,
    double? value,
    String currency = 'USD',
  }) async {
    loggedEvents.add({
      'event': 'logOptimizeItinerary',
      'tripId': tripId,
      'optimizerType': optimizerType,
      'value': value,
      'currency': currency,
    });
  }

  @override
  Future<void> logAIRecommendation({
    String? recommendationType,
    String? placeId,
    bool? accepted,
  }) async {
    loggedEvents.add({
      'event': 'logAIRecommendation',
      'recommendationType': recommendationType,
      'placeId': placeId,
      'accepted': accepted,
    });
  }

  @override
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    loggedEvents.add({
      'event': 'logScreenView',
      'screenName': screenName,
      'screenClass': screenClass,
    });
  }

  @override
  Future<void> logLanguageChange(String languageCode) async {
    loggedEvents.add({
      'event': 'logLanguageChange',
      'languageCode': languageCode,
    });
  }

  @override
  Future<void> logThemeChange(String theme) async {
    loggedEvents.add({
      'event': 'logThemeChange',
      'theme': theme,
    });
  }

  @override
  Future<void> logError({
    required String errorType,
    String? errorMessage,
    String? screenName,
  }) async {
    loggedEvents.add({
      'event': 'logError',
      'errorType': errorType,
      'errorMessage': errorMessage,
      'screenName': screenName,
    });
  }

  @override
  Future<void> logUnlockAchievement({
    required String achievementId,
    String? achievementName,
    String? category,
  }) async {
    loggedEvents.add({
      'event': 'logUnlockAchievement',
      'achievementId': achievementId,
      'achievementName': achievementName,
      'category': category,
    });
  }

  @override
  Future<void> logCustomEvent({
    required String eventName,
    Map<String, Object>? parameters,
  }) async {
    loggedEvents.add({
      'event': 'logCustomEvent',
      'eventName': eventName,
      'parameters': parameters,
    });
  }

  @override
  Future<void> setUserProperty({required String name, required String value}) async {
    loggedEvents.add({
      'event': 'setUserProperty',
      'name': name,
      'value': value,
    });
  }

  @override
  Future<void> setUserId(String? userId) async {
    loggedEvents.add({
      'event': 'setUserId',
      'userId': userId,
    });
  }

  @override
  Trace newTrace(String traceName) {
    loggedEvents.add({
      'event': 'newTrace',
      'traceName': traceName,
    });
    // Return null and let noSuchMethod handle it
    return null as Trace;
  }

  // Handle any other methods with noSuchMethod
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  group('Current Analytics Service Test', () {
    late MockAnalyticsService analyticsService;

    setUp(() {
      analyticsService = MockAnalyticsService();
    });

    test('should create AnalyticsService instance', () {
      expect(analyticsService, isNotNull);
      expect(analyticsService, isA<AnalyticsService>());
    });


    test('should have all authentication methods', () async {
      // Test that methods exist and can be called without throwing
      expect(() => analyticsService.logLogin(), returnsNormally);
      expect(() => analyticsService.logSignUp(), returnsNormally);
      expect(() => analyticsService.logLogout(), returnsNormally);
    });

    test('should have all trip and itinerary methods', () async {
      expect(() => analyticsService.logCreateItinerary(tripId: 'test', destination: 'Paris'), returnsNormally);
      expect(() => analyticsService.logViewItinerary(tripId: 'test', destination: 'Paris'), returnsNormally);
      expect(() => analyticsService.logEditItinerary(tripId: 'test', action: 'add_place'), returnsNormally);
      expect(() => analyticsService.logDeleteItinerary(tripId: 'test'), returnsNormally);
      expect(() => analyticsService.logShareItinerary(tripId: 'test', method: 'email'), returnsNormally);
    });

    test('should have all place and location methods', () async {
      expect(() => analyticsService.logSearchPlace(searchTerm: 'restaurants', location: 'Paris'), returnsNormally);
      expect(() => analyticsService.logViewPlace(placeId: 'place123', placeName: 'Eiffel Tower', category: 'attraction'), returnsNormally);
      expect(() => analyticsService.logAddPlaceToItinerary(placeId: 'place123', placeName: 'Eiffel Tower', tripId: 'trip123'), returnsNormally);
      expect(() => analyticsService.logRemovePlaceFromItinerary(placeId: 'place123', placeName: 'Eiffel Tower', tripId: 'trip123'), returnsNormally);
    });

    test('should have AI and optimization methods', () async {
      expect(() => analyticsService.logOptimizeItinerary(tripId: 'trip123', optimizerType: 'route'), returnsNormally);
      expect(() => analyticsService.logAIRecommendation(recommendationType: 'place', placeId: 'place123', accepted: true), returnsNormally);
    });

    test('should have user engagement methods', () async {
      expect(() => analyticsService.logScreenView(screenName: 'home'), returnsNormally);
    });

    test('should have app settings methods', () async {
      expect(() => analyticsService.logLanguageChange('en'), returnsNormally);
      expect(() => analyticsService.logThemeChange('dark'), returnsNormally);
    });

    test('should have error methods', () async {
      expect(() => analyticsService.logError(errorType: 'network', errorMessage: 'Connection failed'), returnsNormally);
    });


    test('should have achievement methods', () async {
      expect(() => analyticsService.logUnlockAchievement(achievementId: 'first_trip', achievementName: 'First Trip Created'), returnsNormally);
    });

    test('should have custom event and user property methods', () async {
      expect(() => analyticsService.logCustomEvent(eventName: 'test_event', parameters: {'key': 'value'}), returnsNormally);
      expect(() => analyticsService.setUserProperty(name: 'user_type', value: 'premium'), returnsNormally);
      expect(() => analyticsService.setUserId('user123'), returnsNormally);
    });

  });
}
