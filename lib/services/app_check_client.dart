import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:http/http.dart' as http;

/// An [http.Client] that attaches a Firebase App Check token to each request.
class AppCheckClient extends http.BaseClient {
  AppCheckClient([http.Client? inner]) : _inner = inner ?? http.Client();

  final http.Client _inner;

  /// Obtains a valid App Check token if possible.
  Future<String?> _obtainToken() async {
    try {
      // Force refresh to ensure we request a fresh token.
      final token = await FirebaseAppCheck.instance.getToken(true);
      if (token != null) {
        return token;
      }
      // Wait for any in-flight request to complete.
      return await FirebaseAppCheck.instance.onTokenChange.first;
    } catch (e) {
      // Log the error so we understand why the token failed.
      print('Failed to obtain App Check token: $e');
      return null;
    }
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    print('Sending request to ${request.url}');
    print('Headers: ${request.headers}');
    final tokenResult = await _obtainToken();
    if (tokenResult != null) {
      request.headers['X-Firebase-AppCheck'] = tokenResult;
    }
    print('Sending request to ${request.url}');
    print('Headers: ${request.headers}');
    return _inner.send(request);
  }
}
