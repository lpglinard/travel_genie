import 'package:logging/logging.dart';

import 'location.dart';
import 'photo.dart';

class Place {
  /// Creates a logger for the Place class
  static final _logger = Logger('Place');

  const Place({
    required this.placeId,
    required this.displayName,
    required this.displayNameLanguageCode,
    required this.formattedAddress,
    required this.googleMapsUri,
    this.websiteUri,
    this.types = const [],
    this.rating,
    this.userRatingCount,
    required this.location,
    this.openingHours = const [],
    this.photos = const [],
    this.generativeSummary = '',
    this.disclosureText = '',
  });

  final String placeId;
  final String displayName;
  final String displayNameLanguageCode;
  final String formattedAddress;
  final String googleMapsUri;
  final String? websiteUri;
  final List<String> types;
  final double? rating;
  final int? userRatingCount;
  final Location location;
  final List<String> openingHours;
  final List<Photo> photos;
  final String generativeSummary;
  final String disclosureText;

  factory Place.fromJson(Map<String, dynamic> json) {
    // Parse display_name which is now an object with text and language_code
    String displayName = '';
    String displayNameLanguageCode = '';
    if (json['display_name'] is Map<String, dynamic>) {
      final displayNameObj = json['display_name'] as Map<String, dynamic>;
      displayName = displayNameObj['text'] as String? ?? '';
      displayNameLanguageCode =
          displayNameObj['language_code'] as String? ?? '';
    } else if (json['display_name'] is String) {
      // For backward compatibility
      displayName = json['display_name'] as String;
      displayNameLanguageCode = 'en'; // Default to English
    }

    // Parse generative_summary which is an object with overview and disclosure_text
    String generativeSummary = '';
    String disclosureText = '';
    if (json['generative_summary'] is Map<String, dynamic>) {
      final generativeSummaryObj =
          json['generative_summary'] as Map<String, dynamic>;
      if (generativeSummaryObj['overview'] is Map<String, dynamic>) {
        generativeSummary =
            generativeSummaryObj['overview']['text'] as String? ?? '';
      }
      if (generativeSummaryObj['disclosure_text'] is Map<String, dynamic>) {
        disclosureText =
            generativeSummaryObj['disclosure_text']['text'] as String? ?? '';
      }
    }

    return Place(
      placeId: json['place_id'] as String? ?? '',
      displayName: displayName,
      displayNameLanguageCode: displayNameLanguageCode,
      formattedAddress: json['formatted_address'] as String? ?? '',
      googleMapsUri: json['google_maps_uri'] as String? ?? '',
      websiteUri: json['website_uri'] as String?,
      types: (json['types'] as List?)?.cast<String>() ?? const [],
      rating: (json['rating'] as num?)?.toDouble(),
      userRatingCount: json['user_rating_count'] as int?,
      location: json['location'] == null
          ? const Location(lat: 0, lng: 0)
          : Location.fromJson(json['location'] as Map<String, dynamic>),
      openingHours:
          (json['opening_hours'] as List?)?.cast<String>() ?? const [],
      generativeSummary: generativeSummary,
      disclosureText: disclosureText,
      photos: () {
        final photosList = (json['photos'] as List?)?.map((e) {
          final photo = Photo.fromJson(e as Map<String, dynamic>);
          Photo.logCreation(photo);
          return photo;
        }).toList();

        if (photosList != null) {
          _logger.fine(
            'Created ${photosList.length} Photo instances for place ${json['place_id']}',
          );
        } else {
          _logger.fine(
            'No photos found for place ${json['place_id']}, using empty list',
          );
        }

        return photosList ?? const [];
      }(),
    );
  }
}
