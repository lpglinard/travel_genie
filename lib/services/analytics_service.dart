import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_performance/firebase_performance.dart';

class AnalyticsService {
  AnalyticsService()
    : _analytics = FirebaseAnalytics.instance,
      _performance = FirebasePerformance.instance;

  final FirebaseAnalytics _analytics;
  final FirebasePerformance _performance;

  FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  // Authentication Events
  Future<void> logLogin({String method = 'email'}) {
    return _analytics.logLogin(loginMethod: method);
  }

  Future<void> logSignUp({String method = 'email'}) {
    return _analytics.logSignUp(signUpMethod: method);
  }

  Future<void> logLogout() {
    return _analytics.logEvent(name: 'logout');
  }

  // Trip and Itinerary Events
  Future<void> logCreateItinerary({String? id, String? destination}) {
    return _analytics.logEvent(
      name: 'create_itinerary',
      parameters: {
        if (id != null) 'itinerary_id': id,
        if (destination != null) 'destination': destination,
      },
    );
  }

  Future<void> logViewItinerary({String? id, String? destination}) {
    return _analytics.logEvent(
      name: 'view_itinerary',
      parameters: {
        if (id != null) 'itinerary_id': id,
        if (destination != null) 'destination': destination,
      },
    );
  }

  Future<void> logEditItinerary({String? id, String? action}) {
    return _analytics.logEvent(
      name: 'edit_itinerary',
      parameters: {
        if (id != null) 'itinerary_id': id,
        if (action != null) 'action': action,
      },
    );
  }

  Future<void> logDeleteItinerary({String? id}) {
    return _analytics.logEvent(
      name: 'delete_itinerary',
      parameters: id != null ? {'itinerary_id': id} : null,
    );
  }

  Future<void> logShareItinerary({String? id, String? method}) {
    return _analytics.logEvent(
      name: 'share_itinerary',
      parameters: {
        if (id != null) 'itinerary_id': id,
        if (method != null) 'share_method': method,
      },
    );
  }

  // Place and Location Events
  Future<void> logSearchPlace({String? query, String? location}) {
    return _analytics.logSearch(searchTerm: query ?? '');
  }

  Future<void> logViewPlace({String? placeId, String? placeName, String? category}) {
    return _analytics.logEvent(
      name: 'view_place',
      parameters: {
        if (placeId != null) 'place_id': placeId,
        if (placeName != null) 'place_name': placeName,
        if (category != null) 'place_category': category,
      },
    );
  }

  Future<void> logAddPlaceToItinerary({
    String? placeId,
    String? placeName,
    String? itineraryId,
    String? dayId,
  }) {
    return _analytics.logEvent(
      name: 'add_place_to_itinerary',
      parameters: {
        if (placeId != null) 'place_id': placeId,
        if (placeName != null) 'place_name': placeName,
        if (itineraryId != null) 'itinerary_id': itineraryId,
        if (dayId != null) 'day_id': dayId,
      },
    );
  }

  Future<void> logRemovePlaceFromItinerary({
    String? placeId,
    String? placeName,
    String? itineraryId,
  }) {
    return _analytics.logEvent(
      name: 'remove_place_from_itinerary',
      parameters: {
        if (placeId != null) 'place_id': placeId,
        if (placeName != null) 'place_name': placeName,
        if (itineraryId != null) 'itinerary_id': itineraryId,
      },
    );
  }

  // AI and Optimization Events
  Future<void> logUseAIOptimizer({String? itineraryId, String? optimizationType}) {
    return _analytics.logEvent(
      name: 'use_ai_optimizer',
      parameters: {
        if (itineraryId != null) 'itinerary_id': itineraryId,
        if (optimizationType != null) 'optimization_type': optimizationType,
      },
    );
  }

  Future<void> logAIRecommendation({
    String? recommendationType,
    String? placeId,
    String? accepted,
  }) {
    return _analytics.logEvent(
      name: 'ai_recommendation',
      parameters: {
        if (recommendationType != null) 'recommendation_type': recommendationType,
        if (placeId != null) 'place_id': placeId,
        if (accepted != null) 'accepted': accepted,
      },
    );
  }

