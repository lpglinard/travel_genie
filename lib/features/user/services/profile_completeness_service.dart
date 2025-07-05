/// Service for calculating traveler profile completeness
/// Follows Single Responsibility Principle - only handles profile completeness calculation
/// Follows Dependency Inversion Principle - depends on abstractions

import '../models/traveler_profile.dart';

/// Data model for profile completeness information
class ProfileCompletenessInfo {
  const ProfileCompletenessInfo({
    required this.percentage,
    required this.completedFields,
    required this.totalFields,
    required this.missingFields,
  });

  final double percentage;
  final int completedFields;
  final int totalFields;
  final List<String> missingFields;

  /// Convert percentage to integer for display
  int get percentageAsInt => (percentage * 100).round();

  /// Check if profile is complete
  bool get isComplete => percentage == 1.0;
}

/// Service for calculating profile completeness based on TravelerProfile
class ProfileCompletenessService {
  /// Calculate profile completeness based on TravelerProfile
  /// This is the unified logic that should be used by all widgets
  static ProfileCompletenessInfo calculateCompleteness(TravelerProfile? profile) {
    if (profile == null) {
      return const ProfileCompletenessInfo(
        percentage: 0.0,
        completedFields: 0,
        totalFields: 6,
        missingFields: [
          'travelCompany',
          'budget',
          'accommodationTypes',
          'interests',
          'gastronomicPreferences',
          'itineraryStyle',
        ],
      );
    }

    int completedFields = 0;
    const int totalFields = 6;
    final List<String> missingFields = [];

    // Check each field according to the same logic as TravelerProfile.isComplete
    if (profile.travelCompany.isNotEmpty) {
      completedFields++;
    } else {
      missingFields.add('travelCompany');
    }

    if (profile.budget != null) {
      completedFields++;
    } else {
      missingFields.add('budget');
    }

    if (profile.accommodationTypes.isNotEmpty) {
      completedFields++;
    } else {
      missingFields.add('accommodationTypes');
    }

    if (profile.interests.isNotEmpty) {
      completedFields++;
    } else {
      missingFields.add('interests');
    }

    if (profile.gastronomicPreferences.isNotEmpty) {
      completedFields++;
    } else {
      missingFields.add('gastronomicPreferences');
    }

    if (profile.itineraryStyle != null) {
      completedFields++;
    } else {
      missingFields.add('itineraryStyle');
    }

    final percentage = completedFields / totalFields;

    return ProfileCompletenessInfo(
      percentage: percentage,
      completedFields: completedFields,
      totalFields: totalFields,
      missingFields: missingFields,
    );
  }
}