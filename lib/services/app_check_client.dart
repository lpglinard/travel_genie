import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:http/http.dart' as http;

/// An [http.Client] that attaches a Firebase App Check token to each request.
class AppCheckClient extends http.BaseClient {
  AppCheckClient([http.Client? inner]) : _inner = inner ?? http.Client();

  final http.Client _inner;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    try {
      final tokenResult = await FirebaseAppCheck.instance.getToken();
      final token = tokenResult.token;
      if (token != null) {
        request.headers['X-Firebase-AppCheck'] = token;
      }
    } catch (_) {
      // If App Check token retrieval fails, send the request without it.
    }
    return _inner.send(request);
  }
}
