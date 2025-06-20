import 'package:logging/logging.dart';

/// A class representing an author attribution for a photo.
class AuthorAttribution {
  /// Creates a logger for the AuthorAttribution class
  static final _logger = Logger('AuthorAttribution');

  const AuthorAttribution({required this.displayName, this.uri, this.photoUri});

  final String displayName;
  final String? uri;
  final String? photoUri;

  factory AuthorAttribution.fromJson(Map<String, dynamic> json) {
    _logger.fine('AuthorAttribution.fromJson called with: $json');
    
    return AuthorAttribution(
      displayName: json['display_name'] as String? ?? '',
      uri: json['uri'] as String?,
      photoUri: json['photo_uri'] as String?,
    );
  }
}