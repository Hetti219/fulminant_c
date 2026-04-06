import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/user.dart' as app_user;

abstract class AuthRepository {
  Stream<firebase_auth.User?> get user;

  firebase_auth.User? get currentUser;

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required DateTime dateOfBirth,
  });

  Future<void> signIn({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<app_user.User?> getUserData(String userId);

  Future<void> updateUserData(app_user.User user);

  Future<void> updateUserProfile(String userId, String fullName);

  Future<void> sendPasswordResetEmail(String email);

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}

class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => message;
}
