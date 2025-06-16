import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_performance/firebase_performance.dart';

class AnalyticsService {
  AnalyticsService()
      : _analytics = FirebaseAnalytics.instance,
        _performance = FirebasePerformance.instance;

  final FirebaseAnalytics _analytics;
  final FirebasePerformance _performance;

  FirebaseAnalyticsObserver get observer => FirebaseAnalyticsObserver(analytics: _analytics);

  Future<void> logLogin({String method = 'email'}) {
    return _analytics.logLogin(loginMethod: method);
  }

  Future<void> logSignUp({String method = 'email'}) {
    return _analytics.logSignUp(signUpMethod: method);
  }

  Future<void> logCreateItinerary({String? id}) {
    return _analytics.logEvent(
      name: 'create_itinerary',
      parameters: id != null ? {'itinerary_id': id} : null,
    );
  }

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
}
