import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_performance/firebase_performance.dart';

/// Refactored Analytics Service following Firebase Analytics Strategy
/// 
/// This service implements Firebase standard events and follows the recommendations
/// from firebase_analytics_strategy.md for better integration with Firebase's
/// analytics dashboard and Google Ads.
class AnalyticsService {
  AnalyticsService()
    : _analytics = FirebaseAnalytics.instance,
      _performance = FirebasePerformance.instance;

  final FirebaseAnalytics _analytics;
  final FirebasePerformance _performance;

  /// Direct access to Firebase Analytics for standard events
  FirebaseAnalytics get analytics => _analytics;

  FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  // ============================================================================
  // AUTHENTICATION EVENTS - Using Firebase Standard Events
  // ============================================================================

  /// Track user login using Firebase standard event
  Future<void> logLogin({String method = 'email'}) {
    return _analytics.logLogin(loginMethod: method);
  }

  /// Track user signup using Firebase standard event with Google Ads conversion
  Future<void> logSignUp({String method = 'email'}) {
    // Log Google Ads conversion for signup
    _analytics.logEvent(
      name: 'ad_conversion',
      parameters: {
        'campaign_id': "web-traffic-Performance-Max-1",
        'value': 1.0,
        'currency': 'USD',
      },
    );
    return _analytics.logSignUp(signUpMethod: method);
  }

  /// Track user logout - keeping as custom event since no Firebase standard exists
  Future<void> logLogout() {
    return _analytics.logEvent(name: 'logout');
  }

  // ============================================================================
  // TRIP AND ITINERARY EVENTS - Using Firebase Standard Events
  // ============================================================================

  /// Track itinerary creation using Firebase standard begin_checkout event
  /// This is the primary conversion event for trip planning
  Future<void> logCreateItinerary({
    String? tripId,
    String? destination,
    double? value,
    String currency = 'USD',
    List<AnalyticsEventItem>? items,
  }) {
    return _analytics.logBeginCheckout(
      value: value ?? 0.0,
      currency: currency,
      items: items,
      parameters: {
        if (tripId != null) 'trip_id': tripId,
        if (destination != null) 'destination': destination,
      },
    );
  }

  /// Track itinerary viewing using Firebase standard view_item event
  Future<void> logViewItinerary({
    String? tripId,
    String? destination,
    double? value,
    String currency = 'USD',
    List<AnalyticsEventItem>? items,
  }) {
    return _analytics.logViewItem(
      currency: currency,
      value: value ?? 0.0,
      items: items ?? [
        AnalyticsEventItem(
          itemId: tripId ?? 'unknown',
          itemName: destination ?? 'Unknown Destination',
          itemCategory: 'trip',
        )
      ],
    );
  }

  /// Track itinerary sharing using Firebase standard share event
  Future<void> logShareItinerary({
    String? tripId,
    String? method,
    String contentType = 'trip',
  }) {
    return _analytics.logShare(
      contentType: contentType,
      itemId: tripId ?? 'unknown',
      method: method ?? 'unknown',
    );
  }

  /// Track itinerary editing using Firebase standard select_content event
  Future<void> logEditItinerary({String? tripId, String? action}) {
    return _analytics.logSelectContent(
      contentType: 'trip',
      itemId: tripId ?? 'unknown',
      parameters: {
        if (tripId != null) 'trip_id': tripId,
        if (action != null) 'edit_action': action,
      },
    );
  }

  /// Track itinerary deletion - custom event (no Firebase standard equivalent)
  Future<void> logDeleteItinerary({String? tripId}) {
    return _analytics.logEvent(
      name: 'delete_itinerary',
      parameters: tripId != null ? {'trip_id': tripId} : null,
    );
  }

  // ============================================================================
  // PLACE AND LOCATION EVENTS - Using Firebase Standard Events
  // ============================================================================

  /// Track place search using Firebase standard search event
  Future<void> logSearchPlace({String? searchTerm, String? location}) {
    return _analytics.logSearch(searchTerm: searchTerm ?? '');
  }

  /// Track place viewing using Firebase standard view_item event
  Future<void> logViewPlace({
    String? placeId,
    String? placeName,
    String? category,
    double? value,
    String currency = 'USD',
  }) {
    return _analytics.logViewItem(
      currency: currency,
      value: value ?? 0.0,
      items: [
        AnalyticsEventItem(
          itemId: placeId ?? 'unknown',
          itemName: placeName ?? 'Unknown Place',
          itemCategory: category ?? 'place',
        )
      ],
    );
  }

  /// Track adding place to itinerary using Firebase standard add_to_cart event
  /// Treats trip building like e-commerce
  Future<void> logAddPlaceToItinerary({
    String? placeId,
    String? placeName,
    String? category,
    String? tripId,
    String? dayId,
    double? value,
    String currency = 'USD',
  }) {
    return _analytics.logAddToCart(
      currency: currency,
      value: value ?? 0.0,
      items: [
        AnalyticsEventItem(
          itemId: placeId ?? 'unknown',
          itemName: placeName ?? 'Unknown Place',
          itemCategory: category ?? 'place',
          parameters: {
            if (tripId != null) 'trip_id': tripId,
            if (dayId != null) 'day_id': dayId,
          },
        )
      ],
    );
  }

