import 'package:firebase_auth/firebase_auth.dart';

/// Service wrapper around [FirebaseAuth] to allow dependency injection
/// and simplify authentication-related operations.
class AuthService {
  const AuthService(this._firebaseAuth);

  final FirebaseAuth _firebaseAuth;

  /// Currently authenticated user or `null` if not signed in.
  User? get currentUser => _firebaseAuth.currentUser;

  /// Stream of authentication state changes.
  Stream<User?> authStateChanges() => _firebaseAuth.authStateChanges();

  /// Sign the current user out.
  Future<void> signOut() => _firebaseAuth.signOut();
}
