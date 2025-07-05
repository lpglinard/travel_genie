import '../../../core/models/location.dart';
import '../../../core/models/photo.dart';
import 'place_categories.dart';
import 'place_category.dart';

class Place {
  Place({
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
    this.orderInDay = 0,
    this.estimatedDurationMinutes,
    PlaceCategory? category,
  }) : category = category ?? PlaceCategories.determineCategoryFromTypes(types);

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
  final int orderInDay;
  final int? estimatedDurationMinutes;
  final PlaceCategory category;

  factory Place.fromJson(Map<String, dynamic> json) {
    String displayName = '';
    String displayNameLanguageCode = '';
    final displayNameField = json['displayName'] ?? json['display_name'] ?? json['name'];
    if (displayNameField is Map<String, dynamic>) {
      displayName = displayNameField['text'] as String? ?? '';
      displayNameLanguageCode =
          ((displayNameField['languageCode'] ??
                  displayNameField['language_code'])
              as String?) ??
          '';
    } else if (displayNameField is String) {
      displayName = displayNameField;
      displayNameLanguageCode = 'en';
    }

    String generativeSummary = '';
    String disclosureText = '';
    final generativeSummaryField =
        json['generativeSummary'] ?? json['generative_summary'];
    if (generativeSummaryField is Map<String, dynamic>) {
      if (generativeSummaryField['overview'] is Map<String, dynamic>) {
        generativeSummary =
            generativeSummaryField['overview']['text'] as String? ?? '';
      }
      final disclosureTextField =
          generativeSummaryField['disclosureText'] ??
          generativeSummaryField['disclosure_text'];
      if (disclosureTextField is Map<String, dynamic>) {
        disclosureText = disclosureTextField['text'] as String? ?? '';
      }
    }

    final types = (json['types'] as List?)?.cast<String>() ?? const [];

    return Place(
      placeId:
          (json['placeId'] ?? json['id'] ?? json['place_id']) as String? ?? '',
      displayName: displayName,
      displayNameLanguageCode: displayNameLanguageCode,
      formattedAddress:
          (json['formattedAddress'] ?? json['formatted_address']) as String? ??
          '',
      googleMapsUri:
          (json['googleMapsUri'] ?? json['google_maps_uri']) as String? ?? '',
      websiteUri: (json['websiteUri'] ?? json['website_uri']) as String?,
      types: types,
      rating: (json['rating'] as num?)?.toDouble(),
      userRatingCount:
          (json['userRatingCount'] ?? json['user_rating_count']) as int?,
      location: json['location'] == null
          ? const Location(lat: 0, lng: 0)
          : Location.fromJson(json['location'] as Map<String, dynamic>),
      openingHours: () {
        if (json['currentOpeningHours'] is Map<String, dynamic> &&
            json['currentOpeningHours']['weekdayDescriptions'] is List) {
          return (json['currentOpeningHours']['weekdayDescriptions'] as List)
              .cast<String>();
        }
        return (json['opening_hours'] as List?)?.cast<String>() ?? const [];
      }(),
      generativeSummary: generativeSummary,
      disclosureText: disclosureText,
      photos: () {
        final photosList = (json['photos'] as List?)?.map((e) {
          final photo = Photo.fromJson(e as Map<String, dynamic>);
          return photo;
        }).toList();
        return photosList ?? const [];
      }(),
      orderInDay: (json['orderInDay'] as int?) ?? 0,
      estimatedDurationMinutes: (json['estimatedDurationMinutes'] as int?),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'placeId': placeId,
      'id': placeId,
      'place_id': placeId,
      'displayName': {
        'text': displayName,
        'languageCode': displayNameLanguageCode,
      },
      'formattedAddress': formattedAddress,
      'googleMapsUri': googleMapsUri,
      if (websiteUri != null) 'websiteUri': websiteUri,
      'types': types,
      if (rating != null) 'rating': rating,
      if (userRatingCount != null) 'userRatingCount': userRatingCount,
      'location': location.toMap(),
      'openingHours': openingHours,
      'photos': photos.map((p) => p.toMap()).toList(),
      if (generativeSummary.isNotEmpty || disclosureText.isNotEmpty)
        'generativeSummary': {
          'overview': {'text': generativeSummary},
          'disclosureText': {'text': disclosureText},
        },
      'category': category.id,
      'orderInDay': orderInDay,
      if (estimatedDurationMinutes != null) 'estimatedDurationMinutes': estimatedDurationMinutes,
    };
  }
}
