import 'location.dart';
import 'photo.dart';

class Place {
  const Place({
    required this.placeId,
    required this.displayName,
    required this.formattedAddress,
    required this.googleMapsUri,
    this.websiteUri,
    this.types = const [],
    this.rating,
    this.userRatingCount,
    required this.location,
    this.openingHours = const [],
    this.photos = const [],
  });

  final String placeId;
  final String displayName;
  final String formattedAddress;
  final String googleMapsUri;
  final String? websiteUri;
  final List<String> types;
  final double? rating;
  final int? userRatingCount;
  final Location location;
  final List<String> openingHours;
  final List<Photo> photos;

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      placeId: json['place_id'] as String? ?? '',
      displayName: json['display_name'] as String? ?? '',
      formattedAddress: json['formatted_address'] as String? ?? '',
      googleMapsUri: json['google_maps_uri'] as String? ?? '',
      websiteUri: json['website_uri'] as String?,
      types: (json['types'] as List?)?.cast<String>() ?? const [],
      rating: (json['rating'] as num?)?.toDouble(),
      userRatingCount: json['user_rating_count'] as int?,
      location: json['location'] == null
          ? const Location(lat: 0, lng: 0)
          : Location.fromJson(json['location'] as Map<String, dynamic>),
      openingHours: (json['opening_hours'] as List?)?.cast<String>() ?? const [],
      photos: (json['photos'] as List?)
              ?.map((e) => Photo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}
