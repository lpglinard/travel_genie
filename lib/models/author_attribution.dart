/// A class representing an author attribution for a photo.
class AuthorAttribution {
  const AuthorAttribution({required this.displayName, this.uri, this.photoUri});

  final String displayName;
  final String? uri;
  final String? photoUri;

  factory AuthorAttribution.fromJson(Map<String, dynamic> json) {
    return AuthorAttribution(
      displayName:
          (json['displayName'] ?? json['display_name']) as String? ?? '',
      uri: json['uri'] as String?,
      photoUri: (json['photoUri'] ?? json['photo_uri']) as String?,
    );
  }
}
