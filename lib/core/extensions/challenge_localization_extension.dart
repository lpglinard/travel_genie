import '../../l10n/app_localizations.dart';

/// Extension to resolve challenge localization keys to localized strings.
extension ChallengeLocalizationExtension on AppLocalizations {
  /// Returns the localized title for the given [key].
  String challengeTitleFromKey(String key) {
    switch (key) {
      case 'challengeCreateAccountTitle':
        return challengeCreateAccountTitle;
      case 'challengeCompleteProfileTitle':
        return challengeCompleteProfileTitle;
      case 'challengeCreateTripTitle':
        return challengeCreateTripTitle;
      case 'challengeSavePlaceTitle':
        return challengeSavePlaceTitle;
      case 'challengeGenerateItineraryTitle':
        return challengeGenerateItineraryTitle;
      default:
        return key;
    }
  }

  /// Returns the localized description for the given [key].
  String challengeDescriptionFromKey(String key) {
    switch (key) {
      case 'challengeCreateAccountDescription':
        return challengeCreateAccountDescription;
      case 'challengeCompleteProfileDescription':
        return challengeCompleteProfileDescription;
      case 'challengeCreateTripDescription':
        return challengeCreateTripDescription;
      case 'challengeSavePlaceDescription':
        return challengeSavePlaceDescription;
      case 'challengeGenerateItineraryDescription':
        return challengeGenerateItineraryDescription;
      default:
        return key;
    }
  }
}
