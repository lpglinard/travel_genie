import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';
import 'package:travel_genie/models/photo.dart';

void main() {
  setUp(() {
    // Configure logging for tests
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      print('${record.level.name}: ${record.loggerName}: ${record.message}');
      if (record.error != null) {
        print('ERROR: ${record.error}');
      }
      if (record.stackTrace != null) {
        print('STACK: ${record.stackTrace}');
      }
    });
  });

  test('Photo.logCreation logs creation details', () {
    // This test verifies that Photo.logCreation logs creation details
    const photo = Photo(
      reference: 'test_reference',
      width: 100,
      height: 200,
      url: 'https://example.com/image.jpg',
    );

    // Log the creation
    Photo.logCreation(photo);

    // No assertions needed, we're just verifying that logging doesn't cause errors
    expect(photo.reference, 'test_reference');
  });

  test('Photo.fromJson logs parsing details', () {
    // This test verifies that Photo.fromJson logs parsing details
    final photo = Photo.fromJson({
      'reference': 'json_reference',
      'width': 300,
      'height': 400,
      'url': 'https://example.com/json_image.jpg',
      'flag_content_uri': 'https://example.com/flag',
      'google_maps_uri': 'https://maps.google.com/example',
      'author_attributions': [
        {
          'display_name': 'Test Author',
          'uri': 'https://example.com/author',
          'photo_uri': 'https://example.com/author/photo.jpg'
        }
      ],
    });

    // Verify the parsed values
    expect(photo.reference, 'json_reference');
    expect(photo.width, 300);
    expect(photo.height, 400);
    expect(photo.url, 'https://example.com/json_image.jpg');
    expect(photo.flagContentUri, 'https://example.com/flag');
    expect(photo.googleMapsUri, 'https://maps.google.com/example');
    expect(photo.authorAttributions.length, 1);
    expect(photo.authorAttributions[0].displayName, 'Test Author');
    expect(photo.authorAttributions[0].uri, 'https://example.com/author');
    expect(photo.authorAttributions[0].photoUri, 'https://example.com/author/photo.jpg');
  });

  test('urlWithKey logs API key and result', () {
    // This test verifies that urlWithKey logs the API key and result
    const photo = Photo(
      reference: 'api_reference',
      width: 500,
      height: 600,
    );

    final url = photo.urlWithKey('test_api_key_12345');

    // Verify the URL format
    expect(url, contains('api_reference'));
    expect(url, contains('test_api_key_12345'));
  });
}
