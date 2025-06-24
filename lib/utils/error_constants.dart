/// Constants for error messages used throughout the application.
/// 
/// These constants are used to identify error types and can be translated
/// at the UI level using the app's internationalization system.
class ErrorConstants {
  // Authentication errors
  static const String userNotLoggedIn = 'USER_NOT_LOGGED_IN';
  
  // Service operation errors
  static const String daySummaryFetchFailed = 'DAY_SUMMARY_FETCH_FAILED';
  static const String daySummaryAddPlaceSuccess = 'DAY_SUMMARY_ADD_PLACE_SUCCESS';
  static const String daySummaryAddPlaceError = 'DAY_SUMMARY_ADD_PLACE_ERROR';
  static const String daySummaryReorderPlaceSuccess = 'DAY_SUMMARY_REORDER_PLACE_SUCCESS';
  static const String daySummaryReorderPlaceError = 'DAY_SUMMARY_REORDER_PLACE_ERROR';
  static const String daySummaryRemovePlaceSuccess = 'DAY_SUMMARY_REMOVE_PLACE_SUCCESS';
  static const String daySummaryRemovePlaceError = 'DAY_SUMMARY_REMOVE_PLACE_ERROR';
}