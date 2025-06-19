class Photo {
  const Photo({
    required this.reference,
    this.width,
    this.height,
    this.url,
  });

  final String reference;
  final int? width;
  final int? height;
  final String? url;

  /// Returns a photo URL using the provided [apiKey]. If [url] is already
  /// present, it is returned as is. Otherwise the URL is constructed following
  /// the Google Places photo API format.
  String urlWithKey(String apiKey) {
    return url ??
        'https://maps.googleapis.com/maps/api/place/photo'
        '?maxwidth=400'
        '&photo_reference=$reference'
        '&key=$apiKey';
  }

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      reference: json['reference'] as String? ?? '',
      width: json['width'] as int?,
      height: json['height'] as int?,
      url: json['url'] as String?,
    );
  }
}
