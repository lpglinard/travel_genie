import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:travel_genie/models/user_deletion_request.dart';
import 'package:travel_genie/models/user_deletion_response.dart';

class UserDeletionService {
  UserDeletionService({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  // Base URL following the pattern from other services
  static const String baseUrl =
      'https://sophisticated-chimera.odsy.to/user-management';
  static const String deleteUserDataEndpoint = '/delete-user-data';

  Future<UserDeletionResponse> deleteAllUserData(String userId) async {
    try {
      // Get the current Firebase user and ID token
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Get the Firebase ID token for authentication
      final String? idToken = await currentUser.getIdToken();
      if (idToken == null) {
        throw Exception('Failed to get authentication token');
      }

      // Create the request body
      final UserDeletionRequest request = UserDeletionRequest(userId: userId);

      // Log request details
      print('=== Request Details ===');
      print('URL: $baseUrl$deleteUserDataEndpoint');
      print('Headers:');
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
        'User-Agent': 'Flutter App',
      };
      headers.forEach((key, value) {
        // Oculta o token real por segurança
        if (key == 'Authorization') {
          print('  $key: Bearer ${value}');
        } else {
          print('  $key: $value');
        }
      });
      print('Request Body:');
      print(const JsonEncoder.withIndent('  ').convert(request.toJson()));
      print('==================\n');

      // Make the HTTP POST request
      final response = await _client.post(
        Uri.parse('$baseUrl$deleteUserDataEndpoint'),
        headers: headers,
        body: jsonEncode(request.toJson()),
      );

      // Parse the response
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return UserDeletionResponse.fromJson(responseData);
      } else {
        // Handle HTTP error responses
        String errorMessage = 'HTTP ${response.statusCode}';
        try {
          final Map<String, dynamic> errorData = jsonDecode(response.body);
          errorMessage = errorData['errorMessage'] ?? errorMessage;
        } catch (e) {
          // If response body is not JSON, use status code
        }

        return UserDeletionResponse(
          userId: userId,
          success: false,
          errorMessage: errorMessage,
          message: 'Failed to delete user data',
          timestamp: DateTime.now().millisecondsSinceEpoch,
        );
      }
    } catch (e) {
      // Handle network errors, JSON parsing errors, etc.
      return UserDeletionResponse(
        userId: userId,
        success: false,
        errorMessage: 'Network error: ${e.toString()}',
        message: 'Failed to connect to server',
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
    }
  }
}