  // User Engagement Events
  Future<void> logScreenView({required String screenName, String? screenClass}) {
    return _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass,
    );
  }

  Future<void> logUserEngagement({
    String? engagementType,
    int? duration,
    String? content,
  }) {
    return _analytics.logEvent(
      name: 'user_engagement',
      parameters: {
        if (engagementType != null) 'engagement_type': engagementType,
        if (duration != null) 'duration_seconds': duration,
        if (content != null) 'content': content,
      },
    );
  }

  // App Settings Events
  Future<void> logLanguageChange(String languageCode) {
    return _analytics.logEvent(
      name: 'change_language',
      parameters: {'language': languageCode},
    );
  }

  Future<void> logThemeChange(String theme) {
    return _analytics.logEvent(
      name: 'change_theme',
      parameters: {'theme': theme},
    );
  }

  // Error and Performance Events
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

  Future<void> logPerformanceMetric({
    required String metricName,
    required double value,
    String? unit,
  }) {
    return _analytics.logEvent(
      name: 'performance_metric',
      parameters: {
        'metric_name': metricName,
        'value': value,
        if (unit != null) 'unit': unit,
      },
    );
  }

  // User Interaction Events
  Future<void> logButtonTap({
    required String buttonName,
    String? screenName,
    String? context,
  }) {
    return _analytics.logEvent(
      name: 'button_tap',
      parameters: {
        'button_name': buttonName,
        if (screenName != null) 'screen_name': screenName,
        if (context != null) 'context': context,
      },
    );
  }

  Future<void> logDragStart({
    String? itemType,
    String? itemId,
    String? fromLocation,
  }) {
    return _analytics.logEvent(
      name: 'drag_start',
      parameters: {
        if (itemType != null) 'item_type': itemType,
        if (itemId != null) 'item_id': itemId,
        if (fromLocation != null) 'from_location': fromLocation,
      },
    );
  }

  Future<void> logDragEnd({
    String? itemType,
    String? itemId,
    String? toLocation,
    bool? successful,
  }) {
    return _analytics.logEvent(
      name: 'drag_end',
      parameters: {
        if (itemType != null) 'item_type': itemType,
        if (itemId != null) 'item_id': itemId,
        if (toLocation != null) 'to_location': toLocation,
        if (successful != null) 'successful': successful.toString(),
      },
    );
  }

  Future<void> logSearchInteraction({
    String? action, // 'start', 'clear', 'submit'
    String? query,
    String? screenName,
  }) {
    return _analytics.logEvent(
      name: 'search_interaction',
      parameters: {
        if (action != null) 'action': action,
        if (query != null) 'query': query,
        if (screenName != null) 'screen_name': screenName,
      },
    );
  }

  Future<void> logDialogInteraction({
    required String dialogType,
    required String action, // 'open', 'close', 'confirm', 'cancel'
    String? screenName,
  }) {
    return _analytics.logEvent(
      name: 'dialog_interaction',
      parameters: {
        'dialog_type': dialogType,
        'action': action,
        if (screenName != null) 'screen_name': screenName,
      },
    );
  }

  Future<void> logWidgetInteraction({
    required String widgetType,
    required String action,
    String? widgetId,
    String? screenName,
    Map<String, Object>? additionalData,
  }) {
    return _analytics.logEvent(
      name: 'widget_interaction',
      parameters: {
        'widget_type': widgetType,
        'action': action,
        if (widgetId != null) 'widget_id': widgetId,
        if (screenName != null) 'screen_name': screenName,
        if (additionalData != null) ...additionalData,
      },
    );
  }

  // Custom Events
  Future<void> logCustomEvent({
    required String eventName,
    Map<String, Object>? parameters,
  }) {
    return _analytics.logEvent(
      name: eventName,
      parameters: parameters,
    );
  }

  // User Properties
  Future<void> setUserProperty({
    required String name,
    required String value,
  }) {
    return _analytics.setUserProperty(name: name, value: value);
  }

  Future<void> setUserId(String? userId) {
    return _analytics.setUserId(id: userId);
  }

  // Performance Monitoring
  Trace newTrace(String traceName) {
    return _performance.newTrace(traceName);
  }

  Future<void> startTrace(String traceName) async {
    final trace = newTrace(traceName);
    await trace.start();
  }

  Future<void> stopTrace(String traceName) async {
    final trace = newTrace(traceName);
    await trace.stop();
  }
}
