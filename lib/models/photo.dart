import 'author_attribution.dart';

/// A class representing a photo from Google Places API.
class Photo {
  /// Creates a new Photo instance.
  ///
  /// [reference] is the photo reference from Google Places API.
  /// [width] is the optional width of the photo.
  /// [height] is the optional height of the photo.
  /// [url] is the optional direct URL to the photo.
  /// [authorAttributions] is the optional list of author attributions.
  /// [flagContentUri] is the optional URI for flagging content.
  /// [googleMapsUri] is the optional URI for viewing the photo on Google Maps.
  const Photo({
    required this.reference,
    this.width,
    this.height,
    this.url,
    this.authorAttributions = const [],
    this.flagContentUri,
    this.googleMapsUri,
  });

  final String reference;
  final int? width;
  final int? height;
  final String? url;
  final List<AuthorAttribution> authorAttributions;
  final String? flagContentUri;
  final String? googleMapsUri;

  /// Returns a photo URL using the provided [apiKey]. If [url] is already
  /// present, it is returned as is. Otherwise the URL is constructed following
  /// the Google Places photo API format.
  String urlWithKey(String apiKey) {
    final result =
        url ??
        'https://places.googleapis.com/v1/$reference/media'
            '?key=$apiKey'
            '&maxWidthPx=800';

    return result;
  }

  /// Creates a Photo instance from a JSON map.
  ///
  /// The JSON map should contain the following keys:
  /// - reference: String (required)
  /// - width: int (optional)
  /// - height: int (optional)
  /// - url: String (optional)
  /// - author_attributions: List (optional)
  /// - flag_content_uri: String (optional)
  /// - google_maps_uri: String (optional)
  factory Photo.fromJson(Map<String, dynamic> json) {
    final reference = (json['name'] ?? json['reference']) as String? ?? '';
    final width = (json['widthPx'] ?? json['width']) as int?;
    final height = (json['heightPx'] ?? json['height']) as int?;
    final url = json['url'] as String?;
    final flagContentUri =
        (json['flagContentUri'] ?? json['flag_content_uri']) as String?;
    final googleMapsUri =
        (json['googleMapsUri'] ?? json['google_maps_uri']) as String?;

    // Parse author attributions
    final authorAttributionsList =
        ((json['authorAttributions'] ?? json['author_attributions']) as List?)
            ?.map((e) => AuthorAttribution.fromJson(e as Map<String, dynamic>))
            .toList() ??
        const [];

    return Photo(
      reference: reference,
      width: width,
      height: height,
      url: url,
      authorAttributions: authorAttributionsList,
      flagContentUri: flagContentUri,
      googleMapsUri: googleMapsUri,
    );
  }
}
