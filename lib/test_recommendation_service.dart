import 'dart:convert';
import 'dart:io';
import 'dart:developer';
import 'package:travel_genie/models/place.dart';

Future<void> main() async {
  print('Starting test...');

  try {
    // Load the fortaleza.json file
    print('Loading fortaleza.json file...');
    final file = File('fortaleza.json');
    final jsonString = await file.readAsString();
    print('File loaded successfully. Length: ${jsonString.length}');
    print('First 100 characters: ${jsonString.substring(0, jsonString.length > 100 ? 100 : jsonString.length)}');

    // Parse the JSON
    print('Parsing JSON...');
    final jsonData = json.decode(jsonString);
    print('JSON type: ${jsonData.runtimeType}');

    if (jsonData is Map<String, dynamic>) {
      print('JSON keys: ${jsonData.keys.join(', ')}');

      if (jsonData.containsKey('places')) {
        final places = jsonData['places'];
        print('Places type: ${places.runtimeType}');

        if (places is List) {
          print('Found ${places.length} places in the response');

          // Convert the places to Place objects
          print('Converting to Place objects...');
          final placeObjects = places
              .map((e) => Place.fromJson(e as Map<String, dynamic>))
              .toList();

          print('Successfully parsed ${placeObjects.length} places');
          if (placeObjects.isNotEmpty) {
            print('First place: ${placeObjects.first.displayName}');
          } else {
            print('No places found in the response');
          }

          // If we get here, the test passed
          print('TEST PASSED: Successfully parsed the response');
        } else {
          print('TEST FAILED: The "places" field is not a List: ${places.runtimeType}');
        }
      } else {
        print('TEST FAILED: JSON does not contain a "places" key');
      }
    } else {
      print('TEST FAILED: JSON is not a Map: ${jsonData.runtimeType}');
    }
  } catch (e, st) {
    // If we get here, there was an error
    print('TEST FAILED: ${e.toString()}');
    print('Stack trace: $st');
  }
}
