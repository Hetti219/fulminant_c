import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart' as app_user;

class AuthRepository {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRepository({
    firebase_auth.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<firebase_auth.User?> get user => _firebaseAuth.authStateChanges();

  firebase_auth.User? get currentUser => _firebaseAuth.currentUser;

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required DateTime dateOfBirth,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        final user = app_user.User(
          id: credential.user!.uid,
          email: email,
          fullName: fullName,
          dateOfBirth: dateOfBirth,
          points: 0,
          createdAt: DateTime.now(),
        );

        await _firestore.collection('users').doc(user.id).set(user.toMap());
      }
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  Future<app_user.User?> getUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return app_user.User.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  Future<void> updateUserData(app_user.User user) async {
    try {
      await _firestore.collection('users').doc(user.id).update(user.toMap());
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  Future<void> updateUserProfile(String userId, String fullName) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'fullName': fullName,
      });
    } catch (e) {
      throw AuthException(e.toString());
    }
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}