  /// Track removing place from itinerary using Firebase standard remove_from_cart event
  Future<void> logRemovePlaceFromItinerary({
    String? placeId,
    String? placeName,
    String? category,
    String? tripId,
    double? value,
    String currency = 'USD',
  }) {
    return _analytics.logRemoveFromCart(
      currency: currency,
      value: value ?? 0.0,
      items: [
        AnalyticsEventItem(
          itemId: placeId ?? 'unknown',
          itemName: placeName ?? 'Unknown Place',
          itemCategory: category ?? 'place',
          parameters: {
            if (tripId != null) 'trip_id': tripId,
          },
        )
      ],
    );
  }

  // ============================================================================
  // AI AND OPTIMIZATION EVENTS - Custom Conversion Events
  // ============================================================================

  /// Track AI optimizer usage - custom conversion event for Google Ads
  /// This is a key conversion event that should be imported into Google Ads
  Future<void> logOptimizeItinerary({
    String? tripId,
    String? optimizerType,
    double? value,
    String currency = 'USD',
  }) {
    return _analytics.logEvent(
      name: 'optimize_itinerary',
      parameters: {
        if (tripId != null) 'trip_id': tripId,
        if (optimizerType != null) 'optimizer_type': optimizerType,
        'value': value ?? 1.0,
        'currency': currency,
      },
    );
  }

  /// Track AI recommendation interactions using Firebase standard select_content event
  Future<void> logAIRecommendation({
    String? recommendationType,
    String? placeId,
    bool? accepted,
  }) {
    return _analytics.logSelectContent(
      contentType: 'ai_recommendation',
      itemId: placeId ?? 'unknown',
      parameters: {
        if (recommendationType != null)
          'recommendation_type': recommendationType,
        if (placeId != null) 'place_id': placeId,
        if (accepted != null) 'accepted': accepted,
      },
    );
  }

  // ============================================================================
  // USER ENGAGEMENT EVENTS - Firebase Standard Events
  // ============================================================================

  /// Track screen views using Firebase standard event
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) {
    return _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass,
    );
  }

  /// Track tutorial completion using Firebase standard event
  Future<void> logTutorialComplete() {
    return _analytics.logTutorialComplete();
  }

  /// Track tutorial begin using Firebase standard event
  Future<void> logTutorialBegin() {
    return _analytics.logTutorialBegin();
  }

  // ============================================================================
  // APP SETTINGS AND USER PROPERTIES - Simplified
  // ============================================================================

  /// Track language changes - custom event for user segmentation
  Future<void> logLanguageChange(String languageCode) {
    // Set user property for segmentation
    setUserProperty(name: 'preferred_language', value: languageCode);

    return _analytics.logEvent(
      name: 'change_language',
      parameters: {'language': languageCode},
    );
  }

  /// Track theme changes - custom event for user segmentation
  Future<void> logThemeChange(String theme) {
    // Set user property for segmentation
    setUserProperty(name: 'app_theme', value: theme);

    return _analytics.logEvent(
      name: 'change_theme',
      parameters: {'theme': theme},
    );
  }

  // ============================================================================
  // ERROR TRACKING - Simplified
  // ============================================================================

  /// Track application errors
  Future<void> logError({
    required String errorType,
    String? errorMessage,
    String? screenName,
  }) {
    return _analytics.logEvent(
      name: 'app_error',
      parameters: {
        'error_type': errorType,
        if (errorMessage != null) 'error_message': errorMessage,
        if (screenName != null) 'screen_name': screenName,
      },
    );
  }

  // ============================================================================
  // GAMIFICATION EVENTS - Firebase Standard Events
  // ============================================================================

  /// Track achievement unlocks using Firebase standard event
  /// Updates achievement_count user property for segmentation
  Future<void> logUnlockAchievement({
    required String achievementId,
    String? achievementName,
    String? category,
  }) async {
    // Log the achievement unlock
    await _analytics.logUnlockAchievement(
      id: achievementId,
      parameters: <String, Object>{
        'achievement_id': achievementId,
        if (achievementName != null) 'achievement_name': achievementName,
        if (category != null) 'category': category,
        'value': 1,
      },
    );

    // Update user property for segmentation (simplified - would need actual count in real implementation)
    await setUserProperty(name: 'latest_achievement', value: achievementId);
  }

  /// Track level progression using Firebase standard event
  Future<void> logLevelUp({
    required int level,
    String? character,
  }) {
    return _analytics.logLevelUp(
      level: level,
      character: character,
    );
  }

  // ============================================================================
  // USER PROPERTIES AND SEGMENTATION
  // ============================================================================

  /// Set user properties for segmentation as defined in strategy
  Future<void> setUserProperty({required String name, required String value}) {
    return _analytics.setUserProperty(name: name, value: value);
  }

  /// Set user ID for tracking
  Future<void> setUserId(String? userId) {
    return _analytics.setUserId(id: userId);
  }

  /// Set onboarding completion status
  Future<void> setOnboardingComplete(bool completed) {
    return setUserProperty(name: 'onboarded', value: completed.toString());
  }

  /// Set user rank for gamification segmentation
  Future<void> setUserRank(String rank) {
    return setUserProperty(name: 'user_rank', value: rank);
  }

  // ============================================================================
  // PERFORMANCE MONITORING - Simplified
  // ============================================================================

  /// Create new performance trace
  Trace newTrace(String traceName) {
    return _performance.newTrace(traceName);
  }

  // ============================================================================
  // CUSTOM EVENTS - For business-specific needs
  // ============================================================================

  /// Log custom events when Firebase standard events don't fit
  Future<void> logCustomEvent({
    required String eventName,
    Map<String, Object>? parameters,
  }) {
    return _analytics.logEvent(name: eventName, parameters: parameters);
  }
}
